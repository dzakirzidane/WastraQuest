import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/prediction_model.dart';

class PredictionException implements Exception {
  final String message;
  PredictionException(this.message);

  @override
  String toString() => message;
}

class PredictionService {
  Future<PredictionResponse> predictKelulusan(PredictionRequest request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/predict');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return PredictionResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 503) {
        throw PredictionException('Model ML belum siap di server. Coba lagi nanti.');
      } else {
        final body = jsonDecode(response.body);
        throw PredictionException(
          body['detail']?.toString() ?? 'Gagal memproses prediksi (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw PredictionException('Tidak bisa terhubung ke server. Cek koneksi/IP backend.');
    } on PredictionException {
      rethrow;
    } catch (e) {
      throw PredictionException('Terjadi kesalahan: $e');
    }
  }
}