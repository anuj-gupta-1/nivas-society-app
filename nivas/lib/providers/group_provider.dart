import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/group.dart';
import 'package:nivas/models/space.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Provider for groups in current project
/// 
/// Returns all groups user has access to
final projectGroupsProvider = StreamProvider<List<Group>>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (projectId == null || userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.groupsCollection)
      .where('project_id', isEqualTo: projectId)
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Group.fromFirestore(doc))
        .where((group) {
          // Show general groups and groups user is a member of
          return group.isGeneral || group.isMember(userId);
        })
        .toList();
  });
});

/// Provider for user's groups (groups they are a member of)
final userGroupsProvider = StreamProvider<List<Group>>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (projectId == null || userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.groupsCollection)
      .where('project_id', isEqualTo: projectId)
      .where('member_ids', arrayContains: userId)
      .orderBy('last_activity_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
  });
});

/// Provider for available groups (not a member yet)
final availableGroupsProvider = StreamProvider<List<Group>>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (projectId == null || userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.groupsCollection)
      .where('project_id', isEqualTo: projectId)
      .where('type', isEqualTo: GroupType.private.name)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Group.fromFirestore(doc))
        .where((group) => !group.isMember(userId))
        .toList();
  });
});

/// Provider for a specific group
/// 
/// Usage: ref.watch(groupProvider(groupId))
final groupProvider = StreamProvider.family<Group?, String>((ref, groupId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.groupsCollection)
      .doc(groupId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Group.fromFirestore(doc);
  });
});

/// Provider for spaces in a group
/// 
/// Usage: ref.watch(groupSpacesProvider(groupId))
final groupSpacesProvider = StreamProvider.family<List<Space>, String>((ref, groupId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.spacesCollection)
      .where('group_id', isEqualTo: groupId)
      .orderBy('type', descending: false) // General first
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Space.fromFirestore(doc)).toList();
  });
});

/// Provider for a specific space
/// 
/// Usage: ref.watch(spaceProvider(spaceId))
final spaceProvider = StreamProvider.family<Space?, String>((ref, spaceId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.spacesCollection)
      .doc(spaceId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Space.fromFirestore(doc);
  });
});

/// Provider for pending group access requests for a group
/// 
/// Usage: ref.watch(groupAccessRequestsProvider(groupId))
final groupAccessRequestsProvider = StreamProvider.family<List<GroupAccessRequest>, String>((ref, groupId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.groupAccessRequestsCollection)
      .where('group_id', isEqualTo: groupId)
      .where('status', isEqualTo: RequestStatus.pending.name)
      .orderBy('requested_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => GroupAccessRequest.fromFirestore(doc))
        .toList();
  });
});

/// Provider for user's pending access requests
final userAccessRequestsProvider = StreamProvider<List<GroupAccessRequest>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.groupAccessRequestsCollection)
      .where('user_id', isEqualTo: userId)
      .where('status', isEqualTo: RequestStatus.pending.name)
      .orderBy('requested_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => GroupAccessRequest.fromFirestore(doc))
        .toList();
  });
});

/// Provider to check if user is admin of a group
/// 
/// Usage: ref.watch(isGroupAdminProvider(groupId))
final isGroupAdminProvider = Provider.family<bool, String>((ref, groupId) {
  final userId = ref.watch(currentUserIdProvider);
  final groupAsync = ref.watch(groupProvider(groupId));
  
  if (userId == null) return false;
  
  return groupAsync.when(
    data: (group) => group?.isAdmin(userId) ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to check if user is member of a group
/// 
/// Usage: ref.watch(isGroupMemberProvider(groupId))
final isGroupMemberProvider = Provider.family<bool, String>((ref, groupId) {
  final userId = ref.watch(currentUserIdProvider);
  final groupAsync = ref.watch(groupProvider(groupId));
  
  if (userId == null) return false;
  
  return groupAsync.when(
    data: (group) => group?.isMember(userId) ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});
