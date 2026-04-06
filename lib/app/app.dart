import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/app/router.dart';
import 'package:stackhive/core/theme/app_theme.dart';
import 'package:stackhive/core/theme/theme_provider.dart';

class StackHiveApp extends ConsumerWidget {
  const StackHiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    final _ = ref.watch(themeProvider);
    final themeController = ref.read(themeProvider.notifier);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      themeAnimationDuration: Duration(milliseconds: 300),

      routerConfig: router,
    );
  }
}

// Now the app reacts automatically to theme changes.
