class ConsultationRecord {
  final String id;
  final String date;
  final String time;
  final String duration;
  final String mainEmotion;
  final String summary;
  final int emotionScore;

  ConsultationRecord({
    required this.id,
    required this.date,
    required this.time,
    required this.duration,
    required this.mainEmotion,
    required this.summary,
    required this.emotionScore,
  });
}
