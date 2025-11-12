import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing an apartment owner/resident
/// 
/// This model supports:
/// - Multiple units per user (investor with multiple flats)
/// - Multiple projects per user (owns flats in different societies)
/// - Immutable core data (phone, name cannot be edited)
/// - Project-specific display names
class User {
  final String userId; // UUID - globally unique, immutable
  final String phoneNumber; // Format: +91-XXXXXXXXXX (immutable)
  final String? email; // Optional, editable
  final DateTime createdAt;

  const User({
    required this.userId,
    required this.phoneNumber,
    this.email,
    required this.createdAt,
  });

  /// Create User from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      userId: doc.id,
      phoneNumber: data['phone_number'] as String,
      email: data['email'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  /// Convert User to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'phone_number': phoneNumber,
      'email': email,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields (for editable fields only)
  User copyWith({
    String? email,
  }) {
    return User(
      userId: userId,
      phoneNumber: phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, phone: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
