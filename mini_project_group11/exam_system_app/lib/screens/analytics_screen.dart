import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../models/result.dart';
import '../services/result_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  AnalyticsScreenState createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  ExamResult? _analytics;
  Exam? _exam;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exam == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Exam) {
        _exam = args;
        _fetchAnalytics(args.id);
      } else {
        setState(() {
          _errorMessage = 'No exam specified for analytics.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAnalytics(String examId) async {
    try {
      final data = await ResultService.getExamAnalytics(examId);
      setState(() {
        _analytics = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam != null ? '${_exam!.title} - Analytics' : 'Exam Analytics'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _exam != null
                ? () {
                    setState(() => _isLoading = true);
                    _fetchAnalytics(_exam!.id);
                  }
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                )
              : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    final analytics = _analytics;
    if (analytics == null || analytics.totalStudents == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No submissions recorded yet for this exam.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final totalStudents = analytics.totalStudents;
    final passCount = analytics.passCount;
    final failCount = analytics.failCount;
    final passRate = analytics.passPercentage;
    final averageScore = analytics.averageScore;
    final highestScore = analytics.highestScore;
    final lowestScore = analytics.lowestScore;
    final topScorers = analytics.topScorers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Total Attempts',
                  '$totalStudents',
                  Icons.people_outline,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  'Pass Rate',
                  '${passRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Average Score',
                  averageScore.toStringAsFixed(1),
                  Icons.calculate_outlined,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  'High / Low',
                  '$highestScore / $lowestScore',
                  Icons.compare_arrows,
                  Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pass vs Fail Breakdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: totalStudents > 0 ? (passCount / totalStudents) : 0,
                    minHeight: 12,
                    backgroundColor: Colors.red.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 12, height: 12, color: Colors.green.shade600),
                          const SizedBox(width: 6),
                          Text('Passed: $passCount'),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 12, height: 12, color: Colors.red.shade200),
                          const SizedBox(width: 6),
                          Text('Failed: $failCount'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Top Scorers list
          if (topScorers.isNotEmpty) ...[
            const Text(
              'Top Scorers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topScorers.length,
              itemBuilder: (context, index) {
                final student = topScorers[index];
                final studentName = student['studentName']?.toString() ?? 'Student';
                final score = student['score'] ?? 0;
                final total = student['totalMarks'] ?? 0;
                final pct = student['percentage'] ?? 0.0;

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.amber : Colors.blue.shade100,
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: index == 0 ? Colors.white : Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Score: $score / $total ($pct%)'),
                    trailing: const Icon(Icons.star, color: Colors.amber),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
