import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../services/content_suggestions.dart';

class SummaryStep extends StatefulWidget {
  const SummaryStep({super.key});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  late TextEditingController _summaryController;
  String _suggestion = '';

  @override
  void initState() {
    super.initState();
    final summary = context.read<ResumeProvider>().resume.summary;
    _summaryController = TextEditingController(text: summary?.content ?? '');
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'A brief overview of your professional background and career goals. Keep it concise (2-3 sentences).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _summaryController,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                labelText: 'Professional Summary',
                hintText:
                    'Experienced software engineer with 5+ years in full-stack development...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                context.read<ResumeProvider>().updateSummary(value);
                _generateSuggestion(value);
              },
            ),
            const SizedBox(height: 16),
            // Character count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Character count: ${_summaryController.text.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_summaryController.text.length > 300)
                  Chip(
                    label: const Text('Getting long'),
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            if (_suggestion.isNotEmpty)
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
                            'Suggestion',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _suggestion,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              'Summary Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTip('Start with a strong opening statement'),
            _buildTip('Highlight your key qualifications'),
            _buildTip('Include 2-3 years of experience'),
            _buildTip('Use action verbs (Led, Developed, Improved)'),
            _buildTip('Keep it under 300 characters for ATS'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(tip),
          ),
        ],
      ),
    );
  }

  void _generateSuggestion(String text) {
    final suggestion = ContentSuggestions.getKeywordRecommendation(text);
    setState(() {
      _suggestion = suggestion;
    });
  }
}
