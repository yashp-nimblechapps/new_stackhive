import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/models/user_model.dart';

final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final authAsync = ref.watch(authStateProvider);

  final firebaseUser = authAsync.valueOrNull;

  if (firebaseUser == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return AppUser.fromMap(doc.data()!, doc.id);
      });
});

// switches Firestore doc based on UID

// Listens to Firestore document based on UID
// Returns AppUser?
// Automatically switches when UID changes