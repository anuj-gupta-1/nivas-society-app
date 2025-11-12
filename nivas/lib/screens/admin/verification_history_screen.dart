import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/project_membership.dart';
import 'package:nivas/utils/constants.dart';

/// Verification history screen showing all past verifications
class VerificationHistoryScreen extends ConsumerStatefulWidget {
  final String projectId;

  const VerificationHistoryScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<VerificationHistoryScreen> createState() => _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends ConsumerState<VerificationHistoryScreen> {
  String _selectedStatus = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification History'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or unit...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Approved'),
                      _buildFilterChip('Rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // History List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getHistoryStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final memberships = snapshot.data!.docs
                    .map((doc) => ProjectMembership.fromFirestore(doc))
                    .where((m) => _matchesSearch(m))
                    .toList();

                if (memberships.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: memberships.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(memberships[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getHistoryStream() {
    Query query = FirebaseFirestore.instance
        .collection(AppConstants.projectMembershipsCollection)
        .where('project_id', isEqualTo: widget.projectId)
        .orderBy('verified_at', descending: true);

    if (_selectedStatus == 'Approved') {
      query = query.where('verification_status', isEqualTo: VerificationStatus.approved.name);
    } else if (_selectedStatus == 'Rejected') {
      query = query.where('verification_status', isEqualTo: VerificationStatus.rejected.name);
    } else {
      // Show both approved and rejected
      query = query.where('verification_status', whereIn: [
        VerificationStatus.approved.name,
        VerificationStatus.rejected.name,
      ]);
    }

    return query.snapshots();
  }

  bool _matchesSearch(ProjectMembership membership) {
    if (_searchQuery.isEmpty) return true;
    
    final name = membership.displayName.toLowerCase();
    final unit = membership.unitOwnerships.isNotEmpty
        ? membership.unitOwnerships.first.unitNumber.toLowerCase()
        : '';
    
    return name.contains(_searchQuery) || unit.contains(_searchQuery);
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Color(AppColors.primaryBlue).withOpacity(0.2),
        checkmarkColor: Color(AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No verification history',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ProjectMembership membership) {
    final isApproved = membership.verificationStatus == VerificationStatus.approved;
    final unit = membership.unitOwnerships.isNotEmpty
        ? membership.unitOwnerships.first
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isApproved
                      ? Color(AppColors.success).withOpacity(0.1)
                      : Color(AppColors.error).withOpacity(0.1),
                  child: Icon(
                    isApproved ? Icons.check : Icons.close,
                    color: isApproved
                        ? Color(AppColors.success)
                        : Color(AppColors.error),
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
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (unit != null)
                        Text(
                          '${unit.unitNumber} • ${unit.block} • ${unit.phase}',
                          style: TextStyle(
                            color: Color(AppColors.textSecondary),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? Color(AppColors.success).withOpacity(0.1)
                        : Color(AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isApproved ? 'Approved' : 'Rejected',
                    style: TextStyle(
                      color: isApproved
                          ? Color(AppColors.success)
                          : Color(AppColors.error),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Verification Details
            if (membership.verifiedAt != null) ...[
              _buildDetailRow(
                Icons.access_time,
                'Verified',
                _formatTimestamp(membership.verifiedAt!),
              ),
            ],
            
            if (membership.verifiedBy != null) ...[
              _buildDetailRow(
                Icons.person,
                'Verified by',
                membership.verifiedBy!,
              ),
            ],
            
            // Rejection Reason
            if (!isApproved && membership.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(AppColors.error).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(AppColors.error).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(AppColors.error),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(AppColors.error),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            membership.rejectionReason!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Color(AppColors.textSecondary),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
