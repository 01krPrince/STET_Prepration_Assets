import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import 'mock_test_result_screen.dart';

class MockTestSessionScreen extends StatefulWidget {
  final List<Question> questions;
  const MockTestSessionScreen({super.key, required this.questions});

  @override
  State<MockTestSessionScreen> createState() => _MockTestSessionScreenState();
}

class _MockTestSessionScreenState extends State<MockTestSessionScreen> {
  late Map<int, String?> _answers;
  late Set<int> _markedForReview;
  late Set<int> _visited;
  int _current = 0;
  late int _secondsLeft;
  Timer? _timer;

  static const int _durationSeconds = 150 * 60; // 150 minutes, per verified duration

  @override
  void initState() {
    super.initState();
    _answers = {for (int i = 0; i < widget.questions.length; i++) i: null};
    _markedForReview = {};
    _visited = {0};
    _secondsLeft = _durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _submit(auto: true);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _goTo(int i) {
    setState(() {
      _current = i;
      _visited.add(i);
    });
  }

  Future<void> _submit({bool auto = false}) async {
    _timer?.cancel();
    if (!auto) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submit Mock Test?'),
          content: Text(
            'Attempted: ${_answers.values.where((v) => v != null).length} / ${widget.questions.length}\n'
            'You cannot resume this session after submitting.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      );
      if (confirmed != true) {
        _startTimer();
        return;
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MockTestResultScreen(questions: widget.questions, answers: _answers),
      ),
    );
  }

  void _openPalette() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Question Palette', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _legend(AppColors.success, 'Answered'),
                  _legend(AppColors.accent, 'Marked'),
                  _legend(AppColors.border, 'Not visited'),
                  _legend(AppColors.error, 'Visited, unanswered'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: GridView.builder(
                  itemCount: widget.questions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) {
                    Color color = AppColors.border;
                    Color textColor = AppColors.textPrimary;
                    if (_markedForReview.contains(i)) {
                      color = AppColors.accent;
                      textColor = Colors.white;
                    } else if (_answers[i] != null) {
                      color = AppColors.success;
                      textColor = Colors.white;
                    } else if (_visited.contains(i)) {
                      color = AppColors.error;
                      textColor = Colors.white;
                    }
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _goTo(i);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Text('${i + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit mock test?'),
        content: const Text('Your timer and answers for this attempt will be lost. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Exit')),
        ],
      ),
    );
    if (result == true && mounted) {
      _timer?.cancel();
      Navigator.pop(context);
    }
  }

  Widget _legend(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_current];
    final lowTime = _secondsLeft < 300;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _confirmExit),
          title: Text('Q ${_current + 1} / ${widget.questions.length}'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: lowTime ? AppColors.error : Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(_timeLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.grid_view), onPressed: _openPalette),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(q.topic, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      if (_markedForReview.contains(_current)) {
                        _markedForReview.remove(_current);
                      } else {
                        _markedForReview.add(_current);
                      }
                    }),
                    icon: Icon(
                      _markedForReview.contains(_current) ? Icons.flag : Icons.outlined_flag,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    label: Text(
                      _markedForReview.contains(_current) ? 'Marked' : 'Mark for Review',
                      style: const TextStyle(color: AppColors.accent, fontSize: 12),
                    ),
                  ),
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
                      onPressed: () => _goTo(_current - 1),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 8),
                if (_current < widget.questions.length - 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _goTo(_current + 1),
                      child: const Text('Next'),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () => _submit(),
                    child: const Text('Submit'),
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
