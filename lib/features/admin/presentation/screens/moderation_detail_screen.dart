import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/admin/data/admin_moderation_repository.dart';
import 'package:stackhive/features/answer/provider/answer_provider.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';

class ModerationDetailScreen extends ConsumerWidget {
  final String questionId;

  const ModerationDetailScreen({super.key, required this.questionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final questionAsync = ref.watch(questionDetailProvider(questionId));
    final answersAsync = ref.watch(answersStreamProvider(questionId));
    final repo = AdminModerationRepository(FirebaseFirestore.instance);

    return Scaffold(
      appBar: AppBar(title: const Text('Moderation Detail')),
      body: questionAsync.when(
        data: (question) {
          if (question == null) {
            return const Center(child: Text('Not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// QUESTION HEADER
                Text(
                  "Question",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16),

                /// QUESTION CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(question.userId)
                                .get(),
                            builder: (context, snapshot) {
                              String name = "User";

                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                name = data['name'] ?? "User";
                              }

                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : "U",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          Spacer(),

                          /// DELETE QUESTION BUTTON
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(
                                color: theme.colorScheme.error.withValues(
                                  alpha: .4,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text("Delete"),
                            onPressed: () async {
                              final confirm = await AppDialogs.confirm(
                                context,
                                icon: Icons.delete_outline,
                                title: "Delete Questions",
                                description:
                                    "This will remove all answers too.",
                                confirmText: "Delete",
                                confirmColor: theme.colorScheme.error,
                              );

                              if (confirm == true) {
                                await repo.deleteQuestion(question: question);
                                AppSnackBar.show(
                                  "Question deleted successfully",
                                  type: SnackType.success,
                                );

                                final currentSort = ref.read(
                                  questionSortProvider,
                                );
                                final params = PaginationParams(
                                  tag: null,
                                  sort: currentSort,
                                );

                                ref
                                    .read(
                                      paginatedQuestionsProvider(
                                        params,
                                      ).notifier,
                                    )
                                    .removeLocalQuestion(question.id);

                                if (context.mounted) {
                                  context.pop();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 14),

                      /// TITLE
                      Text(
                        question.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// DESCRIPTION
                      Text(
                        question.description,
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 18),

                      /// STATS ROW
                      Row(
                        children: [
                          /// ANSWERS COUNT
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: .08,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ans: ${question.answerCount}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// VOTE COUNT
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: .08,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.how_to_vote_outlined,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Votes: ${question.voteCount}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// ANSWERS HEADER
                Text(
                  "Answers",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                /// ANSWERS LIST
                answersAsync.when(
                  data: (answers) {
                    if (answers.isEmpty) {
                      return Text(
                        'No answers',
                        style: theme.textTheme.bodyMedium,
                      );
                    }

                    return Column(
                      children: answers.map((answer) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// USER ROW
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(answer.userId)
                                    .get(),
                                builder: (context, snapshot) {
                                  String name = "User";

                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    final data =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    name = data['name'] ?? "User";
                                  }

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : "U",
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Text(
                                        name,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              /// ANSWER CONTENT
                              Text(
                                answer.content,
                                style: theme.textTheme.bodyMedium,
                              ),

                              const SizedBox(height: 14),

                              /// FOOTER
                              Row(
                                children: [
                                  /// VOTES
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: .08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.how_to_vote_outlined,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Votes: ${answer.voteCount}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Spacer(),

                                  /// DELETE ANSWER
                                  IconButton(
                                    icon: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error
                                            .withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final confirm = await AppDialogs.confirm(
                                        context,
                                        icon: Icons.delete_outline,
                                        title: "Delete Answer",
                                        description: "Are you sure?",
                                        confirmText: "Delete",
                                        confirmColor: theme.colorScheme.error,
                                      );

                                      if (confirm == true) {
                                        await repo.deleteAnswer(
                                          questionId: questionId,
                                          answerId: answer.id,
                                          answerVoteCount: answer.voteCount,
                                        );
                                        AppSnackBar.show(
                                          "Answer deleted successfully",
                                          type: SnackType.success,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text(e.toString()),
      ),
    );
  }
}
