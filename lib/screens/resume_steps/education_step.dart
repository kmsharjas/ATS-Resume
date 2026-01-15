import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';

class EducationStep extends StatefulWidget {
  const EducationStep({Key? key}) : super(key: key);

  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final educations = provider.resume.education;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Education',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your educational background in reverse chronological order.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ...List.generate(
                  educations.length,
                  (index) =>
                      _buildEducationCard(context, educations[index], index),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEducationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationCard(
    BuildContext context,
    Education education,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${education.degree} in ${education.field}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        education.institution,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        education.formattedDate,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      if (education.gpa != null)
                        Text(
                          'GPA: ${education.gpa}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () =>
                          _showEditEducationDialog(context, education, index),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        context.read<ResumeProvider>().deleteEducation(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEducationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EducationDialog(
        onSave: (education) {
          context.read<ResumeProvider>().addEducation(education);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditEducationDialog(
    BuildContext context,
    Education education,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EducationDialog(
        education: education,
        onSave: (updated) {
          context.read<ResumeProvider>().updateEducation(index, updated);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _EducationDialog extends StatefulWidget {
  final Education? education;
  final Function(Education) onSave;

  const _EducationDialog({
    this.education,
    required this.onSave,
  });

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  late TextEditingController _degreeController;
  late TextEditingController _institutionController;
  late TextEditingController _fieldController;
  late TextEditingController _gpaController;
  late DateTime _graduationDate;

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      _degreeController = TextEditingController(text: widget.education!.degree);
      _institutionController =
          TextEditingController(text: widget.education!.institution);
      _fieldController = TextEditingController(text: widget.education!.field);
      _gpaController = TextEditingController(text: widget.education!.gpa ?? '');
      _graduationDate = widget.education!.graduationDate;
    } else {
      _degreeController = TextEditingController();
      _institutionController = TextEditingController();
      _fieldController = TextEditingController();
      _gpaController = TextEditingController();
      _graduationDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _fieldController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.education != null ? 'Edit Education' : 'Add Education'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _degreeController,
              decoration: const InputDecoration(labelText: 'Degree *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fieldController,
              decoration: const InputDecoration(labelText: 'Field of Study *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _institutionController,
              decoration:
                  const InputDecoration(labelText: 'Institution Name *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gpaController,
              decoration: const InputDecoration(labelText: 'GPA (optional)'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Graduation: ${_graduationDate.toLocal().toString().split(' ')[0]}'),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _graduationDate,
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _graduationDate = picked);
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_degreeController.text.isEmpty ||
                _fieldController.text.isEmpty ||
                _institutionController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please fill in all required fields')),
              );
              return;
            }
            widget.onSave(
              Education(
                degree: _degreeController.text,
                institution: _institutionController.text,
                field: _fieldController.text,
                graduationDate: _graduationDate,
                gpa: _gpaController.text.isEmpty ? null : _gpaController.text,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
