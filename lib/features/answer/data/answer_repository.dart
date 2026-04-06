import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/features/notifications/data/notification_repository.dart';
import 'package:stackhive/features/notifications/data/notification_settings_repository.dart';
import 'package:stackhive/models/answer_model.dart';
import 'package:stackhive/models/notification_model.dart';

class AnswerRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepository;
  final NotificationSettingsRepository _settingsRepository;

  AnswerRepository(
    this._firestore,
    this._notificationRepository,
    this._settingsRepository,
  );

  // Subcollection reference
  CollectionReference<Map<String, dynamic>> answersRef(String questionId) {
    return _firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers');
  }

  // Add Answer
  Future<void> addAnswer({
    required String questionId,
    required String userId,
    required String content,
  }) async {
    final answerDoc = answersRef(questionId).doc();

    final batch = _firestore.batch();

    // Add answer
    final answer = AnswerModel(
      id: answerDoc.id,
      questionId: questionId,
      userId: userId,
      content: content,
      voteCount: 0,
      isBestAnswer: false,
      createdAt: Timestamp.now(),
    );

    // Add answer document
    batch.set(answerDoc, answer.toMap());

    // Increment answerCount in question document
    final questionDoc = _firestore.collection('questions').doc(questionId);

    batch.update(questionDoc, {'answerCount': FieldValue.increment(1)});

    // Increment global totalAnswers
    final statsRef = _firestore.collection('stats').doc('global');
    batch.update(statsRef, {'totalAnswers': FieldValue.increment(1)});

    await batch.commit();

    // Create Notifications
    final questionSnapshot = await questionDoc.get();
    final questionOwnerId = questionSnapshot.data()?['userId'];

    final senderDoc = await _firestore.collection('users').doc(userId).get();
    final senderName = senderDoc.data()?['name'] ?? 'User';

    // Prevent self-notification
    if (questionOwnerId != null && questionOwnerId != userId) {
      final notification = NotificationModel(
        id: '',
        senderId: userId,
        senderName: senderName,
        receiverId: questionOwnerId,
        type: 'new_answer',
        questionId: questionId,
        answerId: answerDoc.id,
        previewText: content.length > 100 ? content.substring(0, 100) : content,
        isRead: false,
        createdAt: DateTime.now(),
      );

      final settings = await _settingsRepository.getSettings(questionOwnerId);
      //print("Notification settings:");
      //print("pushEnabled: ${settings.pushEnabled}");
      //print("newAnswers: ${settings.newAnswers}");

      // Global notification disabled
      if (!settings.pushEnabled || !settings.newAnswers) {
        //print("Notifications disabled. Skipping notification.");
        return;
      }

      //print("Creating notification for $questionOwnerId");

      await _notificationRepository.createNotification(
        receiverId: questionOwnerId,
        notification: notification,
      );
    }
  }

  // Get Answers (Real-time Stream)
  Stream<List<AnswerModel>> getAnswers(String questionId) {
    return answersRef(questionId)
        .orderBy('isBestAnswer', descending: true)
        .orderBy('voteCount', descending: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshots) => snapshots.docs
              .map((doc) => AnswerModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Delete Answer
  Future<void> deleteAnswer({
    required String questionId,
    required AnswerModel answer,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final answerRef = firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers')
        .doc(answer.id);

    final questionRef = firestore.collection('questions').doc(questionId);
    final statsRef = firestore.collection('stats').doc('global');

    final questionSnapshot = await questionRef.get();
    final bestAnswerId = questionSnapshot.data()?['bestAnswerId'];

    final batch = firestore.batch();

    batch.delete(answerRef);


    batch.update(questionRef, {
      'answerCount': FieldValue.increment(-1),
      if (bestAnswerId == answer.id) 'bestAnswerId': null,
    });

    final Map<String, dynamic> questionUpdate = {
      'answerCount': FieldValue.increment(-1),
    };

    if (bestAnswerId == answer.id) {
      questionUpdate['bestAnswerId'] = null;
    }

    batch.update(questionRef, questionUpdate);

    batch.update(statsRef, {
      'totalAnswers': FieldValue.increment(-1),
      'totalVotes': FieldValue.increment(-answer.voteCount),
    });

    await batch.commit();
  }

  // Update Answer Content
  Future<void> updateAnswer({
    required String questionId,
    required String answerId,
    required String newContent,
  }) async {
    await answersRef(questionId).doc(answerId).update({'content': newContent});
  }

  // Vote Answer
  Future<void> voteAnswer({
    required String questionId,
    required String answerId,
    required String userId,
    required int newVote, // 1 or -1
  }) async {
    if (newVote != 1 && newVote != -1 && newVote != 0) {
      throw Exception("Invalid vote value");
    }

    final answerDoc = answersRef(questionId).doc(answerId);
    final voteDoc = answerDoc.collection('votes').doc(userId);
    final statsRef = _firestore.collection('stats').doc('global');

    bool isFirstVote = false;

    await _firestore.runTransaction((transaction) async {
      final voteSnapshot = await transaction.get(voteDoc);

      int voteChange = 0;

      if (!voteSnapshot.exists) {
        if (newVote == 0) return; // nothing to remove

        // First time voting
        voteChange = newVote;
        isFirstVote = true;

        transaction.set(voteDoc, {'value': newVote});
      } else {
        final oldVote = (voteSnapshot['value'] as num).toInt();

        if (newVote == 0) {
          // Remove vote
          voteChange = -oldVote;
          transaction.delete(voteDoc);
        } else if (oldVote == newVote) {
          // Same vote tapped again → remove vote
          voteChange = -oldVote;
          transaction.delete(voteDoc);
        } else {
          // Switche vote
          voteChange = newVote - oldVote;
          transaction.update(voteDoc, {'value': newVote});
        }
      }

      transaction.update(answerDoc, {
        'voteCount': FieldValue.increment(voteChange),
      });
      transaction.update(statsRef, {
        'totalVotes': FieldValue.increment(voteChange),
      });
    });

    // Create notification ONLY if first vote
    if (isFirstVote) {
      final answerSnapshot = await answerDoc.get();
      final data = answerSnapshot.data();

      final answerOwnerId = data?['userId'];
      final content = data?['content'] ?? '';

      final senderDoc = await _firestore.collection('users').doc(userId).get();
      final senderName = senderDoc.data()?['name'] ?? "User";

      if (answerOwnerId != null && answerOwnerId != userId) {
        final preview = content.length > 100
            ? content.substring(0, 100)
            : content;

        final notification = NotificationModel(
          id: '',
          senderId: userId,
          senderName: senderName,
          receiverId: answerOwnerId,
          type: 'vote',
          voteType: newVote == 1 ? 'upvote' : 'downvote',
          questionId: questionId,
          answerId: answerId,
          previewText: preview,
          isRead: false,
          createdAt: DateTime.now(),
        );

        final settings = await _settingsRepository.getSettings(answerOwnerId);

        // If user disabled notification then stop
        if (!settings.pushEnabled || !settings.votes) return;

        await _notificationRepository.createNotification(
          receiverId: answerOwnerId,
          notification: notification,
        );
      }
    }
  }

  // Mark Best Answer
  Future<void> markBestAnswer({
  required String questionId,
  required String answerId,
  required String currentUserId,
}) async {
  final batch = _firestore.batch();

  final questionRef = _firestore.collection('questions').doc(questionId);
  final answersCollection = answersRef(questionId);
  final selectedAnswerRef = answersCollection.doc(answerId);

  // Fetch required documents
  final questionSnapshot = await questionRef.get();
  if (!questionSnapshot.exists) {
    throw Exception("Question not found");
  }

  final selectedAnswerSnapshot = await selectedAnswerRef.get();
  if (!selectedAnswerSnapshot.exists) {
    throw Exception("Selected answer not found");
  }

  final previousBestAnswerId =
      questionSnapshot.data()?['bestAnswerId'];

  // Reset previous best answer (if exists AND document exists)
  if (previousBestAnswerId != null) {
    final previousBestRef =
        answersCollection.doc(previousBestAnswerId);

    final prevSnapshot = await previousBestRef.get();

    if (prevSnapshot.exists) {
      batch.update(previousBestRef, {'isBestAnswer': false});
    }
  }

  // Set new best answer
  batch.update(selectedAnswerRef, {'isBestAnswer': true});

  // Update question document
  batch.update(questionRef, {'bestAnswerId': answerId});

  // Commit batch
  await batch.commit();

  // ==========================
  //  Notification Logic
  // ==========================

  final answerData = selectedAnswerSnapshot.data();
  final answerOwnerId = answerData?['userId'];
  final answerText = answerData?['content'] ?? '';

  // Get sender info
  final senderDoc = await _firestore
      .collection('users')
      .doc(currentUserId)
      .get();

  final senderName = senderDoc.data()?['name'] ?? 'User';

  // Prevent self notification
  if (answerOwnerId == null || answerOwnerId == currentUserId) return;

  final preview = answerText.length > 100
      ? answerText.substring(0, 100)
      : answerText;

  final notification = NotificationModel(
    id: '',
    senderId: currentUserId,
    senderName: senderName,
    receiverId: answerOwnerId,
    type: 'best_answer',
    questionId: questionId,
    answerId: answerId,
    previewText: preview,
    isRead: false,
    createdAt: DateTime.now(),
  );

  // Check notification settings
  final settings =
      await _settingsRepository.getSettings(answerOwnerId);

  if (!settings.pushEnabled || !settings.bestAnswer) return;

  // Create notification
  await _notificationRepository.createNotification(
    receiverId: answerOwnerId,
    notification: notification,
  );
}

  // Get User Vote
  Stream<int?> getUserVote({
    required String questionId,
    required String answerId,
    required String userId,
  }) {
    return answersRef(
      questionId,
    ).doc(answerId).collection('votes').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return (doc.data()?['value'] as num?)?.toInt();
    });
  }

  // return
  // 1 -> Upvoted, -1 -> Downvoted, null -> No vote
} 

/*
Real-time answer stream
Atomic answerCount increment
Voting system
Best answer pinning
Safe batch writes
Ordered answer display logic
*/