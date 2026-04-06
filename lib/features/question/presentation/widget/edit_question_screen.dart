import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';
import 'package:stackhive/features/tag/provider/selected_tag_provider.dart';
import 'package:stackhive/models/question_model.dart';
class EditQuestionScreen extends ConsumerStatefulWidget {
  final QuestionModel question;

  const EditQuestionScreen({
    super.key,
    required this.question,
  });

  @override
  ConsumerState<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends ConsumerState<EditQuestionScreen> {

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController tagsController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.question.title);
    descriptionController =
        TextEditingController(text: widget.question.description);

    tagsController =
        TextEditingController(text: widget.question.tags.join(','));
  }

  Future<void> save() async {
    final repo = ref.read(questionRepositoryProvider);

    final selectedTag = ref.read(selectedTagProvider);
    final selectedSort = ref.read(questionSortProvider);

    final params = PaginationParams(tag: selectedTag, sort: selectedSort);

    final notifier =
        ref.read(paginatedQuestionsProvider(params).notifier);

    setState(() => isSaving = true);

    try {

      final tags = tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

      await repo.updateQuestion(
        questionId: widget.question.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        tags: tags,
      );

      final updated = widget.question.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        tags: tags,
      );


      notifier.updateLocalQuestion(updated);

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.show("Question updated", type: SnackType.success);
      }

    } catch (e) {
      AppSnackBar.show("Update failed", type: SnackType.error);
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: Text("Edit Question"),
        actions: [
          TextButton(
            onPressed: isSaving ? null : save,
            child: isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text("Save"),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            /// TITLE
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "What's your programming question?",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            /// DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Explain your problem in detail...",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            /// TAGS
            TextField(
              controller: tagsController,
              decoration: InputDecoration(
                labelText: "Tags",
                hintText: "flutter, firebase, dart",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : save,
                child: isSaving
                    ? CircularProgressIndicator()
                    : Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }
}