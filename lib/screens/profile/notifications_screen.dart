import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/models/notification_model.dart';
import 'package:empleame/providers/providers.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final _notificationsStreamProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final userAsync = ref.watch(currentUserStreamProvider);
  final uid = userAsync.valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(notificationRepositoryProvider).watchNotifications(uid);
});

// ── Screen ──────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(_notificationsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: notifAsync.whenOrNull(
              data: (notifs) {
                final hasUnread = notifs.any((n) => !n.isRead);
                if (!hasUnread) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () => _markAllAsRead(ref),
                  child: const Text(
                    'Leídas',
                    style: TextStyle(
                      color: Color(0xFF7210FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationCard(
                notif: notif,
                onTap: () => _onNotifTap(context, ref, notif),
              );
            },
          );
        },
      ),
    );
  }

  void _onNotifTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notif,
  ) {
    // Mark as read
    final uid = ref.read(currentUserStreamProvider).valueOrNull?.uid;
    if (uid != null && !notif.isRead) {
      ref.read(notificationRepositoryProvider).markAsRead(uid, notif.id);
    }
    // Navigate to the related service if serviceId is present
    if (notif.serviceId != null && notif.serviceId!.isNotEmpty) {
      context.push('/service-detail/${notif.serviceId}');
    }
  }

  void _markAllAsRead(WidgetRef ref) {
    final uid = ref.read(currentUserStreamProvider).valueOrNull?.uid;
    if (uid != null) {
      ref.read(notificationRepositoryProvider).markAllAsRead(uid);
    }
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotificationCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isService = notif.serviceId != null;
    final iconBg = notif.title.contains('Aprobado')
        ? const Color(0xFF34D399)
        : notif.title.contains('Rechazado')
            ? const Color(0xFFFB7185)
            : const Color(0xFF7210FF);
    final icon = notif.title.contains('Aprobado')
        ? Icons.check_circle_outline
        : notif.title.contains('Rechazado')
            ? Icons.cancel_outlined
            : Icons.notifications_outlined;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF3EEFF),
          borderRadius: BorderRadius.circular(20),
          border: notif.isRead
              ? null
              : Border.all(color: const Color(0xFF7210FF).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7210FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (isService) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Ver servicio →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7210FF).withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 36,
              color: Color(0xFF7210FF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando cambie el estado de tus servicios\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
