enum UserRole { cliente, atendente, farmaceutico, gerente, admin }

extension UserRoleX on UserRole {
  static UserRole fromValue(String? value) {
    switch (value) {
      case 'atendente':
        return UserRole.atendente;
      case 'farmaceutico':
        return UserRole.farmaceutico;
      case 'gerente':
        return UserRole.gerente;
      case 'admin':
        return UserRole.admin;
      case 'cliente':
      default:
        return UserRole.cliente;
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    required this.role,
  });

  factory User.fromProfileMap(Map<String, dynamic> map) {
    return User(
      id: (map['id'] ?? '').toString(),
      name: (map['full_name'] ?? map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: UserRoleX.fromValue(map['role']?.toString()),
    );
  }
}
