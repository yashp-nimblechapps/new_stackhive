import 'package:cloud_firestore/cloud_firestore.dart';

class SavedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference savedRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('savedQuestions');

  // SAVE
  Future<void> saveQuestion(String uid, String questionId) async {
    await savedRef(uid).doc(questionId).set({
      'questionId': questionId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  // REMOVE
  Future<void> removeSaved(String uid, String questionId) async {
    await savedRef(uid).doc(questionId).delete();
  }

  // STREAM SAVED IDS
  Stream<List<String>> getSavedIds(String uid) {
    return savedRef(uid).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toList(),
    );
  }

  // CHECK IF SAVED
  Future<bool> isSaved(String uid, String questionId) async {
    final doc = await savedRef(uid).doc(questionId).get();
    return doc.exists;
  }
}
