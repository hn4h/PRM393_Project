import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/image_helper.dart';
import '../models/cs_chat_models.dart';
import '../repository/cs_chat_repository.dart';
import 'cs_chat_room_screen.dart';

class CsChatInboxScreen extends ConsumerStatefulWidget {
  const CsChatInboxScreen({super.key});

  @override
  ConsumerState<CsChatInboxScreen> createState() => _CsChatInboxScreenState();
}

class _CsChatInboxScreenState extends ConsumerState<CsChatInboxScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  RealtimeChannel? _inboxChannel;
  Timer? _refreshDebounce;
  int _refreshSeed = 0;

  @override
  void initState() {
    super.initState();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    if (customerId == null) return;

    _inboxChannel = Supabase.instance.client
        .channel('cs-chat-inbox-$customerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.chatConversations,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (_) {
            if (!mounted) return;
            _scheduleRefresh();
          },
        )
        .subscribe();
  }

  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _refreshSeed++);
    });
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    if (_inboxChannel != null) {
      Supabase.instance.client.removeChannel(_inboxChannel!);
    }
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() => _refreshSeed++),
              decoration: InputDecoration(
                hintText: 'Search worker',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _refreshSeed++);
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<CsChatConversationItem>>(
        key: ValueKey('cs-chat-inbox-$_refreshSeed-${_searchCtrl.text.trim()}'),
        future: ref
            .read(csChatRepositoryProvider)
            .fetchInbox(query: _searchCtrl.text),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _StateView(
              icon: Icons.error_outline,
              title: 'Unable to load messages',
              subtitle: snapshot.error.toString(),
              onTap: () => setState(() => _refreshSeed++),
              actionLabel: 'Retry',
            );
          }

          final items = snapshot.data ?? const <CsChatConversationItem>[];
          if (items.isEmpty) {
            return _StateView(
              icon: Icons.forum_outlined,
              title: 'No conversations yet',
              subtitle:
                  'Chat will appear here after a worker accepts your booking.',
              onTap: () => setState(() => _refreshSeed++),
              actionLabel: 'Refresh',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _refreshSeed++),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CsChatRoomScreen(
                          conversationId: item.conversationId,
                        ),
                      ),
                    );

                    if (!mounted) return;
                    setState(() => _refreshSeed++);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: scheme.surface,
                          child: ClipOval(
                            child: (item.workerAvatarUrl ?? '').isNotEmpty
                                ? ImageHelper.loadNetworkImage(
                                    imageUrl: item.workerAvatarUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorWidget: Icon(
                                      Icons.person,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: scheme.onSurfaceVariant,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.workerName,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.serviceTag,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.lastMessagePreview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body2.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              csChatTimeLabel(item.lastMessageAtUtc7),
                              style: AppTextStyles.caption.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (item.unreadCount > 0)
                              Container(
                                constraints: const BoxConstraints(minWidth: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(999),
                                  ),
                                ),
                                child: Text(
                                  item.unreadCount > 99
                                      ? '99+'
                                      : '${item.unreadCount}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _StateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: scheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.headline3),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
