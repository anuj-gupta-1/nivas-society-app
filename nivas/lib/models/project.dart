import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a society/apartment project
class Project {
  final String projectId;
  final String projectName; // e.g., "Prestige Lakeside Habitat"
  final String location; // e.g., "Bangalore, Karnataka"
  final String? reraNumber; // Optional RERA registration number
  final int totalUnits; // e.g., 1400
  final List<String> phases; // e.g., ["Phase 1", "Phase 2"]
  final List<String> blocks; // e.g., ["A", "B", "C", "D", "E"]
  final Map<String, dynamic> unitStructure; // Nested structure of units
  final ProjectStatus status;
  final DateTime createdAt;
  final String createdBy; // User ID of creator

  const Project({
    required this.projectId,
    required this.projectName,
    required this.location,
    this.reraNumber,
    required this.totalUnits,
    required this.phases,
    required this.blocks,
    required this.unitStructure,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });

  /// Create from Firestore document
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      projectId: doc.id,
      projectName: data['project_name'] as String,
      location: data['location'] as String,
      reraNumber: data['rera_number'] as String?,
      totalUnits: data['total_units'] as int,
      phases: List<String>.from(data['phases'] as List),
      blocks: List<String>.from(data['blocks'] as List),
      unitStructure: data['unit_structure'] as Map<String, dynamic>,
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.underConstruction,
      ),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      createdBy: data['created_by'] as String,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'project_name': projectName,
      'location': location,
      'rera_number': reraNumber,
      'total_units': totalUnits,
      'phases': phases,
      'blocks': blocks,
      'unit_structure': unitStructure,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
      'created_by': createdBy,
    };
  }

  /// Get all units for a specific phase and block
  List<String> getUnits(String phase, String block) {
    try {
      final phaseData = unitStructure[phase] as Map<String, dynamic>?;
      if (phaseData == null) return [];
      
      final blockData = phaseData[block] as List<dynamic>?;
      if (blockData == null) return [];
      
      return blockData.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Copy with updated fields
  Project copyWith({
    String? projectName,
    String? location,
    String? reraNumber,
    int? totalUnits,
    List<String>? phases,
    List<String>? blocks,
    Map<String, dynamic>? unitStructure,
    ProjectStatus? status,
  }) {
    return Project(
      projectId: projectId,
      projectName: projectName ?? this.projectName,
      location: location ?? this.location,
      reraNumber: reraNumber ?? this.reraNumber,
      totalUnits: totalUnits ?? this.totalUnits,
      phases: phases ?? this.phases,
      blocks: blocks ?? this.blocks,
      unitStructure: unitStructure ?? this.unitStructure,
      status: status ?? this.status,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}

/// Project status during different phases
enum ProjectStatus {
  underConstruction, // Construction phase
  nearCompletion, // Near completion + utility completion
  softHandover, // Soft handover phase
  registration, // Registration phase
  moveIn, // Moving in phase
  completed, // Full society operational
}

/// Extension to get display text for status
extension ProjectStatusExtension on ProjectStatus {
  String get displayText {
    switch (this) {
      case ProjectStatus.underConstruction:
        return 'Under Construction';
      case ProjectStatus.nearCompletion:
        return 'Near Completion';
      case ProjectStatus.softHandover:
        return 'Soft Handover';
      case ProjectStatus.registration:
        return 'Registration';
      case ProjectStatus.moveIn:
        return 'Move In';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }
}
