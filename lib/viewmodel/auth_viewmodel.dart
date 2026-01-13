import 'dart:convert';
import 'dart:io';
import '../core/storage/app_preferences.dart';
import '../core/storage/pref_keys.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthViewModel extends ChangeNotifier {
  // 🔹 FORM KEY
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 🔹 Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
 


  // 🔹 State
  File? profileImage;
  String? base64Image;
  bool isLoading = false;
  bool hasSubmitted = false; 
  String? emailError;
  bool isCheckingEmail = false;


  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  
  /// 📸 Pick Image + convert to Base64
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      profileImage = file;
      base64Image = base64String;
      notifyListeners();
    }
  }

  /// 📝 Register User
  Future<String?> registerUser() async {
   
    if (!formKey.currentState!.validate()) {
      return 'Please fix the errors in the form';
    }

    if (profileImage == null || base64Image == null) {
      return 'Profile image is required';
    }

    isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      print('Saving userId to secure storage: $uid');


      await _firestore.collection('user').doc(uid).set({
        'uid': uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'profileImageBase64': base64Image,
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });


      await AppPreferences.putBool(PrefKeys.isLoggedIn, true);
      await AppPreferences.putString(PrefKeys.userId, uid);
      await AppPreferences.putString(
        PrefKeys.userName,
        usernameController.text.trim(),
      );


      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already in use';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 
  Future<String?> loginUser() async {
    isLoading = true;
    notifyListeners();
    


    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      await AppPreferences.putBool(PrefKeys.isLoggedIn, true);
      await AppPreferences.putString(PrefKeys.userId, uid);


      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

bool isLoggedIn() {
  return AppPreferences.getBool(PrefKeys.isLoggedIn);
}


Future<void> checkIfEmailExists(String email) async {
  if (email.isEmpty || !email.contains('@')) return;

  isCheckingEmail = true;
  notifyListeners();

  try {
    final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    if (methods.isNotEmpty) {
      emailError = 'Email already in use';
    } else {
      emailError = null;
    }
  } catch (e) {
    emailError = null; // fail silently
  }

  isCheckingEmail = false;
  notifyListeners();
}

Timer? _emailDebounce;

void onEmailChanged(String value) {
  if (_emailDebounce?.isActive ?? false) _emailDebounce!.cancel();

  _emailDebounce = Timer(const Duration(milliseconds: 500), () {
    checkIfEmailExists(value.trim());
  });
}


  /// 🚪 Logout User
  Future<void> logout() async {
    await AppPreferences.clear();
    await _auth.signOut();

  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}


// import 'dart:convert';
// import 'dart:io';
 
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
 
// class AuthViewModel extends ChangeNotifier {
//   // 🔹 FORM KEY
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
 
//   // 🔹 Controllers
//   final usernameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
 
//   // 🔹 State
//   File? profileImage;
//   String? base64Image;
//   bool isLoading = false;
 
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
 
//   /// 📸 Pick Image + convert to Base64
//   Future<void> pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
 
//     if (picked != null) {
//       final file = File(picked.path);
//       final bytes = await file.readAsBytes();
//       final base64String = base64Encode(bytes);
 
//       profileImage = file;
//       base64Image = base64String;
//       notifyListeners();
//     }
//   }
 
//   /// 📝 Register User
//   Future<String?> registerUser() async {
//     // 🔴 First: validate form
//     if (!formKey.currentState!.validate()) {
//       return 'Please fix the errors in the form';
//     }
 
//     if (profileImage == null || base64Image == null) {
//       return 'Profile image is required';
//     }
 
//     isLoading = true;
//     notifyListeners();
 
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
 
//       final uid = userCredential.user!.uid;
 
//       await _firestore.collection('user').doc(uid).set({
//         'uid': uid,
//         'username': usernameController.text.trim(),
//         'email': emailController.text.trim(),
//         'profileImageBase64': base64Image,
//         'provider': 'email',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
 
//       return null;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'email-already-in-use') {
//         return 'Email already in use';
//       } else if (e.code == 'weak-password') {
//         return 'Password is too weak';
//       }
//       return e.message;
//     } catch (e) {
//       return e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
 
//   @override
//   void dispose() {
//     usernameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
 