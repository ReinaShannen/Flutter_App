import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(seconds: 10), 
      ),
    );

    await _remoteConfig.setDefaults({
      'maintenance_mode': false,
      'welcome_message': 'Welcome to the app',
      'show_register': true,
    });

    await _remoteConfig.fetchAndActivate();
  }

  static bool get maintenanceMode =>
      _remoteConfig.getBool('maintenance_mode');

  static String get welcomeMessage =>
      _remoteConfig.getString('welcome_message');

  static bool get showRegister =>
      _remoteConfig.getBool('show_register');

  static String get appThemeColor =>
    _remoteConfig.getString('app_theme_color');

}
