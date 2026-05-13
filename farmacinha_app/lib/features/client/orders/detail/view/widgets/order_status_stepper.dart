import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusStepper({super.key, required this.currentStatus});

  static const List<_StepInfo> _steps = [
    _StepInfo(
      status: OrderStatus.pending,
      label: 'Aguardando',
      icon: Icons.hourglass_empty_rounded,
    ),
    _StepInfo(
      status: OrderStatus.confirmed,
      label: 'Confirmado',
      icon: Icons.check_circle_outline_rounded,
    ),
    _StepInfo(
      status: OrderStatus.preparing,
      label: 'Em preparo',
      icon: Icons.medication_rounded,
    ),
    _StepInfo(
      status: OrderStatus.transit,
      label: 'Em trânsito',
      icon: Icons.local_shipping_rounded,
    ),
    _StepInfo(
      status: OrderStatus.delivered,
      label: 'Entregue',
      icon: Icons.check_circle_rounded,
    ),
  ];

  int get _currentStepIndex {
    if (currentStatus == OrderStatus.cancelled) return -1;
    return _steps.indexWhere((s) => s.status == currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled) {
      return _buildCancelledState();
    }

    return Column(
      children: [
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              // Linha conectora
              final stepIndex = i ~/ 2;
              final isDone = stepIndex < _currentStepIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isDone ? Pallete.primaryRed : Pallete.borderColor,
                ),
              );
            }

            final stepIndex = i ~/ 2;
            final isDone = stepIndex < _currentStepIndex;
            final isCurrent = stepIndex == _currentStepIndex;
            final step = _steps[stepIndex];

            return Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isDone || isCurrent
                            ? Pallete.primaryRed
                            : Pallete.grayColor,
                    boxShadow:
                        isCurrent
                            ? [
                              BoxShadow(
                                color: Pallete.primaryRed.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    step.icon,
                    size: 22,
                    color: isDone || isCurrent ? Colors.white : Pallete.textColor,
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        // Labels abaixo dos steps
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) return const Expanded(child: SizedBox());
            final stepIndex = i ~/ 2;
            final isCurrent = stepIndex == _currentStepIndex;
            final isDone = stepIndex < _currentStepIndex;
            return SizedBox(
              width: 44,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _steps[stepIndex].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                    color:
                        isCurrent || isDone
                            ? Pallete.primaryRed
                            : Pallete.textColor,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCancelledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_rounded, color: Colors.grey, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este pedido foi cancelado',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepInfo {
  final OrderStatus status;
  final String label;
  final IconData icon;
  const _StepInfo({
    required this.status,
    required this.label,
    required this.icon,
  });
}
