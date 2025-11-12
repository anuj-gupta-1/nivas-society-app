import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/group.dart';
import 'package:nivas/models/user.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/screens/group/group_access_requests_screen.dart';
import 'package:nivas/utils/constants.dart';

/// Group settings screen (for group admins)
/// 
/// Manage group details, members, and admins
class GroupSettingsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupSettingsScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupProvider(widget.groupId));
    final pendingRequestsAsync = ref.watch(groupAccessRequestsProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Settings'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return const Center(child: Text('Group not found'));
          }

          // Initialize controllers if editing
          if (_isEditing && _nameController.text.isEmpty) {
            _nameController.text = group.name;
            _descriptionController.text = group.description;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Group Details Section
              _buildSectionTitle('Group Details'),
              const SizedBox(height: 12),
              _buildDetailsCard(group),
              
              const SizedBox(height: 24),
              
              // Pending Requests Section
              if (!group.isGeneral) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Access Requests'),
                    pendingRequestsAsync.when(
                      data: (requests) {
                        if (requests.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(AppColors.error),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAccessRequestsCard(group),
                const SizedBox(height: 24),
              ],
              
              // Members Section
              _buildSectionTitle('Members (${group.memberCount})'),
              const SizedBox(height: 12),
              _buildMembersCard(group),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailsCard(Group group) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _nameController.clear();
                          _descriptionController.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveChanges(group),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryBlue),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildDetailRow('Name', group.name),
              if (group.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Description', group.description),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(
                'Type',
                group.isGeneral ? 'General (Public)' : 'Private',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Created',
                _formatDate(group.createdAt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(AppColors.textSecondary),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildAccessRequestsCard(Group group) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupAccessRequestsScreen(groupId: group.groupId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.pending_actions, color: Color(AppColors.warning)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'View Pending Requests',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersCard(Group group) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: group.memberIds.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final userId = group.memberIds[index];
          final isAdmin = group.adminIds.contains(userId);
          
          return FutureBuilder<User?>(
            future: _getUserData(userId),
            builder: (context, snapshot) {
              final user = snapshot.data;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(AppColors.primaryBlue).withOpacity(0.1),
                  child: Text(
                    user?.displayName[0].toUpperCase() ?? '?',
                    style: TextStyle(
                      color: Color(AppColors.primaryBlue),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user?.displayName ?? 'Loading...'),
                subtitle: Text(user?.phoneNumber ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMemberAction(value, group, userId, isAdmin),
                      itemBuilder: (context) => [
                        if (!isAdmin)
                          const PopupMenuItem(
                            value: 'make_admin',
                            child: Text('Make Admin'),
                          ),
                        if (isAdmin && group.adminIds.length > 1)
                          const PopupMenuItem(
                            value: 'remove_admin',
                            child: Text('Remove Admin'),
                          ),
                        if (userId != ref.read(currentUserIdProvider))
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove from Group'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<User?> _getUserData(String userId) async {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveChanges(Group group) async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ref.read(errorProvider.notifier).setError('Name cannot be empty');
      return;
    }

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      
      await firestore
          .collection(AppConstants.groupsCollection)
          .doc(group.groupId)
          .update({
        'name': name,
        'description': description,
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isEditing = false;
        _nameController.clear();
        _descriptionController.clear();
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Group updated!');
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to update: $e');
    }
  }

  Future<void> _handleMemberAction(
    String action,
    Group group,
    String userId,
    bool isAdmin,
  ) async {
    switch (action) {
      case 'make_admin':
        await _makeAdmin(group, userId);
        break;
      case 'remove_admin':
        await _removeAdmin(group, userId);
        break;
      case 'remove':
        await _removeMember(group, userId);
        break;
    }
  }

  Future<void> _makeAdmin(Group group, String userId) async {
    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      
      await firestore
          .collection(AppConstants.groupsCollection)
          .doc(group.groupId)
          .update({
        'admin_ids': FieldValue.arrayUnion([userId]),
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Admin privileges granted');
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed: $e');
    }
  }

  Future<void> _removeAdmin(Group group, String userId) async {
    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      
      await firestore
          .collection(AppConstants.groupsCollection)
          .doc(group.groupId)
          .update({
        'admin_ids': FieldValue.arrayRemove([userId]),
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Admin privileges revoked');
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed: $e');
    }
  }

  Future<void> _removeMember(Group group, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Remove this user from the group?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      
      await firestore
          .collection(AppConstants.groupsCollection)
          .doc(group.groupId)
          .update({
        'member_ids': FieldValue.arrayRemove([userId]),
        'admin_ids': FieldValue.arrayRemove([userId]),
        'member_count': FieldValue.increment(-1),
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Member removed');
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed: $e');
    }
  }
}
