import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's membership in a project
/// 
/// This handles the many-to-many relationship between users and projects:
/// - One user can belong to multiple projects
/// - One project can have multiple users
/// - Each membership has project-specific data (display name, role, units)
class ProjectMembership {
  final String membershipId;
  final String userId;
  final String projectId;
  final String displayName; // Project-specific, editable
  final UserRole role;
  final VerificationStatus verificationStatus;
  final String? verificationDocUrl;
  final DateTime? verifiedAt;
  final String? verifiedBy; // Admin user ID who approved
  final String? rejectionReason; // Reason for rejection if rejected
  final List<UnitOwnership> unitOwnerships;
  final DateTime createdAt;

  const ProjectMembership({
    required this.membershipId,
    required this.userId,
    required this.projectId,
    required this.displayName,
    required this.role,
    required this.verificationStatus,
    this.verificationDocUrl,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
    required this.unitOwnerships,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory ProjectMembership.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectMembership(
      membershipId: doc.id,
      userId: data['user_id'] as String,
      projectId: data['project_id'] as String,
      displayName: data['display_name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.owner,
      ),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == data['verification_status'],
        orElse: () => VerificationStatus.pending,
      ),
      verificationDocUrl: data['verification_doc_url'] as String?,
      verifiedAt: data['verified_at'] != null
          ? (data['verified_at'] as Timestamp).toDate()
          : null,
      verifiedBy: data['verified_by'] as String?,
      rejectionReason: data['rejection_reason'] as String?,
      unitOwnerships: (data['unit_ownerships'] as List<dynamic>?)
              ?.map((e) => UnitOwnership.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'project_id': projectId,
      'display_name': displayName,
      'role': role.name,
      'verification_status': verificationStatus.name,
      'verification_doc_url': verificationDocUrl,
      'verified_at': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
      'unit_ownerships': unitOwnerships.map((e) => e.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Check if user is admin (Group Admin or Super Admin)
  bool get isAdmin => role == UserRole.groupAdmin || role == UserRole.superAdmin;

  /// Check if user is verified
  bool get isVerified => verificationStatus == VerificationStatus.approved;

  /// Copy with updated fields
  ProjectMembership copyWith({
    String? displayName,
    UserRole? role,
    VerificationStatus? verificationStatus,
    String? verificationDocUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? rejectionReason,
    List<UnitOwnership>? unitOwnerships,
  }) {
    return ProjectMembership(
      membershipId: membershipId,
      userId: userId,
      projectId: projectId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocUrl: verificationDocUrl ?? this.verificationDocUrl,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      unitOwnerships: unitOwnerships ?? this.unitOwnerships,
      createdAt: createdAt,
    );
  }
}

/// User roles in a project
enum UserRole {
  owner, // Standard user
  groupAdmin, // Can manage specific groups
  superAdmin, // Can manage entire project
}

/// Verification status for new users
enum VerificationStatus {
  pending, // Waiting for admin approval
  approved, // Verified and active
  rejected, // Verification rejected
}

/// Represents ownership of a specific unit
class UnitOwnership {
  final String unitId;
  final String unitNumber; // e.g., "A-1201"
  final String block; // e.g., "Block A"
  final String phase; // e.g., "Phase 1"
  final OwnershipType ownershipType;

  const UnitOwnership({
    required this.unitId,
    required this.unitNumber,
    required this.block,
    required this.phase,
    required this.ownershipType,
  });

  factory UnitOwnership.fromMap(Map<String, dynamic> map) {
    return UnitOwnership(
      unitId: map['unit_id'] as String,
      unitNumber: map['unit_number'] as String,
      block: map['block'] as String,
      phase: map['phase'] as String,
      ownershipType: OwnershipType.values.firstWhere(
        (e) => e.name == map['ownership_type'],
        orElse: () => OwnershipType.primary,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unit_id': unitId,
      'unit_number': unitNumber,
      'block': block,
      'phase': phase,
      'ownership_type': ownershipType.name,
    };
  }

  /// Display format: "A-1201 (Block A, Phase 1)"
  String get displayText => '$unitNumber ($block, $phase)';
}

/// Type of ownership for a unit
enum OwnershipType {
  primary, // Primary owner
  coOwner, // Co-owner (joint ownership)
  joint, // Joint ownership with family
}
