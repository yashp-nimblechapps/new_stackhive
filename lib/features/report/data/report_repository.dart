import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository(this._firestore);

  Future<void> submitReport(ReportModel report) async {
    final existingReport = await _firestore
        .collection('reports')
        .where('contentId', isEqualTo: report.contentId)
        .where('reportedBy', isEqualTo: report.reportedBy)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingReport.docs.isNotEmpty) {
      throw Exception("You have already reported this content.");
    }

    final docRef = _firestore.collection('reports').doc();

    await docRef.set(report.toMap());
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
    required String adminId,
  }) async {
    await _firestore
        .collection('reports')
        .doc(reportId)
        .update({
          'status': newStatus,
          'resolvedAt': FieldValue.serverTimestamp(),
          'resolvedBy': adminId,
        });
  }
}


/*
Without this:
User can spam report button
Admin dashboard becomes messy
Analytics becomes inaccurate

With this:
✔ One active report per user per content
✔ Clean moderation system
✔ Better UX
*/