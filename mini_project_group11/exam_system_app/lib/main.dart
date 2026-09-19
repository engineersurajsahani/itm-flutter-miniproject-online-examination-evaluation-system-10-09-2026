import 'package:flutter/material.dart';

import 'screens/add_exam_screen.dart';
import 'screens/add_question_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/analytics_screen.dart';
import 'screens/edit_exam_screen.dart';
import 'screens/edit_question_screen.dart';
import 'screens/exam_detail_screen.dart';
import 'screens/exam_list_screen.dart';
import 'screens/exam_result_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_results_screen.dart';
import 'screens/question_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/take_exam_screen.dart';

void main() {
  runApp(const OnlineExamApp());
}

class OnlineExamApp extends StatelessWidget {
  const OnlineExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Examination & Evaluation System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          primary: const Color(0xFF1E3C72),
          secondary: const Color(0xFF2A5298),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Dashboards
        '/student-dashboard': (context) => const StudentDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),

        // Exam Management
        '/exam-list': (context) => const ExamListScreen(),
        '/exam_list': (context) => const ExamListScreen(),
        '/add-exam': (context) => const AddExamScreen(),
        '/add_exam': (context) => const AddExamScreen(),
        '/edit-exam': (context) => const EditExamScreen(),
        '/edit_exam': (context) => const EditExamScreen(),
        '/exam-detail': (context) => const ExamDetailScreen(),
        '/exam_detail': (context) => const ExamDetailScreen(),

        // Question Management
        '/question-list': (context) => const QuestionListScreen(),
        '/question_list': (context) => const QuestionListScreen(),
        '/add-question': (context) => const AddQuestionScreen(),
        '/add_question': (context) => const AddQuestionScreen(),
        '/edit-question': (context) => const EditQuestionScreen(),
        '/edit_question': (context) => const EditQuestionScreen(),

        // Examination & Results
        '/take-exam': (context) => const TakeExamScreen(),
        '/take_exam': (context) => const TakeExamScreen(),
        '/exam-result': (context) => const ExamResultScreen(),
        '/exam_result': (context) => const ExamResultScreen(),
        '/my-results': (context) => const MyResultsScreen(),
        '/my_results': (context) => const MyResultsScreen(),
        '/result-analytics': (context) => const AnalyticsScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
      },
    );
  }
}
