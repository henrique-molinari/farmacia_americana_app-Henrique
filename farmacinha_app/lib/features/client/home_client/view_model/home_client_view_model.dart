import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/cart/view_model/cart_view_model.dart';
import 'package:farmacia_app/features/client/home_client/data/mocks/mock_banners.dart';
import 'package:farmacia_app/features/client/home_client/data/models/banner_model.dart';
import 'package:farmacia_app/features/client/home_client/data/models/category_model.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:farmacia_app/features/client/home_client/data/repositories/products_repository.dart';
import 'package:flutter/material.dart';

class HomeClientViewModel extends ChangeNotifier {
  HomeClientViewModel({AuthSessionViewModel? authSession})
    : _authSession = authSession ?? AuthSessionViewModel.instance {
    _banners = MockBanners.getBanners();
    searchController.addListener(_onSearchChanged);
    refreshProducts();
  }

  final AuthSessionViewModel _authSession;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  List<BannerModel> _banners = [];

  String _selectedCategoryId = '';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController searchController = TextEditingController();

  List<Product> get filteredProducts => _filteredProducts;
  List<Category> get categories => _categories;
  List<BannerModel> get banners => _banners;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGuest => _authSession.isGuest || !_authSession.isAuthenticated;

  Future<void> refreshProducts() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _allProducts = await ProductsRepository.instance.fetchActiveProducts();
      _categories = _buildCategories(_allProducts);
      _applyFilters(notify: false);
    } catch (error) {
      debugPrint('Erro ao carregar produtos do Supabase: $error');
      _errorMessage = 'Erro ao carregar dados da farmacia.';
      _allProducts = [];
      _filteredProducts = [];
      _categories = _buildCategories(<Product>[]);
    } finally {
      _setLoading(false);
    }
  }

  void _onSearchChanged() {
    _searchQuery = searchController.text;
    _applyFilters();
  }

  void _applyFilters({bool notify = true}) {
    _filteredProducts = _allProducts.where((product) {
      final categoryMatch =
          _selectedCategoryId.isEmpty ||
          _selectedCategoryId == 'all' ||
          product.category.toLowerCase() == _selectedCategoryId.toLowerCase();

      final searchMatch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();

    if (notify) {
      notifyListeners();
    }
  }

  List<Category> _buildCategories(List<Product> products) {
    final categoryMap = <String, int>{};
    for (final product in products) {
      categoryMap[product.category] = (categoryMap[product.category] ?? 0) + 1;
    }

    final categories = <Category>[
      Category(
        id: 'all',
        name: 'Todos',
        icon: Icons.apps_rounded,
        productCount: products.length,
      ),
    ];

    final iconMap = <String, IconData>{
      'medicamentos': Icons.healing_rounded,
      'higiene': Icons.soap_rounded,
      'beleza': Icons.spa_rounded,
      'suplementos': Icons.favorite_rounded,
      'vitaminas': Icons.energy_savings_leaf_rounded,
      'controlados': Icons.local_hospital_rounded,
    };

    final nameMap = <String, String>{
      'medicamentos': 'Medicamentos',
      'higiene': 'Higiene',
      'beleza': 'Beleza',
      'suplementos': 'Suplementos',
      'vitaminas': 'Vitaminas',
      'controlados': 'Controlados',
    };

    final sortedKeys = categoryMap.keys.toList()..sort();
    for (final key in sortedKeys) {
      categories.add(
        Category(
          id: key,
          name: nameMap[key] ?? _capitalize(key),
          icon: iconMap[key] ?? Icons.category_rounded,
          productCount: categoryMap[key] ?? 0,
        ),
      );
    }

    return categories;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  void clearFilters() {
    searchController.clear();
    _selectedCategoryId = '';
    _searchQuery = '';
    _applyFilters();
  }

  void addToCart(BuildContext context, Product product) {
    if (!_authSession.requireAuthentication(
      context,
      message: 'Entre com sua conta para adicionar produtos ao carrinho.',
    )) {
      return;
    }

    CartViewModel.instance.addProduct(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${product.name} adicionado ao carrinho.')),
      );
  }

  bool requestProtectedAction(BuildContext context, String message) {
    return _authSession.requireAuthentication(context, message: message);
  }

  void viewProductDetail(Product product) {
    debugPrint('Usuario visualizando detalhes de: ${product.name}');
  }

  List<Product> getPromotionalProducts() {
    return _allProducts.where((p) => p.isOnPromotion).take(5).toList();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
