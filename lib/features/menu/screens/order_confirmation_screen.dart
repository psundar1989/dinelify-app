import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/order_detail.dart';
import '../../../data/providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../routes/app_router.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key, required this.args});

  final OrderConfirmArgs args;

  @override
  ConsumerState<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends ConsumerState<OrderConfirmationScreen> {
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final selections = widget.args.selections.entries
        .map((e) => OrderDetailModel(mealType: e.key, foodType: e.value, status: 'active'))
        .toList();

    try {
      final repo = ref.read(orderRepositoryProvider);
      if (widget.args.existingOrderId != null) {
        await repo.update(id: widget.args.existingOrderId!, selections: selections);
      } else {
        await repo.create(orderDate: widget.args.date, selections: selections);
      }
      ref.invalidate(upcomingOrdersProvider);
      if (!mounted) return;
      setState(() => _isSuccess = true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccess(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(widget.args.date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: widget.args.selections.entries.map((e) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(e.key[0].toUpperCase() + e.key.substring(1)),
                      trailing: Text(
                        _titleCase(e.value),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: e.value == 'veg'
                              ? AppColors.veg
                              : e.value == 'non_veg'
                              ? AppColors.nonVeg
                              : AppColors.skip,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 8),
            ],
            PrimaryButton(
              label: widget.args.existingOrderId != null ? 'Save Changes' : 'Confirm Order',
              onPressed: _confirm,
              isLoading: _isSubmitting,
            ),
          ],
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
              Text(
                widget.args.existingOrderId != null ? 'Order Updated' : 'Order Created',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Your meals for ${DateFormat('d MMM yyyy').format(widget.args.date)} are all set.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'View Upcoming Orders',
                onPressed: () => context.go('/orders/upcoming'),
              ),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleCase(String value) => value.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join('-');
}
