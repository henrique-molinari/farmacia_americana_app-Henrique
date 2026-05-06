import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/view/account_screen.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_attachment_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_message_model.dart';
import 'package:farmacia_app/features/client/chat/data/models/client_chat_option_model.dart';
import 'package:farmacia_app/features/client/chat/view_model/client_chat_view_model.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/client/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  late final ClientChatViewModel _viewModel;
  late final ScrollController _scrollController;
  String _lastRenderedMessageId = '';

  @override
  void initState() {
    super.initState();
    _viewModel = ClientChatViewModel();
    _scrollController = ScrollController();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
        ),
        titleSpacing: 0,
        title: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final conversation = _viewModel.conversation;

            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/logo_pequena.png',
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        conversation.pharmacyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF291715),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conversation.statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8F6A64),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return IconButton(
                onPressed: _viewModel.isLoading ? null : _confirmResetChat,
                tooltip: 'Recomecar chat',
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Pallete.primaryRed,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final conversation = _viewModel.conversation;
          _scrollToLatestMessage(conversation.messages);

          return Column(
            children: [
              if (_viewModel.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _viewModel.errorMessage!,
                    style: const TextStyle(
                      color: Pallete.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EE),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFD7D1)),
                ),
                child: const Row(
                  children: [
                    _TopInfoIcon(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'O atendimento comeca pelo ChatBot com opcoes clicaveis. Quando necessario, a conversa e encaminhada para uma pessoa do time.',
                        style: TextStyle(
                          color: Color(0xFF5D3F3C),
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF8F7),
                        Color(0xFFFFF4F1),
                        Color(0xFFFFF0EE),
                      ],
                    ),
                  ),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (_viewModel.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const Center(
                        child: _DayPill(label: 'Atendimento de hoje'),
                      ),
                      const SizedBox(height: 22),
                      ...conversation.messages.map(
                        (message) => _MessageBubble(
                          message: message,
                          isOptionsEnabled: _viewModel.isOptionsEnabledFor(
                            message.id,
                          ),
                          onOptionSelected: _viewModel.selectOption,
                        ),
                      ),
                      if (conversation.isSupportTyping) ...[
                        const SizedBox(height: 6),
                        const _TypingIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              _ChatComposer(
                controller: _viewModel.messageController,
                isEnabled: _viewModel.canSendFreeText && !_viewModel.isLoading,
                canAttach: _viewModel.canAttachFiles && !_viewModel.isLoading,
                onAttach: _showAttachmentOptions,
                onSend: () {
                  _viewModel.sendMessage();
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: _onBottomBarTap,
      ),
    );
  }

  void _scrollToLatestMessage(List<ClientChatMessage> messages) {
    final lastMessageId = messages.isEmpty ? 'empty' : messages.last.id;
    if (lastMessageId == _lastRenderedMessageId) {
      return;
    }

    _lastRenderedMessageId = lastMessageId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _showAttachmentOptions() async {
    if (!_viewModel.canAttachFiles) {
      _showSnack('Recomece o chat para enviar novos anexos.');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Anexar arquivo',
                  style: TextStyle(
                    color: Color(0xFF291715),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Escolha se deseja enviar uma imagem da galeria ou um documento compativel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Pallete.textColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                _AttachmentOptionTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: const Color(0xFF005F93),
                  iconBackgroundColor: const Color(0xFFCDE5FF),
                  title: 'Anexar imagem',
                  subtitle: 'Seleciona apenas fotos ou imagens da galeria',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final message = await _viewModel.attachFile(
                      ClientAttachmentType.photo,
                    );
                    if (!mounted || message == null) return;
                    _showSnack(message);
                  },
                ),
                const SizedBox(height: 12),
                _AttachmentOptionTile(
                  icon: Icons.description_rounded,
                  iconColor: Pallete.primaryRed,
                  iconBackgroundColor: const Color(0xFFFFE3DF),
                  title: 'Anexar documento',
                  subtitle: 'Aceita PDF, DOC, DOCX, TXT e RTF',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final message = await _viewModel.attachFile(
                      ClientAttachmentType.document,
                    );
                    if (!mounted || message == null) return;
                    _showSnack(message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmResetChat() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recomecar chat?'),
          content: const Text(
            'A conversa atual sera limpa desta tela e o menu inicial aparecera novamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Recomecar'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !mounted) {
      return;
    }

    await _viewModel.resetChat();

    if (!mounted) {
      return;
    }

    _showSnack('Chat reiniciado.');
  }

  void _onBottomBarTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.cart);
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TopInfoIcon extends StatelessWidget {
  const _TopInfoIcon();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD33D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const SizedBox(
        width: 42,
        height: 42,
        child: Icon(Icons.smart_toy_rounded, color: Color(0xFF6E5C00)),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final String label;

  const _DayPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAE6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9A6E66),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ClientChatMessage message;
  final bool isOptionsEnabled;
  final ValueChanged<ClientChatOption> onOptionSelected;

  const _MessageBubble({
    required this.message,
    required this.isOptionsEnabled,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isFromClient = message.isFromClient;
    final isFromAttendant = message.isFromAttendant;

    final bubbleColor = isFromClient
        ? Pallete.primaryRed
        : isFromAttendant
        ? const Color(0xFFFFE8E4)
        : Colors.white;

    final textColor = isFromClient ? Colors.white : const Color(0xFF3A2A27);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isFromClient
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (isFromAttendant) ...[
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                message.senderName?.trim().isNotEmpty == true
                    ? message.senderName!
                    : 'Atendimento humano',
                style: TextStyle(
                  color: Pallete.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          Align(
            alignment: isFromClient
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 310),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isFromClient ? 18 : 6),
                    bottomRight: Radius.circular(isFromClient ? 6 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.hasAttachment)
                      _AttachmentPreview(message: message)
                    else if ((message.text ?? '').isNotEmpty)
                      Text(
                        message.text!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (message.hasOptions) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.options
                            .map(
                              (option) => _OptionChip(
                                option: option,
                                enabled: isOptionsEnabled,
                                onTap: () => onOptionSelected(option),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.time,
                style: const TextStyle(
                  color: Color(0xFF8F817A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (message.showReadReceipt) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.done_all_rounded,
                  size: 15,
                  color: Color(0xFFB88A8A),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final ClientChatOption option;
  final bool enabled;
  final VoidCallback onTap;

  const _OptionChip({
    required this.option,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFFFF0EE) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: enabled ? const Color(0xFFFFD0C8) : const Color(0xFFE2E2E2),
          ),
        ),
        child: Text(
          option.label,
          style: TextStyle(
            color: enabled ? Pallete.primaryRed : const Color(0xFF8E8E8E),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final ClientChatMessage message;

  const _AttachmentPreview({required this.message});

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachment!;
    final isPhoto = attachment.type == ClientAttachmentType.photo;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: message.isFromClient
            ? const Color(0x33FFFFFF)
            : const Color(0xFFFFF3F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: message.isFromClient
                  ? Colors.white.withOpacity(0.16)
                  : const Color(0xFFFFE3DF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPhoto
                  ? Icons.photo_library_rounded
                  : Icons.picture_as_pdf_rounded,
              color: message.isFromClient ? Colors.white : Pallete.primaryRed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: message.isFromClient
                        ? Colors.white
                        : const Color(0xFF4A4A4A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.fileDetails,
                  style: TextStyle(
                    color: message.isFromClient
                        ? Colors.white.withOpacity(0.82)
                        : const Color(0xFF8B8B8B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 6),
      child: Text(
        'Atendimento digitando...',
        style: TextStyle(
          color: Color(0xFF9A887F),
          fontSize: 13,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final bool canAttach;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _ChatComposer({
    required this.controller,
    required this.isEnabled,
    required this.canAttach,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F7),
          border: Border(top: BorderSide(color: Color(0xFFFFDDD8))),
        ),
        child: Row(
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: canAttach ? onAttach : null,
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: canAttach
                        ? Pallete.primaryRed
                        : const Color(0xFFD8D8D8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.only(left: 16, right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  enabled: isEnabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => isEnabled ? onSend() : null,
                  decoration: InputDecoration(
                    hintText: isEnabled
                        ? 'Escreva sua mensagem...'
                        : 'Escolha uma opcao no chat para continuar...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9D9D9D),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: isEnabled ? Pallete.primaryRed : const Color(0xFFD8D8D8),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: isEnabled ? onSend : null,
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  width: 54,
                  height: 54,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _AttachmentOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF291715),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Pallete.textColor,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Pallete.textColor),
          ],
        ),
      ),
    );
  }
}
