import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({super.key});

  @override
  QuestionListScreenState createState() => QuestionListScreenState();
}

class QuestionListScreenState extends State<QuestionListScreen> {
  List<Question> questions = [];
  late Exam exam;

  Future<void> loadQuestions() async {
    final value = await QuestionService.findByExamId(exam.id);
    if (!mounted) return;
    setState(() {
      questions = value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    exam = ModalRoute.of(context)!.settings.arguments as Exam;
    loadQuestions();
  }

  Future<void> handleDelete(String id) async {
    await QuestionService.findByIdAndDelete(id);
    await loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Questions - ${exam.title}')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final Question q = questions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(q.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Correct: ${q.correctAnswer} • Marks: ${q.marks}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => handleDelete(q.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/edit-question', arguments: q);
                      await loadQuestions();
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-question', arguments: exam);
          await loadQuestions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
