import 'dart:html';
import 'package:flutter/material.dart';
import 'resume_builder_screen.dart';
import 'uploaded_resume_analysis_screen.dart';
import '../services/resume_upload_parser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUploadingResume = false;

  final List<Map<String, dynamic>> _checksData = [
    {
      'icon': Icons.contact_mail,
      'title': 'Contact Info',
      'desc': 'Name, email, phone, location'
    },
    {
      'icon': Icons.description,
      'title': 'Professional Summary',
      'desc': 'Compelling 2-3 sentence intro'
    },
    {
      'icon': Icons.flash_on,
      'title': 'Action Verbs',
      'desc': 'Strong verbs like "Led", "Managed"'
    },
    {
      'icon': Icons.trending_up,
      'title': 'Achievement Focus',
      'desc': 'Results & quantifiable metrics'
    },
    {
      'icon': Icons.work_history,
      'title': 'Experience Details',
      'desc': '3-5 bullet points per job'
    },
    {
      'icon': Icons.school,
      'title': 'Education Complete',
      'desc': 'Degree, school, graduation date'
    },
    {
      'icon': Icons.code,
      'title': 'Technical Skills',
      'desc': 'Industry-specific expertise'
    },
    {
      'icon': Icons.balance,
      'title': 'Skill Balance',
      'desc': 'Mix of technical & soft skills'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6200EE),
                    const Color(0xFF3F51B5),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 48.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATS Resume Checker',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get your resume ATS-ready in seconds. Upload and analyze instantly.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 32),
                    // Main CTA Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _startResumeBuilder(context),
                            icon: const Icon(Icons.edit),
                            label: const Text('Build Resume'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6200EE),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickAndAnalyzeResume(),
                            icon: _isUploadingResume
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFF6200EE)),
                                    ),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(
                              _isUploadingResume ? 'Uploading...' : 'Upload',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBB86FC),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Checks Grid Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What We Check (8 Points)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _checksData.length,
                    itemBuilder: (context, index) {
                      final check = _checksData[index];
                      return _buildCheckCard(
                        context,
                        icon: check['icon'] as IconData,
                        title: check['title'] as String,
                        desc: check['desc'] as String,
                      );
                    },
                  ),
                ],
              ),
            ),
            // Info Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6200EE).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✓ Simple. Modern. Accurate.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6200EE),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your resume or build one from scratch. Get instant ATS scoring based on 8 comprehensive checks.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6200EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6200EE),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndAnalyzeResume() async {
    try {
      final FileUploadInputElement uploadInput = FileUploadInputElement()
        ..accept = '.pdf,.docx,.doc,.txt'
        ..click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final file = files[0];
        final reader = FileReader();

        setState(() => _isUploadingResume = true);

        reader.onLoadEnd.listen((_) async {
          try {
            final result = reader.result as String;
            final cleanedText = _extractTextFromFile(result, file.name);

            final uploadedResume =
                ResumeUploadParser.parseResumeText(cleanedText);

            if (!mounted) return;

            setState(() => _isUploadingResume = false);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UploadedResumeAnalysisScreen(
                  uploadedResume: uploadedResume,
                ),
              ),
            );
          } catch (e) {
            setState(() => _isUploadingResume = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error processing file: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });

        reader.readAsText(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _extractTextFromFile(String fileContent, String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return fileContent
          .replaceAll(RegExp(r'[\x00-\x1f]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    } else if (fileName.toLowerCase().endsWith('.docx')) {
      try {
        final textRegex = RegExp(r'<w:t[^>]*>([^<]*)</w:t>');
        final matches = textRegex.allMatches(fileContent);
        final text = matches
            .map((m) => m.group(1))
            .join(' ')
            .replaceAll(RegExp(r'\s+'), ' ');
        return text.isNotEmpty ? text : fileContent;
      } catch (e) {
        return fileContent;
      }
    } else {
      return fileContent;
    }
  }

  void _startResumeBuilder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResumeBuilderScreen()),
    );
  }
}
