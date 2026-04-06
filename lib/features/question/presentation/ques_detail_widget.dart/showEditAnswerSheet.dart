import 'package:flutter/material.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/answer/data/answer_repository.dart';
import 'package:stackhive/models/answer_model.dart';

void showEditAnswerSheet(
  BuildContext parentcontext, {
  required AnswerModel answer,
  required String questionId,
  required AnswerRepository answerRepo,
}) {
  final controller = TextEditingController(text: answer.content);

  showModalBottomSheet(
    context: parentcontext,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20,20,20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 40, color: Colors.blue),

              SizedBox(height: 12),

              Text('Edit Answer',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              SizedBox(height: 16),

              TextField(
                controller: controller,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Update your answer...',
                ),
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        final newContent = controller.text.trim();

                        try {
                          Navigator.pop(context);

                          if (newContent.isNotEmpty &&
                              newContent != answer.content) {
                            await answerRepo.updateAnswer(
                              questionId: questionId,
                              answerId: answer.id,
                              newContent: newContent,
                            );
                          }
                          if (parentcontext.mounted) {
                            AppSnackBar.show('Answer updated');
                          }
                        } catch (_) {
                          if (parentcontext.mounted) {
                            AppSnackBar.show('Update failed');
                          }
                        }
                      },
                      child: Text('Save',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
