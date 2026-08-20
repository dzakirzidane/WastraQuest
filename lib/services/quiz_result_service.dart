import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_result_model.dart';

class QuizResultException implements Exception {
  final String message;
  QuizResultException(this.message);

  @override
  String toString() => message;
}

class QuizResultService {
  static const String baseUrl = 'https://wastraquest-production.up.railway.app';

  Future<void> submitQuizResult(QuizResultRequest request) async {
    final url = Uri.parse('$baseUrl/quiz-results');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw QuizResultException(
          body['detail']?.toString() ??
              'Gagal menyimpan hasil kuis (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw QuizResultException('Tidak bisa terhubung ke server. Cek koneksi/IP backend.');
    } on QuizResultException {
      rethrow;
    } catch (e) {
      throw QuizResultException('Terjadi kesalahan: $e');
    }
  }
}