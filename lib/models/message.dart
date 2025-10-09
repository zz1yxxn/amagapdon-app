enum MessageSender { user, ai }

enum MessageType { text, image }

class Message {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.type,
    this.imageUrl,
  });
}
