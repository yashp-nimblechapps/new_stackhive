import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/theme/theme_preference.dart';

class ThemeController extends StateNotifier<ThemePreference> {
  ThemeController() : super(ThemePreference.system);

  final _firestore = FirebaseFirestore.instance;

  // Convert to FLutter ThemeMode
  ThemeMode get themeMode {
    switch (state) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  // Load theme from user profile
  void loadTheme(ThemePreference preference) {
    state = preference;
  }

  // Change theme + save to Firestore
  Future<void> setTheme(ThemePreference preference, String userId) async {
    state = preference;

    await _firestore.collection('users').doc(userId).update({
      'themePreference': preference.value,
    });
  }
}

final themeProvider = StateNotifierProvider<ThemeController, ThemePreference>(
  (ref) => ThemeController(),
);

/*
Responsibilities:

Load user's theme preference
Convert it to ThemeMode
Allow changing theme
Update Firestore
Update UI instantly
*/
