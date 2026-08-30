class OrderDetailModel {
  const OrderDetailModel({
    required this.mealType,
    required this.foodType,
    required this.status,
  });

  final String mealType;
  final String foodType;
  final String status;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => OrderDetailModel(
    mealType: json['meal_type'] as String,
    foodType: json['food_type'] as String,
    status: json['status'] as String? ?? 'active',
  );

  Map<String, dynamic> toSelectionJson() => {
    'meal_type': mealType,
    'food_type': foodType,
  };
}
