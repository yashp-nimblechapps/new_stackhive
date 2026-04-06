import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/auth/provider/auth_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.role == 'admin';

    final content = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionTitle(context, "Your account"),

        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.person_outline,
              title: "Account Details",
              onTap: () => context.push('/accDetail'),
            ),
            _SettingsTile(
              icon: Icons.verified_user_outlined,
              title: "Account Status",
              onTap: () {
                if (isAdmin) {
                  context.go('/admin/adminAccStatus');
                } else {
                  context.push('/accStatus');
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle(context, "Appearance"),

        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark / Light mode",
              onTap: () => context.push('/theme'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle(context, "App Settings"),

        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              onTap: () => context.push('/notificationSettings'),
            ),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: "App Language",
              onTap: () => _showLanguageBottomSheet(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle(context, "More Info"),

        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: "About App",
              onTap: () => context.push('/aboutApp'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () => context.push('/privacy'),
            ),
            _SettingsTile(
              icon: Icons.support_agent_outlined,
              title: "Help & Support",
              onTap: () => context.push('/helpsupport'),
            ),
          ],
        ),

        const SizedBox(height: 40),

        _LogoutButton(ref: ref),
      ],
    );

    // ADMIN LAYOUT
    if (isAdmin) {
      return AdminLayout(title: 'Settings', child: content);
    }

    // NORMAL USER
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: content,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: Theme.of(
            context,
          ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              SizedBox(height: 20),

              // header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'App Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // subtitle
              Text(
                'Select the language you want to use in StackHive.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 25),

              // language tile
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // selected indicatore
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    ),

                    SizedBox(width: 16),
                    Text(
                      'English',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Spacer(),
                    Text(
                      'Default',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // note
              Text(
                "Currently StackHive is available only in English. "
                "More languages will be supported in future updates.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;

  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: .3)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.logout),
      label: const Text(
        "Log Out",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: () async {
        await ref.read(authControllerProvider.notifier).logout();
        context.go('/login');
      },
    );
  }
}
