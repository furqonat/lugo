import 'package:shared_preferences/shared_preferences.dart';

const authStatus = 'authStatus';
const authState = 'authState';
const referal = 'referal';

class Preferences {
  final SharedPreferences preferences;

  Preferences(this.preferences);

  String getReferal() {
    return preferences.getString(referal) ?? '';
  }

  void setReferal(String ref) {
    preferences.setString(referal, ref);
  }

  bool getAuthstatus() {
    return preferences.getBool(authStatus) ?? false;
  }

  void setAuthStatus(bool status) {
    preferences.setBool(authStatus, status);
  }

  bool getIsSignIn() {
    return preferences.getBool(authState) ?? false;
  }

  void setIsSignIn([isSignIn = false]) {
    preferences.setBool(authState, isSignIn);
  }
}
