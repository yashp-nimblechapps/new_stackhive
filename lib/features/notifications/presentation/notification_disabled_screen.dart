import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/notifications/provider/notification_settings_provider.dart';

class NotificationDisabledScreen extends ConsumerWidget {
  const NotificationDisabledScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setttingsAsync = ref.watch(notificationSettingsProvider);

    return setttingsAsync.when(
      data: (settings) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 20),

                Text(
                  'Notifications Disabled',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Text(
                  'You have disabled notifications.\nEnable them to receive updates.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    final updateSettings = ref.read(
                      updateNotificationSettingsProvider,
                    );

                    final newSettings = settings.copyWith(pushEnabled: true);
                    await updateSettings(newSettings);
                    AppSnackBar.show(
                      "Notifications enabled",
                      type: SnackType.info,
                    );

                  },
                  child: Text('Enable Notifications'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
