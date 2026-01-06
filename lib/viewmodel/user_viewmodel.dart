import 'package:flutter/material.dart';
import '../../model/user_model.dart';
import '../../core/services/api_service.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<UserModel> users = [];

  // =========================
  // GET USERS
  // =========================
  Future<void> loadUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      users = await _apiService.request<List<UserModel>>(
        endpoint: 'users',
        method: HttpMethod.get,
        parser: (json) {
          final List list = json as List;
          return list.map((e) => UserModel.fromJson(e)).toList();
        },
      );
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
      final newUser = await _apiService.request<UserModel>(
        endpoint: 'users',
        method: HttpMethod.post,
        body: {
          'name': name,
          'email': email,
        },
        parser: (json) => UserModel.fromJson(json),
      );

      users.add(newUser);
      notifyListeners();
    } catch (e) {
      debugPrint('CREATE USER ERROR: $e');
    }
  }

  // =========================
  // UPDATE USER
  // =========================
  Future<void> updateUser(int id, String name, String email) async {
    try {
      await _apiService.request<void>(
        endpoint: 'users/$id',
        method: HttpMethod.put,
        body: {
          'name': name,
          'email': email,
        },
        parser: (_) => null,
      );

      final index = users.indexWhere((u) => u.id == id);
      if (index != -1) {
        users[index].name = name;
        users[index].email = email;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('UPDATE USER ERROR: $e');
    }
  }

  // =========================
  // DELETE USER
  // =========================
  Future<void> deleteUser(int id) async {
    try {
      await _apiService.request<void>(
        endpoint: 'users/$id',
        method: HttpMethod.delete,
        parser: (_) => null,
      );

      users.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('DELETE USER ERROR: $e');
    }
  }

  // =========================
  // LOGIN (LOCAL CHECK)
  // =========================
  bool login(String name, String email) {
    return users.any(
      (u) => u.name == name && u.email == email,
    );
  }
}
