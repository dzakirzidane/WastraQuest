import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prediction_model.dart';
import '../services/prediction_service.dart';

enum PredictionStatus { idle, loading, success, error }

class PredictionProvider extends ChangeNotifier {
  final PredictionService _service = PredictionService();

  PredictionStatus status = PredictionStatus.idle;
  PredictionResponse? result;
  String? errorMessage;

  Future<void> predict({
    required int jawabanBenar,
    required String tingkatKesulitan,
  }) async {
    status = PredictionStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final request = PredictionRequest(
        jawabanBenar: jawabanBenar,
        tingkatKesulitan: tingkatKesulitan,
      );
      result = await _service.predictKelulusan(request);
      status = PredictionStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      status = PredictionStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    status = PredictionStatus.idle;
    result = null;
    errorMessage = null;
    notifyListeners();
  }
}

final predictionProviderNotifier =
    ChangeNotifierProvider<PredictionProvider>((ref) => PredictionProvider());