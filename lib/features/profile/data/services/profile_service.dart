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
      await user.updateDisplayName(name);
    }
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == ProfileConstants.firebaseErrRequiresRecentLogin) {
          throw ProfileConstants.excRequiresRecentLogin;
        }
        throw e.message ?? ProfileConstants.genericError;
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
