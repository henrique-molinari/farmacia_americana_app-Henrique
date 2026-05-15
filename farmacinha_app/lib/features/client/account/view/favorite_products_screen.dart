import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/view_model/favorite_products_view_model.dart';
import 'package:farmacia_app/features/client/widgets/custom_bottom_nav_bar.dart';

class FavoriteProductsScreen extends StatefulWidget {
  const FavoriteProductsScreen({super.key});

  @override
  State<FavoriteProductsScreen> createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  static const Color _screenBg = Color(0xFFFFF8F7);
  static const Color _surfaceLowest = Colors.white;
  static const Color _surfaceLow = Color(0xFFFFF0EE);
  static const Color _surfaceHighest = Color(0xFFFDDDD8);

  final FavoriteProductsViewModel viewModel = FavoriteProductsViewModel();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _suggestionsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _onBottomBarTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.cart);
      return;
    }

    if (index == 3) {
      return;
    }

    debugPrint('Tab $index selecionada em Favoritos');
  }

  Future<void> _scrollToSuggestions() async {
    final suggestionsContext = _suggestionsKey.currentContext;

    if (suggestionsContext != null) {
      await Scrollable.ensureVisible(
        suggestionsContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
      return;
    }

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _goToCategories() {
    Navigator.of(context).pushNamed(AppRoutes.homeClient);
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFB90014)),
        ),
        title: const Text(
          'Produtos Favoritos',
          style: TextStyle(
            color: Color(0xFFB90014),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => debugPrint('Buscar em favoritos'),
            icon: const Icon(Icons.search_rounded, color: Color(0xFFB90014)),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
            icon: const Icon(
              Icons.shopping_cart_rounded,
              color: Color(0xFFB90014),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUA COLEÇÃO CURADA',
                  style: TextStyle(
                    color: Color(0xFF5D3F3C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF291715),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(text: 'Itens que você '),
                      TextSpan(
                        text: 'ama.',
                        style: TextStyle(
                          color: Color(0xFFB90014),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 340 ? 1 : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.favoriteProducts.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: crossAxisCount == 1 ? 0.86 : 0.58,
                      ),
                      itemBuilder: (context, index) {
                        if (index == viewModel.favoriteProducts.length) {
                          return _buildDiscoverMoreCard();
                        }

                        final product = viewModel.favoriteProducts[index];
                        return _ProductCard(
                          product: product,
                          isLoadingAddToCart:
                              viewModel.isAddingToCart(product.id),
                          onFavoriteTap: () =>
                              viewModel.removeFromFavorites(product),
                          onAddTap: () =>
                              _showInfo(viewModel.addToCart(product)),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 26),
                _buildTipsCard(),
                const SizedBox(height: 20),
                LayoutBuilder(
                  key: _suggestionsKey,
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 340 ? 1 : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.suggestedProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: crossAxisCount == 1 ? 0.86 : 0.58,
                      ),
                      itemBuilder: (context, index) {
                        final product = viewModel.suggestedProducts[index];
                        return _ProductCard(
                          product: product,
                          suggested: true,
                          isLoadingAddToCart:
                              viewModel.isAddingToCart(product.id),
                          onFavoriteTap: () =>
                              viewModel.addToFavorites(product),
                          onAddTap: () =>
                              _showInfo(viewModel.addToCart(product)),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: _onBottomBarTap,
      ),
    );
  }

  Widget _buildDiscoverMoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceLow,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE7BDB8), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _scrollToSuggestions,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF926E6B),
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Descubra Mais',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF291715),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _goToCategories,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver Categorias',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFB90014),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB90014),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dicas para você',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF291715),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Sugestões baseadas nos seus favoritos.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D3F3C),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          _TipIcon(
            icon: Icons.auto_awesome_rounded,
            iconColor: Color(0xFF705D00),
          ),
          SizedBox(width: 8),
          _TipIcon(
            icon: Icons.health_and_safety_rounded,
            iconColor: Color(0xFF005F93),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final FavoriteProduct product;
  final bool suggested;
  final bool isLoadingAddToCart;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddTap;

  const _ProductCard({
    required this.product,
    required this.onFavoriteTap,
    required this.onAddTap,
    required this.isLoadingAddToCart,
    this.suggested = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _FavoriteProductsScreenState._surfaceLowest,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    color: _FavoriteProductsScreenState._surfaceLow,
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Pallete.textColor,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onFavoriteTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: product.isFavorite
                            ? const Color(0xFFB90014)
                            : const Color(0xFFAA8784),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.categoryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: product.categoryText,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF291715),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: Color(0xFF291715),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: suggested ? Colors.white : const Color(0xFFE30613),
                foregroundColor: const Color(0xFFE30613),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: const Color(0xFFE30613),
                    width: suggested ? 2 : 0,
                  ),
                ),
              ),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: isLoadingAddToCart
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('check'),
                        size: 16,
                        color: suggested ? const Color(0xFFE30613) : Colors.white,
                      )
                    : Icon(
                        Icons.add_shopping_cart_rounded,
                        key: const ValueKey('cart'),
                        size: 16,
                        color: suggested ? const Color(0xFFE30613) : Colors.white,
                      ),
              ),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: FittedBox(
                  key: ValueKey(isLoadingAddToCart),
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isLoadingAddToCart ? 'Adicionado' : 'Adicionar',
                    style: TextStyle(
                      color: suggested ? const Color(0xFFE30613) : Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _TipIcon({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE7BDB8)),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
