import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/user_entity.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Subscribe to Firebase auth stream — updates state reactively
    ref.watch(authRepositoryProvider).authStateChanges.listen((user) {
      if (user != null) {
        state = AsyncData(AuthAuthenticated(user));
      } else {
        state = const AsyncData(AuthUnauthenticated());
      }
    });

    // Resolve initial state from current Firebase session
    final result = await ref.read(authRepositoryProvider).getCurrentUser();
    return result.fold(
      (failure) => const AuthUnauthenticated(),
      (user) =>
          user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithGoogleProvider).call();
    state = result.fold(
      (failure) => AsyncData(AuthError(failure.message)),
      (user) => AsyncData(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await ref.read(signOutUseCaseProvider).call();
    state = result.fold(
      (failure) => AsyncData(AuthError(failure.message)),
      (_) => const AsyncData(AuthUnauthenticated()),
    );
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// Convenience: returns the current user or null
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider).value;
  if (authState is AuthAuthenticated) return authState.user;
  return null;
});
