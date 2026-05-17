import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/view/addresses_screen.dart';
import 'package:farmacia_app/features/client/account/view/payment_methods_screen.dart';
import 'package:farmacia_app/features/client/account/view_model/account_view_model.dart';
import 'package:farmacia_app/features/client/orders/list/view/orders_screen.dart';
import 'package:farmacia_app/features/client/account/view/personal_data_screen.dart';
import 'package:farmacia_app/features/client/account/view/favorite_products_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountViewModel viewModel = AccountViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Minha Conta',
          style: TextStyle(
            color: Pallete.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Pallete.primaryRed),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: viewModel.isGuest
                ? _buildGuestAccess()
                : Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildMenuGrid(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildGuestAccess() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: Pallete.primaryRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Pallete.primaryRed,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Você está como visitante',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF291715),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para acessar pedidos, dados pessoais, favoritos e formas de pagamento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Pallete.textColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => viewModel.navigateToLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Fazer login',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => viewModel.navigateToRegister(context),
                child: const Text(
                  'Não tem conta? Cadastre-se',
                  style: TextStyle(
                    color: Pallete.primaryRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final user = viewModel.currentUser;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Pallete.accentYellow, width: 2.5),
                ),
                child: ClipOval(
                  child: Container(
                    color: Pallete.grayColor,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: Pallete.textColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => debugPrint('Editar foto'),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Pallete.primaryRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Usuário',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF291715),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Pallete.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Pallete.accentYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    viewModel.loyaltyTier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E5C00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final tiles = [
      _MenuTile(
        icon: Icons.shopping_bag_rounded,
        iconBgColor: Pallete.primaryRed.withOpacity(0.1),
        iconColor: Pallete.primaryRed,
        title: 'Meus Pedidos',
        subtitle: 'Veja seu histórico de compras',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          );
        },
      ),
      _MenuTile(
        icon: Icons.badge_rounded,
        iconBgColor: Pallete.accentYellow.withOpacity(0.2),
        iconColor: const Color(0xFF705D00),
        title: 'Dados Pessoais',
        subtitle: 'Edite suas informações de perfil',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PersonalDataScreen()),
          );
        },
      ),
      _MenuTile(
        icon: Icons.favorite_rounded,
        iconBgColor: const Color(0xFFFFDAD6),
        iconColor: const Color(0xFFBA1A1A),
        title: 'Produtos Favoritos',
        subtitle: 'Sua lista de desejos e recorrentes',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FavoriteProductsScreen()),
          );
        },
      ),
      _MenuTile(
        icon: Icons.location_on_rounded,
        iconBgColor: const Color(0xFFCDE5FF).withOpacity(0.5),
        iconColor: const Color(0xFF005F93),
        title: 'Endereços',
        subtitle: 'Gerencie seus locais de entrega',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddressesScreen()),
          );
        },
      ),
      _MenuTile(
        icon: Icons.credit_card_rounded,
        iconBgColor: const Color(0xFFFDDBD7),
        iconColor: const Color(0xFF5D3F3C),
        title: 'Métodos de Pagamento',
        subtitle: 'Cartões e formas de pagamento',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
          );
        },
      ),
      _LogoutTile(onTap: () => _showLogoutDialog()),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            children: [
              for (final tile in tiles) ...[
                tile,
                if (tile != tiles.last) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < tiles.length; index += 2) ...[
              Row(
                children: [
                  Expanded(child: tiles[index]),
                  const SizedBox(width: 12),
                  Expanded(child: tiles[index + 1]),
                ],
              ),
              if (index < tiles.length - 2) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair da conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Tem certeza que deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Pallete.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await viewModel.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatefulWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Pallete.borderColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF291715),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Pallete.textColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutTile({required this.onTap});

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Pallete.primaryRed.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Pallete.primaryRed.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Pallete.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Pallete.primaryRed.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Sair',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Pallete.primaryRed,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Encerrar sessão no dispositivo',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF93000D),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
