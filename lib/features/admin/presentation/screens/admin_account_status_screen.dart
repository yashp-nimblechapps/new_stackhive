import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/theme/app_colors.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class AdminAccountStatusScreen extends ConsumerWidget {
  const AdminAccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground, 
        elevation: 0,
        title: const Text(
          'Account Status',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            AppSnackBar.show(
              "Admin not found",
              type: SnackType.error,
            );
            return const Center(child: Text("Admin not found"));
          }

          final isBlocked = user.isBlocked;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [

                /// AVATAR
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// NAME
                Text(
                  user.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                /// STATUS BADGE
                _StatusBadge(),

                const SizedBox(height: 28),

                /// STATUS CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "You are an admin of the app. You can perform the following actions and access the following features.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                const SizedBox(height: 28),

                /// PERMISSIONS CARD
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [

                      _PermissionTile(
                        icon: Icons.login,
                        title: 'Login / Logout',
                        allowed: true,
                      ),

                      _PermissionTile(
                        icon: Icons.help_outline,
                        title: 'View Stats',
                        allowed: !isBlocked,
                      ),

                      _PermissionTile(
                        icon: Icons.question_answer_outlined,
                        title: 'User Management',
                        allowed: !isBlocked,
                      ),

                      _PermissionTile(
                        icon: Icons.thumb_up_alt_outlined,
                        title: 'Manage Moderation',
                        allowed: !isBlocked,
                      ),

                      _PermissionTile(
                        icon: Icons.thumb_up_alt_outlined,
                        title: 'View Analytics',
                        allowed: !isBlocked,
                      ),

                      _PermissionTile(
                        icon: Icons.thumb_up_alt_outlined,
                        title: 'Manage Reported Content',
                        allowed: !isBlocked,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: ${e.toString()}")),
      ),
    );
  }
}


class _StatusBadge extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    final color = Colors.orange;

    final text = "ADMIN";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// PERMISSION TILE
class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool allowed;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.allowed,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            color: allowed
                ? Colors.green
                : theme.colorScheme.error,
          )
        ],
      ),
    );
  }
}