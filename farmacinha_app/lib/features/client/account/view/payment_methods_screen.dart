import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/view_model/payment_methods_view_model.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/client/orders/list/view/orders_screen.dart';
import 'package:farmacia_app/features/client/widgets/custom_bottom_nav_bar.dart';

const Color _paymentScreenBackground = Color(0xFFFFF8F7);
const Color _paymentSurfaceWhite = Color(0xFFFFFFFF);
const Color _paymentSoftRose = Color(0xFFFFF0EE);
const Color _paymentSoftRoseBorder = Color(0xFFE7BDB8);
const Color _paymentCardText = Color(0xFF291715);
const Color _paymentMutedText = Color(0xFF5D3F3C);
const Color _paymentSubtleText = Color(0xFF9B8D8B);

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final PaymentMethodsViewModel viewModel = PaymentMethodsViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paymentScreenBackground,
      appBar: AppBar(
        backgroundColor: _paymentScreenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text(
          'Métodos de Pagamento',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Pallete.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                'Pharmacy\nCare',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Pallete.primaryRed,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final primaryMethod = viewModel.primaryMethod;
          final savedMethods = viewModel.savedMethods;

          final horizontalPadding =
              MediaQuery.of(context).size.width < 360 ? 16.0 : 22.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              10,
              horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeroHeader(),
                const SizedBox(height: 28),
                _buildMainCard(primaryMethod),
                const SizedBox(height: 34),
                _buildSectionHeader(viewModel.savedMethodsLabel),
                const SizedBox(height: 18),
                for (final method in savedMethods) ...[
                  _SavedMethodTile(
                    method: method,
                    onMenuTap: () => _showInfo(viewModel.cardActionsMessage),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildAddCardButton(),
                const SizedBox(height: 48),
                _buildSecurityFooter(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildHeroHeader() {
    return const SizedBox(
      height: 122,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              'Pay.',
              style: TextStyle(
                color: Color(0xFFF4D2CE),
                fontSize: 72,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          Positioned(
            top: 34,
            left: 0,
            right: 0,
            child: Text(
              'Gerencie seus cartões e formas de pagamento com segurança clínica.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _paymentCardText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(PaymentMethodCard method) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFDFDA), Color(0xFFFFC9C4)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Pallete.primaryRed,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'PADRÃO',
                      style: TextStyle(
                        color: Pallete.primaryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.icon,
                  color: _paymentMutedText,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'FINAL DO CARTÃO',
            style: TextStyle(
              color: _paymentMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              method.maskedNumber,
              maxLines: 1,
              style: const TextStyle(
                color: _paymentCardText,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _CardInfoBlock(
                  label: 'TITULAR',
                  value: method.holderName,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: _CardInfoBlock(
                  label: 'VALIDADE',
                  value: method.expiryDate,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String savedMethodsLabel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'Outros Métodos',
            style: TextStyle(
              color: _paymentCardText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Flexible(
          child: Text(
            savedMethodsLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Pallete.primaryRed,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return OutlinedButton.icon(
      onPressed: () => _showInfo(viewModel.addCardMessage),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(92),
        backgroundColor: Colors.transparent,
        side: const BorderSide(
          color: _paymentSoftRoseBorder,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      icon: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: _paymentMutedText,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 18),
      ),
      label: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Adicionar novo cartão',
          style: TextStyle(
            color: _paymentMutedText,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return const Center(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 18, color: _paymentSubtleText),
                SizedBox(width: 10),
                Text(
                  'AMBIENTE 100% SEGURO',
                  style: TextStyle(
                    color: _paymentSubtleText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: 230,
            child: Text(
              'Seus dados são criptografados seguindo os mais rigorosos padrões da indústria farmacêutica.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _paymentSubtleText,
                fontSize: 13,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 3) {
      Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == AppRoutes.account,
      );
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.cart);
      return;
    }

    _showInfo(viewModel.unavailableScreenMessage);
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CardInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _CardInfoBlock({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _paymentMutedText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: _paymentCardText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SavedMethodTile extends StatelessWidget {
  final PaymentMethodCard method;
  final VoidCallback? onMenuTap;

  const _SavedMethodTile({
    required this.method,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _paymentSurfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _paymentSoftRose,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(method.icon, color: _paymentMutedText, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _paymentCardText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  method.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _paymentMutedText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onMenuTap != null)
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.more_vert, color: _paymentMutedText),
            ),
        ],
      ),
    );
  }
}
