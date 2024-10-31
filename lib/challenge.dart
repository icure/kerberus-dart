import 'dart:convert';

class Challenge {
  final String id;
  final List<String> salts;
  final int difficultyFactor;

  Challenge({required this.id, required this.salts, required this.difficultyFactor});

  factory Challenge.fromJsonString(String jsonString) {
    return Challenge.fromJson(jsonDecode(jsonString));
  }

  factory Challenge.fromJson(dynamic json) {
    final challengeJsonMap = json as Map<String, dynamic>;
    return Challenge(
        id: challengeJsonMap["id"] as String,
        salts: (challengeJsonMap["salts"] as List<dynamic>).map((x) => x as String).toList(),
        difficultyFactor: challengeJsonMap["difficultyFactor"] as int
    );
  }
}