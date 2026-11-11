// Port of src/services/chat.ts (mock repository).
import '../types.dart';
import 'network.dart';

/// Seed thread from the design's `msgs` state.
const seedMessages = <ChatMessage>[
  ChatMessage(id: 0, kind: 'system', text: 'Omar joined the match', textAr: 'عمر انضم للماتش'),
  ChatMessage(id: 1, kind: 'other', who: 'Ahmed', whoAr: 'أحمد', initial: 'A', avatar: 'navy', text: 'Squad is almost ready — 2 spots left. Invite anyone solid.', textAr: 'الشلة شبه كاملة — فاضل مكانين. اعزم أي حد جامد.'),
  ChatMessage(id: 2, kind: 'other', who: 'Omar', whoAr: 'عمر', initial: 'O', avatar: 'tint', text: 'My cousin plays CB, adding him now', textAr: 'ابن عمي بيلعب قلب دفاع، هضيفه دلوقتي'),
  ChatMessage(id: 3, kind: 'mine', text: 'Booked the pitch 8 to 10. Gate 2 has parking.', textAr: 'حجزت الملعب من 8 لـ 10. بوابة 2 فيها باركينج.'),
  ChatMessage(id: 4, kind: 'other', who: 'Ahmed', whoAr: 'أحمد', initial: 'A', avatar: 'navy', text: 'Perfect. Bibs on me, bring 50 each for the pitch.', textAr: 'تمام. البيبات عليّا، كل واحد يجيب 50 للملعب.'),
];

/// Post a message. Replace with a WebSocket/API call without touching the UI.
Future<String> sendMessage(String text) => simulateRequest(text, 120);
