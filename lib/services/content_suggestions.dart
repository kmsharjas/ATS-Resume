class ContentSuggestions {
  static const Map<String, List<String>> actionVerbs = {
    'Leadership': [
      'Led',
      'Directed',
      'Managed',
      'Coordinated',
      'Oversaw',
      'Supervised',
      'Championed',
      'Spearheaded',
    ],
    'Achievement': [
      'Accomplished',
      'Achieved',
      'Attained',
      'Exceeded',
      'Improved',
      'Increased',
      'Boosted',
      'Enhanced',
    ],
    'Technical': [
      'Developed',
      'Implemented',
      'Engineered',
      'Designed',
      'Built',
      'Created',
      'Programmed',
      'Architected',
    ],
    'Analysis': [
      'Analyzed',
      'Evaluated',
      'Assessed',
      'Examined',
      'Identified',
      'Investigated',
      'Diagnosed',
      'Determined',
    ],
    'Communication': [
      'Communicated',
      'Presented',
      'Negotiated',
      'Collaborated',
      'Coordinated',
      'Liaised',
      'Briefed',
      'Articulated',
    ],
  };

  static List<String> getSuggestedVerbs(String category) {
    return actionVerbs[category] ?? actionVerbs['Achievement']!;
  }

  static List<String> getAchievementTemplates() {
    return [
      'Increased [metric] by [number]% through [action]',
      'Reduced [metric] by [number]% by implementing [solution]',
      'Led a team of [number] professionals to [achievement]',
      'Improved [process] efficiency, resulting in [benefit]',
      'Developed [solution] that [specific_outcome] for [number] users/clients',
      'Managed budget of [\$amount] and delivered [result]',
      'Streamlined [process], saving [time/money/resources]',
      'Designed and launched [project] that achieved [metric]',
    ];
  }

  static List<String> suggestBulletPoints(String jobTitle) {
    final suggestions = <String>[];

    // Generic suggestions based on common responsibilities
    suggestions.addAll([
      'Collaborated with cross-functional teams to deliver projects on time',
      'Optimized workflow processes, improving efficiency by tracking KPIs',
      'Communicated progress and challenges to stakeholders regularly',
      'Identified and resolved operational bottlenecks',
      'Contributed to continuous improvement initiatives',
    ]);

    // Role-specific suggestions
    if (jobTitle.toLowerCase().contains('engineer') ||
        jobTitle.toLowerCase().contains('developer')) {
      suggestions.addAll([
        'Architected scalable solutions using modern technologies',
        'Wrote clean, maintainable code with comprehensive documentation',
        'Implemented automated testing, improving code quality',
        'Conducted code reviews and mentored junior developers',
        'Debugged complex issues and deployed production fixes',
      ]);
    }

    if (jobTitle.toLowerCase().contains('manager') ||
        jobTitle.toLowerCase().contains('lead')) {
      suggestions.addAll([
        'Led team of X professionals across product roadmap delivery',
        'Mentored and developed team members, resulting in career growth',
        'Set performance metrics and drove team to exceed targets',
        'Managed stakeholder relationships and executive communications',
        'Implemented agile processes improving team velocity',
      ]);
    }

    if (jobTitle.toLowerCase().contains('analyst')) {
      suggestions.addAll([
        'Analyzed data to identify trends and provide actionable insights',
        'Created dashboards and visualizations for executive reporting',
        'Developed KPIs and tracking mechanisms for strategic initiatives',
        'Collaborated with teams to implement data-driven improvements',
        'Documented findings in clear reports for non-technical stakeholders',
      ]);
    }

    if (jobTitle.toLowerCase().contains('sales') ||
        jobTitle.toLowerCase().contains('account')) {
      suggestions.addAll([
        'Generated \$X in revenue through strategic account management',
        'Built relationships with C-level executives resulting in partnerships',
        'Exceeded quota by X% through targeted outreach campaigns',
        'Onboarded and retained X% of new clients',
        'Presented solutions to prospects, achieving X% close rate',
      ]);
    }

    return suggestions;
  }

  static List<String> suggestSkillsForRole(String jobTitle) {
    final skillSuggestions = <String>[];

    // Technical Skills
    if (jobTitle.toLowerCase().contains('developer') ||
        jobTitle.toLowerCase().contains('engineer')) {
      skillSuggestions.addAll([
        'Programming Languages: JavaScript, Python, Java, C++',
        'Frameworks: React, Flutter, Django, Spring',
        'Databases: SQL, MongoDB, Firebase',
        'Tools: Git, Docker, Jenkins, AWS',
      ]);
    }

    // Professional Skills (Universal)
    skillSuggestions.addAll([
      'Communication',
      'Problem Solving',
      'Project Management',
      'Teamwork',
      'Attention to Detail',
    ]);

    return skillSuggestions;
  }

  static String getKeywordRecommendation(String currentText) {
    final recommendations = <String>[];

    if (!currentText.toLowerCase().contains('led') &&
        !currentText.toLowerCase().contains('managed') &&
        !currentText.toLowerCase().contains('directed')) {
      recommendations.add('Add leadership-focused action verbs');
    }

    if (!RegExp(r'\d+%|\d+x').hasMatch(currentText)) {
      recommendations
          .add('Include quantifiable metrics (percentages, numbers)');
    }

    if (!currentText.toLowerCase().contains('team') &&
        !currentText.toLowerCase().contains('collaborated')) {
      recommendations.add('Highlight teamwork and collaboration');
    }

    if (currentText.length < 50) {
      recommendations.add('Expand bullet point with more details');
    }

    return recommendations.isEmpty
        ? 'Good bullet point! Clear and quantifiable.'
        : recommendations.join(' • ');
  }
}
