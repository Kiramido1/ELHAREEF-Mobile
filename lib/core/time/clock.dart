// Injectable "now", so date-dependent rules (calendar, past slots,
// cancellation deadlines, greetings) are deterministic in tests.

class Clock {
  const Clock();
  DateTime now() => DateTime.now();
}

class FixedClock implements Clock {
  const FixedClock(this.fixed);
  final DateTime fixed;
  @override
  DateTime now() => fixed;
}

/// Midnight at the start of [d].
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
