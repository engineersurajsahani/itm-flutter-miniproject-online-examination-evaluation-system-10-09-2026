class Exam {
  String id;
  String title;
  String subject;
  String description;
  int duration; // in minutes
  String scheduledAt; // ISO date string
  String status; // draft, active, completed
  String createdBy; // user id

  Exam({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.duration,
    required this.scheduledAt,
    required this.status,
    required this.createdBy,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    int parsedDuration = 30; // fallback default 30 mins
    if (json['duration'] != null) {
      parsedDuration = json['duration'] is int ? json['duration'] : int.tryParse(json['duration'].toString()) ?? 30;
    } else if (json['durationMinutes'] != null) {
      parsedDuration = json['durationMinutes'] is int ? json['durationMinutes'] : int.tryParse(json['durationMinutes'].toString()) ?? 30;
    }

    if (parsedDuration <= 0) parsedDuration = 30;

    return Exam(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? (json['title']?.toString() ?? 'General'),
      description: json['description']?.toString() ?? '',
      duration: parsedDuration,
      scheduledAt: json['scheduledAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'draft',
      createdBy: json['createdBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'description': description,
    'duration': duration,
    'durationMinutes': duration,
    'scheduledAt': scheduledAt,
    'status': status,
    'createdBy': createdBy,
  };
}
