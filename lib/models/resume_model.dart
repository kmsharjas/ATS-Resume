import 'package:intl/intl.dart';

class ContactInfo {
  String fullName;
  String email;
  String phone;
  String location;
  String? linkedinUrl;
  String? portfolioUrl;
  String? profilePhotoPath; // Base64 encoded photo or file path

  ContactInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedinUrl,
    this.portfolioUrl,
    this.profilePhotoPath,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedinUrl': linkedinUrl,
        'portfolioUrl': portfolioUrl,
        'profilePhotoPath': profilePhotoPath,
      };

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        location: json['location'] ?? '',
        linkedinUrl: json['linkedinUrl'],
        portfolioUrl: json['portfolioUrl'],
        profilePhotoPath: json['profilePhotoPath'],
      );
}

class WorkExperience {
  String jobTitle;
  String companyName;
  String location;
  DateTime startDate;
  DateTime? endDate;
  bool isCurrentlyWorking;
  List<String> responsibilities;

  WorkExperience({
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.isCurrentlyWorking,
    required this.responsibilities,
  });

  String get dateRange {
    final startFormatted = DateFormat('MMM yyyy').format(startDate);
    if (isCurrentlyWorking) {
      return '$startFormatted - Present';
    }
    final endFormatted = DateFormat('MMM yyyy').format(endDate!);
    return '$startFormatted - $endFormatted';
  }

  Map<String, dynamic> toJson() => {
        'jobTitle': jobTitle,
        'companyName': companyName,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isCurrentlyWorking': isCurrentlyWorking,
        'responsibilities': responsibilities,
      };

  factory WorkExperience.fromJson(Map<String, dynamic> json) => WorkExperience(
        jobTitle: json['jobTitle'] ?? '',
        companyName: json['companyName'] ?? '',
        location: json['location'] ?? '',
        startDate: DateTime.parse(
            json['startDate'] ?? DateTime.now().toIso8601String()),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        isCurrentlyWorking: json['isCurrentlyWorking'] ?? false,
        responsibilities: List<String>.from(json['responsibilities'] ?? []),
      );
}

class Education {
  String degree;
  String institution;
  String field;
  DateTime graduationDate;
  String? gpa;
  List<String>? relevantCoursework;

  Education({
    required this.degree,
    required this.institution,
    required this.field,
    required this.graduationDate,
    this.gpa,
    this.relevantCoursework,
  });

  String get formattedDate => DateFormat('MMM yyyy').format(graduationDate);

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'field': field,
        'graduationDate': graduationDate.toIso8601String(),
        'gpa': gpa,
        'relevantCoursework': relevantCoursework,
      };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        degree: json['degree'] ?? '',
        institution: json['institution'] ?? '',
        field: json['field'] ?? '',
        graduationDate: DateTime.parse(
            json['graduationDate'] ?? DateTime.now().toIso8601String()),
        gpa: json['gpa'],
        relevantCoursework: json['relevantCoursework'] != null
            ? List<String>.from(json['relevantCoursework'])
            : null,
      );
}

class Skill {
  String category;
  List<String> skills;

  Skill({
    required this.category,
    required this.skills,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'skills': skills,
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        category: json['category'] ?? '',
        skills: List<String>.from(json['skills'] ?? []),
      );
}

class Summary {
  String content;
  int characterCount;

  Summary({
    required this.content,
  }) : characterCount = content.length;

  Map<String, dynamic> toJson() => {
        'content': content,
      };

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        content: json['content'] ?? '',
      );
}

class Resume {
  String id;
  String templateName;
  DateTime createdAt;
  DateTime updatedAt;
  ContactInfo contactInfo;
  Summary? summary;
  List<WorkExperience> workExperience;
  List<Education> education;
  List<Skill> skills;

  Resume({
    required this.id,
    required this.templateName,
    required this.contactInfo,
    this.summary,
    required this.workExperience,
    required this.education,
    required this.skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Sort experience and education in reverse chronological order
  List<WorkExperience> get sortedWorkExperience {
    final sorted = [...workExperience];
    sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted;
  }

  List<Education> get sortedEducation {
    final sorted = [...education];
    sorted.sort((a, b) => b.graduationDate.compareTo(a.graduationDate));
    return sorted;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateName': templateName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'contactInfo': contactInfo.toJson(),
        'summary': summary?.toJson(),
        'workExperience': workExperience.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
        'skills': skills.map((e) => e.toJson()).toList(),
      };

  factory Resume.fromJson(Map<String, dynamic> json) => Resume(
        id: json['id'] ?? '',
        templateName: json['templateName'] ?? 'Classic',
        contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
        summary:
            json['summary'] != null ? Summary.fromJson(json['summary']) : null,
        workExperience: (json['workExperience'] as List?)
                ?.map((e) => WorkExperience.fromJson(e))
                .toList() ??
            [],
        education: (json['education'] as List?)
                ?.map((e) => Education.fromJson(e))
                .toList() ??
            [],
        skills:
            (json['skills'] as List?)?.map((e) => Skill.fromJson(e)).toList() ??
                [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}

class JobDescription {
  String content;
  List<String> extractedKeywords;
  int characterCount;

  JobDescription({
    required this.content,
    required this.extractedKeywords,
  }) : characterCount = content.length;

  factory JobDescription.fromContent(String content) {
    final keywords = _extractKeywords(content);
    return JobDescription(
      content: content,
      extractedKeywords: keywords,
    );
  }

  static List<String> _extractKeywords(String text) {
    // Simple keyword extraction based on technical terms and common skills
    final commonKeywords = [
      'flutter',
      'dart',
      'kotlin',
      'swift',
      'java',
      'python',
      'javascript',
      'react',
      'angular',
      'node.js',
      'mongodb',
      'sql',
      'firebase',
      'aws',
      'leadership',
      'communication',
      'project management',
      'agile',
      'scrum',
      'testing',
      'debugging',
      'rest api',
      'microservices',
      'docker',
      'git',
      'ci/cd',
      'devops',
      'machine learning',
      'artificial intelligence',
    ];

    final lowerText = text.toLowerCase();
    return commonKeywords
        .where((keyword) => lowerText.contains(keyword))
        .toList();
  }
}

class ATSFeedback {
  bool hasMultipleColumns;
  bool hasImages;
  bool hasCustomFonts;
  bool hasInconsistentDates;
  bool hasLowKeywordDensity;
  List<String> warnings;
  int matchPercentage;

  ATSFeedback({
    this.hasMultipleColumns = false,
    this.hasImages = false,
    this.hasCustomFonts = false,
    this.hasInconsistentDates = false,
    this.hasLowKeywordDensity = false,
    List<String>? warnings,
    this.matchPercentage = 0,
  }) : warnings = warnings ?? [];

  bool get isOptimal =>
      !hasMultipleColumns &&
      !hasImages &&
      !hasCustomFonts &&
      !hasInconsistentDates &&
      !hasLowKeywordDensity &&
      warnings.isEmpty;
}
