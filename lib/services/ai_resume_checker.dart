import '../models/resume_model.dart';

class ResumeCheckResult {
  final String checkName;
  final String description;
  final bool passed;
  final String feedback;
  final String recommendation;
  final double score; // 0-100

  ResumeCheckResult({
    required this.checkName,
    required this.description,
    required this.passed,
    required this.feedback,
    required this.recommendation,
    required this.score,
  });
}

class AIResumeChecker {
  /// Performs 16 crucial checks on resume
  static List<ResumeCheckResult> performFullCheck(Resume resume) {
    return [
      _check1ContactInfo(resume),
      _check2ProfessionalSummary(resume),
      _check3ActionVerbs(resume),
      _check4Quantifiable(resume),
      _check5KeywordDensity(resume),
      _check6DateConsistency(resume),
      _check7WorkExperienceDescription(resume),
      _check8EducationComplete(resume),
      _check9SkillsPresent(resume),
      _check10FileFormatting(resume),
      _check11GrammarBasic(resume),
      _check12AchievementFocus(resume),
      _check13RelevantSkills(resume),
      _check14ConsistentFormatting(resume),
      _check15LengthOptimization(resume),
      _check16MissingRedFlags(resume),
    ];
  }

  /// Check 1: Contact Information Completeness
  static ResumeCheckResult _check1ContactInfo(Resume resume) {
    final info = resume.contactInfo;
    final hasAll = info.fullName.isNotEmpty &&
        info.email.isNotEmpty &&
        info.phone.isNotEmpty &&
        info.location.isNotEmpty;

    final score = (info.fullName.isNotEmpty ? 25 : 0) +
        (info.email.isNotEmpty ? 25 : 0) +
        (info.phone.isNotEmpty ? 25 : 0) +
        (info.location.isNotEmpty ? 25 : 0);

    return ResumeCheckResult(
      checkName: 'Contact Information',
      description: 'Verify all essential contact details are present',
      passed: hasAll,
      feedback: hasAll
          ? '✓ All contact information is complete'
          : '✗ Missing: ${[
              if (info.fullName.isEmpty) 'Full Name',
              if (info.email.isEmpty) 'Email',
              if (info.phone.isEmpty) 'Phone',
              if (info.location.isEmpty) 'Location',
            ].join(', ')}',
      recommendation:
          'Ensure recruiter can easily contact you. Email should be professional.',
      score: score.toDouble(),
    );
  }

  /// Check 2: Professional Summary Quality
  static ResumeCheckResult _check2ProfessionalSummary(Resume resume) {
    final summary = resume.summary?.content ?? '';
    final hasSummary = summary.isNotEmpty;
    final goodLength = summary.length >= 50 && summary.length <= 300;
    final hasKeywords = _countKeywords(
            summary, ['experienced', 'skilled', 'professional', 'expertise']) >=
        1;

    final passed = hasSummary && goodLength && hasKeywords;
    var score = 0.0;

    if (hasSummary) score += 30;
    if (goodLength) score += 35;
    if (hasKeywords) score += 35;

    return ResumeCheckResult(
      checkName: 'Professional Summary',
      description: 'Check if summary is compelling and keyword-rich',
      passed: passed,
      feedback: hasSummary
          ? 'Summary length: ${summary.length} characters. ${goodLength ? '✓ Good length' : '✗ Should be 50-300 characters'}'
          : '✗ No professional summary found',
      recommendation:
          'Write 2-3 sentences highlighting key achievements and career goals.',
      score: score.clamp(0, 100),
    );
  }

  /// Check 3: Action Verbs Usage
  static ResumeCheckResult _check3ActionVerbs(Resume resume) {
    final actionVerbs = [
      'achieved',
      'led',
      'managed',
      'developed',
      'created',
      'implemented',
      'designed',
      'improved',
      'increased',
      'decreased',
      'optimized',
      'spearheaded',
      'orchestrated',
      'transformed',
      'revolutionized',
      'pioneered'
    ];

    final allText = _buildResumeText(resume).toLowerCase();
    var verbCount = 0;

    for (var verb in actionVerbs) {
      verbCount += RegExp('\\b$verb\\b').allMatches(allText).length;
    }

    final score = (verbCount / 10) * 100;
    final passed = verbCount >= 5;

    return ResumeCheckResult(
      checkName: 'Action Verbs',
      description: 'Verify strong action verbs are used throughout',
      passed: passed,
      feedback:
          'Found $verbCount action verbs. ${passed ? '✓ Great!' : '✗ Need more strong action verbs'}',
      recommendation:
          'Start bullet points with strong action verbs like: Led, Managed, Developed, Achieved',
      score: score.clamp(0, 100),
    );
  }

  /// Check 4: Quantifiable Achievements
  static ResumeCheckResult _check4Quantifiable(Resume resume) {
    final allText = _buildResumeText(resume);

    // Look for numbers and percentages
    final numberPattern = RegExp(r'\b\d+\b|\d+%');
    final matches = numberPattern.allMatches(allText).length;

    final passed = matches >= 5;
    var score = (matches / 5) * 100;

    return ResumeCheckResult(
      checkName: 'Quantifiable Achievements',
      description: 'Check for metrics and numbers in achievements',
      passed: passed,
      feedback:
          'Found $matches quantifiable metrics. ${passed ? '✓ Excellent' : '✗ Add more numbers and percentages'}',
      recommendation:
          'Include metrics like: "Increased sales by 25%", "Managed team of 8", "Reduced costs by 50K"',
      score: score.clamp(0, 100),
    );
  }

  /// Check 5: Keyword Density
  static ResumeCheckResult _check5KeywordDensity(Resume resume) {
    final allText = _buildResumeText(resume);
    final keywords = _extractKeywords(allText);

    final passed = keywords.length >= 10;
    var score = (keywords.length / 20) * 100;

    return ResumeCheckResult(
      checkName: 'Keyword Density',
      description: 'Verify sufficient industry-specific keywords',
      passed: passed,
      feedback:
          'Found ${keywords.length} unique keywords. ${passed ? '✓ Good keyword coverage' : '✗ Add industry-specific keywords'}',
      recommendation:
          'Include technical skills, industry terms, and certifications relevant to your target role.',
      score: score.clamp(0, 100),
    );
  }

  /// Check 6: Date Consistency
  static ResumeCheckResult _check6DateConsistency(Resume resume) {
    bool dateIssue = false;
    String feedback = '✓ All dates are consistent';

    // Check work experience dates
    for (var i = 0; i < resume.workExperience.length - 1; i++) {
      final current = resume.workExperience[i];
      final next = resume.workExperience[i + 1];

      if (current.startDate.isBefore(next.endDate ?? DateTime.now())) {
        dateIssue = true;
        feedback = '✗ Date overlap detected in work experience';
        break;
      }
    }

    // Check education dates
    for (var edu in resume.education) {
      if (edu.graduationDate.isAfter(DateTime.now())) {
        dateIssue = true;
        feedback = '✗ Future graduation date detected';
        break;
      }
    }

    return ResumeCheckResult(
      checkName: 'Date Consistency',
      description: 'Verify no date overlaps or inconsistencies',
      passed: !dateIssue,
      feedback: feedback,
      recommendation: 'Ensure all dates are accurate and don\'t overlap.',
      score: dateIssue ? 30.0 : 100.0,
    );
  }

  /// Check 7: Work Experience Description Quality
  static ResumeCheckResult _check7WorkExperienceDescription(Resume resume) {
    if (resume.workExperience.isEmpty) {
      return ResumeCheckResult(
        checkName: 'Experience Description',
        description: 'Check quality of work experience descriptions',
        passed: false,
        feedback: '✗ No work experience found',
        recommendation: 'Add at least one work experience entry with details.',
        score: 0,
      );
    }

    var totalScore = 0.0;
    var entriesChecked = 0;

    for (var exp in resume.workExperience) {
      if (exp.responsibilities.isNotEmpty) {
        final avgLength =
            exp.responsibilities.fold(0, (sum, resp) => sum + resp.length) /
                exp.responsibilities.length;
        if (avgLength >= 30) totalScore += 100;
      }
      entriesChecked++;
    }

    final avgScore = entriesChecked > 0 ? totalScore / entriesChecked : 0;
    final passed = avgScore >= 70;

    return ResumeCheckResult(
      checkName: 'Experience Description',
      description: 'Check quality of work experience descriptions',
      passed: passed,
      feedback:
          '${resume.workExperience.length} experiences found. Quality: ${avgScore.toStringAsFixed(0)}%',
      recommendation:
          'Write 3-5 bullet points per job highlighting achievements and responsibilities.',
      score: avgScore.toDouble(),
    );
  }

  /// Check 8: Education Information Complete
  static ResumeCheckResult _check8EducationComplete(Resume resume) {
    if (resume.education.isEmpty) {
      return ResumeCheckResult(
        checkName: 'Education Information',
        description: 'Verify education details are complete',
        passed: false,
        feedback: '✗ No education information found',
        recommendation: 'Add your educational background.',
        score: 0,
      );
    }

    var allComplete = true;
    for (var edu in resume.education) {
      if (edu.degree.isEmpty || edu.institution.isEmpty) {
        allComplete = false;
        break;
      }
    }

    return ResumeCheckResult(
      checkName: 'Education Information',
      description: 'Verify education details are complete',
      passed: allComplete,
      feedback: allComplete
          ? '✓ All education details complete'
          : '✗ Some education fields are incomplete',
      recommendation:
          'Ensure degree, school, and graduation date are all filled in.',
      score: allComplete ? 100 : 60,
    );
  }

  /// Check 9: Skills Section Present
  static ResumeCheckResult _check9SkillsPresent(Resume resume) {
    final totalSkills =
        resume.skills.fold(0, (sum, skillCat) => sum + skillCat.skills.length);

    final passed = totalSkills >= 10;
    var score = 0.0;
    if (totalSkills == 0) {
      score = 0;
    } else if (totalSkills < 5) {
      score = 40;
    } else if (totalSkills < 10) {
      score = 70;
    } else if (totalSkills < 15) {
      score = 85;
    } else {
      score = 100;
    }

    return ResumeCheckResult(
      checkName: 'Skills Section',
      description: 'Verify comprehensive skills are listed',
      passed: passed,
      feedback:
          '$totalSkills skills found. ${passed ? '✓ Good coverage' : '✗ Add more skills'}',
      recommendation:
          'List 15-20 relevant technical and soft skills organized by category.',
      score: score.clamp(0, 100),
    );
  }

  /// Check 10: File Formatting (ATS Compatibility)
  static ResumeCheckResult _check10FileFormatting(Resume resume) {
    // Check for problematic characters
    final allText = _buildResumeText(resume);
    final hasSpecialChars = RegExp(r'[®™©℠]').hasMatch(allText);

    return ResumeCheckResult(
      checkName: 'File Formatting',
      description: 'Check ATS compatibility and formatting',
      passed: !hasSpecialChars,
      feedback: !hasSpecialChars
          ? '✓ ATS-friendly formatting'
          : '✗ Contains special characters that may cause ATS issues',
      recommendation:
          'Avoid graphics, special characters, and complex formatting. Use simple fonts.',
      score: hasSpecialChars ? 50 : 100,
    );
  }

  /// Check 11: Basic Grammar Check
  static ResumeCheckResult _check11GrammarBasic(Resume resume) {
    final allText = _buildResumeText(resume);

    // Simple grammar checks
    final commonErrors = [
      RegExp(r'\btheir\s+\w+\s+is\b'),
      RegExp(r'\byour\s+\w+\s+are\b'),
    ];

    var errorCount = 0;
    for (var pattern in commonErrors) {
      errorCount += pattern.allMatches(allText).length;
    }

    final passed = errorCount == 0;

    return ResumeCheckResult(
      checkName: 'Grammar Check',
      description: 'Basic grammar and spelling verification',
      passed: passed,
      feedback: passed
          ? '✓ No obvious grammar errors found'
          : '✗ Found potential grammar issues',
      recommendation:
          'Proofread carefully and consider using grammar tools like Grammarly.',
      score: passed ? 100 : 60,
    );
  }

  /// Check 12: Achievement Focus
  static ResumeCheckResult _check12AchievementFocus(Resume resume) {
    final allText = _buildResumeText(resume);
    final achievementWords = [
      'improved',
      'increased',
      'achieved',
      'accomplished',
      'exceeded',
      'delivered'
    ];

    var count = 0;
    for (var word in achievementWords) {
      count += RegExp('\\b$word\\b').allMatches(allText.toLowerCase()).length;
    }

    final passed = count >= 3;
    var score = (count / 6) * 100;

    return ResumeCheckResult(
      checkName: 'Achievement Focus',
      description: 'Verify focus on accomplishments not just duties',
      passed: passed,
      feedback:
          'Found $count achievement statements. ${passed ? '✓ Good' : '✗ More achievements needed'}',
      recommendation:
          'Focus on results and impact, not just job responsibilities.',
      score: score.clamp(0, 100),
    );
  }

  /// Check 13: Relevant Skills for Target Role
  static ResumeCheckResult _check13RelevantSkills(Resume resume) {
    final techSkills = resume.skills
        .where((s) => s.category.toLowerCase().contains('technical'))
        .toList();

    final softSkills = resume.skills
        .where((s) => s.category.toLowerCase().contains('soft'))
        .toList();

    final hasBalanced = techSkills.isNotEmpty && softSkills.isNotEmpty;
    var score = 0.0;

    if (techSkills.isNotEmpty) score += 50;
    if (softSkills.isNotEmpty) score += 50;

    return ResumeCheckResult(
      checkName: 'Skill Balance',
      description: 'Verify mix of technical and soft skills',
      passed: hasBalanced,
      feedback: hasBalanced
          ? '✓ Good balance of technical and soft skills'
          : '✗ Add both technical and soft skills',
      recommendation:
          'Include technical skills relevant to the job and soft skills like communication, leadership.',
      score: score.clamp(0, 100),
    );
  }

  /// Check 14: Consistent Formatting
  static ResumeCheckResult _check14ConsistentFormatting(Resume resume) {
    // Check if dates are formatted consistently
    final dateFormats = <String>{};

    for (var exp in resume.workExperience) {
      dateFormats.add(exp.dateRange);
    }

    for (var edu in resume.education) {
      dateFormats.add(edu.formattedDate);
    }

    final consistent = dateFormats.length <= 2;

    return ResumeCheckResult(
      checkName: 'Formatting Consistency',
      description: 'Check for consistent formatting throughout',
      passed: consistent,
      feedback: consistent
          ? '✓ Consistent formatting'
          : '✗ Date formats appear inconsistent',
      recommendation:
          'Use consistent date format (e.g., "Jan 2020 - Dec 2021") throughout.',
      score: consistent ? 100 : 70,
    );
  }

  /// Check 15: Resume Length Optimization
  static ResumeCheckResult _check15LengthOptimization(Resume resume) {
    final totalContent = _buildResumeText(resume);
    final wordCount = totalContent.split(' ').length;

    // Ideal range: 250-750 words for entry level, 500-1000 for experienced
    final isOptimal = wordCount >= 250 && wordCount <= 1200;
    var score = 50.0;

    if (wordCount >= 250 && wordCount <= 1200) {
      score = 100;
    } else if (wordCount < 250) {
      score = 50;
    } else {
      score = 70;
    }

    return ResumeCheckResult(
      checkName: 'Resume Length',
      description: 'Verify resume is not too short or too long',
      passed: isOptimal,
      feedback:
          '$wordCount words. ${isOptimal ? '✓ Good length' : wordCount < 250 ? '✗ Too short' : '✗ Slightly long'}',
      recommendation:
          'Aim for 250-750 words (1 page) for entry level, 500-1000 for experienced professionals.',
      score: score,
    );
  }

  /// Check 16: Missing Red Flags
  static ResumeCheckResult _check16MissingRedFlags(Resume resume) {
    var flagCount = 0;
    var flags = <String>[];

    // Check for unexplained gaps
    DateTime? lastDate;
    for (var exp in resume.sortedWorkExperience) {
      if (lastDate != null) {
        final gap =
            lastDate.difference(exp.endDate ?? DateTime.now()).inDays / 30;
        if (gap > 6) {
          flagCount++;
          flags.add('Gap of ${gap.toStringAsFixed(0)} months detected');
        }
      }
      lastDate = exp.startDate;
    }

    // Check for recent employment
    if (resume.workExperience.isNotEmpty) {
      final mostRecent = resume.sortedWorkExperience.first.endDate;
      if (mostRecent != null) {
        final monthsAgo = DateTime.now().difference(mostRecent).inDays / 30;
        if (monthsAgo > 12 &&
            resume.sortedWorkExperience.first.isCurrentlyWorking) {
          flagCount++;
          flags.add('Consider updating current employment status');
        }
      }
    }

    final passed = flagCount == 0;

    return ResumeCheckResult(
      checkName: 'Red Flags Check',
      description: 'Identify common resume red flags',
      passed: passed,
      feedback: passed ? '✓ No red flags detected' : '⚠ ${flags.join(', ')}',
      recommendation:
          'Address any employment gaps with explanations if asked in interviews.',
      score: passed ? 100 : 60,
    );
  }

  // Helper methods
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

  static int _countKeywords(String text, List<String> keywords) {
    int count = 0;
    final lowerText = text.toLowerCase();
    for (var keyword in keywords) {
      count += RegExp('\\b$keyword\\b').allMatches(lowerText).length;
    }
    return count;
  }

  static List<String> _extractKeywords(String text) {
    final keywords = <String>{};
    final words = text.split(' ');

    for (var word in words) {
      if (word.length > 4 && !_commonWords.contains(word.toLowerCase())) {
        keywords.add(word.toLowerCase());
      }
    }

    return keywords.toList();
  }

  static const List<String> _commonWords = [
    'the',
    'and',
    'with',
    'from',
    'that',
    'have',
    'this',
    'been',
    'were',
    'their',
    'your',
    'also',
    'into',
    'more',
    'than'
  ];
}
