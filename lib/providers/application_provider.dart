import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String val) {
    _error = val;
    notifyListeners();
  }

  // Check if student has already applied to this opportunity
  Future<bool> hasApplied(String studentId, String opportunityId) async {
    try {
      final query = await _db.collection('applications')
          .where('studentId', isEqualTo: studentId)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Apply to opportunity
  Future<bool> applyToOpportunity({
    required String opportunityId,
    required String opportunityTitle,
    required String startupId,
    required String startupName,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required List<String> studentSkills,
    required String pitch,
  }) async {
    _setLoading(true);
    try {
      // Avoid duplicates
      final alreadyApplied = await hasApplied(studentId, opportunityId);
      if (alreadyApplied) {
        _setError('You have already applied to this opportunity.');
        _setLoading(false);
        return false;
      }

      final docRef = _db.collection('applications').doc();
      final app = ApplicationModel(
        id: docRef.id,
        opportunityId: opportunityId,
        opportunityTitle: opportunityTitle,
        startupId: startupId,
        startupName: startupName,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        studentSkills: studentSkills,
        pitch: pitch,
        status: 'Pending',
        feedback: '',
        createdAt: DateTime.now(),
      );

      await docRef.set(app.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get stream of applications for a student
  Stream<List<ApplicationModel>> studentApplicationsStream(String studentId) {
    return _db.collection('applications')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Get stream of applications for a startup founder
  Stream<List<ApplicationModel>> startupApplicationsStream(String startupId) {
    return _db.collection('applications')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Update application status
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status, // 'Pending' | 'Shortlisted' | 'Interviewing' | 'Accepted' | 'Rejected'
    required String feedback,
  }) async {
    _setLoading(true);
    try {
      await _db.collection('applications').doc(applicationId).update({
        'status': status,
        'feedback': feedback,
      });
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
