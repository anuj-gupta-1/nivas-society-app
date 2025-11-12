import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/project.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/utils/constants.dart';

/// State notifier for managing current selected project
/// 
/// This keeps track of which project the user is currently viewing
class CurrentProjectNotifier extends StateNotifier<String?> {
  CurrentProjectNotifier() : super(null);
  
  /// Set the current project
  void setProject(String projectId) {
    state = projectId;
  }
  
  /// Clear the current project
  void clearProject() {
    state = null;
  }
}

/// Provider for current selected project ID
/// 
/// This is the project context the user is currently in
final currentProjectIdProvider = StateNotifierProvider<CurrentProjectNotifier, String?>((ref) {
  return CurrentProjectNotifier();
});

/// Provider for current project data
/// 
/// Fetches project details based on currently selected project
final currentProjectProvider = StreamProvider<Project?>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  
  if (projectId == null) {
    return Stream.value(null);
  }
  
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(AppConstants.projectsCollection)
      .doc(projectId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Project.fromFirestore(doc);
  });
});

/// Provider for a specific project by ID
/// 
/// Usage: ref.watch(projectProvider(projectId))
final projectProvider = StreamProvider.family<Project?, String>((ref, projectId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.projectsCollection)
      .doc(projectId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Project.fromFirestore(doc);
  });
});

/// Provider for all projects (for admin/super admin)
/// 
/// Returns list of all projects in the system
final allProjectsProvider = StreamProvider<List<Project>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.projectsCollection)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Project.fromFirestore(doc))
        .toList();
  });
});

/// Provider to check if user has selected a project
final hasSelectedProjectProvider = Provider<bool>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  return projectId != null;
});

/// Provider for current project's phases
final currentProjectPhasesProvider = Provider<List<String>>((ref) {
  final project = ref.watch(currentProjectProvider);
  
  return project.when(
    data: (data) => data?.phases ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for current project's blocks
final currentProjectBlocksProvider = Provider<List<String>>((ref) {
  final project = ref.watch(currentProjectProvider);
  
  return project.when(
    data: (data) => data?.blocks ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider to get units for a specific phase and block
/// 
/// Usage: ref.watch(projectUnitsProvider((projectId, phase, block)))
final projectUnitsProvider = Provider.family<List<String>, ({String projectId, String phase, String block})>((ref, params) {
  final project = ref.watch(projectProvider(params.projectId));
  
  return project.when(
    data: (data) => data?.getUnits(params.phase, params.block) ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});
