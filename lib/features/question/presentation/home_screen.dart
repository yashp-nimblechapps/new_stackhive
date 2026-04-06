import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/core/navigation/navigation_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/notifications/provider/notification_provider.dart';
import 'package:stackhive/features/question/data/pagination_params.dart';
import 'package:stackhive/features/question/data/question_sort.dart';
import 'package:stackhive/features/question/presentation/widget/home_question_card.dart';
import 'package:stackhive/features/question/presentation/widget/showQuesActions.dart';
import 'package:stackhive/features/question/provider/question_provider.dart';
import 'package:stackhive/features/tag/provider/selected_tag_provider.dart';
import 'package:stackhive/features/tag/provider/tag_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final selectedTag = ref.read(selectedTagProvider);
      final selectedSort = ref.watch(questionSortProvider);

      final params = PaginationParams(tag: selectedTag, sort: selectedSort);
      ref.read(paginatedQuestionsProvider(params).notifier).loadInitial();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final selectedTag = ref.read(selectedTagProvider);
        final selectedSort = ref.watch(questionSortProvider);

        final params = PaginationParams(tag: selectedTag, sort: selectedSort);

        ref.read(paginatedQuestionsProvider(params).notifier).loadMore();
      }
    });
  }

  String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tag changes
    ref.listen<String?>(selectedTagProvider, (previous, next) {
      final selectedSort = ref.watch(questionSortProvider);
      final params = PaginationParams(tag: next, sort: selectedSort);

      ref.read(paginatedQuestionsProvider(params).notifier).loadInitial();
    });

    // Sort changes
    ref.listen<QuestionSort>(questionSortProvider, (previous, next) {
      final selectedTag = ref.read(selectedTagProvider);

      final params = PaginationParams(tag: selectedTag, sort: next);
      ref.read(paginatedQuestionsProvider(params).notifier).loadInitial();
    });

    final selectedTag = ref.watch(selectedTagProvider);
    final selectedSort = ref.watch(questionSortProvider);

    final params = PaginationParams(tag: selectedTag, sort: selectedSort);

    final questions = ref.watch(paginatedQuestionsProvider(params));
    final notifier = ref.read(paginatedQuestionsProvider(params).notifier);

    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/stackhive_blue.png',
              width: 35,
              height: 35,
            ),
            SizedBox(width: 8),
            Text('StackHive', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [_notificationItem(context)],
      ),

      body: Column(
        children: [
          // TAGS
          _tagChips(),
          SizedBox(height: 8),

          // SORT MENU
          _sortMenu(),
          SizedBox(height: 8),

          // QUESTION LIST
          Expanded(
            child: questions.isEmpty
                ? (notifier.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _emptyState())
                : userAsync.when(
                    data: (user) {
                      final isBlocked = user?.isBlocked ?? false;

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: questions.length + 1,
                        itemBuilder: (context, index) {
                          if (index < questions.length) {
                            final question = questions[index];

                            return HomeScreenQuestionCard(
                              question: question,
                              isBlocked: isBlocked,
                              onMore: () =>
                                  showQuesActions(context, ref, question),
                            );
                          }

                          if (notifier.hasMore) {
                            return Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return SizedBox();
                        },
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error $e')),
                  ),
          ),
        ],
      ),
    );
  }

  // SORT MENU
  Widget _sortMenu() {
    return Consumer(
      builder: (context, ref, _) {
        final selected = ref.watch(questionSortProvider);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PopupMenuButton<QuestionSort>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  ref.read(questionSortProvider.notifier).state = value;
                },
                itemBuilder: (context) {
                  return QuestionSort.values.map((sort) {
                    return PopupMenuItem(value: sort, child: Text(sort.name));
                  }).toList();
                },
                child: Row(
                  children: [
                    Text(
                      selected.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tagChips() {
    return Consumer(
      builder: (context, ref, _) {
        final tagsAsync = ref.watch(allTagsProvider);
        final selectedTag = ref.watch(selectedTagProvider);

        return tagsAsync.when(
          data: (tags) {
            if (tags.isEmpty) {
              return Container(
                height: 50,
                color: Colors.yellow,
                alignment: Alignment.center,
              );
            }

            return Container(
              height: 45,
              padding: EdgeInsets.only(left: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tags.length + 1,
                itemBuilder: (context, index) {
                  // First chip = "All"
                  if (index == 0) {
                    final isSelected = selectedTag == null;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text('All'),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        onSelected: (_) {
                          ref.read(selectedTagProvider.notifier).state = null;
                        },
                      ),
                    );
                  }

                  // Other chips
                  final tag = tags[index - 1];
                  final isSelected = selectedTag == tag.name;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (_) {
                        if (isSelected) {
                          ref.read(selectedTagProvider.notifier).state = null;
                        } else {
                          ref.read(selectedTagProvider.notifier).state =
                              tag.name;
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(),
        );
      },
    );
  }

  // EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),

          Text(
            'No questions yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          Text(
            'Be the first to ask something 🚀',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () =>
                ref.read(bottomNavIndexProvider.notifier).state = 2,
            child: Text('Ask Question'),
          ),
        ],
      ),
    );
  }
}

Widget _notificationItem(BuildContext context) {
  return Consumer(
    builder: (context, ref, _) {
      final unreadCount = ref.watch(unreadCountProvider);
      final theme = Theme.of(context);

      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: 26,
              color: theme.iconTheme.color,
            ),
            onPressed: () => context.push('/notifications'),
          ),

          if (unreadCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}


/*

Home loads
Shows circular loader
Then shows all questions
If you add new question → appears instantly

Show list of questions
Real-time updates
Title
Vote count
Tags
Created time

//////Tag 
If no chip selected → normal feed
If chip selected → filtered feed

Dynamic switching.
No extra screens.
Clean architecture.

*/