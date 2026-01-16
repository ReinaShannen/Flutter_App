import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AppPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================== STRING ==================

  static Future<void> putString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // ================== INT ==================

  static Future<void> putInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  // ================== BOOL ==================

  static Future<void> putBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // ================== THEME MODE ==================

  static Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs?.setString('theme_mode', mode.name);
  }

  static ThemeMode getThemeMode() {
    final mode = _prefs?.getString('theme_mode') ?? 'system';

    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ================== REMOVE / CLEAR ==================

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
