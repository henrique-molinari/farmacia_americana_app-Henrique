import 'dart:async';

import 'package:flutter/material.dart';
import 'package:farmacia_app/core/utils/date_time_utils.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/mocks/mock_attendant_status.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_chat_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_status_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAttendantViewModel extends ChangeNotifier {
  HomeAttendantViewModel({SupportChatRepository? repository})
    : _repository = repository ?? SupportChatRepository.instance {
    _baseStatusList = MockAttendantStatus.getStatusList();
    searchController.addListener(_applyFilters);
  }

  final SupportChatRepository _repository;
  final TextEditingController searchController = TextEditingController();
  ValueChanged<SupportHumanRequestNotification>? onHumanSupportRequest;

  List<AttendantChat> _allChats = [];
  List<AttendantChat> _filteredChats = [];
  List<AttendantStatus> _baseStatusList = [];
  List<AttendantStatus> _statusList = [];
  RealtimeChannel? _channel;

  String _selectedStatus = 'em_atendimento';
  int _currentTab = 0;
  int _notificationsCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendantChat> get chats => _filteredChats;
  List<AttendantStatus> get statusList => _statusList;
  String get selectedStatus => _selectedStatus;
  int get currentTab => _currentTab;
  int get notificationsCount => _notificationsCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await refresh();
    _subscribeToRealtime();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final conversations = await _repository.fetchAttendantInbox();
      final notifications = await _repository
          .fetchRecentHumanRequestNotifications(limit: 20);
      _notificationsCount = notifications.length;
      _allChats = conversations
          .map(
            (conversation) => AttendantChat(
              id: conversation.clientId,
              customerName: conversation.clientName,
              preview: conversation.lastMessagePreview,
              timestamp: _formatInboxTimestamp(conversation),
              status: conversation.status,
              isUrgent: conversation.isUrgent,
              isPositive: conversation.status == 'finalizado',
            ),
          )
          .toList(growable: false);
      _updateStatusCounts();
      _applyFilters(notify: false);
    } catch (error) {
      _allChats = [];
      _filteredChats = [];
      _notificationsCount = 0;
      _updateStatusCounts();
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectStatus(String statusId) {
    _selectedStatus = statusId;
    _applyFilters();
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void _applyFilters({bool notify = true}) {
    final query = searchController.text.trim().toLowerCase();

    _filteredChats = _allChats
        .where((chat) {
          final statusMatch = chat.status == _selectedStatus;
          final queryMatch =
              query.isEmpty ||
              chat.customerName.toLowerCase().contains(query) ||
              chat.preview.toLowerCase().contains(query);
          return statusMatch && queryMatch;
        })
        .toList(growable: false);

    if (notify) {
      notifyListeners();
    }
  }

  void _updateStatusCounts() {
    _statusList = _baseStatusList
        .map((status) {
          final count = _allChats
              .where((chat) => chat.status == status.id)
              .length;
          return AttendantStatus(
            id: status.id,
            label: status.label,
            count: count,
            icon: status.icon,
          );
        })
        .toList(growable: false);
  }

  void _subscribeToRealtime() {
    if (_channel != null) {
      return;
    }

    final client = Supabase.instance.client;
    _channel = client.channel('home-attendant-inbox')
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
        callback: (payload) {
          unawaited(_handleSupportRequestMessage(payload));
          unawaited(refresh());
        },
      )
      ..subscribe();
  }

  Future<void> _handleSupportRequestMessage(
    PostgresChangePayload payload,
  ) async {
    if (payload.eventType != PostgresChangeEvent.insert) {
      return;
    }

    final message = payload.newRecord;
    final body = (message['body'] ?? '').toString().trim();
    if ((message['sender_type'] ?? '').toString() != 'system' ||
        !body.contains('Aguarde, em alguns minutinhos')) {
      return;
    }

    final conversationId = (message['conversation_id'] ?? '').toString();
    final conversation = await _repository.fetchConversationById(
      conversationId,
    );
    if (conversation == null) {
      return;
    }

    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    if (conversation.attendantId != null &&
        conversation.attendantId != authUserId) {
      return;
    }

    onHumanSupportRequest?.call(
      SupportHumanRequestNotification(
        id: (message['id'] ?? '').toString(),
        conversationId: conversationId,
        clientId: conversation.clientId,
        clientName: conversation.clientName,
        preview: body.isEmpty ? 'Cliente solicitou atendimento humano.' : body,
        isUrgent: conversation.isUrgent,
        createdAt:
            tryParseUtcToLocal(message['created_at']?.toString()) ??
            DateTime.now(),
      ),
    );
  }

  String _formatInboxTimestamp(SupportConversationRecord conversation) {
    final moment = conversation.lastMessageAt ?? conversation.updatedAt;
    final now = DateTime.now();
    final difference = now.difference(moment);

    if (conversation.isUrgent && difference.inMinutes <= 10) {
      return 'URGENTE • ${difference.inMinutes.clamp(1, 10)}M';
    }

    if (difference.inMinutes < 1) {
      return 'Agora';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    if (difference.inDays == 1) {
      return 'Ontem';
    }

    return '${moment.day.toString().padLeft(2, '0')}/${moment.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    searchController.dispose();
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }
    super.dispose();
  }
}
