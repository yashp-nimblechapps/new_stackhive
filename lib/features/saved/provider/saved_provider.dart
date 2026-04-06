import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import '../data/saved_repository.dart';

final savedRepositoryProvider = Provider((ref) {
  return SavedRepository();
});

/// STREAM OF SAVED QUESTION IDS
final savedQuestionsProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(savedRepositoryProvider);
  final user = ref.watch(currentUserProvider).value;

  if (user == null) {
    return const Stream.empty();
  }

  return repo.getSavedIds(user.id);
});

final toggleSaveProvider = Provider((ref) => ToggleSaveController(ref));

class ToggleSaveController {
  final Ref ref;

  ToggleSaveController(this.ref);

  Future<void> toggle(String questionId) async {
    final repo = ref.read(savedRepositoryProvider);
    final user = ref.read(currentUserProvider).value;

    if (user == null) return;

    final isSaved = await repo.isSaved(user.id, questionId);

    if (isSaved) {
      await repo.removeSaved(user.id, questionId);
    } else {
      await repo.saveQuestion(user.id, questionId);
    }
  }
}
