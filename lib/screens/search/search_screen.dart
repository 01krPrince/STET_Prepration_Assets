import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../repositories/content_repository.dart';
import '../../widgets/question_view_card.dart';
import '../notes/note_detail_screen.dart';
import '../syllabus/syllabus_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, String>> _results = [];

  void _onChanged(String q) {
    setState(() => _results = ContentRepository.instance.search(q));
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'Note':
        return Icons.description_outlined;
      case 'Question':
        return Icons.quiz_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  void _onTapResult(Map<String, String> r) {
    final repo = ContentRepository.instance;
    if (r['type'] == 'Unit') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => UnitDetailScreen(unit: repo.unitById(r['unitId']!))));
    } else if (r['type'] == 'Note') {
      final note = repo.notesForUnit(r['unitId']!).firstWhere((n) => n.topicName == r['refId']);
      Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)));
    } else if (r['type'] == 'Question') {
      final q = repo.questionById(r['refId']!);
      if (q == null) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Question')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [QuestionViewCard(question: q)],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search topics, notes, questions...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _controller.text.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Search works fully offline across all bundled notes, questions and units.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          : _results.isEmpty
              ? const Center(child: Text('No results found.', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final r = _results[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(_iconFor(r['type']!), color: AppColors.primary),
                        title: Text(r['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        subtitle: Text('${r['type']} • ${r['subtitle']}', style: const TextStyle(fontSize: 11.5)),
                        onTap: () => _onTapResult(r),
                      ),
                    );
                  },
                ),
    );
  }
}
