/// User model for Firestore/Firebase operations
/// 
/// This is a **DTO (Data Transfer Object)** that represents the network/database format
/// (↔ Express request/response DTOs or MongoDB documents)
/// 
/// MERN Comparison:
/// - UserModel ↔ MongoDB document or Express response schema
/// - fromJson/toJson ↔ JSON.stringify/JSON.parse
/// - toEntity() ↔ Data transformation/mapping

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_library_app/src/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String? displayName,
    required String? photoUrl,
    required String? libraryMemberId,
    @Default('USER') String role,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool hasCompletedOnboarding,
    @Default('en') String preferredLanguage,
    required Map<String, dynamic>? preferences,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      libraryMemberId: data['libraryMemberId'],
      role: data['role'] ?? 'USER',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      preferences: data['preferences'] as Map<String, dynamic>?,
    );
  }

  /// Convert model to Firestore-compatible JSON
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'libraryMemberId': libraryMemberId,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'preferredLanguage': preferredLanguage,
      'preferences': preferences,
    };
  }

  /// Convert model to domain entity
  /// This is the **mapper** step (↔ Express data transformation)
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      libraryMemberId: libraryMemberId,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hasCompletedOnboarding: hasCompletedOnboarding,
      preferredLanguage: preferredLanguage,
      preferences: preferences,
    );
  }

  /// Create factory constructor with default values
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      displayName: null,
      photoUrl: null,
      libraryMemberId: null,
      role: 'USER',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasCompletedOnboarding: false,
      preferredLanguage: 'en',
      preferences: null,
    );
  }
}
