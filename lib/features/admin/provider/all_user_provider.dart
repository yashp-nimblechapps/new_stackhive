import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/models/user_model.dart';

final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (adminUser) {
      if (adminUser == null || adminUser.role != 'admin') {
        return const Stream.empty();
      }

      return FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
          .snapshots()
          .map((snapshots) {
            return snapshots.docs
                .map((doc) => AppUser.fromMap(doc.data(), doc.id))
                .toList();
          });
    },

    loading: () {
      return const Stream.empty();
    },

    error: (e, _) {
      return const Stream.empty();
    },
  );
});