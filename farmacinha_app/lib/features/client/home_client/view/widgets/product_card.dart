import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class ProductCard extends StatelessWidget {
  // URL ou path da imagem do produto
  final String imageUrl;

  // Nome do produto
  final String productName;

  // Preço do produto em reais
  final double price;

  // Avaliação do produto (0 a 5 estrelas)
  final double rating;

  // Quantidade de avaliações
  final int reviewCount;

  // Flag se o produto está em promoção
  final bool isOnPromotion;

  // Desconto em percentual (ex: 20 para 20%)
  final int? discountPercentage;

  // Callback ao clicar no card
  final VoidCallback onTap;

  // Callback ao clicar no botão de adicionar ao carrinho
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    required this.onAddToCart,
    this.isOnPromotion = false,
    this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Pallete.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Pallete.borderColor,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== IMAGEM + BADGE DE PROMOÇÃO =====
            Stack(
              children: [
                // Imagem do produto
                Container(
                  width: double.infinity,
                  height: isMobile ? 140 : 180,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    color: Pallete.grayColor,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Pallete.textColor,
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation(
                              Pallete.gradient3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Badge de Promoção
                if (isOnPromotion && discountPercentage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 69, 58),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          color: Pallete.whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ===== INFORMAÇÕES DO PRODUTO =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do Produto
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 50, 50, 50),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Avaliação (Estrelas)
                    Row(
                      children: [
                        // Estrelas
                        Flexible(
                          child: SizedBox(
                            height: 16,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < rating.floor()
                                        ? Icons.star_rounded
                                        : index < rating
                                            ? Icons.star_half_rounded
                                            : Icons.star_outline_rounded,
                                    size: 14,
                                    color: Pallete.gradient3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Quantidade de avaliações
                        Flexible(
                          child: Text(
                            '($reviewCount)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Pallete.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Preço
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Preço original (se houver desconto)
                              if (isOnPromotion && discountPercentage != null)
                                Text(
                                  'R\$ ${price.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Pallete.textColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),

                              // Preço atual
                              Text(
                                isOnPromotion && discountPercentage != null
                                    ? 'R\$ ${(price * (1 - discountPercentage! / 100)).toStringAsFixed(2)}'
                                    : 'R\$ ${price.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Pallete.gradient3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botão de adicionar ao carrinho
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Pallete.actionButton,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 18,
                              color: Color.fromARGB(255, 50, 50, 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
