import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

class WeekDateSelector extends StatelessWidget {
  const WeekDateSelector({
    super.key,
    required this.dates,
    required this.selected,
    required this.orderableFlags,
    required this.onSelect,
  });

  final List<DateTime> dates;
  final DateTime selected;

  /// Keyed by yyyy-MM-dd — drives the visual "locked" state, sourced from
  /// the API's `is_orderable` flag (never computed locally).
  final Map<String, bool> orderableFlags;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final key = DateFormat('yyyy-MM-dd').format(date);
          final isSelected = DateUtils.isSameDay(date, selected);
          final isOrderable = orderableFlags[key] ?? true;

          return InkWell(
            onTap: () => onSelect(date),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (!isOrderable) ...[
                    const SizedBox(height: 2),
                    Icon(Icons.lock, size: 12, color: isSelected ? Colors.white70 : AppColors.textMuted),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
