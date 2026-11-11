import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/features/chat/data/datasources/chat_mock_datasource.dart';
import 'package:elhareef/features/chat/domain/entities/chat_message.dart';
import 'package:elhareef/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl();

  @override
  List<ChatMessage> get seedThread => seedMessages;

  @override
  Future<void> send(String text) => simulateRequest(null, 120);
}
