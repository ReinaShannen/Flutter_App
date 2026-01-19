// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get login => 'உள்நுழை';

  @override
  String get welcomeBack => 'மீண்டும் வரவேற்கிறோம்';

  @override
  String get loginToContinue => 'தொடர உள்நுழையவும்';

  @override
  String get emailRequired => 'மின்னஞ்சல் அவசியம்';

  @override
  String get passwordRequired => 'கடவுச்சொல் அவசியம்';

  @override
  String get invalidEmail => 'தவறான மின்னஞ்சல் வடிவம்';

  @override
  String get passwordTooShort => 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get loginFailed => 'உள்நுழைவு தோல்வியடைந்தது. மீண்டும் முயற்சிக்கவும்';

  @override
  String get wrongPassword => 'தவறான கடவுச்சொல்';

  @override
  String get userNotFound => 'இந்த மின்னஞ்சலுடன் கணக்கு இல்லை';

  @override
  String get userDisabled => 'இந்த கணக்கு முடக்கப்பட்டுள்ளது';

  @override
  String get genericError => 'ஏதோ தவறு ஏற்பட்டுள்ளது. மீண்டும் முயற்சிக்கவும்';

  @override
  String get emailLabel => 'மின்னஞ்சல்';

  @override
  String get passwordLabel => 'கடவுச்சொல்';

  @override
  String get dontHaveAccount => 'கணக்கு இல்லையா?';

  @override
  String get register => 'பதிவு';

  @override
  String get profileManager => 'சுயவிவர மேலாளர்';

  @override
  String get manageUsers => 'பயனர்களை எளிதாக நிர்வகிக்கவும்';

  @override
  String get homeSubtitle => 'Flutter மற்றும் Firebase மூலம்\nஅங்கீகாரம் மற்றும் தரவு';

  @override
  String get secureAuth => 'பாதுகாப்பான Firebase அங்கீகாரம்';

  @override
  String get manageUsersRealtime => 'நேரடியாக பயனர்களை நிர்வகிக்கவும்';

  @override
  String get cleanArchitecture => 'சுத்தமான MVVM கட்டமைப்பு';

  @override
  String get trustText => 'பாதுகாப்பு • வேகம் • Firebase Auth';

  @override
  String get forceCrash => 'கட்டாயக் கோளாறு';
}
