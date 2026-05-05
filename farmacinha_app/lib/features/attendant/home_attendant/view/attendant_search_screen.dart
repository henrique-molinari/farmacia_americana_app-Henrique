// attendant_search_screen.dart

import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_search_client_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_search__view_model.dart';

class AttendantSearchScreen extends StatefulWidget {
  const AttendantSearchScreen({super.key});

  @override
  State<AttendantSearchScreen> createState() => _AttendantSearchScreenState();
}

class _AttendantSearchScreenState extends State<AttendantSearchScreen> {
  late final AttendantSearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendantSearchViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F4),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF4F4F4),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Row(
          children: [
            Text(
              'PAINEL AMERICANA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB80000),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.attendantProfile);
            },
            child: Container(
              width: 46,
              height: 46,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Pallete.primaryRed, width: 2),
              ),
              child: const Icon(Icons.person, color: Color(0xFF111111)),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final clients = _viewModel.clients;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Central de Atendimento',
                  style: TextStyle(
                    fontSize: 52 / 2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF151515),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Localize o cliente para iniciar o atendimento\nfarmacêutico.',
                  style: TextStyle(
                    fontSize: 18 / 1.25,
                    color: Color(0xFF4A2C2C),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E7E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.person_search_outlined,
                          color: Color(0xFF6E4B4B),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _viewModel.searchController,
                          decoration: const InputDecoration(
                            hintText: 'Digite o CPF ou Nome',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 18 / 1.2,
                              color: Color(0xFF9A9A9A),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _viewModel.onSearchPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Pallete.primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              'BUSCAR',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18 / 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      color: Pallete.primaryRed,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Buscas\nRecentes',
                      style: TextStyle(
                        fontSize: 21 / 1.3,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (clients.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Nenhum cliente encontrado.')),
                  )
                else
                  ...clients.map(
                    (client) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecentClientCard(
                        client: client,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attendantChatDetail,
                            arguments: client.id,
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFEFEFEF),
                    border: Border.all(color: const Color(0xFFF4F4F4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF0D467),
                          child: Icon(
                            Icons.lightbulb,
                            color: Color(0xFF4A3C0A),
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dica rápida',
                              style: TextStyle(
                                fontSize: 18 / 1.15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sempre verifique se o cliente possui\nconvênio ativo no sistema\nAmericana Plus para garantir os\nmelhores descontos em\nmedicamentos de uso contínuo.',
                              style: TextStyle(
                                fontSize: 16 / 1.2,
                                color: Color(0xFF402626),
                                height: 1.5,
                              ),
                            ),
                          ],
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.homeAttendant);
            return;
          }

          if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.attendantChat);
          }

          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.attendantProfile);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Pallete.primaryRed,
        unselectedItemColor: const Color(0xFF9F9F9F),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'INÍCIO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'ESTOQUE',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'CHAT'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PERFIL'),
        ],
      ),
    );
  }
}

class _RecentClientCard extends StatelessWidget {
  final AttendantSearchClient client;
  final VoidCallback onTap;

  const _RecentClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E7E7),
                  borderRadius: BorderRadius.circular(14),
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
                      client.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101010),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.cpf,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F6F6F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E9E9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        client.timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFD0D0D0),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
