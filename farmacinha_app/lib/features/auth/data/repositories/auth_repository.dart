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

  Future<User> updateCurrentUserProfile({
    required String fullName,
    required String email,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para alterar seus dados.');
    }

    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedName.isEmpty) {
      throw Exception('Informe seu nome completo.');
    }
    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Informe um e-mail valido.');
    }

    final currentProfile = await _client
        .from('profiles')
        .select('role')
        .eq('id', authUser.id)
        .maybeSingle();
    final currentRole = UserRoleX.fromValue(
      currentProfile?['role']?.toString(),
    );
    final newEmailRole = inferRoleFromEmail(normalizedEmail);
    if (currentRole == UserRole.cliente && newEmailRole != UserRole.cliente) {
      throw Exception(
        'E-mails institucionais devem ser criados pelo cadastro correto, nao pela tela de dados pessoais.',
      );
    }
    if (currentRole == UserRole.gerente && newEmailRole != UserRole.gerente) {
      throw Exception(
        'O e-mail do gerente precisa terminar com @americanaadm.com.',
      );
    }

    try {
      final updatedProfile = await _client
          .rpc(
            'update_my_profile_instant',
            params: {'p_full_name': normalizedName, 'p_email': normalizedEmail},
          )
          .single();

      try {
        await _client.auth.refreshSession();
      } catch (_) {
        // O perfil já foi salvo, então o login novo pega o e-mail certo.
      }

      return User.fromProfileMap(Map<String, dynamic>.from(updatedProfile));
    } on supabase.PostgrestException catch (error) {
      if (!_isMissingInstantProfileUpdateRpc(error)) {
        rethrow;
      }
    }

    final currentEmail = (authUser.email ?? '').trim().toLowerCase();
    supabase.User updatedAuthUser = authUser;
    if (normalizedEmail != currentEmail) {
      final response = await _client.auth.updateUser(
        supabase.UserAttributes(
          email: normalizedEmail,
          data: {'full_name': normalizedName},
        ),
      );
      updatedAuthUser = response.user ?? _client.auth.currentUser ?? authUser;
    } else {
      final response = await _client.auth.updateUser(
        supabase.UserAttributes(data: {'full_name': normalizedName}),
      );
      updatedAuthUser = response.user ?? _client.auth.currentUser ?? authUser;
    }

    final effectiveEmail = (updatedAuthUser.email ?? currentEmail)
        .trim()
        .toLowerCase();
    await _client
        .from('profiles')
        .update({'full_name': normalizedName, 'email': effectiveEmail})
        .eq('id', authUser.id);

    final updatedProfile = await _client
        .from('profiles')
        .select('id, full_name, email, role')
        .eq('id', authUser.id)
        .single();

    return User.fromProfileMap(updatedProfile);
  }

  Future<void> updateCurrentUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authUser = _client.auth.currentUser;
    final email = authUser?.email?.trim();
    if (authUser == null || email == null || email.isEmpty) {
      throw Exception('Entre com sua conta para alterar sua senha.');
    }

    await _client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await _client.auth.updateUser(
      supabase.UserAttributes(password: newPassword),
    );
    await _client.auth.signInWithPassword(email: email, password: newPassword);
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
        final normalizedFallbackEmail = (fallbackEmail ?? '').trim();
        final profileEmail = (profile['email'] ?? '').toString().trim();
        final shouldUpdate =
            profile['role']?.toString() != expectedRole.name ||
            (fallbackName != null &&
                (profile['full_name'] ?? '').toString().trim().isEmpty) ||
            (fallbackEmail != null &&
                normalizedFallbackEmail.isNotEmpty &&
                profileEmail.toLowerCase() !=
                    normalizedFallbackEmail.toLowerCase());

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _isMissingInstantProfileUpdateRpc(supabase.PostgrestException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    return code == 'pgrst202' ||
        (message.contains('update_my_profile_instant') &&
            message.contains('schema cache')) ||
        message.contains('could not find the function');
  }
}
