import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/week_date_selector.dart';
import '../../../data/models/menu_day.dart';
import '../../../data/models/order.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../routes/app_router.dart';
import '../providers/menu_providers.dart';

class WeeklyMenuScreen extends ConsumerStatefulWidget {
  const WeeklyMenuScreen({super.key});

  @override
  ConsumerState<WeeklyMenuScreen> createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends ConsumerState<WeeklyMenuScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final weeklyMenu = ref.watch(weeklyMenuProvider);
    final upcomingOrders = ref.watch(upcomingOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Menu')),
      body: weeklyMenu.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorStateView(message: err.toString(), onRetry: () => ref.invalidate(weeklyMenuProvider)),
        data: (days) {
          if (days.isEmpty) return const SizedBox.shrink();

          final selected = days.firstWhere(
            (d) => DateUtils.isSameDay(d.date, _selectedDate),
            orElse: () => days.first,
          );

          return Column(
            children: [
              const SizedBox(height: 8),
              WeekDateSelector(
                dates: days.map((d) => d.date).toList(),
                selected: selected.date,
                orderableFlags: {
                  for (final d in days) DateFormat('yyyy-MM-dd').format(d.date): d.isOrderable,
                },
                onSelect: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(selected.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selected.isOrderable
                          ? 'Open for ordering'
                          : 'Ordering closed for this date',
                      style: TextStyle(
                        color: selected.isOrderable ? AppColors.success : AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final mealType in ['breakfast', 'lunch', 'dinner'])
                      _MealTypeSection(mealType: mealType, day: selected),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: selected.isOrderable
                          ? () {
                              final matches = upcomingOrders.value
                                      ?.where((o) => DateUtils.isSameDay(o.orderDate, selected.date))
                                      .toList() ??
                                  [];
                              final existingOrder = matches.isEmpty ? null : matches.first;
                              context.push(
                                '/menu/select',
                                extra: MealSelectionArgs(date: selected.date, existingOrder: existingOrder),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.restaurant),
                      label: Text(_actionLabel(upcomingOrders.value, selected)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _actionLabel(List<OrderModel>? orders, MenuDayModel day) {
    final hasOrder = orders?.any((o) => DateUtils.isSameDay(o.orderDate, day.date)) ?? false;
    return hasOrder ? 'Edit Order for This Day' : 'Select Meals for This Day';
  }
}

class _MealTypeSection extends StatelessWidget {
  const _MealTypeSection({required this.mealType, required this.day});

  final String mealType;
  final MenuDayModel day;

  String get _title => mealType[0].toUpperCase() + mealType.substring(1);

  @override
  Widget build(BuildContext context) {
    final meals = day.mealsFor(mealType);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (meals.isEmpty)
              const Text('No menu published yet', style: TextStyle(color: AppColors.textMuted))
            else
              ...meals.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        m.foodType == 'veg' ? Icons.eco : Icons.set_meal,
                        size: 14,
                        color: m.foodType == 'veg' ? AppColors.veg : AppColors.nonVeg,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(m.foodName, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
