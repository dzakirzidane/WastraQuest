import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../providers/prediction_provider.dart';
import '../models/prediction_model.dart';
import 'dart:math';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();

    // Update user stats
    final quizState = ref.read(quizProvider);
    if (quizState != null) {
      ref.read(userProvider.notifier).updateStats(
            score: quizState.score,
            difficulty: quizState.difficulty,
          );

      // Play confetti for good scores
      final totalQuestions = quizState.questions.length;
      final percentage =
          (quizState.correctAnswers / totalQuestions * 100).round();
      if (percentage >= 70) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _confettiController.play();
        });
      }

      // Panggil prediksi ML (Random Forest vs SVM) setelah kuis selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(predictionProviderNotifier).predict(
              jawabanBenar: quizState.correctAnswers,
              tingkatKesulitan: quizState.difficulty,
            );
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildPredictionSection(PredictionProvider prediction) {
    if (prediction.status == PredictionStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFD4AF37),
          ),
        ),
      );
    }

    if (prediction.status == PredictionStatus.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Prediksi ML tidak tersedia: ${prediction.errorMessage}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (prediction.status == PredictionStatus.success &&
        prediction.result != null) {
      final res = prediction.result!;
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F26),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediksi Kelulusan (ML)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildModelTile('Random Forest', res.randomForest),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModelTile('SVM', res.svm),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildModelTile(String modelName, ModelPrediction pred) {
    final isLulus = pred.isLulus;
    final color = isLulus ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF232930),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            modelName,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pred.prediksi,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pred.probabilitasLulus * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final user = ref.watch(userProvider);
    final prediction = ref.watch(predictionProviderNotifier);

    if (quizState == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1320),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B1320),
            ),
            child: const Text('Kembali'),
          ),
        ),
      );
    }

    final bestScoreAsync = ref.watch(bestScoreProvider(quizState.difficulty));
    final totalQuestions = quizState.questions.length;
    final percentage =
        (quizState.correctAnswers / totalQuestions * 100).round();

    String getMessage() {
      if (percentage >= 90) return 'Sempurna! 🏆';
      if (percentage >= 80) return 'Luar Biasa! 🎉';
      if (percentage >= 60) return 'Bagus Sekali! 👏';
      if (percentage >= 40) return 'Cukup Baik! 👍';
      return 'Tetap Semangat! 💪';
    }

    Color getGradeColor() {
      if (percentage >= 80) return const Color(0xFF2ECC71);
      if (percentage >= 60) return const Color(0xFFF39C12);
      return const Color(0xFFE74C3C);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Trophy Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              getGradeColor().withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 70,
                          color: getGradeColor(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Message
                      Text(
                        getMessage(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: getGradeColor(),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (user != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Score Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F26),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: getGradeColor().withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Skor Akhir',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${quizState.score}',
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${quizState.correctAnswers}/$totalQuestions Benar',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$percentage% Akurasi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 1,
                              color: const Color(0xFF232930),
                            ),
                            const SizedBox(height: 12),
                            bestScoreAsync.when(
                              data: (bestScore) => Column(
                                children: [
                                  Text(
                                    'Skor Terbaik',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        bestScore > quizState.score
                                            ? '$bestScore'
                                            : '${quizState.score}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: bestScore > quizState.score
                                              ? Colors.white70
                                              : const Color(0xFFD4AF37),
                                        ),
                                      ),
                                      if (bestScore <= quizState.score) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.new_releases,
                                          color: Color(0xFFD4AF37),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Baru!',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFD4AF37),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              loading: () => const CircularProgressIndicator(
                                  strokeWidth: 2),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),

                      // Prediksi ML (Random Forest vs SVM)
                      _buildPredictionSection(prediction),

                      const SizedBox(height: 30),

                      // Play Again Button
                      Container(
                        height: 50,
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
                              ref.read(quizProvider.notifier).reset();
                              ref.read(predictionProviderNotifier).reset();
                              context.go('/home');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'MAIN LAGI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B1320),
                                  letterSpacing: 1.2,
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

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 15,
                minBlastForce: 5,
                emissionFrequency: 0.03,
                numberOfParticles: 30,
                gravity: 0.2,
                colors: const [
                  Color(0xFFD4AF37),
                  Color(0xFFFFE5A3),
                  Color(0xFFB8941E),
                  Color(0xFF2ECC71),
                  Color(0xFF3498DB),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}