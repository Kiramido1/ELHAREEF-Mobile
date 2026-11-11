import 'package:flutter/foundation.dart';

import 'package:elhareef/features/chat/domain/entities/chat_message.dart';
import 'package:elhareef/features/chat/domain/repositories/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController(this._repo) : messages = List.of(_repo.seedThread);
  final ChatRepository _repo;
  List<ChatMessage> messages;

  /// Ignores blank text; appends once the server acknowledges.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _repo.send(trimmed);
    messages = [...messages, ChatMessage(id: messages.length, kind: MessageKind.mine, text: trimmed)];
    notifyListeners();
  }
}
