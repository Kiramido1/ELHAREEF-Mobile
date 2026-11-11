// Port of src/types/index.ts. Enum-like TS unions stay as strings so the
// mock data and translation lookups (typeAr, levelAr…) stay 1:1.

class Pitch {
  const Pitch({
    required this.id,
    required this.name,
    required this.area,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.type,
    required this.availableNow,
    required this.gradIndex,
  });
  final int id;
  final String name, area, dist, rating;
  final int reviews, price;

  /// '5-a-side' | '7-a-side' | '8-a-side' | '11-a-side'
  final String type;
  final bool availableNow;
  final int gradIndex;
}

/// 'none' | 'pending' | 'joined'
typedef JoinStatus = String;

class Match {
  const Match({
    required this.id,
    required this.org,
    required this.orgAr,
    required this.initial,
    required this.avatar,
    required this.pitch,
    required this.area,
    required this.day,
    required this.time,
    required this.durHours,
    required this.joined,
    required this.total,
    required this.level,
    required this.gradIndex,
    required this.desc,
    required this.descAr,
  });
  final int id;
  final String org, orgAr, initial;

  /// 'navy' | 'tint' | 'green'
  final String avatar;
  final String pitch, area, day, time;
  final int durHours, joined, total;

  /// 'Beginner' | 'Intermediate' | 'Advanced' | 'Any level'
  final String level;
  final int gradIndex;
  final String desc, descAr;

  Match copyWith({int? joined}) => Match(
        id: id,
        org: org,
        orgAr: orgAr,
        initial: initial,
        avatar: avatar,
        pitch: pitch,
        area: area,
        day: day,
        time: time,
        durHours: durHours,
        joined: joined ?? this.joined,
        total: total,
        level: level,
        gradIndex: gradIndex,
        desc: desc,
        descAr: descAr,
      );
}

class BookingRecord {
  const BookingRecord({
    required this.id,
    required this.pitch,
    required this.date,
    required this.dateAr,
    required this.time,
    required this.timeAr,
    required this.dur,
    required this.durAr,
    required this.status,
    required this.price,
  });
  final String id, pitch, date, dateAr, time, timeAr, dur, durAr;

  /// 'confirmed' | 'completed' | 'cancelled'
  final String status;
  final int price;
}

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

  /// 'system' | 'other' | 'mine'
  final String kind;
  final String text;
  final String? textAr, who, whoAr, initial;

  /// 'navy' | 'tint'
  final String? avatar;
}

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
