import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/submission.dart';

class SubmissionService {
  static const String apiUrl = 'http://localhost:4001/submissions';

  static final List<Submission> _submissions = [];

  // Submit exam answers — server auto-evaluates and returns score
  static Future<Submission?> submitExam({
    required String examId,
    required String studentId,
    required String studentName,
    required Map<String, String> answers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'examId': examId,
          'studentId': studentId,
          'studentName': studentName,
          'answers': answers,
        }),
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return Submission.fromJson(body['submission'] as Map<String, dynamic>);
      }
    } on Exception {
      // Local fallback — create a dummy submission
      final submission = Submission(
        id: (_submissions.length + 1).toString(),
        examId: examId,
        studentId: studentId,
        studentName: studentName,
        answers: answers.map((k, v) => MapEntry(k, {'selectedAnswer': v})),
        score: 0,
        totalMarks: 0,
        percentage: 0.0,
        submittedAt: DateTime.now().toIso8601String(),
      );
      _submissions.add(submission);
      return submission;
    }
    return null;
  }

  static Future<List<Submission>> findByExamId(String examId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/exam/$examId'));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Submission.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return _submissions.where((s) => s.examId == examId).toList();
    }

    return _submissions.where((s) => s.examId == examId).toList();
  }

  static Future<List<Submission>> findByStudentId(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/student/$studentId'));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Submission.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return _submissions.where((s) => s.studentId == studentId).toList();
    }

    return _submissions.where((s) => s.studentId == studentId).toList();
  }

  static Future<Submission?> findById(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200) {
        return Submission.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } on Exception {
      final matches = _submissions.where((s) => s.id == id).toList();
      return matches.isNotEmpty ? matches.first : null;
    }
    return null;
  }
}
