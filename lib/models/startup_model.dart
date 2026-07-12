import 'package:cloud_firestore/cloud_firestore.dart';

class StartupModel {
  final String id;
  final String founderId;
  final String name;
  final String industry;
  final String description;
  final String cohort; // e.g. "ALU Incubation 2024" or "ALX Hup 2025"
  final bool isVerified;
  final DateTime createdAt;

  StartupModel({
    required this.id,
    required this.founderId,
    required this.name,
    required this.industry,
    required this.description,
    required this.cohort,
    this.isVerified = false,
    required this.createdAt,
  });

  factory StartupModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StartupModel(
      id: documentId,
      founderId: map['founderId'] ?? '',
      name: map['name'] ?? '',
      industry: map['industry'] ?? '',
      description: map['description'] ?? '',
      cohort: map['cohort'] ?? '',
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'founderId': founderId,
      'name': name,
      'industry': industry,
      'description': description,
      'cohort': cohort,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  StartupModel copyWith({
    String? id,
    String? founderId,
    String? name,
    String? industry,
    String? description,
    String? cohort,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return StartupModel(
      id: id ?? this.id,
      founderId: founderId ?? this.founderId,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      cohort: cohort ?? this.cohort,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
