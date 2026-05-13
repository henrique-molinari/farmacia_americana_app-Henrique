import 'dart:async';

import 'package:flutter/material.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_search_client_model.dart';
import 'package:farmacia_app/features/support/data/repositories/support_chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendantSearchViewModel extends ChangeNotifier {
  AttendantSearchViewModel({SupportChatRepository? repository})
    : _repository = repository ?? SupportChatRepository.instance {
    searchController.addListener(_applyFilters);
  }

  final SupportChatRepository _repository;
  final TextEditingController searchController = TextEditingController();

  List<AttendantSearchClient> _allClients = [];
  List<AttendantSearchClient> _filteredClients = [];
  RealtimeChannel? _channel;
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendantSearchClient> get clients => _filteredClients;
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
      _allClients = conversations
          .map(
            (conversation) => AttendantSearchClient(
              id: conversation.clientId,
              initials: conversation.clientInitials,
              name: conversation.clientName,
              cpf: conversation.clientCpf.isEmpty
                  ? 'CPF não informado'
                  : conversation.clientCpf,
              timeLabel: _formatRecentTime(
                conversation.lastMessageAt ?? conversation.updatedAt,
              ),
              preview: conversation.lastMessagePreview,
              isUrgent: conversation.isUrgent,
            ),
          )
          .toList(growable: false);
      _applyFilters(notify: false);
    } catch (error) {
      _allClients = [];
      _filteredClients = [];
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchPressed() {
    _applyFilters();
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
              client.initials.toLowerCase().contains(query) ||
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
    _channel = client.channel('attendant-search-list')
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

  String _formatRecentTime(DateTime moment) {
    final now = DateTime.now();
    final difference = now.difference(moment);

    if (difference.inHours < 1) {
      return 'AGORA';
    }

    if (difference.inDays == 0) {
      return 'HOJE';
    }

    if (difference.inDays == 1) {
      return 'ONTEM';
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
