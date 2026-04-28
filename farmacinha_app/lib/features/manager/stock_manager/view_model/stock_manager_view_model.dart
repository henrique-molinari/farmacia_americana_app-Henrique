import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:flutter/foundation.dart';

class StockManagerViewModel extends ChangeNotifier {
  static const int lowStockThreshold = 10;

  final ManagerDashboardRepository _repository =
      ManagerDashboardRepository.instance;

  List<ManagerProductSummary> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ManagerProductSummary> get allProducts =>
      List<ManagerProductSummary>.unmodifiable(_allProducts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalProducts => _allProducts.length;

  List<String> get categories {
    final values =
        _allProducts
            .map((product) => product.category)
            .where((category) => category.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Todos', ...values];
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await _repository.fetchProducts();
    } catch (_) {
      _errorMessage = 'Erro ao carregar produtos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ManagerProductSummary> getFilteredProducts({
    required String selectedCategory,
    required String searchQuery,
  }) {
    return _allProducts.where((product) {
      final matchesCategory =
          selectedCategory == 'Todos' || product.category == selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  bool isLowStock(int quantity) => quantity <= lowStockThreshold;
}
