import 'package:flutter/material.dart';

import '../../data/models/meal.dart';
import '../theme/app_colors.dart';

/// One selectable option (Veg / Non-Veg / Skip) within the Meal Selection
/// screen for a given meal_type. [meal] is null for the "Skip" option.
class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.foodType,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.meal,
  });

  final String foodType;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final MealModel? meal;

  Color get _accent => switch (foodType) {
    'veg' => AppColors.veg,
    'non_veg' => AppColors.nonVeg,
    _ => AppColors.skip,
  };

  IconData get _icon => switch (foodType) {
    'veg' => Icons.eco,
    'non_veg' => Icons.set_meal,
    _ => Icons.block,
  };

  String get _label => switch (foodType) {
    'veg' => 'Veg',
    'non_veg' => 'Non-Veg',
    _ => 'Skip',
  };

  @override
  Widget build(BuildContext context) {
    final isUnavailable = foodType != 'skip' && (meal == null || !meal!.isAvailable);
    final isDisabled = !enabled || isUnavailable;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accent.withValues(alpha: 0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? _accent : AppColors.border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (meal != null)
                      Text(
                        isUnavailable ? 'Unavailable' : meal!.foodName,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? _accent : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
