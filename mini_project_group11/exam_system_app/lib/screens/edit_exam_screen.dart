import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../services/exam_service.dart';

class EditExamScreen extends StatefulWidget {
  const EditExamScreen({super.key});

  @override
  EditExamScreenState createState() => EditExamScreenState();
}

class EditExamScreenState extends State<EditExamScreen> {
  String id = '';
  String createdBy = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController scheduledAtController = TextEditingController();
  String selectedStatus = 'draft';
  bool _initialized = false;

  void handleSubmit() async {
    final Exam exam = Exam(
      id: id,
      title: titleController.text,
      subject: subjectController.text,
      description: descriptionController.text,
      duration: int.tryParse(durationController.text) ?? 60,
      scheduledAt: scheduledAtController.text,
      status: selectedStatus,
      createdBy: createdBy,
    );

    await ExamService.editExam(exam);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final Exam exam = ModalRoute.of(context)!.settings.arguments as Exam;
      titleController.text = exam.title;
      subjectController.text = exam.subject;
      descriptionController.text = exam.description;
      durationController.text = exam.duration.toString();
      scheduledAtController.text = exam.scheduledAt;
      selectedStatus = exam.status;
      id = exam.id;
      createdBy = exam.createdBy;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exam')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Exam Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: scheduledAtController,
              decoration: const InputDecoration(
                labelText: 'Scheduled At (YYYY-MM-DD HH:MM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value ?? 'draft';
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Exam', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
