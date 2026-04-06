import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/navigation/navigation_provider.dart';
import 'package:stackhive/features/profile/presentation/profile_screen.dart';
import 'package:stackhive/features/question/presentation/ask_question_screen.dart';
import 'package:stackhive/features/question/presentation/home_screen.dart';
import 'package:stackhive/features/question/presentation/search_screen.dart';
import 'package:stackhive/features/saved/presentation/saved_questions_screen.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FirstScreen extends ConsumerStatefulWidget {
  const FirstScreen({super.key});

  @override
  ConsumerState<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends ConsumerState<FirstScreen> {
  final List<Widget> screens = [
    HomeScreen(), //0
    SearchScreen(), //1
    AskQuestionScreen(), //2
    SavedQuestionsScreen(), //3
    ProfileScreen(), //4
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex, children: screens
      ),


      // MODERN FLOATING NAV BAR
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                _navItem(
                  context, 
                  icon: Icons.home_outlined, 
                  activeIcon: Icons.home, 
                  index: 0, 
                  selectedIndex: selectedIndex
                ),

                _navItem(
                  context, 
                  icon: Icons.search_outlined, 
                  activeIcon: Icons.search_outlined, 
                  index: 1, 
                  selectedIndex: selectedIndex
                ),

                // CENTER FAB
                GestureDetector(
                  onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),



                _navItem(
                  context, 
                  icon: Icons.bookmark_border, 
                  activeIcon: Icons.bookmark, 
                  index: 3, 
                  selectedIndex: selectedIndex
                ),

                _navItem(
                  context, 
                  icon: Icons.account_circle_outlined, 
                  activeIcon: Icons.account_circle, 
                  index: 4, 
                  selectedIndex: selectedIndex
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required int selectedIndex,
  }) {
    final theme = Theme.of(context);
    final isSelected = index == selectedIndex;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Icon(
          isSelected ? activeIcon : icon,
          key: ValueKey(isSelected),
          size: 26,
          color: isSelected
            ? theme.colorScheme.primary
            : theme.iconTheme.color,
        ),
      ),
      onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = index,
    );
  }

}


/* Circular FAB (FloatingActionButton)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 70, width: 70,
        child: FloatingActionButton(
          onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
          shape: CircleBorder(),
          backgroundColor: Colors.grey.shade200,
          elevation: 6,
          child: Icon(Icons.add, color: Colors.black, size: 28),
        ),
),*/

