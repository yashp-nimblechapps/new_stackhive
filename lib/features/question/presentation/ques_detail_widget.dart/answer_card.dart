import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/question/presentation/ques_detail_widget.dart/showAnswerActions.dart';
import 'package:stackhive/models/answer_model.dart';
import 'package:stackhive/models/question_model.dart';

class AnswerCard extends ConsumerWidget {
  final String questionId;
  final QuestionModel question;
  final AnswerModel answer;
  final AsyncValue<int?> voteAsync;

  final bool isAnswerOwner;
  final bool isQuestionOwner;
  final bool canDelete;

  const AnswerCard({
    super.key,
    required this.questionId,
    required this.question,
    required this.answer,
    required this.voteAsync,
    required this.isAnswerOwner,
    required this.isQuestionOwner,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CONTENT+ MENU
          Row(
            children: [
              // ANSWER TEXT
              Expanded(
                child: Text(answer.content, style: theme.textTheme.bodyMedium),
              ),

              // MORE BUTTON
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  showAnswerActions(context, ref, question, answer);
                },
              ),
            ],
          ),
          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              /// VOTES
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .08),
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
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              // BEST ANSWER BADGE
              if (answer.isBestAnswer)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Best Answer',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
