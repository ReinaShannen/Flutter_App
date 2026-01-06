import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  File? profileImage;
  String? base64Image;
  bool isLoading = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Pick Image + convert to Base64
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

  /// Register User
  Future<String?> registerUser() async {
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

      await _firestore.collection('user').doc(uid).set({
        'uid': uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'profileImageBase64': base64Image,
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

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

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
