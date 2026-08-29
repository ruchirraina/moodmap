import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants/auth_constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;

    if (kIsWeb) {
      await _googleSignIn.initialize(clientId: AuthConstants.googleWebClientId);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _googleSignIn.initialize(
        clientId: AuthConstants.googleIosClientId,
        serverClientId: AuthConstants.googleWebClientId,
      );
    } else {
      await _googleSignIn.initialize(
        serverClientId: AuthConstants.googleWebClientId,
      );
    }
    _isGoogleSignInInitialized = true;
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthConstants.excGeneric;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthConstants.excGeneric;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      final googleUser = await _googleSignIn.authenticate();

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('canceled') ||
          errorString.contains('aborted') ||
          errorString.contains('sign_in_canceled')) {
        throw AuthConstants.excSignInAborted;
      }
      if (errorString.contains('network') ||
          errorString.contains('host') ||
          errorString.contains('connection') ||
          errorString.contains('offline')) {
        throw AuthConstants.excNetwork;
      }
      throw AuthConstants.excGoogleSignInFailed;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthConstants.excGeneric;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case AuthConstants.firebaseErrEmailInUse:
        return AuthConstants.excEmailInUse;
      case AuthConstants.firebaseErrUserNotFound:
      case AuthConstants.firebaseErrWrongPassword:
      case AuthConstants.firebaseErrInvalidCred:
        return AuthConstants.excInvalidCreds;
      case AuthConstants.firebaseErrInvalidEmail:
        return AuthConstants.excInvalidEmail;
      case AuthConstants.firebaseErrWeakPassword:
        return AuthConstants.excWeakPassword;
      case AuthConstants.firebaseErrUserDisabled:
        return AuthConstants.excUserDisabled;
      case AuthConstants.firebaseErrNetwork:
        return AuthConstants.excNetwork;
      default:
        return AuthConstants.excGeneric;
    }
  }
}
