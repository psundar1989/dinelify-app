import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

/// The unauthenticated landing screen: "Register" for new users, or
/// "Order Food" for existing users who just need their mobile number
/// looked up — mirrors the Dinelify website's home page.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Welcome to Dinelify', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Register as a new user, or order food if you already have an account.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Register',
                icon: Icons.person_add_outlined,
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/order/mobile'),
                icon: const Icon(Icons.restaurant),
                label: const Text('Order Food'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
