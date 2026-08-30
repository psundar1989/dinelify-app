import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/network/dio_client.dart';
import '../models/order.dart';
import '../models/order_detail.dart';

class OrderService {
  OrderService(this._dio);
  final Dio _dio;

  Future<List<OrderModel>> upcoming() => unwrap(
    () => _dio.get('/orders/upcoming'),
    (data) => (data as List<dynamic>).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList(),
  );

  Future<List<OrderModel>> history() => unwrap(
    () => _dio.get('/orders/history'),
    (data) => ((data as Map<String, dynamic>)['data'] as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Future<OrderModel> show(int id) => unwrap(
    () => _dio.get('/orders/$id'),
    (data) => OrderModel.fromJson(data as Map<String, dynamic>),
  );

  Future<OrderModel> create({required DateTime orderDate, required List<OrderDetailModel> selections}) => unwrap(
    () => _dio.post(
      '/orders',
      data: {
        'order_date': DateFormat('yyyy-MM-dd').format(orderDate),
        'selections': selections.map((s) => s.toSelectionJson()).toList(),
      },
    ),
    (data) => OrderModel.fromJson(data as Map<String, dynamic>),
  );

  Future<OrderModel> update({required int id, required List<OrderDetailModel> selections}) => unwrap(
    () => _dio.put(
      '/orders/$id',
      data: {'selections': selections.map((s) => s.toSelectionJson()).toList()},
    ),
    (data) => OrderModel.fromJson(data as Map<String, dynamic>),
  );

  Future<void> cancel(int id) => unwrap(() => _dio.delete('/orders/$id'), (_) {});
}
