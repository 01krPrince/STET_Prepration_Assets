import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../widgets/review_answer_card.dart';
import '../home/home_screen.dart';

class PracticeResultScreen extends StatefulWidget {
  final List<Question> questions;
  final Map<int, String?> answers;
  final String label;
  const PracticeResultScreen({super.key, required this.questions, required this.answers, required this.label});

  @override
  State<PracticeResultScreen> createState() => _PracticeResultScreenState();
}

class _PracticeResultScreenState extends State<PracticeResultScreen> {
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
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      type: 'practice',
      label: widget.label,
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
    for (int i = 0; i < total; i++) {
      final selected = widget.answers[i];
      if (selected == null) continue;
      attempted++;
      if (selected == widget.questions[i].correctAnswer) {
        correct++;
      } else {
        wrong++;
      }
    }
    final accuracy = attempted == 0 ? 0.0 : (correct / attempted) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Result'),
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
                Text(widget.label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('${accuracy.round()}%', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
                const Text('Accuracy', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('$total', 'Total'),
                    _stat('$attempted', 'Attempted'),
                    _stat('$correct', 'Correct', color: AppColors.success),
                    _stat('$wrong', 'Wrong', color: AppColors.error),
                  ],
                ),
              ],
            ),
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
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}
