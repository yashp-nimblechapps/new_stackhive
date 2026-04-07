import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/theme/app_colors.dart';
import 'package:stackhive/features/auth/provider/auth_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/profile/provider/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text("User not found"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                /// HEADER
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                            right: -20,
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

                          /// Branding (StackHive)
                          Positioned(
                            top: 110,
                            left: 150,
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

                          /// Welcome Text
                          Positioned(
                            top: 150,
                            left: 150,
                            child: Text(
                              "${greeting()}, ${user.name}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),

                          /// Settings Button (your original)
                          Positioned(
                            top: 50,
                            right: 20,
                            child: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.settings),
                                  onPressed: () {
                                    context.push('/settings');
                                  },
                                ),
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
                            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black, 
                            width: 2
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
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,                          
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
                      left: 25,
                      child: Text(user.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,)
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 100),


                if (user.isBlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Blocked by admin",
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                              

                /// ACTIVITY TITLE
                _SectionTitle('Activity'),

                /// STATS GRID
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: statsAsync.when(
                    data: (stats) => _StatsGrid(stats: stats),
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                  ),
                ),

                SizedBox(height: 24),

                /// CHART
                _SectionTitle('Chart'),
                SizedBox(height: 18),
                Text("See how you’ve contributed to the community", style: TextStyle(
                  color: Colors.grey, fontSize: 14,
                )),
                SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: statsAsync.when(
                    data: (stats) => _Chart(stats: stats),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(theme.colorScheme.primary, "Questions"),
                    _legendDot(theme.colorScheme.secondary, "Answers"),
                    _legendDot(Colors.orange, "Votes"),
                  ],
                ),

                const SizedBox(height: 30),

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
    final theme = Theme.of(context);
    final isAdmin = role == "admin";

    final color = isAdmin
        ? theme.colorScheme.secondary
        : Colors.green;

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

class _StatsGrid extends StatelessWidget {
  final dynamic stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final activityScore =
        (stats.questionCount * 5) +
        (stats.answerCount * 10) +
        (stats.totalVotes * 2);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _StatCard("Questions", stats.questionCount.toString(), Icons.help),

        _StatCard(
          "Answers",
          stats.answerCount.toString(),
          Icons.question_answer,
        ),

        _StatCard(
          "Votes",
          stats.totalVotes.toString(),
          Icons.thumb_up_alt_outlined,
        ),

        _StatCard(
          "Activity",
          activityScore.toString(),
          Icons.local_fire_department,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withValues(alpha: .05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 2),

          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final dynamic stats;

  const _Chart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("Q");
                    case 1:
                      return const Text("A");
                    case 2:
                      return const Text("V");
                  }
                  return const Text("");
                },
              ),
            ),
          ),

          barGroups: [

            _bar(0, stats.questionCount.toDouble(), theme.colorScheme.primary),
            _bar(1, stats.answerCount.toDouble(), theme.colorScheme.secondary),
            _bar(2, stats.totalVotes.toDouble(), Colors.orange),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
      ],
    );
  }
}

Widget _legendDot(Color color, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12,color: Colors.grey)),
      ],
    ),
  );
}
