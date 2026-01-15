import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/resume_model.dart';

class DocxExportService {
  static Future<Uint8List> generateDocx(Resume resume) async {
    // Create a proper DOCX file (which is a ZIP archive with XML content)
    final archive = Archive();

    // Add required DOCX structure files
    _addDocxStructure(archive);

    // Generate document.xml with content
    final documentXml = _generateDocument(resume);
    final documentXmlBytes = utf8.encode(documentXml);
    archive.addFile(ArchiveFile(
      'word/document.xml',
      documentXmlBytes.length,
      documentXmlBytes,
    ));

    // Generate relationships file
    final relsXml =
        _generateRelationships(resume.contactInfo.profilePhotoPath != null);
    final relsXmlBytes = utf8.encode(relsXml);
    archive.addFile(ArchiveFile(
      'word/_rels/document.xml.rels',
      relsXmlBytes.length,
      relsXmlBytes,
    ));

    // Add photo if available
    if (resume.contactInfo.profilePhotoPath != null &&
        resume.contactInfo.profilePhotoPath!.isNotEmpty) {
      final photoBytes =
          _extractBytesFromDataUri(resume.contactInfo.profilePhotoPath);
      if (photoBytes != null) {
        archive.addFile(ArchiveFile(
          'word/media/image1.jpg',
          photoBytes.length,
          photoBytes,
        ));
      }
    }

    // Generate ZIP (DOCX file)
    final encoder = ZipEncoder();
    return Uint8List.fromList(encoder.encode(archive)!);
  }

  static void _addDocxStructure(Archive archive) {
    // [Content_Types].xml
    final contentTypes =
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
<Override PartName="/word/media/image1.jpg" ContentType="image/jpeg"/>
</Types>''';

    archive.addFile(ArchiveFile(
        '[Content_Types].xml', contentTypes.length, utf8.encode(contentTypes)));

    // _rels/.rels
    final rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

    archive.addFile(ArchiveFile('_rels/.rels', rels.length, utf8.encode(rels)));

    // word/_rels/document.xml.rels will be added later with photo reference if needed

    // word/styles.xml (basic styles)
    final styles = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults>
<w:rPrDefault>
<w:rPr>
<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
<w:sz w:val="22"/>
</w:rPr>
</w:rPrDefault>
</w:docDefaults>
</w:styles>''';

    archive.addFile(
        ArchiveFile('word/styles.xml', styles.length, utf8.encode(styles)));
  }

  static String _generateDocument(Resume resume) {
    final buffer = StringBuffer();

    buffer.write('''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
<w:body>
''');

    // Contact info with photo
    buffer.write(_generateContactInfo(resume.contactInfo));

    // Summary
    if (resume.summary != null && resume.summary!.content.isNotEmpty) {
      buffer.write(
          _generateSection('PROFESSIONAL SUMMARY', resume.summary!.content));
    }

    // Work experience
    if (resume.workExperience.isNotEmpty) {
      buffer.write(_generateSection('WORK EXPERIENCE', ''));
      for (final exp in resume.sortedWorkExperience) {
        buffer.write(_generateWorkExperience(exp));
      }
    }

    // Education
    if (resume.education.isNotEmpty) {
      buffer.write(_generateSection('EDUCATION', ''));
      for (final edu in resume.sortedEducation) {
        buffer.write(_generateEducation(edu));
      }
    }

    // Skills
    if (resume.skills.isNotEmpty) {
      buffer.write(_generateSection('SKILLS', ''));
      for (final skill in resume.skills) {
        buffer.write(_generateSkill(skill));
      }
    }

    buffer.write('</w:body></w:document>');

    return buffer.toString();
  }

  static String _generateContactInfo(ContactInfo contact) {
    final buffer = StringBuffer();

    // Name (bold, larger)
    buffer.write('<w:p><w:pPr><w:jc w:val="left"/></w:pPr>');
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

    // Add photo if available
    if (contact.profilePhotoPath != null &&
        contact.profilePhotoPath!.isNotEmpty) {
      buffer.write('''<w:p><w:pPr><w:jc w:val="left"/></w:pPr>
<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">
<wp:extent cx="914400" cy="914400"/>
<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
<pic:pic>
<pic:nvPicPr><pic:cNvPr id="1" name="photo.jpg"/><pic:cNvPicPr/></pic:nvPicPr>
<pic:blipFill><a:blip r:embed="rId4"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="914400" cy="914400"/></a:xfrm>
<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>
</pic:pic></a:graphicData></a:graphic>
</wp:inline></w:drawing></w:r></w:p>''');
    }

    buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');

    return buffer.toString();
  }

  static String _generateSection(String title, String content) {
    final buffer = StringBuffer();

    // Section heading (bold)
    buffer
        .write('<w:p><w:pPr><w:spacing w:before="240" w:after="120"/></w:pPr>');
    buffer.write('<w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr>');
    buffer.write('<w:t>${_escapeXml(title)}</w:t></w:r></w:p>');

    // Border
    buffer.write(
        '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="12" w:space="1" w:color="000000"/></w:pBdr></w:pPr></w:p>');

    if (content.isNotEmpty) {
      buffer.write('<w:p><w:r><w:t>${_escapeXml(content)}</w:t></w:r></w:p>');
    }

    return buffer.toString();
  }

  static String _generateWorkExperience(WorkExperience exp) {
    final buffer = StringBuffer();

    // Job title (bold) and date
    buffer.write('<w:p><w:r><w:rPr><w:b/></w:rPr>');
    buffer.write('<w:t>${_escapeXml(exp.jobTitle)}</w:t></w:r>');
    buffer.write('<w:r><w:t> - ${_escapeXml(exp.dateRange)}</w:t></w:r></w:p>');

    // Company and location
    buffer.write(
        '<w:p><w:r><w:t>${_escapeXml(exp.companyName)} | ${_escapeXml(exp.location)}</w:t></w:r></w:p>');

    // Responsibilities
    for (final resp in exp.responsibilities) {
      buffer.write('<w:p><w:pPr><w:ind w:left="720"/></w:pPr>');
      buffer.write('<w:r><w:t>• ${_escapeXml(resp)}</w:t></w:r></w:p>');
    }

    buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');

    return buffer.toString();
  }

  static String _generateEducation(Education edu) {
    final buffer = StringBuffer();

    // Degree and date
    buffer.write('<w:p><w:r><w:rPr><w:b/></w:rPr>');
    buffer.write(
        '<w:t>${_escapeXml(edu.degree)} in ${_escapeXml(edu.field)}</w:t></w:r>');
    buffer.write(
        '<w:r><w:t> - ${_escapeXml(edu.formattedDate)}</w:t></w:r></w:p>');

    // Institution
    buffer.write(
        '<w:p><w:r><w:t>${_escapeXml(edu.institution)}</w:t></w:r></w:p>');

    if (edu.gpa != null) {
      buffer.write(
          '<w:p><w:r><w:t>GPA: ${_escapeXml(edu.gpa!)}</w:t></w:r></w:p>');
    }

    buffer.write('<w:p><w:pPr><w:spacing w:line="240"/></w:pPr></w:p>');

    return buffer.toString();
  }

  static String _generateSkill(Skill skill) {
    final buffer = StringBuffer();

    buffer.write('<w:p><w:r><w:rPr><w:b/></w:rPr>');
    buffer.write('<w:t>${_escapeXml(skill.category)}</w:t></w:r>');
    buffer.write(
        '<w:r><w:t>: ${_escapeXml(skill.skills.join(", "))}</w:t></w:r></w:p>');

    return buffer.toString();
  }

  static String _generateRelationships(bool hasPhoto) {
    final buffer = StringBuffer();

    buffer.write('''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
''');

    if (hasPhoto) {
      buffer.write(
          '<Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.jpg"/>\n');
    }

    buffer.write('</Relationships>');

    return buffer.toString();
  }

  static Uint8List? _extractBytesFromDataUri(String? dataUri) {
    if (dataUri?.startsWith('data:') ?? false) {
      final parts = dataUri!.split(',');
      if (parts.length == 2) {
        try {
          return base64Decode(parts[1]);
        } catch (e) {
          print('Error decoding base64 photo: $e');
          return null;
        }
      }
    }
    return null;
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
