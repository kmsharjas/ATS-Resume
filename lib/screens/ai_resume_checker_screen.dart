import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../services/ai_resume_checker.dart';

class AIResumeCheckerScreen extends StatefulWidget {
  const AIResumeCheckerScreen({Key? key}) : super(key: key);

  @override
  State<AIResumeCheckerScreen> createState() => _AIResumeCheckerScreenState();
}

class _AIResumeCheckerScreenState extends State<AIResumeCheckerScreen> {
  late List<ResumeCheckResult> _checkResults;

  @override
  void initState() {
    super.initState();
    final resume = context.read<ResumeProvider>().resume;
    _checkResults = AIResumeChecker.performFullCheck(resume);
  }

  @override
  Widget build(BuildContext context) {
    final passedChecks = _checkResults.where((r) => r.passed).length;
    final totalChecks = _checkResults.length;
    final overallScore =
        _checkResults.fold(0.0, (sum, r) => sum + r.score) / totalChecks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Resume Checker'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Score Card
              _buildOverallScoreCard(
                  context, passedChecks, totalChecks, overallScore),
              const SizedBox(height: 32),

              // Performance Level
              _buildPerformanceLevel(context, overallScore),
              const SizedBox(height: 32),

              // Check Results
              Text(
                '16 Crucial Checks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ..._checkResults.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final result = entry.value;
                return _buildCheckResultCard(context, index, result);
              }).toList(),

              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareReport(),
                  icon: const Icon(Icons.share),
                  label: const Text('Share Check Results'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(
    BuildContext context,
    int passed,
    int total,
    double score,
  ) {
    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getScoreColor(score).withOpacity(0.1),
              _getScoreColor(score).withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Resume Score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${score.toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(score),
                              ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$passed/$total Checks Passed',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getScoreColor(score).withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      '${score.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor:
                    AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceLevel(BuildContext context, double score) {
    final level = _getPerformanceLevel(score);
    final icon = _getPerformanceLevelIcon(level);
    final message = _getPerformanceLevelMessage(score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getScoreColor(score).withOpacity(0.15),
        border: Border.all(color: _getScoreColor(score), width: 2),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckResultCard(
    BuildContext context,
    int index,
    ResumeCheckResult result,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: result.passed ? Colors.green : Colors.orange,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.checkName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.feedback,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: result.passed ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${result.score.toStringAsFixed(0)}/100',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Feedback',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.feedback,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recommendation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          result.recommendation,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
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

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceLevel(double score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Improvement';
  }

  String _getPerformanceLevelIcon(String level) {
    switch (level) {
      case 'Excellent!':
        return '🚀';
      case 'Very Good':
        return '⭐';
      case 'Good':
        return '👍';
      case 'Fair':
        return '📝';
      default:
        return '⚠️';
    }
  }

  String _getPerformanceLevelMessage(double score) {
    if (score >= 90)
      return 'Your resume is in excellent shape! Ready for top companies.';
    if (score >= 80)
      return 'Your resume is strong and likely to get callbacks.';
    if (score >= 70)
      return 'Your resume is good. Consider addressing highlighted areas.';
    if (score >= 60)
      return 'Your resume needs improvement. Focus on weak areas.';
    return 'Your resume needs significant work. Address all recommendations.';
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Report copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
