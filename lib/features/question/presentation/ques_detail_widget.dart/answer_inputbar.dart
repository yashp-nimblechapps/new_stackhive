import 'package:flutter/material.dart';

class AnswerInputBar extends StatelessWidget {

  final TextEditingController controller;
  final VoidCallback onPost;

  const AnswerInputBar({super.key, required this.controller, required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your answer...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(width: 10),

          ElevatedButton(
            onPressed: onPost,
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
            ), 
            child: Text('Post')
          )
        ],
      ),
    );
  }
}