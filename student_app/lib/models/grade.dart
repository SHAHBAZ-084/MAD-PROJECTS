class Grade {
  final String id;
  final String studentId;
  final String courseId;
  final String courseCode;
  final String courseName;
  final double score;
  final String letterGrade;
  final String semester;
  final DateTime date;

  Grade({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.score,
    required this.letterGrade,
    required this.semester,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseName': courseName,
      'score': score,
      'letterGrade': letterGrade,
      'semester': semester,
      'date': date.toIso8601String(),
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      courseId: map['courseId'] as String,
      courseCode: map['courseCode'] as String,
      courseName: map['courseName'] as String,
      score: (map['score'] as num).toDouble(),
      letterGrade: map['letterGrade'] as String,
      semester: map['semester'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  static String calculateLetterGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
} 