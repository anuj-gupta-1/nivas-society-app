import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/user.dart';
import 'package:nivas/models/project_membership.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for current user data
/// 
/// Fetches user data from Firestore based on current auth state
/// Returns null if not authenticated or user not found
final currentUserProvider = StreamProvider<User?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value(null);
  }
  
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  });
});

/// Provider for current user's project memberships (all statuses)
/// 
/// Returns list of all project memberships regardless of verification status
/// Useful for checking if user has any memberships
final userMembershipsProvider = StreamProvider<List<ProjectMembership>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(AppConstants.projectMembershipsCollection)
      .where('user_id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ProjectMembership.fromFirestore(doc))
        .toList();
  });
});

/// Provider for current user's project memberships
/// 
/// Returns list of all projects the user belongs to
/// Useful for project selection screen
final userProjectMembershipsProvider = StreamProvider<List<ProjectMembership>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(AppConstants.projectMembershipsCollection)
      .where('user_id', isEqualTo: userId)
      .where('verification_status', isEqualTo: VerificationStatus.approved.name)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ProjectMembership.fromFirestore(doc))
        .toList();
  });
});

/// Provider for user's membership in a specific project
/// 
/// Usage: ref.watch(projectMembershipProvider(projectId))
final projectMembershipProvider = StreamProvider.family<ProjectMembership?, String>((ref, projectId) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value(null);
  }
  
  final firestore = ref.watch(firestoreProvider);
  final membershipId = '${userId}_$projectId';
  
  return firestore
      .collection(AppConstants.projectMembershipsCollection)
      .doc(membershipId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return ProjectMembership.fromFirestore(doc);
  });
});

/// Provider to check if user is admin in a project
/// 
/// Usage: ref.watch(isProjectAdminProvider(projectId))
final isProjectAdminProvider = Provider.family<bool, String>((ref, projectId) {
  final membership = ref.watch(projectMembershipProvider(projectId));
  
  return membership.when(
    data: (data) => data?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to check if user is super admin in a project
/// 
/// Usage: ref.watch(isSuperAdminProvider(projectId))
final isSuperAdminProvider = Provider.family<bool, String>((ref, projectId) {
  final membership = ref.watch(projectMembershipProvider(projectId));
  
  return membership.when(
    data: (data) => data?.role == UserRole.superAdmin,
    loading: () => false,
    error: (_, __) => false,
  );
});
