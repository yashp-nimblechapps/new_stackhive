import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/admin/provider/all_user_provider.dart';
import 'package:stackhive/features/auth/provider/auth_provider.dart';
import 'package:stackhive/features/auth/provider/currentUserProvider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),

      data: (adminUser) {
        if (adminUser?.role != 'admin') {
          return Center(
            child: Text(
              'Admin access required',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        final users = ref.watch(allUsersProvider);

        return AdminLayout(
          title: "User Management",
          child: Column(
            children: [
              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) {
                    setState(() {
                      search = v.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search users",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// USERS LIST
              Expanded(
                child: users.when(
                  data: (list) {
                    /// remove current admin
                    final filtered = list
                        .where((u) => u.id != adminUser?.id)
                        .where(
                          (u) =>
                              u.name.toLowerCase().contains(search) ||
                              u.email.toLowerCase().contains(search),
                        )
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        final isAdmin = user.role == "admin";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  /// AVATAR
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : "U",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  /// USER INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              user.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),

                                            const SizedBox(width: 8),

                                            if (isAdmin)
                                              _badge(
                                                context,
                                                "ADMIN",
                                                theme.colorScheme.primary,
                                              )
                                            else if (user.isBlocked)
                                              _badge(
                                                context,
                                                "BLOCKED",
                                                theme.colorScheme.error,
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          user.email,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: .7),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              Row(
                                children: [
                                  
                                  /// BLOCK USER
                                  IconButton(
                                    onPressed: () async {
                                      if (user.role == 'admin') return;

                                      final confirm = await AppDialogs.confirm(
                                        context,
                                        icon: user.isBlocked ? Icons.lock_open : Icons.lock_outline,
                                        title: user.isBlocked  ? "Unblock User" : "Block User",
                                        description: user.isBlocked
                                            ? "This user will regain access."
                                            : "This user will be blocked.",
                                        confirmText: user.isBlocked  ? "Unblock" : "Block",
                                        confirmColor: theme.colorScheme.primary,
                                      );

                                      if (confirm == true) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.id)
                                            .update({
                                              'isBlocked': !user.isBlocked,
                                            });
                                        AppSnackBar.show(
                                          user.isBlocked 
                                            ? "User has been Unblocked"
                                            : "User has been Blocked",
                                          type: user.isBlocked 
                                            ? SnackType.success
                                            : SnackType.error
                                        );    
                                      }

                                    },
                                    icon: _iconContainer(
                                      context,
                                      user.isBlocked
                                          ? Icons.lock_open
                                          : Icons.lock_outline,
                                    ),
                                  ),

                                  /// DELETE USER
                                  IconButton(
                                    onPressed: () async {
                                      final confirm = await AppDialogs.confirm(
                                        context,
                                        icon: Icons.delete_outline,
                                        title: "Delete User",
                                        description:
                                            "This will permanently delete the account.",
                                        confirmText: "Delete",
                                        confirmColor: theme.colorScheme.error,
                                      );

                                      if (confirm == true) {
                                        ref
                                            .read(authRepositoryProvider)
                                            .deleteUserAccount(user.id);

                                        AppSnackBar.show(
                                          "User Acoount has been Deleted",
                                          type: SnackType.info                                          
                                        );    
                                      }
                                    },
                                    icon: _iconContainer(
                                      context,
                                      Icons.delete_outline,
                                    ),
                                  ),

                                  /// PROMOTE / DEMOTE
                                  IconButton(
                                    onPressed: () async {
                                      final confirm = await AppDialogs.confirm(
                                        context,
                                        icon:
                                            Icons.admin_panel_settings_outlined,
                                        title: isAdmin
                                            ? "Demote Admin"
                                            : "Promote to Admin",
                                        description: isAdmin
                                            ? "User will lose admin privileges."
                                            : "User will become admin.",
                                        confirmText: isAdmin
                                            ? "Demote"
                                            : "Promote",
                                        confirmColor: theme.colorScheme.primary,
                                      );

                                      if (confirm == true) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.id)
                                            .update({
                                              'role': isAdmin
                                                  ? 'user'
                                                  : 'admin',
                                            });

                                         AppSnackBar.show(
                                          isAdmin 
                                            ? "User has been Demoted"
                                            : "User promote to Admin",
                                          type: isAdmin 
                                            ? SnackType.error
                                            : SnackType.success,
                                        );   
                                      }
                                    },
                                    icon: _iconContainer(
                                      context,
                                      isAdmin
                                          ? Icons.security_outlined
                                          : Icons.admin_panel_settings_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },

                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _iconContainer(BuildContext context, IconData icon) {
  final theme = Theme.of(context);

  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: theme.colorScheme.primary),
  );
}

Widget _badge(BuildContext context, String label, Color color) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}
