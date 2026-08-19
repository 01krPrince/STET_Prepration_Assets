import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// The core "View Answer" question widget used across Notes->Questions,
/// Practice review, Search results, and Bookmarks. Answer/explanation
/// stay hidden until the user taps to reveal them, per the app's design.
class QuestionViewCard extends StatefulWidget {
  final Question question;
  final int index;
  const QuestionViewCard({super.key, required this.question, this.index = 0});

  @override
  State<QuestionViewCard> createState() => _QuestionViewCardState();
}

class _QuestionViewCardState extends State<QuestionViewCard> {
  bool _revealed = false;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final b = await StorageService.instance.isBookmarked(widget.question.id);
    if (mounted) setState(() => _bookmarked = b);
  }

  Future<void> _toggleBookmark() async {
    final b = await StorageService.instance.toggleBookmark(widget.question.id);
    if (mounted) setState(() => _bookmarked = b);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.difficultyColor(q.difficulty).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    q.difficulty,
                    style: TextStyle(
                      color: AppTheme.difficultyColor(q.difficulty),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    q.type == QuestionType.pyq ? 'PYQ' : 'PRACTICE',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _bookmarked ? AppColors.accent : AppColors.textSecondary,
                  ),
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.index > 0 ? '${widget.index}. ${q.question}' : q.question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 10),
            ...['A', 'B', 'C', 'D'].map((k) {
              final isCorrect = _revealed && k == q.correctAnswer;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.success.withOpacity(0.10) : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect ? AppColors.success : AppColors.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$k. ', style: TextStyle(fontWeight: FontWeight.w700, color: isCorrect ? AppColors.success : AppColors.textPrimary)),
                      Expanded(
                        child: Text(
                          q.options[k] ?? '',
                          style: TextStyle(color: isCorrect ? AppColors.success : AppColors.textPrimary),
                        ),
                      ),
                      if (isCorrect) const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            if (!_revealed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _revealed = true),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View Answer'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correct Answer: ${q.correctAnswer}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(q.explanation, style: const TextStyle(height: 1.4)),
                    if (q.source != null && q.source!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Source: ${q.source}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                    ]
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
