import 'package:flutter/material.dart';
import '../models/resume_model.dart';
import '../services/ai_resume_checker.dart';

class UploadedResumeAnalysisScreen extends StatefulWidget {
  final Resume uploadedResume;

  const UploadedResumeAnalysisScreen({
    super.key,
    required this.uploadedResume,
  });

  @override
  State<UploadedResumeAnalysisScreen> createState() =>
      _UploadedResumeAnalysisScreenState();
}

class _UploadedResumeAnalysisScreenState
    extends State<UploadedResumeAnalysisScreen> {
  late List<ResumeCheckResult> _checkResults;
  late double _overallScore;

  @override
  void initState() {
    super.initState();
    _performChecks();
  }

  void _performChecks() {
    final results = AIResumeChecker.performFullCheck(widget.uploadedResume);

    double totalScore = 0;
    for (var result in results) {
      totalScore += result.score;
    }

    setState(() {
      _checkResults = results;
      _overallScore = totalScore / results.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Resume Analysis'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallScoreCard(),
              const SizedBox(height: 32),
              _buildCheckResultsSection(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATS Score',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getScoreColor(_overallScore).withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '${_overallScore.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(_overallScore),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPerformanceLevelMessage(_overallScore),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPerformanceLevelDescription(_overallScore),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume Checks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._checkResults.map((result) => _buildCheckResultCard(result)),
      ],
    );
  }

  Widget _buildCheckResultCard(ResumeCheckResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getScoreColor(result.score).withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  result.score.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(result.score),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.checkName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.passed ? '✓ Passed' : '✗ Needs Improvement',
                    style: TextStyle(
                      fontSize: 12,
                      color: result.passed
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              result.passed ? Icons.check_circle : Icons.warning,
              color: result.passed
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF9800),
              size: 20,
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      result.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.6,
                      ),
                    ),
                  ),
                if (result.feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Feedback: ${result.feedback}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                if (result.recommendation.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Recommendation: ${result.recommendation}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _shareResults(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6200EE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Share Results'),
          ),
        ),
      ],
    );
  }

  void _shareResults() {
    // Placeholder for share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return const Color(0xFF4CAF50);
    if (score >= 70) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getPerformanceLevelMessage(double score) {
    if (score >= 90) return '🚀 Excellent';
    if (score >= 80) return '⭐ Very Good';
    if (score >= 70) return '👍 Good';
    if (score >= 60) return '📝 Fair';
    return '⚠️ Needs Improvement';
  }

  String _getPerformanceLevelDescription(double score) {
    if (score >= 90) {
      return 'Your resume is ATS-optimized and highly competitive!';
    }
    if (score >= 80) {
      return 'Your resume is well-structured. Minor improvements recommended.';
    }
    if (score >= 70) {
      return 'Your resume has good potential. Consider the suggestions.';
    }
    if (score >= 60) {
      return 'Your resume needs some adjustments for better ATS compatibility.';
    }
    return 'Your resume needs significant improvements to be competitive.';
  }
}
