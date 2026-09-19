import 'package:flutter/material.dart';

import '../models/submission.dart';
import '../models/user.dart';
import '../services/submission_service.dart';

class MyResultsScreen extends StatefulWidget {
  const MyResultsScreen({super.key});

  @override
  MyResultsScreenState createState() => MyResultsScreenState();
}

class MyResultsScreenState extends State<MyResultsScreen> {
  User? _user;
  List<Submission> _results = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is User) {
        _user = args;
        _loadResults();
      } else {
        setState(() {
          _errorMessage = 'User not found.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadResults() async {
    if (_user == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await SubmissionService.findByStudentId(_user!.id);
      setState(() {
        _results = results;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load results: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exam Results'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResults,
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
                      ElevatedButton(onPressed: _loadResults, child: const Text('Retry')),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_edu, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('You haven\'t taken any exams yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final res = _results[index];
                        final isPassed = res.percentage >= 40.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isPassed ? Colors.green.shade300 : Colors.red.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isPassed ? Colors.green.shade100 : Colors.red.shade100,
                              child: Icon(
                                isPassed ? Icons.check_circle : Icons.cancel,
                                color: isPassed ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              'Exam #${res.examId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Score: ${res.score} / ${res.totalMarks} (${res.percentage.toStringAsFixed(1)}%)'),
                                Text(
                                  'Status: ${isPassed ? "PASSED" : "FAILED"}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isPassed ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/exam_result', arguments: res);
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
