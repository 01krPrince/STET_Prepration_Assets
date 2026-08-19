import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../repositories/content_repository.dart';
import '../../services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _loading = true;
  Map<String, int> _overall = {'attempted': 0, 'correct': 0, 'wrong': 0};
  List<SessionResult> _sessions = [];
  List<_UnitStat> _unitStats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final overall = await StorageService.instance.getOverallStats();
    final sessions = await StorageService.instance.getSessions();
    final ids = await StorageService.instance.getAttemptedIds();

    final repo = ContentRepository.instance;
    final stats = <String, _UnitStat>{};
    for (final u in repo.units) {
      stats[u.id] = _UnitStat(unitTitle: u.title, totalQuestions: repo.questionCountForUnit(u.id));
    }
    for (final id in ids.correct) {
      final q = repo.questionById(id);
      if (q != null && stats.containsKey(q.unitId)) stats[q.unitId]!.correct++;
    }
    for (final id in ids.wrong) {
      final q = repo.questionById(id);
      if (q != null && stats.containsKey(q.unitId)) stats[q.unitId]!.wrong++;
    }

    if (mounted) {
      setState(() {
        _overall = overall;
        _sessions = sessions;
        _unitStats = stats.values.where((s) => s.totalQuestions > 0).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attempted = _overall['attempted'] ?? 0;
    final correct = _overall['correct'] ?? 0;
    final wrong = _overall['wrong'] ?? 0;
    final accuracy = attempted == 0 ? 0.0 : (correct / attempted) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _statCard('$attempted', 'Attempted', AppColors.primary)),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard('$correct', 'Correct', AppColors.success)),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard('$wrong', 'Wrong', AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _statCard('${accuracy.round()}%', 'Overall Accuracy', AppColors.accent, wide: true),
                  const SizedBox(height: 24),
                  const Text('Unit-wise Coverage', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  ..._unitStats.map((s) {
                    final done = s.correct + s.wrong;
                    final pct = s.totalQuestions == 0 ? 0.0 : done / s.totalQuestions;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(s.unitTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                              Text('$done/${s.totalQuestions}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Text('Session History', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  if (_sessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No practice or mock test sessions yet.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ..._sessions.take(20).map((s) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              s.type == 'mock' ? Icons.timer_outlined : Icons.fact_check_outlined,
                              color: AppColors.primary,
                            ),
                            title: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text(
                              '${s.correct}/${s.totalQuestions} correct • ${s.accuracy.round()}% accuracy\n${_formatDate(s.completedAt)}',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            isThreeLine: true,
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Widget _statCard(String value, String label, Color color, {bool wide = false}) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _UnitStat {
  final String unitTitle;
  final int totalQuestions;
  int correct = 0;
  int wrong = 0;
  _UnitStat({required this.unitTitle, required this.totalQuestions});
}
