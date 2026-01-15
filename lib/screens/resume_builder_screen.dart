import 'package:flutter/material.dart';
import 'resume_steps/contact_info_step.dart';
import 'resume_steps/summary_step.dart';
import 'resume_steps/work_experience_step.dart';
import 'resume_steps/education_step.dart';
import 'resume_steps/skills_step.dart';
import 'resume_steps/review_step.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({Key? key}) : super(key: key);

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  final List<String> steps = [
    'Contact Info',
    'Summary',
    'Work Experience',
    'Education',
    'Skills',
    'Review & Export',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of ${steps.length}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            minHeight: 4,
          ),
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  steps[_currentStep],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: const [
                ContactInfoStep(),
                SummaryStep(),
                WorkExperienceStep(),
                EducationStep(),
                SkillsStep(),
                ReviewStep(),
              ],
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _previousStep,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentStep < steps.length - 1)
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar with steps
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    steps.length,
                    (index) => _buildStepButton(index),
                  ),
                ),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Progress
                LinearProgressIndicator(
                  value: (_currentStep + 1) / steps.length,
                  minHeight: 4,
                ),
                // Page view
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: const [
                      ContactInfoStep(),
                      SummaryStep(),
                      WorkExperienceStep(),
                      EducationStep(),
                      SkillsStep(),
                      ReviewStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton(int index) {
    final isActive = _currentStep == index;
    final isCompleted = index < _currentStep;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : isCompleted
                    ? Theme.of(context).colorScheme.surface
                    : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  steps[index],
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
