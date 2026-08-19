import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Everything the user does locally (progress, bookmarks, session history,
/// profile name) is persisted with shared_preferences — no server, no
/// account, per the app's offline-first / local-profile design.
class StorageService {
  StorageService._internal();
  static final StorageService instance = StorageService._internal();

  static const _kProfileName = 'profile_name';
  static const _kBookmarks = 'bookmarked_question_ids';
  static const _kAttemptedCorrect = 'attempted_correct_ids';
  static const _kAttemptedWrong = 'attempted_wrong_ids';
  static const _kSessions = 'session_history';
  static const _kCompletedTopics = 'completed_topics';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------- Profile ----------

  Future<String> getProfileName() async {
    final p = await _p;
    return p.getString(_kProfileName) ?? 'Prince Kumar';
  }

  Future<void> setProfileName(String name) async {
    final p = await _p;
    await p.setString(_kProfileName, name);
  }

  // ---------- Bookmarks ----------

  Future<Set<String>> getBookmarks() async {
    final p = await _p;
    return (p.getStringList(_kBookmarks) ?? []).toSet();
  }

  Future<bool> toggleBookmark(String questionId) async {
    final p = await _p;
    final set = (p.getStringList(_kBookmarks) ?? []).toSet();
    bool nowBookmarked;
    if (set.contains(questionId)) {
      set.remove(questionId);
      nowBookmarked = false;
    } else {
      set.add(questionId);
      nowBookmarked = true;
    }
    await p.setStringList(_kBookmarks, set.toList());
    return nowBookmarked;
  }

  Future<bool> isBookmarked(String questionId) async {
    final set = await getBookmarks();
    return set.contains(questionId);
  }

  // ---------- Attempt tracking (for accuracy + progress dashboard) ----------

  Future<void> recordAttempts(List<AttemptedAnswer> answers) async {
    final p = await _p;
    final correct = (p.getStringList(_kAttemptedCorrect) ?? []).toSet();
    final wrong = (p.getStringList(_kAttemptedWrong) ?? []).toSet();
    for (final a in answers) {
      if (a.selectedOption == null) continue; // skipped, not attempted
      if (a.isCorrect) {
        correct.add(a.questionId);
        wrong.remove(a.questionId);
      } else {
        wrong.add(a.questionId);
        correct.remove(a.questionId);
      }
    }
    await p.setStringList(_kAttemptedCorrect, correct.toList());
    await p.setStringList(_kAttemptedWrong, wrong.toList());
  }

  /// Returns the raw sets of attempted question IDs, split by outcome.
  /// Used by the Progress screen to compute a per-unit breakdown by
  /// cross-referencing each ID against ContentRepository.
  Future<({Set<String> correct, Set<String> wrong})> getAttemptedIds() async {
    final p = await _p;
    final correct = (p.getStringList(_kAttemptedCorrect) ?? []).toSet();
    final wrong = (p.getStringList(_kAttemptedWrong) ?? []).toSet();
    return (correct: correct, wrong: wrong);
  }

  Future<Map<String, int>> getOverallStats() async {
    final p = await _p;
    final correct = (p.getStringList(_kAttemptedCorrect) ?? []).length;
    final wrong = (p.getStringList(_kAttemptedWrong) ?? []).length;
    return {
      'attempted': correct + wrong,
      'correct': correct,
      'wrong': wrong,
    };
  }

  // ---------- Session history (practice + mock results) ----------

  Future<void> saveSession(SessionResult result) async {
    final p = await _p;
    final raw = p.getStringList(_kSessions) ?? [];
    raw.insert(0, json.encode(result.toJson()));
    if (raw.length > 100) raw.removeRange(100, raw.length);
    await p.setStringList(_kSessions, raw);
  }

  Future<List<SessionResult>> getSessions() async {
    final p = await _p;
    final raw = p.getStringList(_kSessions) ?? [];
    return raw
        .map((s) => SessionResult.fromJson(json.decode(s)))
        .toList();
  }

  // ---------- Completed topics (for "Continue Study" / preparation %) ----------

  Future<Set<String>> getCompletedTopics() async {
    final p = await _p;
    return (p.getStringList(_kCompletedTopics) ?? []).toSet();
  }

  Future<void> markTopicCompleted(String topicKey) async {
    final p = await _p;
    final set = (p.getStringList(_kCompletedTopics) ?? []).toSet();
    set.add(topicKey);
    await p.setStringList(_kCompletedTopics, set.toList());
  }
}
