import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/models/analytics_model.dart';
import 'package:stackhive/models/question_model.dart';
import 'package:stackhive/models/tag_model.dart';
import 'package:stackhive/models/user_model.dart';

final analyticsProvider = StreamProvider<AnalyticsData>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore.collection('stats').doc('global').snapshots().asyncMap((
    statsDoc,
  ) async {
    final stats = statsDoc.data();

    /// TOP USED TAG
    final tagSnap = await firestore
        .collection('tags')
        .orderBy('usageCount', descending: true)
        .limit(1)
        .get();

    TagModel? topTag;
    if (tagSnap.docs.isNotEmpty) {
      topTag = TagModel.fromMap(
        tagSnap.docs.first.data(),
        tagSnap.docs.first.id,
      );
    }

    /// TAG DISTRIBUTION (ALL TAGS)
    final tagDistributionSnap = await firestore
        .collection('tags')
        .orderBy('usageCount', descending: true)
        .limit(8)
        .get();

    final tagDistribution = tagDistributionSnap.docs
        .map((doc) => TagModel.fromMap(doc.data(), doc.id))
        .toList();

    /// TOP VOTED QUESTION
    final questionSnap = await firestore
        .collection('questions')
        .orderBy('voteCount', descending: true)
        .limit(1)
        .get();

    QuestionModel? topQuestion;
    if (questionSnap.docs.isNotEmpty) {
      topQuestion = QuestionModel.fromFirestore(questionSnap.docs.first);
    }

    /// CONTRIBUTOR ANALYSIS
    final answersSnap = await firestore.collectionGroup('answers').get();

    final Map<String, int> userVoteMap = {};

    for (var doc in answersSnap.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final votes = data['voteCount'] ?? 0;

      userVoteMap[userId] = (userVoteMap[userId] ?? 0) + (votes as int);
    }

    /// sort contributors
    final sortedUsers = userVoteMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    /// TOP CONTRIBUTOR
    AppUser? topContributor;

    if (sortedUsers.isNotEmpty) {
      final userDoc = await firestore
          .collection('users')
          .doc(sortedUsers.first.key)
          .get();

      if (userDoc.exists) {
        topContributor = AppUser.fromMap(userDoc.data()!, userDoc.id);
      }
    }

    /// TOP 5 CONTRIBUTORS
    List<AppUser> topContributors = [];

    for (var entry in sortedUsers.take(5)) {
      final userDoc = await firestore.collection('users').doc(entry.key).get();

      if (userDoc.exists) {
        topContributors.add(AppUser.fromMap(userDoc.data()!, userDoc.id));
      }
    }

    // FROWTH ANALYTICS (7 DAYS)

    final now = DateTime.now();

    final last7Days = List.generate(
      7,
      (i) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i)),
    );

    final List<int> questionsPerDay = List.filled(7, 0);
    final List<int> answersPerDay = List.filled(7, 0);

    // QUESTIONS
    final questionDocs = await firestore
        .collection('questions')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(last7Days.first),
        )
        .get();

    for (var doc in questionDocs.docs) {
      final createdAt = (doc['createdAt'] as Timestamp).toDate();

      for (int i = 0; i < last7Days.length; i++) {
        final day = last7Days[i];

        if (createdAt.year == day.year &&
            createdAt.month == day.month &&
            createdAt.day == day.day) {
          questionsPerDay[i]++;
        }
      }
    }

    // ANSWERS
    final answersDocs = await firestore
      .collectionGroup('answers')
      .where('createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(last7Days.first),
      )
      .get();

    for (var doc in answersDocs.docs) {
      final createdAt = (doc['createdAt'] as Timestamp).toDate();

      for (int i = 0; i < last7Days.length; i++) {
        final day = last7Days[i];

        if (createdAt.year == day.year &&
            createdAt.month == day.month &&
            createdAt.day == day.day) {
          answersPerDay[i]++;
        }
      }
    }

    return AnalyticsData(
      topTag: topTag,
      topQuestion: topQuestion,
      topContributor: topContributor,
      totalVotes: stats?['totalVotes'] ?? 0,
      totalQuestions: stats?['totalQuestions'] ?? 0,
      totalAnswers: stats?['totalAnswers'] ?? 0,

      /// NEW
      tagDistribution: tagDistribution,
      topContributors: topContributors,

      questionsPerDay: questionsPerDay,
      answersPerDay: answersPerDay,
    );
  });
});
