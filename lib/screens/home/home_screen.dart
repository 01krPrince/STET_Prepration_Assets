import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../repositories/content_repository.dart';
import '../../services/storage_service.dart';
import '../syllabus/syllabus_screen.dart';
import '../practice/practice_setup_screen.dart';
import '../mocktest/mock_test_screen.dart';
import '../revision/quick_revision_screen.dart';
import '../pdflibrary/pdf_library_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../progress/progress_screen.dart';
import '../search/search_screen.dart';
import '../about/about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  Map<String, int> _stats = {'attempted': 0, 'correct': 0, 'wrong': 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await StorageService.instance.getProfileName();
    final stats = await StorageService.instance.getOverallStats();
    if (mounted) setState(() {
      _name = name;
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository.instance;
    final totalQuestions = repo.csQuestions.length + repo.teachingQuestions.length;
    final attempted = _stats['attempted'] ?? 0;
    final correct = _stats['correct'] ?? 0;
    final accuracy = attempted == 0 ? 0.0 : (correct / attempted) * 100;
    final prepPct = totalQuestions == 0 ? 0.0 : (attempted / totalQuestions).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIHAR STET 2026'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _name.isEmpty ? 'Welcome' : 'Welcome, ${_name.split(' ').first}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Text(
              'Paper 2 • Computer Science • Offline Prep',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _PrepCard(prepPct: prepPct, attempted: attempted, totalQuestions: totalQuestions, accuracy: accuracy),
            const SizedBox(height: 20),
            const Text('Study', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.92,
              children: [
                _Tile(icon: Icons.menu_book_outlined, label: 'Syllabus', onTap: () => _openSyllabus(context)),
                _Tile(icon: Icons.description_outlined, label: 'Notes', onTap: () => _openSyllabus(context)),
                _Tile(icon: Icons.quiz_outlined, label: 'Questions', onTap: () => _openSyllabus(context)),
                _Tile(icon: Icons.bolt_outlined, label: 'Quick\nRevision', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickRevisionScreen()))),
                _Tile(icon: Icons.picture_as_pdf_outlined, label: 'PDF\nLibrary', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfLibraryScreen()))),
                _Tile(icon: Icons.bookmark_outline, label: 'Bookmarks', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Test Yourself', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _WideAction(
                    icon: Icons.fact_check_outlined,
                    title: 'Practice Mode',
                    subtitle: 'Pick a unit & topic',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticeSetupScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WideAction(
                    icon: Icons.timer_outlined,
                    title: 'Mock Test',
                    subtitle: 'Full-length, timed',
                    color: AppColors.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockTestScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('More', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.insights_outlined, color: AppColors.primary),
                    title: const Text('Progress Dashboard'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.primary),
                    title: const Text('About & Exam Info'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openSyllabus(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SyllabusScreen()));
  }
}

class _PrepCard extends StatelessWidget {
  final double prepPct;
  final int attempted;
  final int totalQuestions;
  final double accuracy;
  const _PrepCard({required this.prepPct, required this.attempted, required this.totalQuestions, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preparation Progress', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: prepPct,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBlock('${(prepPct * 100).round()}%', 'Coverage'),
              _statBlock('$attempted/$totalQuestions', 'Attempted'),
              _statBlock('${accuracy.round()}%', 'Accuracy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBlock(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _WideAction({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
