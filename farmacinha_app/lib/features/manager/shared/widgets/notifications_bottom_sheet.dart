import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:flutter/material.dart';

class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsBottomSheet(),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'success':
        return const Color(0xFF10B981);
      case 'warning':
        return const Color(0xFFFAC000);
      case 'error':
        return Pallete.primaryRed;
      default:
        return Pallete.textColor;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'warning':
        return Icons.info_outline_rounded;
      case 'error':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  List<_ManagerNotification> _buildNotifications(ManagerDashboardData data) {
    final notifications = <_ManagerNotification>[];

    for (final order in data.recentOrders.take(4)) {
      notifications.add(
        _ManagerNotification(
          title: 'Pedido ${order.id.replaceFirst('PED-', '#')}',
          description:
              '${order.customerName} - R\$ ${order.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
          time: _relativeTime(order.createdAt),
          type: order.statusLabel == 'PENDENTE' ? 'warning' : 'success',
        ),
      );
    }

    final lowStockProducts = data.products
        .where((product) => product.stock <= 10)
        .take(3)
        .toList(growable: false);

    for (final product in lowStockProducts) {
      notifications.add(
        _ManagerNotification(
          title: 'Estoque critico',
          description: '${product.name} com ${product.stock} unidades.',
          time: 'Agora',
          type: 'error',
        ),
      );
    }

    return notifications;
  }

  String _relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return 'Ha ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Ha ${difference.inHours} horas';
    if (difference.inDays == 1) return 'Ontem';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: FutureBuilder<ManagerDashboardData>(
        future: ManagerDashboardRepository.instance.fetchDashboardData(),
        builder: (context, snapshot) {
          final notifications = snapshot.hasData
              ? _buildNotifications(snapshot.data!)
              : <_ManagerNotification>[];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Pallete.borderColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notificacoes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Pallete.primaryRed,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${notifications.length} novas',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Pallete.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: Pallete.primaryRed),
                )
              else if (snapshot.hasError)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 36),
                  child: Text(
                    'Nao foi possivel carregar notificacoes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Pallete.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 36),
                  child: Text(
                    'Nenhuma notificacao real encontrada ainda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Pallete.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Pallete.borderColor,
                    indent: 20,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final color = _colorForType(notification.type);
                    final icon = _iconForType(notification.type);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notification.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Pallete.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Pallete.textColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          );
        },
      ),
    );
  }
}

class _ManagerNotification {
  final String title;
  final String description;
  final String time;
  final String type;

  const _ManagerNotification({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
  });
}
