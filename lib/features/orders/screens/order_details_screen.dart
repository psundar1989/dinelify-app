import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../routes/app_router.dart';
import '../providers/order_providers.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order? This cannot be undone.',
      confirmLabel: 'Cancel Order',
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(orderRepositoryProvider).cancel(orderId);
      ref.invalidate(orderDetailsProvider(orderId));
      ref.invalidate(upcomingOrdersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) =>
            ErrorStateView(message: err.toString(), onRetry: () => ref.invalidate(orderDetailsProvider(orderId))),
        data: (order) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(order.orderDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text('Status: ${order.status[0].toUpperCase()}${order.status.substring(1)}'),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: order.orderDetails.map((d) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(d.mealType[0].toUpperCase() + d.mealType.substring(1)),
                          trailing: Text(
                            d.foodType.replaceAll('_', '-'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (order.isEditable)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelOrder(context, ref),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                          child: const Text('Cancel Order'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.push(
                            '/menu/select',
                            extra: MealSelectionArgs(date: order.orderDate, existingOrder: order),
                          ),
                          child: const Text('Edit Order'),
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'This order is locked and can no longer be edited or cancelled.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
