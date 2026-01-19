// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'LOGIN';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToContinue => 'Login to continue';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginFailed => 'Login failed. Please try again';

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String get userNotFound => 'No account found with this email';

  @override
  String get userDisabled => 'This account has been disabled';

  @override
  String get genericError => 'Something went wrong. Please try again';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get dontHaveAccount => 'Don’t have an account?';

  @override
  String get register => 'REGISTER';

  @override
  String get profileManager => 'Profile Manager';

  @override
  String get manageUsers => 'Manage users easily';

  @override
  String get homeSubtitle => 'Authentication & data powered by\nFlutter and Firebase';

  @override
  String get secureAuth => 'Secure Firebase Authentication';

  @override
  String get manageUsersRealtime => 'Manage users in real-time';

  @override
  String get cleanArchitecture => 'Clean MVVM architecture';

  @override
  String get trustText => 'Secure • Fast • Firebase Auth';

  @override
  String get forceCrash => 'FORCE CRASH';
}
