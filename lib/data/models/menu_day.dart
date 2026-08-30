import 'meal.dart';

/// One day's worth of the weekly menu, exactly as shaped by
/// GET /api/menus/weekly and GET /api/menus/{date}. `isOrderable` and
/// `cutoffAt` are computed server-side by OrderRuleService — Flutter never
/// re-implements the advance-window / cutoff business rules.
class MenuDayModel {
  const MenuDayModel({
    required this.date,
    required this.meals,
    required this.isOrderable,
    required this.cutoffAt,
  });

  final DateTime date;
  final Map<String, List<MealModel>> meals;
  final bool isOrderable;
  final DateTime cutoffAt;

  List<MealModel> mealsFor(String mealType) => meals[mealType] ?? const [];

  factory MenuDayModel.fromJson(Map<String, dynamic> json) {
    final menus = json['menus'] as Map<String, dynamic>;

    Map<String, List<MealModel>> parseMeals() {
      final result = <String, List<MealModel>>{};
      for (final mealType in ['breakfast', 'lunch', 'dinner']) {
        final list = (menus[mealType] as List<dynamic>? ?? [])
            .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
            .toList();
        result[mealType] = list;
      }
      return result;
    }

    return MenuDayModel(
      date: DateTime.parse(json['date'] as String),
      meals: parseMeals(),
      isOrderable: json['is_orderable'] as bool? ?? false,
      cutoffAt: DateTime.parse(json['cutoff_at'] as String),
    );
  }
}
