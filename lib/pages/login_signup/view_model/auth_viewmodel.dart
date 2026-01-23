import 'dart:convert';
import 'dart:io';
import '../../../core/storage/app_preferences.dart';
import '../../../core/storage/pref_keys.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class AuthViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  File? profileImage;
  String? base64Image;
  bool isLoading = false;
  bool hasSubmitted = false;
  String? emailError;
  bool isCheckingEmail = false;
  String? imageError;

  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> pickImage() async {
    imageError = null;

    try {
      debugPrint('Starting image picker...');

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked == null) {
        debugPrint('No image selected');
        return;
      }

      debugPrint('image selected: ${picked.path}');
      final file = File(picked.path);

      if (!await file.exists()) {
        imageError = 'Selected file does not exist';
        _showError(imageError!);
        notifyListeners();
        return;
      }

      debugPrint('File exists');

      // Check file size 
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB

      debugPrint('File size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

      if (fileSize > maxSize) {
        imageError = 'Image is too large. Maximum size is 5MB.';
        _showError(imageError!);
        notifyListeners();
        return;
      }

      if (fileSize == 0) {
        imageError = 'Image file is empty';
        _showError(imageError!);
        notifyListeners();
        return;
      }

      debugPrint('Converting to base64...');

      // Convert to base64
      final base64String = await convertImageToBase64(file);

      if (base64String.isEmpty) {
        imageError = 'Failed to convert image';
        _showError(imageError!);
        notifyListeners();
        return;
      }

      debugPrint('Base64 conversion successful: ${base64String.length} characters');

      try {
        final decoded = base64Decode(base64String);

        if (decoded.isEmpty) {
          throw Exception('Decoded image is empty');
        }

        debugPrint('Base64 validation successful: ${decoded.length} bytes decoded');
      } catch (e) {
        imageError = 'Invalid image format: ${e.toString()}';
        _showError(imageError!);
        notifyListeners();
        return;
      }

     profileImage = file;
      base64Image = base64String;
      imageError = null;
      notifyListeners();

      debugPrint('Image picked successfully. Size: ${base64String.length} characters');
    } catch (e, stackTrace) {
      debugPrint('Error picking image: $e');
      debugPrint('Stack trace: $stackTrace');
      imageError = 'Error selecting image: ${e.toString()}';
      _showError(imageError!);
      notifyListeners();
    }
  }

  /// Convert Image to Base64
  Future<String> convertImageToBase64(File image) async {
    try {
      debugPrint('Reading file: ${image.path}');

      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Image file is empty - no bytes read');
      }

      debugPrint('Read ${bytes.length} bytes from file');

      final base64String = base64Encode(bytes);

      if (base64String.isEmpty) {
        throw Exception('Base64 encoding resulted in empty string');
      }

      debugPrint('Base64 string length: ${base64String.length} characters');

      try {
        final testDecode = base64Decode(base64String);
        debugPrint('Validation: Successfully decoded ${testDecode.length} bytes');
      } catch (e) {
        throw Exception('Base64 validation failed: $e');
      }

      return base64String;
    } catch (e, stackTrace) {
      debugPrint('Error converting image to base64: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Show Error (can be customized to show snackbar)
  void _showError(String message) {
    debugPrint('Error: $message');
    // TODO: Implement snackbar or dialog
  }

  /// 📝 Register User
  Future<String?> registerUser() async {
    debugPrint('Starting Firestore-first registration...');

    // Validate form
    if (!formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return 'Please fix the errors in the form';
    }

    // Validate image
    if (profileImage == null || base64Image == null || base64Image!.isEmpty) {
      debugPrint('No profile image selected');
      return 'Profile image is required';
    }

    debugPrint('Form valid, image present (${base64Image!.length} chars)');

    // Validate base64 string
    try {
      final testDecode = base64Decode(base64Image!);
      debugPrint('Pre-upload validation: ${testDecode.length} bytes decoded');
    } catch (e) {
      debugPrint('Base64 validation failed: $e');
      return 'Invalid profile image. Please select again.';
    }

    isLoading = true;
    notifyListeners();

    String? email = emailController.text.trim();
    String? username = usernameController.text.trim();
    String? password = passwordController.text.trim();

    // Generate temporary ID for Firestore
    String tempDocId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${_firestore.collection('temp').doc().id}';
    debugPrint(' Generated temporary document ID: $tempDocId');

    try {
      // STEP 1: Save user data to Firestore first (with pending status)
      debugPrint('STEP 1: Creating Firestore document with pending status...');

      final pendingUserData = {
        'tempId': tempDocId,
        'username': username,
        'email': email,
        'profileImageBase64': base64Image!,
        'provider': 'email',
        'status': 'pending', 
        'createdAt': FieldValue.serverTimestamp(),
      };

      debugPrint('   - Username: $username');
      debugPrint('   - Email: $email');
      debugPrint('   - Image size: ${base64Image!.length} characters');

      // Save to Firestore with temporary ID
      await _firestore.collection('user').doc(tempDocId).set(pendingUserData);
      debugPrint('STEP 1: Firestore document created with pending status');

      // STEP 2: Create Firebase Auth user
      debugPrint('STEP 2: Creating Firebase Auth user...');

      UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authError) {
        debugPrint('Auth creation failed, cleaning up Firestore document...');
        // Clean up the Firestore document since Auth failed
        await _firestore.collection('user').doc(tempDocId).delete();
        debugPrint('Cleaned up Firestore document: $tempDocId');

        // Re-throw the auth error for the existing error handling
        throw authError;
      }

      final uid = userCredential.user!.uid;
      debugPrint(' STEP 2: Auth user created with final UID: $uid');

      // STEP 3: Update Firestore with final UID
      debugPrint('STEP 3: Updating Firestore with final UID...');

      final finalUserData = {
        'uid': uid,
        'username': username,
        'email': email,
        'profileImageBase64': base64Image!,
        'provider': 'email',
        'status': 'active', // Update status to active
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Method 1: Update the existing document (keeping temp ID)
      await _firestore.collection('user').doc(tempDocId).update({
        'uid': uid,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Updated existing document with UID');

      

      debugPrint('STEP 3: Firestore updated successfully');

      // STEP 4: Update Firebase Auth user profile
      debugPrint(' STEP 4: Updating Auth user profile...');

      try {
        await userCredential.user!.updateDisplayName(username);
        debugPrint('Auth display name updated');
      } catch (e) {
        debugPrint('Could not update Auth display name: $e');
        // Non-critical error, continue
      }

      // STEP 5: Save to local preferences
      debugPrint('STEP 5: Saving to local preferences...');

      await AppPreferences.putBool(PrefKeys.isLoggedIn, true);
      await AppPreferences.putString(PrefKeys.userId, uid);
      await AppPreferences.putString(PrefKeys.userName, username);

      debugPrint('Local preferences saved');
      debugPrint('Firestore-first registration completed successfully!');

      return null; // Success

    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code}');
      debugPrint('   Message: ${e.message}');

      if (e.code == 'email-already-in-use') {
        return 'Email already in use';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Authentication error occurred';

    } on FirebaseException catch (e) {
      debugPrint('Firestore Error: ${e.code}');
      debugPrint('   Message: ${e.message}');

      // Check if it's a document size issue
      if (e.code == 'invalid-argument') {
        return 'Image data is invalid or too large. Please try a different image.';
      } else if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore rules.';
      }

      return 'Database error: ${e.message}';

    } catch (e, stackTrace) {
      debugPrint('Unexpected Registration Error: $e');

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  ///  Login User
  Future<String?> loginUser() async {
    debugPrint('Starting login...');

    isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      debugPrint(' User logged in: $uid');

      await AppPreferences.putBool(PrefKeys.isLoggedIn, true);
      await AppPreferences.putString(PrefKeys.userId, uid);

      // Optionally fetch and save username
      try {
        final userDoc = await _firestore.collection('user').doc(uid).get();
        if (userDoc.exists) {
          final username = userDoc.data()?['username'] as String?;
          if (username != null) {
            await AppPreferences.putString(PrefKeys.userName, username);
          }
        }
      } catch (e) {
        debugPrint('Could not fetch user data: $e');
      }

      debugPrint('Login completed successfully');
      return null;

    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.code} - ${e.message}');

      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        return 'This account has been disabled';
      }

      return e.message ?? 'Login failed';

    } catch (e) {
      debugPrint('Unexpected login error: $e');
      return 'Login failed: ${e.toString()}';

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return AppPreferences.getBool(PrefKeys.isLoggedIn);
  }

  /// Check if email exists (with debouncing)
  Future<void> checkIfEmailExists(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      emailError = null;
      notifyListeners();
      return;
    }

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
      debugPrint('Email check error: $e');
      emailError = null;
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

  /// Logout User
  Future<void> logout() async {
    debugPrint('Logging out...');

    await AppPreferences.clear();
    await _auth.signOut();

    // Clear state
    profileImage = null;
    base64Image = null;
    emailError = null;
    imageError = null;

    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    notifyListeners();
    debugPrint('Logout completed');
  }

  /// Dispose
  @override
  void dispose() {
    _emailDebounce?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}