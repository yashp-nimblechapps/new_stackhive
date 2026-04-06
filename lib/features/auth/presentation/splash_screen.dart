import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool isDark = true;
  Timer? _themeTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Animate background change
    _themeTimer = Timer(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        isDark = false;
      });
    });

    // Wait 3 seconds then check auth
    _navigationTimer = Timer(Duration(seconds: 2), () async {
      if (!mounted) return;

      final authState = ref.watch(authStateProvider);

      final isUser = ref.watch(currentUserProvider).value;
      final isAdmin = isUser?.role == 'admin';

      authState.whenData((user) {
        if (!mounted) return;

        if (user == null) {
          context.go('/login');
        } else if (isAdmin) {
          context.go('/admin');
        } else {
          context.go('/first');
        }
      });
    });

    @override
    // ignore: unused_element
    void dispose() {
      _themeTimer?.cancel();
      _navigationTimer?.cancel();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        color: isDark ? Colors.black : Colors.white,
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/stackhive_blue.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
