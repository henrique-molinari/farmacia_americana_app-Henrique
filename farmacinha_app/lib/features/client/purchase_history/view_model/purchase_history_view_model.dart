import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/client/orders/data/repositories/orders_repository.dart';
import 'package:flutter/material.dart';

class PurchaseHistoryViewModel extends ChangeNotifier {
  List<Order> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalSpent => _history.fold(0, (sum, o) => sum + o.totalAmount);

  int get totalOrders => _history.length;

  PurchaseHistoryViewModel() {
    _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final orders = await OrdersRepository.instance.fetchCurrentUserOrders();
      _history = orders
          .where((order) => order.status == OrderStatus.delivered)
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar historico.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
