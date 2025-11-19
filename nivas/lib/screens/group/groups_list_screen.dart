import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/group.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/screens/group/create_group_screen.dart';
import 'package:nivas/screens/space/spaces_list_screen.dart';
import 'package:nivas/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Groups list screen
/// 
/// Shows all groups user has access to and available groups
class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final availableGroupsAsync = ref.watch(availableGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userGroupsProvider);
          ref.invalidate(availableGroupsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Groups Section
              Text(
                'My Groups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              userGroupsAsync.when(
                data: (groups) {
                  if (groups.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.group_outlined,
                      title: 'No Groups Yet',
                      message: 'You haven\'t joined any groups',
                    );
                  }
                  
                  return Column(
                    children: groups.map((group) {
                      return _buildGroupCard(context, ref, group, isMember: true);
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorState(error.toString()),
              ),
              
              const SizedBox(height: 32),
              
              // Available Groups Section
              Text(
                'Available Groups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              availableGroupsAsync.when(
                data: (groups) {
                  if (groups.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'All Caught Up',
                      message: 'You have access to all available groups',
                    );
                  }
                  
                  return Column(
                    children: groups.map((group) {
                      return _buildGroupCard(context, ref, group, isMember: false);
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorState(error.toString()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateGroupButton(context, ref),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    WidgetRef ref,
    Group group, {
    required bool isMember,
  }) {
    final userId = ref.watch(currentUserIdProvider);
    final isAdmin = userId != null && group.isAdmin(userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isMember
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpacesListScreen(groupId: group.groupId),
                  ),
                );
              }
            : null,
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
                      color: group.isGeneral
                          ? Color(AppColors.success).withOpacity(0.1)
                          : Color(AppColors.primaryBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      group.isGeneral ? Icons.public : Icons.lock,
                      color: group.isGeneral
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
                                group.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.warning).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Color(AppColors.warning),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (group.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            group.description,
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
                    Icons.people,
                    '${group.memberCount} members',
                  ),
                  const SizedBox(width: 12),
                  if (group.lastActivityAt != null)
                    _buildStatChip(
                      Icons.access_time,
                      _formatTimeAgo(group.lastActivityAt!),
                    ),
                ],
              ),
              
              // Action Button for non-members
              if (!isMember) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _requestAccess(context, ref, group),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Request Access'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryBlue),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Color(AppColors.textSecondary),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading groups',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Color(AppColors.textSecondary),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget? _buildCreateGroupButton(BuildContext context, WidgetRef ref) {
    // Only show for super admins
    final projectId = ref.watch(currentProjectIdProvider);
    if (projectId == null) return null;

    final isSuperAdmin = ref.watch(isSuperAdminProvider(projectId));
    
    if (!isSuperAdmin) return null;

    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateGroupScreen(),
          ),
        );
        
        if (result == true) {
          // Refresh the list
          ref.invalidate(userGroupsProvider);
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Create Group'),
      backgroundColor: Color(AppColors.primaryBlue),
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

  Future<void> _requestAccess(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Access to ${group.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add an optional message for the group admins:'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Why do you want to join this group?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryBlue),
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('User not authenticated');

      final firestore = ref.read(firestoreProvider);
      final requestId = '${group.groupId}_$userId';

      final request = GroupAccessRequest(
        requestId: requestId,
        groupId: group.groupId,
        userId: userId,
        message: messageController.text.trim(),
        status: RequestStatus.pending,
        requestedAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.groupAccessRequestsCollection)
          .doc(requestId)
          .set(request.toFirestore());

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Access request sent!');

      // TODO: Send notification to group admins
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to send request: $e');
    }
  }
}
