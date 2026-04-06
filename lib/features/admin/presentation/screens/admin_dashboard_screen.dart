import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/admin/presentation/widgets/actionCard.dart';
import 'package:stackhive/features/admin/presentation/widgets/statCard.dart';
import 'package:stackhive/features/admin/provider/admin_stats_provider.dart';
import 'package:stackhive/features/auth/provider/auth_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final theme = Theme.of(context);

    return AdminLayout(
      title: 'Admin Dashboard',

      child: stats.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStatsProvider);
          },

          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              /// HEADER CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: .8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Text(
                        "Welcome back, Admin 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              /// STATS TITLE
              Text(
                "Platform Stats",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              /// STATS GRID
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                children: [
                  StatsCard(
                    title: "Users",
                    value: data.totalUsers,
                    icon: Icons.people,
                  ),
                  StatsCard(
                    title: "Questions",
                    value: data.totalQuestions,
                    icon: Icons.help_outline,
                  ),
                  StatsCard(
                    title: "Answers",
                    value: data.totalAnswers,
                    icon: Icons.question_answer_outlined,
                  ),
                  StatsCard(
                    title: "Tags",
                    value: data.totalTags,
                    icon: Icons.sell_outlined,
                  ),
                  StatsCard(
                    title: "Votes",
                    value: data.totalVotes,
                    icon: Icons.how_to_vote_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// MANAGEMENT TITLE
              Text(
                "Quick Access",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              /// ACTION CARDS
              ActionCard(
                title: "User Management",
                icon: Icons.manage_accounts_outlined,
                onTap: () => context.push('/admin/userManage'),
              ),

              ActionCard(
                title: "Tag Management",
                icon: Icons.local_offer_outlined,
                onTap: () => context.push('/admin/tagManage'),
              ),

              ActionCard(
                title: "Moderation",
                icon: Icons.shield_outlined,
                onTap: () => context.push('/admin/moderation'),
              ),

              ActionCard(
                title: "Analytics",
                icon: Icons.analytics_outlined,
                onTap: () => context.push('/admin/analytics'),
              ),

              ActionCard(
                title: "Reported Questions",
                icon: Icons.report_gmailerrorred_outlined,
                onTap: () => context.push('/admin/report'),
              ),

              ActionCard(
                title: "Logout",
                icon: Icons.logout,
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).logout();

                  ref.invalidate(adminStatsProvider);
                  ref.invalidate(currentUserProvider);

                  context.go('/login');
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text("Error: ${e.toString()}")),
      ),
    );
  }
}
