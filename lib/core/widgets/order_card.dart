import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/order.dart';
import '../theme/app_colors.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.onTap});

  final OrderModel order;
  final VoidCallback? onTap;

  Color get _statusColor => switch (order.status) {
    'confirmed' => AppColors.success,
    'locked' => AppColors.info,
    'cancelled' => AppColors.danger,
    _ => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEE, d MMM yyyy').format(order.orderDate),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status[0].toUpperCase() + order.status.substring(1),
                      style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: order.orderDetails.map((d) {
                  return Chip(
                    label: Text('${_titleCase(d.mealType)}: ${_titleCase(d.foodType)}'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.background,
                    side: const BorderSide(color: AppColors.border),
                  );
                }).toList(),
              ),
              if (order.isEditable) ...[
                const SizedBox(height: 8),
                const Text('Editable until cutoff', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _titleCase(String value) => value.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}
