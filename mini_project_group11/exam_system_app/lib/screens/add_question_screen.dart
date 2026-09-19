import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  AddQuestionScreenState createState() => AddQuestionScreenState();
}

class AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final TextEditingController marksController = TextEditingController(text: '1');
  String correctAnswer = 'A';

  void handleSubmit() async {
    final Exam exam = ModalRoute.of(context)!.settings.arguments as Exam;

    final Question q = Question(
      id: '',
      examId: exam.id,
      questionText: questionTextController.text,
      optionA: optionAController.text,
      optionB: optionBController.text,
      optionC: optionCController.text,
      optionD: optionDController.text,
      correctAnswer: correctAnswer,
      marks: int.tryParse(marksController.text) ?? 1,
    );

    await QuestionService.addQuestion(q);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: questionTextController, decoration: const InputDecoration(labelText: 'Question Text', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: optionAController, decoration: const InputDecoration(labelText: 'Option A', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: optionBController, decoration: const InputDecoration(labelText: 'Option B', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: optionCController, decoration: const InputDecoration(labelText: 'Option C', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: optionDController, decoration: const InputDecoration(labelText: 'Option D', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: correctAnswer,
              decoration: const InputDecoration(labelText: 'Correct Answer', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('Option A')),
                DropdownMenuItem(value: 'B', child: Text('Option B')),
                DropdownMenuItem(value: 'C', child: Text('Option C')),
                DropdownMenuItem(value: 'D', child: Text('Option D')),
              ],
              onChanged: (v) => setState(() => correctAnswer = v ?? 'A'),
            ),
            const SizedBox(height: 12),
            TextField(controller: marksController, decoration: const InputDecoration(labelText: 'Marks', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(onPressed: handleSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text('Add Question', style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}
