import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/app/app_navigator.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_account_status_screen.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:stackhive/features/admin/presentation/screens/analytics_screen.dart';
import 'package:stackhive/features/admin/presentation/screens/moderation_detail_screen.dart';
import 'package:stackhive/features/admin/presentation/screens/moderation_screen.dart';
import 'package:stackhive/features/admin/presentation/screens/tag_management_screen.dart';
import 'package:stackhive/features/admin/presentation/screens/user_management_screen.dart';
import 'package:stackhive/features/auth/presentation/login_screen.dart';
import 'package:stackhive/features/auth/presentation/register_screen.dart';
import 'package:stackhive/features/auth/presentation/splash_screen.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';
import 'package:stackhive/features/notifications/presentation/notification_screen.dart';
import 'package:stackhive/features/notifications/presentation/notification_settings_screen.dart';
import 'package:stackhive/features/profile/presentation/admin_profile_screen.dart';
import 'package:stackhive/features/profile/presentation/profile_screen.dart';
import 'package:stackhive/features/question/presentation/ask_question_screen.dart';
import 'package:stackhive/features/auth/presentation/first_screen.dart';
import 'package:stackhive/features/question/presentation/home_screen.dart';
import 'package:stackhive/features/question/presentation/question_detail_screen.dart';
import 'package:stackhive/features/question/presentation/search_screen.dart';
import 'package:stackhive/features/report/presentation/admin_reports_screen.dart';
import 'package:stackhive/features/saved/presentation/saved_questions_screen.dart';
import 'package:stackhive/features/setting/presentation/about_app_screen.dart';
import 'package:stackhive/features/setting/presentation/account_detail_screen.dart';
import 'package:stackhive/features/setting/presentation/account_status_screen.dart';
import 'package:stackhive/features/setting/presentation/help_support_screen.dart';
import 'package:stackhive/features/setting/presentation/privacy_policy_screen.dart';
import 'package:stackhive/features/setting/presentation/settings_screen.dart';
import 'package:stackhive/features/setting/presentation/theme_change_screen.dart';
import 'package:stackhive/models/user_model.dart';

// GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',

    redirect: (context, state) {
      final user = userAsync.value;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Still loading user
      if (userAsync.isLoading) return null;

      // Not logged in → go to login
      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      // Logged in & trying to access login/register
      if (isLoggingIn) {
        return user.role == 'admin' ? '/admin' : '/';
      }

      // Protect ALL admin routes
      if (state.matchedLocation.startsWith('/admin') && user.role != 'admin') {
        return '/first';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/first', builder: (context, state) => const FirstScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/askQues',
        builder: (context, state) => const AskQuestionScreen(),
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedQuestionsScreen(),
      ),

      GoRoute(
        path: '/detailQues/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return QuestionDetailScreen(id: id);
        },
      ),

      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/accDetail',
        builder: (context, state) => const AccountDetailScreen(),
      ),
      GoRoute(
        path: '/accStatus',
        builder: (context, state) => const AccountStatusScreen(),
      ),
      GoRoute(
        path: '/theme',
        builder: (context, state) => const ThemeChangeScreen(),
      ),
      GoRoute(
        path: '/notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/aboutApp',
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/helpsupport',
        builder: (context, state) => const HelpSupportScreen(),
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: '/adminProfile',
            builder: (context, state) => const AdminProfileScreen(),
          ),
          GoRoute(
            path: '/userManage',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: '/tagManage',
            builder: (context, state) => const TagManagementScreen(),
          ),
          GoRoute(
            path: '/moderation',
            builder: (context, state) => const ModerationScreen(),
          ),

          GoRoute(
            path: '/moderation/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ModerationDetailScreen(questionId: id);
            },
          ),

          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/report',
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: '/adminAccStatus',
            builder: (context, state) => const AdminAccountStatusScreen(),
          ),
        ],
      ),
    ],
  );

  ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
