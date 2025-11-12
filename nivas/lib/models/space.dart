import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a space within a group
/// 
/// Spaces organize threads within a group:
/// - General Space: Default space in every group
/// - Dedicated Spaces: Created by admins for specific topics
class Space {
  final String spaceId;
  final String groupId;
  final String projectId;
  final String name;
  final String description;
  final SpaceType type;
  final String createdBy; // User ID of creator
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int threadCount;
  final DateTime? lastActivityAt;

  const Space({
    required this.spaceId,
    required this.groupId,
    required this.projectId,
    required this.name,
    required this.description,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.threadCount,
    this.lastActivityAt,
  });

  /// Create from Firestore document
  factory Space.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Space(
      spaceId: doc.id,
      groupId: data['group_id'] as String,
      projectId: data['project_id'] as String,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      type: SpaceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SpaceType.dedicated,
      ),
      createdBy: data['created_by'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      threadCount: data['thread_count'] as int? ?? 0,
      lastActivityAt: data['last_activity_at'] != null
          ? (data['last_activity_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'group_id': groupId,
      'project_id': projectId,
      'name': name,
      'description': description,
      'type': type.name,
      'created_by': createdBy,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'thread_count': threadCount,
      'last_activity_at': lastActivityAt != null
          ? Timestamp.fromDate(lastActivityAt!)
          : null,
    };
  }

  /// Check if space is general (default)
  bool get isGeneral => type == SpaceType.general;

  /// Copy with updated fields
  Space copyWith({
    String? name,
    String? description,
    SpaceType? type,
    DateTime? updatedAt,
    int? threadCount,
    DateTime? lastActivityAt,
  }) {
    return Space(
      spaceId: spaceId,
      groupId: groupId,
      projectId: projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      threadCount: threadCount ?? this.threadCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Type of space
enum SpaceType {
  general, // Default space in every group
  dedicated, // Created for specific topics
}
