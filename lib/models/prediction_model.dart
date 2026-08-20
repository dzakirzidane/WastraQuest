class ModelPrediction {
  final String prediksi;
  final double probabilitasLulus;

  ModelPrediction({
    required this.prediksi,
    required this.probabilitasLulus,
  });

  factory ModelPrediction.fromJson(Map<String, dynamic> json) {
    return ModelPrediction(
      prediksi: json['prediksi'] as String,
      probabilitasLulus: (json['probabilitas_lulus'] as num).toDouble(),
    );
  }

  bool get isLulus => prediksi == 'Lulus';
}

class PredictionResponse {
  final int jawabanBenar;
  final String tingkatKesulitan;
  final ModelPrediction svm;

  PredictionResponse({
    required this.jawabanBenar,
    required this.tingkatKesulitan,
    required this.svm,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      jawabanBenar: json['jawaban_benar'] as int,
      tingkatKesulitan: json['tingkat_kesulitan'] as String,
      svm: ModelPrediction.fromJson(json['svm']),
    );
  }
}

class PredictionRequest {
  final int jawabanBenar;
  final String tingkatKesulitan;

  PredictionRequest({
    required this.jawabanBenar,
    required this.tingkatKesulitan,
  });

  Map<String, dynamic> toJson() {
    return {
      'jawaban_benar': jawabanBenar,
      'tingkat_kesulitan': tingkatKesulitan,
    };
  }
}