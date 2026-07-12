import 'package:flutter_test/flutter_test.dart';
import 'package:gakwayaformativeassignment/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserModel Tests', () {
    test('Should correctly parse from map', () {
      final Timestamp nowTimestamp = Timestamp.now();
      final map = {
        'uid': 'test-uid-123',
        'email': 'student@alu.edu',
        'displayName': 'Test Student',
        'role': 'student',
        'createdAt': nowTimestamp,
        'bio': 'A passion for Flutter development.',
        'skills': ['Flutter', 'Dart', 'Firebase'],
        'major': 'Software Engineering',
        'gradYear': '2026',
        'portfolioUrl': 'https://github.com/teststudent',
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'test-uid-123');
      expect(user.email, 'student@alu.edu');
      expect(user.displayName, 'Test Student');
      expect(user.role, 'student');
      expect(user.skills, contains('Flutter'));
      expect(user.skills.length, 3);
      expect(user.major, 'Software Engineering');
      expect(user.gradYear, '2026');
    });

    test('Should correctly convert to map', () {
      final user = UserModel(
        uid: 'test-uid-456',
        email: 'founder@alu.edu',
        displayName: 'Test Founder',
        role: 'founder',
        createdAt: DateTime.now(),
        bio: 'Building ALU VentureLink.',
        startupId: 'startup-999',
      );

      final map = user.toMap();

      expect(map['uid'], 'test-uid-456');
      expect(map['email'], 'founder@alu.edu');
      expect(map['role'], 'founder');
      expect(map['startupId'], 'startup-999');
    });
  });
}
