import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/data/question_repository.dart';
import 'package:stackhive/features/question/data/question_sort.dart';
import 'package:stackhive/features/tag/provider/tag_provider.dart';
import 'package:stackhive/models/question_model.dart';

// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// Question Repository provider
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  final tagRepo = ref.read(tagRepositoryProvider);

  return QuestionRepository(firestore, tagRepo);
});

// Stream provider for all question (Home Feed)
final questionListProvider = StreamProvider<List<QuestionModel>>((ref) {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getAllQuestions();
});

// Stream provider for single question detail
final questionDetailProvider = StreamProvider.family<QuestionModel?, String>((
  ref,
  id,
) {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionById(id);
});

final filteredQuestionProvider =
    StreamProvider.family<List<QuestionModel>, String>((ref, tag) {
      final repo = ref.read(questionRepositoryProvider);
      return repo.getQuestionsByTag(tag);
    });

final searchQuestionProvider =
    StreamProvider.family<List<QuestionModel>, String>((ref, keyword) {
      final repo = ref.read(questionRepositoryProvider);
      return repo.searchQuestions(keyword);
    });

final questionUserVoteProvider =
    StreamProvider.family<int?, ({String questionId, String userId})>((ref,params,) {
      
      final repo = ref.watch(questionRepositoryProvider);

      return repo.getUserVote(
        questionId: params.questionId,
        userId: params.userId,
      );
    });

// Pagination Class and Provider

class PaginatedQuestionsNotifier extends StateNotifier<List<QuestionModel>> {
  PaginatedQuestionsNotifier(this._repo, this._tag, this._sort) : super([]);

  final QuestionRepository _repo;
  final String? _tag;
  final QuestionSort _sort;

  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> loadInitial() async {
    state = [];
    _lastDoc = null;
    _hasMore = true;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;

    final (newQuestions, lastDoc) = await _repo.fetchQuestionsPaginated(
      tag: _tag,
      sort: _sort,
      lastDoc: _lastDoc,
    );

    if (newQuestions.isEmpty) {
      _hasMore = false;
    } else {
      state = [...state, ...newQuestions];
      _lastDoc = lastDoc;
    }

    _isLoading = false;
  }

  void removeLocalQuestion(String questionId) {
    state = state.where((q) => q.id != questionId).toList();
  }

  void updateLocalQuestion(QuestionModel updated) {
    state = [
      for (final q in state)
        if (q.id == updated.id) updated else q,
    ];
  }

  void updateLocalVote(String questionId, int change) {
    state = state.map((q) {
      if (q.id == questionId) {
        return q.copyWith(voteCount: q.voteCount + change);
      }
      return q;
    }).toList();
  }
}

// pagination provider
// Now pagination depends on selectedTag
final paginatedQuestionsProvider =
    StateNotifierProvider.family<
      PaginatedQuestionsNotifier,
      List<QuestionModel>,
      PaginationParams
    >((ref, params) {
      final repo = ref.read(questionRepositoryProvider);

      return PaginatedQuestionsNotifier(repo, params.tag, params.sort);
    });

// Sort provider
final questionSortProvider = StateProvider((ref) {
  return QuestionSort.Newest;
});
