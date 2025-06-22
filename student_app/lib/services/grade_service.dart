import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grade.dart';

class GradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'grades';

  // Get all grades for a student
  Future<List<Grade>> getStudentGrades(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => Grade.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Error getting grades: $e';
    }
  }

  // Get grades for a specific course
  Future<List<Grade>> getCourseGrades(String studentId, String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => Grade.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Error getting course grades: $e';
    }
  }

  // Add a new grade
  Future<void> addGrade(Grade grade) async {
    try {
      await _firestore.collection(_collection).add(grade.toMap());
    } catch (e) {
      throw 'Error adding grade: $e';
    }
  }

  // Update a grade
  Future<void> updateGrade(String gradeId, Grade grade) async {
    try {
      await _firestore.collection(_collection).doc(gradeId).update(grade.toMap());
    } catch (e) {
      throw 'Error updating grade: $e';
    }
  }

  // Delete a grade
  Future<void> deleteGrade(String gradeId) async {
    try {
      await _firestore.collection(_collection).doc(gradeId).delete();
    } catch (e) {
      throw 'Error deleting grade: $e';
    }
  }

  // Get GPA for a student
  Future<double> getGPA(String studentId) async {
    try {
      final grades = await getStudentGrades(studentId);
      if (grades.isEmpty) return 0.0;

      double totalPoints = 0;
      int totalCredits = 0;

      for (var grade in grades) {
        double points = _getGradePoints(grade.letterGrade);
        totalPoints += points;
        totalCredits++;
      }

      return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    } catch (e) {
      throw 'Error calculating GPA: $e';
    }
  }

  // Helper method to convert letter grade to points
  double _getGradePoints(String letterGrade) {
    switch (letterGrade.toUpperCase()) {
      case 'A':
        return 4.0;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      default:
        return 0.0;
    }
  }

  // Stream of grades for a student
  Stream<List<Grade>> studentGradesStream(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Grade.fromMap(doc.data())).toList());
  }
} 