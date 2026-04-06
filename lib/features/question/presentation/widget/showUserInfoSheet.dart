import 'package:flutter/material.dart';
import 'package:stackhive/models/question_model.dart';

void showUserInfoSheet(BuildContext context, QuestionModel question) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why am I seeing this content?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            Text(
              'This content appears in your feed because:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: 12),

            _infoItem('You are a member of StackHive'),
            _infoItem('It matches topics developers discuss'),
            _infoItem('You follow related tags or interests'),

            SizedBox(height: 20),

            Text(
              'Our goal is to help developers discover useful questions and share answers, knowledge with the community.',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Widget _infoItem(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(Icons.check_circle_outline, size: 18),
        SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
