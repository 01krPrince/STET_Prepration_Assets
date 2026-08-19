import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../repositories/content_repository.dart';
import '../../services/storage_service.dart';
import '../../widgets/question_view_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Question> _bookmarked = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ids = await StorageService.instance.getBookmarks();
    final questions = ids
        .map((id) => ContentRepository.instance.questionById(id))
        .whereType<Question>()
        .toList();
    if (mounted) {
      setState(() {
        _bookmarked = questions;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarked.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('No bookmarks yet.\nTap the bookmark icon on any question to save it here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookmarked.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => QuestionViewCard(question: _bookmarked[i], index: i + 1),
                  ),
                ),
    );
  }
}
