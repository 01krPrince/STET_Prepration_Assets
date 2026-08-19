import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';

/// Post-submission review card: shows the question, the user's selected
/// option (highlighted correct/incorrect), the correct answer, and the
/// explanation — always revealed since the attempt is already complete.
class ReviewAnswerCard extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final int index;
  const ReviewAnswerCard({super.key, required this.question, required this.selectedOption, required this.index});

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedOption == question.correctAnswer;
    final wasSkipped = selectedOption == null;

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
                    color: wasSkipped
                        ? AppColors.textSecondary.withOpacity(0.15)
                        : (isCorrect ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    wasSkipped ? 'SKIPPED' : (isCorrect ? 'CORRECT' : 'WRONG'),
                    style: TextStyle(
                      color: wasSkipped ? AppColors.textSecondary : (isCorrect ? AppColors.success : AppColors.error),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('$index. ${question.question}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.35)),
            const SizedBox(height: 10),
            ...['A', 'B', 'C', 'D'].map((k) {
              final isThisCorrect = k == question.correctAnswer;
              final isThisSelected = k == selectedOption;
              Color bg = AppColors.background;
              Color border = AppColors.border;
              if (isThisCorrect) {
                bg = AppColors.success.withOpacity(0.10);
                border = AppColors.success;
              } else if (isThisSelected && !isCorrect) {
                bg = AppColors.error.withOpacity(0.10);
                border = AppColors.error;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Text('$k. ', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Expanded(child: Text(question.options[k] ?? '')),
                      if (isThisCorrect) const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                      if (isThisSelected && !isThisCorrect) const Icon(Icons.cancel, color: AppColors.error, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
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
                  Text('Correct Answer: ${question.correctAnswer}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Text(question.explanation, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
