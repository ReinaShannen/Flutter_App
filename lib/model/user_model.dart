class UserModel {
  final int id; 
  final String name;
  final String email;
  final String? profileImageBase64; 
  final bool isRegistered; 

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageBase64,
    this.isRegistered = false,
  });

  // 🔹 From API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isRegistered: false,
    );
  }

  //  From Firestore registered users
  factory UserModel.fromFirestore(int docId, Map<String, dynamic> json) {
    return UserModel(
      id: docId,
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageBase64: json['profileImageBase64'],
      isRegistered: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
























// class UserModel {
//   final String id; // String because Firestore UID is string
//   final String name;
//   final String email;
//   final String? profileImageBase64; // only for registered users
//   final bool isRegistered; // true = firestore user, false = api user

//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.profileImageBase64,
//     required this.isRegistered,
//   });

//   // 🔹 From API (jsonplaceholder)
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'].toString(),
//       name: json['name'],
//       email: json['email'],
//       profileImageBase64: null,
//       isRegistered: false,
//     );
//   }

//   // 🔹 From Firestore (registered users)
//   factory UserModel.fromFirestore(String docId, Map<String, dynamic> json) {
//     return UserModel(
//       id: docId,
//       name: json['username'] ?? '',
//       email: json['email'] ?? '',
//       profileImageBase64: json['profileImageBase64'],
//       isRegistered: true,
//     );
//   }

//   // 🔹 To Firestore (only for API cache)
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//     };
//   }
// }











// class UserModel {
//   final int id;
//   final String name;
//   final String email;

//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//   });

//   // 🔹 From API (jsonplaceholder)
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//     );
//   }

//   // 🔹 To Firestore
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//     };
//   }
// }









// //W/O API CHANGES

// class UserModel {
//   int id;
//   String name;
//   String email;
//   String? profileImageBase64;

//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.profileImageBase64,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       profileImageBase64: json['profileImageBase64'], // may be null for API users
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//     };
//   }

// }