import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

class StartupProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<StartupModel> _startups = [];
  List<StartupModel> _unverifiedStartups = [];
  bool _isLoading = false;
  String _error = '';

  List<StartupModel> get startups => _startups;
  List<StartupModel> get unverifiedStartups => _unverifiedStartups;
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

  // Subscribe to all startups (real-time stream)
  Stream<List<StartupModel>> startupsStream() {
    return _db.collection('startups')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => StartupModel.fromMap(doc.data(), doc.id)).toList();
        });
  }

  // Stream unverified startups specifically for admin panel
  Stream<List<StartupModel>> unverifiedStartupsStream() {
    return _db.collection('startups')
        .where('isVerified', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => StartupModel.fromMap(doc.data(), doc.id)).toList();
        });
  }

  // Verify startup function (cascade changes to posted opportunities as well)
  Future<bool> verifyStartup(String startupId) async {
    _setLoading(true);
    try {
      // 1. Update startup document verification flag
      await _db.collection('startups').doc(startupId).update({
        'isVerified': true,
      });

      // 2. Cascade verification to all opportunities posted by this startup
      final batch = _db.batch();
      final oppsQuery = await _db.collection('opportunities')
          .where('startupId', isEqualTo: startupId)
          .get();

      for (var doc in oppsQuery.docs) {
        batch.update(doc.reference, {
          'startupVerified': true,
        });
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

  // Admin: Remove or reject startup
  Future<bool> deleteStartup(String startupId) async {
    _setLoading(true);
    try {
      await _db.collection('startups').doc(startupId).delete();
      
      // Cascade delete to opportunities
      final batch = _db.batch();
      final oppsQuery = await _db.collection('opportunities')
          .where('startupId', isEqualTo: startupId)
          .get();

      for (var doc in oppsQuery.docs) {
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
}
