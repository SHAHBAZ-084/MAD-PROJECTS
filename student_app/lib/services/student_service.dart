import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_profile.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'students';
  final Map<String, StudentProfile> _cache = {};

  /// Get student profile with caching
  Future<StudentProfile?> getStudentProfile(String userId) async {
    // Check cache first
    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }

    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        throw 'Profile data is null';
      }

      final profile = StudentProfile.fromMap(data);
      _cache[userId] = profile; // Cache the profile
      return profile;
    } on FirebaseException catch (e) {
      throw 'Failed to get profile: ${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  /// Create or update student profile
  Future<void> saveStudentProfile(StudentProfile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .set(profile.toMap(), SetOptions(merge: true));
      
      // Update cache
      _cache[profile.id] = profile;
    } on FirebaseException catch (e) {
      throw 'Failed to save profile: ${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  /// Delete student profile
  Future<void> deleteStudentProfile(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
      // Remove from cache
      _cache.remove(userId);
    } on FirebaseException catch (e) {
      throw 'Failed to delete profile: ${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  /// Stream of student profile changes with caching
  Stream<StudentProfile?> studentProfileStream(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            _cache.remove(userId);
            return null;
          }
          
          final data = doc.data();
          if (data == null) {
            _cache.remove(userId);
            return null;
          }
          
          final profile = StudentProfile.fromMap(data);
          _cache[userId] = profile;
          return profile;
        });
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }

  /// Get cached profile if available
  StudentProfile? getCachedProfile(String userId) {
    return _cache[userId];
  }
} 