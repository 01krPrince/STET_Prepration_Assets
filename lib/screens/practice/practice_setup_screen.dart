import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../repositories/content_repository.dart';
import 'practice_session_screen.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  String? _selectedUnitId;
  String _selectedTopic = 'All Topics';
  int _count = 10;

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository.instance;
    final units = repo.units;
    final topics = _selectedUnitId == null
        ? <String>[]
        : repo.topicsInUnitQuestions(_selectedUnitId!);
    final availableCount = repo
        .buildPracticeSet(unitId: _selectedUnitId, topic: _selectedTopic, count: 99999)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Mode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Unit', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _selectedUnitId,
                  hint: const Text('All Units'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Units')),
                    ...units.map((u) => DropdownMenuItem(value: u.id, child: Text(u.title))),
                  ],
                  onChanged: (v) => setState(() {
                    _selectedUnitId = v;
                    _selectedTopic = 'All Topics';
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Topic', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedTopic,
                  items: [
                    const DropdownMenuItem(value: 'All Topics', child: Text('All Topics')),
                    ...topics.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                  ],
                  onChanged: _selectedUnitId == null
                      ? null
                      : (v) => setState(() => _selectedTopic = v ?? 'All Topics'),
                ),
              ),
            ),
          ),
          if (_selectedUnitId == null)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Select a unit to filter by topic.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          const SizedBox(height: 18),
          const Text('Number of Questions', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [10, 20, 30, 50].map((n) {
              final selected = _count == n;
              return ChoiceChip(
                label: Text('$n'),
                selected: selected,
                onSelected: (_) => setState(() => _count = n),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '$availableCount question(s) available with this filter.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: availableCount == 0
                  ? null
                  : () {
                      final set = repo.buildPracticeSet(
                        unitId: _selectedUnitId,
                        topic: _selectedTopic,
                        count: _count,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeSessionScreen(
                            questions: set,
                            label: _selectedUnitId == null
                                ? 'Practice • All Units'
                                : 'Practice • ${repo.unitById(_selectedUnitId!).title}',
                          ),
                        ),
                      );
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Start Practice'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
