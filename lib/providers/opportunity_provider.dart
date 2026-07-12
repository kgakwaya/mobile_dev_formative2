import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class OpportunityProvider extends ChangeNotifier {
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

  // Post a new opportunity
  Future<bool> postOpportunity({
    required String startupId,
    required String startupName,
    required bool startupVerified,
    required String title,
    required String description,
    required String roleType,
    required List<String> skillsRequired,
    required String locationType,
    required String duration,
    required String hoursPerWeek,
  }) async {
    _setLoading(true);
    try {
      final docRef = _db.collection('opportunities').doc();
      final opp = OpportunityModel(
        id: docRef.id,
        startupId: startupId,
        startupName: startupName,
        startupVerified: startupVerified,
        title: title,
        description: description,
        roleType: roleType,
        skillsRequired: skillsRequired,
        locationType: locationType,
        duration: duration,
        hoursPerWeek: hoursPerWeek,
        isClosed: false,
        createdAt: DateTime.now(),
      );

      await docRef.set(opp.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get stream of all active (open) opportunities
  Stream<List<OpportunityModel>> get openOpportunitiesStream {
    return _db.collection('opportunities')
        .where('isClosed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => OpportunityModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Get stream of opportunities for a specific startup
  Stream<List<OpportunityModel>> startupOpportunitiesStream(String startupId) {
    return _db.collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => OpportunityModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Close opportunity
  Future<bool> toggleOpportunityStatus(String opportunityId, bool isClosed) async {
    _setLoading(true);
    try {
      await _db.collection('opportunities').doc(opportunityId).update({
        'isClosed': isClosed,
      });
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete opportunity
  Future<bool> deleteOpportunity(String opportunityId) async {
    _setLoading(true);
    try {
      await _db.collection('opportunities').doc(opportunityId).delete();
      
      // Cascade delete: Remove applications associated with this opportunity
      final batch = _db.batch();
      final appsQuery = await _db.collection('applications')
          .where('opportunityId', isEqualTo: opportunityId)
          .get();

      for (var doc in appsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Cascade delete: Remove bookmarks
      final bookmarksQuery = await _db.collection('bookmarks')
          .where('opportunityId', isEqualTo: opportunityId)
          .get();
          
      for (var doc in bookmarksQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Bookmark toggling
  Future<void> toggleBookmark(String userId, String opportunityId) async {
    final bookmarkDocId = '${userId}_$opportunityId';
    final docRef = _db.collection('bookmarks').doc(bookmarkDocId);
    
    try {
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'userId': userId,
          'opportunityId': opportunityId,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Stream bookmarks for a specific user
  Stream<List<String>> userBookmarkIdsStream(String userId) {
    return _db.collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()['opportunityId'] as String).toList();
        });
  }
}
