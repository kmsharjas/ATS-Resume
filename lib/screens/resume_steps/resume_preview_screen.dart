import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_template.dart';
import '../../services/resume_template_service.dart';

class ResumePreviewScreen extends StatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  late ResumeTemplate _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = ResumeTemplate.minimalist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        elevation: 0,
      ),
      body: Consumer<ResumeProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Template Selector
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Template',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ResumeTemplate.values
                            .map((template) => Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: _buildTemplateButton(
                                    template,
                                    _selectedTemplate == template,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Preview
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    child: ResumeTemplateService.getTemplatePreview(
                      provider.resume,
                      _selectedTemplate,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateButton(ResumeTemplate template, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTemplate = template;
          context.read<ResumeProvider>().setTemplate(template.value);
        });
      },
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(template.displayName),
          const SizedBox(height: 2),
          Text(
            template.description,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
