import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/presentation/widget/edit_question_screen.dart';
import 'package:stackhive/features/question/presentation/widget/showReportBottomSheet.dart';
import 'package:stackhive/features/question/presentation/widget/showUserInfoSheet.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';
import 'package:stackhive/features/saved/provider/saved_provider.dart';
import 'package:stackhive/features/tag/provider/selected_tag_provider.dart';
import 'package:stackhive/models/question_model.dart';

void showQuesActions(
  BuildContext context,
  WidgetRef ref,
  QuestionModel question,
) {
  final currentUser = ref.read(currentUserProvider).value;
  final isQuestionOwner = currentUser?.id == question.userId;
  final isBlocked = currentUser?.isBlocked ?? false;

  final savedAsync = ref.watch(savedQuestionsProvider);
  final savedIds = savedAsync.value ?? [];

  final isSaved = savedIds.contains(question.id);

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          // WATCH QUESTION AGAIN
          final questionAsync = ref.watch(questionDetailProvider(question.id));

          return questionAsync.when(
            loading: () => Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),

            error: (e, _) =>
                Padding(padding: EdgeInsets.all(30), child: Text("Error $e")),

            data: (q) {
              if (q == null) return SizedBox();

              final theme = Theme.of(context);

              final voteAsync = ref.watch(
                questionUserVoteProvider((
                  questionId: q.id,
                  userId: currentUser!.id,
                )),
              );

              final userVote = voteAsync.value;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // VOTING SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // UPVOTE
                            Column(
                              children: [
                                _voteCircle(
                                  context: context,
                                  icon: Icons.arrow_upward,
                                  enabled: !isBlocked,
                                  selected: userVote == 1,
                                  onTap: () async {
                                    int newVote;

                                    if (userVote == 1) {
                                      newVote = 0; // remove vote
                                    } else {
                                      newVote = 1; // upvote
                                    }

                                    await ref
                                        .read(questionRepositoryProvider)
                                        .voteQuestion(
                                          questionId: q.id,
                                          userId: currentUser.id,
                                          newVote: newVote,
                                        );
                                  },
                                ),
                                SizedBox(height: 6),
                                Text('Upvote'),
                              ],
                            ),
                            SizedBox(width: 30),

                            // VOTE COUNT BOX
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    q.voteCount.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Votes', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),

                            SizedBox(width: 30),

                            // DOWNVOTE
                            Column(
                              children: [
                                _voteCircle(
                                  context: context,
                                  icon: Icons.arrow_downward,
                                  enabled: !isBlocked,
                                  selected: userVote == -1,
                                  onTap: () async {
                                    int newVote;

                                    if (userVote == -1) {
                                      newVote = 0; // remove vote
                                    } else {
                                      newVote = -1; // downvote
                                    }

                                    await ref
                                        .read(questionRepositoryProvider)
                                        .voteQuestion(
                                          questionId: q.id,
                                          userId: currentUser.id,
                                          newVote: newVote,
                                        );
                                  },
                                ),
                                SizedBox(height: 6),
                                Text("Downvote"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        Divider(),

                        // SAVE
                        _sheetTile(
                          icon: isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          title: isSaved
                              ? 'Remove from Collection'
                              : 'Save to Collection',
                          onTap: () async {

                            final toggleController = ref.read(toggleSaveProvider);

                            Navigator.pop(context);

                            if (isSaved) {
                              final confirm = await AppDialogs.confirm(
                                context,
                                icon: Icons.bookmark_remove,
                                title: "Remove from collection",
                                description:
                                    "This question will be removed from your saved list.",
                                confirmText: "Remove",
                                confirmColor: theme.colorScheme.error,
                                destructive: true,
                              );

                              if (confirm != true) return;
                            }

                            await toggleController.toggle(question.id);
                          },
                        ),

                        // INFO
                        _sheetTile(
                          icon: Icons.info_outline,
                          title: "Why am I seeing this?",
                          onTap: () {
                            Navigator.pop(context);
                            showUserInfoSheet(context, q);
                          },
                        ),

                        // REPORT
                        _sheetTile(
                          icon: Icons.flag_outlined,
                          title: 'Report question',
                          onTap: () {
                            Navigator.pop(context);
                            ShowReportBottomSheet.show(
                              context,
                              ref,
                              contentId: q.id,
                              contentType: 'question',
                              parentId: q.id,
                            );
                          },
                        ),
                        Divider(height: 20),

                        // EDIT
                        if (isQuestionOwner)
                          _sheetTile(
                            icon: Icons.edit_outlined,
                            title: 'Edit question',
                            isDanger: true,
                            onTap: () {
                              Navigator.pop(context);

                              Future.microtask(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditQuestionScreen(question: question),
                                  ),
                                );
                              });
                            },
                          ),

                        // DELETE (OWNER ONLY)
                        if (isQuestionOwner)
                          _sheetTile(
                            icon: Icons.delete_outline,
                            title: 'Delete question',
                            isDanger: true,
                            onTap: () async {
                              final repo = ref.read(questionRepositoryProvider);
                              final selectedTag = ref.read(selectedTagProvider);
                              final selectedSort = ref.read(questionSortProvider);

                              final params = PaginationParams(
                                tag: selectedTag,
                                sort: selectedSort,
                              );

                              final notifier = ref.read(
                                paginatedQuestionsProvider(params).notifier,
                              );

                             final rootContext = Navigator.of(context, rootNavigator: true).context;
                              Navigator.pop(context);

                              final confirmed = await AppDialogs.confirm(
                                rootContext,
                                icon: Icons.delete_outline,
                                title: 'Delete Question?',
                                description:
                                    'This action cannot be undone. The question and all answers will be permanently removed.',
                                confirmText: 'Delete',
                                confirmColor: Colors.red,
                                destructive: true,
                              );

                              if (confirmed == true) {
                                try {
                                  await repo.deleteQuestion(
                                    q.id,
                                    question: q,
                                  );

                                  notifier.removeLocalQuestion(q.id);

                                  if (rootContext.mounted) {
                                    AppSnackBar.show(
                                      'Question deleted',
                                      type: SnackType.success,
                                    );

                                    GoRouter.of(rootContext).go('/first'); 
                                  }
                                } catch (e) {
                                  if (rootContext.mounted) {
                                    AppSnackBar.show(
                                      'Delete failed: $e',
                                      type: SnackType.error,
                                    );
                                  }
                                }
                              }
                            }
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _voteCircle({
  required BuildContext context,
  required IconData icon,
  required VoidCallback onTap,
  required bool selected,
  bool enabled = true,
}) {
  final theme = Theme.of(context);

  Color iconColor = theme.colorScheme.onSurfaceVariant;

  if (selected) {
    if (icon == Icons.arrow_upward) {
      iconColor = Colors.green;
    } else {
      iconColor = Colors.red;
    }
  }

  return InkWell(
    borderRadius: BorderRadius.circular(40),
    onTap: enabled ? onTap : null,
    child: Ink(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.2),
      ),
      child: Icon(icon, size: 28, color: iconColor),
    ),
  );
}

Widget _sheetTile({
  required IconData icon,
  required String title,
  bool isDanger = false,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: isDanger ? Colors.red : null),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: isDanger ? Colors.red : null,
      ),
    ),
    onTap: onTap,
  );
}
