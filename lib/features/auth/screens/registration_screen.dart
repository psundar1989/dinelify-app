import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/location.dart';
import '../../../data/models/room.dart';
import '../../../data/providers.dart';
import '../../../data/services/user_service.dart';
import '../providers/auth_controller.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key, this.mobile = ''});

  final String mobile;

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _mobileController = TextEditingController(text: widget.mobile);

  List<LocationModel> _locations = [];
  List<RoomModel> _rooms = [];
  int? _locationId;
  int? _roomId;

  bool _isLoadingLocations = true;
  bool _isLoadingRooms = false;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _error;
  RegisterResult? _pendingLogin;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await ref.read(locationRepositoryProvider).locations();
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _isLoadingLocations = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoadingLocations = false;
      });
    }
  }

  Future<void> _onLocationChanged(int? locationId) async {
    setState(() {
      _locationId = locationId;
      _roomId = null;
      _rooms = [];
      _isLoadingRooms = locationId != null;
    });
    if (locationId == null) return;

    try {
      final rooms = await ref.read(locationRepositoryProvider).rooms(locationId);
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _isLoadingRooms = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRooms = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_locationId == null || _roomId == null) {
      setState(() => _error = 'Please select your delivery location and room number.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(userRepositoryProvider)
          .register(
            name: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            locationId: _locationId!,
            roomId: _roomId!,
          );
      // Registration also logs the user in (the API returns a token), but
      // we hold off updating authControllerProvider until they tap through
      // the success screen below, so the router doesn't yank them into the
      // dashboard before they've seen "Registration successful".
      if (!mounted) return;
      setState(() {
        _isSuccess = true;
        _pendingLogin = result;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('mobile') ?? e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _continueToOrderFood() async {
    final result = _pendingLogin;
    if (result == null) return;
    await ref.read(authControllerProvider.notifier).onLoggedIn(token: result.token, user: result.user);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccess(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: _isLoadingLocations
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(label: 'Full Name', controller: _nameController, validator: Validators.name),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Mobile Number',
                      controller: _mobileController,
                      hintText: '9876543210',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.mobile,
                    ),
                    const SizedBox(height: 16),
                    Text('Delivery Location', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _locationId,
                      hint: const Text('Select location'),
                      items: _locations
                          .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
                          .toList(),
                      onChanged: _onLocationChanged,
                    ),
                    const SizedBox(height: 16),
                    Text('Room Number', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _roomId,
                      hint: Text(_isLoadingRooms ? 'Loading rooms…' : 'Select room'),
                      items: _rooms
                          .map((r) => DropdownMenuItem(value: r.id, child: Text(r.roomNumber)))
                          .toList(),
                      onChanged: _rooms.isEmpty ? null : (value) => setState(() => _roomId = value),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.danger)),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(label: 'Register', onPressed: _submit, isLoading: _isSubmitting),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 72),
              const SizedBox(height: 16),
              Text('Registration Successful', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                "You're all set. Continue to order your meals.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Order Food', onPressed: _continueToOrderFood),
            ],
          ),
        ),
      ),
    );
  }
}
