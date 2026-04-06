import 'package:flutter/material.dart';

class AdminSidebarItem extends StatelessWidget {
  final AdminNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const AdminSidebarItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              /// ICON CONTAINER
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              /// LABEL
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),

              /// ACTIVE INDICATOR
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1 : 0,
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminNavItem {
  final String title;
  final IconData icon;
  final String route;

  const AdminNavItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

const adminNavItems = [
  AdminNavItem(
    title: "Dashboard",
    icon: Icons.dashboard_outlined,
    route: "/admin",
  ),
  AdminNavItem(
    title: "User Management",
    icon: Icons.manage_accounts_outlined,
    route: "/admin/userManage",
  ),
  AdminNavItem(
    title: "Tag Management",
    icon: Icons.local_offer_outlined,
    route: "/admin/tagManage",
  ),
  AdminNavItem(
    title: "Moderation",
    icon: Icons.shield_outlined,
    route: "/admin/moderation",
  ),
  AdminNavItem(
    title: "Analytics",
    icon: Icons.analytics_outlined,
    route: "/admin/analytics",
  ),
  AdminNavItem(
    title: "Reported Questions",
    icon: Icons.report_gmailerrorred_outlined,
    route: "/admin/report",
  ),
  AdminNavItem(
    title: "Settings",
    icon: Icons.settings_outlined,
    route: "/settings",
  ),
];