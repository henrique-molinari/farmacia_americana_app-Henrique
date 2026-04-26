import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _products = [
    {'name': 'Advanced Multi-Vitamin', 'sold': '142', 'price': 'R\$ 89,90'},
    {'name': 'Soro Fisiológico Plus', 'sold': '118', 'price': 'R\$ 12,50'},
    {'name': 'Protetor Solar FPS 50', 'sold': '97', 'price': 'R\$ 45,00'},
    {'name': 'Dipirona 500mg', 'sold': '89', 'price': 'R\$ 8,90'},
    {'name': 'Paracetamol 750mg', 'sold': '74', 'price': 'R\$ 12,00'},
    {'name': 'Vitamina C 1g', 'sold': '61', 'price': 'R\$ 34,90'},
    {'name': 'Shampoo Anticaspa', 'sold': '55', 'price': 'R\$ 22,50'},
    {'name': 'Omeprazol 20mg', 'sold': '48', 'price': 'R\$ 19,90'},
    {'name': 'Complexo B', 'sold': '43', 'price': 'R\$ 22,00'},
    {'name': 'Sabonete Líquido', 'sold': '38', 'price': 'R\$ 14,90'},
  ];

  List<Map<String, String>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) =>
        p['name']!.toLowerCase().contains(_searchQuery.toLowerCase()),
    ).toList();
  }

  String _rankLabel(int index) {
    switch (index) {
      case 0: return '🥇';
      case 1: return '🥈';
      case 2: return '🥉';
      default: return '${index + 1}º';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

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
      body: Column(
        children: [
          // Campo de busca
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

          // Contagem
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

          // Lista
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
                            // Ranking
                            SizedBox(
                              width: 32,
                              child: Text(
                                _rankLabel(index),
                                style: TextStyle(
                                  fontSize: isTop3 ? 20 : 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Ícone
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

                            // Nome e vendas
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product['sold']} vendidos',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Pallete.primaryRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Preço
                            Text(
                              product['price']!,
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
      ),
    );
  }
}