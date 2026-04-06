import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/core/widgets/app_dialogs.dart';
import 'package:stackhive/core/widgets/app_snackbar.dart';
import 'package:stackhive/features/admin/presentation/screens/admin_layout.dart';
import 'package:stackhive/features/tag/provider/tag_provider.dart';

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tagsAsync = ref.watch(allTagsProvider);

    return AdminLayout(
      title: "Tag Management",
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
                hintText: "Search tags",
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

          // TAGS LIST
          Expanded(
            child: tagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),

              data: (tags) {
                final filtered = tags
                    .where((t) => t.name.toLowerCase().contains(search))
                    .toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tag = filtered[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          /// TAG ICON
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: .1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.local_offer_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),

                          SizedBox(width: 12),

                          /// TAG INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tag.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),

                                Text(
                                  "${tag.usageCount} uses",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: .7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// DELETE TAG
                          IconButton(
                            onPressed: () async {
                              final confirm = await AppDialogs.confirm(
                                context,
                                icon: Icons.delete_outline,
                                title: "Delete Tag",
                                description:
                                    "This will permanently remove this tag from the platform",
                                confirmText: "Delete",
                                confirmColor: theme.colorScheme.error,
                              );

                              if (confirm == true) {
                                ref
                                    .read(tagRepositoryProvider)
                                    .deleteTag(tag.id);

                                AppSnackBar.show(
                                  "Tag deleted successfully",
                                  type: SnackType.success,
                                );
                              }
                            },
                            
                            icon: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: .1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
