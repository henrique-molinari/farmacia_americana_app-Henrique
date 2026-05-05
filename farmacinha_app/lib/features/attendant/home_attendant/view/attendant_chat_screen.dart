import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_search_client_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_chat_view_model.dart';

class AttendantChatScreen extends StatefulWidget {
  const AttendantChatScreen({super.key});

  @override
  State<AttendantChatScreen> createState() => _AttendantChatScreenState();
}

class _AttendantChatScreenState extends State<AttendantChatScreen> {
  late final AttendantChatViewModel _viewModel;
  bool _didSyncRouteSelection = false;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendantChatViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didSyncRouteSelection) return;

    final selectedClientId =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (selectedClientId != null) {
      _viewModel.selectClient(selectedClientId);
    }

    _didSyncRouteSelection = true;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F4),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF4F4F4),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Row(
          children: [
            Text(
              'FARMÁCIA AMERICANA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB80000),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications,
              color: Color(0xFF101828),
              size: 28,
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ATENDIMENTO AO CLIENTE',
                  style: TextStyle(
                    color: Color(0xFFB80000),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conversas Ativas',
                  style: TextStyle(
                    fontSize: 21.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF161A1D),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  width: 82,
                  height: 5,
                  color: const Color(0xFFF2C500),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _viewModel.searchController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6E4B4B)),
                      hintText: 'Buscar paciente ou pedido...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_viewModel.clients.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Nenhuma conversa encontrada.')),
                  )
                else
                  ..._viewModel.clients.map(
                    (client) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ChatClientCard(
                        client: client,
                        isSelected: _viewModel.selectedClientId == client.id,
                        onTap: () {
                          _viewModel.selectClient(client.id);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attendantChatDetail,
                            arguments: client.id,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.homeAttendant);
            return;
          }

          if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.attendantProductRegistration,
            );
            return;
          }

          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.attendantProfile);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Pallete.primaryRed,
        unselectedItemColor: const Color(0xFF707A89),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Estoque',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _ChatClientCard extends StatelessWidget {
  final AttendantSearchClient client;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChatClientCard({
    required this.client,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const previewText = 'Olá, preciso de ajuda com meu pedido...';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Pallete.primaryRed : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x14B80000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? const Color(0xFFF7DADA)
                      : const Color(0xFFE7E7E7),
                ),
                child: Center(
                  child: Text(
                    client.initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatName(client.name),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      previewText,
                      style: TextStyle(
                        color: isSelected
                            ? Pallete.primaryRed
                            : const Color(0xFF4F3131),
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTimeLabel(client.timeLabel),
                    style: TextStyle(
                      color: isSelected
                          ? Pallete.primaryRed
                          : const Color(0xFF6F5959),
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: isSelected
                        ? Pallete.primaryRed
                        : const Color(0xFF6F5959),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatName(String upperName) {
    return upperName
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _formatTimeLabel(String label) {
    if (label.toUpperCase() == 'HÁ 2 HORAS') return 'AGORA';
    return label;
  }
}
