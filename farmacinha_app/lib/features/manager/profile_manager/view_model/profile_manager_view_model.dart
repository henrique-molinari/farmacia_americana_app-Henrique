import 'package:farmacia_app/features/auth/data/models/user_model.dart';
import 'package:farmacia_app/features/auth/data/repositories/auth_repository.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileManagerViewModel {
  ProfileManagerViewModel() {
    final user = AuthSessionViewModel.instance.currentUser;
    if (user != null) {
      name = user.name.isEmpty ? 'Gerente' : user.name;
      email = user.email;
      role = _roleLabel(user.role);
    }
  }

  String name = 'Gerente';
  String role = 'Gerente';
  String email = '';

  final String filial = 'Jacutinga - MG';

  final List<Map<String, String>> activityHistory = [
    {'title': 'Login realizado', 'time': 'Sessao atual', 'type': 'success'},
    {
      'title': 'Painel conectado ao Supabase',
      'time': 'Hoje',
      'type': 'success',
    },
  ];

  Future<ManagerProfileSaveResult> saveProfile({
    required String name,
    required String email,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      return const ManagerProfileSaveResult(
        success: false,
        message: 'Informe o nome do gerente.',
      );
    }

    if (!normalizedEmail.endsWith('@americanaadm.com')) {
      return const ManagerProfileSaveResult(
        success: false,
        message: 'O e-mail do gerente precisa terminar com @americanaadm.com.',
      );
    }

    try {
      final updatedUser = await AuthRepository.instance
          .updateCurrentUserProfile(
            fullName: normalizedName,
            email: normalizedEmail,
          );

      AuthSessionViewModel.instance.updateCurrentUser(updatedUser);
      this.name = updatedUser.name.isEmpty ? normalizedName : updatedUser.name;
      this.email = updatedUser.email;
      role = _roleLabel(updatedUser.role);

      if (updatedUser.email.toLowerCase() != normalizedEmail) {
        return ManagerProfileSaveResult(
          success: false,
          message:
              'O Supabase ainda manteve o e-mail ${updatedUser.email}. Rode a RPC update_my_profile_instant no SQL Editor para troca instantanea.',
        );
      }

      return const ManagerProfileSaveResult(
        success: true,
        message: 'Perfil atualizado com sucesso!',
      );
    } on AuthException catch (error) {
      return ManagerProfileSaveResult(
        success: false,
        message: _formatAuthError(error.message),
      );
    } on PostgrestException catch (error) {
      return ManagerProfileSaveResult(success: false, message: error.message);
    } catch (error) {
      return ManagerProfileSaveResult(
        success: false,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<ManagerPasswordSaveResult> saveNewPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty) {
      return const ManagerPasswordSaveResult(message: 'Informe a senha atual.');
    }

    if (newPassword.trim().isEmpty) {
      return const ManagerPasswordSaveResult(message: 'Informe a nova senha.');
    }

    if (newPassword != confirmPassword) {
      return const ManagerPasswordSaveResult(
        message: 'A confirmacao da senha nao confere.',
      );
    }

    try {
      await AuthRepository.instance.updateCurrentUserPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return const ManagerPasswordSaveResult(
        message: 'Senha alterada com sucesso!',
        shouldCloseSheet: true,
      );
    } on AuthException catch (error) {
      return ManagerPasswordSaveResult(
        message: _formatPasswordAuthError(error),
      );
    } catch (error) {
      return ManagerPasswordSaveResult(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.gerente:
        return 'Gerente';
      case UserRole.farmaceutico:
        return 'Farmaceutico';
      case UserRole.atendente:
        return 'Atendente';
      case UserRole.cliente:
        return 'Cliente';
    }
  }

  String _formatAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('already registered') ||
        lowerMessage.contains('already exists')) {
      return 'Este e-mail ja esta em uso por outra conta.';
    }

    if (lowerMessage.contains('email rate limit')) {
      return 'O Supabase bloqueou muitos envios de e-mail agora. Tente novamente mais tarde.';
    }

    return 'Nao foi possivel atualizar o perfil. Detalhe: $message';
  }

  String _formatPasswordAuthError(AuthException error) {
    final lowerMessage = error.message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials')) {
      return 'Senha atual incorreta.';
    }

    if (lowerMessage.contains('password')) {
      return 'O Supabase recusou essa senha. Verifique o tamanho minimo configurado no painel.';
    }

    return 'Nao foi possivel alterar a senha. Detalhe: ${error.message}';
  }
}

class ManagerProfileSaveResult {
  final bool success;
  final String message;

  const ManagerProfileSaveResult({
    required this.success,
    required this.message,
  });
}

class ManagerPasswordSaveResult {
  final String message;
  final bool shouldCloseSheet;

  const ManagerPasswordSaveResult({
    required this.message,
    this.shouldCloseSheet = false,
  });
}
