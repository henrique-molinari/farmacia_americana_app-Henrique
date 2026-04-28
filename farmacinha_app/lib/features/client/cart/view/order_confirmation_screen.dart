import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/client/orders/detail/view/order_detail_screen.dart';
import 'package:flutter/material.dart';

const Color _confirmationBg = Color(0xFFFFF8F7);
const Color _confirmationSoft = Color(0xFFFFF0EE);
const Color _confirmationSoftest = Color(0xFFFDDDD8);
const Color _confirmationText = Color(0xFF291715);
const Color _confirmationMuted = Color(0xFF5D3F3C);

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _confirmationBg,
      appBar: AppBar(
        backgroundColor: _confirmationBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
        ),
        centerTitle: true,
        title: const Text(
          'Confirmação',
          style: TextStyle(
            color: Pallete.primaryRed,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: Pallete.primaryRed),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
        child: Column(
          children: [
            _buildHero(),
            const SizedBox(height: 18),
            const Text(
              'Pedido realizado\ncom sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _confirmationText,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tudo pronto por aqui! Sua saúde está em boas mãos e logo estaremos na sua porta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _confirmationMuted,
                fontSize: 15,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    backgroundColor: Colors.white,
                    icon: Icons.receipt_long_rounded,
                    iconColor: Pallete.primaryRed,
                    label: 'Nº DO PEDIDO',
                    value: order.id.replaceFirst('PED-', '#'),
                    valueColor: _confirmationText,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoCard(
                    backgroundColor: const Color(0xFFFCD400),
                    icon: Icons.speed_rounded,
                    iconColor: const Color(0xFF6E5C00),
                    label: 'ENTREGA ESTIMADA',
                    value: _estimatedWindowLabel(order),
                    valueColor: const Color(0xFF564600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRouteCard(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.track_changes_rounded),
                label: const Text(
                  'Acompanhar Pedido',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeClientScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _confirmationSoftest,
                  foregroundColor: const Color(0xFF93000D),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Voltar para o Início',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 34),
            Opacity(
              opacity: 0.36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _BrandDash(color: Color(0xFFE8B5BF)),
                  SizedBox(width: 10),
                  Text(
                    'DROGARIA AMERICANA',
                    style: TextStyle(
                      color: _confirmationMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(width: 10),
                  _BrandDash(color: Color(0xFFD0C58E)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            left: 50,
            child: _FloatingDot(color: const Color(0xFFB3A258), size: 20),
          ),
          Positioned(
            top: 140,
            right: 0,
            child: _FloatingDot(color: const Color(0xFF7EB7DD), size: 16),
          ),
          Positioned(
            bottom: 58,
            right: 28,
            child: _FloatingDot(color: const Color(0xFFFFE27A), size: 28),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE74C57), Color(0xFFE33A49)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Pallete.primaryRed.withOpacity(0.22),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Color(0xFFE04A58),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 170,
        width: double.infinity,
        color: const Color(0xFFFFE9D6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _RoutePainter()),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.26),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Pallete.primaryRed,
                      child: Icon(
                        Icons.local_shipping_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Em preparação',
                      style: TextStyle(
                        color: _confirmationText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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

  String _estimatedWindowLabel(Order order) {
    if (order.estimatedDelivery == null) {
      return 'Em breve';
    }

    final minutes = order.estimatedDelivery!.difference(order.createdAt).inMinutes;
    final min = minutes <= 20 ? 20 : minutes - 10;
    final max = minutes + 5;
    return '$min-$max min';
  }
}

class _InfoCard extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCard({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 162,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              color: valueColor.withOpacity(0.55),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDot extends StatelessWidget {
  final Color color;
  final double size;

  const _FloatingDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BrandDash extends StatelessWidget {
  final Color color;

  const _BrandDash({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 1.2;
    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.32)
      ..strokeWidth = 0.8;

    for (double y = 12; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 4), minorRoadPaint);
    }

    for (double x = 14; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, size.height), minorRoadPaint);
    }

    final path = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.52,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.58,
        size.width,
        size.height * 0.2,
      );

    final routePaint = Paint()
      ..color = const Color(0xFFF06A4A)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPaint = Paint()
      ..color = const Color(0xFF9BD1D8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.35,
        size.width * 0.82,
        size.height,
      );

    canvas.drawPath(river, riverPaint);
    canvas.drawPath(path, routePaint);

    canvas.drawLine(
      Offset(size.width * 0.16, 0),
      Offset(size.width * 0.22, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.46, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
