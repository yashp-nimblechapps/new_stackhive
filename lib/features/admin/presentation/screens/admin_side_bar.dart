import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/features/admin/presentation/widgets/admin_sidebar_item.dart';
import 'package:stackhive/features/auth/provider/auth_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();
    final user = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [

          /// TOP HEADER
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: SafeArea(
              bottom: false,
              child: InkWell(
                onTap: () => context.push('/admin/adminProfile'),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    /// AVATAR
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                        child: Text(
                          user.value?.name.isNotEmpty == true
                              ? user.value!.name[0].toUpperCase()
                              : "U",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// USER NAME
                          Text(
                            user.value?.name ?? "Admin",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                      
                          SizedBox(height: 4),
                      
                          /// ROLE
                          Text(
                            "Administrator",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: .8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// NAVIGATION
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [

                for (final item in adminNavItems)
                  AdminSidebarItem(
                    item: item,
                    isActive: location == item.route,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(item.route);
                    },
                  ),

                const SizedBox(height: 12),

                Divider(
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
              ],
            ),
          ),

          /// LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: .3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}