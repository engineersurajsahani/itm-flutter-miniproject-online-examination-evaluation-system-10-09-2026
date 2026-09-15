import 'package:flutter/material.dart';

import '../models/exam.dart';

class ExamDetailScreen extends StatelessWidget {
  const ExamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Exam exam = ModalRoute.of(context)!.settings.arguments as Exam;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exam Header
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.assignment, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              exam.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              exam.subject,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Details Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: const Text("Description"),
                      subtitle: Text(exam.description),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.timer, color: Colors.orange),
                      title: const Text("Duration"),
                      subtitle: Text('${exam.duration} minutes'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule, color: Colors.green),
                      title: const Text("Scheduled At"),
                      subtitle: Text(exam.scheduledAt),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: exam.status == 'active'
                            ? Colors.green
                            : exam.status == 'draft'
                                ? Colors.orange
                                : Colors.grey,
                      ),
                      title: const Text("Status"),
                      subtitle: Text(exam.status.toUpperCase()),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.purple),
                      title: const Text("Created By"),
                      subtitle: Text(exam.createdBy),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
