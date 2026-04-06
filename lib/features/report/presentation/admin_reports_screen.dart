import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/report/provider/report_provider.dart';
import 'package:stackhive/models/report_model.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(reportsProvider);

    return AdminLayout(
      title: 'Reported Content',
      child: Column(
        children: [
          const SizedBox(height: 12),

          /// FILTER CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  /// ICON
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "Filter",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  /// DROPDOWN
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      borderRadius: BorderRadius.circular(16),
                      alignment: AlignmentGeometry.centerRight,
                      elevation: 6,
                      value: selectedFilter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text('Resolved'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// REPORT LIST
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = selectedFilter == 'all'
                    ? reports
                    : reports.where((r) => r.status == selectedFilter).toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Text(
                      "No reports found",
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReportCard(report: report),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final ReportModel report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPending = report.status == 'pending';
    final isResolved = report.status == 'resolved';

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              /// CONTENT TYPE ICON
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  report.contentType == 'question'
                      ? Icons.help_outline
                      : Icons.chat_bubble_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                report.contentType.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              /// STATUS BADGE
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withValues(alpha: .15)
                      : Colors.green.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.status.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPending ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// REASON
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "Reason ",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: report.reason),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// REPORTED BY
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "Reported by ",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: report.reportedByName),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// ACTIONS
          Row(
            children: [
              /// VIEW CONTENT
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (report.contentType == 'question') {
                      context.push('/admin/moderation/${report.contentId}');
                    } else {
                      if (report.parentId.isNotEmpty) {
                        context.push('/admin/moderation/${report.parentId}');
                      } else {
                        //print("Parent ID missing");
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "View Content",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),

              if (isPending) ...[
                const SizedBox(width: 12),

                /// MARK RESOLVED
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final confirm = await AppDialogs.confirm(
                        context,
                        icon: Icons.check_circle_outline,
                        title: "Mark as resolved?",
                        description:
                            "This report will be marked as resolved.",
                        confirmText: "Resolve",
                        confirmColor: theme.colorScheme.primary,
                      );

                      if (confirm == true) {
                        await ref
                            .read(reportControllerProvider.notifier)
                            .updateStatus(
                              reportId: report.id,
                              newStatus: 'resolved',
                            );
                            
                        AppSnackBar.show(
                          "Mark Resolved",
                          type: SnackType.info,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Mark Resolved",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );

    /// SWIPE TO DELETE (ONLY WHEN RESOLVED)
    if (!isResolved) return card;

    return Dismissible(
      key: ValueKey(report.id),
      direction: DismissDirection.startToEnd,

      confirmDismiss: (_) async {
        final confirm = await AppDialogs.confirm(
          context,
          icon: Icons.delete_outline,
          title: "Delete report?",
          description:
              "This will permanently remove the resolved report.",
          confirmText: "Delete",
          confirmColor: theme.colorScheme.error,
          destructive: true,
        );

        if (confirm == true) {
          await ref
              .read(reportControllerProvider.notifier)
              .deleteReport(report.id);
        }

        return confirm ?? false;
      },

      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 26,
        ),
      ),

      child: card,
    );
  }
}