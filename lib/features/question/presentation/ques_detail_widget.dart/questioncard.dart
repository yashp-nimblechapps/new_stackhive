import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/question/presentation/ques_detail_widget.dart/tag_chip.dart';
import 'package:stackhive/features/question/presentation/widget/showQuesActions.dart';
import 'package:stackhive/models/question_model.dart';

class QuestionCard extends ConsumerWidget {
  final QuestionModel question;
  final bool isQuestionOwner;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isQuestionOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 18, left: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 12),

          // TITLE + MENU
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: question.tags.map((tag) => TagChip(tag: tag)).toList(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () => showQuesActions(context, ref, question),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            question.title,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6,),
            child: Text(question.description),
          ),

          SizedBox(height: 18),

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
                  color: theme.colorScheme.primary.withValues(alpha: .08),
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
                      '${question.answerCount}',
                      style: theme.textTheme.labelSmall
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
                      '${question.voteCount}',
                      style: theme.textTheme.labelSmall
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
