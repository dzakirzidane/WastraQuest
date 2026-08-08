import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../providers/quiz_provider.dart';
import '../services/audio_service.dart';
import 'dart:math';

class QuizScreen extends ConsumerStatefulWidget {
  final String difficulty;

  const QuizScreen({super.key, required this.difficulty});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load questions immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).initQuiz(widget.difficulty);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1320),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
          ),
        ),
      );
    }

    // Check if questions loaded successfully
    if (quizState.questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1320),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFD4AF37),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat pertanyaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Periksa koneksi atau coba lagi',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1419),
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 20),
          onPressed: () {
            ref.read(quizProvider.notifier).reset();
            context.go('/home');
          },
        ),
        title: Text(
          'Soal ${quizState.currentIndex + 1}/15',
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        actions: [
          // NEW: Timer Display
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: quizState.timeRemaining <= 5
                    ? Colors.red.withValues(alpha: 0.2)
                    : const Color(0xFF1A1F26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: quizState.timeRemaining <= 5
                      ? Colors.red
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer,
                      color: quizState.timeRemaining <= 5
                          ? Colors.red
                          : Colors.white70,
                      size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${quizState.timeRemaining}s',
                    style: TextStyle(
                      color: quizState.timeRemaining <= 5
                          ? Colors.red
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Score Display
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${quizState.score}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              key: ValueKey(quizState.currentIndex),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question Card
                    Card(
                      color: const Color(0xFF1A1F26),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            // Image Placeholder - FULL WIDTH
                            Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.5),
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.asset(
                                  'assets/images/${quizState.currentQuestion.image}',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback jika gambar tidak tersedia
                                    return Container(
                                      color: const Color(0xFF0F1419),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.checkroom,
                                              size: 60,
                                              color: Color(0xFFD4AF37),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Gambar tidak tersedia',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Question Text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F26).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        quizState.currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Options
                    ...List.generate(
                      quizState.currentQuestion.options.length,
                      (index) => _OptionButton(
                        option: quizState.currentQuestion.options[index],
                        index: index,
                        selectedIndex: quizState.selectedIndex,
                        correctIndex: quizState.currentQuestion.answerIndex,
                        isAnswered: quizState.isAnswered,
                        onTap: () {
                          ref.read(quizProvider.notifier).selectAnswer(index);
                          if (index == quizState.currentQuestion.answerIndex) {
                            _confettiController.play();
                            _audioService.playCorrectSound();
                          } else {
                            _audioService.playWrongSound();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Next Button
                    if (quizState.isAnswered)
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8941E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (quizState.isLastQuestion) {
                                // Normal completion
                                ref.read(quizProvider.notifier).completeQuiz();
                                _audioService.playCompleteSound();
                                context.go('/result');
                              } else {
                                // Next question
                                ref.read(quizProvider.notifier).nextQuestion();
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                quizState.isLastQuestion
                                    ? 'LIHAT HASIL'
                                    : 'LANJUT',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B1320),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Confetti Effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Color(0xFFD4AF37),
                Color(0xFFFFE5A3),
                Color(0xFFB8941E),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String option;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool isAnswered;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isAnswered,
    required this.onTap,
  });

  Color _getColor() {
    if (!isAnswered) {
      return const Color(0xFF1A2332);
    }
    if (index == correctIndex) {
      return const Color(0xFF27AE60);
    }
    if (index == selectedIndex && index != correctIndex) {
      return const Color(0xFFE74C3C);
    }
    return const Color(0xFF1A2332);
  }

  Color _getBorderColor() {
    if (!isAnswered) {
      return const Color(0xFF2A3442);
    }
    if (index == correctIndex) {
      return const Color(0xFF2ECC71);
    }
    if (index == selectedIndex && index != correctIndex) {
      return const Color(0xFFC0392B);
    }
    return const Color(0xFF2A3442);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _getColor(),
          border: Border.all(color: _getBorderColor(), width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isAnswered && index == correctIndex
              ? [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAnswered ? null : onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isAnswered && index == correctIndex)
                    const Icon(Icons.check_circle,
                        color: Color(0xFF2ECC71), size: 20),
                  if (isAnswered &&
                      index == selectedIndex &&
                      index != correctIndex)
                    const Icon(Icons.cancel,
                        color: Color(0xFFC0392B), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
