import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_stock_product_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/attendant_products_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_product_registration_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';

/* 
 
  Eu criei este arquivo para concentrar toda a configuração dos testes que usam
  o Supabase real. Assim eu evito repetir login, montagem do client, buscas no
  banco e limpeza de dados em vários arquivos diferentes.

*/
class SupabaseTestHelper {
  static const _url = 'https://svutfmjjqkmfcyfgxgqq.supabase.co';
  static const _anonKey = 'sb_publishable_x4Dtp-jkbNuh7euNnFkzjQ_pL9NHceb';
  static const _defaultTestEmail = 'atendente1@americanaat.com';
  static const _defaultTestPassword = '123456';
  static const _envTestEmail = String.fromEnvironment('SUPABASE_TEST_EMAIL');
  static const _envTestPassword = String.fromEnvironment('SUPABASE_TEST_PASSWORD');

  static late final SupabaseClient client;
  static late final AttendantProductsRepository repository;
  static String? authenticatedUserId;
  static String? authenticatedUserEmail;
  static String? authenticatedUserRole;

  static Future<void> ensureInitialized() async {
    // Aqui eu inicializo o binding básico do Flutter para permitir o uso das classes do framework.
    WidgetsFlutterBinding.ensureInitialized();

    // Neste ponto eu crio um client próprio do Supabase para ser reutilizado nos testes.
    client = SupabaseClient(_url, _anonKey);

    // Antes de usar o banco, eu autentico o usuário de teste.
    await _signInStaffUser();

    // Depois do login eu monto o repositório usando esse client autenticado.
    repository = AttendantProductsRepository(client: client);
  }

  static Future<void> _signInStaffUser() async {
    // Se eu passar credenciais por dart-define, elas têm prioridade.
    // Caso contrário, o teste usa o usuário padrão definido aqui.
    final email = _envTestEmail.isNotEmpty ? _envTestEmail : _defaultTestEmail;
    final password =
        _envTestPassword.isNotEmpty ? _envTestPassword : _defaultTestPassword;

    try {
      // Aqui acontece o login real no Supabase.
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      authenticatedUserId = user?.id;
      authenticatedUserEmail = user?.email;
      if (user == null) {
        fail('Login no Supabase não retornou usuário autenticado.');
      }

      // Depois do login eu consulto o perfil desse usuário para validar o role.
      await _loadAuthenticatedRole();
    } on AuthException catch (error) {
      fail(
        'Não foi possível autenticar no Supabase com o usuário de teste. '
        'Mensagem: ${error.message}',
      );
    } catch (error) {
      fail('Falha inesperada ao autenticar no Supabase: $error');
    }
  }

  static Future<void> _loadAuthenticatedRole() async {
    if (authenticatedUserId == null) return;

    try {
      // Aqui eu verifico na tabela profiles se o usuário existe e qual papel ele possui.
      final profile = await client
          .from('profiles')
          .select('id, email, role')
          .eq('id', authenticatedUserId!)
          .maybeSingle();

      if (profile == null) {
        fail(
          'O usuário autenticado não possui registro em public.profiles. '
          'User id: $authenticatedUserId, email: $authenticatedUserEmail',
        );
      }

      authenticatedUserRole = profile['role']?.toString();
      final allowedRoles = {'atendente', 'farmaceutico', 'gerente', 'admin'};

      // Essa checagem garante que o teste não está rodando com um perfil sem permissão administrativa.
      if (!allowedRoles.contains(authenticatedUserRole)) {
        fail(
          'O usuário autenticado não tem perfil administrativo suficiente '
          'para manipular products. Role atual: $authenticatedUserRole',
        );
      }
    } on PostgrestException catch (error) {
      fail(
        'Falha ao consultar public.profiles do usuário autenticado. '
        '${describePostgrestError(error)}',
      );
    } catch (error) {
      fail('Falha inesperada ao validar o perfil autenticado: $error');
    }
  }

  static Future<void> waitForProductsLoad(
    AttendantProductRegistrationViewModel viewModel,
  ) async {
    const timeout = Duration(seconds: 20);
    final startedAt = DateTime.now();

    // O ViewModel carrega produtos assim que é criado, então eu espero esse processo terminar.
    while (viewModel.isLoadingProducts) {
      if (DateTime.now().difference(startedAt) > timeout) {
        fail('Tempo esgotado ao aguardar o carregamento de produtos.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  static Future<AttendantStockProduct?> findProductByName(String name) async {
    // Essa busca por nome ajuda principalmente a localizar produtos criados no próprio teste.
    final products = await repository.fetchProducts();
    for (final product in products) {
      if (product.name == name) return product;
    }
    return null;
  }

  static Future<AttendantStockProduct?> findProductById(String id) async {
    // Aqui eu busco por id porque isso deixa a validação mais precisa em edição e exclusão.
    final products = await repository.fetchProducts();
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  static Future<void> waitUntilProductIsDeleted(String id) async {
    const timeout = Duration(seconds: 8);
    final startedAt = DateTime.now();

    // Depois de excluir, eu espero um pouco porque a leitura nem sempre reflete a mudança imediatamente.
    while (DateTime.now().difference(startedAt) <= timeout) {
      final product = await findProductById(id);
      if (product == null) return;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    fail('O produto com id $id ainda está visível após a exclusão.');
  }

  static Future<void> cleanupByNames(Iterable<String> names) async {
    // Essa limpeza serve para não deixar registros temporários no banco depois dos testes.
    for (final name in names) {
      final product = await findProductByName(name);
      if (product != null) {
        await repository.deleteProduct(product.id);
      }
    }
  }

  static String describePostgrestError(Object error) {
    // Aqui eu organizo o erro do Postgrest de um jeito mais fácil de ler no terminal.
    if (error is PostgrestException) {
      return 'PostgrestException(code: ${error.code}, message: ${error.message}, '
          'details: ${error.details}, hint: ${error.hint})';
    }
    return error.toString();
  }

  static String currentAuthSummary() {
    // Esse resumo ajuda a identificar rapidamente com qual usuário o teste estava autenticado.
    return 'authUserId=$authenticatedUserId, '
        'authEmail=$authenticatedUserEmail, '
        'authRole=$authenticatedUserRole';
  }
}
