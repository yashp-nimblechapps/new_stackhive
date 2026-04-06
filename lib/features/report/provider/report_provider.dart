import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/report/data/report_repository.dart';
import 'package:stackhive/models/report_model.dart';

// Repository Provider
final reportRepositoryProvider = Provider((ref) => ReportRepository(FirebaseFirestore.instance));

// Controller Provider
final reportControllerProvider =
    StateNotifierProvider<ReportController, AsyncValue<void>>((ref) => ReportController(
      ref,ref.read(reportRepositoryProvider),
    ),
);

class ReportController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final ReportRepository _repository;

  ReportController(this.ref, this._repository)
      : super(const AsyncData(null));

  Future<void> submitReport({
    required String contentId,
    required String contentType,
    required String parentId,
    required String reason,
  }) async {
    if (!mounted) return;
    state = const AsyncLoading();

    try {
      final user = ref.read(currentUserProvider).value;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      final report = ReportModel(
        id: '',
        contentId: contentId,
        contentType: contentType,
        parentId: parentId, 
        reportedBy: user.id,
        reportedByName: user.name,
        reason: reason,
        createdAt: DateTime.now(),
        status: 'pending', 
      );

      await _repository.submitReport(report);

      if (!mounted) return;

      state = const AsyncData(null); 
    } catch (e, st) {
      if (!mounted) return; 
      
      state = AsyncError(e, st);
    }
  }

  Future<void> updateStatus({
    required String reportId,
    required String newStatus,
  }) async {
    try {
      state = const AsyncLoading();

      final currentUser = ref.read(currentUserProvider);
      final admin = currentUser.value;
      
      await _repository.updateReportStatus(
        reportId: reportId, 
        newStatus: newStatus,
        adminId: admin!.id,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteReport(String reportId) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .delete();
  }


}

final reportsProvider = StreamProvider<List<ReportModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (adminUser) {
      if (adminUser == null || adminUser.role != 'admin') {
        return const Stream.empty();
      }

      return FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data(), doc.id)).toList();
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