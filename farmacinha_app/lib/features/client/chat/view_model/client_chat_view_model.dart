import 'dart:io';

import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/chat/data/mocks/mock_client_chat_conversation.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_attachment_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_bot_step_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_conversation_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_message_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_option_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/ocr_prescription_review_result_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientChatViewModel extends ChangeNotifier {
  final AuthSessionViewModel _authSession;
  final TextEditingController messageController = TextEditingController();
  final Map<String, ClientChatBotStep> _steps = {};

  ClientChatConversation _conversation =
      MockClientChatConversation.getConversation();
  String? _activeOptionsMessageId;
  String? _manualInputContext;
  bool _isHumanAttendanceActive = false;

  ClientChatViewModel({AuthSessionViewModel? authSession})
    : _authSession = authSession ?? AuthSessionViewModel.instance {
    _steps.addAll(_buildSteps());
    _openBotStep('main_menu');
  }

  ClientChatConversation get conversation => _conversation;
  String? get activeOptionsMessageId => _activeOptionsMessageId;
  bool get canSendFreeText => _isHumanAttendanceActive || _manualInputContext != null;
  bool get canAttachFiles => true;
  String get clientName => _authSession.currentUser?.name ?? 'Cliente';

  bool isOptionsEnabledFor(String messageId) {
    return _activeOptionsMessageId == messageId;
  }

  bool isPrescriptionOcrOption(ClientChatOption option) {
    return option.nextStepId == 'prescription_ocr';
  }

  void selectOption(ClientChatOption option) {
    _appendMessage(
      ClientChatMessage(
        id: 'user-choice-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        time: _formatCurrentTime(),
        text: option.label,
        showReadReceipt: true,
      ),
    );

    final nextStep = option.nextStepId;

    if (nextStep == 'main_menu') {
      _manualInputContext = null;
      _isHumanAttendanceActive = false;
      _openBotStep('main_menu');
      return;
    }

    _openBotStep(nextStep);
  }

  void sendMessage() {
    final draft = messageController.text.trim();

    if (draft.isEmpty || !canSendFreeText) return;

    _appendMessage(
      ClientChatMessage(
        id: 'user-message-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        time: _formatCurrentTime(),
        text: draft,
        showReadReceipt: true,
      ),
    );

    messageController.clear();

    if (_manualInputContext == 'leave_message') {
      _manualInputContext = null;
      _openBotStep('leave_message_confirmation');
      return;
    }

    if (_manualInputContext == 'request_callback') {
      _manualInputContext = null;
      _openBotStep('request_callback_confirmation');
      return;
    }
  }

  Future<String?> attachFile(ClientAttachmentType type) async {
    if (type == ClientAttachmentType.photo) {
      final permissionGranted = await _requestMediaPermission();
      if (!permissionGranted) {
        return 'Nao foi possivel acessar as midias do dispositivo.';
      }
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: type == ClientAttachmentType.photo
          ? FileType.image
          : FileType.custom,
      allowedExtensions: type == ClientAttachmentType.document
          ? ['pdf', 'doc', 'docx', 'txt', 'rtf']
          : null,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final extension = (file.extension ?? '').toLowerCase();

    if (type == ClientAttachmentType.photo && !_isImageExtension(extension)) {
      return 'Selecione apenas arquivos de imagem para este tipo de envio.';
    }

    if (type == ClientAttachmentType.document &&
        !_isDocumentExtension(extension)) {
      return 'Selecione apenas documentos PDF, DOC, DOCX, TXT ou RTF.';
    }

    final attachment = ClientChatAttachment(
      id: 'attachment-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      fileName: file.name,
      fileDetails: '${_formatFileSize(file.size)} • ${_attachmentLabel(type)}',
      filePath: file.path,
      fileExtension: extension,
      sizeInBytes: file.size,
    );

    _appendMessage(
      ClientChatMessage(
        id: 'attachment-message-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        time: _formatCurrentTime(),
        attachment: attachment,
        showReadReceipt: true,
      ),
    );

    if (!_isHumanAttendanceActive && _manualInputContext == null) {
      _appendMessage(
        ClientChatMessage(
          id: 'bot-attachment-${DateTime.now().microsecondsSinceEpoch}',
          sender: ClientChatSender.bot,
          time: _formatCurrentTime(),
          text:
              'Recebi seu anexo. Se quiser continuar com o atendimento automatico, escolha uma das opcoes abaixo.',
        ),
      );
    }

    notifyListeners();
    return null;
  }

  Map<String, ClientChatBotStep> _buildSteps() {
    return {
      'main_menu': const ClientChatBotStep(
        id: 'main_menu',
        message:
            'Bem-vindo(a) a Drogaria Americana.\n\nComo posso te ajudar hoje?\nEscolha uma opcao no proprio chat para continuar.',
        options: [
          ClientChatOption(
            id: 'products',
            label: 'Produtos & Estoque',
            nextStepId: 'products_menu',
          ),
          ClientChatOption(
            id: 'services',
            label: 'Servicos',
            nextStepId: 'services_menu',
          ),
          ClientChatOption(
            id: 'orders',
            label: 'Pedidos & Entregas',
            nextStepId: 'orders_menu',
          ),
          ClientChatOption(
            id: 'general',
            label: 'Duvidas gerais',
            nextStepId: 'general_menu',
          ),
          ClientChatOption(
            id: 'human',
            label: 'Falar com um humano',
            nextStepId: 'human_menu',
          ),
        ],
      ),
      'products_menu': _menuStep(
        id: 'products_menu',
        message: 'Produtos & Estoque\n\nEscolha o que voce precisa agora.',
        options: const [
          ClientChatOption(
            id: 'stock_check',
            label: 'Verificar se tem na loja',
            nextStepId: 'stock_check',
          ),
          ClientChatOption(
            id: 'price_check',
            label: 'Saber preco de um produto',
            nextStepId: 'price_check',
          ),
          ClientChatOption(
            id: 'similar_products',
            label: 'Ver opcoes similares',
            nextStepId: 'similar_products',
          ),
        ],
      ),
      'services_menu': _menuStep(
        id: 'services_menu',
        message: 'Servicos\n\nSelecione o servico desejado.',
        options: const [
          ClientChatOption(
            id: 'piercing',
            label: 'Perfuracao e brincos',
            nextStepId: 'piercing',
          ),
          ClientChatOption(
            id: 'injectable',
            label: 'Aplicacao de medicamento injetavel',
            nextStepId: 'injectable',
          ),
          ClientChatOption(
            id: 'pressure',
            label: 'Afericao de pressao ou glicemia',
            nextStepId: 'pressure',
          ),
          ClientChatOption(
            id: 'other_service',
            label: 'Outro servico',
            nextStepId: 'other_service',
          ),
        ],
      ),
      'orders_menu': _menuStep(
        id: 'orders_menu',
        message: 'Pedidos & Entregas\n\nEscolha a opcao relacionada ao seu pedido.',
        options: const [
          ClientChatOption(
            id: 'track_order',
            label: 'Acompanhar meu pedido',
            nextStepId: 'track_order',
          ),
          ClientChatOption(
            id: 'delivery_problem',
            label: 'Problema com a entrega',
            nextStepId: 'delivery_problem',
          ),
          ClientChatOption(
            id: 'exchange_return',
            label: 'Trocar ou devolver produto',
            nextStepId: 'exchange_return',
          ),
          ClientChatOption(
            id: 'wrong_item',
            label: 'Produto veio com defeito ou diferente',
            nextStepId: 'wrong_item',
          ),
        ],
      ),
      'general_menu': _menuStep(
        id: 'general_menu',
        message: 'Duvidas gerais\n\nSelecione o assunto desejado.',
        options: const [
          ClientChatOption(
            id: 'working_hours',
            label: 'Horario de funcionamento',
            nextStepId: 'working_hours',
          ),
          ClientChatOption(
            id: 'store_address',
            label: 'Endereco das lojas',
            nextStepId: 'store_address',
          ),
          ClientChatOption(
            id: 'discounts',
            label: 'Descontos e clube de beneficios',
            nextStepId: 'discounts',
          ),
          ClientChatOption(
            id: 'prescription',
            label: 'Receita medica',
            nextStepId: 'prescription',
          ),
          ClientChatOption(
            id: 'other_subject',
            label: 'Outro assunto',
            nextStepId: 'other_subject',
          ),
        ],
      ),
      'human_menu': _menuStep(
        id: 'human_menu',
        message: 'Falar com um humano\n\nEscolha como deseja continuar.',
        options: const [
          ClientChatOption(
            id: 'human_now',
            label: 'Quero falar agora',
            nextStepId: 'human_now',
          ),
          ClientChatOption(
            id: 'leave_message',
            label: 'Deixar recado',
            nextStepId: 'leave_message',
          ),
          ClientChatOption(
            id: 'request_callback',
            label: 'Solicitar retorno',
            nextStepId: 'request_callback',
          ),
        ],
      ),
      'stock_check': _leafStep(
        id: 'stock_check',
        message:
            'Posso te ajudar a confirmar disponibilidade em loja. Se quiser agilizar, anexe uma foto da embalagem ou da receita e depois selecione atendimento humano para a conferenca final.',
        parentStepId: 'products_menu',
      ),
      'price_check': _leafStep(
        id: 'price_check',
        message:
            'Para consultar preco com mais precisao, siga para o atendimento humano e informe o nome do produto, a dosagem e a quantidade desejada.',
        parentStepId: 'products_menu',
      ),
      'similar_products': _leafStep(
        id: 'similar_products',
        message:
            'Podemos sugerir opcoes similares, genericos ou outras apresentacoes. Escolha atendimento humano para receber indicacoes mais especificas.',
        parentStepId: 'products_menu',
      ),
      'piercing': _leafStep(
        id: 'piercing',
        message:
            'Realizamos perfuracao de lobulo e colocacao de brincos em horarios especificos. Leve documento e, para menores, o responsavel legal.',
        parentStepId: 'services_menu',
      ),
      'injectable': _leafStep(
        id: 'injectable',
        message:
            'Aplicacao de medicamento injetavel depende de prescricao valida e triagem no local. Voce pode anexar a receita para adiantar a avaliacao.',
        parentStepId: 'services_menu',
      ),
      'pressure': _leafStep(
        id: 'pressure',
        message:
            'Afericao de pressao e glicemia geralmente e feita por ordem de chegada. Para confirmar disponibilidade da unidade, escolha atendimento humano.',
        parentStepId: 'services_menu',
      ),
      'other_service': _leafStep(
        id: 'other_service',
        message:
            'Temos uma equipe pronta para orientar sobre servicos especificos da loja. Se preferir, siga para atendimento humano agora.',
        parentStepId: 'services_menu',
      ),
      'track_order': _leafStep(
        id: 'track_order',
        message:
            'Seu pedido #8829 esta em separacao final no momento. Se precisar de ajuda adicional com o rastreio, posso te encaminhar para uma pessoa do atendimento.',
        parentStepId: 'orders_menu',
      ),
      'delivery_problem': _leafStep(
        id: 'delivery_problem',
        message:
            'Sinto muito pelo transtorno. Para resolver mais rapido, escolha atendimento humano com urgencia e, se quiser, anexe comprovantes ou fotos.',
        parentStepId: 'orders_menu',
      ),
      'exchange_return': _leafStep(
        id: 'exchange_return',
        message:
            'Trocas e devolucoes dependem do tipo de produto e da integridade da embalagem. Posso te direcionar ao atendimento humano para validar seu caso.',
        parentStepId: 'orders_menu',
      ),
      'wrong_item': _leafStep(
        id: 'wrong_item',
        message:
            'Se o item veio diferente ou com defeito, anexe uma foto do produto e da nota ou comprovante. Em seguida, escolha atendimento humano para a tratativa.',
        parentStepId: 'orders_menu',
      ),
      'working_hours': _leafStep(
        id: 'working_hours',
        message:
            'Atendemos de segunda a sabado das 8h as 22h, e aos domingos das 8h as 18h. O atendimento humano no chat segue a mesma janela.',
        parentStepId: 'general_menu',
      ),
      'store_address': _leafStep(
        id: 'store_address',
        message:
            'Temos unidade no Centro e atendimento para entregas em bairros proximos. Escolha atendimento humano se quiser confirmar a loja mais perto de voce.',
        parentStepId: 'general_menu',
      ),
      'discounts': _leafStep(
        id: 'discounts',
        message:
            'Oferecemos promocoes sazonais e beneficios em produtos selecionados. Para consultar regras detalhadas e convenios, o atendimento humano pode te ajudar.',
        parentStepId: 'general_menu',
      ),
      'prescription': _leafStep(
        id: 'prescription',
        message:
            'Para medicamentos que exigem receita, voce pode anexar imagem ou documento aqui mesmo. Depois, se quiser, siga para um humano para validacao final.',
        parentStepId: 'general_menu',
        includePrescriptionOcrShortcut: true,
      ),
      'other_subject': _leafStep(
        id: 'other_subject',
        message:
            'Sem problema. Posso te encaminhar para uma pessoa do atendimento ou voce pode voltar ao menu para escolher outra categoria.',
        parentStepId: 'general_menu',
      ),
      'human_now': ClientChatBotStep(
        id: 'human_now',
        message: _isWithinServiceHours()
            ? 'Tudo certo. Estou transferindo sua conversa para um atendente humano agora.'
            : 'No momento estamos fora do horario de atendimento humano. Voce pode deixar um recado ou solicitar retorno.',
        options: _isWithinServiceHours()
            ? const []
            : const [
                ClientChatOption(
                  id: 'leave_message_from_closed',
                  label: 'Deixar recado',
                  nextStepId: 'leave_message',
                ),
                ClientChatOption(
                  id: 'callback_from_closed',
                  label: 'Solicitar retorno',
                  nextStepId: 'request_callback',
                ),
                ClientChatOption(
                  id: 'back_to_human_menu',
                  label: 'Voltar para falar com humano',
                  nextStepId: 'human_menu',
                ),
                ClientChatOption(
                  id: 'back_to_main_closed',
                  label: 'Voltar ao menu principal',
                  nextStepId: 'main_menu',
                ),
              ],
        startsHumanAttendance: _isWithinServiceHours(),
        enablesManualInput: _isWithinServiceHours(),
      ),
      'leave_message': const ClientChatBotStep(
        id: 'leave_message',
        message:
            'Perfeito. Escreva seu recado ou anexe um documento/imagem, e eu registrarei para a equipe humana continuar depois.',
        options: [],
        enablesManualInput: true,
      ),
      'leave_message_confirmation': const ClientChatBotStep(
        id: 'leave_message_confirmation',
        message:
            'Seu recado foi registrado com sucesso. Nossa equipe humana dara continuidade assim que possivel.',
        options: [
          ClientChatOption(
            id: 'new_human_attempt',
            label: 'Tentar falar com humano agora',
            nextStepId: 'human_now',
          ),
          ClientChatOption(
            id: 'back_main_from_leave_message',
            label: 'Voltar ao menu principal',
            nextStepId: 'main_menu',
          ),
          ClientChatOption(
            id: 'urgent_from_leave_message',
            label: 'Falar com humano com urgencia',
            nextStepId: 'urgent_human',
          ),
        ],
      ),
      'request_callback': const ClientChatBotStep(
        id: 'request_callback',
        message:
            'Escreva um telefone ou a melhor forma de contato e diga em que horario prefere receber retorno.',
        options: [],
        enablesManualInput: true,
      ),
      'request_callback_confirmation': const ClientChatBotStep(
        id: 'request_callback_confirmation',
        message:
            'Solicitacao de retorno registrada. Assim que um atendente estiver disponivel, a equipe fara contato.',
        options: [
          ClientChatOption(
            id: 'human_again',
            label: 'Tentar falar com humano agora',
            nextStepId: 'human_now',
          ),
          ClientChatOption(
            id: 'back_main_from_callback',
            label: 'Voltar ao menu principal',
            nextStepId: 'main_menu',
          ),
          ClientChatOption(
            id: 'urgent_from_callback',
            label: 'Falar com humano com urgencia',
            nextStepId: 'urgent_human',
          ),
        ],
      ),
      'urgent_human': const ClientChatBotStep(
        id: 'urgent_human',
        message:
            'Sinalizei sua conversa como urgente e vou priorizar o atendimento humano agora.',
        options: [],
        startsHumanAttendance: true,
        enablesManualInput: true,
      ),
    };
  }

  ClientChatBotStep _menuStep({
    required String id,
    required String message,
    required List<ClientChatOption> options,
  }) {
    return ClientChatBotStep(
      id: id,
      message: message,
      options: [
        ...options,
        const ClientChatOption(
          id: 'back_to_main',
          label: 'Voltar ao menu principal',
          nextStepId: 'main_menu',
        ),
        const ClientChatOption(
          id: 'urgent_human',
          label: 'Falar com humano com urgencia',
          nextStepId: 'urgent_human',
        ),
      ],
    );
  }

  ClientChatBotStep _leafStep({
    required String id,
    required String message,
    required String parentStepId,
    bool includePrescriptionOcrShortcut = false,
  }) {
    return ClientChatBotStep(
      id: id,
      message: message,
      options: [
        if (includePrescriptionOcrShortcut)
          const ClientChatOption(
            id: 'ocr-prescription',
            label: 'Ler receita com IA',
            nextStepId: 'prescription_ocr',
          ),
        ClientChatOption(
          id: 'back-parent-$id',
          label: 'Voltar para a categoria anterior',
          nextStepId: parentStepId,
        ),
        const ClientChatOption(
          id: 'go-human-now',
          label: 'Falar com um humano agora',
          nextStepId: 'human_now',
        ),
        const ClientChatOption(
          id: 'go-main-now',
          label: 'Voltar ao menu principal',
          nextStepId: 'main_menu',
        ),
        const ClientChatOption(
          id: 'go-urgent-human',
          label: 'Falar com humano com urgencia',
          nextStepId: 'urgent_human',
        ),
      ],
    );
  }

  void _openBotStep(String stepId) {
    final step = _steps[stepId];
    if (step == null) return;

    if (!step.enablesManualInput) {
      _manualInputContext = null;
    } else {
      _manualInputContext = stepId;
    }

    _appendMessage(
      ClientChatMessage(
        id: 'bot-step-$stepId-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.bot,
        time: _formatCurrentTime(),
        text: '${step.message}\n\nA qualquer momento, use as opcoes abaixo para voltar ao menu principal ou pedir atendimento humano urgente.',
        options: step.options,
      ),
    );

    _activeOptionsMessageId = step.options.isEmpty
        ? null
        : _conversation.messages.last.id;

    if (step.startsHumanAttendance) {
      _isHumanAttendanceActive = true;
      _manualInputContext = null;
      _appendHumanIntroduction(isUrgent: stepId == 'urgent_human');
      _activeOptionsMessageId = null;
    } else if (!step.enablesManualInput) {
      _isHumanAttendanceActive = false;
    }

    notifyListeners();
  }

  void _appendHumanIntroduction({required bool isUrgent}) {
    _appendMessage(
      ClientChatMessage(
        id: 'attendant-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.attendant,
        time: _formatCurrentTime(),
        text: isUrgent
            ? 'Ola, aqui e a Juliana, do atendimento humano da Drogaria Americana. Recebi sua prioridade e vou seguir com voce por aqui agora.'
            : 'Ola, aqui e a Juliana, do atendimento humano da Drogaria Americana. Acabei de assumir sua conversa e vou te ajudar a partir daqui.',
      ),
    );
  }

  void _appendMessage(ClientChatMessage message) {
    _conversation = _conversation.copyWith(
      isSupportTyping: false,
      messages: [..._conversation.messages, message],
    );
  }

  void startPrescriptionOcrFlow() {
    _appendMessage(
      ClientChatMessage(
        id: 'ocr-request-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        time: _formatCurrentTime(),
        text: 'Quero analisar uma receita com OCR.',
        showReadReceipt: true,
      ),
    );

    _appendMessage(
      ClientChatMessage(
        id: 'ocr-guidance-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.bot,
        time: _formatCurrentTime(),
        text:
            'Perfeito. Abra a leitura OCR, revise os dados reconhecidos e so depois envie o formulario para o chat. O envio nao substitui a validacao do farmaceutico.',
      ),
    );

    _activeOptionsMessageId = null;
    notifyListeners();
  }

  void registerPrescriptionOcrReview(OcrPrescriptionReviewResult review) {
    final attachment = ClientChatAttachment(
      id: 'ocr-attachment-${DateTime.now().microsecondsSinceEpoch}',
      type: ClientAttachmentType.photo,
      fileName: review.fileName,
      fileDetails: 'Receita revisada via OCR',
      filePath: review.imagePath,
      fileExtension: 'jpg',
    );

    _appendMessage(
      ClientChatMessage(
        id: 'ocr-attachment-message-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        time: _formatCurrentTime(),
        attachment: attachment,
        showReadReceipt: true,
      ),
    );

    final medicationsText = review.medications.isEmpty
        ? 'Nenhum medicamento confirmado no formulario.'
        : review.medications.map((item) => '- $item').join('\n');

    final crmText = review.crm.isEmpty ? 'Nao informado' : review.crm;
    final prescriptionColorText = review.prescriptionColor.isEmpty
        ? 'Nao informada'
        : review.prescriptionColor;
    final issueDateText = review.issueDateText.isEmpty
        ? 'Nao informada'
        : review.issueDateText;

    _appendMessage(
      ClientChatMessage(
        id: 'ocr-summary-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        time: _formatCurrentTime(),
        text:
            'Enviei a receita revisada.\n\nTipo: ${review.wasHandwritten ? 'Escrita a caneta' : 'Digitalizada'}\nCRM: $crmText\nCor: $prescriptionColorText\nData: $issueDateText\nMedicamentos:\n$medicationsText',
        showReadReceipt: true,
      ),
    );

    _appendMessage(
      ClientChatMessage(
        id: 'ocr-response-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.bot,
        time: _formatCurrentTime(),
        text:
            'Receita recebida. Os dados revisados foram anexados ao atendimento como apoio de digitacao. A validacao tecnica final continuara com o farmaceutico responsavel.',
      ),
    );

    if (review.hasLowConfidenceWarning) {
      _appendMessage(
        ClientChatMessage(
          id: 'ocr-low-confidence-${DateTime.now().microsecondsSinceEpoch}',
          sender: ClientChatSender.bot,
          time: _formatCurrentTime(),
          text:
              'Aviso: a receita foi marcada como escrita a caneta e parte da leitura pode ter ficado incompleta. Os campos enviados devem ser conferidos manualmente antes da validacao final.',
        ),
      );
    }

    if (review.hasControlledMedicationWarning) {
      _appendMessage(
        ClientChatMessage(
          id: 'ocr-warning-${DateTime.now().microsecondsSinceEpoch}',
          sender: ClientChatSender.bot,
          time: _formatCurrentTime(),
          text:
              'Alerta regulatorio: Para este medicamento, a apresentacao da via fisica original ou assinatura digital ICP-Brasil e obrigatoria.',
        ),
      );
    }

    notifyListeners();
  }

  Future<bool> _requestMediaPermission() async {
    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.photos;
    }

    var status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  bool _isImageExtension(String extension) {
    const allowed = {'jpg', 'jpeg', 'png', 'webp', 'heic'};
    return allowed.contains(extension);
  }

  bool _isDocumentExtension(String extension) {
    const allowed = {'pdf', 'doc', 'docx', 'txt', 'rtf'};
    return allowed.contains(extension);
  }

  String _attachmentLabel(ClientAttachmentType type) {
    if (type == ClientAttachmentType.photo) {
      return 'Imagem';
    }

    return 'Documento';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(1)} KB';
    }

    final megabytes = kilobytes / 1024;
    return '${megabytes.toStringAsFixed(1)} MB';
  }

  static bool _isWithinServiceHours() {
    final now = DateTime.now();
    const openingHour = 8;
    final closingHour = now.weekday == DateTime.sunday ? 18 : 22;
    return now.hour >= openingHour && now.hour < closingHour;
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
