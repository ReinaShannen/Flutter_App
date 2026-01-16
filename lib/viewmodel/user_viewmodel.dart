import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/services/api_service.dart';
import '../model/user_model.dart';
import '../model/dashboard_user.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService api;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserViewModel(this.api);

  bool isLoading = false;

  // FINAL unified list for dashboard
  List<DashboardUser> combinedUsers = [];

  // =========================
  // LOAD API USERS → SAVE TO users_cache
  // =========================
  Future<void> loadUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      final List<UserModel> users = await api.getUsers();

      final batch = _firestore.batch();

      for (var user in users) {
        final docRef =
            _firestore.collection('users_cache').doc(user.id.toString());

        batch.set(docRef, user.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      debugPrint('LOAD USERS ERROR: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD ALL USERS (API + REGISTERED)
  // =========================
  Future<void> loadAllUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      final List<DashboardUser> tempList = [];

      // =======================
      // API USERS (users_cache)
      // =======================
      final apiSnapshot = await _firestore.collection('users_cache').get();

      for (var doc in apiSnapshot.docs) {
        final data = doc.data();

        tempList.add(
          DashboardUser(
            id: doc.id, // API id
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            isRegistered: false,
            profileImageBase64: null,
          ),
        );
      }

      // =======================
      // REGISTERED USERS (user collection)
      // =======================
      final registeredSnapshot = await _firestore.collection('user').get();

      for (var doc in registeredSnapshot.docs) {
        final data = doc.data();

        tempList.add(
          DashboardUser(
            id: doc.id, // Firebase UID
            name: data['username'] ?? '',
            email: data['email'] ?? '',
            isRegistered: true,
            profileImageBase64: data['profileImageBase64'],
          ),
        );
      }

      combinedUsers = tempList;

      debugPrint(' Combined users loaded: ${combinedUsers.length}');
    } catch (e) {
      debugPrint('LOAD ALL USERS ERROR: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // CREATE USER (API)
  // =========================
  Future<void> createUser(String name, String email) async {
    try {
      final UserModel user = await api.createUser(name, email);

      await _firestore
          .collection('users_cache')
          .doc(user.id.toString())
          .set(user.toJson(), SetOptions(merge: true));

      await loadAllUsers();
    } catch (e) {
      debugPrint('CREATE USER ERROR: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE USER (API USER)
  // =========================
  Future<void> updateUser(int id, String name, String email) async {
    try {
      final UserModel updatedUser = await api.updateUser(id, name, email);

      await _firestore
          .collection('users_cache')
          .doc(id.toString())
          .update(updatedUser.toJson());

      await loadAllUsers();
    } catch (e) {
      debugPrint('UPDATE USER ERROR: $e');
      rethrow;
    }
  }

  // =========================
  // DELETE USER (API USER)
  // =========================
  Future<void> deleteUser(int id) async {
    try {
      await api.deleteUser(id);

      await _firestore.collection('users_cache').doc(id.toString()).delete();

      await loadAllUsers();
    } catch (e) {
      debugPrint('DELETE USER ERROR: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE REGISTERED USER (Firebase)
  // =========================
  Future<void> updateRegisteredUser(
    String uid,
    String name,
    String email,
  ) async {
    try {
      await _firestore.collection('user').doc(uid).update({
        'username': name,
        'email': email,
      });

      await loadAllUsers();
    } catch (e) {
      debugPrint('UPDATE REGISTERED USER ERROR: $e');
      rethrow;
    }
  }

  // =========================
  // DELETE REGISTERED USER (Firebase)
  // =========================
  Future<void> deleteRegisteredUser(String uid) async {
    try {
      await _firestore.collection('user').doc(uid).delete();

      await loadAllUsers();
    } catch (e) {
      debugPrint('DELETE REGISTERED USER ERROR: $e');
      rethrow;
    }
  }
  
}


// import 'package:flutter/material.dart';
// import '../core/services/api_service.dart';
// import '../../model/user_model.dart';

// class UserViewModel extends ChangeNotifier {
//   final ApiService api;

//   UserViewModel(this.api); 

//   bool isLoading = false;
//   List<UserModel> users = [];

//   /// GET
//   Future<void> loadUsers() async {
//     isLoading = true;
//     notifyListeners();

//     users = await api.getUsers();

//     isLoading = false;
//     notifyListeners();
//   }

//   /// POST
//   Future<void> createUser(String name, String email) async {
//     final user = await api.createUser(name, email);
//     users.add(user);
//     notifyListeners();

    
//   }

//   /// PUT
//   Future<void> updateUser(int id, String name, String email) async {
//     await api.updateUser(id, name, email);

//     final index = users.indexWhere((u) => u.id == id);
//     if (index != -1) {
//       users[index].name = name;
//       users[index].email = email;
//       notifyListeners();
//     }
//   }

//   /// DELETE
//   Future<void> deleteUser(int id) async {
//     await api.deleteUser(id);
//     users.removeWhere((u) => u.id == id);
//     notifyListeners();
//   }

//   /// LOGIN
//   bool login(String name, String email) {
//     return users.any(
//       (u) => u.name == name && u.email == email,
//     );
//   }
// }
