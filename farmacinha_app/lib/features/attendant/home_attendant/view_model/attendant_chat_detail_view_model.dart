import 'dart:async';

import 'package:flutter/material.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_chat_message_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_conversation_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_search_client_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendantChatDetailViewModel extends ChangeNotifier {
  AttendantChatDetailViewModel({SupportChatRepository? repository})
    : _repository = repository ?? SupportChatRepository.instance;

  final SupportChatRepository _repository;
  final TextEditingController messageController = TextEditingController();

  AttendantConversation? _currentConversation;
  RealtimeChannel? _channel;
  Timer? _refreshTimer;
  String? _selectedClientId;
  bool _isLoading = false;
  bool _isClosing = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  AttendantConversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isClosing => _isClosing;
  String? get errorMessage => _errorMessage;

  Future<void> initialize(String? clientId) async {
    _selectedClientId = clientId;
    await refresh();
    _subscribeToRealtime();
    _startRefreshPolling();
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _errorMessage = null;
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final clientId = await _resolveClientId();
      if (clientId == null) {
        _currentConversation = null;
        return;
      }

      _selectedClientId = clientId;
      final conversation = await _repository.claimConversationForAttendant(
        clientId,
      );

      if (conversation == null) {
        _currentConversation = null;
        return;
      }

      final messages = await _repository.fetchMessages(conversation.id);
      _currentConversation = AttendantConversation(
        client: AttendantSearchClient(
          id: conversation.clientId,
          initials: conversation.clientInitials,
          name: conversation.clientName,
          cpf: conversation.clientCpf.isEmpty
              ? 'CPF não informado'
              : conversation.clientCpf,
          timeLabel: '',
          preview: conversation.lastMessagePreview,
          isUrgent: conversation.isUrgent,
        ),
        statusLabel: _statusLabel(conversation),
        orderCode: 'ATEND ${conversation.displayCode}',
        isClientTyping: false,
        messages: messages
            .map(_mapMessage)
            .whereType<AttendantChatMessage>()
            .toList(growable: false),
      );
    } catch (error) {
      _currentConversation = null;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isRefreshing = false;
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void selectClient(String clientId) {
    _selectedClientId = clientId;
    unawaited(refresh());
  }

  Future<void> sendMessage() async {
    final draft = messageController.text.trim();
    if (draft.isEmpty || _isClosing) {
      return;
    }

    final clientId = _selectedClientId;
    if (clientId == null) {
      return;
    }

    try {
      await _repository.sendAttendantText(clientId: clientId, text: draft);
      messageController.clear();
      await refresh();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> closeConversation() async {
    final clientId = _selectedClientId;
    if (clientId == null || _isClosing) {
      return false;
    }

    _isClosing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.closeConversationAsAttendant(
        clientId: clientId,
        closingMessage: _closingMessage,
      );
      messageController.clear();
      _currentConversation = null;
      _selectedClientId = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isClosing = false;
      notifyListeners();
    }
  }

  Future<String?> _resolveClientId() async {
    if (_selectedClientId != null && _selectedClientId!.isNotEmpty) {
      return _selectedClientId;
    }

    final inbox = await _repository.fetchAttendantInbox();
    if (inbox.isEmpty) {
      return null;
    }

    return inbox.first.clientId;
  }

  AttendantChatMessage? _mapMessage(SupportMessageRecord message) {
    if (message.senderType == SupportSenderType.system ||
        message.senderType == SupportSenderType.bot) {
      return null;
    }

    final isAttachment = message.messageType == SupportMessageType.attachment;
    final isFromAttendant = message.senderType == SupportSenderType.attendant;

    return AttendantChatMessage(
      id: message.id,
      type: isAttachment
          ? AttendantMessageType.attachment
          : AttendantMessageType.text,
      isFromAttendant: isFromAttendant,
      time: _formatTime(message.createdAt),
      fileName: message.attachmentName,
      fileDetails: message.attachmentDetails,
      showReadReceipt: isFromAttendant,
      message: message.body,
    );
  }

  String _statusLabel(SupportConversationRecord conversation) {
    if (conversation.attendantName != null &&
        conversation.attendantName!.trim().isNotEmpty) {
      return 'COM ${conversation.attendantName!.toUpperCase()}';
    }

    if (conversation.status == 'novo') {
      return 'AGUARDANDO';
    }

    return 'EM ATENDIMENTO';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static const String _closingMessage =
      'Atendimento encerrado, obrigado pela confiança  qualquer duvida entre em contato novamente :)';

  void _subscribeToRealtime() {
    if (_channel != null) {
      return;
    }

    final client = Supabase.instance.client;
    _channel = client.channel('attendant-chat-detail')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'support_conversations',
        callback: (_) => unawaited(refresh()),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'support_messages',
        callback: (_) => unawaited(refresh()),
      )
      ..subscribe();
  }

  void _startRefreshPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(refresh(showLoading: false)),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    _refreshTimer?.cancel();
    _refreshTimer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }
    super.dispose();
  }
}
