import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/profile/data/profileStats_repository.dart';
import 'package:stackhive/models/profileStats_model.dart';

// Profile Repository provider
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(FirebaseFirestore.instance),
);

// Profile Stats provider
final profileStatsProvider = StreamProvider<ProfileStats>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        throw Exception("User not found");
      }

      final repo = ref.read(profileRepositoryProvider);
      return repo.watchUserProfileStats(user.id);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => const Stream.empty(),
  );
});