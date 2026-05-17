import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/client/home_client/view_model/home_client_view_model.dart';
import 'package:farmacia_app/features/client/home_client/view/widgets/product_card.dart';
import 'package:farmacia_app/features/client/widgets/custom_app_bar.dart';
import 'package:farmacia_app/features/client/widgets/custom_bottom_nav_bar.dart';
import 'package:farmacia_app/features/client/home_client/view/widgets/banner_carousel.dart';
import 'package:farmacia_app/features/client/home_client/view/widgets/category_grid.dart';
import 'package:farmacia_app/features/client/account/view/account_screen.dart';
import 'package:farmacia_app/features/client/notifications/view/notifications_screen.dart';
import 'package:farmacia_app/features/client/notifications/view_model/notifications_view_model.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  final HomeClientViewModel viewModel = HomeClientViewModel();
  final NotificationsViewModel notificationsViewModel =
      NotificationsViewModel();
  int _currentTabIndex = 0;

  @override
  void dispose() {
    viewModel.dispose();
    notificationsViewModel.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 1:
        if (viewModel.requestProtectedAction(
          context,
          'Entre com sua conta para iniciar um atendimento pelo chat.',
        )) {
          Navigator.of(context).pushNamed(AppRoutes.clientChat);
        }
        break;
      case 2:
        if (viewModel.requestProtectedAction(
          context,
          'Entre com sua conta para acessar seu carrinho.',
        )) {
          Navigator.of(context).pushNamed(AppRoutes.cart);
        }
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
        break;
      default:
        setState(() => _currentTabIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: notificationsViewModel,
          builder: (context, _) => CustomAppBar(
            onMenuTap: () => debugPrint('Abrir Drawer'),
            onNotificationTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationsScreen(viewModel: notificationsViewModel),
                ),
              );
            },
            unreadCount: notificationsViewModel.unreadCount,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Pallete.primaryRed),
              ),
            );
          }

          if (viewModel.errorMessage != null &&
              viewModel.filteredProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 56,
                      color: Pallete.textColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Pallete.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: viewModel.refreshProducts,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshProducts,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  BannerCarousel(
                    banners: viewModel.banners,
                    onTap: (id) => debugPrint('Banner $id clicado'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Categorias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  CategoryGrid(
                    categories: viewModel.categories,
                    onCategoryTap: (categoryName) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.searchResult,
                        arguments: categoryName,
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      'Destaques para você',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildProductsGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Pallete.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Pallete.borderColor),
        ),
        child: TextField(
          controller: viewModel.searchController,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.pushNamed(
                context,
                AppRoutes.searchResult,
                arguments: value,
              );
            }
          },
          decoration: const InputDecoration(
            hintText: 'Buscar na Farmácia Americana...',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Pallete.textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.68,
        ),
        itemCount: viewModel.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = viewModel.filteredProducts[index];
          return ProductCard(
            imageUrl: product.imageUrl,
            productName: product.name,
            price: product.price,
            rating: product.rating,
            reviewCount: product.reviewCount,
            isOnPromotion: product.isOnPromotion,
            discountPercentage: product.discountPercentage,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: product,
              );
            },
            onAddToCart: () => viewModel.addToCart(context, product),
          );
        },
      ),
    );
  }
}
