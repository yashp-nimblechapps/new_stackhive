import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/models/adminStats_model.dart';

final adminStatsProvider = StreamProvider<AdminStats>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null || user.role != 'admin') {
        return Stream.empty();
      }

      return FirebaseFirestore.instance
          .collection('stats')
          .doc('global')
          .snapshots()
          .map((doc) {
        final data = doc.data()!;
        return AdminStats(
          totalUsers: data['totalUsers'] ?? 0,
          totalQuestions: data['totalQuestions'] ?? 0,
          totalAnswers: data['totalAnswers'] ?? 0,
          totalTags: data['totalTags'] ?? 0,
          totalVotes: data['totalVotes'] ?? 0,
        );
      });
    },
    loading: () => Stream.empty(),
    error: (_, _) => Stream.empty(),
  );
});