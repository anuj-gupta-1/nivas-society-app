import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/space.dart';
import 'package:nivas/models/group.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/screens/space/create_space_screen.dart';
import 'package:nivas/screens/thread/threads_list_screen.dart';
import 'package:nivas/utils/constants.dart';

/// Spaces list screen within a group
/// 
/// Shows all spaces in a group with General Space first
class SpacesListScreen extends ConsumerWidget {
  final String groupId;

  const SpacesListScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupId));
    final spacesAsync = ref.watch(groupSpacesProvider(groupId));
    final isAdmin = ref.watch(isGroupAdminProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: groupAsync.when(
          data: (group) => Text(group?.name ?? 'Spaces'),
          loading: () => const Text('Spaces'),
          error: (_, __) => const Text('Spaces'),
        ),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(groupSpacesProvider(groupId));
        },
        child: spacesAsync.when(
          data: (spaces) {
            if (spaces.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                return _buildSpaceCard(context, ref, spaces[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading spaces',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateSpaceScreen(groupId: groupId),
                  ),
                );

                if (result == true) {
                  ref.invalidate(groupSpacesProvider(groupId));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Space'),
              backgroundColor: Color(AppColors.primaryBlue),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.space_dashboard_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Spaces Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Spaces help organize discussions by topic',
              style: TextStyle(
                color: Color(AppColors.textSecondary),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceCard(BuildContext context, WidgetRef ref, Space space) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ThreadsListScreen(spaceId: space.spaceId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: space.isGeneral
                          ? Color(AppColors.success).withOpacity(0.1)
                          : Color(AppColors.primaryBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      space.isGeneral ? Icons.home : Icons.space_dashboard,
                      color: space.isGeneral
                          ? Color(AppColors.success)
                          : Color(AppColors.primaryBlue),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                space.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (space.isGeneral)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.success).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    color: Color(AppColors.success),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (space.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            space.description,
                            style: TextStyle(
                              color: Color(AppColors.textSecondary),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  _buildStatChip(
                    Icons.forum,
                    '${space.threadCount} threads',
                  ),
                  const SizedBox(width: 12),
                  if (space.lastActivityAt != null)
                    _buildStatChip(
                      Icons.access_time,
                      _formatTimeAgo(space.lastActivityAt!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Color(AppColors.textSecondary)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Color(AppColors.textSecondary),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
