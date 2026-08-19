import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

/// Loads all bundled offline study content once at app startup and serves
/// it to every screen. Everything here runs from local JSON assets — no
/// network calls — so the app works fully offline after install.
class ContentRepository {
  ContentRepository._internal();
  static final ContentRepository instance = ContentRepository._internal();

  late ExamInfo examInfo;
  late List<SyllabusUnit> units;
  late List<TopicNote> notes;
  late List<Question> csQuestions;
  late List<Question> teachingQuestions;
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    final syllabusRaw = await rootBundle.loadString('assets/data/syllabus.json');
    final syllabusJson = json.decode(syllabusRaw) as Map<String, dynamic>;
    examInfo = ExamInfo.fromJson(syllabusJson['examInfo']);
    units = (syllabusJson['units'] as List)
        .map((e) => SyllabusUnit.fromJson(e))
        .toList();

    final notesRaw = await rootBundle.loadString('assets/data/notes.json');
    notes = (json.decode(notesRaw) as List)
        .map((e) => TopicNote.fromJson(e))
        .toList();

    final qRaw = await rootBundle.loadString('assets/data/questions.json');
    csQuestions =
        (json.decode(qRaw) as List).map((e) => Question.fromJson(e)).toList();

    final tRaw = await rootBundle.loadString('assets/data/teaching_aptitude.json');
    teachingQuestions =
        (json.decode(tRaw) as List).map((e) => Question.fromJson(e)).toList();

    _loaded = true;
  }

  // ---------- Lookups ----------

  SyllabusUnit unitById(String id) => units.firstWhere((u) => u.id == id);

  List<TopicNote> notesForUnit(String unitId) =>
      notes.where((n) => n.unitId == unitId).toList();

  List<Question> questionsForUnit(String unitId) =>
      csQuestions.where((q) => q.unitId == unitId).toList();

  List<Question> questionsForTopic(String unitId, String topic) => csQuestions
      .where((q) => q.unitId == unitId && q.topic == topic)
      .toList();

  List<String> topicsInUnitQuestions(String unitId) {
    final set = <String>{};
    for (final q in csQuestions.where((q) => q.unitId == unitId)) {
      set.add(q.topic);
    }
    return set.toList();
  }

  int questionCountForUnit(String unitId) =>
      csQuestions.where((q) => q.unitId == unitId).length;

  List<Question> get allQuestions => csQuestions;

  Question? questionById(String id) {
    try {
      return csQuestions.firstWhere((q) => q.id == id);
    } catch (_) {
      try {
        return teachingQuestions.firstWhere((q) => q.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Builds a practice set: filter by unit (optional) and topic (optional),
  /// shuffle, then cap to [count]. If fewer questions exist than requested,
  /// returns everything available (no fake padding).
  List<Question> buildPracticeSet({
    String? unitId,
    String? topic,
    required int count,
  }) {
    List<Question> pool = List.from(csQuestions);
    if (unitId != null) pool = pool.where((q) => q.unitId == unitId).toList();
    if (topic != null && topic != 'All Topics') {
      pool = pool.where((q) => q.topic == topic).toList();
    }
    pool.shuffle(Random());
    if (pool.length <= count) return pool;
    return pool.sublist(0, count);
  }

  /// Full-length mock: every available CS question + every available
  /// Teaching Aptitude question, in randomized order. The official pattern
  /// is 100+50=150; this app currently ships fewer authored questions than
  /// that (see examInfo.verificationStatus / About screen for details),
  /// so the mock uses everything currently available rather than padding
  /// with repeats.
  List<Question> buildFullMock() {
    final all = <Question>[...csQuestions, ...teachingQuestions];
    all.shuffle(Random());
    return all;
  }

  // ---------- Search ----------

  List<Map<String, String>> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    final results = <Map<String, String>>[];

    for (final n in notes) {
      if (n.topicName.toLowerCase().contains(q) ||
          n.definition.toLowerCase().contains(q) ||
          n.coreConcept.toLowerCase().contains(q)) {
        results.add({
          'type': 'Note',
          'title': n.topicName,
          'subtitle': n.unitTitle,
          'unitId': n.unitId,
          'refId': n.topicName,
        });
      }
    }
    for (final qn in csQuestions) {
      if (qn.question.toLowerCase().contains(q) ||
          qn.topic.toLowerCase().contains(q)) {
        results.add({
          'type': 'Question',
          'title': qn.question,
          'subtitle': '${unitById(qn.unitId).title} • ${qn.topic}',
          'unitId': qn.unitId,
          'refId': qn.id,
        });
      }
    }
    for (final u in units) {
      if (u.title.toLowerCase().contains(q)) {
        results.add({
          'type': 'Unit',
          'title': u.title,
          'subtitle': u.priority,
          'unitId': u.id,
          'refId': u.id,
        });
      }
    }
    return results.take(60).toList();
  }
}
