import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/resume_model.dart';

class ResumeProvider extends ChangeNotifier {
  late Resume _resume;

  Resume get resume => _resume;

  ResumeProvider() {
    _initializeResume();
  }

  void _initializeResume() {
    _resume = Resume(
      id: const Uuid().v4(),
      templateName: 'Classic',
      contactInfo: ContactInfo(
        fullName: '',
        email: '',
        phone: '',
        location: '',
      ),
      workExperience: [],
      education: [],
      skills: [],
    );
  }

  // Contact Info
  void updateContactInfo(ContactInfo contactInfo) {
    _resume.contactInfo = contactInfo;
    _updateTimestamp();
    notifyListeners();
  }

  // Summary
  void updateSummary(String summaryText) {
    _resume.summary = Summary(content: summaryText);
    _updateTimestamp();
    notifyListeners();
  }

  // Work Experience
  void addWorkExperience(WorkExperience experience) {
    _resume.workExperience.add(experience);
    _updateTimestamp();
    notifyListeners();
  }

  void updateWorkExperience(int index, WorkExperience experience) {
    if (index >= 0 && index < _resume.workExperience.length) {
      _resume.workExperience[index] = experience;
      _updateTimestamp();
      notifyListeners();
    }
  }

  void deleteWorkExperience(int index) {
    if (index >= 0 && index < _resume.workExperience.length) {
      _resume.workExperience.removeAt(index);
      _updateTimestamp();
      notifyListeners();
    }
  }

  // Education
  void addEducation(Education education) {
    _resume.education.add(education);
    _updateTimestamp();
    notifyListeners();
  }

  void updateEducation(int index, Education education) {
    if (index >= 0 && index < _resume.education.length) {
      _resume.education[index] = education;
      _updateTimestamp();
      notifyListeners();
    }
  }

  void deleteEducation(int index) {
    if (index >= 0 && index < _resume.education.length) {
      _resume.education.removeAt(index);
      _updateTimestamp();
      notifyListeners();
    }
  }

  // Skills
  void addSkillCategory(Skill skill) {
    _resume.skills.add(skill);
    _updateTimestamp();
    notifyListeners();
  }

  void updateSkillCategory(int index, Skill skill) {
    if (index >= 0 && index < _resume.skills.length) {
      _resume.skills[index] = skill;
      _updateTimestamp();
      notifyListeners();
    }
  }

  void deleteSkillCategory(int index) {
    if (index >= 0 && index < _resume.skills.length) {
      _resume.skills.removeAt(index);
      _updateTimestamp();
      notifyListeners();
    }
  }

  // Template
  void setTemplate(String templateName) {
    _resume.templateName = templateName;
    _updateTimestamp();
    notifyListeners();
  }

  void _updateTimestamp() {
    _resume.updatedAt = DateTime.now();
  }

  void resetResume() {
    _initializeResume();
    notifyListeners();
  }

  Map<String, dynamic> exportAsJson() => _resume.toJson();

  void importFromJson(Map<String, dynamic> json) {
    _resume = Resume.fromJson(json);
    notifyListeners();
  }
}
