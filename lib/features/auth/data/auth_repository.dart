import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stackhive/core/theme/theme_preference.dart';
import 'package:stackhive/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    final appUser = AppUser(
      id: user.uid,
      name: name,
      email: email,
      role: 'employee',
      isBlocked: false,
      themePreference: ThemePreference.system,
    );

    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(user.uid);
    final statsRef = _firestore.collection('stats').doc('global');

    batch.set(userRef, appUser.toMap());

    batch.update(statsRef, {'totalUsers': FieldValue.increment(1)});
    await batch.commit();
    return appUser;
  }

  // Login
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userDoc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception("User profile not found in Firestore.");
    }

    return AppUser.fromMap(userDoc.data()!, userDoc.id);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get Current User
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> deleteUserAccount(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      /// STEP 1: Pick Google account
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception("Google sign-in cancelled");
      }

      /// STEP 2: Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      /// STEP 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      /// STEP 4: Sign in to Firebase
      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user!;
      final userRef = _firestore.collection('users').doc(user.uid);

      final userDoc = await userRef.get();

      /// STEP 5: If NEW USER → create Firestore doc
      if (!userDoc.exists) {
        final newUser = AppUser(
          id: user.uid,
          name: user.displayName ?? "User",
          email: user.email ?? "",
          role: 'employee',
          isBlocked: false,
          themePreference: ThemePreference.system,
        );

        final batch = _firestore.batch();

        batch.set(userRef, newUser.toMap());

        /// optional: increment stats
        final statsRef = _firestore.collection('stats').doc('global');
        batch.update(statsRef, {
          'totalUsers': FieldValue.increment(1),
        });

        await batch.commit();
        return newUser;
      }

      /// STEP 6: Existing user
      return AppUser.fromMap(userDoc.data()!, userDoc.id);

    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }
}

//What This Does

//When user registers:
//1 Creates Firebase Auth account
//2Creates Firestore document
//3 Saves role = employee
//This is important for future admin control.
