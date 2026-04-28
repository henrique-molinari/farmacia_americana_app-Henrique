import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/profile_manager/view/widgets/profile_header.dart';
import 'package:farmacia_app/features/manager/profile_manager/view/widgets/profile_form.dart';
import 'package:farmacia_app/features/manager/profile_manager/view/widgets/activity_history.dart';
import 'package:farmacia_app/features/manager/profile_manager/view_model/profile_manager_view_model.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';

class ProfileManagerScreen extends StatefulWidget {
  const ProfileManagerScreen({super.key});

  @override
  State<ProfileManagerScreen> createState() => _ProfileManagerScreenState();
}

class _ProfileManagerScreenState extends State<ProfileManagerScreen> {
  final _viewModel = ProfileManagerViewModel();

  void _onSave(String name, String role, String email) {
    setState(() {
      _viewModel.name = name;
      _viewModel.role = role;
      _viewModel.email = email;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Perfil atualizado com sucesso!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sair da conta',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: Pallete.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Pallete.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthSessionViewModel.instance.signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.primaryRed,
              foregroundColor: Pallete.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Pallete.whiteColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: const Text(
        'Meu Perfil',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Pallete.borderColor),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          // Bloco de foto, nome, cargo e filial
          ProfileHeader(
            name: _viewModel.name,
            role: _viewModel.role,
            filial: _viewModel.filial, // ← filial passada aqui
          ),

          const SizedBox(height: 28),

          // Formulário editável
          ProfileForm(
            initialName: _viewModel.name,
            initialRole: _viewModel.role,
            initialEmail: _viewModel.email,
            onSave: _onSave,
          ),

          const SizedBox(height: 20),

          // Histórico de atividades
          ActivityHistory(activities: _viewModel.activityHistory),

          const SizedBox(height: 20),

          // Botão de logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _onLogout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: Pallete.textColor,
              ),
              label: const Text(
                'Sair da conta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Pallete.textColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Pallete.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
