import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'student' | 'founder' | 'admin'
  final DateTime createdAt;
  final String bio;
  
  // Student-specific fields
  final List<String> skills;
  final String major;
  final String gradYear;
  final String portfolioUrl;
  
  // Founder-specific fields
  final String? startupId;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.bio = '',
    this.skills = const [],
    this.major = '',
    this.gradYear = '',
    this.portfolioUrl = '',
    this.startupId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      major: map['major'] ?? '',
      gradYear: map['gradYear'] ?? '',
      portfolioUrl: map['portfolioUrl'] ?? '',
      startupId: map['startupId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'bio': bio,
      'skills': skills,
      'major': major,
      'gradYear': gradYear,
      'portfolioUrl': portfolioUrl,
      'startupId': startupId,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    DateTime? createdAt,
    String? bio,
    List<String>? skills,
    String? major,
    String? gradYear,
    String? portfolioUrl,
    String? startupId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      major: major ?? this.major,
      gradYear: gradYear ?? this.gradYear,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      startupId: startupId ?? this.startupId,
    );
  }
}
