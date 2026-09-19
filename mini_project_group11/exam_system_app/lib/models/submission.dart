class Submission {
  String id;
  String examId;
  String studentId;
  String studentName;
  Map<String, dynamic> answers; // questionId -> answer details
  int score;
  int totalMarks;
  double percentage;
  String submittedAt;

  Submission({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) => Submission(
    id: json['id']?.toString() ?? '',
    examId: json['examId'] ?? '',
    studentId: json['studentId'] ?? '',
    studentName: json['studentName'] ?? '',
    answers: json['answers'] is Map ? Map<String, dynamic>.from(json['answers']) : {},
    score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
    totalMarks: json['totalMarks'] is int ? json['totalMarks'] : int.tryParse(json['totalMarks']?.toString() ?? '0') ?? 0,
    percentage: json['percentage'] is double
        ? json['percentage']
        : double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
    submittedAt: json['submittedAt'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'examId': examId,
    'studentId': studentId,
    'studentName': studentName,
    'answers': answers,
    'score': score,
    'totalMarks': totalMarks,
    'percentage': percentage,
    'submittedAt': submittedAt,
  };
}
