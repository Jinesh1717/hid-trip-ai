class TripPlan {
  final int id;
  final String title;
  final String destination;
  final double? budget;
  final int? durationDays;
  final Map<String, dynamic> aiGeneratedJson;
  final String createdAt;

  TripPlan({
    required this.id,
    required this.title,
    required this.destination,
    this.budget,
    this.durationDays,
    required this.aiGeneratedJson,
    required this.createdAt,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'],
      title: json['title'] ?? '',
      destination: json['destination'] ?? '',
      budget: json['budget']?.toDouble(),
      durationDays: json['duration_days'],
      aiGeneratedJson: json['ai_generated_json'] ?? {},
      createdAt: json['created_at'] ?? '',
    );
  }
}
