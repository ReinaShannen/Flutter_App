import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../core/storage/app_preferences.dart';
import '../../../core/storage/pref_keys.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;

  Future<void> login({
    required String email,
    required String password,
    required VoidCallback onSuccess,
    required Function(String message) onError,
    required Map<String, String> errorMessages,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        FirebaseAnalytics.instance.logEvent(
          name: 'login_success',
          parameters: {
            'user_id': user.uid,
            'method': 'email_password',
          },
        );

        await AppPreferences.putBool(PrefKeys.isLoggedIn, true);
        await AppPreferences.putString(PrefKeys.userId, user.uid);
        await AppPreferences.putString(
          PrefKeys.userName,
          user.email ?? '',
        );

        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      FirebaseAnalytics.instance.logEvent(
        name: 'login_failed',
        parameters: {'error_code': e.code},
      );

      onError(
        errorMessages[e.code] ?? errorMessages['default']!,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
