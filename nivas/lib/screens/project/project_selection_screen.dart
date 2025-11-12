import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/project.dart';
import 'package:nivas/models/project_membership.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Project selection screen
/// 
/// Shows list of projects user belongs to
/// Auto-selects if user has only one project
class ProjectSelectionScreen extends ConsumerStatefulWidget {
  const ProjectSelectionScreen({super.key});

  @override
  ConsumerState<ProjectSelectionScreen> createState() => _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState extends ConsumerState<ProjectSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Check for auto-selection after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoSelection();
    });
  }

  void _checkAutoSelection() {
    final membershipsAsync = ref.read(userProjectMembershipsProvider);
    
    membershipsAsync.whenData((memberships) {
      if (memberships.length == 1) {
        // Auto-select if user has only one project
        _selectProject(memberships.first);
      }
    });
  }

  void _selectProject(ProjectMembership membership) {
    // Set current project
    ref.read(currentProjectIdProvider.notifier).setProject(membership.projectId);
    
    // Navigate to home screen
    // TODO: Navigate to actual home screen when implemented
    ref.read(successProvider.notifier).setSuccess('Project selected: ${membership.projectId}');
  }

  @override
  Widget build(BuildContext context) {
    final membershipsAsync = ref.watch(userProjectMembershipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Project'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: membershipsAsync.when(
        data: (memberships) {
          if (memberships.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: memberships.length,
            itemBuilder: (context, index) {
              final membership = memberships[index];
              return _buildProjectCard(membership);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load projects',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Projects Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are not a member of any projects yet. Please contact your society admin.',
              style: TextStyle(
                color: Color(AppColors.textSecondary),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectMembership membership) {
    final projectAsync = ref.watch(projectProvider(membership.projectId));

    return projectAsync.when(
      data: (project) {
        if (project == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _selectProject(membership),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(AppColors.primaryBlue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.apartment,
                          color: Color(AppColors.primaryBlue),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.location,
                              style: TextStyle(
                                color: Color(AppColors.textSecondary),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(AppColors.textSecondary),
                        size: 20,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  Divider(color: Colors.grey[200]),
                  
                  const SizedBox(height: 16),
                  
                  // Project Details
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.person,
                          _getRoleLabel(membership.role),
                          _getRoleColor(membership.role),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.home,
                          membership.unitOwnerships.isNotEmpty
                              ? membership.unitOwnerships.first.unitNumber
                              : 'No unit',
                          Color(AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                  
                  // TODO: Add unread notification count when notifications are implemented
                  // if (unreadCount > 0) ...[
                  //   const SizedBox(height: 12),
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //     decoration: BoxDecoration(
                  //       color: Color(AppColors.error).withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(Icons.notifications, size: 16, color: Color(AppColors.error)),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           '$unreadCount unread notifications',
                  //           style: TextStyle(
                  //             color: Color(AppColors.error),
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.groupAdmin:
        return 'Group Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Color(AppColors.primaryBlue);
      case UserRole.groupAdmin:
        return Color(AppColors.warning);
      case UserRole.superAdmin:
        return Color(AppColors.success);
    }
  }
}
