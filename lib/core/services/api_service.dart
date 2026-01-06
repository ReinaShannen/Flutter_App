import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/user_model.dart';
// class ApiService {
//   static const String baseUrl =
//       'https://jsonplaceholder.typicode.com/users';

//   /// GET - Fetch users
//   Future<List<UserModel>> getUsers() async {

//     final res = await http.get(Uri.parse(baseUrl));

//     if (res.statusCode == 200) {
//       final List data = jsonDecode(res.body);
//       return data
//           .map((e) => UserModel.fromJson(e))
//           .toList(); 
//     } else {
//       throw Exception('Failed to load users');
//     }
//   }

//   /// POST - Create user
//   Future<UserModel> createUser(String name, String email) async {
//     final res = await http.post(
//       Uri.parse(baseUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': name,
//         'email': email,
//       }),
      
//     );

//     final data = jsonDecode(res.body);

//     return UserModel(
//       id: data['id'] ?? DateTime.now().millisecondsSinceEpoch,
//       name: name,
//       email: email,
//     );
//   }

//   /// PUT - Update user
//   Future<void> updateUser(int id, String name, String email) async {
//     await http.put(
//       Uri.parse('$baseUrl/$id'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': name,
//         'email': email,
//       }),
//     );
//   }

//   /// DELETE - Delete user
//   Future<void> deleteUser(int id) async {
//     await http.delete(Uri.parse('$baseUrl/$id'));
//   }
// }


enum HttpMethod { get, post, put, delete }

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<T> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required T Function(dynamic json) parser,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');

    final response = await _sendRequest(
      uri: uri,
      method: method,
      body: body,
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return parser(data);
    } else {
      throw Exception(
        'API Error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<http.Response> _sendRequest({
    required Uri uri,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    switch (method) {
      case HttpMethod.get:
        return http.get(uri, headers: requestHeaders);

      case HttpMethod.post:
        return http.post(uri, headers: requestHeaders, body: jsonEncode(body));

      case HttpMethod.put:
        return http.put(uri, headers: requestHeaders, body: jsonEncode(body));

      case HttpMethod.delete:
        return http.delete(uri, headers: requestHeaders);
    }
  }
}
