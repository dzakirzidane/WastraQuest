import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionLoader {
  static Future<List<Question>> loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/questions.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Question.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }
}
