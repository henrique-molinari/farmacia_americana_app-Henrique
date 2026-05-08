import 'dart:async';

import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/home_manager/view/home_manager_screen.dart';
import 'package:farmacia_app/features/manager/bi_manager/view/bi_manager_screen.dart';
import 'package:farmacia_app/features/manager/stock_manager/view/stock_manager_screen.dart';
import 'package:farmacia_app/features/manager/profile_manager/view/profile_manager_screen.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerShellScreen extends StatefulWidget {
  const ManagerShellScreen({super.key});

  @override
  State<ManagerShellScreen> createState() => _ManagerShellScreenState();
}

class _ManagerShellScreenState extends State<ManagerShellScreen> {
  int _currentIndex = 0;
  RealtimeChannel? _notificationChannel;
  final Set<String> _shownNotificationIds = <String>{};

  final List<Widget> _screens = const [
    HomeManagerScreen(),
    BiManagerScreen(),
    StockManagerScreen(),
    ProfileManagerScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToManagerNotifications();
  }

  @override
  void dispose() {
    final channel = _notificationChannel;
    _notificationChannel = null;
    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Pallete.whiteColor,
          border: Border(top: BorderSide(color: Pallete.borderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Pallete.primaryRed,
          unselectedItemColor: Pallete.textColor,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'BI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Estoque',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeToManagerNotifications() {
    if (_notificationChannel != null) {
      return;
    }

    final client = Supabase.instance.client;
    _notificationChannel = client.channel('manager-notifications')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'orders',
        callback: (payload) => unawaited(_handleOrderCreated(payload)),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        callback: (payload) => unawaited(_handleOrderUpdated(payload)),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'profiles',
        callback: _handleProfileCreated,
      )
      ..subscribe();
  }

  Future<void> _handleOrderCreated(PostgresChangePayload payload) async {
    final order = await ManagerDashboardRepository.instance.fetchOrderByRawId(
      payload.newRecord['id'],
    );
    if (order == null) {
      return;
    }

    _showManagerNotification(
      id: 'order-created-${order.id}',
      title: 'Novo pedido realizado',
      message:
          '${order.customerName} fez o pedido ${order.id.replaceFirst('PED-', '#')}.',
      icon: Icons.receipt_long_rounded,
      onTap: () => setState(() => _currentIndex = 0),
    );
  }

  Future<void> _handleOrderUpdated(PostgresChangePayload payload) async {
    final newStatus = (payload.newRecord['status'] ?? '').toString();
    final oldStatus = (payload.oldRecord['status'] ?? '').toString();
    if (newStatus != 'delivered' || oldStatus == 'delivered') {
      return;
    }

    final order = await ManagerDashboardRepository.instance.fetchOrderByRawId(
      payload.newRecord['id'],
    );
    if (order == null) {
      return;
    }

    _showManagerNotification(
      id: 'sale-finished-${order.id}',
      title: 'Venda finalizada',
      message:
          '${order.customerName} concluiu uma venda de R\$ ${order.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}.',
      icon: Icons.check_circle_outline_rounded,
      onTap: () => setState(() => _currentIndex = 0),
    );
  }

  void _handleProfileCreated(PostgresChangePayload payload) {
    final profile = payload.newRecord;
    if ((profile['role'] ?? '').toString() != 'cliente') {
      return;
    }

    final client = ManagerClientSummary(
      id: (profile['id'] ?? '').toString(),
      name: _profileName(profile),
      email: (profile['email'] ?? '').toString(),
      createdAt: DateTime.now(),
    );

    _showManagerNotification(
      id: 'client-created-${client.id}',
      title: 'Novo cliente cadastrado',
      message: client.name,
      icon: Icons.person_add_alt_1_rounded,
      onTap: () => setState(() => _currentIndex = 0),
    );
  }

  void _showManagerNotification({
    required String id,
    required String title,
    required String message,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    if (!mounted || !_shownNotificationIds.add(id)) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Pallete.primaryRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title: $message',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: onTap,
          ),
        ),
      );
  }

  String _profileName(Map<String, dynamic> profile) {
    final name = (profile['full_name'] ?? '').toString().trim();
    if (name.isNotEmpty) {
      return name;
    }

    final email = (profile['email'] ?? '').toString().trim();
    if (email.isNotEmpty) {
      return email;
    }

    return 'Cliente';
  }
}
