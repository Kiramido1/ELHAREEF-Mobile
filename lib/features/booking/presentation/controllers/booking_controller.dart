// State of the booking flow (pitch → date → time → duration → payment).
// Business rules live in the domain (BookingRules, Quote, ConfirmBooking);
// this controller only holds selections and exposes derived view state.
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/domain/repositories/booking_repository.dart';
import 'package:elhareef/features/booking/domain/usecases/confirm_booking.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart' show bookingFee;
import 'package:elhareef/features/pitches/domain/entities/pitch.dart';
import 'package:elhareef/features/pitches/domain/repositories/pitch_repository.dart';

enum ConfirmOutcome { confirmed, declined, slotTaken, offline, failed }

class BookingController extends ChangeNotifier {
  BookingController({
    required BookingRepository bookings,
    required this._pitches,
    required this._clock,
  })  : _bookings = bookings,
        _confirm = ConfirmBooking(bookings) {
    _resetSelections();
  }

  final BookingRepository _bookings;
  final PitchRepository _pitches;
  final Clock _clock;
  final ConfirmBooking _confirm;

  int pitchId = 0;
  late DateTime day; // selected day (midnight)
  late DateTime visibleMonth; // first of the month shown in the calendar
  int? startHour;
  int hours = 2;
  bool recur = false;
  PayMode payMode = PayMode.full;
  PaymentMethod payMethod = PaymentMethod.card;

  Set<int> _busy = const {};
  bool loadingSlots = false;
  bool submitting = false;

  /// End of the slot hold after a declined payment.
  DateTime? holdUntil;

  /// The booking produced by the last successful confirmation.
  Booking? lastBooking;

  int _slotRequest = 0;

  DateTime get now => _clock.now();
  Pitch get pitch => _pitches.byId(pitchId);

  /// Start hours that cannot be picked on the selected day (taken or past).
  Set<int> get unavailable => {..._busy, ...BookingRules.pastHours(day, now)};

  bool isStartAvailable(int h) => !unavailable.contains(h) && BookingRules.maxHoursFrom(h, unavailable) > 0;
  bool isDurationAvailable(int d) => startHour == null || BookingRules.canBook(startHour!, d, unavailable);
  bool isDayBookable(DateTime d) => BookingRules.isDayBookable(d, now);

  bool get canGoPrevMonth {
    final m = DateTime(now.year, now.month);
    return visibleMonth.isAfter(m);
  }

  bool get canGoNextMonth {
    final last = now.add(const Duration(days: BookingRules.bookingWindowDays));
    return DateTime(visibleMonth.year, visibleMonth.month + 1).isBefore(DateTime(last.year, last.month + 1));
  }

  int get sessions => recur ? BookingRules.recurWeeks : 1;
  Quote get quote => Quote.of(pricePerHour: pitch.price, hours: hours, sessions: sessions, fee: bookingFee);
  bool get canContinue => startHour != null && BookingRules.canBook(startHour!, hours, unavailable);
  List<DateTime> get sessionDays => [for (var k = 0; k < sessions; k++) DateTime(day.year, day.month, day.day + 7 * k)];

  /// First free one-hour start at [pitchId] on [day] (null: fully booked).
  Future<int?> firstFreeHour(int pitchId, DateTime day) async {
    final d = dayOf(day);
    final blocked = {...await _bookings.busyHours(pitchId, d), ...BookingRules.pastHours(d, now)};
    for (final h in BookingRules.slotHours) {
      if (BookingRules.canBook(h, 1, blocked)) return h;
    }
    return null;
  }

  /// Start a fresh booking flow for [id], optionally pre-selecting a slot.
  Future<void> startFor(int id, {DateTime? onDay, int? atHour}) async {
    _resetSelections();
    pitchId = id;
    if (onDay != null && isDayBookable(onDay)) {
      day = dayOf(onDay);
      visibleMonth = DateTime(day.year, day.month);
    }
    notifyListeners();
    await _loadSlots();
    if (atHour != null && isStartAvailable(atHour)) selectTime(atHour);
  }

  void selectPitch(int id) {
    if (id == pitchId) return;
    pitchId = id;
    startHour = null;
    notifyListeners();
    _loadSlots();
  }

  void showPrevMonth() {
    if (!canGoPrevMonth) return;
    visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    notifyListeners();
  }

  void showNextMonth() {
    if (!canGoNextMonth) return;
    visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    notifyListeners();
  }

  void selectDay(DateTime d) {
    if (!isDayBookable(d)) return;
    day = dayOf(d);
    startHour = null;
    notifyListeners();
    _loadSlots();
  }

  void selectTime(int h) {
    if (!isStartAvailable(h)) return;
    startHour = h;
    final max = BookingRules.maxHoursFrom(h, unavailable);
    if (hours > max) hours = max;
    notifyListeners();
  }

  void selectDuration(int d) {
    if (!BookingRules.durations.contains(d) || !isDurationAvailable(d)) return;
    hours = d;
    notifyListeners();
  }

  void toggleRecur() {
    recur = !recur;
    payMode = recur ? PayMode.deposit : PayMode.full;
    notifyListeners();
  }

  void setPayMode(PayMode mode) {
    payMode = mode;
    notifyListeners();
  }

  void setPayMethod(PaymentMethod method) {
    payMethod = method;
    notifyListeners();
  }

  /// Confirm with the selected method, or [overrideMethod] (cash at venue).
  Future<ConfirmOutcome> confirm({PaymentMethod? overrideMethod}) async {
    if (submitting || !canContinue) return ConfirmOutcome.failed;
    submitting = true;
    notifyListeners();
    try {
      lastBooking = await _confirm(BookingRequest(
        pitchId: pitchId,
        pitchName: pitch.name,
        day: day,
        startHour: startHour!,
        hours: hours,
        recurWeekly: recur,
        quote: quote,
        payMode: payMode,
        method: overrideMethod ?? payMethod,
      ));
      holdUntil = null;
      return ConfirmOutcome.confirmed;
    } on PaymentDeclinedError {
      holdUntil ??= now.add(BookingRules.holdDuration);
      return ConfirmOutcome.declined;
    } on SlotUnavailableError {
      startHour = null;
      unawaited(_loadSlots());
      return ConfirmOutcome.slotTaken;
    } on NetworkError {
      return ConfirmOutcome.offline;
    } catch (_) {
      return ConfirmOutcome.failed;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  /// Time left on the slot hold (null when nothing is held).
  Duration? holdRemaining() => holdUntil?.difference(now);

  void releaseHold() {
    holdUntil = null;
    startHour = null;
    notifyListeners();
  }

  Future<void> _loadSlots() async {
    final request = ++_slotRequest;
    loadingSlots = true;
    notifyListeners();
    try {
      final busy = await _bookings.busyHours(pitchId, day);
      if (request != _slotRequest) return; // a newer day/pitch was picked
      _busy = busy;
      if (startHour != null && !isStartAvailable(startHour!)) startHour = null;
    } on NetworkError {
      // Keep the previous schedule; ConfirmBooking re-checks before charging.
    } finally {
      if (request == _slotRequest) {
        loadingSlots = false;
        notifyListeners();
      }
    }
  }

  void _resetSelections() {
    final today = dayOf(now);
    // After the last slot of the day, default to tomorrow.
    final todayDone = BookingRules.pastHours(today, now).length == BookingRules.slotHours.length;
    day = todayDone ? DateTime(today.year, today.month, today.day + 1) : today;
    visibleMonth = DateTime(day.year, day.month);
    startHour = null;
    hours = 2;
    recur = false;
    payMode = PayMode.full;
    payMethod = PaymentMethod.card;
    holdUntil = null;
    _busy = const {};
  }
}
