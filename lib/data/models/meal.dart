class MealModel {
  const MealModel({
    required this.id,
    required this.mealType,
    required this.foodType,
    required this.foodName,
    required this.status,
  });

  final int id;
  final String mealType;
  final String foodType;
  final String foodName;
  final String status;

  bool get isAvailable => status == 'available';

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id: json['id'] as int,
    mealType: json['meal_type'] as String,
    foodType: json['food_type'] as String,
    foodName: json['food_name'] as String,
    status: json['status'] as String? ?? 'available',
  );
}
