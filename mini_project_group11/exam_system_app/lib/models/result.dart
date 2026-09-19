class ExamResult {
  String examId;
  int totalStudents;
  double averageScore;
  double averagePercentage;
  int highestScore;
  int lowestScore;
  int passCount;
  int failCount;
  double passPercentage;
  List<Map<String, dynamic>> topScorers;
  Map<String, int> scoreDistribution;

  ExamResult({
    required this.examId,
    required this.totalStudents,
    required this.averageScore,
    required this.averagePercentage,
    required this.highestScore,
    required this.lowestScore,
    required this.passCount,
    required this.failCount,
    required this.passPercentage,
    required this.topScorers,
    required this.scoreDistribution,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
    examId: json['examId'] ?? '',
    totalStudents: json['totalStudents'] is int ? json['totalStudents'] : int.tryParse(json['totalStudents']?.toString() ?? '0') ?? 0,
    averageScore: (json['averageScore'] is num ? json['averageScore'].toDouble() : double.tryParse(json['averageScore']?.toString() ?? '0') ?? 0.0),
    averagePercentage: (json['averagePercentage'] is num ? json['averagePercentage'].toDouble() : double.tryParse(json['averagePercentage']?.toString() ?? '0') ?? 0.0),
    highestScore: json['highestScore'] is int ? json['highestScore'] : int.tryParse(json['highestScore']?.toString() ?? '0') ?? 0,
    lowestScore: json['lowestScore'] is int ? json['lowestScore'] : int.tryParse(json['lowestScore']?.toString() ?? '0') ?? 0,
    passCount: json['passCount'] is int ? json['passCount'] : int.tryParse(json['passCount']?.toString() ?? '0') ?? 0,
    failCount: json['failCount'] is int ? json['failCount'] : int.tryParse(json['failCount']?.toString() ?? '0') ?? 0,
    passPercentage: (json['passPercentage'] is num ? json['passPercentage'].toDouble() : double.tryParse(json['passPercentage']?.toString() ?? '0') ?? 0.0),
    topScorers: json['topScorers'] is List
        ? List<Map<String, dynamic>>.from(json['topScorers'].map((e) => Map<String, dynamic>.from(e)))
        : [],
    scoreDistribution: json['scoreDistribution'] is Map
        ? Map<String, int>.from(json['scoreDistribution'].map((k, v) => MapEntry(k.toString(), v is int ? v : int.tryParse(v.toString()) ?? 0)))
        : {},
  );
}
