import 'package:stackhive/core/theme/theme_preference.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isBlocked;
  final ThemePreference themePreference;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.themePreference,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
      isBlocked: map['isBlocked'] ?? false,
      themePreference: ThemePreferenceX.fromString(map['themePreference']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name, 
      'email': email, 
      'role': role, 
      'isBlocked': isBlocked,
      'themePreference': themePreference.value,
      
    };
  }
}
