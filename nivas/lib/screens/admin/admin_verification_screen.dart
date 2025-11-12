import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/project_membership.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/screens/admin/verification_history_screen.dart';
import 'package:nivas/utils/constants.dart';

/// Admin screen to verify pending users
class AdminVerificationScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AdminVerificationScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends ConsumerState<AdminVerificationScreen> {
  String? _selectedPhase;
  String? _selectedBlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Verifications'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Verification History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VerificationHistoryScreen(projectId: widget.projectId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPhase,
                    decoration: const InputDecoration(
                      labelText: 'Phase',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Phases')),
                      ...['Phase 1', 'Phase 2'].map((phase) {
                        return DropdownMenuItem(value: phase, child: Text(phase));
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPhase = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBlock,
                    decoration: const InputDecoration(
                      labelText: 'Block',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Blocks')),
                      ...['Block A', 'Block B', 'Block C', 'Block D', 'Block E'].map((block) {
                        return DropdownMenuItem(value: block, child: Text(block));
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBlock = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Pending Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPendingUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No pending verifications',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final pendingUsers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingUsers.length,
                  itemBuilder: (context, index) {
                    final membership = ProjectMembership.fromFirestore(pendingUsers[index]);
                    return _buildVerificationCard(membership);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getPendingUsersStream() {
    final firestore = ref.read(firestoreProvider);
    Query query = firestore
        .collection(AppConstants.projectMembershipsCollection)
        .where('project_id', isEqualTo: widget.projectId)
        .where('verification_status', isEqualTo: VerificationStatus.pending.name)
        .orderBy('created_at', descending: true);

    // Apply filters
    if (_selectedPhase != null) {
      query = query.where('unit_ownerships', arrayContains: {'phase': _selectedPhase});
    }

    return query.snapshots();
  }

  Widget _buildVerificationCard(ProjectMembership membership) {
    final unit = membership.unitOwnerships.isNotEmpty
        ? membership.unitOwnerships.first
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(AppColors.primaryLight),
                  child: Text(
                    membership.displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: Color(AppColors.primaryDark),
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
                        membership.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        membership.userId,
                        style: TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Unit Details
            if (unit != null) ...[
              _buildInfoRow(Icons.home, 'Unit', unit.unitNumber),
              _buildInfoRow(Icons.business, 'Block', unit.block),
              _buildInfoRow(Icons.layers, 'Phase', unit.phase),
            ],
            
            _buildInfoRow(
              Icons.access_time,
              'Submitted',
              _formatTimestamp(membership.createdAt),
            ),
            
            const SizedBox(height: 16),
            
            // Document
            if (membership.verificationDocUrl != null)
              OutlinedButton.icon(
                onPressed: () => _viewDocument(membership.verificationDocUrl!),
                icon: const Icon(Icons.description),
                label: const Text('View Document'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveUser(membership),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.success),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectUser(membership),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppColors.error),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Color(AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Color(AppColors.textSecondary),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _viewDocument(String url) {
    // TODO: Implement document viewer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Viewer'),
        content: const Text('Document viewer will be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveUser(ProjectMembership membership) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve User'),
        content: Text('Approve ${membership.displayName} for ${membership.unitOwnerships.first.unitNumber}?'),
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
      await firestore
          .collection(AppConstants.projectMembershipsCollection)
          .doc(membership.membershipId)
          .update({
        'verification_status': VerificationStatus.approved.name,
        'verified_at': FieldValue.serverTimestamp(),
        'verified_by': ref.read(currentUserIdProvider),
      });

      ref.read(successProvider.notifier).setSuccess('User approved successfully');
    } catch (e) {
      ref.read(errorProvider.notifier).setError('Failed to approve user: $e');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _rejectUser(ProjectMembership membership) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${membership.displayName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
      await firestore
          .collection(AppConstants.projectMembershipsCollection)
          .doc(membership.membershipId)
          .update({
        'verification_status': VerificationStatus.rejected.name,
        'rejection_reason': reasonController.text,
        'verified_at': FieldValue.serverTimestamp(),
        'verified_by': ref.read(currentUserIdProvider),
      });

      ref.read(successProvider.notifier).setSuccess('User rejected');
    } catch (e) {
      ref.read(errorProvider.notifier).setError('Failed to reject user: $e');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }
}
