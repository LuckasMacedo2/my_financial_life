import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';

class CacheManager {
  SharedPreferences? _preferences;

  CacheManager._();

  static Future<CacheManager> getInstance() async {
    CacheManager cacheManager = CacheManager._();

    if (kIsWeb) {
      cacheManager._preferences = await SharedPreferences.getInstance();
    } else {
      cacheManager._preferences = await SharedPreferences.getInstance();
    }

    return cacheManager;
  }

  Future<void> saveData(String key, String data) async {
    await _preferences!.setString(key, data);
  }

  Future<String?> getData(String key) async {
    return _preferences!.getString(key);
  }
}
