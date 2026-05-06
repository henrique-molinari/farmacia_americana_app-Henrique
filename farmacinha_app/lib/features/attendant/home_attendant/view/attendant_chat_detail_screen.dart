import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_chat_message_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_chat_detail_view_model.dart';

class AttendantChatDetailScreen extends StatefulWidget {
  const AttendantChatDetailScreen({super.key});

  @override
  State<AttendantChatDetailScreen> createState() =>
      _AttendantChatDetailScreenState();
}

class _AttendantChatDetailScreenState extends State<AttendantChatDetailScreen> {
  late final AttendantChatDetailViewModel _viewModel;
  late final ScrollController _scrollController;
  bool _didSyncRouteSelection = false;
  String _lastRenderedMessageId = '';

  @override
  void initState() {
    super.initState();
    _viewModel = AttendantChatDetailViewModel();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didSyncRouteSelection) {
      return;
    }

    final selectedClientId =
        ModalRoute.of(context)?.settings.arguments as String?;
    _viewModel.initialize(selectedClientId);
    _didSyncRouteSelection = true;
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
      backgroundColor: const Color(0xFFF8F4F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: const Color(0x12000000),
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return;
              }

              Navigator.pushReplacementNamed(context, AppRoutes.attendantChat);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Pallete.primaryRed,
            ),
          ),
        ),
        titleSpacing: 0,
        title: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final conversation = _viewModel.currentConversation;

            if (conversation == null) {
              return const SizedBox.shrink();
            }

            return Row(
              children: [
                _AvatarBadge(initials: conversation.client.initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatName(conversation.client.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202124),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${conversation.statusLabel} • ${conversation.orderCode}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B8B84),
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
              final canClose =
                  _viewModel.currentConversation != null &&
                  !_viewModel.isLoading &&
                  !_viewModel.isClosing;

              return IconButton(
                onPressed: canClose ? _confirmCloseAttendance : null,
                tooltip: 'Encerrar atendimento',
                icon: _viewModel.isClosing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Pallete.primaryRed,
                      ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final conversation = _viewModel.currentConversation;

          if (conversation == null) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _viewModel.errorMessage ??
                      'Nenhuma conversa disponivel no momento.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _viewModel.errorMessage!,
                    style: const TextStyle(
                      color: Pallete.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF8F4F1),
                        Color(0xFFF6F1EE),
                        Color(0xFFF3EEEA),
                      ],
                    ),
                  ),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      const Center(child: _DayPill(label: 'HOJE')),
                      const SizedBox(height: 24),
                      ...conversation.messages.map(
                        (message) => _MessageBlock(message: message),
                      ),
                      if (conversation.isClientTyping) ...[
                        const SizedBox(height: 6),
                        const _TypingIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              _Composer(
                controller: _viewModel.messageController,
                isEnabled: !_viewModel.isClosing,
                onSend: () => _viewModel.sendMessage(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _scrollToLatestMessage(List<AttendantChatMessage> messages) {
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

  String _formatName(String upperName) {
    return upperName
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Future<void> _confirmCloseAttendance() async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Encerrar atendimento?'),
          content: const Text(
            'A conversa sera finalizada, limpa da tela do atendente e o cliente recebera a mensagem de encerramento.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Encerrar'),
            ),
          ],
        );
      },
    );

    if (shouldClose != true || !mounted) {
      return;
    }

    final closed = await _viewModel.closeConversation();

    if (!mounted) {
      return;
    }

    if (!closed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.errorMessage ?? 'Nao foi possivel encerrar.',
            ),
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Atendimento encerrado.')));

    Navigator.pushReplacementNamed(context, AppRoutes.attendantChat);
  }
}

class _AvatarBadge extends StatelessWidget {
  final String initials;

  const _AvatarBadge({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF0E5DE),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF4C3B35),
              ),
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: const Color(0xFF41C86A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.8),
            ),
          ),
        ),
      ],
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
        color: const Color(0xFFF1E9E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9A8A82),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  final AttendantChatMessage message;

  const _MessageBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromAttendant = message.isFromAttendant;
    final bubbleColor = isFromAttendant ? Pallete.primaryRed : Colors.white;
    final textColor = isFromAttendant ? Colors.white : const Color(0xFF373737);
    final alignment = isFromAttendant
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Align(
            alignment: isFromAttendant
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 286),
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
                    bottomLeft: Radius.circular(isFromAttendant ? 18 : 6),
                    bottomRight: Radius.circular(isFromAttendant ? 6 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x14000000),
                      blurRadius: isFromAttendant ? 18 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: message.type == AttendantMessageType.attachment
                    ? _AttachmentContent(message: message)
                    : Text(
                        message.message ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          height: 1.45,
                          fontWeight: isFromAttendant
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
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
          ),
        ],
      ),
    );
  }
}

class _AttachmentContent extends StatelessWidget {
  final AttendantChatMessage message;

  const _AttachmentContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0EE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: Pallete.primaryRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.fileDetails ?? '',
                      style: const TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if ((message.message ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            message.message!,
            style: const TextStyle(
              color: Color(0xFF373737),
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 4),
      child: Row(
        children: [
          const Text(
            '...',
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 2,
              color: Color(0xFFC6B8B1),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Cliente digitando...',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF9A887F).withOpacity(0.92),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isEnabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F4F1),
          border: Border(top: BorderSide(color: Color(0xFFE7DDD8))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: isEnabled,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9D9D9D),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => isEnabled ? onSend() : null,
                      ),
                    ),
                    const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xFF6B5D56),
                    ),
                  ],
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
                    size: 28,
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
