import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/project.dart';
import 'package:nivas/models/project_membership.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Project switcher widget
/// 
/// Can be used in app drawer or header to switch between projects
class ProjectSwitcher extends ConsumerWidget {
  const ProjectSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProjectId = ref.watch(currentProjectIdProvider);
    final currentProjectAsync = ref.watch(currentProjectProvider);
    final membershipsAsync = ref.watch(userProjectMembershipsProvider);

    return membershipsAsync.when(
      data: (memberships) {
        if (memberships.isEmpty) {
          return const SizedBox.shrink();
        }

        if (memberships.length == 1) {
          // Only one project, show it without dropdown
          return currentProjectAsync.when(
            data: (project) => project != null
                ? _buildSingleProject(project)
                : const SizedBox.shrink(),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          );
        }

        // Multiple projects, show dropdown
        return _buildProjectDropdown(
          context,
          ref,
          currentProjectId,
          memberships,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSingleProject(Project project) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(AppColors.primaryBlue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apartment,
            color: Color(AppColors.primaryBlue),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              project.name,
              style: TextStyle(
                color: Color(AppColors.primaryBlue),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDropdown(
    BuildContext context,
    WidgetRef ref,
    String? currentProjectId,
    List<ProjectMembership> memberships,
  ) {
    return PopupMenuButton<String>(
      onSelected: (projectId) => _switchProject(ref, projectId),
      itemBuilder: (context) {
        return memberships.map((membership) {
          final projectAsync = ref.watch(projectProvider(membership.projectId));
          
          return projectAsync.when(
            data: (project) {
              if (project == null) return null;
              
              return PopupMenuItem<String>(
                value: membership.projectId,
                child: Row(
                  children: [
                    Icon(
                      Icons.apartment,
                      color: membership.projectId == currentProjectId
                          ? Color(AppColors.primaryBlue)
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: TextStyle(
                              fontWeight: membership.projectId == currentProjectId
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            project.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (membership.projectId == currentProjectId)
                      Icon(
                        Icons.check,
                        color: Color(AppColors.primaryBlue),
                        size: 20,
                      ),
                  ],
                ),
              );
            },
            loading: () => null,
            error: (_, __) => null,
          );
        }).whereType<PopupMenuItem<String>>().toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(AppColors.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apartment,
              color: Color(AppColors.primaryBlue),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ref.watch(currentProjectProvider).when(
                data: (project) => Text(
                  project?.name ?? 'Select Project',
                  style: TextStyle(
                    color: Color(AppColors.primaryBlue),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                loading: () => const Text('Loading...'),
                error: (_, __) => const Text('Error'),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Color(AppColors.primaryBlue),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _switchProject(WidgetRef ref, String projectId) {
    final currentProjectId = ref.read(currentProjectIdProvider);
    
    if (projectId == currentProjectId) {
      return; // Already on this project
    }

    // Show loading
    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      // Clear any cached data if needed
      // TODO: Clear group/space/thread caches when implemented
      
      // Set new project
      ref.read(currentProjectIdProvider.notifier).setProject(projectId);
      
      // TODO: Update notification subscriptions when implemented
      
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Switched project');
      
      // TODO: Navigate to home screen or refresh current screen
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to switch project: $e');
    }
  }
}

/// Compact project switcher for app bar
class CompactProjectSwitcher extends ConsumerWidget {
  const CompactProjectSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProjectAsync = ref.watch(currentProjectProvider);
    final membershipsAsync = ref.watch(userProjectMembershipsProvider);

    return membershipsAsync.when(
      data: (memberships) {
        if (memberships.isEmpty || memberships.length == 1) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'Switch Project',
          onPressed: () {
            _showProjectSwitcherDialog(context, ref, memberships);
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showProjectSwitcherDialog(
    BuildContext context,
    WidgetRef ref,
    List<ProjectMembership> memberships,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Project'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: memberships.length,
            itemBuilder: (context, index) {
              final membership = memberships[index];
              final projectAsync = ref.watch(projectProvider(membership.projectId));
              final currentProjectId = ref.watch(currentProjectIdProvider);

              return projectAsync.when(
                data: (project) {
                  if (project == null) return const SizedBox.shrink();

                  return ListTile(
                    leading: Icon(
                      Icons.apartment,
                      color: membership.projectId == currentProjectId
                          ? Color(AppColors.primaryBlue)
                          : Colors.grey,
                    ),
                    title: Text(project.name),
                    subtitle: Text(project.location),
                    trailing: membership.projectId == currentProjectId
                        ? Icon(Icons.check, color: Color(AppColors.primaryBlue))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(currentProjectIdProvider.notifier).setProject(membership.projectId);
                      ref.read(successProvider.notifier).setSuccess('Switched to ${project.name}');
                    },
                  );
                },
                loading: () => const ListTile(
                  title: Text('Loading...'),
                ),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
