enum ThemePreference {
  light,
  dark,
  system,
}

extension ThemePreferenceX on ThemePreference {
  String get value {
    switch (this) {
      case ThemePreference.light:
        return 'light';
      case ThemePreference.dark:
        return 'dark';
      case ThemePreference.system:
        return 'system';
    }
  }

  static ThemePreference fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemePreference.light;
      case 'dark':
        return ThemePreference.dark;
      case 'system':
      default:
        return ThemePreference.system;
    }
  }
}