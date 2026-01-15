import 'dart:convert';
import 'dart:typed_data';
import '../models/resume_model.dart';

class DocxExportService {
  static Future<Uint8List> generateDocx(Resume resume) async {
    // This is a simplified DOCX generation using XML format
    // In production, you would use the docx package for proper formatting

    final buffer = StringBuffer();

    // DOCX header
    buffer.write(_generateDocxHeader());

    // Document content
    buffer.write(_generateContactInfo(resume.contactInfo));

    if (resume.summary != null && resume.summary!.content.isNotEmpty) {
      buffer.write(
          _generateSection('PROFESSIONAL SUMMARY', resume.summary!.content));
    }

    if (resume.workExperience.isNotEmpty) {
      buffer.write(_generateWorkExperienceSection(resume.sortedWorkExperience));
    }

    if (resume.education.isNotEmpty) {
      buffer.write(_generateEducationSection(resume.sortedEducation));
    }

    if (resume.skills.isNotEmpty) {
      buffer.write(_generateSkillsSection(resume.skills));
    }

    // DOCX footer
    buffer.write(_generateDocxFooter());

    // Convert string to bytes
    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  static String _generateDocxHeader() {
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:body>
''';
  }

  static String _generateDocxFooter() {
    return '''</w:body>
</w:document>
''';
  }

  static String _generateContactInfo(ContactInfo contact) {
    final buffer = StringBuffer();

    // Name
    buffer.write(
        '<w:p><w:pPr><w:jc w:val="left"/><w:pStyle w:val="Heading1"/></w:pPr>');
    buffer.write('<w:r><w:rPr><w:b/><w:sz w:val="48"/></w:rPr>');
    buffer.write('<w:t>${_escapeXml(contact.fullName)}</w:t></w:r></w:p>');

    // Contact details
    buffer.write('<w:p><w:pPr><w:jc w:val="left"/></w:pPr>');
    buffer.write('<w:r><w:t>${_escapeXml(contact.email)}</w:t></w:r>');
    buffer.write('<w:r><w:t> | </w:t></w:r>');
    buffer.write('<w:r><w:t>${_escapeXml(contact.phone)}</w:t></w:r>');
    buffer.write('<w:r><w:t> | </w:t></w:r>');
    buffer.write('<w:r><w:t>${_escapeXml(contact.location)}</w:t></w:r>');

    if (contact.linkedinUrl != null) {
      buffer.write('<w:r><w:t> | </w:t></w:r>');
      buffer.write('<w:r><w:t>${_escapeXml(contact.linkedinUrl!)}</w:t></w:r>');
    }

    if (contact.portfolioUrl != null) {
      buffer.write('<w:r><w:t> | </w:t></w:r>');
      buffer
          .write('<w:r><w:t>${_escapeXml(contact.portfolioUrl!)}</w:t></w:r>');
    }

    buffer.write('</w:p>');
    buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');

    return buffer.toString();
  }

  static String _generateSection(String title, String content) {
    final buffer = StringBuffer();

    // Section title
    buffer.write('<w:p><w:pPr><w:pStyle w:val="Heading2"/></w:pPr>');
    buffer.write('<w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr>');
    buffer.write('<w:t>${_escapeXml(title)}</w:t></w:r></w:p>');

    // Border line
    buffer.write(
        '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="12" w:space="1" w:color="000000"/></w:pBdr></w:pPr></w:p>');

    // Content
    buffer.write('<w:p><w:r><w:t>${_escapeXml(content)}</w:t></w:r></w:p>');
    buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');

    return buffer.toString();
  }

  static String _generateWorkExperienceSection(
      List<WorkExperience> experiences) {
    final buffer = StringBuffer();

    buffer.write('<w:p><w:pPr><w:pStyle w:val="Heading2"/></w:pPr>');
    buffer.write('<w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr>');
    buffer.write('<w:t>WORK EXPERIENCE</w:t></w:r></w:p>');
    buffer.write(
        '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="12" w:space="1" w:color="000000"/></w:pBdr></w:pPr></w:p>');

    for (final exp in experiences) {
      // Job title and date
      buffer.write('<w:p><w:r><w:rPr><w:b/></w:rPr>');
      buffer.write('<w:t>${_escapeXml(exp.jobTitle)}</w:t></w:r>');
      buffer.write('<w:r><w:tab/></w:r>');
      buffer.write('<w:r><w:t>${_escapeXml(exp.dateRange)}</w:t></w:r></w:p>');

      // Company and location
      buffer.write(
          '<w:p><w:r><w:t>${_escapeXml(exp.companyName)} | ${_escapeXml(exp.location)}</w:t></w:r></w:p>');

      // Responsibilities
      for (final resp in exp.responsibilities) {
        buffer.write('<w:p><w:pPr><w:ind w:left="720"/></w:pPr>');
        buffer.write('<w:r><w:t>• ${_escapeXml(resp)}</w:t></w:r></w:p>');
      }

      buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');
    }

    return buffer.toString();
  }

  static String _generateEducationSection(List<Education> educations) {
    final buffer = StringBuffer();

    buffer.write('<w:p><w:pPr><w:pStyle w:val="Heading2"/></w:pPr>');
    buffer.write('<w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr>');
    buffer.write('<w:t>EDUCATION</w:t></w:r></w:p>');
    buffer.write(
        '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="12" w:space="1" w:color="000000"/></w:pBdr></w:pPr></w:p>');

    for (final edu in educations) {
      // Degree and date
      buffer.write('<w:p><w:r><w:rPr><w:b/></w:rPr>');
      buffer.write(
          '<w:t>${_escapeXml(edu.degree)} in ${_escapeXml(edu.field)}</w:t></w:r>');
      buffer.write('<w:r><w:tab/></w:r>');
      buffer.write(
          '<w:r><w:t>${_escapeXml(edu.formattedDate)}</w:t></w:r></w:p>');

      // Institution
      buffer.write(
          '<w:p><w:r><w:t>${_escapeXml(edu.institution)}</w:t></w:r></w:p>');

      if (edu.gpa != null) {
        buffer.write(
            '<w:p><w:r><w:t>GPA: ${_escapeXml(edu.gpa!)}</w:t></w:r></w:p>');
      }

      buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');
    }

    return buffer.toString();
  }

  static String _generateSkillsSection(List<Skill> skills) {
    final buffer = StringBuffer();

    buffer.write('<w:p><w:pPr><w:pStyle w:val="Heading2"/></w:pPr>');
    buffer.write('<w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr>');
    buffer.write('<w:t>SKILLS</w:t></w:r></w:p>');
    buffer.write(
        '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="12" w:space="1" w:color="000000"/></w:pBdr></w:pPr></w:p>');

    for (final skill in skills) {
      buffer.write('<w:p><w:r><w:rPr><w:b/></w:rPr>');
      buffer.write('<w:t>${_escapeXml(skill.category)}</w:t></w:r>');
      buffer.write(
          '<w:r><w:t>: ${_escapeXml(skill.skills.join(', '))}</w:t></w:r></w:p>');
    }

    return buffer.toString();
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
