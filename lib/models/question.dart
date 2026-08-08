class Question {
  final int id;
  final String region;
  final String title;
  final String image;
  final String question;
  final List<String> options;
  final int answerIndex;

  Question({
    this.id = 0, // Make id optional with default value
    required this.region,
    required this.title,
    required this.image,
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0, // Use null-aware operator
      region: json['region'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answerIndex: json['answerIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'title': title,
      'image': image,
      'question': question,
      'options': options,
      'answerIndex': answerIndex,
    };
  }
}
