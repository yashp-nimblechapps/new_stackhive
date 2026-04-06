import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/features/question/data/question_sort.dart';
import 'package:stackhive/features/tag/data/tag_repository.dart';
import 'package:stackhive/models/question_model.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore;
  final TagRepository _tagRepository;

  QuestionRepository(this._firestore, this._tagRepository);
  final String _collection = 'questions';

  Future<void> createQuestion(QuestionModel question) async {
    final batch = _firestore.batch();

    final questionRef = _firestore.collection('questions').doc();
    final statsRef = _firestore.collection('stats').doc('global');

    batch.set(questionRef, question.copyWith(id: questionRef.id).toMap());

    batch.update(statsRef, {'totalQuestions': FieldValue.increment(1)});

    await batch.commit();

    for (final tag in question.tags) {
      await _tagRepository.incrementTagUsage(tag);
    }
  }

  Stream<List<QuestionModel>> getAllQuestions() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();

      questions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return questions;
    });
  }

  Stream<QuestionModel?> getQuestionById(String id) {
    return _firestore.collection('questions').doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return QuestionModel.fromFirestore(doc);
    });
  }

  Future<void> updateQuestion({
    required String questionId,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    await _firestore.collection('questions').doc(questionId).update({
      'title': title,
      'description': description,
      'tags': tags,
    });
  }

  Future<void> deleteQuestion(
    String id, {
    required QuestionModel question,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final questionRef = firestore.collection('questions').doc(question.id);
    final answersSnapshot = await questionRef.collection('answers').get();
    final batch = firestore.batch();

    int totalAnswerVotes = 0;

    for (var doc in answersSnapshot.docs) {
      final data = doc.data();
      final voteCount = data['voteCount'] ?? 0;

      totalAnswerVotes += voteCount as int;

      batch.delete(doc.reference);
    }

    batch.delete(questionRef);

    final totalVotesToRemove = (question.voteCount) + totalAnswerVotes;

    final statsRef = firestore.collection('stats').doc('global');

    batch.update(statsRef, {
      'totalQuestions': FieldValue.increment(-1),
      'totalAnswers': FieldValue.increment(-answersSnapshot.docs.length),
      'totalVotes': FieldValue.increment(-totalVotesToRemove),
    });

    for (var tag in question.tags) {
      final tagRef = firestore.collection('tags').doc(tag);
      final tagSnapshot = await tagRef.get();
      final usage = tagSnapshot.data()?['usageCount'] ?? 0;

      if (usage <= 1) {
        // delete tag document
        batch.delete(tagRef);

        // Decrement totalTags
        batch.update(statsRef, {'totalTags': FieldValue.increment(-1)});
      } else {
        // Just decrement usage
        batch.update(tagRef, {'usageCount': FieldValue.increment(-1)});
      }
    }

    await batch.commit();
  }

  Stream<List<QuestionModel>> getQuestionsByTag(String tag) {
    return _firestore
        .collection(_collection)
        .where('tags', arrayContains: tag)
        .snapshots()
        .map((snapshots) {
          final questions = snapshots.docs
              .map((doc) => QuestionModel.fromFirestore(doc))
              .toList();

          questions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return questions;
        });
  }

  Future<void> voteQuestion({
    required String questionId,
    required String userId,
    required int newVote, // +1 or -1
  }) async {
    if (newVote != 1 && newVote != -1 && newVote != 0) {
      throw Exception("Invalid vote value");
    }

    final questionDoc = _firestore.collection('questions').doc(questionId);
    final voteDoc = questionDoc.collection('votes').doc(userId);
    final statsRef = _firestore.collection('stats').doc('global');

    await _firestore.runTransaction((transaction) async {
      final voteSnapshot = await transaction.get(voteDoc);
      int voteChange = 0;

      if (!voteSnapshot.exists) {
        if (newVote == 0) return; // nothing to remove
        // first vote
        voteChange = newVote;

        transaction.set(voteDoc, {'value': newVote});
      } else {
        final oldVote = (voteSnapshot['value'] as num).toInt();

        if (newVote == 0) {
          // remove vote
          voteChange = -oldVote;
          transaction.delete(voteDoc);

        } else if (oldVote == newVote) {

          // same vote tapped again → remove
          voteChange = -oldVote;
          transaction.delete(voteDoc);
        } else {
          // switch vote
          voteChange = newVote - oldVote;
          transaction.update(voteDoc, {'value': newVote});
        }
      }

      transaction.update(questionDoc, {
        'voteCount': FieldValue.increment(voteChange),
      });
      transaction.update(statsRef, {
        'totalVotes': FieldValue.increment(voteChange),
      });
    });
  }

  Stream<int?> getUserVote({
    required String questionId,
    required String userId,
  }) {
    return _firestore
        .collection('questions')
        .doc(questionId)
        .collection('votes')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          return (doc.data()?['value'] as num?)?.toInt();
        });
  }

  Stream<List<QuestionModel>> searchQuestions(String keyword) {
    return _firestore
        .collection(_collection)
        .where('searchKeywords', arrayContains: keyword.toLowerCase())
        .snapshots()
        .map((snapshots) {
          final questions = snapshots.docs
              .map((doc) => QuestionModel.fromFirestore(doc))
              .toList();

          questions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return questions;
        });
  }

  // Pagination

  Future<(List<QuestionModel>, DocumentSnapshot?)> fetchQuestionsPaginated({
    String? tag,
    required QuestionSort sort,
    DocumentSnapshot? lastDoc,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(_collection);

    // Tag filter
    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    // Sorting
    switch (sort) {
      case QuestionSort.Newest:
        query = query.orderBy('createdAt', descending: true);
        break;

      case QuestionSort.MostVoted:
        query = query.orderBy('voteCount', descending: true);
        break;

      case QuestionSort.MostAnswered:
        query = query.orderBy('answerCount', descending: true);
        break;
    }

    query = query.limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    final questions = snapshot.docs
        .map((doc) => QuestionModel.fromFirestore(doc))
        .toList();

    final lastVisible = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return (questions, lastVisible);
  }
}

// All Firestore logic stays here
// UI should NEVER talk directly to Firestore

// Real-time updates
// Live feed
// Automatic UI refresh

/*
Tag created if not exists
Usage incremented
No duplicates
*/
