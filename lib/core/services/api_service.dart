import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // =========================
  // GET USERS
  // =========================
  Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // =========================
  // CREATE USER
  // =========================
  Future<UserModel> createUser(String name, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to create user');
    }
  }

  // =========================
  // UPDATE USER
  // =========================
  Future<UserModel> updateUser(int id, String name, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to update user');
    }
  }

  // =========================
  // DELETE USER
  // =========================
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
















//W/O API CHANGES ----------------------------
//// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../model/user_model.dart';

// class ApiService {
//   static const String baseUrl =
//       'https://jsonplaceholder.typicode.com';


//   // GET
//   Future<List<UserModel>> getUsers() async {
//     final res = await http.get(Uri.parse('$baseUrl/users'));

//     if (res.statusCode == 200) {
//       final List data = jsonDecode(res.body);
//       return data.map((e) => UserModel.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load users');
//     }
//   }

//   // POST
//   Future<UserModel> createUser(String name, String email) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/users'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'name': name, 'email': email}),
//     );

//     if (res.statusCode == 201 || res.statusCode == 200) {
//       return UserModel.fromJson(jsonDecode(res.body));
//     } else {
//       throw Exception('Failed to create user');
//     }
//   }

//   // PUT
//   Future<UserModel> updateUser(int id, String name, String email) async {
//     final res = await http.put(
//       Uri.parse('$baseUrl/users/$id'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'name': name, 'email': email}),
//     );

//     if (res.statusCode == 200) {
//       return UserModel.fromJson(jsonDecode(res.body));
//     } else {
//       throw Exception('Failed to update user');
//     }
//   }

//   // DELETE
//   Future<void> deleteUser(int id) async {
//     final res = await http.delete(Uri.parse('$baseUrl/users/$id'));

//     if (res.statusCode != 200 && res.statusCode != 204) {
//       throw Exception('Failed to delete user');
//     }
//   }
// }

















// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../model/user_model.dart';

// class ApiService {
//   static const String baseUrl =
//       'https://jsonplaceholder.typicode.com/users';

// //   /// GET - Fetch users
// //   Future<List<UserModel>> getUsers() async {

// //     final res = await http.get(Uri.parse(baseUrl));

// //     if (res.statusCode == 200) {
// //       final List data = jsonDecode(res.body);
// //       return data
// //           .map((e) => UserModel.fromJson(e))
// //           .toList(); 
// //     } else {
// //       throw Exception('Failed to load users');
// //     }
// //   }

// //   /// POST - Create user
// //   Future<UserModel> createUser(String name, String email) async {
// //     final res = await http.post(
// //       Uri.parse(baseUrl),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({
// //         'name': name,
// //         'email': email,
// //       }),
      
// //     );

// //     final data = jsonDecode(res.body);

// //     return UserModel(
// //       id: data['id'] ?? DateTime.now().millisecondsSinceEpoch,
// //       name: name,
// //       email: email,
// //     );
// //   }

// //   /// PUT - Update user
// //   Future<void> updateUser(int id, String name, String email) async {
// //     await http.put(
// //       Uri.parse('$baseUrl/$id'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({
// //         'name': name,
// //         'email': email,
// //       }),
// //     );
// //   }

// //   /// DELETE - Delete user
// //   Future<void> deleteUser(int id) async {
// //     await http.delete(Uri.parse('$baseUrl/$id'));
// //   }
// // }

