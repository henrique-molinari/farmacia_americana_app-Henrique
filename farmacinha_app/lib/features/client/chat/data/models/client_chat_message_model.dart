import 'package:farmacia_app/features/client/chat/data/models/client_chat_attachment_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_option_model.dart';

enum ClientChatSender { client, bot, attendant }

class ClientChatMessage {
  final String id;
  final ClientChatSender sender;
  final String time;
  final String? senderName;
  final String? text;
  final ClientChatAttachment? attachment;
  final List<ClientChatOption> options;
  final bool showReadReceipt;

  const ClientChatMessage({
    required this.id,
    required this.sender,
    required this.time,
    this.senderName,
    this.text,
    this.attachment,
    this.options = const [],
    this.showReadReceipt = false,
  });

  bool get hasAttachment => attachment != null;
  bool get hasOptions => options.isNotEmpty;
  bool get isFromClient => sender == ClientChatSender.client;
  bool get isFromBot => sender == ClientChatSender.bot;
  bool get isFromAttendant => sender == ClientChatSender.attendant;
}
