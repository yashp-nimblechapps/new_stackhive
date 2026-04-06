import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/answer/data/answer_repository.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/notifications/provider/notification_provider.dart';
import 'package:stackhive/features/notifications/provider/notification_settings_provider.dart';
import 'package:stackhive/models/answer_model.dart';

// Repository Provider
final answerRepositoryProvider = Provider<AnswerRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final notificationRepo = ref.read(notificationRepositoryProvider);
  final notificationsSettingsRepo = ref.read(notificationSettingsRepositoryProvider);

  return AnswerRepository(firestore, notificationRepo, notificationsSettingsRepo);
});

// Real-time Answers Stream Provider (per question)
final answersStreamProvider = StreamProvider.family<List<AnswerModel>, String>((ref, questionId) {
  final repository = ref.watch(answerRepositoryProvider);
  return repository.getAnswers(questionId);
});  

final userVoteProvider = StreamProvider.family<
    int?, ({String questionId, String answerId, String userId})>((ref, params) {

      final currentUser = ref.watch(currentUserProvider).value;

      // If user is blocked, do not query Firestore
      if (currentUser == null || currentUser.isBlocked) { 
        return Stream.value(null);
      }
    
      final repository = ref.watch(answerRepositoryProvider);

      return repository.getUserVote(
        questionId: params.questionId, 
        answerId: params.answerId, 
        userId: params.userId
      );
});



/*
Subscribes to Firestore
Listens to real-time updates
Rebuilds UI automatically
Cleans up when screen disposes
*/