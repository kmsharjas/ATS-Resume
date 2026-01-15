import '../models/resume_model.dart';

class ATSValidator {
  static ATSFeedback validateResume(Resume resume) {
    final feedback = ATSFeedback();

    // Check for missing critical information
    if (resume.contactInfo.fullName.isEmpty) {
      feedback.warnings.add('Full name is required');
    }
    if (resume.contactInfo.email.isEmpty) {
      feedback.warnings.add('Email address is required');
    }
    if (resume.contactInfo.phone.isEmpty) {
      feedback.warnings.add('Phone number is required');
    }

    // Check for consistency in date formats
    _validateDateConsistency(resume, feedback);

    // Check for keyword density
    _validateKeywordDensity(resume, feedback);

    // Check for properly formatted work experience
    _validateWorkExperience(resume, feedback);

    // Check for education quality
    _validateEducation(resume, feedback);

    // Check for skill organization
    _validateSkills(resume, feedback);

    // Calculate match based on completeness
    _calculateCompleteness(resume, feedback);

    return feedback;
  }

  static void _validateDateConsistency(Resume resume, ATSFeedback feedback) {
    final dateFormats = <String>{};

    for (final exp in resume.workExperience) {
      dateFormats.add(_formatDate(exp.startDate));
      if (exp.endDate != null) {
        dateFormats.add(_formatDate(exp.endDate!));
      }
    }

    for (final edu in resume.education) {
      dateFormats.add(_formatDate(edu.graduationDate));
    }

    if (dateFormats.length > 1) {
      feedback.hasInconsistentDates = true;
      feedback.warnings.add(
          'Inconsistent date formats detected. Use "MMM YYYY" format consistently.');
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static void _validateKeywordDensity(Resume resume, ATSFeedback feedback) {
    // Check for minimum keyword presence in resume
    final importantKeywords = [
      'experienced',
      'skilled',
      'led',
      'managed',
      'developed',
      'designed',
      'implemented',
      'improved',
      'increased',
      'achieved',
    ];

    final resumeText = _buildResumeText(resume).toLowerCase();
    int keywordCount = 0;

    for (final keyword in importantKeywords) {
      if (resumeText.contains(keyword)) {
        keywordCount++;
      }
    }

    // If less than 30% of common keywords present, warn
    if (keywordCount < (importantKeywords.length * 0.3)) {
      feedback.hasLowKeywordDensity = true;
      feedback.warnings.add(
          'Consider using stronger action verbs (led, managed, achieved, etc.)');
    }
  }

  static void _validateWorkExperience(Resume resume, ATSFeedback feedback) {
    for (final exp in resume.workExperience) {
      if (exp.jobTitle.isEmpty) {
        feedback.warnings.add('Work experience: Job title is missing');
      }
      if (exp.companyName.isEmpty) {
        feedback.warnings.add('Work experience: Company name is missing');
      }
      if (exp.responsibilities.isEmpty) {
        feedback.warnings.add(
            'Work experience: Add at least one responsibility/achievement');
      }

      // Check for quantifiable achievements
      final hasQuantifiableContent = exp.responsibilities.any(
          (r) => RegExp(r'\d+%|\d+x|\d+\$|\d+ years?|\d+ months?').hasMatch(r));

      if (!hasQuantifiableContent && exp.responsibilities.isNotEmpty) {
        feedback.warnings.add(
            '${exp.jobTitle}: Consider adding quantifiable metrics to achievements');
      }
    }
  }

  static void _validateEducation(Resume resume, ATSFeedback feedback) {
    for (final edu in resume.education) {
      if (edu.degree.isEmpty) {
        feedback.warnings.add('Education: Degree type is missing');
      }
      if (edu.institution.isEmpty) {
        feedback.warnings.add('Education: Institution name is missing');
      }
      if (edu.field.isEmpty) {
        feedback.warnings.add('Education: Field of study is missing');
      }
    }
  }

  static void _validateSkills(Resume resume, ATSFeedback feedback) {
    if (resume.skills.isEmpty) {
      feedback.warnings.add('Add at least one skill category');
    }

    int totalSkills = 0;
    for (final skillCat in resume.skills) {
      if (skillCat.category.isEmpty) {
        feedback.warnings.add('Skill: Category name is missing');
      }
      if (skillCat.skills.isEmpty) {
        feedback.warnings.add('${skillCat.category}: Add at least one skill');
      }
      totalSkills += skillCat.skills.length;
    }

    if (totalSkills < 5) {
      feedback.warnings
          .add('Add more skills to improve your profile (recommend 10+)');
    }
  }

  static void _calculateCompleteness(Resume resume, ATSFeedback feedback) {
    int completionScore = 0;

    // Contact info (20 points)
    if (resume.contactInfo.fullName.isNotEmpty &&
        resume.contactInfo.email.isNotEmpty &&
        resume.contactInfo.phone.isNotEmpty) {
      completionScore += 20;
    }

    // Summary (10 points)
    if (resume.summary != null && resume.summary!.content.isNotEmpty) {
      completionScore += 10;
    }

    // Work experience (20 points)
    if (resume.workExperience.isNotEmpty) {
      completionScore += 20;
    }

    // Education (20 points)
    if (resume.education.isNotEmpty) {
      completionScore += 20;
    }

    // Skills (20 points)
    if (resume.skills.isNotEmpty &&
        resume.skills.every((s) => s.skills.isNotEmpty)) {
      completionScore += 20;
    }

    // Penalize for warnings
    completionScore -= (feedback.warnings.length * 2).clamp(0, 30);

    feedback.matchPercentage = completionScore.clamp(0, 100);
  }

  static String _buildResumeText(Resume resume) {
    final buffer = StringBuffer();
    buffer.write('${resume.contactInfo.fullName} ');
    buffer.write('${resume.contactInfo.email} ');
    buffer.write('${resume.contactInfo.phone} ');

    if (resume.summary != null) {
      buffer.write('${resume.summary!.content} ');
    }

    for (final exp in resume.workExperience) {
      buffer.write('${exp.jobTitle} ${exp.companyName} ');
      for (final resp in exp.responsibilities) {
        buffer.write('$resp ');
      }
    }

    for (final edu in resume.education) {
      buffer.write('${edu.degree} ${edu.field} ${edu.institution} ');
    }

    for (final skillCat in resume.skills) {
      buffer.write('${skillCat.category} ');
      for (final skill in skillCat.skills) {
        buffer.write('$skill ');
      }
    }

    return buffer.toString();
  }
}
