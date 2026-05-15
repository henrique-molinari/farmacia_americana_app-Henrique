import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_notification_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';

class AttendantNotificationsScreen extends StatefulWidget {
  const AttendantNotificationsScreen({super.key});

  @override
  State<AttendantNotificationsScreen> createState() =>
      _AttendantNotificationsScreenState();
}

class _AttendantNotificationsScreenState
    extends State<AttendantNotificationsScreen> {
  late Future<List<AttendantNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<AttendantNotification>> _loadNotifications() async {
    final messages = await SupportChatRepository.instance
        .fetchRecentHumanRequestNotifications(limit: 20);

    return messages
        .map(
          (message) => AttendantNotification(
            icon: Icons.message_rounded,
            iconBackground: const Color(0xFFFDE8E8),
            iconColor: Pallete.primaryRed,
            timeLabel: _timeLabel(message.createdAt),
            title: 'Cliente ${message.clientName} quer atendimento',
            description: message.isUrgent
                ? 'Solicitação urgente para falar com atendente agora.'
                : 'Solicitação para falar com atendente agora.',
            actionLabel: 'Abrir chat',
            chatId: message.clientId,
          ),
        )
        .toList(growable: false);
  }

  void _reloadNotifications() {
    setState(() {
      _notificationsFuture = _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.primaryRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifica\u00e7\u00f5es',
          style: TextStyle(
            color: Color(0xFF151515),
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Ultimas\nmensagens',
                style: TextStyle(
                  color: Pallete.primaryRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<AttendantNotification>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            final notifications =
                snapshot.data ?? const <AttendantNotification>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ATENDIMENTO',
                    style: TextStyle(
                      color: Pallete.primaryRed,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pedidos de Atendimento',
                    style: TextStyle(
                      color: Color(0xFF161616),
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Não foi possível carregar as notificações.',
                        ),
                      ),
                    )
                  else if (notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Nenhum pedido de atendimento por enquanto.',
                        ),
                      ),
                    )
                  else
                    ...notifications.asMap().entries.map((entry) {
                      final index = entry.key;
                      final notification = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == notifications.length - 1 ? 0 : 16,
                        ),
                        child: _UrgentCard(
                          notification: notification,
                          onActionPressed: notification.chatId == null
                              ? null
                              : () async {
                                  await Navigator.pushNamed(
                                    context,
                                    AppRoutes.attendantChatDetail,
                                    arguments: notification.chatId,
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  _reloadNotifications();
                                },
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _timeLabel(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'AGORA';
    if (difference.inMinutes < 60) return '${difference.inMinutes} MIN';
    if (difference.inHours < 24) return '${difference.inHours}H';
    if (difference.inDays == 1) return 'ONTEM';
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}';
  }
}

class _UrgentCard extends StatelessWidget {
  final AttendantNotification notification;
  final VoidCallback? onActionPressed;

  const _UrgentCard({required this.notification, this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onActionPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: const Border(
              left: BorderSide(color: Pallete.primaryRed, width: 4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: notification.iconBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        notification.icon,
                        color: notification.iconColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      notification.timeLabel,
                      style: const TextStyle(
                        color: Color(0xFFB0A3A3),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: Color(0xFF151515),
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.description,
                  style: const TextStyle(
                    color: Color(0xFF3D2B2B),
                    height: 1.4,
                    fontSize: 18,
                  ),
                ),
                if (notification.actionLabel != null &&
                    onActionPressed != null) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onActionPressed,
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: Pallete.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        notification.actionLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
