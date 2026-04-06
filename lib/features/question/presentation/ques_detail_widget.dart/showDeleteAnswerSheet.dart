import 'package:flutter/material.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/answer/data/answer_repository.dart';
import 'package:stackhive/models/answer_model.dart';

void showDeleteAnswerSheet(
  BuildContext parentcontext, {
  required AnswerRepository answerRepo,
  required String questionId,
  required AnswerModel answer,
  }) {
  showModalBottomSheet(
    context: parentcontext,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 40, color: Colors.red),
            SizedBox(height: 12),

            Text(
              'Delete Answer?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),

            Text(
              'This action cannot be undone. The answer will be permanently removed.',
              textAlign: TextAlign.center,
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
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      try {
                        Navigator.pop(context); 
                        await answerRepo.deleteAnswer(
                          questionId: questionId,
                          answer: answer,
                        );

                        if (parentcontext.mounted) {                    
                          AppSnackBar.show('Answer deleted', type: SnackType.success);
                        }

                      } catch (e, _) {
                        if (parentcontext.mounted) {
                          AppSnackBar.show('Delete failed', type: SnackType.error);
                        }
                      }
                    },
                    child: Text('Delete',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
