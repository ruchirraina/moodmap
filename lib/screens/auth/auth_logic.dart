// auth logic code intended to be robust (especially net edges)
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:moodmap/screens/auth/auth_state.dart';

class AuthLogic {
  // init FirebaseAuth instance
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // defined duration to prevent infinite loading spinners/screens when net bad
  static final Duration _timeOut = const Duration(seconds: 10);

  // defined err msg when timeout/trouble connecting to firebase servers
  static final String _netwErrMsg =
      'Connection timed out! You may check your internet connection and try again.';

  // default err msg (idk what happened)
  static final String _defErrMsg =
      'An unkown error occurred! You may try again.';

  // sign up with email+pass
  static Future<String?> signUpWithEmailPass({
    required String email,
    required String password,
    required String name,
  }) async {
    // create UserCredential object (default null)
    UserCredential? credential;

    try {
      // try creating user with input email + password
      credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(_timeOut);

      // try updating user's display name
      await credential.user!.updateDisplayName(name.trim()).timeout(_timeOut);
      await credential.user!.reload();
      // success sign up
      await AuthState.setAuthState(state: true);
      return null;
    } // handle TimeoutException
    on TimeoutException {
      // try deleting the faulty user
      credential?.user?.delete().ignore();
      return _netwErrMsg;
    } // handle FirebaseAuthException
    on FirebaseAuthException catch (e) {
      credential?.user?.delete().ignore();
      return _errMsgFirebaseAuthException(e);
    } // idk what happened
    catch (e) {
      credential?.user?.delete().ignore();
      return _defErrMsg;
    }
  }

  // sign in with email+pass
  static Future<String?> signInWithEmailPass({
    required String email,
    required String password,
  }) async {
    // trying signing in user with email+pass
    try {
      await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(_timeOut);
      // success sign in
      await AuthState.setAuthState(state: true);
      return null;
    } // handle TimeoutException
    on TimeoutException {
      return _netwErrMsg;
    } // handle FirebaseAuthException
    on FirebaseAuthException catch (e) {
      return _errMsgFirebaseAuthException(e);
    } // idk what happened
    catch (e) {
      return _defErrMsg;
    }
  }

  // forgot password
  static Future<String?> forgotPassword({required String email}) async {
    try {
      // attempt sending password reset link
      await _auth.sendPasswordResetEmail(email: email.trim()).timeout(_timeOut);
      // success
      await AuthState.setAuthState(state: true);
      return null;
    } // handle TimeoutException
    on TimeoutException {
      return _netwErrMsg;
    } // handle FirebaseAuthException
    on FirebaseAuthException catch (e) {
      return _errMsgFirebaseAuthException(e);
    } // idk what happened
    catch (e) {
      return _defErrMsg;
    }
  }

  static Future<String?> googleAuth() async {
    try {
      // init instance
      await GoogleSignIn.instance.initialize();

      // trigger google auth popup and store user info
      final googleUser = await GoogleSignIn.instance.authenticate();

      // request acess token for email of user
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
      ]);

      // create credential object
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: clientAuth.accessToken,
      );

      // attemp auth via firebase
      await _auth.signInWithCredential(credential).timeout(_timeOut);
      // success
      await AuthState.setAuthState(state: true);
      return null;
    } // handle TimeoutException
    on TimeoutException {
      await GoogleSignIn.instance.signOut();
      return _netwErrMsg;
    } // handle FirebaseAuthException
    on FirebaseAuthException catch (e) {
      await GoogleSignIn.instance.signOut();
      return _errMsgFirebaseAuthException(e);
    } // maybe google auth error idk
    catch (e) {
      await GoogleSignIn.instance.signOut();
      // catch network drops
      final String errorString = e.toString().toLowerCase();
      if (errorString.contains('network')) {
        return _netwErrMsg;
      }
      return _defErrMsg;
    }
  }

  // sign out func
  static void signOutAuth() async {
    await GoogleSignIn.instance.disconnect().catchError((_) => null);
    await _auth.signOut().catchError((_) => null);
    await AuthState.setAuthState(state: false);
  }

  // error messages for FirebaseAuthException
  static String _errMsgFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return _netwErrMsg;
      case 'too-many-requests':
        return 'Too many attempts! You may try again later.';
      case 'invalid-email':
        return 'This email is invalid!';
      case 'email-already-in-use':
        return 'This email is already in use!';
      case 'weak-password':
        return 'This password is too weak!';
      case 'invalid-credential':
        return "Incorrect email or password!";
      case 'user-disabled':
        return 'This account has been disabled! Contact support: ruchirrainafun@gmail.com.';
      default:
        return _defErrMsg;
    }
  }
}
