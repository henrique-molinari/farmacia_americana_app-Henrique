import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:flutter/material.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ManagerProductSummary>> _productsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<ManagerProductSummary>> _loadProducts() async {
    final orders = await ManagerDashboardRepository.instance.fetchOrders();
    final soldByProductId = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        soldByProductId[item.productId] =
            (soldByProductId[item.productId] ?? 0) + item.quantity;
      }
    }

    final products = await ManagerDashboardRepository.instance.fetchProducts(
      soldByProductId: soldByProductId,
    );
    products.removeWhere((product) => product.soldUnits <= 0);
    products.sort((a, b) => b.soldUnits.compareTo(a.soldUnits));
    return products;
  }

  List<ManagerProductSummary> _filterProducts(
    List<ManagerProductSummary> products,
  ) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  String _rankLabel(int index) {
    switch (index) {
      case 0:
        return '1';
      case 1:
        return '2';
      case 2:
        return '3';
      default:
        return '${index + 1}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Pallete.whiteColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mais Vendidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Pallete.borderColor),
        ),
      ),
      body: FutureBuilder<List<ManagerProductSummary>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Pallete.primaryRed),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Nao foi possivel carregar os produtos.',
                style: TextStyle(
                  color: Pallete.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final products = _filterProducts(snapshot.data ?? []);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextField(
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
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${products.length} produtos',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Pallete.textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Pallete.textColor.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isTop3 = index < 3;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Pallete.whiteColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isTop3
                                    ? Pallete.primaryRed.withOpacity(0.2)
                                    : Pallete.borderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    _rankLabel(index),
                                    style: TextStyle(
                                      fontSize: isTop3 ? 18 : 13,
                                      fontWeight: FontWeight.w700,
                                      color: isTop3
                                          ? Pallete.primaryRed
                                          : Pallete.textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Pallete.grayColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.medication_rounded,
                                    color: Pallete.primaryRed,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${product.soldUnits} vendidos',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Pallete.primaryRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
