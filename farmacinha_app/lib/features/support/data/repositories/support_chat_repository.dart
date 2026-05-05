import 'package:farmacia_app/core/utils/date_time_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SupportSenderType { client, attendant, bot, system }

enum SupportMessageType { text, attachment }

class SupportConversationRecord {
  final String id;
  final String clientId;
  final String clientName;
  final String clientCpf;
  final String clientEmail;
  final String? attendantId;
  final String? attendantName;
  final String status;
  final bool isUrgent;
  final String lastMessagePreview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;

  const SupportConversationRecord({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientCpf,
    required this.clientEmail,
    required this.attendantId,
    required this.attendantName,
    required this.status,
    required this.isUrgent,
    required this.lastMessagePreview,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessageAt,
  });

  String get clientInitials {
    final parts = clientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return 'CL';
    }

    if (parts.length == 1) {
      final name = parts.first;
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get displayCode =>
      '#${id.replaceAll('-', '').substring(0, 6).toUpperCase()}';
}

class SupportMessageRecord {
  final String id;
  final String conversationId;
  final String? senderId;
  final String? senderName;
  final SupportSenderType senderType;
  final SupportMessageType messageType;
  final String? body;
  final String? attachmentName;
  final String? attachmentDetails;
  final DateTime createdAt;

  const SupportMessageRecord({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.messageType,
    required this.body,
    required this.attachmentName,
    required this.attachmentDetails,
    required this.createdAt,
  });
}

class SupportChatRepository {
  SupportChatRepository._();

  static final SupportChatRepository instance = SupportChatRepository._();

  static const String _conversationTable = 'support_conversations';
  static const String _messageTable = 'support_messages';
  static const List<String> _activeStatuses = ['novo', 'em_atendimento'];

  SupabaseClient get _client => Supabase.instance.client;

  Future<SupportConversationRecord?> fetchCurrentClientConversation() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      return null;
    }

    try {
      final response = await _client
          .from(_conversationTable)
          .select()
          .eq('client_id', authUser.id)
          .inFilter('status', _activeStatuses)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapConversation(
        Map<String, dynamic>.from(response),
        await _fetchProfilesForConversations([
          Map<String, dynamic>.from(response),
        ]),
      );
    } on PostgrestException catch (error) {
      throw Exception(_formatSchemaError(error));
    }
  }

  Future<SupportConversationRecord?> fetchLatestClientConversation() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      return null;
    }

    try {
      final response = await _client
          .from(_conversationTable)
          .select()
          .eq('client_id', authUser.id)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapConversation(
        Map<String, dynamic>.from(response),
        await _fetchProfilesForConversations([
          Map<String, dynamic>.from(response),
        ]),
      );
    } on PostgrestException catch (error) {
      throw Exception(_formatSchemaError(error));
    }
  }

  Future<List<SupportConversationRecord>> fetchAttendantInbox({
    bool includeFinished = false,
  }) async {
    try {
      final response = includeFinished
          ? await _client
                .from(_conversationTable)
                .select()
                .order('is_urgent', ascending: false)
                .order('updated_at', ascending: false)
          : await _client
                .from(_conversationTable)
                .select()
                .inFilter('status', _activeStatuses)
                .order('is_urgent', ascending: false)
                .order('updated_at', ascending: false);

      final conversations = response.whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
      final profiles = await _fetchProfilesForConversations(conversations);

      return conversations
          .map((conversation) => _mapConversation(conversation, profiles))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw Exception(_formatSchemaError(error));
    }
  }

  Future<SupportConversationRecord?> fetchConversationForClient(
    String clientId,
  ) async {
    try {
      final response = await _client
          .from(_conversationTable)
          .select()
          .eq('client_id', clientId)
          .inFilter('status', _activeStatuses)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final conversation = Map<String, dynamic>.from(response);
      final profiles = await _fetchProfilesForConversations([conversation]);
      return _mapConversation(conversation, profiles);
    } on PostgrestException catch (error) {
      throw Exception(_formatSchemaError(error));
    }
  }

  Future<List<SupportMessageRecord>> fetchMessages(
    String conversationId,
  ) async {
    try {
      final response = await _client
          .from(_messageTable)
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages = response
          .whereType<Map<String, dynamic>>()
          .map(_mapMessage)
          .toList(growable: false);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return messages;
    } on PostgrestException catch (error) {
      throw Exception(_formatSchemaError(error));
    }
  }

  Future<SupportConversationRecord> requestHumanSupport({
    required bool urgent,
    String? systemMessage,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para falar com um atendente.');
    }

    final existing = await fetchCurrentClientConversation();

    String conversationId;

    if (existing == null) {
      final created = await _client
          .from(_conversationTable)
          .insert({
            'client_id': authUser.id,
            'status': 'novo',
            'is_urgent': urgent,
            'last_message_preview':
                systemMessage ??
                (urgent
                    ? 'Cliente solicitou atendimento humano com urgencia.'
                    : 'Cliente solicitou atendimento humano.'),
            'last_message_at': nowUtc().toIso8601String(),
          })
          .select()
          .single();
      conversationId = (created['id'] ?? '').toString();
    } else {
      conversationId = existing.id;
      await _client
          .from(_conversationTable)
          .update({
            'is_urgent': urgent || existing.isUrgent,
            'status': existing.status == 'finalizado'
                ? 'novo'
                : existing.status,
          })
          .eq('id', existing.id);
    }

    final conversation = await fetchCurrentClientConversation();
    if (conversation == null) {
      throw Exception('Nao foi possivel iniciar o atendimento humano.');
    }
    return conversation;
  }

  Future<void> sendClientText({
    required String conversationId,
    required String text,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para enviar mensagens.');
    }

    final profile = await _fetchProfileById(authUser.id);

    await _insertMessage(
      conversationId: conversationId,
      senderId: authUser.id,
      senderType: SupportSenderType.client,
      senderName: _profileName(profile, fallbackId: authUser.id),
      body: text,
      messageType: SupportMessageType.text,
    );
  }

  Future<void> sendClientNotice({
    required String conversationId,
    required String text,
    String? preserveLastPreview,
  }) async {
    await _insertMessage(
      conversationId: conversationId,
      senderType: SupportSenderType.system,
      senderName: 'Farmacia Americana',
      body: text,
      messageType: SupportMessageType.text,
    );

    if (preserveLastPreview == null || preserveLastPreview.trim().isEmpty) {
      return;
    }

    await _client
        .from(_conversationTable)
        .update({'last_message_preview': preserveLastPreview.trim()})
        .eq('id', conversationId);
  }

  Future<void> sendClientAttachmentSummary({
    required String conversationId,
    required String fileName,
    required String fileDetails,
    String? caption,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para enviar anexos.');
    }

    final profile = await _fetchProfileById(authUser.id);

    await _insertMessage(
      conversationId: conversationId,
      senderId: authUser.id,
      senderType: SupportSenderType.client,
      senderName: _profileName(profile, fallbackId: authUser.id),
      body: caption,
      messageType: SupportMessageType.attachment,
      attachmentName: fileName,
      attachmentDetails: fileDetails,
    );
  }

  Future<SupportConversationRecord?> claimConversationForAttendant(
    String clientId,
  ) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta de atendente para assumir o chat.');
    }

    final conversation = await fetchConversationForClient(clientId);
    if (conversation == null) {
      return null;
    }

    if (conversation.attendantId == null ||
        conversation.attendantId == authUser.id) {
      await _client
          .from(_conversationTable)
          .update({'attendant_id': authUser.id, 'status': 'em_atendimento'})
          .eq('id', conversation.id);
    }

    return fetchConversationForClient(clientId);
  }

  Future<void> sendAttendantText({
    required String clientId,
    required String text,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta de atendente para responder.');
    }

    final claimedConversation = await claimConversationForAttendant(clientId);
    if (claimedConversation == null) {
      throw Exception('Essa conversa nao esta mais disponivel.');
    }

    final profile = await _fetchProfileById(authUser.id);

    await _insertMessage(
      conversationId: claimedConversation.id,
      senderId: authUser.id,
      senderType: SupportSenderType.attendant,
      senderName: _profileName(profile, fallbackId: authUser.id),
      body: text,
      messageType: SupportMessageType.text,
    );
  }

  Future<void> closeConversationAsAttendant({
    required String clientId,
    required String closingMessage,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta de atendente para encerrar o chat.');
    }

    final claimedConversation = await claimConversationForAttendant(clientId);
    if (claimedConversation == null) {
      throw Exception('Essa conversa nao esta mais disponivel.');
    }

    await _insertMessage(
      conversationId: claimedConversation.id,
      senderId: authUser.id,
      senderType: SupportSenderType.system,
      senderName: 'Farmacia Americana',
      body: closingMessage,
      messageType: SupportMessageType.text,
    );

    await _client
        .from(_conversationTable)
        .update({
          'status': 'finalizado',
          'is_urgent': false,
          'last_message_preview': closingMessage,
          'last_message_at': nowUtc().toIso8601String(),
        })
        .eq('id', claimedConversation.id);
  }

  Future<String?> resetCurrentClientConversation() async {
    final conversation = await fetchCurrentClientConversation();
    if (conversation == null) {
      return null;
    }

    await _client
        .from(_conversationTable)
        .update({'status': 'finalizado', 'is_urgent': false})
        .eq('id', conversation.id);

    return conversation.id;
  }

  Future<Map<String, dynamic>> _fetchProfileById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response == null ? const <String, dynamic>{} : response;
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchProfilesForConversations(
    List<Map<String, dynamic>> conversations,
  ) async {
    final ids = <String>{
      for (final conversation in conversations)
        (conversation['client_id'] ?? '').toString(),
      for (final conversation in conversations)
        (conversation['attendant_id'] ?? '').toString(),
    }.where((id) => id.isNotEmpty).toList(growable: false);

    if (ids.isEmpty) {
      return const <String, Map<String, dynamic>>{};
    }

    try {
      final response = await _client
          .from('profiles')
          .select()
          .inFilter('id', ids);
      final result = <String, Map<String, dynamic>>{};
      for (final profile in response.whereType<Map<String, dynamic>>()) {
        final id = (profile['id'] ?? '').toString();
        if (id.isEmpty) {
          continue;
        }
        result[id] = profile;
      }
      return result;
    } catch (_) {
      return const <String, Map<String, dynamic>>{};
    }
  }

  SupportConversationRecord _mapConversation(
    Map<String, dynamic> conversation,
    Map<String, Map<String, dynamic>> profiles,
  ) {
    final clientId = (conversation['client_id'] ?? '').toString();
    final attendantId = (conversation['attendant_id'] ?? '').toString();
    final clientProfile = profiles[clientId] ?? const <String, dynamic>{};
    final attendantProfile = profiles[attendantId] ?? const <String, dynamic>{};
    final lastMessagePreview = (conversation['last_message_preview'] ?? '')
        .toString()
        .trim();

    return SupportConversationRecord(
      id: (conversation['id'] ?? '').toString(),
      clientId: clientId,
      clientName: _profileName(clientProfile, fallbackId: clientId),
      clientCpf: (clientProfile['cpf'] ?? '').toString().trim(),
      clientEmail: (clientProfile['email'] ?? '').toString().trim(),
      attendantId: attendantId.isEmpty ? null : attendantId,
      attendantName: attendantId.isEmpty
          ? null
          : _profileName(attendantProfile, fallbackId: attendantId),
      status: (conversation['status'] ?? 'novo').toString(),
      isUrgent: conversation['is_urgent'] == true,
      lastMessagePreview: lastMessagePreview.isEmpty
          ? 'Nova solicitacao de atendimento.'
          : lastMessagePreview,
      createdAt:
          tryParseUtcToLocal(conversation['created_at']?.toString()) ??
          DateTime.now(),
      updatedAt:
          tryParseUtcToLocal(conversation['updated_at']?.toString()) ??
          DateTime.now(),
      lastMessageAt: tryParseUtcToLocal(
        conversation['last_message_at']?.toString(),
      ),
    );
  }

  SupportMessageRecord _mapMessage(Map<String, dynamic> message) {
    return SupportMessageRecord(
      id: (message['id'] ?? '').toString(),
      conversationId: (message['conversation_id'] ?? '').toString(),
      senderId: (message['sender_id'] ?? '').toString().trim().isEmpty
          ? null
          : (message['sender_id'] ?? '').toString(),
      senderName: (message['sender_name'] ?? '').toString().trim().isEmpty
          ? null
          : (message['sender_name'] ?? '').toString(),
      senderType: _parseSenderType(message['sender_type']?.toString()),
      messageType: _parseMessageType(message['message_type']?.toString()),
      body: (message['body'] ?? '').toString().trim().isEmpty
          ? null
          : (message['body'] ?? '').toString(),
      attachmentName:
          (message['attachment_name'] ?? '').toString().trim().isEmpty
          ? null
          : (message['attachment_name'] ?? '').toString(),
      attachmentDetails:
          (message['attachment_details'] ?? '').toString().trim().isEmpty
          ? null
          : (message['attachment_details'] ?? '').toString(),
      createdAt:
          tryParseUtcToLocal(message['created_at']?.toString()) ??
          DateTime.now(),
    );
  }

  Future<void> _insertMessage({
    required String conversationId,
    required SupportSenderType senderType,
    required SupportMessageType messageType,
    String? senderId,
    String? senderName,
    String? body,
    String? attachmentName,
    String? attachmentDetails,
  }) async {
    try {
      await _client.from(_messageTable).insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_type': _senderTypeValue(senderType),
        'message_type': _messageTypeValue(messageType),
        'body': body,
        'attachment_name': attachmentName,
        'attachment_details': attachmentDetails,
      });
    } on PostgrestException catch (error) {
      throw Exception(_formatSchemaError(error));
    }
  }

  String _profileName(
    Map<String, dynamic> profile, {
    required String fallbackId,
  }) {
    final fullName = (profile['full_name'] ?? '').toString().trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = (profile['email'] ?? '').toString().trim();
    if (email.isNotEmpty) {
      return email;
    }

    if (fallbackId.length >= 6) {
      return 'Cliente ${fallbackId.substring(0, 6)}';
    }

    return 'Cliente';
  }

  SupportSenderType _parseSenderType(String? value) {
    switch (value) {
      case 'attendant':
        return SupportSenderType.attendant;
      case 'bot':
        return SupportSenderType.bot;
      case 'system':
        return SupportSenderType.system;
      case 'client':
      default:
        return SupportSenderType.client;
    }
  }

  SupportMessageType _parseMessageType(String? value) {
    switch (value) {
      case 'attachment':
        return SupportMessageType.attachment;
      case 'text':
      default:
        return SupportMessageType.text;
    }
  }

  String _senderTypeValue(SupportSenderType type) {
    switch (type) {
      case SupportSenderType.client:
        return 'client';
      case SupportSenderType.attendant:
        return 'attendant';
      case SupportSenderType.bot:
        return 'bot';
      case SupportSenderType.system:
        return 'system';
    }
  }

  String _messageTypeValue(SupportMessageType type) {
    switch (type) {
      case SupportMessageType.attachment:
        return 'attachment';
      case SupportMessageType.text:
        return 'text';
    }
  }

  String _formatSchemaError(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (message.contains('support_conversations') ||
        message.contains('support_messages') ||
        message.contains('relation') ||
        message.contains('does not exist')) {
      return 'O chat do atendimento ainda nao foi criado no Supabase. Rode o SQL docs/supabase_support_chat.sql.';
    }

    if (message.contains('row-level security')) {
      return 'O Supabase bloqueou o chat por RLS. Rode o SQL docs/supabase_support_chat.sql e confira as policies.';
    }

    return 'Nao foi possivel sincronizar o chat. Detalhe: ${error.message}';
  }
}
