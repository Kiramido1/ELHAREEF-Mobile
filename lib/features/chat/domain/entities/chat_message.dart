enum MessageKind { system, other, mine }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.kind,
    required this.text,
    this.textAr,
    this.who,
    this.whoAr,
    this.initial,
    this.avatar,
  });
  final int id;
  final MessageKind kind;
  final String text;
  final String? textAr, who, whoAr, initial;

  /// 'navy' | 'tint'
  final String? avatar;
}
