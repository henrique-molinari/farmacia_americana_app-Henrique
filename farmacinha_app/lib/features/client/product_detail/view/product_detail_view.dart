import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import '../view_model/product_detail_view_model.dart';

class ProductDetailScreen extends StatelessWidget {
  // Removido o 'final Product product' como atributo obrigatório do construtor
  // para permitir que o AppRoutes chame a classe sem parâmetros.
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CAPTURA DO DADO: Buscamos o objeto Product enviado via Navigator.pushNamed
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    // Seguindo seu padrão: Injetamos a ViewModel e passamos o produto para ela
    return ChangeNotifierProvider(
      create: (_) => ProductDetailViewModel(product: product),
      child: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do Produto
                  AspectRatio(
                    aspectRatio: 1.25,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Pallete.textColor,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge de Promoção
                        if (product.isOnPromotion)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Pallete.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage}% OFF',
                              style: const TextStyle(
                                color: Pallete.primaryRed, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        
                        Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Expanded(
                              child: Text(
                                " ${product.rating} (${product.reviewCount} avaliações)",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        
                        Text(
                          "R\$ ${product.price.toStringAsFixed(2)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 28, 
                            color: Colors.green, 
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        const SizedBox(height: 25),

                        // BOTÕES DE AÇÃO
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDE8E8), 
                            foregroundColor: Colors.brown,
                            minimumSize: const Size(double.infinity, 55),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => viewModel.addToCart(context),
                          child: const Text(
                            "Adicionar ao Carrinho", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Pallete.primaryRed,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => viewModel.buyNow(context),
                          child: const Text(
                            "Comprar Agora", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ),

                        const SizedBox(height: 30),

                        // DESCRIÇÃO DO PRODUTO
                        const Text(
                          "Descrição",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.black87, 
                            height: 1.5
                          ),
                        ),
                        
                        const SizedBox(height: 40), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
