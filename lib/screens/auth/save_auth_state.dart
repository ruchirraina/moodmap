// save auth state
import 'package:shared_preferences/shared_preferences.dart';

class SaveAuthState {
  // SharedPreferences instance (initially null)
  static SharedPreferences? _pref;
  // auth state key to save if the user is post auth
  static const String _authStateKey = 'authState';

  // init shared preferences (not null)
  static Future<void> initSharedPreferences() async {
    // only init if not already initialized (prevent reinit)
    _pref ??= await SharedPreferences.getInstance();
  }

  // set auth state
  static Future<void> setAuthState({required bool state}) async {
    // iff SharedPreferences instance
    await _pref?.setBool(_authStateKey, state);
  }

  static bool loadAuthState() {
    // iff SharedPreferences instance
    return _pref?.getBool(_authStateKey) ?? false;
  }
}
