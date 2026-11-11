// Port of src/services/players.ts (mock repository).
import '../types.dart';
import 'network.dart';

/// Filled-slot roster names (design's `mSlots` / `squad`).
const rosterEn = ['Ahmed', 'Omar', 'Karim', 'Hady', 'Ziad', 'Tamer', 'Nour', 'Aly', 'Seif', 'Adam'];
const rosterAr = ['أحمد', 'عمر', 'كريم', 'هادي', 'زياد', 'تامر', 'نور', 'علي', 'سيف', 'آدم'];
const squadEn = ['You', 'Ahmed', 'Omar', 'Karim', 'Hady', 'Ziad'];
const squadAr = ['أنت', 'أحمد', 'عمر', 'كريم', 'هادي', 'زياد'];

const notificationsToday = <NotificationItem>[
  NotificationItem(id: 0, unread: true, dot: 'green', text: 'Your booking at Dream Sports Arena is confirmed for Friday 8:00 PM.', textAr: 'حجزك في دريم سبورتس أرينا اتأكد ليوم الجمعة 8 م.', time: '2 min ago', timeAr: 'من دقيقتين'),
  NotificationItem(id: 1, unread: true, dot: 'lime', text: 'Ahmed Hassan requested to join your match.', textAr: 'أحمد حسن طلب الانضمام لماتشك.', time: '1 hr ago', timeAr: 'من ساعة'),
  NotificationItem(id: 2, unread: false, dot: 'green', text: 'Your match now has 7/8 players — 1 spot left.', textAr: 'ماتشك بقى فيه 7/8 لاعيبة — فاضل مكان واحد.', time: '3 hrs ago', timeAr: 'من 3 ساعات'),
];

const notificationsEarlier = <NotificationItem>[
  NotificationItem(id: 3, unread: false, dot: 'muted', text: 'Reminder: your match at Champions Park starts in 2 hours.', textAr: 'تذكير: ماتشك في تشامبيونز بارك هيبدأ بعد ساعتين.', time: 'Yesterday', timeAr: 'امبارح'),
  NotificationItem(id: 4, unread: false, dot: 'danger', text: 'Your booking at Green Field Club on Jul 15 was cancelled and refunded.', textAr: 'حجزك في جرين فيلد يوم 15 يوليو اتلغى واتسترد.', time: 'Jul 15', timeAr: '15 يوليو'),
];

Future<({List<NotificationItem> today, List<NotificationItem> earlier})> listNotifications() =>
    simulateRequest((today: notificationsToday, earlier: notificationsEarlier), 250);
