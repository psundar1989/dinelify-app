import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/providers.dart';
import '../providers/auth_controller.dart';

/// "Order Food" entry point for existing users: enter the registered
/// mobile number and continue — no OTP, no email. The number is used to
/// look the account up directly, matching the website.
class OrderMobileEntryScreen extends ConsumerStatefulWidget {
  const OrderMobileEntryScreen({super.key});

  @override
  ConsumerState<OrderMobileEntryScreen> createState() => _OrderMobileEntryScreenState();
}

class _OrderMobileEntryScreenState extends ConsumerState<OrderMobileEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _notFound = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _notFound = false;
    });

    final mobile = _mobileController.text.trim();
    try {
      final result = await ref.read(authRepositoryProvider).loginByMobile(mobile);
      if (!mounted) return;

      if (result.isNewUser) {
        setState(() => _notFound = true);
        return;
      }

      await ref
          .read(authControllerProvider.notifier)
          .onLoggedIn(token: result.token!, user: result.user!);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Food')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your registered mobile number',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Mobile Number',
                  controller: _mobileController,
                  hintText: '9876543210',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.mobile,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
                if (_notFound) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'No account found for this mobile number.',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/register?mobile=${Uri.encodeQueryComponent(_mobileController.text.trim())}'),
                    child: const Text('Register instead'),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(label: 'Continue', onPressed: _continue, isLoading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
