import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/group.dart';
import 'package:nivas/models/user.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Group access requests screen
/// 
/// Shows pending access requests for group admins to approve/reject
class GroupAccessRequestsScreen extends ConsumerWidget {
  final String groupId;

  const GroupAccessRequestsScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(groupAccessRequestsProvider(groupId));
    final groupAsync = ref.watch(groupProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Requests'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return const Center(child: Text('Group not found'));
          }

          return requestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return _buildRequestCard(context, ref, group, requests[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Pending Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'All access requests have been processed',
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

  Widget _buildRequestCard(
    BuildContext context,
    WidgetRef ref,
    Group group,
    GroupAccessRequest request,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            FutureBuilder<User?>(
              future: _getUserData(ref, request.userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(AppColors.primaryBlue).withOpacity(0.1),
                      child: Text(
                        user?.displayName[0].toUpperCase() ?? '?',
                        style: TextStyle(
                          color: Color(AppColors.primaryBlue),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Loading...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user?.phoneNumber ?? '',
                            style: TextStyle(
                              color: Color(AppColors.textSecondary),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Message
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            
            // Timestamp
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Color(AppColors.textSecondary),
                ),
                const SizedBox(width: 4),
                Text(
                  'Requested ${_formatTimeAgo(request.requestedAt)}',
                  style: TextStyle(
                    color: Color(AppColors.textSecondary),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveRequest(context, ref, group, request),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.success),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectRequest(context, ref, group, request),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<User?> _getUserData(WidgetRef ref, String userId) async {
    try {
      final firestore = ref.read(firestoreProvider);
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _approveRequest(
    BuildContext context,
    WidgetRef ref,
    Group group,
    GroupAccessRequest request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: const Text('Add this user to the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.success),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      final currentUserId = ref.read(currentUserIdProvider);

      // Update request status
      await firestore
          .collection(AppConstants.groupAccessRequestsCollection)
          .doc(request.requestId)
          .update({
        'status': RequestStatus.approved.name,
        'responded_at': FieldValue.serverTimestamp(),
        'responded_by': currentUserId,
      });

      // Add user to group
      await firestore
          .collection(AppConstants.groupsCollection)
          .doc(group.groupId)
          .update({
        'member_ids': FieldValue.arrayUnion([request.userId]),
        'member_count': FieldValue.increment(1),
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('User approved!');

      // TODO: Send notification to user
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to approve: $e');
    }
  }

  Future<void> _rejectRequest(
    BuildContext context,
    WidgetRef ref,
    Group group,
    GroupAccessRequest request,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Optional reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              backgroundColor: Color(AppColors.error),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      final currentUserId = ref.read(currentUserIdProvider);

      // Update request status
      await firestore
          .collection(AppConstants.groupAccessRequestsCollection)
          .doc(request.requestId)
          .update({
        'status': RequestStatus.rejected.name,
        'responded_at': FieldValue.serverTimestamp(),
        'responded_by': currentUserId,
        'response_message': reasonController.text.trim(),
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Request rejected');

      // TODO: Send notification to user
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to reject: $e');
    }
  }
}
