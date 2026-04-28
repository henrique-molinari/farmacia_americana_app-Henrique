import 'package:farmacia_app/features/auth/data/models/user_model.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';

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
}
