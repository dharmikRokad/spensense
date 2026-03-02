import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> initializeGoogleSignIn();
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  bool _isGoogleInitialized = false;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  // ─── Google Sign-In Initialization ──────────────────────────────────────

  @override
  Future<void> initializeGoogleSignIn() async {
    if (_isGoogleInitialized) return;
    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize();

      signIn.authenticationEvents.listen(
        _handleAuthEvent,
        onError: _handleAuthError,
      );

      // Attempt silent re-auth if a session already exists (no UI shown)
      await signIn.attemptLightweightAuthentication();
      _isGoogleInitialized = true;
    } catch (e) {
      // Non-fatal — full sign-in flow can still proceed
      appLogger.w('Google Sign-In initialization warning: $e');
    }
  }

  Future<void> _handleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    appLogger.d('Google auth event: $event');
  }

  Future<void> _handleAuthError(Object e) async {
    appLogger.e('Google auth stream error: $e');
  }

  // ─── Sign In ─────────────────────────────────────────────────────────────

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await initializeGoogleSignIn();

      final signIn = GoogleSignIn.instance;

      if (!signIn.supportsAuthenticate()) {
        throw const AuthException(
          'Google Sign-In is not supported on this platform.',
        );
      }

      final googleUser = await signIn.authenticate();
      final googleAuth = googleUser.authentication;

      appLogger.d('Google ID Token obtained for: ${googleUser.email}');

      // Build Firebase credential — only idToken is required for Android/iOS
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthException('No Firebase user returned after sign-in.');
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName:
            firebaseUser.displayName ?? googleUser.displayName ?? 'User',
        photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        createdAt: DateTime.now(),
      );

      // Persist to Firestore only on first sign-in
      final docRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userModel.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set(userModel.toJson());
        appLogger.i('New user saved to Firestore: ${userModel.uid}');
      }

      return userModel;
    } on AuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      final msg = _messageFromGoogleException(e);
      appLogger.e('GoogleSignInException: $msg', error: e);
      throw AuthException(msg);
    } on FirebaseAuthException catch (e) {
      final msg = _messageFromFirebaseException(e);
      appLogger.e('FirebaseAuthException [${e.code}]: $msg', error: e);
      throw AuthException(msg);
    } catch (e) {
      appLogger.e('Unexpected sign-in error', error: e);
      throw AuthException('Sign-in failed: ${e.toString()}');
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
      _isGoogleInitialized = false;
      appLogger.i('User signed out successfully.');
    } catch (e) {
      appLogger.e('Sign-out error', error: e);
      throw AuthException('Sign-out failed: ${e.toString()}');
    }
  }

  // ─── Current User ─────────────────────────────────────────────────────────

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      // Fallback: construct from Firebase user object
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AuthException('Failed to fetch current user: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await getCurrentUser();
      } catch (_) {
        return null;
      }
    });
  }

  // ─── Error Message Helpers ─────────────────────────────────────────────────

  String _messageFromGoogleException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign-in was cancelled.',
      GoogleSignInExceptionCode.interrupted =>
        'Sign-in was interrupted. Please try again.',
      _ => 'Google Sign-In failed: ${e.description ?? e.code.toString()}',
    };
  }

  String _messageFromFirebaseException(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'invalid-email' => 'Invalid email address.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' => 'Network error. Check your connection.',
      'account-exists-with-different-credential' =>
        'An account exists with a different sign-in method.',
      'invalid-credential' => 'Credential is malformed or has expired.',
      _ => 'Authentication failed. Please try again.',
    };
  }
}
