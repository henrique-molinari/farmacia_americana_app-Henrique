import 'dart:async';
import 'dart:io';

import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_attachment_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_bot_step_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_conversation_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_message_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_option_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientChatViewModel extends ChangeNotifier {
  ClientChatViewModel({
    AuthSessionViewModel? authSession,
    SupportChatRepository? repository,
  }) : _authSession = authSession ?? AuthSessionViewModel.instance,
       _repository = repository ?? SupportChatRepository.instance {
    _steps.addAll(_buildSteps());
  }

  final AuthSessionViewModel _authSession;
  final SupportChatRepository _repository;
  final TextEditingController messageController = TextEditingController();
  final Map<String, ClientChatBotStep> _steps = {};

  ClientChatConversation _conversation = const ClientChatConversation(
    pharmacyName: 'Farmacia Americana',
    statusLabel: 'ChatBot e equipe de atendimento',
    messages: [],
  );

  RealtimeChannel? _channel;
  String? _activeOptionsMessageId;
  String? _manualInputContext;
  String? _activeConversationId;
  String? _hiddenConversationId;
  bool _isHumanAttendanceActive = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  ClientChatConversation get conversation => _conversation;
  String? get activeOptionsMessageId => _activeOptionsMessageId;
  bool get canSendFreeText =>
      _isHumanAttendanceActive || _manualInputContext != null;
  bool get canAttachFiles => !_conversation.isFinished;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get clientName => _authSession.currentUser?.name ?? 'Cliente';

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    await refreshConversation();
    _subscribeToRealtime();
  }

  Future<void> refreshConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supportConversation = await _repository
          .fetchLatestClientConversation();

      if (supportConversation == null) {
        _activeConversationId = null;
        _isHumanAttendanceActive = false;
        _manualInputContext = null;
        _activeOptionsMessageId = null;
        _conversation = const ClientChatConversation(
          pharmacyName: 'Farmacia Americana',
          statusLabel: 'ChatBot e equipe de atendimento',
          messages: [],
        );
        if (_conversation.messages.isEmpty) {
          _openBotStep('main_menu');
        }
      } else if (supportConversation.status == 'finalizado') {
        if (supportConversation.id != _hiddenConversationId) {
          await _showClosedConversationAsNewStart(supportConversation);
        }
      } else {
        final messages = await _repository.fetchMessages(
          supportConversation.id,
        );
        _activeConversationId = supportConversation.id;
        final isFinished = supportConversation.status == 'finalizado';
        _isHumanAttendanceActive = !isFinished;
        _manualInputContext = null;
        _activeOptionsMessageId = null;
        _conversation = ClientChatConversation(
          conversationId: supportConversation.id,
          pharmacyName: 'Farmacia Americana',
          statusLabel: _statusLabelForConversation(supportConversation),
          attendantName: supportConversation.attendantName,
          isSupportTyping: false,
          isFinished: isFinished,
          messages: messages.map(_mapSupportMessage).toList(growable: false),
        );
      }
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      if (_conversation.messages.isEmpty) {
        _conversation = const ClientChatConversation(
          pharmacyName: 'Farmacia Americana',
          statusLabel: 'ChatBot e equipe de atendimento',
          messages: [],
        );
        _openBotStep('main_menu');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _showClosedConversationAsNewStart(
    SupportConversationRecord supportConversation,
  ) async {
    final messages = await _repository.fetchMessages(supportConversation.id);
    final closingMessage = messages.reversed.firstWhere(
      (message) =>
          (message.senderType == SupportSenderType.system ||
              message.senderType == SupportSenderType.bot) &&
          (message.body ?? '').trim().isNotEmpty,
      orElse: () => messages.isEmpty
          ? SupportMessageRecord(
              id: 'closed-${supportConversation.id}',
              conversationId: supportConversation.id,
              senderId: null,
              senderName: 'Farmacia Americana',
              senderType: SupportSenderType.system,
              messageType: SupportMessageType.text,
              body: supportConversation.lastMessagePreview,
              attachmentName: null,
              attachmentDetails: null,
              createdAt: supportConversation.updatedAt,
            )
          : messages.last,
    );

    _hiddenConversationId = supportConversation.id;
    _activeConversationId = null;
    _isHumanAttendanceActive = false;
    _manualInputContext = null;
    _activeOptionsMessageId = null;
    _conversation = const ClientChatConversation(
      pharmacyName: 'Farmacia Americana',
      statusLabel: 'ChatBot e equipe de atendimento',
      messages: [],
    );

    _appendMessage(_mapSupportMessage(closingMessage));
    _openBotStep('main_menu');
  }

  Future<void> resetChat() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hiddenConversationId =
          await _repository.resetCurrentClientConversation() ??
          _activeConversationId;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      messageController.clear();
      _activeConversationId = null;
      _manualInputContext = null;
      _activeOptionsMessageId = null;
      _isHumanAttendanceActive = false;
      _conversation = const ClientChatConversation(
        pharmacyName: 'Farmacia Americana',
        statusLabel: 'ChatBot e equipe de atendimento',
        messages: [],
      );
      _openBotStep('main_menu');
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isOptionsEnabledFor(String messageId) {
    return _activeOptionsMessageId == messageId;
  }

  void selectOption(ClientChatOption option) {
    unawaited(_handleOptionSelection(option));
  }

  Future<void> _handleOptionSelection(ClientChatOption option) async {
    _appendMessage(
      ClientChatMessage(
        id: 'user-choice-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.client,
        senderName: clientName,
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

    if (nextStep == 'human_now') {
      _openBotStep(nextStep);
      await _registerHumanRequest(
        urgent: false,
        clientMessage: option.label,
        notice: _humanWaitingNotice,
      );
      return;
    }

    if (nextStep == 'urgent_human') {
      _openBotStep(nextStep);
      await _registerHumanRequest(
        urgent: true,
        clientMessage: option.label,
        notice:
            'Aguarde, em alguns minutinhos ja entraremos em contato. Sua conversa foi marcada como urgente.',
      );
      return;
    }

    _openBotStep(nextStep);
  }

  Future<void> sendMessage() async {
    final draft = messageController.text.trim();

    if (draft.isEmpty || !canSendFreeText) {
      return;
    }

    final optimisticMessage = ClientChatMessage(
      id: 'user-message-${DateTime.now().microsecondsSinceEpoch}',
      sender: ClientChatSender.client,
      senderName: clientName,
      time: _formatCurrentTime(),
      text: draft,
      showReadReceipt: true,
    );

    _appendMessage(optimisticMessage);
    messageController.clear();

    try {
      final conversationId = await _ensureConversationForManualInteraction();
      await _repository.sendClientText(
        conversationId: conversationId,
        text: draft,
      );

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
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
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
        senderName: clientName,
        time: _formatCurrentTime(),
        attachment: attachment,
        showReadReceipt: true,
      ),
    );

    try {
      if (_isHumanAttendanceActive || _manualInputContext != null) {
        final conversationId = await _ensureConversationForManualInteraction();
        await _repository.sendClientAttachmentSummary(
          conversationId: conversationId,
          fileName: file.name,
          fileDetails: attachment.fileDetails,
        );
      } else {
        _appendMessage(
          ClientChatMessage(
            id: 'bot-attachment-${DateTime.now().microsecondsSinceEpoch}',
            sender: ClientChatSender.bot,
            time: _formatCurrentTime(),
            text:
                'Recebi seu anexo. Se quiser que a equipe veja isso no painel do atendente, escolha atendimento humano.',
          ),
        );
      }
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
    return null;
  }

  Map<String, ClientChatBotStep> _buildSteps() {
    return {
      'main_menu': const ClientChatBotStep(
        id: 'main_menu',
        message:
            'Bem-vindo(a) a Farmacia Americana.\n\nComo posso te ajudar hoje?\nEscolha uma opcao no proprio chat para continuar.',
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
        message:
            'Pedidos & Entregas\n\nEscolha a opcao relacionada ao seu pedido.',
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
            'Posso te ajudar a confirmar disponibilidade em loja. Se quiser agilizar, anexe uma foto da embalagem ou da receita e depois selecione atendimento humano para a conferencia final.',
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
            'Se precisar de ajuda adicional com o rastreio, posso te encaminhar para uma pessoa do atendimento.',
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
      ),
      'other_subject': _leafStep(
        id: 'other_subject',
        message:
            'Sem problema. Posso te encaminhar para uma pessoa do atendimento ou voce pode voltar ao menu para escolher outra categoria.',
        parentStepId: 'general_menu',
      ),
      'human_now': ClientChatBotStep(
        id: 'human_now',
        message: _humanWaitingNotice,
        options: const [],
        startsHumanAttendance: true,
        enablesManualInput: true,
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
            'Aguarde, em alguns minutinhos ja entraremos em contato. Sua conversa foi marcada como urgente.',
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
  }) {
    return ClientChatBotStep(
      id: id,
      message: message,
      options: [
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

  Future<String> _ensureConversationForManualInteraction() async {
    if (_activeConversationId != null) {
      return _activeConversationId!;
    }

    final systemMessage = _manualInputContext == 'request_callback'
        ? 'Cliente solicitou retorno da equipe.'
        : 'Cliente deixou um recado para a equipe.';

    final conversation = await _ensureHumanConversation(
      urgent: false,
      systemMessage: systemMessage,
    );
    return conversation.id;
  }

  Future<void> _registerHumanRequest({
    required bool urgent,
    required String clientMessage,
    required String notice,
  }) async {
    try {
      final conversation = await _ensureHumanConversation(
        urgent: urgent,
        systemMessage: urgent
            ? 'Cliente solicitou atendimento humano com urgencia.'
            : 'Cliente solicitou atendimento humano.',
      );

      await _repository.sendClientText(
        conversationId: conversation.id,
        text: clientMessage,
      );
      await _repository.sendClientNotice(
        conversationId: conversation.id,
        text: notice,
        preserveLastPreview: clientMessage,
      );
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<SupportConversationRecord> _ensureHumanConversation({
    required bool urgent,
    required String systemMessage,
  }) async {
    final conversation = await _repository.requestHumanSupport(
      urgent: urgent,
      systemMessage: systemMessage,
    );
    _activeConversationId = conversation.id;
    _isHumanAttendanceActive = true;
    _conversation = _conversation.copyWith(
      conversationId: conversation.id,
      statusLabel: _statusLabelForConversation(conversation),
      attendantName: conversation.attendantName,
    );
    notifyListeners();
    return conversation;
  }

  void _openBotStep(String stepId) {
    final step = _steps[stepId];
    if (step == null) {
      return;
    }

    if (!step.enablesManualInput) {
      _manualInputContext = null;
    } else {
      _manualInputContext = stepId;
    }

    _appendMessage(
      ClientChatMessage(
        id: 'bot-step-$stepId-${DateTime.now().microsecondsSinceEpoch}',
        sender: ClientChatSender.bot,
        senderName: 'Farmacia Americana',
        time: _formatCurrentTime(),
        text: step.options.isEmpty
            ? step.message
            : '${step.message}\n\nA qualquer momento, use as opcoes abaixo para voltar ao menu principal ou pedir atendimento humano urgente.',
        options: step.options,
      ),
    );

    _activeOptionsMessageId = step.options.isEmpty
        ? null
        : _conversation.messages.last.id;

    if (step.startsHumanAttendance) {
      _isHumanAttendanceActive = true;
      _manualInputContext = null;
      _activeOptionsMessageId = null;
    } else if (!step.enablesManualInput) {
      _isHumanAttendanceActive = false;
    }

    notifyListeners();
  }

  ClientChatMessage _mapSupportMessage(SupportMessageRecord message) {
    final sender = _mapSender(message.senderType);

    ClientChatAttachment? attachment;
    if (message.messageType == SupportMessageType.attachment &&
        message.attachmentName != null &&
        message.attachmentDetails != null) {
      attachment = ClientChatAttachment(
        id: 'support-${message.id}',
        type: _inferAttachmentType(message.attachmentName!),
        fileName: message.attachmentName!,
        fileDetails: message.attachmentDetails!,
      );
    }

    return ClientChatMessage(
      id: message.id,
      sender: sender,
      senderName: message.senderName,
      time: _formatTime(message.createdAt),
      text: message.body,
      attachment: attachment,
      showReadReceipt: sender == ClientChatSender.client,
    );
  }

  ClientChatSender _mapSender(SupportSenderType senderType) {
    switch (senderType) {
      case SupportSenderType.client:
        return ClientChatSender.client;
      case SupportSenderType.attendant:
        return ClientChatSender.attendant;
      case SupportSenderType.bot:
      case SupportSenderType.system:
        return ClientChatSender.bot;
    }
  }

  ClientAttachmentType _inferAttachmentType(String fileName) {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    return _isImageExtension(extension)
        ? ClientAttachmentType.photo
        : ClientAttachmentType.document;
  }

  String _statusLabelForConversation(SupportConversationRecord conversation) {
    if (conversation.status == 'finalizado') {
      return 'Atendimento encerrado';
    }

    if (conversation.attendantName != null &&
        conversation.attendantName!.trim().isNotEmpty) {
      return 'Atendente: ${conversation.attendantName}';
    }

    if (conversation.status == 'novo') {
      return 'Aguardando um atendente assumir';
    }

    return 'Equipe de atendimento online';
  }

  void _appendMessage(ClientChatMessage message) {
    _conversation = _conversation.copyWith(
      isSupportTyping: false,
      messages: [..._conversation.messages, message],
    );
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

  static const String _humanWaitingNotice =
      'Aguarde, em alguns minutinhos ja entraremos em contato.';

  String _formatCurrentTime() {
    return _formatTime(DateTime.now());
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _subscribeToRealtime() {
    if (_channel != null) {
      return;
    }

    final client = Supabase.instance.client;
    _channel = client.channel('client-support-chat')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'support_conversations',
        callback: (_) => unawaited(refreshConversation()),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'support_messages',
        callback: (_) => unawaited(refreshConversation()),
      )
      ..subscribe();
  }

  @override
  void dispose() {
    messageController.dispose();
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }
    super.dispose();
  }
}
