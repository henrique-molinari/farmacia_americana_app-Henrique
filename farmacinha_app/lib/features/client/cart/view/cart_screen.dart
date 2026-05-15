import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/view/account_screen.dart';
import 'package:farmacia_app/features/client/cart/view/checkout_screen.dart';
import 'package:farmacia_app/features/client/cart/view_model/cart_view_model.dart';
import 'package:farmacia_app/features/client/chat/view/client_chat_screen.dart';
import 'package:farmacia_app/features/client/widgets/custom_bottom_nav_bar.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:flutter/material.dart';

const Color _cartBg = Color(0xFFFFF8F7);
const Color _cartWhite = Colors.white;
const Color _cartSoft = Color(0xFFFFF0EE);
const Color _cartSoftest = Color(0xFFFDDBD7);
const Color _cartText = Color(0xFF291715);
const Color _cartMuted = Color(0xFF5D3F3C);
const Color _cartYellow = Color(0xFFFCD400);
const Color _cartOlive = Color(0xFF705D00);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartViewModel viewModel = CartViewModel.instance;
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: _cartBg,
      appBar: AppBar(
        backgroundColor: _cartBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
        ),
        titleSpacing: 0,
        title: const Text(
          'Carrinho',
          style: TextStyle(
            color: Pallete.primaryRed,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCartActions,
            icon: const Icon(Icons.more_vert_rounded, color: Pallete.primaryRed),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFulfillmentSelector(),
                const SizedBox(height: 18),
                ...viewModel.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _CartItemCard(
                      item: item,
                      onIncrement: () => viewModel.incrementItem(item.productId),
                      onDecrement: () => viewModel.decrementItem(item.productId),
                      onRemove: () => viewModel.removeItem(item.productId),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _buildCouponCard(),
                const SizedBox(height: 22),
                _buildSummaryCard(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: _onBottomBarTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: _cartSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 46,
                color: Pallete.primaryRed,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Seu carrinho está vazio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cartText,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione produtos do catálogo para montar seu pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cartMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeClientScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Explorar catálogo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFulfillmentSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _cartSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FulfillmentChip(
              label: 'Entregar',
              selected:
                  viewModel.selectedFulfillmentType == CartFulfillmentType.delivery,
              onTap: () => viewModel.selectFulfillmentType(CartFulfillmentType.delivery),
            ),
          ),
          Expanded(
            child: _FulfillmentChip(
              label: 'Retirar',
              selected:
                  viewModel.selectedFulfillmentType == CartFulfillmentType.pickup,
              onTap: () => viewModel.selectFulfillmentType(CartFulfillmentType.pickup),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: _cartSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.confirmation_number_rounded, color: _cartOlive),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cupom de Desconto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _cartText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 340;
              final field = TextField(
                controller: _couponController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Digite seu cupom',
                  filled: true,
                  fillColor: _cartWhite,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              );
              final button = SizedBox(
                height: 56,
                width: compact ? double.infinity : null,
                child: ElevatedButton(
                  onPressed: () {
                    final message = viewModel.applyCoupon(_couponController.text);
                    if (viewModel.appliedCouponCode != null) {
                      _couponController.clear();
                    }
                    _showInfo(message);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cartYellow,
                    foregroundColor: _cartOlive,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Aplicar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    field,
                    const SizedBox(height: 12),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: field),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            },
          ),
          if (viewModel.appliedCouponCode != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${viewModel.appliedCouponCode} ativo',
                    style: const TextStyle(
                      color: Pallete.primaryRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.removeCoupon();
                    _showInfo('Cupom removido.');
                  },
                  child: const Text(
                    'Remover',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        color: _cartWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD7D1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: CartViewModel.formatCurrency(viewModel.subtotal),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: viewModel.selectedFulfillmentType == CartFulfillmentType.delivery
                ? 'Frete'
                : 'Retirada',
            value: viewModel.shippingLabel,
            valueColor: viewModel.shippingFee == 0 ? _cartOlive : _cartText,
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Descontos',
            value: viewModel.couponDiscount > 0
                ? '- ${CartViewModel.formatCurrency(viewModel.couponDiscount)}'
                : 'R\$ 0,00',
            valueColor:
                viewModel.couponDiscount > 0 ? Pallete.primaryRed : _cartText,
          ),
          if (viewModel.paymentDiscount > 0) ...[
            const SizedBox(height: 14),
            _SummaryRow(
              label: 'Desconto Pix',
              value:
                  '- ${CartViewModel.formatCurrency(viewModel.paymentDiscount)}',
              valueColor: _cartOlive,
            ),
          ],
          const SizedBox(height: 22),
          const Divider(color: _cartSoft),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _cartText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    CartViewModel.formatCurrency(viewModel.total),
                    style: const TextStyle(
                      color: Pallete.primaryRed,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.primaryRed,
                foregroundColor: Colors.white,
                elevation: 14,
                shadowColor: Pallete.primaryRed.withOpacity(0.28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Finalizar Compra',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBottomBarTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ClientChatScreen()),
      );
      return;
    }

    if (index == 2) {
      return;
    }

    if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountScreen()),
      );
    }
  }

  Future<void> _showCartActions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded),
                  title: const Text('Limpar carrinho'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    viewModel.clearCart();
                    _showInfo('Carrinho limpo.');
                  },
                ),
                if (viewModel.appliedCouponCode != null)
                  ListTile(
                    leading: const Icon(Icons.percent_rounded),
                    title: const Text('Remover cupom'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      viewModel.removeCoupon();
                      _showInfo('Cupom removido.');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final imageSize = compact ? 86.0 : 112.0;

        final image = ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: imageSize,
            height: imageSize,
            color: _cartSoft,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported_outlined,
                color: Pallete.textColor,
              ),
            ),
          ),
        );

        final details = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _cartText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Pallete.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _cartMuted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: compact
                          ? constraints.maxWidth - 32
                          : (constraints.maxWidth - imageSize - 56) / 2,
                    ),
                    child: Text(
                      CartViewModel.formatCurrency(item.unitPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Pallete.primaryRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _QuantityStepper(
                    quantity: item.quantity,
                    onAdd: onIncrement,
                    onRemove: onDecrement,
                  ),
                ],
              ),
            ],
          ),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cartWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image,
              const SizedBox(width: 16),
              details,
            ],
          ),
        );
      },
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _QuantityStepper({
    required this.quantity,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: _cartSoftest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.remove_rounded,
                size: 18,
                color: Pallete.primaryRed,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              quantity.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _cartText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: onAdd,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Pallete.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FulfillmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? _cartText : _cartMuted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = _cartText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _cartMuted, fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
