import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class UserService {
  static const String apiUrl = 'http://localhost:4001/users';

  static final List<User> _users = [
    User(
      id: '1',
      name: 'Admin User',
      email: 'admin@exam.com',
      password: 'admin123',
      role: 'admin',
    ),
    User(
      id: '2',
      name: 'Faculty User',
      email: 'faculty@exam.com',
      password: 'faculty123',
      role: 'faculty',
    ),
    User(
      id: '3',
      name: 'Student User',
      email: 'student@exam.com',
      password: 'student123',
      role: 'student',
    ),
  ];

  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } on Exception {
      // Fallback to local data
      final user = _users.where((u) => u.email == email && u.password == password).toList();
      if (user.isNotEmpty) {
        return user.first;
      }
    }
    return null;
  }

  static Future<void> addUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to add user: ${response.body}');
      }
    } on Exception {
      user.id = _users.isEmpty ? '1' : (int.parse(_users.last.id) + 1).toString();
      _users.add(user);
    }
  }

  static Future<List<User>> find() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => User.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return List<User>.from(_users);
    }

    return List<User>.from(_users);
  }

  static Future<void> editUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update user: ${response.body}');
      }
    } on Exception {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      }
    }
  }

  static Future<void> findByIdAndDelete(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } on Exception {
      _users.removeWhere((user) => user.id == id);
    }
  }
}
