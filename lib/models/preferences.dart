import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences();

  static Future<void> save(Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in map.keys) {
      var value = map[key]!;
      prefs.setString(key, value);
    }
  }

  static Future<Map<String, String>> load() async {
    var map = <String, String>{};
    final prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys();
    for (var key in keys) {
      map[key] = prefs.getString(key)!;
    }
    return map;
  }

  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
