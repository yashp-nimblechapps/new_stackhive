import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/question/presentation/widget/home_question_card.dart';
import 'package:stackhive/features/question/presentation/widget/showQuesActions.dart';
import 'package:stackhive/features/saved/provider/saved_provider.dart';
import 'package:stackhive/models/question_model.dart';

class SavedQuestionsScreen extends ConsumerWidget {
  const SavedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIdsAsync = ref.watch(savedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Questions")),
      body: savedIdsAsync.when(
        data: (savedIds) {
          if (savedIds.isEmpty) {
            return _emptyState();
          }
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('questions')
                .where(FieldPath.documentId, whereIn: savedIds)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              final questions = docs
                  .map((e) => QuestionModel.fromFirestore(e))
                  .toList();

              return ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];

                  return HomeScreenQuestionCard(
                    question: question,
                    isBlocked: false,
                    onMore: () => showQuesActions(context, ref, question),
                  );
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error $e")),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),

          Text(
            "No saved questions yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          Text(
            "Start saving useful questions",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
