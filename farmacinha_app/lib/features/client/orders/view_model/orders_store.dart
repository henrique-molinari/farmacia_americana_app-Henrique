import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/client/orders/data/repositories/orders_repository.dart';
import 'package:flutter/foundation.dart';

class OrdersStore extends ChangeNotifier {
  OrdersStore._();

  static final OrdersStore instance = OrdersStore._();

  final OrdersRepository _repository = OrdersRepository.instance;

  List<Order> _orders = [];

  List<Order> get orders => List<Order>.unmodifiable(_orders);

  Future<void> refresh() async {
    _orders = await _repository.fetchCurrentUserOrders();
    _orders.sort(_sortByNewest);
    notifyListeners();
  }

  Future<Order> createOrder({
    required List<OrderItem> items,
    required PaymentMethod paymentMethod,
    required double totalAmount,
    required String deliveryAddress,
    required DateTime estimatedDelivery,
    required String trackingCode,
  }) async {
    final order = await _repository.createOrder(
      items: items,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      estimatedDelivery: estimatedDelivery,
      trackingCode: trackingCode,
    );

    _orders = [order, ..._orders]..sort(_sortByNewest);
    notifyListeners();
    return order;
  }

  int _sortByNewest(Order a, Order b) => b.createdAt.compareTo(a.createdAt);
}
