import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/navigation/navigation_provider.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';
import 'package:stackhive/features/question/utils/search_utils.dart';
import 'package:stackhive/features/tag/provider/selected_tag_provider.dart';
import 'package:stackhive/models/question_model.dart';

class AskQuestionScreen extends ConsumerStatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitQuestion() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final keywords = generateSearchKeywords(_titleController.text);

    if (title.isEmpty || description.isEmpty) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    if (currentUser.isBlocked) {
      AppSnackBar.show('You are blocked by admin', type: SnackType.info);
    }

    setState(() => _isLoading = true);

    try {
      final question = QuestionModel(
        id: '', 
        title: title, 
        description: description, 
        tags: tags, 
        searchKeywords: keywords,
        userId: currentUser.id, 
        createdAt: DateTime.now(), 
        voteCount: 0,
        answerCount: 0,
        bestAnswerId: null, 
      );

      await ref.read(questionRepositoryProvider).createQuestion(question);
      final selectedTag = ref.read(selectedTagProvider);
      final selectedSort = ref.read(questionSortProvider);

      final params = PaginationParams(tag: selectedTag, sort: selectedSort,);

      await ref.read(paginatedQuestionsProvider(params).notifier).loadInitial();

      AppSnackBar.show(
        "Question Created Successfully",
        type: SnackType.success,
      );

      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();

      setState(() {
        _isLoading = false;
      });

      ref.read(bottomNavIndexProvider.notifier).state = 0;
      
      if (!mounted) return;
      ref.read(bottomNavIndexProvider.notifier).state = 0;
      
    } catch (e) {
      setState(() => _isLoading = false);
    } 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ask Question'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          
                  // TITLE
                  Text('Title', style: theme.textTheme.titleMedium),
                  SizedBox(height: 6),
          
                  TextField(
                    controller: _titleController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. How to fix Flutter layout overflow?',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                    ),
                  ),
                  SizedBox(height: 20),
          
                  // DESCRIPTION
                  Text('Description', style: theme.textTheme.titleMedium),
                  SizedBox(height: 6),
          
                  TextField(
                    controller: _descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Explain your issue in detail...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                    ),
                  ),
                  SizedBox(height: 20),
          
                  // TAGS
                  Text('Tags',style: theme.textTheme.titleMedium),
                  SizedBox(height: 6),
                                 
                  TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      hintText: 'flutter, dart, firebase',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Separate tags with commas',                
                    ),
                  ),
                  SizedBox(height: 30),
          
                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
          
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitQuestion, 
          
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                      ),
                      child: _isLoading
                        ? SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : Text('Post Question', style: TextStyle(fontSize: 16)),
                      ),
                    )
                  ],
                ),    
              ) 
            ),
          ),
        ),
      ),
    );
  }
}