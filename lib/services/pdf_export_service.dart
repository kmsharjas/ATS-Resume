import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/resume_model.dart';

class PDFExportService {
  static Future<pw.Document> generatePDF(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(resume.contactInfo),
              pw.SizedBox(height: 20),
              if (resume.summary != null && resume.summary!.content.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('PROFESSIONAL SUMMARY'),
                    pw.Text(resume.summary!.content),
                    pw.SizedBox(height: 15),
                  ],
                ),
              if (resume.workExperience.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('WORK EXPERIENCE'),
                    ..._buildWorkExperienceSection(resume.sortedWorkExperience),
                    pw.SizedBox(height: 15),
                  ],
                ),
              if (resume.education.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('EDUCATION'),
                    ..._buildEducationSection(resume.sortedEducation),
                    pw.SizedBox(height: 15),
                  ],
                ),
              if (resume.skills.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('SKILLS'),
                    ..._buildSkillsSection(resume.skills),
                  ],
                ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(ContactInfo contact) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          contact.fullName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          [
            contact.email,
            contact.phone,
            contact.location,
            if (contact.linkedinUrl != null) contact.linkedinUrl,
            if (contact.portfolioUrl != null) contact.portfolioUrl,
          ].join(' | '),
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static List<pw.Widget> _buildWorkExperienceSection(
      List<WorkExperience> experiences) {
    return experiences.map((exp) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.jobTitle,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(exp.dateRange),
            ],
          ),
          pw.Text('${exp.companyName} | ${exp.location}'),
          pw.SizedBox(height: 8),
          ...exp.responsibilities.map((resp) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                  pw.Expanded(
                    child:
                        pw.Text(resp, style: const pw.TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            );
          }).toList(),
          pw.SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  static List<pw.Widget> _buildEducationSection(List<Education> educations) {
    return educations.map((edu) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${edu.degree} in ${edu.field}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(edu.formattedDate),
            ],
          ),
          pw.Text(edu.institution),
          if (edu.gpa != null) pw.Text('GPA: ${edu.gpa}'),
          pw.SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  static List<pw.Widget> _buildSkillsSection(List<Skill> skills) {
    return skills.map((skill) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            skill.category,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(skill.skills.join(', '),
              style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 8),
        ],
      );
    }).toList();
  }
}
