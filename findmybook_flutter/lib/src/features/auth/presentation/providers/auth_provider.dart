/// Auth state and providers using Riverpod
/// 
/// MERN Comparison:
/// - Riverpod Provider ↔ Redux store + selectors
/// - StateNotifier ↔ Redux reducer + actions
/// - AsyncValue<T> ↔ {loading, success, error} states
/// - watch() ↔ useSelector() in React
/// 
/// Real-time Updates:
/// - streamCurrentUser() ↔ Redux middleware + WebSocket listener
/// - StreamProvider ↔ Redux listener that re-emits on Firestore changes

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_library_app/src/core/services/service_locator.dart';
import 'package:smart_library_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_library_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_library_app/src/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:smart_library_app/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_library_app/src/features/auth/domain/usecases/sign_up_usecase.dart';

// ============================================================================
// Use Case Providers (GetIt injection)
// ============================================================================

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => getIt<SignUpUseCase>(),
);

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => getIt<SignInUseCase>(),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => getIt<SignOutUseCase>(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);

// ============================================================================
// Real-time User Stream (Firestore Listener)
// ============================================================================

/// Stream current user whenever their data changes in Firestore
/// 
/// This is our **real-time listener** that emits whenever:
/// - User signs in
/// - User profile is updated
/// - Firestore document changes
/// 
/// ↔ Redux middleware listening to WebSocket events
final currentUserStreamProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).streamCurrentUser();
});

// ============================================================================
// Auth State Management
// ============================================================================

/// Auth state containing authentication-related data
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  /// Copy with pattern (↔ Redux state mutations)
  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth State Notifier (↔ Redux reducer + action dispatcher)
class AuthNotifier extends StateNotifier<AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final AuthRepository authRepository;

  AuthNotifier({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.authRepository,
  }) : super(AuthState());

  /// Sign up user
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String libraryMemberId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await signUpUseCase(
      email: email,
      password: password,
      displayName: displayName,
      libraryMemberId: libraryMemberId,
    );

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      ),
    );
  }

  /// Sign in user
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      ),
    );
  }

  /// Sign out user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await signOutUseCase();

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (_) => state = AuthState(), // Reset to initial state
    );
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await authRepository.updateUserProfile(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      preferences: preferences,
    );

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
      ),
    );
  }
}

/// Auth provider using StateNotifier
/// 
/// Access in widgets:
/// ```dart
/// final authState = ref.watch(authNotifierProvider);
/// 
/// // For reading
/// if (authState.isAuthenticated) {
///   print("User: ${authState.user?.email}");
/// }
/// 
/// // For writing/actions
/// ref.read(authNotifierProvider.notifier).signIn(
///   email: email,
///   password: password,
/// );
/// ```
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    signInUseCase: ref.watch(signInUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

// ============================================================================
// Computed Providers (↔ Redux selectors)
// ============================================================================

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Get current user
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

/// Check if auth operation is loading
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

/// Get auth error message
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).errorMessage;
});

/// Check if user is admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});

/// Check if user is librarian
final isLibrarianProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isLibrarian ?? false;
});
