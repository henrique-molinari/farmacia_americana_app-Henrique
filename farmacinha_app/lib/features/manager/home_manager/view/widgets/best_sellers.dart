import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/home_manager/view/all_products_screen.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:flutter/material.dart';

class BestSellers extends StatelessWidget {
  final List<ManagerProductSummary> products;

  const BestSellers({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pallete.borderColor),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mais Vendidos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Icon(Icons.filter_list, color: Pallete.textColor),
            ],
          ),
          const SizedBox(height: 20),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nenhuma venda registrada ainda',
                style: TextStyle(
                  color: Pallete.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Column(
              children: products
                  .take(3)
                  .map((product) => _ProductItem(product: product))
                  .toList(),
            ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllProductsScreen()),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              side: BorderSide(color: Pallete.primaryRed.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ver Todos os Produtos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Pallete.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final ManagerProductSummary product;

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Pallete.grayColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Pallete.primaryRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 10,
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
  }
}
