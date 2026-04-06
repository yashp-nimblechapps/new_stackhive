import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/features/notifications/provider/notification_provider.dart';
import 'package:stackhive/features/notifications/provider/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Notifications Settings')),
      body: settingsAsync.when(
        data: (settings) {
          final updateSettings = ref.read(updateNotificationSettingsProvider);

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 2),
            children: [

              // GENERAL
              _SectionHeader(title: "General"),
              _SettingsSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                value: settings.pushEnabled,
                onChanged: (value) async {
                  final updated = settings.copyWith(pushEnabled: value);
                  await updateSettings(updated);
                },
              ),

              /*
                  _SettingsSwitchTile(
                    title: 'Email Notifications',
                    value: settings.emailEnabled,
                    onChanged: (value) async {
                      final updated = settings.copyWith(emailEnabled: value);
                      await updateSettings(updated);
                    },
                  ),
              */

              _SettingsSwitchTile(
                icon: Icons.volume_up_outlined,
                title: 'Sound',
                value: settings.sound,
                onChanged: (value) async {
                  final updated = settings.copyWith(sound: value);
                  await updateSettings(updated);
                },
              ),

              _SettingsSwitchTile(
                icon: Icons.vibration,
                title: 'Vibration',
                value: settings.vibration,
                onChanged: (value) async {
                  final updated = settings.copyWith(vibration: value);
                  await updateSettings(updated);
                },
              ),
              SizedBox(height: 8),

              Divider(color: Colors.grey.shade400, height: 3, thickness: 3),

              // ACTIVITY
              _SectionHeader(title: "Activity"),
              _SettingsSwitchTile(
                icon: Icons.forum_outlined,
                title: 'New answers on my question',
                value: settings.newAnswers,
                onChanged: (value) async {
                  final updated = settings.copyWith(newAnswers: value);
                  await updateSettings(updated);
                },
              ),

              _SettingsSwitchTile(
                icon: Icons.thumb_up_outlined,
                title: 'Votes on my answers',
                value: settings.votes,
                onChanged: (value) async {
                  final updated = settings.copyWith(votes: value);
                  await updateSettings(updated);
                },
              ),

              _SettingsSwitchTile(
                icon: Icons.star_outline,
                title: 'Best answer selected',
                value: settings.bestAnswer,
                onChanged: (value) async {
                  final updated = settings.copyWith(bestAnswer: value);
                  await updateSettings(updated);
                },
              ),
              SizedBox(height: 8),

              Divider(color: Colors.grey.shade400, height: 3, thickness: 3),
              
              // QUIET HOURS
              _SectionHeader(title: "Quiet hours"),
              _SettingsSwitchTile(
                icon: Icons.do_not_disturb_on_outlined,
                title: 'Do Not Disturb',
                value: settings.quietHoursEnabled,
                onChanged: (value) async {
                  final updated = settings.copyWith(quietHoursEnabled: value);
                  await updateSettings(updated);
                },
              ),
              SizedBox(height: 8),

              Divider(color: Colors.grey.shade400, height: 3, thickness: 3),

              // MANAGEMENT
              _SectionHeader(title: "Notification management"),
              SizedBox(height: 2),
              _ActionTile(
                icon: Icons.done_all,
                title: 'Mark all as read',
                onTap: () async {
                  final user = ref.read(authStateProvider).value;
                  if (user == null) return;

                  final confirm = await AppDialogs.confirm(
                    context,
                    icon: Icons.done_all,
                    title: 'Mark all as read?',
                    description: 'This will mark every notification as read.',
                    confirmText: 'Confirm',
                    confirmColor: Theme.of(context).colorScheme.primary,
                  );

                  if (confirm == true) {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markAllRead(user.uid);

                      AppSnackBar.show(
                        "Mark All Read",
                      type: SnackType.info,
                    );
                  }
                },
              ),
              SizedBox(height: 10),

              _ActionTile(
                icon: Icons.delete_outline,
                title: 'Clear all notifications',
                destructive: true,
                onTap: () async {
                  final user = ref.read(authStateProvider).value;
                  if (user == null) return;

                  final confirm = await AppDialogs.confirm(
                    context,
                    icon: Icons.warning_amber_rounded,
                    title: 'Delete all notifications?',
                    description: 'This action cannot be undone.',
                    confirmText: 'Delete',
                    confirmColor: Theme.of(context).colorScheme.primary,
                    destructive: true,
                  );

                  if (confirm == true) {
                    await ref
                        .read(notificationRepositoryProvider)
                        .clearAllNotifications(user.uid);

                    AppSnackBar.show(
                        "All Notifications Cleared",
                      type: SnackType.info,
                    );
                  }
                },
              ),
            ],
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
      padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: .7),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      visualDensity: VisualDensity(vertical: 1.5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,color: Theme.of(context).colorScheme.primary,size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      dense: true,
      visualDensity: VisualDensity(vertical: -2),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary,size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15,)),
      onTap: onTap,
    );
  }
}
