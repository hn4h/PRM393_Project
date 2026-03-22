import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/cs_chat_models.dart';
import '../repository/cs_chat_repository.dart';

class CsChatRoomScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const CsChatRoomScreen({super.key, required this.conversationId});

  @override
  ConsumerState<CsChatRoomScreen> createState() => _CsChatRoomScreenState();
}

class _CsChatRoomScreenState extends ConsumerState<CsChatRoomScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker _picker = ImagePicker();

  RealtimeChannel? _messagesChannel;
  Timer? _reloadDebounce;
  bool _loading = true;
  bool _sending = false;

  CsChatBookingContext? _context;
  List<CsChatMessage> _messages = const [];
  Uint8List? _pendingImageBytes;
  String? _pendingImageExt;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _messagesChannel = Supabase.instance.client
        .channel('cs-chat-room-${widget.conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.chatMessages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: widget.conversationId,
          ),
          callback: (_) {
            if (!mounted) return;
            _scheduleSilentReload();
          },
        )
        .subscribe();
  }

  void _scheduleSilentReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _reloadDebounce?.cancel();
    if (_messagesChannel != null) {
      Supabase.instance.client.removeChannel(_messagesChannel!);
    }
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() => _loading = true);
      }

      final repo = ref.read(csChatRepositoryProvider);
      final ctx = await repo.fetchBookingContextByConversation(
        widget.conversationId,
      );
      final messages = await repo.fetchMessages(widget.conversationId);
      await repo.markConversationReadByCustomer(widget.conversationId);

      if (!mounted) return;
      setState(() {
        _context = ctx;
        _messages = messages;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_loading || _context == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final contextData = _context!;
    final canSend =
        !contextData.isClosed &&
        (_messageCtrl.text.trim().isNotEmpty || _pendingImageBytes != null);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.surface,
              child: Icon(
                Icons.engineering,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                contextData.workerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Booking details',
            onPressed: _showBookingQuickDetails,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(),
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final prev = index == 0 ? null : _messages[index - 1];

                  final showTimeDivider =
                      prev == null ||
                      message.createdAtUtc7
                              .difference(prev.createdAtUtc7)
                              .inMinutes
                              .abs() >=
                          45 ||
                      message.createdAtUtc7.day != prev.createdAtUtc7.day;

                  return Column(
                    children: [
                      if (showTimeDivider)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '${csChatRelativeDateLabel(message.createdAtUtc7)}, ${csChatTimeLabel(message.createdAtUtc7)}',
                            style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (message.isSystem)
                        _SystemMessageBubble(text: message.text)
                      else
                        _MessageBubble(
                          message: message,
                          onOpenImage: (url) => _openImageFullScreen(url),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (contextData.isClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: AppColors.warning.withValues(alpha: 0.12),
              child: Text(
                'Conversation ended because this booking is completed or cancelled.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            _InputBar(
              controller: _messageCtrl,
              canSend: canSend && !_sending,
              hasPendingImage: _pendingImageBytes != null,
              onRemoveImage: () => setState(() {
                _pendingImageBytes = null;
                _pendingImageExt = null;
              }),
              onChanged: () => setState(() {}),
              onAttach: _pickAttachment,
              onSend: _send,
            ),
        ],
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final segments = file.name.split('.');
    final ext = segments.length > 1 ? segments.last.toLowerCase() : 'jpg';

    if (!mounted) return;
    setState(() {
      _pendingImageBytes = bytes;
      _pendingImageExt = ext;
    });
  }

  Future<void> _send() async {
    final contextData = _context;
    if (contextData == null || contextData.isClosed || _sending) return;

    final text = _messageCtrl.text.trim();
    if (text.isEmpty && _pendingImageBytes == null) return;

    setState(() => _sending = true);
    try {
      final repo = ref.read(csChatRepositoryProvider);
      if (_pendingImageBytes != null) {
        await repo.sendImageMessage(
          conversationId: widget.conversationId,
          bookingId: contextData.bookingId,
          bytes: _pendingImageBytes!,
          extension: _pendingImageExt ?? 'jpg',
        );
      }

      if (text.isNotEmpty) {
        await repo.sendTextMessage(
          conversationId: widget.conversationId,
          bookingId: contextData.bookingId,
          text: text,
        );
      }

      _messageCtrl.clear();
      _pendingImageBytes = null;
      _pendingImageExt = null;
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $e')));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _showBookingQuickDetails() {
    final contextData = _context;
    if (contextData == null) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Details', style: AppTextStyles.headline3),
                const SizedBox(height: 12),
                Text('Service: ${contextData.serviceName}'),
                const SizedBox(height: 6),
                Text('Worker: ${contextData.workerName}'),
                const SizedBox(height: 6),
                Text(
                  'Date: ${csChatRelativeDateLabel(contextData.scheduledAtUtc7)}, ${csChatTimeLabel(contextData.scheduledAtUtc7)}',
                ),
                const SizedBox(height: 6),
                Text('Address: ${contextData.address}'),
                const SizedBox(height: 6),
                Text(
                  'Status: ${contextData.status}',
                  style: AppTextStyles.body2.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openImageFullScreen(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.7,
              maxScale: 4.0,
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final CsChatMessage message;
  final void Function(String imageUrl) onOpenImage;

  const _MessageBubble({required this.message, required this.onOpenImage});

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isFromCustomer;
    final scheme = Theme.of(context).colorScheme;

    final bgColor = isCustomer ? AppColors.primary : scheme.surface;
    final textColor = isCustomer ? Colors.white : scheme.onSurface;
    final align = isCustomer ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: isCustomer
                ? null
                : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.type == CsChatMessageType.image &&
                  (message.imageUrl ?? '').isNotEmpty)
                InkWell(
                  onTap: () => onOpenImage(message.imageUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message.imageUrl!,
                      width: 220,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (message.type == CsChatMessageType.image &&
                  message.text.isEmpty)
                const SizedBox(height: 0)
              else
                Text(
                  message.text,
                  style: AppTextStyles.body2.copyWith(color: textColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final String text;

  const _SystemMessageBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final bool hasPendingImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onChanged;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.canSend,
    required this.hasPendingImage,
    required this.onRemoveImage,
    required this.onChanged,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Column(
        children: [
          if (hasPendingImage)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: InputChip(
                  label: const Text('1 image attached'),
                  onDeleted: onRemoveImage,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Attach image',
                onPressed: onAttach,
                icon: const Icon(Icons.attach_file),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: null,
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: canSend ? onSend : null,
                icon: Icon(
                  Icons.send,
                  color: canSend ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
