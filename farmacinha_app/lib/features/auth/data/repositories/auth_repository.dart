import 'package:farmacia_app/features/auth/data/models/user_model.dart';
import 'package:farmacia_app/features/auth/utils/auth_role_rules.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  supabase.SupabaseClient get _client => supabase.Supabase.instance.client;

  Future<User> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final authUser = response.user;
    if (authUser == null) {
      throw Exception('Nao foi possivel identificar o usuario autenticado.');
    }

    final expectedRole = inferRoleFromEmail(authUser.email ?? email);
    return _syncAndFetchProfile(
      authUser,
      expectedRole: expectedRole,
      fallbackEmail: authUser.email ?? email,
    );
  }

  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final expectedRole = inferRoleFromEmail(email);

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': expectedRole.name},
    );

    final authUser = response.user;
    if (authUser == null) {
      throw Exception('Nao foi possivel concluir o cadastro.');
    }

    if (response.session == null) {
      throw Exception(
        'Cadastro criado, mas o Supabase ainda exige confirmacao por e-mail. Desative "Confirm email" no painel ou confirme o e-mail antes de entrar.',
      );
    }

    return _syncAndFetchProfile(
      authUser,
      fallbackName: fullName,
      fallbackEmail: email,
      expectedRole: expectedRole,
    );
  }

  Future<User?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final expectedRole = inferRoleFromEmail(authUser.email ?? '');
    return _syncAndFetchProfile(
      authUser,
      expectedRole: expectedRole,
      fallbackEmail: authUser.email ?? '',
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<User> _syncAndFetchProfile(
    supabase.User authUser, {
    String? fallbackName,
    String? fallbackEmail,
    required UserRole expectedRole,
  }) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      final profile = await _client
          .from('profiles')
          .select('id, full_name, email, role')
          .eq('id', authUser.id)
          .maybeSingle();

      if (profile != null) {
        final shouldUpdate =
            profile['role']?.toString() != expectedRole.name ||
            (fallbackName != null &&
                (profile['full_name'] ?? '').toString().trim().isEmpty) ||
            (fallbackEmail != null &&
                (profile['email'] ?? '').toString().trim().isEmpty);

        if (shouldUpdate) {
          await _upsertProfile(
            authUser: authUser,
            fallbackName: fallbackName,
            fallbackEmail: fallbackEmail,
            expectedRole: expectedRole,
          );

          final updatedProfile = await _client
              .from('profiles')
              .select('id, full_name, email, role')
              .eq('id', authUser.id)
              .single();

          return User.fromProfileMap(updatedProfile);
        }

        return User.fromProfileMap(profile);
      }

      if (attempt < 3) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
    }

    await _upsertProfile(
      authUser: authUser,
      fallbackName: fallbackName,
      fallbackEmail: fallbackEmail,
      expectedRole: expectedRole,
    );

    final createdProfile = await _client
        .from('profiles')
        .select('id, full_name, email, role')
        .eq('id', authUser.id)
        .single();

    return User.fromProfileMap(createdProfile);
  }

  Future<void> _upsertProfile({
    required supabase.User authUser,
    String? fallbackName,
    String? fallbackEmail,
    required UserRole expectedRole,
  }) async {
    final payload = {
      'id': authUser.id,
      'full_name':
          fallbackName ?? authUser.userMetadata?['full_name']?.toString() ?? '',
      'email': fallbackEmail ?? authUser.email ?? '',
      'role': expectedRole.name,
    };

    await _client.from('profiles').upsert(payload);
  }
}
