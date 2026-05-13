import 'dart:math' as math;

import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';
import 'package:farmacia_app/features/client/account/view/favorite_products_screen.dart';
import 'package:farmacia_app/features/client/account/view_model/addresses_view_model.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/client/orders/list/view/orders_screen.dart';
import 'package:flutter/material.dart';

const Color _addressesScreenBackground = Color(0xFFFFF8F7);
const Color _addressesSurfaceWhite = Color(0xFFFFFFFF);
const Color _addressesSurfaceLow = Color(0xFFFFF0EE);
const Color _addressesSurfaceHigh = Color(0xFFFFE2DE);
const Color _addressesSurfaceHighest = Color(0xFFFDDBD7);
const Color _addressesText = Color(0xFF291715);
const Color _addressesMutedText = Color(0xFF5D3F3C);
const Color _addressesSoftBlue = Color(0xFFCDE5FF);
const Color _addressesBlueText = Color(0xFF004B74);
const Color _addressesErrorContainer = Color(0xFFFFDAD6);
const Color _addressesErrorText = Color(0xFF93000A);

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressesViewModel viewModel = AddressesViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _addressesScreenBackground,
      appBar: AppBar(
        backgroundColor: _addressesScreenBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFB90014)),
        ),
        titleSpacing: 0,
        title: const Text(
          'Endereços',
          style: TextStyle(
            color: Color(0xFFB90014),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Pharmacy Care',
                  style: TextStyle(
                    color: Color(0xFFB90014),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final horizontalPadding =
              MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              26,
              horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 38),
                _buildSectionHeader(),
                const SizedBox(height: 26),
                for (final address in viewModel.addresses) ...[
                  _AddressCard(
                    address: address,
                    onEdit: () => _showInfo(viewModel.editAddressMessage),
                    onDelete: () => _showInfo(viewModel.deleteAddressMessage),
                  ),
                  const SizedBox(height: 26),
                ],
                const SizedBox(height: 14),
                _buildMapCard(),
                const SizedBox(height: 48),
                _buildAddAddressButton(),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _AddressesBottomNavBar(onTap: _onBottomNavTap),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
      decoration: BoxDecoration(
        color: _addressesSurfaceLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Onde você está?',
            style: TextStyle(
              color: _addressesText,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Gerencie seus endereços para uma\nentrega rápida e segura dos seus\ncuidados farmacêuticos.',
            style: TextStyle(
              color: _addressesMutedText,
              fontSize: 16,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Transform.rotate(
              angle: math.pi / 15,
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: const Color(0xFFE31B23),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'Meus Locais',
            style: TextStyle(
              color: _addressesText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Flexible(
          child: Text(
            viewModel.registeredAddressesLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFB90014),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 194,
        width: double.infinity,
        color: _addressesSurfaceLow,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _SoftMapPainter()),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.04),
                    _addressesScreenBackground.withOpacity(0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 26,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'COBERTURA AMERICANA HEALTH',
                    style: TextStyle(
                      color: _addressesText,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: SizedBox(
          height: 68,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showInfo(viewModel.addAddressMessage),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE30613),
              foregroundColor: Colors.white,
              elevation: 18,
              shadowColor: const Color(0xFFE30613).withOpacity(0.32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 28),
            label: const Text(
              'Novo Endereço',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FavoriteProductsScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      );
      return;
    }

    Navigator.of(context).maybePop();
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
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        color: _addressesSurfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _addressesSurfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(address.icon, color: Pallete.primaryRed, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _addressesText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destinatário: ${address.recipient}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _addressesMutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _addressesSoftBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'PADRÃO',
                        style: TextStyle(
                          color: _addressesBlueText,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          Text(
            '${address.streetLine}\n'
            '${address.districtLine}\n'
            'CEP: ${address.zipCode}',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _addressesMutedText,
              fontSize: 16,
              height: 1.62,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: _addressesSurfaceLow),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      backgroundColor: _addressesSurfaceLow,
                      foregroundColor: _addressesText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text(
                      'Editar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: _addressesErrorContainer,
                    foregroundColor: _addressesErrorText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressesBottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTap;

  const _AddressesBottomNavBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _addressesScreenBackground.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'INÍCIO',
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'FAVORITOS',
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'PEDIDOS',
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.person_rounded,
                  label: 'PERFIL',
                  selected: true,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _addressesErrorContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Pallete.primaryRed : Pallete.textColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? Pallete.primaryRed : Pallete.textColor,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFE9E3E2);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final minorPaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 0.8;
    final majorPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.2;

    for (double x = -20; x < size.width + 30; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x + 18, size.height), minorPaint);
    }

    for (double y = 14; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 8), minorPaint);
    }

    final roads = [
      [Offset(0, size.height * 0.42), Offset(size.width, size.height * 0.38)],
      [Offset(size.width * 0.3, 0), Offset(size.width * 0.33, size.height)],
      [Offset(size.width * 0.72, 0), Offset(size.width * 0.62, size.height)],
      [Offset(0, size.height * 0.73), Offset(size.width, size.height * 0.68)],
      [Offset(size.width * 0.12, 0), Offset(size.width * 0.5, size.height)],
      [Offset(size.width * 0.9, 0), Offset(size.width * 0.78, size.height)],
    ];

    for (final road in roads) {
      canvas.drawLine(road[0], road[1], majorPaint);
    }

    final blockPaint = Paint()..color = Colors.white.withOpacity(0.12);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 6; col++) {
        final rect = Rect.fromLTWH(
          12 + col * 58,
          16 + row * 42,
          34 + (col.isEven ? 10 : 0),
          22,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          blockPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
