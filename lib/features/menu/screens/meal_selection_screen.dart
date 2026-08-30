import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/meal_card.dart';
import '../../../data/models/meal.dart';
import '../../../routes/app_router.dart';
import '../providers/menu_providers.dart';

class MealSelectionScreen extends ConsumerStatefulWidget {
  const MealSelectionScreen({super.key, required this.args});

  final MealSelectionArgs args;

  @override
  ConsumerState<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends ConsumerState<MealSelectionScreen> {
  late final Map<String, String> _selections;

  static const _mealTypes = ['breakfast', 'lunch', 'dinner'];

  @override
  void initState() {
    super.initState();
    _selections = {
      for (final d in widget.args.existingOrder?.orderDetails ?? []) d.mealType: d.foodType,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.args.date);
    final dayAsync = ref.watch(menuDayProvider(dateKey));

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('EEE, d MMM').format(widget.args.date))),
      body: dayAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.invalidate(menuDayProvider(dateKey)),
        ),
        data: (day) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final mealType in _mealTypes) _mealTypeBlock(context, mealType, day.mealsFor(mealType)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _selections.length == _mealTypes.length ? _proceed : null,
                child: const Text('Confirm Order'),
              ),
              if (_selections.length != _mealTypes.length) ...[
                const SizedBox(height: 8),
                const Text(
                  'Choose an option (Veg / Non-Veg / Skip) for every meal to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _mealTypeBlock(BuildContext context, String mealType, List<MealModel> meals) {
    final vegMeal = meals.where((m) => m.foodType == 'veg').isEmpty
        ? null
        : meals.firstWhere((m) => m.foodType == 'veg');
    final nonVegMeal = meals.where((m) => m.foodType == 'non_veg').isEmpty
        ? null
        : meals.firstWhere((m) => m.foodType == 'non_veg');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType[0].toUpperCase() + mealType.substring(1),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          MealCard(
            foodType: 'veg',
            meal: vegMeal,
            selected: _selections[mealType] == 'veg',
            enabled: true,
            onTap: () => setState(() => _selections[mealType] = 'veg'),
          ),
          const SizedBox(height: 8),
          MealCard(
            foodType: 'non_veg',
            meal: nonVegMeal,
            selected: _selections[mealType] == 'non_veg',
            enabled: true,
            onTap: () => setState(() => _selections[mealType] = 'non_veg'),
          ),
          const SizedBox(height: 8),
          MealCard(
            foodType: 'skip',
            selected: _selections[mealType] == 'skip',
            enabled: true,
            onTap: () => setState(() => _selections[mealType] = 'skip'),
          ),
        ],
      ),
    );
  }

  void _proceed() {
    context.push(
      '/order/confirm',
      extra: OrderConfirmArgs(
        date: widget.args.date,
        selections: Map.of(_selections),
        existingOrderId: widget.args.existingOrder?.id,
      ),
    );
  }
}
