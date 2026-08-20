/// Sesuai dengan DIFFICULTY_MAP di backend (app/ml/predictor.py).
const Map<String, int> difficultyToInt = {
  'easy': 1,
  'medium': 2,
  'hard': 3,
};

class QuizResultRequest {
  final int totalSoal;
  final int jawabanBenar;
  final int skorAkhir;
  final String tingkatKesulitan; // 'easy' | 'medium' | 'hard'
  final double persentaseBenar;
  final bool lulus;
  final String? namaSiswa;

  QuizResultRequest({
    required this.totalSoal,
    required this.jawabanBenar,
    required this.skorAkhir,
    required this.tingkatKesulitan,
    required this.persentaseBenar,
    required this.lulus,
    this.namaSiswa,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_soal': totalSoal,
      'jawaban_benar': jawabanBenar,
      'skor_akhir': skorAkhir,
      'tingkat_kesulitan': difficultyToInt[tingkatKesulitan],
      'persentase_benar': persentaseBenar,
      'kelulusan': lulus ? 1 : 0,
      if (namaSiswa != null) 'nama_siswa': namaSiswa,
    };
  }
}