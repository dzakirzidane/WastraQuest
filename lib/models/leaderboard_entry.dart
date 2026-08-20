class LeaderboardEntry {
  final int peringkat;
  final String namaSiswa;
  final int skorAkhir;
  final double persentaseBenar;
  final int tingkatKesulitan; // 1=easy, 2=medium, 3=hard

  LeaderboardEntry({
    required this.peringkat,
    required this.namaSiswa,
    required this.skorAkhir,
    required this.persentaseBenar,
    required this.tingkatKesulitan,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      peringkat: json['peringkat'] as int,
      namaSiswa: json['nama_siswa'] as String,
      skorAkhir: json['skor_akhir'] as int,
      persentaseBenar: (json['persentase_benar'] as num).toDouble(),
      tingkatKesulitan: json['tingkat_kesulitan'] as int,
    );
  }
}