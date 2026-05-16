import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_stock_product_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/attendant_products_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/product_ai_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_product_registration_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Eu criei esse repositório em memória para conseguir testar só a lógica
// do ViewModel, sem depender de banco real ou carregamento externo.
class _InMemoryAttendantProductsRepository extends AttendantProductsRepository {
  _InMemoryAttendantProductsRepository();

  @override
  Future<List<AttendantStockProduct>> fetchProducts() async {
    return const <AttendantStockProduct>[];
  }
}

class _SuccessProductAiRepository extends ProductAiRepository {
  _SuccessProductAiRepository() : super();

  @override
  Future<String> generateDescription(String productName) async {
    // Aqui eu simulo uma resposta correta da IA.
    return 'Descrição de teste para $productName.';
  }
}

class _EmptyProductAiRepository extends ProductAiRepository {
  _EmptyProductAiRepository() : super();

  @override
  Future<String> generateDescription(String productName) async {
    // Nesse caso eu simulo a IA respondendo algo vazio.
    return '   ';
  }
}

class _ThrowingProductAiRepository extends ProductAiRepository {
  _ThrowingProductAiRepository() : super();

  @override
  Future<String> generateDescription(String productName) async {
    // Aqui eu forço uma exceção para testar o tratamento de erro.
    throw Exception('Falha controlada na IA');
  }
}

void main() {
  late AttendantProductRegistrationViewModel viewModel;

  Future<void> pumpViewModel(ProductAiRepository repository) async {
    // Esse método monta o ViewModel com dependências controladas,
    // deixando cada teste mais previsível.
    viewModel = AttendantProductRegistrationViewModel(
      repository: _InMemoryAttendantProductsRepository(),
      productAiRepository: repository,
    );
  }

  tearDown(() {
    // No final de cada teste eu libero o ViewModel para não acumular estado.
    viewModel.dispose();
  });

  group('AttendantProductRegistrationViewModel - Testes de unidade', () {
    test('TC01 - Impede salvar produto sem categoria selecionada', () async {
      await pumpViewModel(_SuccessProductAiRepository());
      viewModel.nameController.text = 'Produto sem categoria';
      viewModel.descriptionController.text = 'Descrição válida';
      viewModel.priceController.text = '19,90';
      viewModel.stockController.text = '5';

      // Aqui eu tento salvar sem categoria para verificar se a validação bloqueia.
      final result = await viewModel.saveProduct();

      expect(result.success, isFalse);
      expect(result.message, 'Selecione uma categoria.');
    });

    test('TC02 - Valida preço obrigatório e maior que zero', () async {
      await pumpViewModel(_SuccessProductAiRepository());

      // Neste teste eu confiro entradas inválidas e uma válida para o campo preço.
      expect(viewModel.validatePrice(''), 'Informe o preço.');
      expect(viewModel.validatePrice('0'), 'Informe um preço válido.');
      expect(viewModel.validatePrice('-5'), 'Informe um preço válido.');
      expect(viewModel.validatePrice('12,50'), isNull);
    });

    test('TC03 - Valida estoque obrigatório e não negativo', () async {
      await pumpViewModel(_SuccessProductAiRepository());

      // Aqui eu faço a mesma ideia do preço, mas agora para o estoque.
      expect(viewModel.validateStock(''), 'Informe o estoque.');
      expect(viewModel.validateStock('-1'), 'Informe um estoque válido.');
      expect(viewModel.validateStock('abc'), 'Informe um estoque válido.');
      expect(viewModel.validateStock('8'), isNull);
    });

    test('TC04 - Converte preço monetário para double corretamente', () async {
      await pumpViewModel(_SuccessProductAiRepository());

      // Esse teste garante que o texto digitado em formato monetário
      // seja convertido para número corretamente.
      expect(viewModel.parsePrice('R\$ 1.234,56'), 1234.56);
      expect(viewModel.parsePrice('89,90'), 89.90);
      expect(viewModel.parsePrice('texto inválido'), 0);
    });

    test('TC05 - Impede gerar descrição sem nome do produto', () async {
      await pumpViewModel(_SuccessProductAiRepository());

      // Se o nome estiver vazio, o sistema deve impedir a geração da descrição.
      final result = await viewModel.generateProductDescription();

      expect(result.success, isFalse);
      expect(
        result.message,
        'Informe o nome do produto antes de gerar a descrição.',
      );
    });

    test('TC06 - Gera descrição com sucesso quando a IA retorna texto', () async {
      await pumpViewModel(_SuccessProductAiRepository());
      viewModel.nameController.text = 'Dipirona 500mg';

      // Aqui eu testo o fluxo feliz da geração automática de descrição.
      final result = await viewModel.generateProductDescription();

      expect(result.success, isTrue);
      expect(result.message, 'Descrição gerada com sucesso.');
      expect(
        viewModel.descriptionController.text,
        'Descrição de teste para Dipirona 500mg.',
      );
    });

    test('TC07 - Rejeita descrição vazia retornada pela IA', () async {
      await pumpViewModel(_EmptyProductAiRepository());
      viewModel.nameController.text = 'Vitamina C';

      // Nesse cenário eu vejo se o ViewModel percebe que a IA respondeu algo inválido.
      final result = await viewModel.generateProductDescription();

      expect(result.success, isFalse);
      expect(result.message, 'A IA não retornou uma descrição válida.');
    });

    test('TC08 - Informa falha quando a IA lança exceção', () async {
      await pumpViewModel(_ThrowingProductAiRepository());
      viewModel.nameController.text = 'Omeprazol';

      // Aqui eu valido se a exceção da IA é tratada sem travar o estado de carregamento.
      final result = await viewModel.generateProductDescription();

      expect(result.success, isFalse);
      expect(
        result.message,
        'Não foi possível gerar a descrição. Tente novamente.',
      );
      expect(viewModel.isGeneratingDescription, isFalse);
    });
  });
}
