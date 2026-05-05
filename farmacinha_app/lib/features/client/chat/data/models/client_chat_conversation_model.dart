import 'package:farmacia_app/features/client/chat/data/models/client_chat_message_model.dart';

class ClientChatConversation {
  final String? conversationId;
  final String pharmacyName;
  final String statusLabel;
  final String? attendantName;
  final bool isSupportTyping;
  final bool isFinished;
  final List<ClientChatMessage> messages;

  const ClientChatConversation({
    this.conversationId,
    required this.pharmacyName,
    required this.statusLabel,
    this.attendantName,
    required this.messages,
    this.isSupportTyping = false,
    this.isFinished = false,
  });

  ClientChatConversation copyWith({
    String? conversationId,
    String? pharmacyName,
    String? statusLabel,
    String? attendantName,
    bool? isSupportTyping,
    bool? isFinished,
    List<ClientChatMessage>? messages,
  }) {
    return ClientChatConversation(
      conversationId: conversationId ?? this.conversationId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      statusLabel: statusLabel ?? this.statusLabel,
      attendantName: attendantName ?? this.attendantName,
      isSupportTyping: isSupportTyping ?? this.isSupportTyping,
      isFinished: isFinished ?? this.isFinished,
      messages: messages ?? this.messages,
    );
  }
}
