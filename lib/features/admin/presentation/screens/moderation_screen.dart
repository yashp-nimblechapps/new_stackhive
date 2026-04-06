import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/admin/data/admin_moderation_repository.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/admin/provider/moderation_provider.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final questions = ref.watch(allQuestionsProvider);
    final repo = AdminModerationRepository(FirebaseFirestore.instance);

    return AdminLayout(
      title: 'Question Moderation',
      child: questions.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No questions',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final question = list[index];

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  context.push('/admin/moderation/${question.id}');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                  

                      /// OWNER
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
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                name = data['name'] ?? "User";
                              }

                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                                      style: theme.textTheme.bodyMedium?.copyWith(
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

                          /// DELETE BUTTON
                          IconButton(
                            onPressed: () async {
                              final confirm = await AppDialogs.confirm(
                                context,
                                icon: Icons.delete_outline,
                                title: "Delete Question", 
                                description: '/nAre you sure you want to delete this question?\n'
                                    'All answers and votes will also be permanently removed.',
                                confirmText: "Delete",
                                confirmColor: theme.colorScheme.error,  
                              );  
                                
                              if (confirm == true) {
                                await repo.deleteQuestion(question: question);

                                AppSnackBar.show(
                                  "Question deleted successfully",
                                  type: SnackType.success,
                                );

                                final currentSort =
                                    ref.read(questionSortProvider);

                                final params = PaginationParams(
                                  tag: null,
                                  sort: currentSort,
                                );

                                ref
                                    .read(
                                        paginatedQuestionsProvider(params)
                                            .notifier)
                                    .removeLocalQuestion(question.id);
                              }
                            },
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
                          ),

                        ],
                      ),

                      const SizedBox(height: 14),

                      /// QUESTION TITLE
                      Text(
                        question.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// FOOTER
                      Row(
                        children: [

                          /// ANSWERS
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

                          const SizedBox(width: 10),

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
                                  'Votes: ${question.voteCount}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(),),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}