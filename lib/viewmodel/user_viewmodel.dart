import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/api_service.dart';
import '../../model/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService api;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserViewModel(this.api);

  bool isLoading = false;

  // =========================
  // LOAD USERS (API → Firestore)
  // =========================
  Future<void> loadUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      debugPrint('Calling API to load users...');
      final List<UserModel> users = await api.getUsers();

      final batch = _firestore.batch();

      for (var user in users) {
        final docRef =
            _firestore.collection('users_cache').doc(user.id.toString());

        batch.set(docRef, user.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('All users saved to Firestore successfully');
    } catch (e) {
      debugPrint('LOAD USERS ERROR: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // CREATE USER
  // =========================
  Future<void> createUser(String name, String email) async {
    try {
      final UserModel user = await api.createUser(name, email);

      await _firestore
          .collection('users_cache')
          .doc(user.id.toString())
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('CREATE USER ERROR: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE USER
  // =========================
  Future<void> updateUser(int id, String name, String email) async {
    try {
      final UserModel updatedUser = await api.updateUser(id, name, email);

      await _firestore
          .collection('users_cache')
          .doc(id.toString())
          .update(updatedUser.toJson());
    } catch (e) {
      debugPrint('UPDATE USER ERROR: $e');
      rethrow;
    }
  }

  // =========================
  // DELETE USER
  // =========================
  Future<void> deleteUser(int id) async {
    try {
      await api.deleteUser(id);

      await _firestore.collection('users_cache').doc(id.toString()).delete();
    } catch (e) {
      debugPrint('DELETE USER ERROR: $e');
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
