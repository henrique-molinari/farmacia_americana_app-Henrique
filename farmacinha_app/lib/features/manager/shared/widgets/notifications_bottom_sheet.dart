import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  static const List<Map<String, String>> _notifications = [
    {
      'title': 'Estoque crítico',
      'description': 'Paracetamol 750mg abaixo de 5 unidades.',
      'time': 'Agora',
      'type': 'error',
    },
    {
      'title': 'Relatório gerado',
      'description': 'O relatório mensal foi gerado com sucesso.',
      'time': 'Há 2 horas',
      'type': 'success',
    },
    {
      'title': 'Novo pedido #CK-9282',
      'description': 'Ricardo Oliveira — R\$ 452,00',
      'time': 'Hoje, 09:30',
      'type': 'warning',
    },
    {
      'title': 'Estoque atualizado',
      'description': 'Vitamina C 1g teve entrada de 50 unidades.',
      'time': 'Hoje, 08:15',
      'type': 'success',
    },
    {
      'title': 'Pedido #CK-9279 cancelado',
      'description': 'Marcos Pereira cancelou o pedido de R\$ 78,50.',
      'time': 'Ontem, 17:48',
      'type': 'error',
    },
  ];

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

  // Método estático para abrir o BottomSheet facilmente em qualquer tela
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrasto
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Pallete.borderColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          const SizedBox(height: 16),

          // Cabeçalho
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                // Badge com quantidade
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
                    '${_notifications.length} novas',
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

          // Lista de notificações
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notifications.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Pallete.borderColor,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              final color = _colorForType(notification['type']!);
              final icon = _iconForType(notification['type']!);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone colorido
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

                    // Título, descrição e hora
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification['description']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Pallete.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['time']!,
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

          // Espaço para o safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}