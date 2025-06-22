class Course {
  final String id;
  final String code;
  final String name;
  final String instructor;
  final String schedule;
  final String room;
  final int credits;
  final String semester;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.instructor,
    required this.schedule,
    required this.room,
    required this.credits,
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'instructor': instructor,
      'schedule': schedule,
      'room': room,
      'credits': credits,
      'semester': semester,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      instructor: map['instructor'] as String,
      schedule: map['schedule'] as String,
      room: map['room'] as String,
      credits: map['credits'] as int,
      semester: map['semester'] as String,
    );
  }
} 