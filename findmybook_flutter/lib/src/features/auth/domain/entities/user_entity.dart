/// User entity representing the core business model
/// 
/// This is our **immutable business entity** (↔ MongoDB User Schema + TypeScript interfaces)
/// 
/// MERN Comparison:
/// - Freezed with @freezed ↔ TypeScript interfaces + Zod validation
/// - copyWith() method ↔ Spread operator {...user}
/// - value equality ↔ Custom equals() in Express models

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    /// Unique Firebase UID
    required String id,

    /// User's email address
    required String email,

    /// User's display name
    required String? displayName,

    /// User's profile picture URL
    required String? photoUrl,

    /// User's library membership ID
    required String? libraryMemberId,

    /// User's role in the system (USER, ADMIN, LIBRARIAN)
    @Default('USER') String role,

    /// Timestamp when user account was created
    required DateTime createdAt,

    /// Timestamp when user account was last updated
    required DateTime updatedAt,

    /// Whether user has completed onboarding
    @Default(false) bool hasCompletedOnboarding,

    /// User's preferred language
    @Default('en') String preferredLanguage,

    /// User preferences (denormalized for performance)
    required Map<String, dynamic>? preferences,
  }) = _UserEntity;

  const UserEntity._();

  /// Check if user is admin
  bool get isAdmin => role == 'ADMIN';

  /// Check if user is librarian
  bool get isLibrarian => role == 'LIBRARIAN';

  /// Check if user profile is complete
  bool get isProfileComplete =>
      displayName != null &&
      displayName!.isNotEmpty &&
      libraryMemberId != null;
}
