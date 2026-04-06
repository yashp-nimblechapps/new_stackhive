import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/theme/app_colors.dart';
import 'package:stackhive/core/theme/theme_preference.dart';
import 'package:stackhive/core/theme/theme_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class ThemeChangeScreen extends ConsumerWidget {
  const ThemeChangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themeProvider);
    final themeController = ref.read(themeProvider.notifier);

    final userId = ref.read(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground, 
        title: Text("Appearance")
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _themeCard(
              context,
              title: 'System',
              subtitle: 'Follow device theme',
              icon: Icons.settings_suggest,
              selected: themePreference == ThemePreference.system,
              onTap: () => themeController.setTheme(ThemePreference.system, userId!),
            ),
            SizedBox(height: 12),

            _themeCard(
              context,
              title: 'Light',
              icon: Icons.light_mode,
              subtitle: 'Always use light mode',
              selected: themePreference == ThemePreference.light,
              onTap: () => themeController.setTheme(ThemePreference.light, userId!),
            ),
            SizedBox(height: 12),

            _themeCard(
              context,
              title: 'Dark',
              subtitle: 'Always use dark mode',
              icon: Icons.dark_mode,
              selected: themePreference == ThemePreference.dark,
              onTap: () => themeController.setTheme(ThemePreference.dark, userId!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: colorScheme.primary),
            ),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),

            if (selected) Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
