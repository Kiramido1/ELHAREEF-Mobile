// Seed squad-chat thread (a WebSocket datasource would replace this).
import 'package:elhareef/features/chat/domain/entities/chat_message.dart';

const seedMessages = <ChatMessage>[
  ChatMessage(id: 0, kind: MessageKind.system, text: 'Omar joined the match', textAr: 'عمر انضم للماتش'),
  ChatMessage(id: 1, kind: MessageKind.other, who: 'Ahmed', whoAr: 'أحمد', initial: 'A', avatar: 'navy', text: 'Squad is almost ready — 2 spots left. Invite anyone solid.', textAr: 'الشلة شبه كاملة — فاضل مكانين. اعزم أي حد جامد.'),
  ChatMessage(id: 2, kind: MessageKind.other, who: 'Omar', whoAr: 'عمر', initial: 'O', avatar: 'tint', text: 'My cousin plays CB, adding him now', textAr: 'ابن عمي بيلعب قلب دفاع، هضيفه دلوقتي'),
  ChatMessage(id: 3, kind: MessageKind.mine, text: 'Booked the pitch 8 to 10. Gate 2 has parking.', textAr: 'حجزت الملعب من 8 لـ 10. بوابة 2 فيها باركينج.'),
  ChatMessage(id: 4, kind: MessageKind.other, who: 'Ahmed', whoAr: 'أحمد', initial: 'A', avatar: 'navy', text: 'Perfect. Bibs on me, bring 50 each for the pitch.', textAr: 'تمام. البيبات عليّا، كل واحد يجيب 50 للملعب.'),
];
