import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/tag/data/tag_repository.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(FirebaseFirestore.instance);
});

final allTagsProvider= StreamProvider((ref) {
  return ref.read(tagRepositoryProvider).getAllTags();
});