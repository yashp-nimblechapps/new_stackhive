import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/models/profileStats_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository(this._firestore);

  Stream<ProfileStats> watchUserProfileStats(String userId) {
    return _firestore
        .collection('questions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((questionSnapshot) async {

      int questionCount = questionSnapshot.docs.length;
      int answerCount = 0;
      int totalVotes = 0;

      for (var questionDoc in questionSnapshot.docs) {
        final questionData = questionDoc.data();
        totalVotes += (questionData['voteCount'] ?? 0) as int;

        // Get answers subcollection
        final answersSnapshot = await questionDoc.reference
            .collection('answers')
            .get();

        for (var answerDoc in answersSnapshot.docs) {
          final answerData = answerDoc.data();
          answerCount++;
          totalVotes += (answerData['voteCount'] ?? 0) as int;
        }
      }

      return ProfileStats(
        questionCount: questionCount,
        answerCount: answerCount,
        totalVotes: totalVotes,
      );
    });
  }
}