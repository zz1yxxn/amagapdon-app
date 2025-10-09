import 'message.dart';

class ConsultationData {
  final Map<String, int> emotions;
  final String summary;
  final String recommendations;
  final List<Message> messages;

  ConsultationData({
    required this.emotions,
    required this.summary,
    required this.recommendations,
    required this.messages,
  });
}
