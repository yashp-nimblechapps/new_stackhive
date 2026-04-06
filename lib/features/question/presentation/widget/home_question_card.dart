import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/models/question_model.dart';

class HomeScreenQuestionCard extends ConsumerWidget {
  final QuestionModel question;
  final bool isBlocked;
  final Function()? onMore;

  const HomeScreenQuestionCard({
    super.key,
    required this.question,
    required this.isBlocked,
    this.onMore,
  });

  String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.push('/detailQues/${question.id}');
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// MORE
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onMore,
                  ),
                ],
              ),

              /// TAGS
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: question.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    child: Text(tag, style: theme.textTheme.labelSmall),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              /// FOOTER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeAgo(question.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),

                  if (isBlocked)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        'Voting disabled',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
