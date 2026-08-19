import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../repositories/content_repository.dart';

class QuickRevisionScreen extends StatelessWidget {
  const QuickRevisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final units = ContentRepository.instance.units;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Revision')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: units.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = units[i];
          final notesCount = ContentRepository.instance.notesForUnit(u.id).length;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.bolt, color: AppColors.accent),
              title: Text(u.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('$notesCount revision block(s)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnitRevisionScreen(unit: u))),
            ),
          );
        },
      ),
    );
  }
}

class UnitRevisionScreen extends StatelessWidget {
  final SyllabusUnit unit;
  const UnitRevisionScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final notes = ContentRepository.instance.notesForUnit(unit.id);
    return Scaffold(
      appBar: AppBar(title: Text('${unit.title} • Revision', overflow: TextOverflow.ellipsis)),
      body: notes.isEmpty
          ? const Center(child: Text('Revision content for this unit is coming soon.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = notes[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.topicName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: n.quickRevision
                              .map((r) => Chip(
                                    label: Text(r, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: AppColors.accentSoft,
                                  ))
                              .toList(),
                        ),
                        if (n.importantFacts.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Text('Key Facts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          ...n.importantFacts.map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $f', style: const TextStyle(fontSize: 12.5, height: 1.35)),
                              )),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
