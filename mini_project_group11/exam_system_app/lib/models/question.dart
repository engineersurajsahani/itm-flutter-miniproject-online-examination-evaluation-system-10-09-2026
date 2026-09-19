class Question {
  String id;
  String examId;
  String questionText;
  String optionA;
  String optionB;
  String optionC;
  String optionD;
  String correctAnswer; // A, B, C, or D
  int marks;

  Question({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.marks,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id']?.toString() ?? '',
    examId: json['examId'] ?? '',
    questionText: json['questionText'] ?? '',
    optionA: json['optionA'] ?? '',
    optionB: json['optionB'] ?? '',
    optionC: json['optionC'] ?? '',
    optionD: json['optionD'] ?? '',
    correctAnswer: json['correctAnswer'] ?? '',
    marks: json['marks'] is int ? json['marks'] : int.tryParse(json['marks']?.toString() ?? '1') ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'examId': examId,
    'questionText': questionText,
    'optionA': optionA,
    'optionB': optionB,
    'optionC': optionC,
    'optionD': optionD,
    'correctAnswer': correctAnswer,
    'marks': marks,
  };
}
