import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import 'practice_result_screen.dart';

class PracticeSessionScreen extends StatefulWidget {
  final List<Question> questions;
  final String label;
  const PracticeSessionScreen({super.key, required this.questions, required this.label});

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  late Map<int, String?> _answers;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _answers = {for (int i = 0; i < widget.questions.length; i++) i: null};
  }

  void _submit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeResultScreen(
          questions: widget.questions,
          answers: _answers,
          label: widget.label,
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit practice?'),
        content: const Text('Your progress in this session will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Exit')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_current];
    final attempted = _answers.values.where((v) => v != null).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Q ${_current + 1} of ${widget.questions.length}'),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / widget.questions.length,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.difficultyColor(q.difficulty).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(q.difficulty, style: TextStyle(color: AppTheme.difficultyColor(q.difficulty), fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Text(q.topic, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  Text('$attempted/${widget.questions.length} attempted', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(q.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4)),
                  const SizedBox(height: 16),
                  ...['A', 'B', 'C', 'D'].map((k) {
                    final selected = _answers[_current] == k;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _answers[_current] = k),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.6 : 1),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: selected ? AppColors.primary : AppColors.background,
                                child: Text(k, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(q.options[k] ?? '', style: const TextStyle(height: 1.3))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (_current > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _current -= 1),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _current < widget.questions.length - 1
                        ? () => setState(() => _current += 1)
                        : _submit,
                    child: Text(_current < widget.questions.length - 1 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
