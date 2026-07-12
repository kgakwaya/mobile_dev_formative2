import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityModel {
  final String id;
  final String startupId;
  final String startupName;
  final bool startupVerified;
  final String title;
  final String description;
  final String roleType; // Software Development, UI/UX Design, Marketing, Operations, Business Analysis, Content Creation, Research
  final List<String> skillsRequired;
  final String locationType; // Remote, Hybrid, On-Campus
  final String duration; // e.g. "3 months", "6 months"
  final String hoursPerWeek; // e.g. "10 hrs/week", "20 hrs/week"
  final bool isClosed;
  final DateTime createdAt;

  OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.startupVerified,
    required this.title,
    required this.description,
    required this.roleType,
    required this.skillsRequired,
    required this.locationType,
    required this.duration,
    required this.hoursPerWeek,
    this.isClosed = false,
    required this.createdAt,
  });

  factory OpportunityModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OpportunityModel(
      id: documentId,
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      startupVerified: map['startupVerified'] ?? false,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      roleType: map['roleType'] ?? '',
      skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
      locationType: map['locationType'] ?? 'Remote',
      duration: map['duration'] ?? '',
      hoursPerWeek: map['hoursPerWeek'] ?? '',
      isClosed: map['isClosed'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'startupVerified': startupVerified,
      'title': title,
      'description': description,
      'roleType': roleType,
      'skillsRequired': skillsRequired,
      'locationType': locationType,
      'duration': duration,
      'hoursPerWeek': hoursPerWeek,
      'isClosed': isClosed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OpportunityModel copyWith({
    String? id,
    String? startupId,
    String? startupName,
    bool? startupVerified,
    String? title,
    String? description,
    String? roleType,
    List<String>? skillsRequired,
    String? locationType,
    String? duration,
    String? hoursPerWeek,
    bool? isClosed,
    DateTime? createdAt,
  }) {
    return OpportunityModel(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      startupName: startupName ?? this.startupName,
      startupVerified: startupVerified ?? this.startupVerified,
      title: title ?? this.title,
      description: description ?? this.description,
      roleType: roleType ?? this.roleType,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      locationType: locationType ?? this.locationType,
      duration: duration ?? this.duration,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
