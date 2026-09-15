import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/result.dart';
import '../models/submission.dart';

class ResultService {
  static const String apiUrl = 'http://localhost:4001/results';

  static Future<ExamResult> getExamAnalytics(String examId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/exam/$examId'));

      if (response.statusCode == 200) {
        return ExamResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } on Exception {
      // Return empty analytics
      return ExamResult(
        examId: examId,
        totalStudents: 0,
        averageScore: 0,
        averagePercentage: 0,
        highestScore: 0,
        lowestScore: 0,
        passCount: 0,
        failCount: 0,
        passPercentage: 0,
        topScorers: [],
        scoreDistribution: {},
      );
    }

    return ExamResult(
      examId: examId,
      totalStudents: 0,
      averageScore: 0,
      averagePercentage: 0,
      highestScore: 0,
      lowestScore: 0,
      passCount: 0,
      failCount: 0,
      passPercentage: 0,
      topScorers: [],
      scoreDistribution: {},
    );
  }

  static Future<List<Submission>> getStudentResults(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/student/$studentId'));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => Submission.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on Exception {
      return [];
    }

    return [];
  }
}
