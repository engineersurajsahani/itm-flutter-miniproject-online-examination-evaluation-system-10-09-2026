import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/question_service.dart';

class EditQuestionScreen extends StatefulWidget {
  const EditQuestionScreen({super.key});

  @override
  EditQuestionScreenState createState() => EditQuestionScreenState();
}

class EditQuestionScreenState extends State<EditQuestionScreen> {
  String id = '';
  String examId = '';
  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  String correctAnswer = 'A';
  bool _initialized = false;

  void handleSubmit() async {
    final Question q = Question(
      id: id, examId: examId,
      questionText: questionTextController.text,
      optionA: optionAController.text, optionB: optionBController.text,
      optionC: optionCController.text, optionD: optionDController.text,
      correctAnswer: correctAnswer, marks: int.tryParse(marksController.text) ?? 1,
    );
    await QuestionService.editQuestion(q);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final Question q = ModalRoute.of(context)!.settings.arguments as Question;
      id = q.id; examId = q.examId;
      questionTextController.text = q.questionText;
      optionAController.text = q.optionA; optionBController.text = q.optionB;
      optionCController.text = q.optionC; optionDController.text = q.optionD;
      correctAnswer = q.correctAnswer; marksController.text = q.marks.toString();
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Question')),
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
              child: ElevatedButton(onPressed: handleSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text('Update Question', style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}
