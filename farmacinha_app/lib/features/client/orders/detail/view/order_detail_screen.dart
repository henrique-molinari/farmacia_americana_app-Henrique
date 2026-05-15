import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/client/orders/detail/view_model/order_detail_view_model.dart';
import 'package:farmacia_app/features/client/orders/detail/view/widgets/order_status_stepper.dart';
import 'package:farmacia_app/features/client/delivery/view/delivery_tracking_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = OrderDetailViewModel(order: widget.order);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          order.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Pallete.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper de status
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status do Pedido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF291715),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OrderStatusStepper(currentStatus: order.status),
                  if (viewModel.formattedEstimatedDelivery != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: Pallete.textColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Previsão: ${viewModel.formattedEstimatedDelivery}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Pallete.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botão de rastreamento
            if (viewModel.canTrack)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeliveryTrackingScreen(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.local_shipping_rounded),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Rastrear Entrega',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),

            if (viewModel.canTrack) const SizedBox(height: 12),

            // Itens do pedido
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itens (${order.itemCount})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF291715),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => _OrderItemRow(item: item)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF291715),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          viewModel.formattedTotal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Pallete.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Informações de entrega e pagamento
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalhes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF291715),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Data do pedido',
                    value: viewModel.formattedDate,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Endereço de entrega',
                    value: order.deliveryAddress,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.payment_rounded,
                    label: 'Forma de pagamento',
                    value: order.paymentMethod.label,
                  ),
                  if (order.trackingCode != null) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.qr_code_rounded,
                      label: 'Código de rastreio',
                      value: order.trackingCode!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImageUrl.isEmpty
                ? Container(
                    width: 48,
                    height: 48,
                    color: Pallete.grayColor,
                    child: const Icon(
                      Icons.medication_rounded,
                      color: Pallete.primaryRed,
                      size: 20,
                    ),
                  )
                : Image.network(
                    item.productImageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: Pallete.grayColor,
                      child: const Icon(Icons.image_not_supported, size: 20),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF291715),
                  ),
                ),
                Text(
                  '${item.quantity}x  R\$ ${item.unitPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Pallete.textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF291715),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Pallete.primaryRed),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Pallete.textColor),
              ),
              Text(
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF291715),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
