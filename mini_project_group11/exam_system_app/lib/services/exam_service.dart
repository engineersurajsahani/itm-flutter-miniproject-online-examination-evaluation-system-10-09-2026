import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exam.dart';

class ExamService {
  static const String apiUrl = 'http://localhost:4001/exams';

  static final List<Exam> _exams = [
    Exam(
      id: '1',
      title: 'Data Structures Midterm',
      subject: 'Data Structures',
      description: 'Midterm exam covering arrays, linked lists, stacks and queues',
      duration: 60,
      scheduledAt: '2026-09-20T10:00:00',
      status: 'active',
      createdBy: '2',
    ),
    Exam(
      id: '2',
      title: 'Database Management Final',
      subject: 'DBMS',
      description: 'Final exam on SQL, normalization, and transactions',
      duration: 90,
      scheduledAt: '2026-09-25T14:00:00',
      status: 'draft',
      createdBy: '2',
    ),
  ];

  static Future<void> addExam(Exam exam) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(exam.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to add exam: ${response.body}');
      }
    } on Exception {
      exam.id = _exams.isEmpty ? '1' : (int.parse(_exams.last.id) + 1).toString();
      _exams.add(exam);
    }
  }

  static Future<void> editExam(Exam exam) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${exam.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(exam.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update exam: ${response.body}');
      }
    } on Exception {
      final index = _exams.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        _exams[index] = exam;
      }
    }
  }

  static Future<void> findByIdAndDelete(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete exam: ${response.body}');
      }
    } on Exception {
      _exams.removeWhere((exam) => exam.id == id);
    }
  }

  static Future<List<Exam>> find() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Exam.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return List<Exam>.from(_exams);
    }

    return List<Exam>.from(_exams);
  }

  static Future<List<Exam>> findByStatus(String status) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/status/$status'));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Exam.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return _exams.where((exam) => exam.status == status).toList();
    }

    return _exams.where((exam) => exam.status == status).toList();
  }

  static Future<Exam> getExamById(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200) {
        return Exam.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } on Exception {
      return _exams.firstWhere((exam) => exam.id == id);
    }

    return _exams.firstWhere((exam) => exam.id == id);
  }
}
