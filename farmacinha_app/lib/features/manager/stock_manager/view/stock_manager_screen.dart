import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/widgets/notifications_bottom_sheet.dart';
import 'package:farmacia_app/features/manager/stock_manager/view/widgets/category_filter_chips.dart';
import 'package:farmacia_app/features/manager/stock_manager/view/widgets/stock_product_card.dart';
import 'package:farmacia_app/features/manager/stock_manager/view_model/stock_manager_view_model.dart';
import 'package:flutter/material.dart';

class StockManagerScreen extends StatefulWidget {
  const StockManagerScreen({super.key});

  @override
  State<StockManagerScreen> createState() => _StockManagerScreenState();
}

class _StockManagerScreenState extends State<StockManagerScreen> {
  final _viewModel = StockManagerViewModel();
  final _searchController = TextEditingController();

  String _selectedCategory = 'Todos';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadProducts();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = _viewModel.getFilteredProducts(
      selectedCategory: _selectedCategory,
      searchQuery: _searchQuery,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: Pallete.primaryRed,
        onRefresh: _viewModel.loadProducts,
        child: _buildBody(products),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Pallete.whiteColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Pallete.borderColor),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Pallete.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Pallete.primaryRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FARMACIA AMERICANA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Pallete.primaryRed,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Painel Administrativo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Pallete.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Pallete.textColor,
          ),
          onPressed: () => NotificationsBottomSheet.show(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(List<ManagerProductSummary> products) {
    if (_viewModel.isLoading && _viewModel.allProducts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Pallete.primaryRed),
      );
    }

    if (_viewModel.errorMessage != null && _viewModel.allProducts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 160),
          const Icon(
            Icons.cloud_off_rounded,
            color: Pallete.primaryRed,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Pallete.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: _viewModel.loadProducts,
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estoque',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_viewModel.totalProducts} produtos cadastrados',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Pallete.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar produto...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Pallete.textColor.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Pallete.textColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Pallete.whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Pallete.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Pallete.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Pallete.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                CategoryFilterChips(
                  categories: _viewModel.categories,
                  selectedCategory: _selectedCategory,
                  onSelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        products.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Pallete.textColor.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum produto encontrado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Pallete.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return StockProductCard(
                      name: product.name,
                      category: product.category,
                      quantity: product.stock,
                      price: product.price,
                      isLowStock: _viewModel.isLowStock(product.stock),
                    );
                  }, childCount: products.length),
                ),
              ),
      ],
    );
  }
}
