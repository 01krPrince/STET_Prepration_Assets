import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../repositories/content_repository.dart';
import 'mock_test_session_screen.dart';

class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository.instance;
    final info = repo.examInfo;
    final availableCs = repo.csQuestions.length;
    final availableTeaching = repo.teachingQuestions.length;
    final availableTotal = availableCs + availableTeaching;

    return Scaffold(
      appBar: AppBar(title: const Text('Mock Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Official Pattern', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  _row('Total Questions', '${info.totalQuestions} (${info.sectionAQuestions} CS + ${info.sectionBQuestions} Teaching)'),
                  _row('Total Marks', '${info.totalMarks}'),
                  _row('Duration', info.duration),
                  _row('Negative Marking', info.negativeMarking),
                  const Divider(height: 20),
                  const Text('This App Currently Includes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  _row('Computer Science Qs', '$availableCs'),
                  _row('Teaching Aptitude Qs', '$availableTeaching'),
                  _row('Total Available', '$availableTotal'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'The full mock uses every question currently in the app rather than repeating '
                      'questions to artificially reach 150 — the question bank will keep growing toward '
                      'full parity with the official pattern in future updates.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Full Mock Test'),
              onPressed: () {
                final set = repo.buildFullMock();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MockTestSessionScreen(questions: set)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
