import 'dart:async';

import 'package:flutter/material.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_search_client_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendantChatViewModel extends ChangeNotifier {
  AttendantChatViewModel({SupportChatRepository? repository})
    : _repository = repository ?? SupportChatRepository.instance {
    searchController.addListener(_applyFilters);
  }

  final SupportChatRepository _repository;
  final TextEditingController searchController = TextEditingController();
  final List<AttendantSearchClient> _allClients = [];

  List<AttendantSearchClient> _filteredClients = [];
  RealtimeChannel? _channel;
  Timer? _refreshTimer;
  String? _selectedClientId;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  List<AttendantSearchClient> get clients => _filteredClients;
  String? get selectedClientId => _selectedClientId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
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
      final conversations = await _repository.fetchAttendantInbox();
      _allClients
        ..clear()
        ..addAll(
          conversations.map(
            (conversation) => AttendantSearchClient(
              id: conversation.clientId,
              initials: conversation.clientInitials,
              name: conversation.clientName,
              cpf: conversation.clientCpf.isEmpty
                  ? 'CPF nao informado'
                  : conversation.clientCpf,
              timeLabel: _formatTimeLabel(
                conversation.lastMessageAt ?? conversation.updatedAt,
              ),
              preview: conversation.lastMessagePreview,
              isUrgent: conversation.isUrgent,
            ),
          ),
        );
      _applyFilters(notify: false);
    } catch (error) {
      _allClients.clear();
      _filteredClients = [];
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
    notifyListeners();
  }

  void _applyFilters({bool notify = true}) {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      _filteredClients = List<AttendantSearchClient>.from(_allClients);
      if (notify) {
        notifyListeners();
      }
      return;
    }

    _filteredClients = _allClients
        .where((client) {
          return client.name.toLowerCase().contains(query) ||
              client.cpf.toLowerCase().contains(query) ||
              client.preview.toLowerCase().contains(query);
        })
        .toList(growable: false);

    if (notify) {
      notifyListeners();
    }
  }

  void _subscribeToRealtime() {
    if (_channel != null) {
      return;
    }

    final client = Supabase.instance.client;
    _channel = client.channel('attendant-chat-list')
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

  String _formatTimeLabel(DateTime moment) {
    final now = DateTime.now();
    final difference = now.difference(moment);

    if (difference.inMinutes < 1) {
      return 'AGORA';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} MIN';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}H';
    }

    if (difference.inDays == 1) {
      return 'ONTEM';
    }

    return '${moment.day.toString().padLeft(2, '0')}/${moment.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    searchController.dispose();
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
