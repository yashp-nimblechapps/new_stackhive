import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/admin/provider/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analytics = ref.watch(analyticsProvider);

    return AdminLayout(
      title: 'Analytics Dashboard',
      child: analytics.when(
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------------------------
                /// SOME STATS
                /// -------------------------
                Text(
                  "Some Stats",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                /// MOST USED TAG
                Text("Most Used Tag", style: theme.textTheme.bodySmall),

                const SizedBox(height: 8),

                _AnalyticsCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.tag,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        data.topTag?.name ?? "N/A",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// MOST VOTED QUESTION
                Text("Most Voted Question", style: theme.textTheme.bodySmall),

                const SizedBox(height: 8),

                _AnalyticsCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.question_answer_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          data.topQuestion?.title ?? "N/A",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// MOST CONTRIBUTOR
                Text("Most Contributor", style: theme.textTheme.bodySmall),

                const SizedBox(height: 8),

                _AnalyticsCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.emoji_events_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        data.topContributor?.name ?? "N/A",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// -------------------------
                /// SOME CHARTS
                /// -------------------------
                Text(
                  "Some Charts",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 24),

                /// =========================================================
                /// (i) ACTIVITY CHART
                /// =========================================================
                Text(
                  "Activity Chart",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Shows total questions, answers and votes on the platform",
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 16),

                /// STATS
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Questions",
                        value: data.totalQuestions.toString(),
                        icon: Icons.help_outline,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCard(
                        title: "Answers",
                        value: data.totalAnswers.toString(),
                        icon: Icons.chat_bubble_outline,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCard(
                        title: "Votes",
                        value: data.totalVotes.toString(),
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// BAR CHART
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            [
                              data.totalQuestions,
                              data.totalAnswers,
                              data.totalVotes,
                            ].reduce((a, b) => a > b ? a : b).toDouble() +
                            2,
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: theme.colorScheme.outlineVariant,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return Text(
                                      "Questions",
                                      style: theme.textTheme.bodySmall,
                                    );
                                  case 1:
                                    return Text(
                                      "Answers",
                                      style: theme.textTheme.bodySmall,
                                    );
                                  case 2:
                                    return Text(
                                      "Votes",
                                      style: theme.textTheme.bodySmall,
                                    );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: data.totalQuestions.toDouble(),
                                width: 16,
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: data.totalAnswers.toDouble(),
                                width: 16,
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: data.totalVotes.toDouble(),
                                width: 16,
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// =========================================================
                /// (ii) GROWTH OVERVIEW
                /// =========================================================
                Text(
                  "Growth Overview",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Questions per day and answers per day growth",
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: theme.colorScheme.outlineVariant,
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                      
                            titlesData: FlTitlesData(
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = [
                                      "M",
                                      "T",
                                      "W",
                                      "T",
                                      "F",
                                      "S",
                                      "S",
                                    ];
                                    if (value.toInt() < days.length) {
                                      return Text(
                                        days[value.toInt()],
                                        style: theme.textTheme.bodySmall,
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),
                      
                            lineBarsData: [
                              /// QUESTIONS LINE
                              LineChartBarData(
                                spots: List.generate(
                                  data.questionsPerDay.isEmpty
                                      ? 7
                                      : data.questionsPerDay.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    data.questionsPerDay.isEmpty
                                        ? 0
                                        : data.questionsPerDay[index].toDouble(),
                                  ),
                                ),
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                      
                              /// ANSWERS LINE
                              LineChartBarData(
                                spots: List.generate(
                                  data.answersPerDay.isEmpty
                                      ? 7
                                      : data.answersPerDay.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    data.answersPerDay.isEmpty
                                        ? 0
                                        : data.answersPerDay[index].toDouble(),
                                  ),
                                ),
                                isCurved: true,
                                color: theme.colorScheme.secondary,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ), 
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),               
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        /// QUESTIONS LEGEND
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 3,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Questions",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        /// ANSWERS LEGEND
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 3,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Answers",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ],
                  ),

                ),
                

                const SizedBox(height: 28),

                /// =========================================================
                /// (iii) TAG DISTRIBUTION
                /// =========================================================
                Text(
                  "Tag Distribution Pie Chart",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Distribution of questions by tags",
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: data.tagDistribution.map((tag) {
                              final value = (tag.usageCount).toDouble();

                              return PieChartSectionData(
                                value: value,
                                title: tag.name,
                                radius: 60,
                                titleStyle: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                color: theme.colorScheme.primary
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// TAG LEGEND
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: data.tagDistribution.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: .08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// =========================================================
                /// (iv) CONTRIBUTOR LEADERBOARD
                /// =========================================================
                Text(
                  "Contributor Leaderboard",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Top contributors on the platform",
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: data.topContributors.isEmpty
                      ? Center(
                          child: Text(
                            "No contributors yet",
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      : Column(
                          children: List.generate(data.topContributors.length, (
                            index,
                          ) {
                            final user = data.topContributors[index];

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == data.topContributors.length - 1
                                    ? 0
                                    : 12,
                              ),
                              child: _ContributorRow(
                                rank: index + 1,
                                name: user.name,
                              ),
                            );
                          }),
                        ),
                ),
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

class _AnalyticsCard extends StatelessWidget {
  final Widget child;

  const _AnalyticsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ContributorRow extends StatelessWidget {
  final int rank;
  final String name;

  const _ContributorRow({required this.rank, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            name[0].toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "#$rank",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
