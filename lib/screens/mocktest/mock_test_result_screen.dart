import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../widgets/review_answer_card.dart';
import '../home/home_screen.dart';

class MockTestResultScreen extends StatefulWidget {
  final List<Question> questions;
  final Map<int, String?> answers;
  const MockTestResultScreen({super.key, required this.questions, required this.answers});

  @override
  State<MockTestResultScreen> createState() => _MockTestResultScreenState();
}

class _MockTestResultScreenState extends State<MockTestResultScreen> {
  bool _showReview = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    if (_saved) return;
    _saved = true;
    final attempts = <AttemptedAnswer>[];
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final selected = widget.answers[i];
      attempts.add(AttemptedAnswer(
        questionId: q.id,
        selectedOption: selected,
        isCorrect: selected == q.correctAnswer,
      ));
    }
    await StorageService.instance.recordAttempts(attempts);

    final total = widget.questions.length;
    final attempted = attempts.where((a) => a.selectedOption != null).length;
    final correct = attempts.where((a) => a.isCorrect).length;
    await StorageService.instance.saveSession(SessionResult(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      type: 'mock',
      label: 'Full Mock Test',
      completedAt: DateTime.now(),
      totalQuestions: total,
      attempted: attempted,
      correct: correct,
      wrong: attempted - correct,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    int correct = 0, wrong = 0, attempted = 0;
    int csCorrect = 0, csAttempted = 0, csTotal = 0;
    int teachCorrect = 0, teachAttempted = 0, teachTotal = 0;

    for (int i = 0; i < total; i++) {
      final q = widget.questions[i];
      final isTeaching = q.unitId == 'teaching';
      if (isTeaching) {
        teachTotal++;
      } else {
        csTotal++;
      }
      final selected = widget.answers[i];
      if (selected == null) continue;
      attempted++;
      final isCorrect = selected == q.correctAnswer;
      if (isCorrect) correct++; else wrong++;
      if (isTeaching) {
        teachAttempted++;
        if (isCorrect) teachCorrect++;
      } else {
        csAttempted++;
        if (isCorrect) csCorrect++;
      }
    }
    final accuracy = attempted == 0 ? 0.0 : (correct / attempted) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Test Result'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text('$correct / $total', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                const Text('Score', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('${accuracy.round()}%', 'Accuracy'),
                    _stat('$attempted', 'Attempted'),
                    _stat('$wrong', 'Wrong', color: AppColors.error),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _sectionCard('Computer Science', csCorrect, csAttempted, csTotal)),
              const SizedBox(width: 10),
              Expanded(child: _sectionCard('Teaching Aptitude', teachCorrect, teachAttempted, teachTotal)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showReview = !_showReview),
              icon: Icon(_showReview ? Icons.expand_less : Icons.expand_more),
              label: Text(_showReview ? 'Hide Review' : 'Review Answers'),
            ),
          ),
          if (_showReview) ...[
            const SizedBox(height: 12),
            ...List.generate(total, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ReviewAnswerCard(
                  question: widget.questions[i],
                  selectedOption: widget.answers[i],
                  index: i + 1,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _stat(String value, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _sectionCard(String title, int correct, int attempted, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 6),
            Text('$correct / $total', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
            Text('$attempted attempted', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
