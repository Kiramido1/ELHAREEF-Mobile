import 'package:elhareef/features/chat/domain/entities/chat_message.dart';

abstract interface class ChatRepository {
  List<ChatMessage> get seedThread;

  /// Post a message; completes when the server acknowledges it.
  Future<void> send(String text);
}
