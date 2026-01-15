import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';

class SkillsStep extends StatefulWidget {
  const SkillsStep({super.key});

  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final skills = provider.resume.skills;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your skills into categories. Use comma-separated values.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ...List.generate(
                  skills.length,
                  (index) => _buildSkillCard(context, skills[index], index),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddSkillDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Skill Category'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    Skill skill,
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
                        skill.category,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skill.skills
                            .map(
                              (s) => Chip(
                                label: Text(s),
                                onDeleted: () {
                                  final updated = Skill(
                                    category: skill.category,
                                    skills: skill.skills
                                        .where((skill) => skill != s)
                                        .toList(),
                                  );
                                  context
                                      .read<ResumeProvider>()
                                      .updateSkillCategory(index, updated);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () => _showEditSkillDialog(context, skill, index),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        context
                            .read<ResumeProvider>()
                            .deleteSkillCategory(index);
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

  void _showAddSkillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SkillDialog(
        onSave: (skill) {
          context.read<ResumeProvider>().addSkillCategory(skill);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditSkillDialog(
    BuildContext context,
    Skill skill,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => _SkillDialog(
        skill: skill,
        onSave: (updated) {
          context.read<ResumeProvider>().updateSkillCategory(index, updated);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SkillDialog extends StatefulWidget {
  final Skill? skill;
  final Function(Skill) onSave;

  const _SkillDialog({
    this.skill,
    required this.onSave,
  });

  @override
  State<_SkillDialog> createState() => _SkillDialogState();
}

class _SkillDialogState extends State<_SkillDialog> {
  late TextEditingController _categoryController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      _categoryController = TextEditingController(text: widget.skill!.category);
      _skillsController =
          TextEditingController(text: widget.skill!.skills.join(', '));
    } else {
      _categoryController = TextEditingController();
      _skillsController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.skill != null ? 'Edit Skill Category' : 'Add Skill Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category *',
                hintText: 'Programming Languages',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillsController,
              maxLines: 3,
              minLines: 2,
              decoration: const InputDecoration(
                labelText: 'Skills *',
                hintText: 'Python, Java, JavaScript, Flutter',
                helperText: 'Separate with commas',
                border: OutlineInputBorder(),
              ),
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
            if (_categoryController.text.isEmpty ||
                _skillsController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please fill in all required fields')),
              );
              return;
            }

            final skillsList = _skillsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

            widget.onSave(
              Skill(
                category: _categoryController.text,
                skills: skillsList,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
