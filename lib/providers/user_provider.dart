import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson != null) {
      final map = json.decode(profileJson) as Map<String, dynamic>;
      state = UserProfile.fromJson(map);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
    state = profile;
  }

  Future<void> updateStats({
    required int score,
    required String difficulty,
  }) async {
    if (state == null) return;

    final currentBest = state!.bestScores[difficulty] ?? 0;
    final newBestScores = Map<String, int>.from(state!.bestScores);
    
    if (score > currentBest) {
      newBestScores[difficulty] = score;
    }

    final updatedProfile = state!.copyWith(
      gamesPlayed: state!.gamesPlayed + 1,
      totalScore: state!.totalScore + score,
      bestScores: newBestScores,
    );

    await saveProfile(updatedProfile);
  }

  Future<void> resetProgress() async {
    if (state == null) return;

    final resetProfile = state!.copyWith(
      gamesPlayed: 0,
      totalScore: 0,
      bestScores: {},
    );

    await saveProfile(resetProfile);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    state = null;
  }

  bool get hasProfile => state != null;
}

final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});