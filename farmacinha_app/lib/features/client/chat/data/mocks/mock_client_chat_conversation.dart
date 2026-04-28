import 'package:farmacia_app/features/client/chat/data/models/client_chat_conversation_model.dart';

class MockClientChatConversation {
  static ClientChatConversation getConversation() {
    return const ClientChatConversation(
      pharmacyName: 'Drogaria Americana',
      statusLabel: 'ChatBot e equipe de atendimento',
      isSupportTyping: false,
      messages: [],
    );
  }
}
