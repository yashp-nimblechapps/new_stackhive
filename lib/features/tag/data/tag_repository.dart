import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/models/tag_model.dart';

class TagRepository {
  final FirebaseFirestore _firestore;

  TagRepository(this._firestore);

  CollectionReference get _tagRef => _firestore.collection('tags');

  // Create Tag
  Future<void> createTag(String name) async {
    final doc = _tagRef.doc(name.toLowerCase());

    await doc.set({
      'name': name.toLowerCase(),
      'usageCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get All Tags
  Stream<List<TagModel>> getAllTags() {
    return _tagRef.orderBy('usageCount', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(
            (doc) =>
                TagModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  // Increment Usage (Transaction)
  Future<void> incrementTagUsage(String tagName) async {
    final docRef = _tagRef.doc(tagName.toLowerCase());
    final statsRef = _firestore.collection('stats').doc('global');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // NEW TAG CREATED
        transaction.set(docRef, {
          'name': tagName.toLowerCase(),
          'usageCount': 1,
          'createdAt': Timestamp.now(),
        });

        transaction.set(statsRef, {
          'totalTags': FieldValue.increment(1),
        }, SetOptions(merge: true));
      } else {
        final currentCount = snapshot['usageCount'] ?? 0;
        transaction.update(docRef, {'usageCount': currentCount + 1});
      }
    });
  }

  // Delete Tag (Admin)
  Future<void> deleteTag(String tagId) async {
    final docRef = _tagRef.doc(tagId);
    final statsRef = _firestore.collection('stats').doc('global');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      transaction.delete(docRef);

      transaction.update(statsRef, {'totalTags': FieldValue.increment(-1)});
    });
  }
}

/*
Using tag name as document ID → prevents duplicates
Using transaction → safe increments
Scalable pattern
*/
