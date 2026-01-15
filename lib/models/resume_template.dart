/// Resume template styles and configurations
enum ResumeTemplate {
  minimalist,
  modern,
  professional,
  creative,
}

extension TemplateExtension on ResumeTemplate {
  String get displayName {
    switch (this) {
      case ResumeTemplate.minimalist:
        return 'Minimalist';
      case ResumeTemplate.modern:
        return 'Modern';
      case ResumeTemplate.professional:
        return 'Professional';
      case ResumeTemplate.creative:
        return 'Creative';
    }
  }

  String get description {
    switch (this) {
      case ResumeTemplate.minimalist:
        return 'Clean and simple with maximum readability';
      case ResumeTemplate.modern:
        return 'Contemporary design with subtle accents';
      case ResumeTemplate.professional:
        return 'Traditional business-focused layout';
      case ResumeTemplate.creative:
        return 'Bold design with visual elements';
    }
  }

  String get value {
    switch (this) {
      case ResumeTemplate.minimalist:
        return 'minimalist';
      case ResumeTemplate.modern:
        return 'modern';
      case ResumeTemplate.professional:
        return 'professional';
      case ResumeTemplate.creative:
        return 'creative';
    }
  }

  static ResumeTemplate fromString(String value) {
    switch (value.toLowerCase()) {
      case 'minimalist':
        return ResumeTemplate.minimalist;
      case 'modern':
        return ResumeTemplate.modern;
      case 'professional':
        return ResumeTemplate.professional;
      case 'creative':
        return ResumeTemplate.creative;
      default:
        return ResumeTemplate.minimalist;
    }
  }
}
