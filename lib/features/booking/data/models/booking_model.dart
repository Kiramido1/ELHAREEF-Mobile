// JSON mapping for [Booking]. Entities never know about serialisation.
import 'package:elhareef/features/booking/domain/entities/booking.dart';

abstract final class BookingModel {
  static Map<String, Object?> toJson(Booking b) => {
        'id': b.id,
        'pitchId': b.pitchId,
        'pitchName': b.pitchName,
        'start': b.start.toIso8601String(),
        'hours': b.hours,
        'sessions': b.sessions,
        'total': b.total,
        'paidNow': b.paidNow,
        'method': b.method.name,
        'payMode': b.payMode.name,
        'status': b.status.name,
      };

  static Booking fromJson(Map<String, Object?> j) => Booking(
        id: j['id']! as String,
        pitchId: j['pitchId']! as int,
        pitchName: j['pitchName']! as String,
        start: DateTime.parse(j['start']! as String),
        hours: j['hours']! as int,
        sessions: j['sessions']! as int,
        total: j['total']! as int,
        paidNow: j['paidNow']! as int,
        method: PaymentMethod.values.byName(j['method']! as String),
        payMode: PayMode.values.byName(j['payMode']! as String),
        status: BookingStatus.values.byName(j['status']! as String),
      );
}
