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
  String get invalidEmail => 'Enter a valid email address';

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
  String get register => 'Register';

  @override
  String get forceCrash => 'FORCE CRASH';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get users => 'Users';

  @override
  String get logout => 'Logout';

  @override
  String get addUser => 'Add User';

  @override
  String get editUser => 'Edit User';

  @override
  String get editRegisteredUser => 'Edit Registered User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this user?';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter username';

  @override
  String get emailHint => 'Enter email address';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameMinLength => 'Minimum 3 characters required';

  @override
  String get passwordLength => '6–20 characters required';

  @override
  String get passwordStrength => 'Use at least 1 upper, lower, number & special character';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get confirmLogoutTitle => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to logout?';
}
