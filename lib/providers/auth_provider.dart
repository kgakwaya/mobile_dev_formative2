import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/startup_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  StartupModel? _currentStartup;
  bool _isLoading = false;
  String _error = '';

  UserModel? get currentUser => _currentUser;
  StartupModel? get currentStartup => _currentStartup;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await fetchUserData(user.uid);
      } else {
        _currentUser = null;
        _currentStartup = null;
        notifyListeners();
      }
    });
    // Seed default admin account in the background on startup
    Future.delayed(const Duration(seconds: 1), () {
      seedAdminAccount();
    });
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String val) {
    _error = val;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!);
        
        // If founder, fetch their startup
        if (_currentUser!.role == 'founder' && _currentUser!.startupId != null) {
          final startupDoc = await _db.collection('startups').doc(_currentUser!.startupId).get();
          if (startupDoc.exists && startupDoc.data() != null) {
            _currentStartup = StartupModel.fromMap(startupDoc.data()!, startupDoc.id);
          }
        } else if (_currentUser!.role == 'founder') {
          // Check if a startup document already exists for this founder (in case of half-completed onboarding)
          final startupsQuery = await _db.collection('startups')
              .where('founderId', isEqualTo: uid)
              .limit(1)
              .get();
          if (startupsQuery.docs.isNotEmpty) {
            final docData = startupsQuery.docs.first;
            _currentStartup = StartupModel.fromMap(docData.data(), docData.id);
            _currentUser = _currentUser!.copyWith(startupId: docData.id);
            // Save back to user document
            await _db.collection('users').doc(uid).update({'startupId': docData.id});
          }
        }
      } else {
        // Fallback: If document is missing but logged-in user is admin@alu.edu, recreate the Firestore document
        final authUser = _auth.currentUser;
        if (authUser != null && authUser.email == 'admin@alu.edu') {
          UserModel adminUser = UserModel(
            uid: uid,
            email: 'admin@alu.edu',
            displayName: 'Incubator Officer',
            role: 'admin',
            createdAt: DateTime.now(),
            bio: 'Official ALU Venture incubator admin.',
          );
          await _db.collection('users').doc(uid).set(adminUser.toMap());
          _currentUser = adminUser;
        }
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Automatic admin account seeding
  Future<void> seedAdminAccount() async {
    try {
      // 1. Check if admin user document exists in Firestore
      final query = await _db.collection('users')
          .where('email', isEqualTo: 'admin@alu.edu')
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        return; // Already exists in Firestore
      }
      
      // 2. Admin document doesn't exist in Firestore. Let's record the original signed in user
      final originalUser = _auth.currentUser;
      
      // 3. Create the admin user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@alu.edu',
        password: 'admin123',
      );
      final uid = credential.user!.uid;

      // 4. Create Firestore user document
      UserModel adminUser = UserModel(
        uid: uid,
        email: 'admin@alu.edu',
        displayName: 'Incubator Officer',
        role: 'admin',
        createdAt: DateTime.now(),
        bio: 'Official ALU Venture incubator admin.',
      );
      await _db.collection('users').doc(uid).set(adminUser.toMap());
      debugPrint('Admin account seeded successfully.');

      // 5. Clean up Auth state if a different user was logged in originally
      if (originalUser != null) {
        await _auth.signOut();
        // (Note: The user can log back in on the login screen)
      }
    } catch (e) {
      // Handles email-already-in-use exceptions silently or network failures
      debugPrint('Admin seeding check finished (Admin may already exist or offline): $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An unknown error occurred during sign in.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String bio = '',
    List<String> skills = const [],
    String major = '',
    String gradYear = '',
    String portfolioUrl = '',
    // Startup founder fields
    String startupName = '',
    String startupIndustry = '',
    String startupDescription = '',
    String startupCohort = '',
  }) async {
    _setLoading(true);
    clearError();
    try {
      // 1. Create firebase user
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;

      // 2. Setup user model
      UserModel user = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        role: email.trim().toLowerCase() == 'admin@alu.edu' ? 'admin' : role,
        createdAt: DateTime.now(),
        bio: bio,
        skills: skills,
        major: major,
        gradYear: gradYear,
        portfolioUrl: portfolioUrl,
      );

      // 3. Handle specific startup founder flow
      if (role == 'founder') {
        // Create startup document first
        final startupRef = _db.collection('startups').doc();
        StartupModel startup = StartupModel(
          id: startupRef.id,
          founderId: uid,
          name: startupName,
          industry: startupIndustry,
          description: startupDescription,
          cohort: startupCohort,
          isVerified: false, // Startups require admin verification
          createdAt: DateTime.now(),
        );
        
        await startupRef.set(startup.toMap());
        _currentStartup = startup;
        
        // Link startup to user model
        user = user.copyWith(startupId: startupRef.id);
      }

      // 4. Save user document
      await _db.collection('users').doc(uid).set(user.toMap());
      
      // Immediately sign out to prevent auto-login, forcing the user to log in manually
      await _auth.signOut();
      
      _currentUser = null;
      _currentStartup = null;
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An unknown error occurred during registration.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String bio,
    List<String>? skills,
    String? major,
    String? gradYear,
    String? portfolioUrl,
  }) async {
    if (_currentUser == null) return;
    _setLoading(true);
    try {
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        bio: bio,
        skills: skills,
        major: major,
        gradYear: gradYear,
        portfolioUrl: portfolioUrl,
      );

      await _db.collection('users').doc(_currentUser!.uid).update(updatedUser.toMap());
      _currentUser = updatedUser;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateStartupProfile({
    required String name,
    required String industry,
    required String description,
    required String cohort,
  }) async {
    if (_currentUser == null || _currentStartup == null) return;
    _setLoading(true);
    try {
      final updatedStartup = _currentStartup!.copyWith(
        name: name,
        industry: industry,
        description: description,
        cohort: cohort,
      );

      await _db.collection('startups').doc(_currentStartup!.id).update(updatedStartup.toMap());
      _currentStartup = updatedStartup;
      
      // Update startup details stored in opportunities (denormalized for quick fetching)
      final batch = _db.batch();
      final oppsQuery = await _db.collection('opportunities')
          .where('startupId', isEqualTo: _currentStartup!.id)
          .get();
      for (var doc in oppsQuery.docs) {
        batch.update(doc.reference, {'startupName': name});
      }
      await batch.commit();
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _currentUser = null;
      _currentStartup = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
}
