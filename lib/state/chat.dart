// Port of src/state/ChatContext.tsx.
import 'package:flutter/foundation.dart';

import '../services/chat.dart' as svc;
import '../types.dart';

class ChatController extends ChangeNotifier {
  List<ChatMessage> messages = List.of(svc.seedMessages);

  /// Send a message; completes when the mock server acknowledges it.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await svc.sendMessage(trimmed);
    messages = [...messages, ChatMessage(id: messages.length, kind: 'mine', text: trimmed)];
    notifyListeners();
  }
}
