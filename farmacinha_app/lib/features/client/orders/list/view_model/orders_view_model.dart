import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/client/orders/view_model/orders_store.dart';
import 'package:flutter/material.dart';

class OrdersViewModel extends ChangeNotifier {
  OrdersViewModel({OrdersStore? ordersStore})
      : _ordersStore = ordersStore ?? OrdersStore.instance {
    _ordersStore.addListener(_handleOrdersChanged);
    _loadOrders();
  }

  final OrdersStore _ordersStore;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedFilterIndex = 0;

  List<Order> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedFilterIndex => _selectedFilterIndex;

  final List<String> filterLabels = const [
    'Todos',
    'Ativos',
    'Entregues',
    'Cancelados',
  ];

  Future<void> refresh() async {
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    _setLoading(true);
    try {
      await _ordersStore.refresh();
      _allOrders = _ordersStore.orders;
      _errorMessage = null;
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Erro ao carregar pedidos.';
    } finally {
      _setLoading(false);
    }
  }

  void _handleOrdersChanged() {
    _allOrders = _ordersStore.orders;
    _applyFilter();
  }

  void selectFilter(int index) {
    _selectedFilterIndex = index;
    _applyFilter();
  }

  void _applyFilter() {
    switch (_selectedFilterIndex) {
      case 1:
        _filteredOrders = _allOrders.where((order) => order.status.isActive).toList();
        break;
      case 2:
        _filteredOrders = _allOrders
            .where((order) => order.status == OrderStatus.delivered)
            .toList();
        break;
      case 3:
        _filteredOrders = _allOrders
            .where((order) => order.status == OrderStatus.cancelled)
            .toList();
        break;
      default:
        _filteredOrders = List<Order>.from(_allOrders);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersStore.removeListener(_handleOrdersChanged);
    super.dispose();
  }
}
