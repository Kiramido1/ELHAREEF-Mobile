// Booking entities and the rules every booking obeys. Pure Dart.

enum BookingStatus { confirmed, completed, cancelled }

enum PaymentMethod { card, wallet, cash }

enum PayMode { full, deposit }

class Booking {
  const Booking({
    required this.id,
    required this.pitchId,
    required this.pitchName,
    required this.start,
    required this.hours,
    required this.sessions,
    required this.total,
    required this.paidNow,
    required this.method,
    required this.payMode,
    required this.status,
  });

  final String id;
  final int pitchId;
  final String pitchName;

  /// Kick-off of the first session (local time).
  final DateTime start;
  final int hours;

  /// 1, or [BookingRules.recurWeeks] for a weekly booking.
  final int sessions;
  final int total, paidNow;
  final PaymentMethod method;
  final PayMode payMode;
  final BookingStatus status;

  int get startHour => start.hour;
  DateTime get end => start.add(Duration(hours: hours));
  int get dueAtVenue => total - paidNow;

  /// Kick-off of every session (weekly bookings repeat on the same weekday).
  List<DateTime> get sessionStarts => [for (var k = 0; k < sessions; k++) start.add(Duration(days: 7 * k))];

  DateTime get freeCancellationUntil => start.subtract(BookingRules.freeCancellationWindow);

  /// Stored status, with confirmed bookings in the past reported as completed.
  BookingStatus statusAt(DateTime now) =>
      status == BookingStatus.confirmed && sessionStarts.last.add(Duration(hours: hours)).isBefore(now)
          ? BookingStatus.completed
          : status;

  bool canCancelAt(DateTime now) => statusAt(now) == BookingStatus.confirmed && now.isBefore(start);
  bool isFreeCancellationAt(DateTime now) => now.isBefore(freeCancellationUntil);

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        pitchId: pitchId,
        pitchName: pitchName,
        start: start,
        hours: hours,
        sessions: sessions,
        total: total,
        paidNow: paidNow,
        method: method,
        payMode: payMode,
        status: status ?? this.status,
      );
}

/// What the user is asking to book.
class BookingRequest {
  const BookingRequest({
    required this.pitchId,
    required this.pitchName,
    required this.day,
    required this.startHour,
    required this.hours,
    required this.recurWeekly,
    required this.quote,
    required this.payMode,
    required this.method,
  });

  final int pitchId;
  final String pitchName;
  final DateTime day;
  final int startHour, hours;
  final bool recurWeekly;
  final Quote quote;
  final PayMode payMode;
  final PaymentMethod method;

  int get sessions => recurWeekly ? BookingRules.recurWeeks : 1;
  DateTime get start => DateTime(day.year, day.month, day.day, startHour);
  List<DateTime> get sessionDays => [for (var k = 0; k < sessions; k++) DateTime(day.year, day.month, day.day + 7 * k)];
}

/// Price breakdown for a booking.
class Quote {
  const Quote._(this.price, this.fee, this.total, this.deposit);

  /// `hours × rate × sessions` + fee; deposit = max(50, 25% of total rounded to 5).
  factory Quote.of({required int pricePerHour, required int hours, required int sessions, required int fee}) {
    final price = hours * pricePerHour * sessions;
    final total = price + fee;
    final deposit = ((total * 0.25) / 5).round() * 5;
    return Quote._(price, fee, total, deposit < 50 ? 50 : deposit);
  }

  final int price, fee, total, deposit;
  int get remainingAfterDeposit => total - deposit;
  int dueNow(PayMode mode) => mode == PayMode.deposit ? deposit : total;
}

abstract final class BookingRules {
  /// Bookable start hours, 4 PM – 10 PM.
  static const slotHours = [16, 17, 18, 19, 20, 21, 22];

  /// Pitches close at midnight.
  static const closingHour = 24;
  static const durations = [1, 2, 3, 4];
  static const recurWeeks = 4;
  static const freeCancellationWindow = Duration(hours: 12);

  /// How far ahead the calendar allows booking.
  static const bookingWindowDays = 60;

  /// How long a slot stays held after a declined payment.
  static const holdDuration = Duration(minutes: 10);

  /// True when every hour in [start, start + hours) is free and the game
  /// ends by closing time.
  static bool canBook(int start, int hours, Set<int> busy) {
    if (start + hours > closingHour) return false;
    for (var h = start; h < start + hours; h++) {
      if (busy.contains(h)) return false;
    }
    return true;
  }

  /// Longest bookable duration from [start] (0 when the start is taken).
  static int maxHoursFrom(int start, Set<int> busy) {
    var best = 0;
    for (final d in durations) {
      if (canBook(start, d, busy)) best = d;
    }
    return best;
  }

  /// Start hours that are already in the past on [day], given [now].
  static Set<int> pastHours(DateTime day, DateTime now) {
    final sameDay = day.year == now.year && day.month == now.month && day.day == now.day;
    if (!sameDay) return const {};
    return {for (final h in slotHours) if (h <= now.hour) h};
  }

  static bool isDayBookable(DateTime day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(today) && d.difference(today).inDays <= bookingWindowDays;
  }
}
