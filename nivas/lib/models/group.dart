import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a discussion group within a project
/// 
/// Groups organize users and discussions:
/// - General Group: All verified users have access
/// - Private Groups: Require admin approval to join
class Group {
  final String groupId;
  final String projectId;
  final String name;
  final String description;
  final GroupType type;
  final List<String> memberIds; // User IDs of members
  final List<String> adminIds; // User IDs of group admins
  final String createdBy; // User ID of creator
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int memberCount;
  final DateTime? lastActivityAt;

  const Group({
    required this.groupId,
    required this.projectId,
    required this.name,
    required this.description,
    required this.type,
    required this.memberIds,
    required this.adminIds,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.memberCount,
    this.lastActivityAt,
  });

  /// Create from Firestore document
  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Group(
      groupId: doc.id,
      projectId: data['project_id'] as String,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      type: GroupType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => GroupType.private,
      ),
      memberIds: List<String>.from(data['member_ids'] as List? ?? []),
      adminIds: List<String>.from(data['admin_ids'] as List? ?? []),
      createdBy: data['created_by'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      memberCount: data['member_count'] as int? ?? 0,
      lastActivityAt: data['last_activity_at'] != null
          ? (data['last_activity_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'project_id': projectId,
      'name': name,
      'description': description,
      'type': type.name,
      'member_ids': memberIds,
      'admin_ids': adminIds,
      'created_by': createdBy,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'member_count': memberCount,
      'last_activity_at': lastActivityAt != null
          ? Timestamp.fromDate(lastActivityAt!)
          : null,
    };
  }

  /// Check if user is a member
  bool isMember(String userId) => memberIds.contains(userId);

  /// Check if user is an admin
  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Check if group is general (accessible to all)
  bool get isGeneral => type == GroupType.general;

  /// Copy with updated fields
  Group copyWith({
    String? name,
    String? description,
    GroupType? type,
    List<String>? memberIds,
    List<String>? adminIds,
    DateTime? updatedAt,
    int? memberCount,
    DateTime? lastActivityAt,
  }) {
    return Group(
      groupId: groupId,
      projectId: projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Type of group
enum GroupType {
  general, // Accessible to all verified users
  private, // Requires approval to join
}

/// Represents a group access request
class GroupAccessRequest {
  final String requestId;
  final String groupId;
  final String userId;
  final String message; // Optional message from user
  final RequestStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? respondedBy; // Admin who approved/rejected
  final String? responseMessage; // Optional rejection reason

  const GroupAccessRequest({
    required this.requestId,
    required this.groupId,
    required this.userId,
    required this.message,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.respondedBy,
    this.responseMessage,
  });

  /// Create from Firestore document
  factory GroupAccessRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupAccessRequest(
      requestId: doc.id,
      groupId: data['group_id'] as String,
      userId: data['user_id'] as String,
      message: data['message'] as String? ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      requestedAt: (data['requested_at'] as Timestamp).toDate(),
      respondedAt: data['responded_at'] != null
          ? (data['responded_at'] as Timestamp).toDate()
          : null,
      respondedBy: data['responded_by'] as String?,
      responseMessage: data['response_message'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'message': message,
      'status': status.name,
      'requested_at': Timestamp.fromDate(requestedAt),
      'responded_at':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'responded_by': respondedBy,
      'response_message': responseMessage,
    };
  }
}

/// Status of group access request
enum RequestStatus {
  pending,
  approved,
  rejected,
}
