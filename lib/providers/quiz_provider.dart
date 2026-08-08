import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../services/question_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int? selectedIndex;
  final bool isAnswered;
  final int correctAnswers;
  final int timeRemaining; 
  final String difficulty;

  QuizState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.selectedIndex,
    this.isAnswered = false,
    this.correctAnswers = 0,
    this.timeRemaining = 0, // NEW: Default 0
    required this.difficulty,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? score,
    int? selectedIndex,
    bool? isAnswered,
    int? correctAnswers,
    int? timeRemaining, // NEW: Add to copyWith
    String? difficulty,
    bool resetSelectedIndex = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      selectedIndex:
          resetSelectedIndex ? null : (selectedIndex ?? this.selectedIndex),
      isAnswered: isAnswered ?? this.isAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      timeRemaining: timeRemaining ?? this.timeRemaining, // NEW
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Question get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex >= questions.length - 1;
}

class QuizNotifier extends StateNotifier<QuizState?> {
  QuizNotifier() : super(null);

  // Cache questions to avoid reloading
  static List<Question>? _cachedQuestions;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _getInitialTime(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 20;
      case 'medium':
        return 15;
      case 'hard':
        return 10;
      default:
        return 15;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (state == null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      if (state!.timeRemaining > 0) {
        state = state!.copyWith(timeRemaining: state!.timeRemaining - 1);
      } else {
        timer.cancel();
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    if (state == null || state!.isAnswered) return;

    if (state!.isLastQuestion) {
      completeQuiz();
    } else {
      nextQuestion();
    }
  }

  Future<void> initQuiz(String difficulty) async {
    try {
      // Reset state first to show loading
      state = null;

      // Load questions from cache or file
      _cachedQuestions ??= await QuestionLoader.loadQuestions();

      // Create shuffled copy of questions (don't modify cache)
      final List<Question> shuffledQuestions = List.from(_cachedQuestions!);
      shuffledQuestions.shuffle(); // Randomize order

      // Select subset (always 15 questions)
      int questionCount = 15;

      // Take first N questions from shuffled list
      final selectedQuestions = shuffledQuestions.take(questionCount).toList();

      // Create new quiz state with shuffled questions
      state = QuizState(
        questions: selectedQuestions,
        difficulty: difficulty,
        timeRemaining: _getInitialTime(difficulty),
      );

      _startTimer();
    } catch (e) {
      print('Error initializing quiz: $e');
      // Set a default state to prevent infinite loading
      state = QuizState(questions: [], difficulty: difficulty);
    }
  }

  // Preload questions to cache (call early to avoid loading delay)
  static Future<void> preloadQuestions() async {
    try {
      _cachedQuestions ??= await QuestionLoader.loadQuestions();
    } catch (e) {
      print('Error preloading questions: $e');
    }
  }

  void answerQuestion(int selectedIndex) {
    if (state == null || state!.isAnswered) return;

    _timer?.cancel();

    final currentQuestion = state!.currentQuestion;
    final isCorrect = selectedIndex == currentQuestion.answerIndex;

    state = state!.copyWith(
      selectedIndex: selectedIndex,
      isAnswered: true,
      score: isCorrect ? state!.score + 20 : state!.score,
      correctAnswers:
          isCorrect ? state!.correctAnswers + 1 : state!.correctAnswers,
    );
  }

  // Alias for backward compatibility
  void selectAnswer(int index) => answerQuestion(index);

  void nextQuestion() {
    if (state == null) return;

    state = state!.copyWith(
      currentIndex: state!.currentIndex + 1,
      isAnswered: false,
      resetSelectedIndex: true,
      timeRemaining: _getInitialTime(state!.difficulty),
    );

    _startTimer();
  }

  Future<void> completeQuiz() async {
    _timer?.cancel();
    if (state == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'best_score_${state!.difficulty}';
    final currentBest = prefs.getInt(key) ?? 0;

    if (state!.score > currentBest) {
      await prefs.setInt(key, state!.score);
    }
  }

  void reset() {
    _timer?.cancel();
    state = null;
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState?>((ref) {
  return QuizNotifier();
});

final bestScoreProvider =
    FutureProvider.family<int, String>((ref, difficulty) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('best_score_$difficulty') ?? 0;
});
