import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/theme/theme_provider.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/models/user_model.dart';

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (authUser) {
      if (authUser == null) {
        return Stream.value(null);
      }

      return FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;

            final user = AppUser.fromMap(doc.data()!, doc.id);

            /// load theme
            ref.read(themeProvider.notifier).loadTheme(user.themePreference);

            return user;
          });
    },

    loading: () => const Stream.empty(),

    error: (_, _) => const Stream.empty(),
  );
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});
