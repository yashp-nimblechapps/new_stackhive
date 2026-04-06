import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/answer/provider/answer_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/question/presentation/ques_detail_widget.dart/showEditAnswerSheet.dart';
import 'package:stackhive/features/question/presentation/widget/showReportBottomSheet.dart';
import 'package:stackhive/features/question/presentation/widget/showUserInfoSheet.dart';
import 'package:stackhive/models/answer_model.dart';
import 'package:stackhive/models/question_model.dart';

void showAnswerActions(
  BuildContext context,
  WidgetRef ref,
  QuestionModel question,
  AnswerModel answer,
) {
  final currentUser = ref.read(currentUserProvider).value;

  final isQuestionOwner = currentUser?.id == question.userId;
  final isAnswerOwner = currentUser?.id == answer.userId;
  final canDelete = isAnswerOwner || isQuestionOwner;
  final isBlocked = currentUser?.isBlocked ?? false;

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
          final answersAsync = ref.watch(answersStreamProvider(question.id));

          return answersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(30),
              child: Text("Error $e"),
            ),
            data: (answers) {
              final a = answers.firstWhere(
                (element) => element.id == answer.id,
                orElse: () => answer,
              );

              final theme = Theme.of(context);

              final userVoteAsync = ref.watch(
                userVoteProvider((
                  questionId: question.id,
                  answerId: a.id,
                  userId: currentUser!.id,
                )),
              );

              final userVote = userVoteAsync.value ?? 0;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// VOTING SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// UPVOTE
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
                                        .read(answerRepositoryProvider)
                                        .voteAnswer(
                                          questionId: question.id,
                                          answerId: a.id,
                                          userId: currentUser.id,
                                          newVote: newVote,
                                        );
                                  },
                                ),
                                const SizedBox(height: 6),
                                const Text('Upvote'),
                              ],
                            ),

                            const SizedBox(width: 30),

                            /// VOTE COUNT
                            Container(
                              padding: const EdgeInsets.symmetric(
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
                                    a.voteCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Votes',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 30),

                            /// DOWNVOTE
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
                                        .read(answerRepositoryProvider)
                                        .voteAnswer(
                                          questionId: question.id,
                                          answerId: a.id,
                                          userId: currentUser.id,
                                          newVote: newVote,
                                        );
                                  },
                                ),
                                const SizedBox(height: 6),
                                const Text("Downvote"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(),

                        /// MARK BEST ANSWER
                        if (isQuestionOwner && !a.isBestAnswer)
                          _sheetTile(
                            icon: Icons.check_circle_outline,
                            title: 'Mark as Best Answer',
                            onTap: () async {
                              Navigator.pop(context);

                              await ref
                                  .read(answerRepositoryProvider)
                                  .markBestAnswer(
                                    questionId: question.id,
                                    answerId: a.id,
                                    currentUserId: currentUser.id,
                                  );

                              AppSnackBar.show(
                                "Mark as Best Answer",
                                type: SnackType.info,
                              );

                            },
                          ),

                        /// INFO
                        _sheetTile(
                          icon: Icons.info_outline,
                          title: "Why am I seeing this?",
                          onTap: () {
                            Navigator.pop(context);
                            showUserInfoSheet(context, question);
                          },
                        ),

                        /// REPORT
                        _sheetTile(
                          icon: Icons.flag_outlined,
                          title: 'Report answer',
                          onTap: () {
                            Navigator.pop(context);

                            ShowReportBottomSheet.show(
                              context,
                              ref,
                              contentId: a.id,
                              contentType: 'answer',
                              parentId: question.id,
                            );
                          },
                        ),

                        const Divider(height: 20),

                        /// EDIT ANSWER
                        if (isAnswerOwner)
                          _sheetTile(
                            icon: Icons.edit_outlined,
                            title: 'Edit answer',
                            isDanger: true,
                            onTap: () {
                              Navigator.pop(context);

                              showEditAnswerSheet(
                                context,
                                answer: answer,
                                questionId: question.id,
                                answerRepo: ref.read(answerRepositoryProvider),
                              );
                            },
                          ),

                        // DELETE ANSWER
                        if (canDelete)
                          _sheetTile(
                            icon: Icons.delete_outline,
                            title: 'Delete answer',
                            isDanger: true,
                            onTap: () async {
                              final answerRepo = ref.read(answerRepositoryProvider);
                              
                              final rootContext =
                                  Navigator.of(context, rootNavigator: true).context;

                              Navigator.pop(context);

                              final confirmed = await AppDialogs.confirm(
                                rootContext,
                                icon: Icons.delete_outline,
                                title: 'Delete Answer?',
                                description:
                                    'This action cannot be undone. The answer will be permanently removed.',
                                confirmText: 'Delete',
                                confirmColor: Colors.red,
                                destructive: true,
                              );

                              if (confirmed == true) {
                                try {
                                  await answerRepo.deleteAnswer(
                                    questionId: question.id,
                                    answer: a,
                                  );

                                  if (rootContext.mounted) {
                                    AppSnackBar.show('Answer deleted', type: SnackType.success);
                                  }
                                } catch (e) {
                                  if (rootContext.mounted) {
                                    AppSnackBar.show('Delete failed',type: SnackType.error);
                                  }
                                }
                              }
                            },
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
