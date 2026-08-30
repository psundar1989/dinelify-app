import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/location.dart';
import '../../../data/models/room.dart';
import '../../../data/providers.dart';
import '../../auth/providers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  List<LocationModel> _locations = [];
  List<RoomModel> _rooms = [];
  int? _locationId;
  int? _roomId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _locationId = user?.location?.id;
    _roomId = user?.room?.id;
    _load();
  }

  Future<void> _load() async {
    try {
      final locations = await ref.read(locationRepositoryProvider).locations();
      final rooms = _locationId != null
          ? await ref.read(locationRepositoryProvider).rooms(_locationId!)
          : <RoomModel>[];
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _rooms = rooms;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _onLocationChanged(int? locationId) async {
    setState(() {
      _locationId = locationId;
      _roomId = null;
      _rooms = [];
    });
    if (locationId == null) return;
    final rooms = await ref.read(locationRepositoryProvider).rooms(locationId);
    if (!mounted) return;
    setState(() => _rooms = rooms);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref
          .read(userRepositoryProvider)
          .updateProfile(name: _nameController.text.trim(), locationId: _locationId, roomId: _roomId);
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(label: 'Full Name', controller: _nameController, validator: Validators.name),
                    const SizedBox(height: 16),
                    Text('Delivery Location', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _locationId,
                      items: _locations.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(),
                      onChanged: _onLocationChanged,
                    ),
                    const SizedBox(height: 16),
                    Text('Room Number', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _roomId,
                      items: _rooms.map((r) => DropdownMenuItem(value: r.id, child: Text(r.roomNumber))).toList(),
                      onChanged: _rooms.isEmpty ? null : (value) => setState(() => _roomId = value),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(label: 'Save Changes', onPressed: _save, isLoading: _isSaving),
                  ],
                ),
              ),
            ),
    );
  }
}
