import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/features/notifications/presentation/notification_disabled_screen.dart';
import 'package:stackhive/features/notifications/presentation/widgets/menu_item.dart';
import 'package:stackhive/features/notifications/provider/notification_provider.dart';
import 'package:stackhive/features/notifications/provider/notification_settings_provider.dart';
import 'package:stackhive/features/notifications/utils/quiet_hours_helper.dart';
import 'package:stackhive/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibration/vibration.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  int _lastCount = 0;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.listenManual<AsyncValue<List<NotificationModel>>>(
        notificationsStreamProvider,
        (previous, next) async {
          next.whenData((notifications) async {
            if (notifications.length > _lastCount) {
              final user = ref.read(authStateProvider).value;

              if (user == null) return;

              final settings = await ref
                  .read(notificationSettingsRepositoryProvider)
                  .getSettings(user.uid);

              if (!isQuietHours(settings)) {
                // VIBRATION
                if (settings.vibration) {
                  final hasVibrator = await Vibration.hasVibrator();

                  if (hasVibrator) {
                    Vibration.vibrate(duration: 200);
                  }
                }

                // SOUND
                if (settings.sound) {
                  await _player.play(AssetSource('sounds/notification.mp3'));
                }
              }
            }
            _lastCount = notifications.length;
          });
        },
      );
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_answer':
        return Icons.question_answer;
      case 'vote':
        return Icons.thumb_up;
      case 'best_answer':
        return Icons.workspace_premium;
      default:
        return Icons.notifications;
    }
  }

  String _getTitle(NotificationModel notification) {
    switch (notification.type) {
      case 'new_answer':
        return '${notification.senderName} answered your question';

      case 'vote':
        if (notification.voteType == 'upvote') {
          return '${notification.senderName} upvoted on your answer';
        } else {
          return '${notification.senderName} downvoted on your answer';
        }
      case 'best_answer':
        return 'Your answer was marked as Best 🎉';
      default:
        return 'New notification';
    }
  }

  String? _getPreview(NotificationModel notification) {
    if (notification.previewText == null) return null;

    if (notification.previewText!.length > 100) {
      return '${notification.previewText!.substring(0, 100)}...';
    }

    return notification.previewText;
  }

  Map<String, List<NotificationModel>> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    final Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final notification in notifications) {
      final date = notification.createdAt;
      final notificationDay = DateTime(date.year, date.month, date.day);

      if (notificationDay == today) {
        grouped['Today']!.add(notification);
      } else if (notificationDay == yesterday) {
        grouped['Yesterday']!.add(notification);
      } else {
        grouped['Earlier']!.add(notification);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) async {
              final user = ref.read(authStateProvider).value;

              if (value == 'mark_all') {
                if (user != null) {
                  final user = ref.read(authStateProvider).value;
                  if (user == null) return;

                  final confirm = await AppDialogs.confirm(
                    context,
                    icon: Icons.done_all,
                    title: 'Mark all as read?',
                    description: 'This will mark every notification as read.',
                    confirmText: 'Confirm',
                    confirmColor: theme.colorScheme.primary,
                  );

                  if (confirm == true) {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markAllRead(user.uid);
                  }
                }
              }

              if (value == 'settings') {
                context.push('/notificationSettings');
              }
            },

            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                height: 44,
                child: MenuItem(
                  icon: Icons.done_all_rounded,
                  label: 'Mark all as read',
                ),
              ),

              PopupMenuItem(
                value: 'settings',
                height: 44,
                child: MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Notification settings',
                ),
              ),
            ],
          ),
        ],
      ),

      body: settingsAsync.when(
        data: (settings) {
          // If notifications disabled
          if (!settings.pushEnabled) {
            return NotificationDisabledScreen();
          }

          // Otherwise show notifications
          return notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications yet',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              final grouped = _groupNotifications(notifications);

              return ListView(
                padding: EdgeInsets.only(bottom: 20),
                children: grouped.entries.expand((entry) {
                  final sectionTitle = entry.key;
                  final sectionNotifications = entry.value;

                  if (sectionNotifications.isEmpty) return <Widget>[];

                  return <Widget>[
                    _SectionHeader(title: sectionTitle),

                    ...sectionNotifications.map((notification) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Dismissible(
                          key: ValueKey(notification.id),
                          onDismissed: (_) async {
                            await ref
                                .read(notificationRepositoryProvider)
                                .deleteNotification(
                                  userId: notification.receiverId,
                                  notificationId: notification.id,
                                );
                          },
                          child: _NotificationCard(
                            icon: _getIcon(notification.type),
                            title: _getTitle(notification),
                            preview: _getPreview(notification),
                            time: timeago.format(notification.createdAt),
                            isRead: notification.isRead,
                            onTap: () async {
                              final repo = ref.read(
                                notificationRepositoryProvider,
                              );

                              await repo.markAsRead(
                                userId: notification.receiverId,
                                notificationId: notification.id,
                              );

                              context.push(
                                '/detailQues/${notification.questionId}',
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ];
                }).toList(),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: .7),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? preview;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.isRead,
    required this.onTap,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isRead
          ? theme.colorScheme.surface
          : theme.colorScheme.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /// ICON CONTAINER
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary),
              ),

              const SizedBox(width: 14),

              /// TEXT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // PREVIEW
                    if (preview != null) ...[
                      SizedBox(height: 6),
                      Text(
                        preview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: .8,
                          ),
                        ),
                      ),
                    ],

                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// UNREAD DOT
              if (!isRead)
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
