import 'package:flutter/material.dart';
import '../models/resume_model.dart';

class JobDescriptionProvider extends ChangeNotifier {
  JobDescription? _jobDescription;
  int _matchPercentage = 0;

  JobDescription? get jobDescription => _jobDescription;
  int get matchPercentage => _matchPercentage;
  List<String> get extractedKeywords =>
      _jobDescription?.extractedKeywords ?? [];

  void setJobDescription(String content) {
    _jobDescription = JobDescription.fromContent(content);
    notifyListeners();
  }

  void calculateMatchPercentage(Resume resume) {
    if (_jobDescription == null) {
      _matchPercentage = 0;
      notifyListeners();
      return;
    }

    final resumeText = _buildResumeText(resume).toLowerCase();
    final keywords = _jobDescription!.extractedKeywords;

    if (keywords.isEmpty) {
      _matchPercentage = 0;
      notifyListeners();
      return;
    }

    int matches = 0;
    for (final keyword in keywords) {
      if (resumeText.contains(keyword.toLowerCase())) {
        matches++;
      }
    }

    _matchPercentage = ((matches / keywords.length) * 100).toInt();
    notifyListeners();
  }

  String _buildResumeText(Resume resume) {
    final buffer = StringBuffer();

    buffer.write('${resume.contactInfo.fullName} ');
    buffer.write('${resume.contactInfo.email} ');
    buffer.write('${resume.contactInfo.phone} ');
    buffer.write('${resume.contactInfo.location} ');

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

  void clearJobDescription() {
    _jobDescription = null;
    _matchPercentage = 0;
    notifyListeners();
  }
}
