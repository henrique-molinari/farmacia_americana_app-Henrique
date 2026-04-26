import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_profile_data_store.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:provider/provider.dart';

class AttendantProfileScreen extends StatefulWidget {
  const AttendantProfileScreen({super.key});

  @override
  State<AttendantProfileScreen> createState() => _AttendantProfileScreenState();
}

class _AttendantProfileScreenState extends State<AttendantProfileScreen> {
  final AttendantProfileDataStore _profileStore =
      AttendantProfileDataStore.instance;

  Future<void> _logout() async {
    await context.read<AuthSessionViewModel>().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profileStore,
      builder: (context, _) {
        final profileData = _profileStore.data;

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
                  'FARMÁCIA AMERICANA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Pallete.primaryRed,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.attendantNotifications,
                  );
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Color(0xFF111111),
                  size: 30,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 182,
                    height: 182,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    profileData.fullName,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileData.roleDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5C5C5C),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _buildSection(
                    title: 'PROFISSIONAL',
                    children: [
                      _MenuRow(
                        icon: Icons.badge_rounded,
                        label: 'Meus Atendimentos',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.attendantChat);
                        },
                      ),
                      _MenuRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Dados Pessoais',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attendantPersonalData,
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSection(
                    title: 'CONFIGURAÇÕES',
                    children: [
                      _MenuRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notificações',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attendantNotifications,
                          );
                        },
                      ),
                      _MenuRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Segurança e Senha',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attendantSecurity,
                          );
                        },
                      ),
                      _MenuRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Ajuda e Suporte',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attendantSupport,
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  TextButton.icon(
                    onPressed: () => _logout(),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Pallete.primaryRed,
                      size: 29,
                    ),
                    label: const Text(
                      'Sair da Conta',
                      style: TextStyle(
                        color: Pallete.primaryRed,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.homeAttendant,
                );
                return;
              }

              if (index == 1) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.attendantSearch,
                );
                return;
              }

              if (index == 2) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.attendantChat,
                );
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
                icon: Icon(Icons.search),
                label: 'BUSCAR',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'CHAT',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'PERFIL',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF4E4E4E),
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEDED)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 78,
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF5F5F5F), size: 33),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD0D0D0),
                  size: 36,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE8E8E8)),
      ],
    );
  }
}
