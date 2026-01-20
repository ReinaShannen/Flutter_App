import 'package:flutter/material.dart';
import '../storage/app_preferences.dart';
import '../services/remote_config_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _brandColor = const Color(0xFF6750A4); // default fallback

  ThemeMode get themeMode => _themeMode;
  Color get brandColor => _brandColor;

  ThemeProvider() {
    _loadThemeModeFromPrefs();
    _loadBrandColorFromRemoteConfig();
  }

  // ===============================
  // LOAD THEME MODE (Light/Dark/System)
  // ===============================
  void _loadThemeModeFromPrefs() {
    _themeMode = AppPreferences.getThemeMode();
  }

  // ===============================
  // LOAD BRAND COLOR FROM REMOTE CONFIG
  // ===============================
  void _loadBrandColorFromRemoteConfig() {
    final hex = RemoteConfigService.appThemeColor;

    if (hex.isNotEmpty) {
      _brandColor = _hexToColor(hex);
      debugPrint('Remote brand color applied: $hex');
    }

    notifyListeners();
  }

  // ===============================
  // SET THEME MODE FROM UI
  // ===============================
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    AppPreferences.setThemeMode(mode);
    notifyListeners();
  }

  // ===============================
  // LIGHT THEME
  // ===============================
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  // ===============================
  // DARK THEME
  // ===============================
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  // ===============================
  // HEX → COLOR CONVERTER
  // ===============================
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
