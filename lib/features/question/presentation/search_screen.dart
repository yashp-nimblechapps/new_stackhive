import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';
import 'package:stackhive/models/question_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  String searchText = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final searchAsync = searchText.isEmpty
        ? null
        : ref.watch(searchQuestionProvider(searchText));

    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search by keyword, tags...',
                prefixIcon: Icon(Icons.search),

                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            searchText = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value) {
                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }
                _debounce = Timer(Duration(milliseconds: 400), () {
                  setState(() {
                    searchText = value.trim().toLowerCase();
                  });
                });
              },
            ),
          ),

          // RESULTS AREA
          Expanded(
            child: searchText.isEmpty
                ? _searchEmptyState()
                : searchAsync!.when(
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (questions) {
                      if (questions.isEmpty) {
                        return _noResults();
                      }

                      return ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: questions.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final question = questions[index];

                          return _searchResultCard(context, question);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _searchResultCard(BuildContext context, QuestionModel question) {
  final theme = Theme.of(context);

  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
      context.push('/detailQues/${question.id}');
    },

    child: Container(
      padding:  EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE
          Text(question.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),

          /// DESCRIPTION
          Text(question.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: 10),

          /// TAGS
          Wrap(
            spacing: 6,
            children: question.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                child: Text(tag, style: theme.textTheme.labelSmall),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _searchEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search, size: 70, color: Colors.grey),
        SizedBox(height: 16),
         Text('Search for questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text('Find answers shared by the community', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

Widget _noResults() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 70, color: Colors.grey),
        SizedBox(height: 16),
        Text('No results found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text('Try different keywords', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}