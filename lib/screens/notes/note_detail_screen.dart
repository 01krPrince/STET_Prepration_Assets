import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../repositories/content_repository.dart';
import '../../widgets/question_view_card.dart';

class NoteDetailScreen extends StatelessWidget {
  final TopicNote note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final relatedQuestions = ContentRepository.instance
        .questionsForUnit(note.unitId)
        .where((q) => q.topic.toLowerCase().contains(note.topicName.split(' ').first.toLowerCase()) ||
            note.topicName.toLowerCase().contains(q.topic.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(note.topicName, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(note.unitTitle, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _SectionCard(title: 'Definition', child: Text(note.definition, style: const TextStyle(height: 1.5))),
          _SectionCard(title: 'Core Concept', child: Text(note.coreConcept, style: const TextStyle(height: 1.5))),
          _SectionCard(
            title: 'Important Points',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: note.importantPoints.map((p) => _bullet(p)).toList(),
            ),
          ),
          _SectionCard(
            title: 'Example',
            accent: true,
            child: Text(note.example, style: const TextStyle(height: 1.5, fontStyle: FontStyle.italic)),
          ),
          _SectionCard(
            title: 'Important Facts',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: note.importantFacts.map((p) => _bullet(p)).toList(),
            ),
          ),
          _SectionCard(
            title: 'Common Confusion',
            warn: true,
            child: Text(note.commonConfusion, style: const TextStyle(height: 1.5)),
          ),
          _SectionCard(
            title: 'Quick Revision',
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: note.quickRevision
                  .map((r) => Chip(label: Text(r, style: const TextStyle(fontSize: 11))))
                  .toList(),
            ),
          ),
          if (relatedQuestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Practice on this topic', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            ...relatedQuestions.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: QuestionViewCard(question: e.value, index: e.key + 1),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.circle, size: 5, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
          ],
        ),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool accent;
  final bool warn;
  const _SectionCard({required this.title, required this.child, this.accent = false, this.warn = false});

  @override
  Widget build(BuildContext context) {
    final color = warn ? AppColors.error : (accent ? AppColors.accent : AppColors.primary);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 16, color: color, margin: const EdgeInsets.only(right: 8)),
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                ],
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
