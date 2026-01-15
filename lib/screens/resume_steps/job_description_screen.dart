import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../providers/job_description_provider.dart';

class JobDescriptionScreen extends StatefulWidget {
  const JobDescriptionScreen({super.key});

  @override
  State<JobDescriptionScreen> createState() => _JobDescriptionScreenState();
}

class _JobDescriptionScreenState extends State<JobDescriptionScreen> {
  late TextEditingController _jobDescriptionController;

  @override
  void initState() {
    super.initState();
    final jobDesc = context.read<JobDescriptionProvider>().jobDescription;
    _jobDescriptionController =
        TextEditingController(text: jobDesc?.content ?? '');
  }

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Description Analyzer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste Job Description',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paste the job description to analyze keywords and see how well your resume matches.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jobDescriptionController,
                maxLines: 10,
                minLines: 8,
                decoration: InputDecoration(
                  hintText: 'Paste job description here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  context
                      .read<JobDescriptionProvider>()
                      .setJobDescription(value);
                  // Calculate match after setting job description
                  context
                      .read<JobDescriptionProvider>()
                      .calculateMatchPercentage(
                        context.read<ResumeProvider>().resume,
                      );
                },
              ),
              const SizedBox(height: 24),
              _buildAnalysisResults(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(BuildContext context) {
    return Consumer<JobDescriptionProvider>(
      builder: (context, jobProvider, _) {
        if (jobProvider.jobDescription == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.edit,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Paste a job description to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        final keywords = jobProvider.extractedKeywords;
        final matchPercentage = jobProvider.matchPercentage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match percentage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resume Match',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$matchPercentage%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: matchPercentage >= 70
                                    ? Colors.green
                                    : matchPercentage >= 50
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: matchPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          matchPercentage >= 70
                              ? Colors.green
                              : matchPercentage >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Keywords found
            Text(
              'Keywords Found (${keywords.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (keywords.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No standard keywords detected in the job description.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: keywords
                    .map(
                      (keyword) => Chip(
                        label: Text(keyword),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
            // Recommendations
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recommendations',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (matchPercentage >= 70)
                      _buildRecommendation(
                        'Excellent keyword alignment!',
                        'Your resume keywords closely match the job description.',
                      )
                    else if (matchPercentage >= 50)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecommendation(
                            'Good alignment',
                            'Try to incorporate more keywords from the job posting.',
                          ),
                          const SizedBox(height: 12),
                          _buildRecommendation(
                            'Focus on missing skills',
                            'Identify skills mentioned in the job that aren\'t in your resume.',
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecommendation(
                            'Low alignment detected',
                            'Consider adding skills and experience related to this position.',
                          ),
                          const SizedBox(height: 12),
                          _buildRecommendation(
                            'Review job requirements',
                            'Ensure your resume addresses the key qualifications.',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendation(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
