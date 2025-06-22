/// A model class representing a student's profile information.
class StudentProfile {
  /// The unique identifier for the student (matches Firebase Auth UID)
  final String id;

  /// The student's email address
  final String email;

  /// The student's full name
  final String fullName;

  /// The student's unique student ID number
  final String studentId;

  /// The student's major/field of study
  final String major;

  /// The student's current year level (1-5)
  final int yearLevel;

  /// Optional URL to the student's profile picture
  final String? profilePictureUrl;

  /// Creates a new [StudentProfile] instance.
  ///
  /// All fields except [profilePictureUrl] are required.
  StudentProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.major,
    required this.yearLevel,
    this.profilePictureUrl,
  }) {
    _validateFields();
  }

  void _validateFields() {
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError('Invalid email address');
    }
    if (fullName.trim().isEmpty) {
      throw ArgumentError('Full name cannot be empty');
    }
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    if (major.trim().isEmpty) {
      throw ArgumentError('Major cannot be empty');
    }
    if (yearLevel < 1 || yearLevel > 5) {
      throw ArgumentError('Year level must be between 1 and 5');
    }
  }

  /// Converts the profile to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'studentId': studentId,
      'major': major,
      'yearLevel': yearLevel,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  /// Creates a [StudentProfile] from a Firestore document
  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    try {
      return StudentProfile(
        id: map['id'] as String,
        email: map['email'] as String,
        fullName: map['fullName'] as String,
        studentId: map['studentId'] as String,
        major: map['major'] as String,
        yearLevel: map['yearLevel'] as int,
        profilePictureUrl: map['profilePictureUrl'] as String?,
      );
    } catch (e) {
      throw FormatException('Invalid profile data: $e');
    }
  }

  /// Creates a copy of this profile with the given fields replaced with new values
  StudentProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? studentId,
    String? major,
    int? yearLevel,
    String? profilePictureUrl,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      yearLevel: yearLevel ?? this.yearLevel,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  /// Returns a map of changed fields between this profile and another
  Map<String, dynamic> getChanges(StudentProfile other) {
    final changes = <String, dynamic>{};
    if (email != other.email) changes['email'] = email;
    if (fullName != other.fullName) changes['fullName'] = fullName;
    if (studentId != other.studentId) changes['studentId'] = studentId;
    if (major != other.major) changes['major'] = major;
    if (yearLevel != other.yearLevel) changes['yearLevel'] = yearLevel;
    if (profilePictureUrl != other.profilePictureUrl) {
      changes['profilePictureUrl'] = profilePictureUrl;
    }
    return changes;
  }

  /// Returns whether this profile has all required fields filled
  bool get isComplete {
    return id.isNotEmpty &&
        email.isNotEmpty &&
        fullName.trim().isNotEmpty &&
        studentId.trim().isNotEmpty &&
        major.trim().isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentProfile &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.studentId == studentId &&
        other.major == major &&
        other.yearLevel == yearLevel &&
        other.profilePictureUrl == profilePictureUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      studentId,
      major,
      yearLevel,
      profilePictureUrl,
    );
  }

  @override
  String toString() {
    return 'StudentProfile(id: $id, email: $email, fullName: $fullName, studentId: $studentId, major: $major, yearLevel: $yearLevel)';
  }
} 