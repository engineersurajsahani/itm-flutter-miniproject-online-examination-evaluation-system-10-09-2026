import 'package:flutter/material.dart';

import '../models/submission.dart';
import '../services/submission_service.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({super.key});

  @override
  ExamResultScreenState createState() => ExamResultScreenState();
}

class ExamResultScreenState extends State<ExamResultScreen> {
  Submission? _submission;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_submission == null && _isLoading && _errorMessage == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Submission) {
        setState(() {
          _submission = args;
          _isLoading = false;
        });
      } else if (args is Map<String, dynamic> && args['submissionId'] != null) {
        _fetchSubmission(args['submissionId'].toString());
      } else {
        setState(() {
          _errorMessage = 'No result data provided.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSubmission(String submissionId) async {
    try {
      final sub = await SubmissionService.findById(submissionId);
      setState(() {
        _submission = sub;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load result: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _submission == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'Result not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final sub = _submission!;
    final isPassed = sub.percentage >= 40.0;
    final percentage = sub.percentage.toStringAsFixed(1);
    final answersList = sub.answers.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        backgroundColor: isPassed ? Colors.green.shade700 : Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isPassed
                        ? [Colors.green.shade50, Colors.white]
                        : [Colors.red.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 64,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isPassed ? 'Congratulations! Passed' : 'Needs Improvement - Failed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: ${sub.score} / ${sub.totalMarks} ($percentage%)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Performance Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Score', '${sub.score}', Icons.grade, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard('Total Marks', '${sub.totalMarks}', Icons.quiz, Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Percentage', '$percentage%', Icons.percent, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard('Status', isPassed ? 'PASSED' : 'FAILED', isPassed ? Icons.check : Icons.close, isPassed ? Colors.green : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Answers Breakdown
            if (answersList.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Submitted Answers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: answersList.length,
                itemBuilder: (context, index) {
                  final entry = answersList[index];
                  final ansData = entry.value;
                  String selected = '';
                  bool? isCorrect;
                  String? correctAns;

                  if (ansData is Map) {
                    selected = ansData['selectedAnswer']?.toString() ?? 'None';
                    isCorrect = ansData['isCorrect'] as bool?;
                    correctAns = ansData['correctAnswer']?.toString();
                  } else {
                    selected = ansData.toString();
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isCorrect == true
                            ? Colors.green.shade300
                            : (isCorrect == false ? Colors.red.shade300 : Colors.grey.shade300),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isCorrect == true
                                    ? Colors.green
                                    : (isCorrect == false ? Colors.red : Colors.blueGrey),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Question ${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 38),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selected: $selected', style: const TextStyle(fontWeight: FontWeight.w500)),
                                if (correctAns != null && isCorrect == false)
                                  Text('Correct: $correctAns', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
