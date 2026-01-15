import '../models/resume_model.dart';

/// Service to parse uploaded resumes and extract information
class ResumeUploadParser {
  /// Parse uploaded resume text and create Resume object
  static Resume parseResumeText(String resumeText) {
    final lines = resumeText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final text = resumeText.toLowerCase();

    // Extract contact info
    final fullName = _extractName(lines);
    final email = _extractEmail(text);
    final phone = _extractPhone(text);
    final location = _extractLocation(lines);

    // Extract work experience
    final workExperience = _extractWorkExperience(lines);

    // Extract education
    final education = _extractEducation(lines);

    // Extract skills
    final skills = _extractSkills(lines);

    // Extract summary
    final summary = _extractSummary(lines);

    return Resume(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      templateName: 'Professional',
      contactInfo: ContactInfo(
        fullName: fullName,
        email: email,
        phone: phone,
        location: location,
      ),
      summary: summary,
      workExperience: workExperience,
      education: education,
      skills: skills,
    );
  }

  static String _extractName(List<String> lines) {
    if (lines.isEmpty) return 'Resume Candidate';

    for (var line in lines) {
      if (line.length > 2 && line.length < 100) {
        final words = line.split(' ');
        if (words.length <= 4 && !_isLikelySectionHeader(line)) {
          return line;
        }
      }
    }
    return 'Resume Candidate';
  }

  static String _extractEmail(String text) {
    final emailRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
    final match = emailRegex.firstMatch(text);
    return match?.group(0) ?? '';
  }

  static String _extractPhone(String text) {
    final phoneRegex = RegExp(
        r'(\+\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|(\+\d{1,3})?\s?\d{10}|(\d{10})');
    final match = phoneRegex.firstMatch(text);
    return match?.group(0) ?? '';
  }

  static String _extractLocation(List<String> lines) {
    final locationIndicators = [
      'city',
      'based',
      'located',
      'area',
      'county',
      'state'
    ];

    for (var line in lines) {
      final lower = line.toLowerCase();
      for (var indicator in locationIndicators) {
        if (lower.contains(indicator)) {
          if (!_isLikelyJobTitle(line) && line.length < 100) {
            return line.replaceAll('|', '').trim();
          }
        }
      }
    }

    // Try to find city, state pattern
    final cityStateRegex = RegExp(r'([A-Z][a-z]+),\s*([A-Z]{2})');
    final match = cityStateRegex.firstMatch(lines.join(' '));
    if (match != null) return match.group(0) ?? '';

    return '';
  }

  static List<WorkExperience> _extractWorkExperience(List<String> lines) {
    final experiences = <WorkExperience>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i];

      if (_isLikelyJobTitle(line)) {
        final jobTitle = line;
        var company = '';
        var location = '';
        final responsibilities = <String>[];

        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (_isLikelyCompanyName(nextLine)) {
            company = nextLine;
            i++;
          }
        }

        i++;
        while (i < lines.length) {
          final currentLine = lines[i];

          if (_isLikelySectionHeader(currentLine)) break;
          if (_isLikelyJobTitle(currentLine)) break;

          if (location.isEmpty && _couldBeLocation(currentLine)) {
            location = currentLine;
            i++;
            continue;
          }

          if (currentLine.startsWith('•') ||
              currentLine.startsWith('-') ||
              currentLine.startsWith('*') ||
              (currentLine.length > 10 && !_isLikelyCompanyName(currentLine))) {
            responsibilities.add(
                currentLine.replaceFirst(RegExp(r'^[•\-*]\s*'), '').trim());
          }

          i++;
        }

        if (jobTitle.isNotEmpty) {
          experiences.add(WorkExperience(
            jobTitle: jobTitle,
            companyName: company.isNotEmpty ? company : 'Company',
            location: location,
            startDate: DateTime.now().subtract(const Duration(days: 365)),
            endDate: null,
            isCurrentlyWorking: false,
            responsibilities: responsibilities.isNotEmpty
                ? responsibilities
                : ['Professional experience'],
          ));
        }
        continue;
      }

      i++;
    }

    return experiences;
  }

  static List<Education> _extractEducation(List<String> lines) {
    final educations = <Education>[];
    final degreeKeywords = [
      'bachelor',
      'master',
      'phd',
      'diploma',
      'associate',
      'b.s',
      'b.a',
      'b.e',
      'm.s',
      'm.a',
      'm.b.a',
      'degree'
    ];

    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();

      for (var keyword in degreeKeywords) {
        if (lower.contains(keyword)) {
          final line = lines[i];
          final parts = line.split(RegExp(r'[|,]'));

          String degree = keyword;
          String institution = 'University';
          String field = 'Field of Study';

          if (parts.isNotEmpty) {
            degree = parts[0].trim();
            if (parts.length > 1) institution = parts[1].trim();
            if (parts.length > 2) field = parts[2].trim();
          }

          if (line.toLowerCase().contains(' in ')) {
            final split = line.split(RegExp(r'\s+in\s+'));
            if (split.length > 1) {
              degree = split[0].trim();
              field = split[1].split(RegExp(r'[,|]'))[0].trim();
            }
          }

          educations.add(Education(
            degree: degree.isEmpty ? keyword : degree,
            institution: institution.isEmpty ? 'University' : institution,
            field: field.isEmpty ? 'Studies' : field,
            graduationDate: DateTime(DateTime.now().year),
          ));
          break;
        }
      }
    }

    return educations.isNotEmpty
        ? educations
        : [
            Education(
              degree: 'Education',
              institution: 'Institution',
              field: 'Field',
              graduationDate: DateTime.now(),
            )
          ];
  }

  static List<Skill> _extractSkills(List<String> lines) {
    final skills = <Skill>[];
    var inSkillSection = false;
    final technicalSkills = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();

      if (lower.contains('skill') && !inSkillSection) {
        inSkillSection = true;
        continue;
      }

      if (inSkillSection) {
        if (_isLikelySectionHeader(lines[i]) && !lower.contains('skill')) {
          break;
        }

        if (lines[i].isNotEmpty && !_isLikelySectionHeader(lines[i])) {
          final skillList = lines[i]
              .split(RegExp(r'[,;|]'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty && s.length > 1)
              .toList();

          technicalSkills.addAll(skillList);
        }
      }
    }

    if (technicalSkills.isNotEmpty) {
      skills.add(Skill(
        category: 'Technical Skills',
        skills: technicalSkills.take(15).toList(),
      ));
    }

    if (skills.isEmpty) {
      skills.add(Skill(
        category: 'Skills',
        skills: ['Professional skills'],
      ));
    }

    return skills;
  }

  static Summary? _extractSummary(List<String> lines) {
    final summaryKeywords = [
      'summary',
      'objective',
      'profile',
      'overview',
      'about'
    ];
    var summaryText = '';

    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();

      for (var keyword in summaryKeywords) {
        if (lower.contains(keyword)) {
          for (var j = i + 1; j < i + 5 && j < lines.length; j++) {
            final line = lines[j].trim();
            if (line.isNotEmpty &&
                !_isLikelySectionHeader(line) &&
                line.length > 5) {
              summaryText += '$line ';
            }
          }
          break;
        }
      }

      if (summaryText.isNotEmpty) break;
    }

    if (summaryText.isEmpty && lines.length > 2) {
      summaryText =
          lines.where((l) => l.length > 10 && l.length < 200).take(1).join(' ');
    }

    if (summaryText.isNotEmpty) {
      final maxLen = summaryText.length > 300 ? 300 : summaryText.length;
      return Summary(content: summaryText.trim().substring(0, maxLen));
    }

    return Summary(
        content: 'Professional with relevant experience and skills.');
  }

  static bool _isLikelyJobTitle(String text) {
    final jobKeywords = [
      'manager',
      'engineer',
      'developer',
      'designer',
      'analyst',
      'consultant',
      'specialist',
      'coordinator',
      'assistant',
      'officer',
      'lead',
      'director',
      'senior',
      'junior',
      'architect',
      'scientist',
      'contractor',
      'associate',
      'executive',
      'administrator',
      'supervisor',
      'technician',
      'representative',
    ];

    final lower = text.toLowerCase();
    return jobKeywords.any((keyword) => lower.contains(keyword)) &&
        text.length < 100;
  }

  static bool _isLikelyCompanyName(String text) {
    return text.length > 2 &&
        text.length < 100 &&
        !text.contains('@') &&
        !text.contains('http') &&
        !_isLikelyJobTitle(text) &&
        !_isLikelySectionHeader(text);
  }

  static bool _isLikelySectionHeader(String text) {
    final headers = [
      'experience',
      'education',
      'skills',
      'certification',
      'project',
      'summary',
      'objective',
      'profile',
      'references',
      'awards',
      'languages',
      'publications'
    ];

    final lower = text.toLowerCase();
    return headers.any((h) => lower.contains(h)) && text.length < 50;
  }

  static bool _couldBeLocation(String text) {
    return (text.contains(',') || RegExp(r'\b[A-Z]{2}\b').hasMatch(text)) &&
        text.length < 60 &&
        !_isLikelyJobTitle(text);
  }
}
