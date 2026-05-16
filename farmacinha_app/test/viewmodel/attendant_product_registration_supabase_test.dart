import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/attendant_products_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/product_ai_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_product_registration_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgrest/postgrest.dart';

import 'supabase_test_helper.dart';

// Neste arquivo eu testo os cenários que realmente conversam com o Supabase.
// A ideia foi validar se cadastrar, editar e excluir produto funciona usando base real.
class _NoOpProductAiRepository extends ProductAiRepository {
  _NoOpProductAiRepository() : super();
}

void main() {
  late AttendantProductRegistrationViewModel viewModel;
  final createdNames = <String>{};

  Future<void> buildViewModel() async {
    // Aqui eu monto o ViewModel apontando para o repositório autenticado no Supabase.
    viewModel = AttendantProductRegistrationViewModel(
      repository: SupabaseTestHelper.repository,
      productAiRepository: _NoOpProductAiRepository(),
    );

    // Eu espero o carregamento inicial terminar para não misturar esse processo com os asserts.
    await SupabaseTestHelper.waitForProductsLoad(viewModel);
  }

  Future<void> fillRequiredFields({
    required String name,
    required String description,
    required String price,
    required String stock,
    String category = 'Medicamentos',
  }) async {
    // Esse método foi criado só para evitar repetição no preenchimento dos campos.
    viewModel.nameController.text = name;
    viewModel.descriptionController.text = description;
    viewModel.priceController.text = price;
    viewModel.stockController.text = stock;
    viewModel.selectCategory(category);
  }

  setUpAll(SupabaseTestHelper.ensureInitialized);

  setUp(() async {
    // Em cada teste eu recrio o ViewModel para deixar o cenário isolado.
    await buildViewModel();
  });

  tearDown(() async {
    // Depois de cada caso eu libero o ViewModel e tento limpar os produtos criados.
    viewModel.dispose();
    await SupabaseTestHelper.cleanupByNames(createdNames);
    createdNames.clear();
  });

  group('Cadastro de produtos com Supabase real - Testes de unidade', () {
    test('TC09 - Salva um novo produto no Supabase com sucesso', () async {
      // Aqui eu gero um nome único para não conflitar com registros já existentes.
      final uniqueName =
          'QA Produto Unitario ${DateTime.now().microsecondsSinceEpoch}';
      createdNames.add(uniqueName);

      await fillRequiredFields(
        name: uniqueName,
        description: 'Produto criado no teste.',
        price: '24,90',
        stock: '7',
      );

      late ProductSaveResult result;
      try {
        // Esse é o ponto principal do teste: salvar um produto real no banco.
        result = await viewModel.saveProduct();
      } on PostgrestException catch (error) {
        fail(
          '${SupabaseTestHelper.describePostgrestError(error)} | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      } catch (error) {
        fail(
          'Falha inesperada no TC09: $error | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      }

      expect(result.success, isTrue);
      expect(result.message, 'Produto cadastrado com sucesso.');
      expect(viewModel.mode, AttendantStockControlMode.list);
      expect(viewModel.nameController.text, isEmpty);

      // Depois do save eu consulto a base para confirmar que o produto foi persistido.
      final savedProduct = await SupabaseTestHelper.findProductByName(uniqueName);
      expect(savedProduct, isNotNull);
      expect(savedProduct!.description, 'Produto criado no teste.');
      expect(savedProduct.category, 'Medicamentos');
      expect(savedProduct.price, 24.90);
      expect(savedProduct.stockQuantity, 7);
    });

    test('TC10 - Atualiza produto existente no Supabase com sucesso', () async {
      // Primeiro eu crio um produto auxiliar para usar no cenário de edição.
      final originalName =
          'QA Produto Edicao ${DateTime.now().microsecondsSinceEpoch}';
      createdNames.add(originalName);

      try {
        await SupabaseTestHelper.repository.saveProduct(
          payload: AttendantProductPayload(
            name: originalName,
            description: 'Descricao original.',
            category: 'Medicamentos',
            price: 10.0,
            stockQuantity: 3,
            registrationDate: DateTime.now(),
            isControlled: false,
          ),
        );
      } on PostgrestException catch (error) {
        fail(
          '${SupabaseTestHelper.describePostgrestError(error)} | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      } catch (error) {
        fail(
          'Falha inesperada ao preparar TC10: $error | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      }

      final existingProduct =
          await SupabaseTestHelper.findProductByName(originalName);
      expect(existingProduct, isNotNull);

      // Aqui eu carrego o produto encontrado no ViewModel para editar como no fluxo real.
      viewModel.editProduct(existingProduct!);
      viewModel.descriptionController.text = 'Descricao atualizada pelo teste.';
      viewModel.priceController.text = '31,50';
      viewModel.stockController.text = '11';
      viewModel.setControlled(true);
      viewModel.selectCategory('Suplementos');

      late ProductSaveResult result;
      try {
        result = await viewModel.saveProduct();
      } on PostgrestException catch (error) {
        fail(
          '${SupabaseTestHelper.describePostgrestError(error)} | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      } catch (error) {
        fail(
          'Falha inesperada no TC10: $error | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      }

      expect(result.success, isTrue);
      expect(result.message, 'Produto atualizado com sucesso.');

      // Depois da edição eu vou ao banco de novo para conferir se os novos valores ficaram salvos.
      final updatedProduct =
          await SupabaseTestHelper.findProductByName(originalName);
      expect(updatedProduct, isNotNull);
      expect(updatedProduct!.description, 'Descricao atualizada pelo teste.');
      expect(updatedProduct.category, 'Suplementos');
      expect(updatedProduct.price, 31.50);
      expect(updatedProduct.stockQuantity, 11);
      expect(updatedProduct.isControlled, isTrue);
    });

    test('TC11 - Remove produto existente com sucesso', () async {
      // Nesse cenário eu crio um produto temporário só para testar a exclusão.
      final productName =
          'QA Produto Exclusao ${DateTime.now().microsecondsSinceEpoch}';

      try {
        await SupabaseTestHelper.repository.saveProduct(
          payload: AttendantProductPayload(
            name: productName,
            description: 'Produto para teste de exclusao.',
            category: 'Higiene',
            price: 8.75,
            stockQuantity: 2,
            registrationDate: DateTime.now(),
            isControlled: false,
          ),
        );
      } on PostgrestException catch (error) {
        fail(
          '${SupabaseTestHelper.describePostgrestError(error)} | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      } catch (error) {
        fail(
          'Falha inesperada ao preparar TC11: $error | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      }

      final existingProduct =
          await SupabaseTestHelper.findProductByName(productName);
      expect(existingProduct, isNotNull);
      final existingProductId = existingProduct!.id;

      // Aqui eu carrego esse produto no ViewModel para excluir do mesmo jeito que a tela faria.
      viewModel.editProduct(existingProduct);

      late ProductSaveResult result;
      try {
        result = await viewModel.deleteCurrentProduct();
      } on PostgrestException catch (error) {
        fail(
          '${SupabaseTestHelper.describePostgrestError(error)} | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      } catch (error) {
        fail(
          'Falha inesperada no TC11: $error | '
          '${SupabaseTestHelper.currentAuthSummary()}',
        );
      }

      expect(result.success, isTrue);
      expect(result.message, 'Produto deletado com sucesso.');

      // Depois da exclusão eu valido pelo id, porque essa verificação é mais precisa.
      await SupabaseTestHelper.waitUntilProductIsDeleted(existingProductId);

      final deletedProduct =
          await SupabaseTestHelper.findProductById(existingProductId);
      expect(deletedProduct, isNull);
    });
  });
}
