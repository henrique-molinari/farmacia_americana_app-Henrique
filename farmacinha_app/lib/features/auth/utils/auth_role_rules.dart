import 'package:farmacia_app/features/auth/data/models/user_model.dart';

UserRole inferRoleFromEmail(String email) {
  final normalizedEmail = email.trim().toLowerCase();

  if (normalizedEmail.endsWith('@americanaat.com')) {
    return UserRole.atendente;
  }

  if (normalizedEmail.endsWith('@americanaadm.com')) {
    return UserRole.gerente;
  }

  return UserRole.cliente;
}
