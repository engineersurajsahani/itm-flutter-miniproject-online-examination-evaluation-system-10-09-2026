import 'dart:async';
import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../models/question.dart';
import '../models/user.dart';
import '../services/question_service.dart';
import '../services/submission_service.dart';

class TakeExamScreen extends StatefulWidget {
  const TakeExamScreen({super.key});

  @override
  TakeExamScreenState createState() => TakeExamScreenState();
}

class TakeExamScreenState extends State<TakeExamScreen> {
  List<Question> questions = [];
  Map<String, String> selectedAnswers = {};
  late Exam exam;
  late User user;
  int remainingSeconds = 1800; // 30 minutes default
  Timer? timer;
  bool isLoading = true;
  bool isSubmitted = false;
  int currentQuestionIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isLoading) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      exam = args['exam'] as Exam;
      user = args['user'] as User;

      final durationMins = exam.duration > 0 ? exam.duration : 30;
      remainingSeconds = durationMins * 60;
      loadQuestions();
    }
  }

  Future<void> loadQuestions() async {
    try {
      final value = await QuestionService.findByExamId(exam.id);
      if (!mounted) return;
      setState(() {
        questions = value;
        isLoading = false;
      });
      if (questions.isNotEmpty) {
        startTimer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      }
      if (remainingSeconds <= 0) {
        t.cancel();
        handleSubmit();
      }
    });
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> handleSubmit() async {
    if (isSubmitted) return;
    isSubmitted = true;
    timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await SubmissionService.submitExam(
        examId: exam.id,
        studentId: user.id,
        studentName: user.name,
        answers: selectedAnswers,
      );

      if (!mounted) return;
      Navigator.pop(context); // dismiss loading dialog

      if (result != null) {
        Navigator.pushReplacementNamed(context, '/exam-result', arguments: result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission failed! Please try again.')),
        );
        setState(() {
          isSubmitted = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission error: $e')),
      );
      setState(() {
        isSubmitted = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(exam.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No questions found for this exam', style: TextStyle(fontSize: 16)),
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

    final Question currentQ = questions[currentQuestionIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exam.title),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Chip(
                avatar: Icon(
                  Icons.timer,
                  color: remainingSeconds <= 60 ? Colors.red : Colors.white,
                  size: 18,
                ),
                label: Text(
                  formatTime(remainingSeconds),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remainingSeconds <= 60 ? Colors.red : Colors.white,
                  ),
                ),
                backgroundColor: remainingSeconds <= 60 ? Colors.red.shade100 : Colors.indigo,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              LinearProgressIndicator(value: (currentQuestionIndex + 1) / questions.length),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${questions.length}',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Answered: ${selectedAnswers.length}/${questions.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQ.questionText,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '(${currentQ.marks} marks)',
                        style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...['A', 'B', 'C', 'D'].map((option) {
                String optionText = '';
                switch (option) {
                  case 'A': optionText = currentQ.optionA; break;
                  case 'B': optionText = currentQ.optionB; break;
                  case 'C': optionText = currentQ.optionC; break;
                  case 'D': optionText = currentQ.optionD; break;
                }
                final isSelected = selectedAnswers[currentQ.id] == option;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => selectedAnswers[currentQ.id] = option),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.indigo : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.indigo.withAlpha(25) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: isSelected ? Colors.indigo : Colors.grey.shade200,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Bottom Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: currentQuestionIndex > 0
                        ? () => setState(() => currentQuestionIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  currentQuestionIndex < questions.length - 1
                      ? ElevatedButton.icon(
                          onPressed: () => setState(() => currentQuestionIndex++),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: handleSubmit,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Submit Exam'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
