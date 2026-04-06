import 'package:flutter/material.dart';
import 'package:stackhive/app/app_navigator.dart';

class AppSnackBar {
  static OverlayEntry? _current;

  static void show(
    String message, {
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = navigatorKey.currentContext;
    final overlay = navigatorKey.currentState?.overlay;

    if (context == null || overlay == null) return;

    final theme = Theme.of(context);

    _current?.remove();

    late OverlayEntry overlayEntry;

    bool isRemoved = false;

    void remove() {
      if (isRemoved) return;
      isRemoved = true;
      overlayEntry.remove();
      _current = null;
    }

    overlayEntry = OverlayEntry(
      builder: (_) => _TopSnackBar(
        message: message,
        type: type,
        duration: duration,
        theme: theme,
        onDismiss: remove,
      ),
    );

    _current = overlayEntry;

    overlay.insert(overlayEntry);
  }
}

enum SnackType { success, error, info }

class _TopSnackBar extends StatefulWidget {
  final String message;
  final SnackType type;
  final Duration duration;
  final ThemeData theme;
  final VoidCallback onDismiss;

  const _TopSnackBar({
    required this.message,
    required this.type,
    required this.duration,
    required this.theme,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;

      await _controller.reverse();
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    IconData icon;
    Color color;

    switch (widget.type) {
      case SnackType.success:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;

      case SnackType.error:
        icon = Icons.error_outline;
        color = theme.colorScheme.error;
        break;

      case SnackType.info:
        icon = Icons.info_outline;
        color = theme.colorScheme.primary;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => widget.onDismiss(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withValues(alpha: .08),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// ICON CONTAINER
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),

                  const SizedBox(width: 12),

                  /// MESSAGE
                  Expanded(
                    child: Text(
                      widget.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
