import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/services/api_service.dart';
import '../model/user_model.dart';
import '../model/dashboard_user.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService api;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserViewModel(this.api);

  // 🔹 Separate loading states (THIS FIXES THE GLITCH)
  bool isInitialLoading = false; // first dashboard load
  bool isActionLoading = false;  // add / update / delete

  List<DashboardUser> combinedUsers = [];

  // =========================
  // LOAD ALL USERS
  // =========================
  Future<void> loadAllUsers({bool silent = false}) async {
    try {
      if (!silent) {
        isInitialLoading = true;
        notifyListeners();
      }

      final List<DashboardUser> tempList = [];

      // ---- API USERS
      final apiSnapshot = await _firestore.collection('users_cache').get();
      for (var doc in apiSnapshot.docs) {
        final data = doc.data();
        tempList.add(
          DashboardUser(
            id: doc.id,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            isRegistered: false,
            profileImageBase64: null,
          ),
        );
      }

      // ---- REGISTERED USERS
      final registeredSnapshot = await _firestore.collection('user').get();
      for (var doc in registeredSnapshot.docs) {
        final data = doc.data();
        tempList.add(
          DashboardUser(
            id: doc.id,
            name: data['username'] ?? '',
            email: data['email'] ?? '',
            isRegistered: true,
            profileImageBase64: data['profileImageBase64'],
          ),
        );
      }

      combinedUsers = tempList;
    } catch (e) {
      debugPrint('LOAD ALL USERS ERROR: $e');
    } finally {
      if (!silent) {
        isInitialLoading = false;
        notifyListeners();
      }
    }
  }

  // =========================
  // CREATE USER
  // =========================
  Future<void> createUser(String name, String email) async {
    try {
      isActionLoading = true;
      notifyListeners();

      final UserModel user = await api.createUser(name, email);

      await _firestore
          .collection('users_cache')
          .doc(user.id.toString())
          .set(user.toJson(), SetOptions(merge: true));

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('CREATE USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE API USER
  // =========================
  Future<void> updateUser(int id, String name, String email) async {
    try {
      isActionLoading = true;
      notifyListeners();

      await api.updateUser(id, name, email);

      await _firestore
          .collection('users_cache')
          .doc(id.toString())
          .update({'name': name, 'email': email});

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('UPDATE USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // DELETE API USER
  // =========================
  Future<void> deleteUser(int id) async {
    try {
      isActionLoading = true;
      notifyListeners();

      await api.deleteUser(id);
      await _firestore.collection('users_cache').doc(id.toString()).delete();

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('DELETE USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE REGISTERED USER
  // =========================
  Future<void> updateRegisteredUser(
    String uid,
    String name,
    String email,
  ) async {
    try {
      isActionLoading = true;
      notifyListeners();

      await _firestore.collection('user').doc(uid).update({
        'username': name,
        'email': email,
      });

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('UPDATE REGISTERED USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // DELETE REGISTERED USER
  // =========================
  Future<void> deleteRegisteredUser(String uid) async {
    try {
      isActionLoading = true;
      notifyListeners();

      await _firestore.collection('user').doc(uid).delete();

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('DELETE REGISTERED USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }
}
