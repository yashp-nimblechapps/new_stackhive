import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/answer/provider/answer_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/question/data/question_repository.dart';
import 'package:stackhive/features/question/presentation/ques_detail_widget.dart/QuestionCard.dart';
import 'package:stackhive/features/question/presentation/ques_detail_widget.dart/answer_card.dart';
import 'package:stackhive/features/question/presentation/ques_detail_widget.dart/answer_inputbar.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';
import 'package:stackhive/features/report/provider/report_provider.dart';
import 'package:stackhive/models/question_model.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const QuestionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionAsync = ref.watch(questionDetailProvider(widget.id));
    final answerAsync = ref.watch(answersStreamProvider(widget.id));
    final userAsync = ref.watch(currentUserProvider);

    ref.listen(reportControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) {
          AppSnackBar.show('Error: ${e.toString()}', type: SnackType.error);
        },
        data: (_) {
          AppSnackBar.show('Report submitted successfully', type: SnackType.success);
        },
      );
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (appUser) {
          final isBlocked = appUser?.isBlocked ?? false;

          return questionAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (question) {
              if (question == null) {
                return Scaffold(body: Center(child: Text('Question deleted')));
              }

              final isQuestionOwner = appUser?.id == question.userId;

              return Scaffold(
                appBar: AppBar(title: Text('Question')),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          // QUESTION CARD
                          QuestionCard(
                            question: question,
                            isQuestionOwner: isQuestionOwner,
                          ),
                          SizedBox(height: 24),

                          // ANSWERS HEADER
                          Text(
                            'Answers',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12),

                          /// ANSWER LIST
                          answerAsync.when(
                            loading: () =>
                                Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text("Error $e"),

                            data: (answers) {
                              if (answers.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text("No answers yet"),
                                );
                              }

                              return Column(
                                children: answers.map((answer) {
                                  final voteAsync = ref.watch(
                                    userVoteProvider((
                                      questionId: widget.id,
                                      answerId: answer.id,
                                      userId: appUser!.id,
                                    )),
                                  );

                                  final isAnswerOwner =
                                      appUser.id == answer.userId;

                                  final canDelete =
                                      isAnswerOwner || isQuestionOwner;

                                  return AnswerCard(
                                    questionId: widget.id,
                                    question: question,
                                    answer: answer,
                                    voteAsync: voteAsync,
                                    isAnswerOwner: isAnswerOwner,
                                    isQuestionOwner: isQuestionOwner,
                                    canDelete: canDelete,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ANSWER INPUT BAR
                    if (!isBlocked)
                      AnswerInputBar(
                        controller: _answerController,
                        onPost: () async {
                          final content = _answerController.text.trim();

                          if (content.isEmpty || appUser == null) return;

                          await ref
                              .read(answerRepositoryProvider)
                              .addAnswer(
                                questionId: widget.id,
                                userId: appUser.id,
                                content: content,
                              );

                          _answerController.clear();
                        },
                      )
                    else
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'You are blocked by admin',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> showEditQuestionDialog(
  BuildContext context,
  QuestionModel question, {
  required QuestionRepository repo,
}) async {
  final titleController = TextEditingController(text: question.title);
  final descriptionController = TextEditingController(
    text: question.description,
  );
  final tagsController = TextEditingController(text: question.tags.join(','));

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Question'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Save'),
          ),
        ],
      );
    },
  );
  if (confirm == true) {
    await repo.updateQuestion(
      questionId: question.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      tags: tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
    AppSnackBar.show(
      "Question Edited Successfully",
      type: SnackType.success,
    );
  }
}




/*
Real-time answers
Voting system
Answer count auto update
Best answer badge ready
StackOverflow-style layout
*/