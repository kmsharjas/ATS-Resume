import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/resume_model.dart';
import '../models/resume_template.dart';

/// Service to handle rendering different resume templates
class ResumeTemplateService {
  /// Extract bytes from base64 data URI
  static Uint8List? extractBytesFromDataUri(String? dataUri) {
    if (dataUri == null || dataUri.isEmpty) return null;
    try {
      // Handle data:image/jpeg;base64,... format
      if (dataUri.startsWith('data:')) {
        final parts = dataUri.split(',');
        if (parts.length == 2) {
          return base64Decode(parts[1]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get template widget for preview
  static Widget getTemplatePreview(
    Resume resume,
    ResumeTemplate template, {
    ScrollController? scrollController,
  }) {
    switch (template) {
      case ResumeTemplate.minimalist:
        return MinimalistTemplate(resume: resume);
      case ResumeTemplate.modern:
        return ModernTemplate(resume: resume);
      case ResumeTemplate.professional:
        return ProfessionalTemplate(resume: resume);
      case ResumeTemplate.creative:
        return CreativeTemplate(resume: resume);
    }
  }
}

/// Minimalist Template - Clean, simple, maximum readability
class MinimalistTemplate extends StatelessWidget {
  final Resume resume;

  const MinimalistTemplate({
    super.key,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with photo and contact info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo
                if (resume.contactInfo.profilePhotoPath != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ResumeTemplateService.extractBytesFromDataUri(
                                    resume.contactInfo.profilePhotoPath) !=
                                null
                            ? Image.memory(
                                ResumeTemplateService.extractBytesFromDataUri(
                                    resume.contactInfo.profilePhotoPath)!,
                                fit: BoxFit.cover,
                              )
                            : Placeholder(
                                child: Text('Photo',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12)),
                              ),
                      ),
                    ),
                  ),
                // Contact Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.contactInfo.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          resume.contactInfo.email,
                          resume.contactInfo.phone,
                          resume.contactInfo.location,
                          if (resume.contactInfo.linkedinUrl != null)
                            resume.contactInfo.linkedinUrl,
                        ].join(' • '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Summary
            if (resume.summary != null &&
                resume.summary!.content.isNotEmpty) ...[
              Text(
                resume.summary!.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],
            // Work Experience
            if (resume.workExperience.isNotEmpty) ...[
              _buildSectionHeader(context, 'Experience'),
              ...resume.sortedWorkExperience.map((exp) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exp.jobTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              exp.dateRange,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${exp.companyName} • ${exp.location}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...exp.responsibilities.map((resp) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text('• $resp',
                                  style: const TextStyle(fontSize: 12)),
                            )),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            // Education
            if (resume.education.isNotEmpty) ...[
              _buildSectionHeader(context, 'Education'),
              ...resume.sortedEducation.map((edu) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${edu.degree} in ${edu.field}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              edu.formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          edu.institution,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (edu.gpa != null)
                          Text(
                            'GPA: ${edu.gpa}',
                            style: const TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            // Skills
            if (resume.skills.isNotEmpty) ...[
              _buildSectionHeader(context, 'Skills'),
              ...resume.skills.map((skill) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          skill.skills.join(', '),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Modern Template - Contemporary design with subtle accents
class ModernTemplate extends StatelessWidget {
  final Resume resume;

  const ModernTemplate({
    super.key,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar
          Container(
            width: 200,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo
                if (resume.contactInfo.profilePhotoPath != null)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ResumeTemplateService.extractBytesFromDataUri(
                                  resume.contactInfo.profilePhotoPath) !=
                              null
                          ? Image.memory(
                              ResumeTemplateService.extractBytesFromDataUri(
                                  resume.contactInfo.profilePhotoPath)!,
                              fit: BoxFit.cover,
                            )
                          : Placeholder(
                              child: Text('Photo',
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12)),
                            ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Contact Info
                const Text(
                  'CONTACT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  resume.contactInfo.email,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  resume.contactInfo.phone,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  resume.contactInfo.location,
                  style: const TextStyle(fontSize: 11),
                ),
                if (resume.contactInfo.linkedinUrl != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    resume.contactInfo.linkedinUrl!,
                    style: const TextStyle(fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 24),
                // Skills
                if (resume.skills.isNotEmpty) ...[
                  const Text(
                    'SKILLS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...resume.skills.map((skill) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skill.skills.join(', '),
                              style: const TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    resume.contactInfo.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // Summary
                  if (resume.summary != null &&
                      resume.summary!.content.isNotEmpty) ...[
                    Text(
                      resume.summary!.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Experience
                  if (resume.workExperience.isNotEmpty) ...[
                    _buildSectionTitle('Experience'),
                    ...resume.sortedWorkExperience.map((exp) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exp.jobTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    exp.dateRange,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                exp.companyName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...exp.responsibilities.map((resp) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Text('• $resp',
                                        style: const TextStyle(fontSize: 11)),
                                  )),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                  // Education
                  if (resume.education.isNotEmpty) ...[
                    _buildSectionTitle('Education'),
                    ...resume.sortedEducation.map((edu) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${edu.degree} in ${edu.field}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    edu.formattedDate,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                edu.institution,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 2,
          width: 30,
          color: Colors.blue[700],
        ),
        const SizedBox(height: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Professional Template - Traditional business-focused layout
class ProfessionalTemplate extends StatelessWidget {
  final Resume resume;

  const ProfessionalTemplate({
    super.key,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with centered contact info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.contactInfo.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            [
                              resume.contactInfo.email,
                              resume.contactInfo.phone,
                              resume.contactInfo.location,
                            ].join(' | '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (resume.contactInfo.profilePhotoPath != null)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ResumeTemplateService.extractBytesFromDataUri(
                                      resume.contactInfo.profilePhotoPath) !=
                                  null
                              ? Image.memory(
                                  ResumeTemplateService.extractBytesFromDataUri(
                                      resume.contactInfo.profilePhotoPath)!,
                                  fit: BoxFit.cover,
                                )
                              : Placeholder(
                                  child: Text('Photo',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10)),
                                ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 16),
            // Summary
            if (resume.summary != null &&
                resume.summary!.content.isNotEmpty) ...[
              Text(
                resume.summary!.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
            ],
            // Work Experience
            if (resume.workExperience.isNotEmpty) ...[
              _buildSectionHeader(context, 'PROFESSIONAL EXPERIENCE'),
              ...resume.sortedWorkExperience.map((exp) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exp.jobTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              exp.dateRange,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          exp.companyName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...exp.responsibilities.map((resp) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text('• $resp',
                                  style: const TextStyle(fontSize: 11)),
                            )),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Education
            if (resume.education.isNotEmpty) ...[
              _buildSectionHeader(context, 'EDUCATION'),
              ...resume.sortedEducation.map((edu) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              edu.institution,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              edu.formattedDate,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          '${edu.degree} in ${edu.field}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Skills
            if (resume.skills.isNotEmpty) ...[
              _buildSectionHeader(context, 'SKILLS'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: resume.skills
                    .map((skill) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${skill.category}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: skill.skills.join(', '),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 1.5,
          width: 80,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Creative Template - Bold design with visual elements
class CreativeTemplate extends StatelessWidget {
  final Resume resume;

  const CreativeTemplate({
    super.key,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section with photo
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(40.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (resume.contactInfo.profilePhotoPath != null)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ResumeTemplateService.extractBytesFromDataUri(
                                  resume.contactInfo.profilePhotoPath) !=
                              null
                          ? Image.memory(
                              ResumeTemplateService.extractBytesFromDataUri(
                                  resume.contactInfo.profilePhotoPath)!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey,
                              child: Center(
                                child: Text('Photo',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ),
                            ),
                    ),
                  ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.contactInfo.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        [
                          resume.contactInfo.email,
                          resume.contactInfo.phone,
                          resume.contactInfo.location,
                          if (resume.contactInfo.linkedinUrl != null)
                            resume.contactInfo.linkedinUrl,
                        ].join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[300],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                if (resume.summary != null &&
                    resume.summary!.content.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border(
                        left: BorderSide(
                          color: Colors.blue[700]!,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      resume.summary!.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                // Experience
                if (resume.workExperience.isNotEmpty) ...[
                  _buildSectionTitle('Experience'),
                  ...resume.sortedWorkExperience.map((exp) => Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exp.jobTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      exp.dateRange,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exp.companyName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...exp.responsibilities.map((resp) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Text('✓ $resp',
                                        style: const TextStyle(fontSize: 11)),
                                  )),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 32),
                ],
                // Education
                if (resume.education.isNotEmpty) ...[
                  _buildSectionTitle('Education'),
                  ...resume.sortedEducation.map((edu) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  edu.institution,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  edu.formattedDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${edu.degree} in ${edu.field}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 32),
                ],
                // Skills
                if (resume.skills.isNotEmpty) ...[
                  _buildSectionTitle('Skills'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: resume.skills
                        .expand((skillCat) => skillCat.skills)
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 24,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
