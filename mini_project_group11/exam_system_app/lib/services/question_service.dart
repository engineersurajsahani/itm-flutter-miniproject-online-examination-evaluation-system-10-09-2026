import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question.dart';

class QuestionService {
  static const String apiUrl = 'http://localhost:4001/questions';

  static final List<Question> _questions = [
    Question(
      id: '1',
      examId: '1',
      questionText: 'What is the time complexity of binary search?',
      optionA: 'O(n)',
      optionB: 'O(log n)',
      optionC: 'O(n log n)',
      optionD: 'O(1)',
      correctAnswer: 'B',
      marks: 2,
    ),
    Question(
      id: '2',
      examId: '1',
      questionText: 'Which data structure uses LIFO principle?',
      optionA: 'Queue',
      optionB: 'Array',
      optionC: 'Stack',
      optionD: 'Linked List',
      correctAnswer: 'C',
      marks: 2,
    ),
    Question(
      id: '3',
      examId: '1',
      questionText: 'What is the worst case time complexity of QuickSort?',
      optionA: 'O(n log n)',
      optionB: 'O(n)',
      optionC: 'O(n^2)',
      optionD: 'O(log n)',
      correctAnswer: 'C',
      marks: 2,
    ),
  ];

  static Future<void> addQuestion(Question question) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(question.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to add question: ${response.body}');
      }
    } on Exception {
      question.id = _questions.isEmpty ? '1' : (int.parse(_questions.last.id) + 1).toString();
      _questions.add(question);
    }
  }

  static Future<void> editQuestion(Question question) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${question.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(question.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update question: ${response.body}');
      }
    } on Exception {
      final index = _questions.indexWhere((q) => q.id == question.id);
      if (index != -1) {
        _questions[index] = question;
      }
    }
  }

  static Future<void> findByIdAndDelete(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete question: ${response.body}');
      }
    } on Exception {
      _questions.removeWhere((question) => question.id == id);
    }
  }

  static Future<List<Question>> findByExamId(String examId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/exam/$examId'));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Question.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return _questions.where((q) => q.examId == examId).toList();
    }

    return _questions.where((q) => q.examId == examId).toList();
  }

  static Future<List<Question>> find() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Question.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return List<Question>.from(_questions);
    }

    return List<Question>.from(_questions);
  }
}
