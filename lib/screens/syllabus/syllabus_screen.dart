import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../repositories/content_repository.dart';
import '../../widgets/question_view_card.dart';
import '../notes/note_detail_screen.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  Color _priorityColor(String p) {
    if (p.contains('MUST')) return AppColors.error;
    if (p.contains('HIGH')) return AppColors.accent;
    if (p.contains('LOW')) return AppColors.textSecondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final units = ContentRepository.instance.units;
    return Scaffold(
      appBar: AppBar(title: const Text('Syllabus & Units')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: units.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = units[i];
          final qCount = ContentRepository.instance.questionCountForUnit(u.id);
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: AppColors.accentSoft,
                child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              title: Text(u.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 6,
                  children: [
                    Chip(
                      label: Text(u.priority, style: TextStyle(color: _priorityColor(u.priority))),
                      backgroundColor: _priorityColor(u.priority).withOpacity(0.10),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text('$qCount Qs'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnitDetailScreen(unit: u))),
            ),
          );
        },
      ),
    );
  }
}

class UnitDetailScreen extends StatelessWidget {
  final SyllabusUnit unit;
  const UnitDetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(unit.title, overflow: TextOverflow.ellipsis),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Topics'),
              Tab(text: 'Notes'),
              Tab(text: 'Questions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TopicsTab(unit: unit),
            _NotesTab(unit: unit),
            _QuestionsTab(unit: unit),
          ],
        ),
      ),
    );
  }
}

class _TopicsTab extends StatelessWidget {
  final SyllabusUnit unit;
  const _TopicsTab({required this.unit});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unit.topics.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(Icons.circle, size: 7, color: AppColors.accent),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(unit.topics[i], style: const TextStyle(height: 1.4))),
          ],
        ),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final SyllabusUnit unit;
  const _NotesTab({required this.unit});

  @override
  Widget build(BuildContext context) {
    final notes = ContentRepository.instance.notesForUnit(unit.id);
    if (notes.isEmpty) {
      return const Center(child: Text('Notes for this unit are coming in the next update.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final n = notes[i];
        return Card(
          child: ListTile(
            title: Text(n.topicName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(n.definition, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: n))),
          ),
        );
      },
    );
  }
}

class _QuestionsTab extends StatelessWidget {
  final SyllabusUnit unit;
  const _QuestionsTab({required this.unit});

  @override
  Widget build(BuildContext context) {
    final questions = ContentRepository.instance.questionsForUnit(unit.id);
    if (questions.isEmpty) {
      return const Center(child: Text('Questions for this unit are coming in the next update.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => QuestionViewCard(question: questions[i], index: i + 1),
    );
  }
}
