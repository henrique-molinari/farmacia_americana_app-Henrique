import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/widgets/attendant_chat_item.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/widgets/attendant_status_tile.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/home_attendant_view_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';

class HomeAttendantScreen extends StatefulWidget {
  const HomeAttendantScreen({super.key});

  @override
  State<HomeAttendantScreen> createState() => _HomeAttendantScreenState();
}

class _HomeAttendantScreenState extends State<HomeAttendantScreen> {
  final HomeAttendantViewModel viewModel = HomeAttendantViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.onHumanSupportRequest = _showHumanSupportRequestNotification;
    viewModel.addListener(_onViewModelChanged);
    viewModel.initialize();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    viewModel.onHumanSupportRequest = null;
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsCount = viewModel.notificationsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.attendantProfile);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Pallete.primaryRed, width: 2),
                  color: const Color(0xFFECEFF4),
                ),
                child: const Icon(Icons.person, color: Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'PAINEL AMERICANA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.attendantNotifications,
                  );
                  if (!mounted) {
                    return;
                  }
                  await viewModel.refresh();
                },
                icon: const Icon(Icons.notifications, color: Color(0xFF111827)),
              ),
              if (notificationsCount > 0)
                Positioned(
                  right: 9,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$notificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.attendantProfile);
            },
            icon: const Icon(Icons.settings, color: Color(0xFF111827)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE7E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCACA)),
                      ),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          color: Pallete.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BUSCAR ATENDIMENTO', style: _titleStyle),
                        const SizedBox(height: 16),
                        TextField(
                          controller: viewModel.searchController,
                          decoration: InputDecoration(
                            hintText: 'Nome ou CPF do cliente...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF8B9BB4),
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF8B9BB4),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE9EEF5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEEDEF),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(color: Pallete.primaryRed, width: 4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: Pallete.primaryRed,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pedidos de Atendimento ($notificationsCount)',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Pallete.primaryRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Clientes aguardando um atendente.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFEA5A63),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FILTRAR POR STATUS',
                          style: TextStyle(
                            color: Color(0xFF8B9BB4),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...viewModel.statusList.map(
                          (status) => AttendantStatusTile(
                            label: status.label,
                            count: status.count,
                            icon: status.icon,
                            selected: status.id == viewModel.selectedStatus,
                            onTap: () => viewModel.selectStatus(status.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'CONVERSAS\nATIVAS',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                            color: Color(0xFF0B132B),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8EF),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFB6E8CB),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Color(0xFF27C281),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sistema\nOnline',
                                    style: TextStyle(
                                      color: Color(0xFF036B44),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFD9E0EB)),
                  const SizedBox(height: 10),
                  if (viewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (viewModel.chats.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'Nenhuma conversa encontrada para este filtro.',
                        ),
                      ),
                    )
                  else
                    ...viewModel.chats.map(
                      (chat) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AttendantChatItem(
                          chat: chat,
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.attendantChatDetail,
                              arguments: chat.id,
                            );
                            if (!mounted) {
                              return;
                            }
                            await viewModel.refresh();
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B1534),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'CARREGAR CONVERSAS ANTERIORES',
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentTab,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.attendantProductRegistration,
            );
            return;
          }

          if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.attendantChat);
            return;
          }

          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.attendantProfile);
            return;
          }

          viewModel.setTab(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Pallete.primaryRed,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'ESTOQUE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'CHAT',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PERFIL'),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DEE8)),
      ),
      child: child,
    );
  }

  void _showHumanSupportRequestNotification(
    SupportHumanRequestNotification notification,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Cliente ${notification.clientName} quer falar com atendente agora!',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Pallete.primaryRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Abrir chat',
            textColor: Colors.white,
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.attendantChatDetail,
                arguments: notification.clientId,
              );
              if (!mounted) {
                return;
              }
              await viewModel.refresh();
            },
          ),
        ),
      );
  }
}

const _titleStyle = TextStyle(
  fontSize: 15,
  letterSpacing: 1.6,
  fontWeight: FontWeight.w700,
  color: Color(0xFF111827),
);
