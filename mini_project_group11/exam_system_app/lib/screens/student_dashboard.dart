import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../models/submission.dart';
import '../models/user.dart';
import '../services/exam_service.dart';
import '../services/submission_service.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  StudentDashboardState createState() => StudentDashboardState();
}

class StudentDashboardState extends State<StudentDashboard> {
  List<Exam> activeExams = [];
  List<Submission> myResults = [];
  late User user;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = ModalRoute.of(context)!.settings.arguments as User;
    loadData();
  }

  Future<void> loadData() async {
    final exams = await ExamService.findByStatus('active');
    final results = await SubmissionService.findByStudentId(user.id);
    if (!mounted) return;
    setState(() {
      activeExams = exams;
      myResults = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user.name}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available Exams
                  const Text(
                    'Available Exams',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  activeExams.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text('No active exams available')),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeExams.length,
                          itemBuilder: (context, index) {
                            final exam = activeExams[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.assignment, color: Colors.indigo),
                                title: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${exam.subject} • ${exam.duration} mins'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/take-exam',
                                      arguments: {'exam': exam, 'user': user},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Start'),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),

                  // My Results
                  const Text(
                    'My Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  myResults.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text('No exam results yet')),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myResults.length,
                          itemBuilder: (context, index) {
                            final result = myResults[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  result.percentage >= 40 ? Icons.check_circle : Icons.cancel,
                                  color: result.percentage >= 40 ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                title: Text('Exam: ${result.examId}'),
                                subtitle: Text('Score: ${result.score}/${result.totalMarks} (${result.percentage}%)'),
                                trailing: IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/exam-result',
                                      arguments: result,
                                    );
                                  },
                                  icon: const Icon(Icons.visibility),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
