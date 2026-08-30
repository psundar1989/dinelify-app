import 'order_detail.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.isEditable,
    required this.cutoffAt,
    required this.orderDetails,
  });

  final int id;
  final DateTime orderDate;
  final String status;
  final bool isEditable;
  final DateTime cutoffAt;
  final List<OrderDetailModel> orderDetails;

  OrderDetailModel? detailFor(String mealType) =>
      orderDetails.where((d) => d.mealType == mealType).firstOrNull;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as int,
    orderDate: DateTime.parse(json['order_date'] as String),
    status: json['status'] as String,
    isEditable: json['is_editable'] as bool? ?? false,
    cutoffAt: DateTime.parse(json['cutoff_at'] as String),
    orderDetails: (json['order_details'] as List<dynamic>? ?? [])
        .map((e) => OrderDetailModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
