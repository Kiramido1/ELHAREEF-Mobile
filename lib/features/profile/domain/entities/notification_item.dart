class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.unread,
    required this.dot,
    required this.text,
    required this.textAr,
    required this.time,
    required this.timeAr,
  });
  final int id;
  final bool unread;

  /// 'green' | 'lime' | 'muted' | 'danger'
  final String dot;
  final String text, textAr, time, timeAr;
}
