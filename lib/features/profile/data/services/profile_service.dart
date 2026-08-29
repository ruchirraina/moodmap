import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/profile_constants.dart';

class ProfileService {
  final FirebaseAuth _firebaseAuth;

  ProfileService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
      } on FirebaseAuthException catch (e) {
        throw _handleProfileException(e);
      } catch (e) {
        throw ProfileConstants.genericError;
      }
    }
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        throw _handleProfileException(e);
      } catch (e) {
        throw ProfileConstants.genericError;
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleProfileException(e);
    } catch (e) {
      throw ProfileConstants.genericError;
    }
  }

  String _handleProfileException(FirebaseAuthException e) {
    switch (e.code) {
      case ProfileConstants.firebaseErrRequiresRecentLogin:
        return ProfileConstants.excRequiresRecentLogin;
      case ProfileConstants.firebaseErrNetwork:
        return ProfileConstants.excNetwork;
      default:
        return ProfileConstants.genericError;
    }
  }
}
