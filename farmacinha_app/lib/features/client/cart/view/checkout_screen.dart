import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/cart/view/order_confirmation_screen.dart';
import 'package:farmacia_app/features/client/cart/view_model/cart_view_model.dart';
import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';

const Color _checkoutBg = Color(0xFFFFF8F7);
const Color _checkoutSoft = Color(0xFFFFF0EE);
const Color _checkoutWhite = Colors.white;
const Color _checkoutText = Color(0xFF291715);
const Color _checkoutMuted = Color(0xFF5D3F3C);
const Color _checkoutBlue = Color(0xFF005F93);
const Color _checkoutOlive = Color(0xFF705D00);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartViewModel viewModel = CartViewModel.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _checkoutBg,
      appBar: AppBar(
        backgroundColor: _checkoutBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
        ),
        titleSpacing: 0,
        title: const Text(
          'Finalizar Pedido',
          style: TextStyle(
            color: Pallete.primaryRed,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                'Pharmacy Care',
                style: TextStyle(
                  color: Pallete.primaryRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFulfillmentToggle(),
                    const SizedBox(height: 26),
                    _buildDeliverySection(),
                    const SizedBox(height: 26),
                    _buildCustomerSection(),
                    const SizedBox(height: 26),
                    _buildPaymentSection(),
                    const SizedBox(height: 26),
                    _buildSummarySection(),
                    const SizedBox(height: 18),
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: Pallete.textColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'AMBIENTE 100% SEGURO',
                            style: TextStyle(
                              color: Pallete.textColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomAction(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFulfillmentToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _checkoutSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Entrega',
              selected:
                  viewModel.selectedFulfillmentType ==
                  CartFulfillmentType.delivery,
              onTap: () =>
                  viewModel.selectFulfillmentType(CartFulfillmentType.delivery),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: 'Retirada',
              selected:
                  viewModel.selectedFulfillmentType ==
                  CartFulfillmentType.pickup,
              onTap: () =>
                  viewModel.selectFulfillmentType(CartFulfillmentType.pickup),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    final isDelivery =
        viewModel.selectedFulfillmentType == CartFulfillmentType.delivery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isDelivery ? 'Entrega' : 'Retirada',
              style: const TextStyle(
                color: _checkoutText,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: isDelivery ? _openAddressSheet : null,
              child: Text(
                isDelivery ? 'Alterar' : 'Farmácia selecionada',
                style: TextStyle(
                  color: isDelivery ? Pallete.primaryRed : Pallete.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _checkoutWhite,
            borderRadius: BorderRadius.circular(22),
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
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: _checkoutSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDelivery
                      ? viewModel.selectedAddress.icon
                      : Icons.storefront_rounded,
                  color: isDelivery ? Pallete.primaryRed : _checkoutBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDelivery
                          ? viewModel.selectedAddress.title
                          : viewModel.storePickupLabel,
                      style: const TextStyle(
                        color: _checkoutText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isDelivery
                          ? viewModel.selectedAddress.formattedLines
                          : '${viewModel.storePickupAddress}\nRetirada disponível em até 20 min.',
                      style: const TextStyle(
                        color: _checkoutMuted,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isDelivery
                    ? Icons.location_on_rounded
                    : Icons.inventory_2_rounded,
                color: const Color(0xFFD8D0BF),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados do Cliente',
          style: TextStyle(
            color: _checkoutText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _checkoutWhite,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoLine(label: 'Nome', value: viewModel.customerName),
              const SizedBox(height: 12),
              _InfoLine(label: 'Email', value: viewModel.customerEmail),
              const SizedBox(height: 12),
              _InfoLine(
                label: 'Contato',
                value: viewModel.selectedAddress.recipient,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pagamento',
          style: TextStyle(
            color: _checkoutText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _PaymentTile(
          icon: Icons.credit_card_rounded,
          title: 'Cartão de Crédito',
          subtitle: 'Até 6x sem juros',
          selected:
              viewModel.selectedPaymentMethod == PaymentMethod.cardOnDelivery,
          onTap: () =>
              viewModel.selectPaymentMethod(PaymentMethod.cardOnDelivery),
        ),
        const SizedBox(height: 12),
        _PaymentTile(
          icon: Icons.qr_code_2_rounded,
          title: 'Pix',
          subtitle: '5% de desconto extra',
          selected: viewModel.selectedPaymentMethod == PaymentMethod.pix,
          subtitleColor: _checkoutOlive,
          onTap: () => viewModel.selectPaymentMethod(PaymentMethod.pix),
        ),
        const SizedBox(height: 12),
        _PaymentTile(
          icon: Icons.payments_rounded,
          title: 'Dinheiro',
          subtitle: 'Pague na entrega',
          selected:
              viewModel.selectedPaymentMethod == PaymentMethod.cashOnDelivery,
          onTap: () =>
              viewModel.selectPaymentMethod(PaymentMethod.cashOnDelivery),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo do Pedido',
          style: TextStyle(
            color: _checkoutText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _checkoutSoft,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              _CheckoutSummaryRow(
                label: 'Subtotal (${viewModel.itemCount} itens)',
                value: CartViewModel.formatCurrency(viewModel.subtotal),
              ),
              const SizedBox(height: 14),
              _CheckoutSummaryRow(
                label:
                    viewModel.selectedFulfillmentType ==
                        CartFulfillmentType.delivery
                    ? 'Entrega'
                    : 'Retirada',
                value: viewModel.shippingLabel,
                valueColor: viewModel.shippingFee == 0
                    ? _checkoutOlive
                    : _checkoutText,
              ),
              const SizedBox(height: 14),
              _CheckoutSummaryRow(
                label: 'Descontos',
                value:
                    '- ${CartViewModel.formatCurrency(viewModel.couponDiscount + viewModel.paymentDiscount)}',
                valueColor: Pallete.primaryRed,
              ),
              const SizedBox(height: 18),
              const Divider(color: Color(0xFFE7BDB8)),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        color: _checkoutText,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CartViewModel.formatCurrency(viewModel.total),
                        style: const TextStyle(
                          color: _checkoutText,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'ou 2x de ${CartViewModel.formatCurrency(viewModel.total / 2)}',
                        style: const TextStyle(
                          color: _checkoutMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      color: _checkoutBg.withOpacity(0.94),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: ElevatedButton.icon(
            onPressed: viewModel.isEmpty || viewModel.isProcessingCheckout
                ? null
                : _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.primaryRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Pallete.borderColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            iconAlignment: IconAlignment.end,
            icon: viewModel.isProcessingCheckout
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.chevron_right_rounded),
            label: Text(
              viewModel.isProcessingCheckout
                  ? 'Confirmando...'
                  : 'Confirmar Pedido',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    try {
      final order = await viewModel.checkout();
      if (!mounted || order == null) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Pallete.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _openAddressSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Escolha o endereço',
                  style: TextStyle(
                    color: _checkoutText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...viewModel.addresses.map(
                  (address) => RadioListTile<String>(
                    value: address.id,
                    groupValue: viewModel.selectedAddress.id,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      viewModel.selectAddress(value);
                      Navigator.of(sheetContext).pop();
                    },
                    activeColor: Pallete.primaryRed,
                    title: Text(
                      address.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(address.formattedLines),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
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
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? _checkoutText : _checkoutMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(color: _checkoutMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _checkoutText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color subtitleColor;

  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.subtitleColor = _checkoutMuted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _checkoutWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Pallete.primaryRed : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _checkoutSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _checkoutMuted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _checkoutText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                      fontWeight: subtitleColor == _checkoutOlive
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: selected ? 1 : 0,
              child: const Icon(
                Icons.check_circle_rounded,
                color: Pallete.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _CheckoutSummaryRow({
    required this.label,
    required this.value,
    this.valueColor = _checkoutText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: _checkoutMuted, fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
