import '../models/order.dart';
import '../models/order_detail.dart';
import '../services/order_service.dart';

class OrderRepository {
  OrderRepository(this._service);
  final OrderService _service;

  Future<List<OrderModel>> upcoming() => _service.upcoming();

  Future<List<OrderModel>> history() => _service.history();

  Future<OrderModel> show(int id) => _service.show(id);

  Future<OrderModel> create({required DateTime orderDate, required List<OrderDetailModel> selections}) =>
      _service.create(orderDate: orderDate, selections: selections);

  Future<OrderModel> update({required int id, required List<OrderDetailModel> selections}) =>
      _service.update(id: id, selections: selections);

  Future<void> cancel(int id) => _service.cancel(id);
}
