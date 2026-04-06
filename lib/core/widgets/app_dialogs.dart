import 'package:flutter/material.dart';

class AppDialogs {
  static Future<bool?> confirm(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String confirmText,
    required Color confirmColor,
    bool destructive = false,
  }) async {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON CONTAINER
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              /// DESCRIPTION
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                ),
              ),

              const SizedBox(height: 22),

              /// ACTION BUTTONS
              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, false), 
                      child: Text("Cancel"),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style:  ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true), 
                      child: Text(confirmText, style: TextStyle(color: Colors.white)),
                    )
                  )
                ],
              ) 
            ],
          ),
        );
      },
    );
  }
}