import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardException implements Exception {
  final String message;
  LeaderboardException(this.message);

  @override
  String toString() => message;
}

class LeaderboardService {
  Future<List<LeaderboardEntry>> fetchLeaderboard({
    int? tingkatKesulitan,
    int limit = 50,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (tingkatKesulitan != null) {
      params['tingkat_kesulitan'] = '$tingkatKesulitan';
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/leaderboard')
        .replace(queryParameters: params);

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw LeaderboardException('Gagal memuat leaderboard (${response.statusCode})');
      }

      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => LeaderboardEntry.fromJson(e)).toList();
    } on http.ClientException {
      throw LeaderboardException('Tidak bisa terhubung ke server. Cek koneksi/IP backend.');
    } on LeaderboardException {
      rethrow;
    } catch (e) {
      throw LeaderboardException('Terjadi kesalahan: $e');
    }
  }
}