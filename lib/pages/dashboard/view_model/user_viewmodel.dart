import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/api_service.dart';
import '../../../model/user_model.dart';
import '../../../model/dashboard_user.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService api;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  UserViewModel(this.api);

  bool isInitialLoading = false;
  bool isActionLoading = false;

  List<DashboardUser> combinedUsers = [];

  // =========================
  // LOAD ALL USERS (FIXED - NEW RECORDS FIRST)
  // =========================
  Future<void> loadAllUsers({bool silent = false}) async {
    try {
      if (!silent) {
        isInitialLoading = true;
        notifyListeners();
      }

      try {
        final apiUsers = await api.getUsers();
        await _syncApiUsersToFirestore(apiUsers);
      } catch (apiError) {
        debugPrint('⚠️ API call failed: $apiError');
      }
      final List<DashboardUser> tempList = [];

      final apiSnapshot = await _firestore
          .collection('users_cache')
          .orderBy('createdAt', descending: true)
          .get();

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
      debugPrint('🎯 Total users loaded: ${combinedUsers.length}');

    } catch (e) {
      debugPrint('❌ LOAD ALL USERS ERROR: $e');

      if (e.toString().contains('index')) {
        debugPrint('⚠️ Firestore index missing, loading without ordering...');
        try {
          final apiSnapshot = await _firestore.collection('users_cache').get();
          final List<DashboardUser> tempList = [];

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

          tempList.sort((a, b) => b.id.compareTo(a.id));
          combinedUsers = tempList;
        } catch (fallbackError) {
          debugPrint('❌ Fallback load failed: $fallbackError');
        }
      }
    } finally {
      if (!silent) {
        isInitialLoading = false;
        notifyListeners();
      }
    }
  }

  // =========================
  // SYNC API USERS TO FIRESTORE
  // =========================
  Future<void> _syncApiUsersToFirestore(List<UserModel> apiUsers) async {
    try {
      if (apiUsers.isEmpty) {
        debugPrint('📭 No API users to sync');
        return;
      }

      debugPrint('💾 Syncing ${apiUsers.length} API users to Firestore...');
      final batch = _firestore.batch();

      for (final user in apiUsers) {
        final docRef = _firestore.collection('users_cache').doc(user.id.toString());

        // Check if document already exists
        final existingDoc = await docRef.get();

        final userData = {
          'apiId': user.id,
          'name': user.name,
          'email': user.email,
          'lastSynced': FieldValue.serverTimestamp(),
          'source': 'api',
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // 🔥 Only set createdAt if document doesn't exist
        if (!existingDoc.exists) {
          userData['createdAt'] = FieldValue.serverTimestamp();
        }

        batch.set(docRef, userData, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Successfully synced ${apiUsers.length} API users to Firestore cache');

    } catch (e) {
      debugPrint('❌ Error syncing API users to Firestore: $e');
    }
  }

  // =========================
  // CREATE USER (NEW RECORDS APPEAR FIRST)
  // =========================
  Future<String> createUser(String name, String email) async {
    try {
      isActionLoading = true;
      notifyListeners();

      // Call API
      final UserModel user = await api.createUser(name, email);

      final docRef = await _firestore.collection('users_cache').add({
        'apiId': user.id,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'manual',
      });

      debugPrint('✅ Created user with Firestore ID: ${docRef.id}');

      await loadAllUsers(silent: true);

      return docRef.id;
    } catch (e) {
      debugPrint('❌ CREATE USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE USER
  // =========================
  Future<void> updateUser(String firestoreId, String name, String email) async {
    try {
      isActionLoading = true;
      notifyListeners();

      debugPrint('Updating user with ID: $firestoreId');

      await _firestore
          .collection('users_cache')
          .doc(firestoreId)
          .update({
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Optional: Update in API
      final doc = await _firestore.collection('users_cache').doc(firestoreId).get();
      if (doc.exists && doc.data()?['apiId'] != null) {
        try {
          await api.updateUser(doc.data()!['apiId'], name, email);
        } catch (apiError) {
          debugPrint('API update failed: $apiError');
        }
      }

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('❌ UPDATE USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // DELETE USER
  // =========================
  Future<void> deleteUser(String firestoreId) async {
    try {
      isActionLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('users_cache').doc(firestoreId).get();

      if (doc.exists && doc.data()?['apiId'] != null) {
        try {
          await api.deleteUser(doc.data()!['apiId']);
        } catch (apiError) {
          debugPrint('API delete failed: $apiError');
        }
      }

      await _firestore.collection('users_cache').doc(firestoreId).delete();
      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('❌ DELETE USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE REGISTERED USER
  // =========================
  Future<void> updateRegisteredUser(String uid, String name, String email) async {
    try {
      isActionLoading = true;
      notifyListeners();

      await _firestore.collection('user').doc(uid).update({
        'username': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadAllUsers(silent: true);
    } catch (e) {
      debugPrint('❌ UPDATE REGISTERED USER ERROR: $e');
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
      debugPrint('❌ DELETE REGISTERED USER ERROR: $e');
      rethrow;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }
}