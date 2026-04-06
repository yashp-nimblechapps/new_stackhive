import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/models/question_model.dart';

class AdminModerationRepository {
  final FirebaseFirestore firestore;

  AdminModerationRepository(this.firestore);

  Future<void> deleteQuestion({
    required QuestionModel question
  }) async {

    final questionRef = firestore.collection('questions').doc(question.id);
    final answersSnapshot = await questionRef.collection('answers').get();
    final batch = firestore.batch();

    int totalAnswersVotes = 0;

    // Delete all answers
    for (var doc in answersSnapshot.docs) {
      final data = doc.data();
      final answerVoteCount = data['voteCount'] ?? 0;

      totalAnswersVotes += answerVoteCount as int;

      batch.delete(doc.reference);
    }

    // Delete question
    batch.delete(questionRef);

    // Calculates total votes to decrement
    final totalVotesToRemove = (question.voteCount) + totalAnswersVotes;

    // Update global stats
    final statsRef = firestore.collection('stats').doc('global');
      batch.set(statsRef, {
        'totalQuestions': FieldValue.increment(-1),
        'totalAnswers': FieldValue.increment(-answersSnapshot.docs.length),
        'totalVotes': FieldValue.increment(-totalVotesToRemove),
      }, SetOptions(merge: true));
    
    // Decrement tag usage
    for (var tag in question.tags) {

      final tagRef = firestore.collection('tags').doc(tag);
      final tagSnapshot = await tagRef.get();
      final usage = tagSnapshot.data()?['usageCount'] ?? 0;

      if (usage <= 1) {
        // delete tag document
        batch.delete(tagRef);

        // Decrement totalTags
        batch.update(statsRef, {
          'totalTags': FieldValue.increment(-1),
        });
      } else {
        // Just decrement usage
        batch.update(tagRef, {
          'usageCount': FieldValue.increment(-1),
        });
      }
    }

    await batch.commit();
  }


  Future<void> deleteAnswer({
  required String questionId,
  required String answerId,
  required int answerVoteCount,
  }) async {
    final answerRef = firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers')
        .doc(answerId);

    final questionRef = firestore.collection('questions').doc(questionId);
    final statsRef = firestore.collection('stats').doc('global');
    final batch = firestore.batch();    

    // Delete answer
    batch.delete(answerRef);

    // Decrement question answer count (if you store it)
    batch.update(questionRef, {
      'answerCount': FieldValue.increment(-1),
    });
  // Update global stats
    batch.update(statsRef, {
      'totalAnswers': FieldValue.increment(-1),
      'totalVotes': FieldValue.increment(-answerVoteCount),
    });

    await batch.commit();
  } 
}