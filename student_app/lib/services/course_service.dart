import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'courses';
  final String _enrollmentsCollection = 'enrollments';

  // Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Error getting courses: $e';
    }
  }

  // Get enrolled courses for a student
  Future<List<Course>> getEnrolledCourses(String studentId) async {
    try {
      final enrollmentSnapshot = await _firestore
          .collection(_enrollmentsCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      final courseIds = enrollmentSnapshot.docs.map((doc) => doc['courseId'] as String).toList();

      if (courseIds.isEmpty) return [];

      final coursesSnapshot = await _firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();

      return coursesSnapshot.docs.map((doc) => Course.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Error getting enrolled courses: $e';
    }
  }

  // Enroll in a course
  Future<void> enrollInCourse(String studentId, String courseId) async {
    try {
      await _firestore.collection(_enrollmentsCollection).add({
        'studentId': studentId,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error enrolling in course: $e';
    }
  }

  // Drop a course
  Future<void> dropCourse(String studentId, String courseId) async {
    try {
      final enrollmentSnapshot = await _firestore
          .collection(_enrollmentsCollection)
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .get();

      for (var doc in enrollmentSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'Error dropping course: $e';
    }
  }

  // Stream of enrolled courses
  Stream<List<Course>> enrolledCoursesStream(String studentId) {
    return _firestore
        .collection(_enrollmentsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .asyncMap((enrollmentSnapshot) async {
      final courseIds = enrollmentSnapshot.docs.map((doc) => doc['courseId'] as String).toList();
      if (courseIds.isEmpty) return [];

      final coursesSnapshot = await _firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();

      return coursesSnapshot.docs.map((doc) => Course.fromMap(doc.data())).toList();
    });
  }
} 