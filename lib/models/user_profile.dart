class UserProfile {
  final String name;
  final int avatarId;
  final String gender; 
  final int gamesPlayed;
  final int totalScore;
  final Map<String, int> bestScores; 

  UserProfile({
    required this.name,
    this.avatarId = 0,
    this.gender = '',
    this.gamesPlayed = 0,
    this.totalScore = 0,
    Map<String, int>? bestScores,
  }) : bestScores = bestScores ?? {};

  UserProfile copyWith({
    String? name,
    int? avatarId,
    String? gender,
    int? gamesPlayed,
    int? totalScore,
    Map<String, int>? bestScores,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      gender: gender ?? this.gender,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      bestScores: bestScores ?? this.bestScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarId': avatarId,
      'gender': gender,
      'gamesPlayed': gamesPlayed,
      'totalScore': totalScore,
      'bestScores': bestScores,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      avatarId: json['avatarId'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      bestScores: json['bestScores'] != null
          ? Map<String, int>.from(json['bestScores'] as Map)
          : {},
    );
  }
}