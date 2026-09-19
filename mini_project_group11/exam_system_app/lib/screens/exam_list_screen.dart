import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../models/user.dart';
import '../services/exam_service.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  ExamListScreenState createState() => ExamListScreenState();
}

class ExamListScreenState extends State<ExamListScreen> {
  List<Exam> exams = [];
  late User user;

  Future<void> loadExamData() async {
    final value = await ExamService.find();
    if (!mounted) return;
    setState(() {
      exams = value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = ModalRoute.of(context)!.settings.arguments as User;
    loadExamData();
  }

  Future<void> handleDelete(String id) async {
    await ExamService.findByIdAndDelete(id);
    await loadExamData();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam List')),
      body: ListView.builder(
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final Exam exam = exams[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(exam.status),
                child: const Icon(Icons.assignment, color: Colors.white),
              ),
              title: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${exam.subject} • ${exam.duration} mins • ${exam.status.toUpperCase()}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => handleDelete(exam.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/exam-detail',
                        arguments: exam,
                      );
                    },
                    icon: const Icon(Icons.visibility),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        '/edit-exam',
                        arguments: exam,
                      );
                      await loadExamData();
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/question-list',
                        arguments: exam,
                      );
                    },
                    icon: const Icon(Icons.quiz, color: Colors.orange),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/result-analytics',
                        arguments: exam,
                      );
                    },
                    icon: const Icon(Icons.analytics, color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-exam', arguments: user);
          await loadExamData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
