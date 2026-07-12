import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final List<String> studentSkills;
  final String pitch;
  final String status; // 'Pending' | 'Shortlisted' | 'Interviewing' | 'Accepted' | 'Rejected'
  final String feedback;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentSkills,
    required this.pitch,
    this.status = 'Pending',
    this.feedback = '',
    required this.createdAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ApplicationModel(
      id: documentId,
      opportunityId: map['opportunityId'] ?? '',
      opportunityTitle: map['opportunityTitle'] ?? '',
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      studentSkills: List<String>.from(map['studentSkills'] ?? []),
      pitch: map['pitch'] ?? '',
      status: map['status'] ?? 'Pending',
      feedback: map['feedback'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentSkills': studentSkills,
      'pitch': pitch,
      'status': status,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? opportunityId,
    String? opportunityTitle,
    String? startupId,
    String? startupName,
    String? studentId,
    String? studentName,
    String? studentEmail,
    List<String>? studentSkills,
    String? pitch,
    String? status,
    String? feedback,
    DateTime? createdAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      startupId: startupId ?? this.startupId,
      startupName: startupName ?? this.startupName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentSkills: studentSkills ?? this.studentSkills,
      pitch: pitch ?? this.pitch,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
