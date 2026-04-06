import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/report/provider/report_provider.dart';

class ShowReportBottomSheet extends ConsumerStatefulWidget {
  final String contentId;
  final String contentType;
  final String parentId;

  const ShowReportBottomSheet({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.parentId,
  });

  static void show(
    BuildContext context,
    WidgetRef ref, {
    required String contentId,
    required String contentType,
    required String parentId,
  }) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (_) => ShowReportBottomSheet(
        contentId: contentId, contentType: contentType, parentId: parentId)
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowReportBottomSheetState();
}

class _ShowReportBottomSheetState extends ConsumerState<ShowReportBottomSheet> {
  String selectedReason = "Spam"; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Report Content",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 20),

          DropdownButtonFormField(
            initialValue: selectedReason,
            items: [
              DropdownMenuItem(value: 'Spam', child: Text('Spam')),
              DropdownMenuItem(value: 'Abusive', child: Text('Abusive')),
              DropdownMenuItem(value: 'Incorrect Info',child: Text('Incorrect Info')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              selectedReason = value!;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Reason",
            ),
          ),

          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final controller = ref.read(reportControllerProvider.notifier);

                  await controller.submitReport(
                    contentId: widget.contentId,
                    contentType: widget.contentType,
                    reason: selectedReason,
                    parentId: widget.parentId,
                  );

                  AppSnackBar.show(
                    "Report Submitted",
                    type: SnackType.info,
                  );

                  if (!context.mounted) return;

                  Navigator.pop(context);

                } catch (e) {
                  if (context.mounted) {}
                }
              },
              child: Text("Submit Report"),
            ),
          ),
        ],
      ),
    );
  }
}
