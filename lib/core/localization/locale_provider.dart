import 'package:flutter/material.dart';
import '../storage/app_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() {
    final code = AppPreferences.getString(_localeKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await AppPreferences.putString(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
