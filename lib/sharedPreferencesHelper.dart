import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class SharedPreferencesHelper {
  static Future<String> getCurrentUserPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PREFS_CURRENT_USER) ?? "";
  }

  static setCurrentUserPrefs(String uid) async {
    print(uid);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PREFS_CURRENT_USER, uid);
  }
}
