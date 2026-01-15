import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';

class WorkExperienceStep extends StatefulWidget {
  const WorkExperienceStep({super.key});

  @override
  State<WorkExperienceStep> createState() => _WorkExperienceStepState();
}

class _WorkExperienceStepState extends State<WorkExperienceStep> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final experiences = provider.resume.workExperience;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Experience',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'List your work experience in reverse chronological order.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ...List.generate(
                  experiences.length,
                  (index) =>
                      _buildExperienceCard(context, experiences[index], index),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddExperienceDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Experience'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceCard(
    BuildContext context,
    WorkExperience experience,
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
                        experience.jobTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${experience.companyName} | ${experience.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        experience.dateRange,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () =>
                          _showEditExperienceDialog(context, experience, index),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        context
                            .read<ResumeProvider>()
                            .deleteWorkExperience(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: experience.responsibilities
                  .map(
                    (resp) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: Theme.of(context).textTheme.bodySmall),
                          Expanded(
                            child: Text(
                              resp,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExperienceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ExperienceDialog(
        onSave: (experience) {
          context.read<ResumeProvider>().addWorkExperience(experience);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditExperienceDialog(
    BuildContext context,
    WorkExperience experience,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ExperienceDialog(
        experience: experience,
        onSave: (updated) {
          context.read<ResumeProvider>().updateWorkExperience(index, updated);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ExperienceDialog extends StatefulWidget {
  final WorkExperience? experience;
  final Function(WorkExperience) onSave;

  const _ExperienceDialog({
    this.experience,
    required this.onSave,
  });

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  late TextEditingController _jobTitleController;
  late TextEditingController _companyNameController;
  late TextEditingController _locationController;
  late DateTime _startDate;
  late DateTime? _endDate;
  late bool _isCurrentlyWorking;
  late List<String> _responsibilities;

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      _jobTitleController =
          TextEditingController(text: widget.experience!.jobTitle);
      _companyNameController =
          TextEditingController(text: widget.experience!.companyName);
      _locationController =
          TextEditingController(text: widget.experience!.location);
      _startDate = widget.experience!.startDate;
      _endDate = widget.experience!.endDate;
      _isCurrentlyWorking = widget.experience!.isCurrentlyWorking;
      _responsibilities = List.from(widget.experience!.responsibilities);
    } else {
      _jobTitleController = TextEditingController();
      _companyNameController = TextEditingController();
      _locationController = TextEditingController();
      _startDate = DateTime.now();
      _endDate = null;
      _isCurrentlyWorking = true;
      _responsibilities = [];
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.experience != null ? 'Edit Experience' : 'Add Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _jobTitleController,
              decoration: const InputDecoration(labelText: 'Job Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Start Date: ${_startDate.toLocal().toString().split(' ')[0]}'),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            if (!_isCurrentlyWorking)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: _startDate,
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Currently Working Here'),
              value: _isCurrentlyWorking,
              onChanged: (value) {
                setState(() {
                  _isCurrentlyWorking = value ?? false;
                  if (_isCurrentlyWorking) {
                    _endDate = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Responsibilities & Achievements'),
                ...List.generate(
                  _responsibilities.length,
                  (index) => Row(
                    children: [
                      Expanded(
                        child: Text(_responsibilities[index]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() => _responsibilities.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showResponsibilityDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Responsibility'),
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
            if (_jobTitleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter job title')),
              );
              return;
            }
            widget.onSave(
              WorkExperience(
                jobTitle: _jobTitleController.text,
                companyName: _companyNameController.text,
                location: _locationController.text,
                startDate: _startDate,
                endDate: _endDate,
                isCurrentlyWorking: _isCurrentlyWorking,
                responsibilities: _responsibilities,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _showResponsibilityDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Responsibility'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(
            hintText: 'Led a team of 5 engineers to develop...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _responsibilities.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
