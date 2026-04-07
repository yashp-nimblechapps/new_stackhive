import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/theme/app_colors.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_side_bar.dart';
import 'package:stackhive/features/auth/provider/auth_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AdminSidebar(),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text("Admin not found"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                /// HEADER
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// 🎨 HEADER BACKGROUND
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          /// Decorative Blob (Top Right)
                          Positioned(
                            top: -40,
                            right: -30,
                            child: Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          /// Decorative Blob (Bottom Left)
                          Positioned(
                            bottom: -50,
                            left: -30,
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          /// MENU BUTTON (ONLY BUTTON IN HEADER)
                          Positioned(
                            top: 30,
                            left: 10,
                            child: Builder(
                              builder: (context) {
                                return IconButton(
                                  icon: const Icon(Icons.menu),
                                  iconSize: 30,
                                  color: Colors.white,
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                );
                              },
                            ),
                          ),

                          /// BRANDING (CENTERED)
                          Positioned(
                            top: 100,
                            left: 40,
                            right: 0,
                            child: Center(
                              child: Text(
                                "StackHive",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          /// WELCOME TEXT
                          Positioned(
                            top: 140,
                            left: 150,
                            child: Text(
                              "${greeting()}, ${user.name}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// AVATAR
                    Positioned(
                      bottom: -50,
                      left: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.surfaceContainer,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ROLE BADGE
                    Positioned(
                      bottom: -50,
                      right: 15,
                      child: RoleBadge(role: user.role),
                    ),

                    // NAME
                    Positioned(
                      bottom: -82,
                      left: 30,
                      child: Text(
                        user.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 120),

                _SectionTitle('Admin Capabilities'),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _CapabilityCard(
                        icon: Icons.security_outlined,
                        title: "Maintain Platform",
                        description:
                            "Ensure content quality and enforce community standards.",
                      ),
                      const SizedBox(height: 12),

                      _CapabilityCard(
                        icon: Icons.flag_outlined,
                        title: "Moderate Content",
                        description:
                            "Review reported questions and answers to keep the platform healthy.",
                      ),
                      const SizedBox(height: 12),

                      _CapabilityCard(
                        icon: Icons.people_outline,
                        title: "Manage Users",
                        description:
                            "Monitor users and take action if platform guidelines are violated.",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                _SectionTitle('Quick Actions'),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _QuickActionTile(
                        icon: Icons.dashboard_outlined,
                        title: "Admin Dashboard",
                        onTap: () {
                          context.push('/admin/dashboard');
                        },
                      ),
                      const SizedBox(height: 12),

                      _QuickActionTile(
                        icon: Icons.people_outline,
                        title: "Manage Users",
                        onTap: () {
                          context.push('/admin/users');
                        },
                      ),
                      const SizedBox(height: 12),

                      _QuickActionTile(
                        icon: Icons.flag_outlined,
                        title: "Review Reports",
                        onTap: () {
                          context.push('/admin/reports');
                        },
                      ),
                      const SizedBox(height: 12),

                      _QuickActionTile(
                        icon: Icons.analytics_outlined,
                        title: "Analytics",
                        onTap: () {
                          context.push('/admin/analytics');
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                /// PROFILE DETAILS BUTTON
                _SectionTitle('Other Options'),
                SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        context.push('/accDetail');
                      },
                      child: Text(
                        'Profile Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// LOGOUT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

/// SECTION TITLE
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CapabilityCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionTile({
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            /// ICON CONTAINER
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: theme.colorScheme.primary),
            ),

            const SizedBox(width: 12),

            Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),

            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
