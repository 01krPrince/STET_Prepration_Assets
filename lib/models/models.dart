// Core data models for the Bihar STET 2026 Computer Science prep app.
// Kept in a single file intentionally so the data layer is easy to scan
// and easy for Prince to extend when adding more units/questions later.

class ExamInfo {
  final String examName;
  final String conductingBody;
  final String notificationDate;
  final String applicationWindow;
  final String subjectCodeNote;
  final String mode;
  final String paperLanguage;
  final String duration;
  final int totalQuestions;
  final int totalMarks;
  final String sectionAName;
  final int sectionAQuestions;
  final int sectionAMarks;
  final String sectionBName;
  final int sectionBQuestions;
  final int sectionBMarks;
  final String negativeMarking;
  final String syllabusLevel;
  final String verificationStatus;
  final String examDate;

  ExamInfo({
    required this.examName,
    required this.conductingBody,
    required this.notificationDate,
    required this.applicationWindow,
    required this.subjectCodeNote,
    required this.mode,
    required this.paperLanguage,
    required this.duration,
    required this.totalQuestions,
    required this.totalMarks,
    required this.sectionAName,
    required this.sectionAQuestions,
    required this.sectionAMarks,
    required this.sectionBName,
    required this.sectionBQuestions,
    required this.sectionBMarks,
    required this.negativeMarking,
    required this.syllabusLevel,
    required this.verificationStatus,
    required this.examDate,
  });

  factory ExamInfo.fromJson(Map<String, dynamic> j) {
    final a = j['sectionA'] as Map<String, dynamic>;
    final b = j['sectionB'] as Map<String, dynamic>;
    return ExamInfo(
      examName: j['examName'] ?? '',
      conductingBody: j['conductingBody'] ?? '',
      notificationDate: j['notificationDate'] ?? '',
      applicationWindow: j['applicationWindow'] ?? '',
      subjectCodeNote: j['subjectCodeNote'] ?? '',
      mode: j['mode'] ?? '',
      paperLanguage: j['paperLanguage'] ?? '',
      duration: j['duration'] ?? '',
      totalQuestions: j['totalQuestions'] ?? 0,
      totalMarks: j['totalMarks'] ?? 0,
      sectionAName: a['name'] ?? '',
      sectionAQuestions: a['questions'] ?? 0,
      sectionAMarks: a['marks'] ?? 0,
      sectionBName: b['name'] ?? '',
      sectionBQuestions: b['questions'] ?? 0,
      sectionBMarks: b['marks'] ?? 0,
      negativeMarking: j['negativeMarking'] ?? '',
      syllabusLevel: j['syllabusLevel'] ?? '',
      verificationStatus: j['verificationStatus'] ?? '',
      examDate: j['examDate'] ?? '',
    );
  }
}

class SyllabusUnit {
  final String id;
  final String title;
  final String priority;
  final List<String> topics;

  SyllabusUnit({
    required this.id,
    required this.title,
    required this.priority,
    required this.topics,
  });

  factory SyllabusUnit.fromJson(Map<String, dynamic> j) {
    return SyllabusUnit(
      id: j['id'],
      title: j['title'],
      priority: j['priority'] ?? 'MEDIUM PRIORITY',
      topics: List<String>.from(j['topics'] ?? []),
    );
  }
}

class TopicNote {
  final String unitId;
  final String unitTitle;
  final String topicName;
  final String definition;
  final String coreConcept;
  final List<String> importantPoints;
  final String example;
  final List<String> importantFacts;
  final String commonConfusion;
  final List<String> quickRevision;

  TopicNote({
    required this.unitId,
    required this.unitTitle,
    required this.topicName,
    required this.definition,
    required this.coreConcept,
    required this.importantPoints,
    required this.example,
    required this.importantFacts,
    required this.commonConfusion,
    required this.quickRevision,
  });

  factory TopicNote.fromJson(Map<String, dynamic> j) {
    return TopicNote(
      unitId: j['unitId'],
      unitTitle: j['unitTitle'],
      topicName: j['topicName'],
      definition: j['definition'] ?? '',
      coreConcept: j['coreConcept'] ?? '',
      importantPoints: List<String>.from(j['importantPoints'] ?? []),
      example: j['example'] ?? '',
      importantFacts: List<String>.from(j['importantFacts'] ?? []),
      commonConfusion: j['commonConfusion'] ?? '',
      quickRevision: List<String>.from(j['quickRevision'] ?? []),
    );
  }
}

enum QuestionType { original, pyq }

class Question {
  final String id;
  final String unitId;
  final String topic;
  final String question;
  final Map<String, String> options; // keys: A, B, C, D
  final String correctAnswer; // A/B/C/D
  final String explanation;
  final String difficulty; // Easy/Medium/Hard
  final QuestionType type;
  final String? source;

  Question({
    required this.id,
    required this.unitId,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.type,
    this.source,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    return Question(
      id: j['id'],
      unitId: j['unitId'],
      topic: j['topic'] ?? '',
      question: j['question'],
      options: Map<String, String>.from(j['options']),
      correctAnswer: j['correctAnswer'],
      explanation: j['explanation'] ?? '',
      difficulty: j['difficulty'] ?? 'Medium',
      type: (j['type'] == 'pyq') ? QuestionType.pyq : QuestionType.original,
      source: j['source'],
    );
  }
}

// Represents one attempted question inside a practice/mock session.
class AttemptedAnswer {
  final String questionId;
  final String? selectedOption; // null if skipped
  final bool isCorrect;
  final bool markedForReview;

  AttemptedAnswer({
    required this.questionId,
    required this.selectedOption,
    required this.isCorrect,
    this.markedForReview = false,
  });
}

// A completed practice or mock test session, stored locally for Progress screen.
class SessionResult {
  final String id;
  final String type; // 'practice' or 'mock'
  final String label;
  final DateTime completedAt;
  final int totalQuestions;
  final int attempted;
  final int correct;
  final int wrong;

  SessionResult({
    required this.id,
    required this.type,
    required this.label,
    required this.completedAt,
    required this.totalQuestions,
    required this.attempted,
    required this.correct,
    required this.wrong,
  });

  double get accuracy => attempted == 0 ? 0 : (correct / attempted) * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'label': label,
        'completedAt': completedAt.toIso8601String(),
        'totalQuestions': totalQuestions,
        'attempted': attempted,
        'correct': correct,
        'wrong': wrong,
      };

  factory SessionResult.fromJson(Map<String, dynamic> j) => SessionResult(
        id: j['id'],
        type: j['type'],
        label: j['label'],
        completedAt: DateTime.parse(j['completedAt']),
        totalQuestions: j['totalQuestions'],
        attempted: j['attempted'],
        correct: j['correct'],
        wrong: j['wrong'],
      );
}
