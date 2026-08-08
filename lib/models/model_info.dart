class ModelMetrics {
  final String modelName;
  final double cvAccuracy;
  final double cvAccuracyStd;
  final double cvPrecision;
  final double cvPrecisionStd;
  final double cvRecall;
  final double cvRecallStd;
  final double cvF1;
  final double cvF1Std;

  final double testAccuracy;
  final double testPrecision;
  final double testRecall;
  final double testF1;

  // Confusion matrix hold-out test set (200 data)
  final int trueNegative; // Actual Tidak Lulus, Predicted Tidak Lulus
  final int falsePositive; // Actual Tidak Lulus, Predicted Lulus
  final int falseNegative; // Actual Lulus, Predicted Tidak Lulus
  final int truePositive; // Actual Lulus, Predicted Lulus

  const ModelMetrics({
    required this.modelName,
    required this.cvAccuracy,
    required this.cvAccuracyStd,
    required this.cvPrecision,
    required this.cvPrecisionStd,
    required this.cvRecall,
    required this.cvRecallStd,
    required this.cvF1,
    required this.cvF1Std,
    required this.testAccuracy,
    required this.testPrecision,
    required this.testRecall,
    required this.testF1,
    required this.trueNegative,
    required this.falsePositive,
    required this.falseNegative,
    required this.truePositive,
  });
}

class ModelInfoData {
  static const int totalData = 1000;
  static const int trainingData = 800;
  static const int testingData = 200;
  static const List<String> features = ['jawaban_benar', 'tingkat_kesulitan'];

  static const ModelMetrics randomForest = ModelMetrics(
    modelName: 'Random Forest',
    cvAccuracy: 0.7840,
    cvAccuracyStd: 0.0229,
    cvPrecision: 0.7382,
    cvPrecisionStd: 0.0479,
    cvRecall: 0.6915,
    cvRecallStd: 0.0579,
    cvF1: 0.7113,
    cvF1Std: 0.0315,
    testAccuracy: 0.7750,
    testPrecision: 0.7353,
    testRecall: 0.6494,
    testF1: 0.6897,
    trueNegative: 105,
    falsePositive: 18,
    falseNegative: 27,
    truePositive: 50,
  );

  static const ModelMetrics svm = ModelMetrics(
    modelName: 'SVM',
    cvAccuracy: 0.7870,
    cvAccuracyStd: 0.0343,
    cvPrecision: 0.7466,
    cvPrecisionStd: 0.0478,
    cvRecall: 0.6788,
    cvRecallStd: 0.0642,
    cvF1: 0.7101,
    cvF1Std: 0.0513,
    testAccuracy: 0.7750,
    testPrecision: 0.7667,
    testRecall: 0.5974,
    testF1: 0.6715,
    trueNegative: 109,
    falsePositive: 14,
    falseNegative: 31,
    truePositive: 46,
  );

  static const String bestCvModel = 'SVM';
}