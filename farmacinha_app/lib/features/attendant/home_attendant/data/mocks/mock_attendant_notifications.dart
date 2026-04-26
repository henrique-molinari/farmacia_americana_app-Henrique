import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_notification_model.dart';

class MockAttendantNotifications {
  static List<AttendantNotification> getNotifications() {
    return const [
      AttendantNotification(
        icon: Icons.error,
        iconBackground: Color(0xFFFDE8E8),
        iconColor: Pallete.primaryRed,
        timeLabel: 'AGORA',
        title: 'Ruptura de Estoque',
        description:
            'Insulina Glargina atingiu n\u00edvel cr\u00edtico na Unidade 01. Reposi\u00e7\u00e3o imediata necess\u00e1ria.',
      ),
      AttendantNotification(
        icon: Icons.message,
        iconBackground: Color(0xFFFDE8E8),
        iconColor: Pallete.primaryRed,
        timeLabel: 'AGORA',
        title: 'Nova Mensagem de Cliente',
        description:
            'Mariana Silva enviou uma nova mensagem sobre o seu pedido em andamento.',
        actionLabel: 'Responder',
        chatId: 'client-1',
      ),
    ];
  }
}
