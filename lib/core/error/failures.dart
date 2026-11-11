// Domain-level failures. The data layer translates transport errors into
// these, so presentation code never depends on a specific backend/client.

sealed class AppFailure implements Exception {
  const AppFailure(this.code);
  final String code;
  @override
  String toString() => code;
}

/// No connectivity, or the server could not be reached.
class NetworkError extends AppFailure {
  const NetworkError() : super('network-unavailable');
}

/// The match filled up before the join request was accepted.
class MatchFullError extends AppFailure {
  const MatchFullError() : super('match-full');
}

/// The card issuer declined the payment.
class PaymentDeclinedError extends AppFailure {
  const PaymentDeclinedError() : super('payment-declined');
}

/// The requested slot is no longer free (taken while the user was deciding).
class SlotUnavailableError extends AppFailure {
  const SlotUnavailableError() : super('slot-unavailable');
}

/// Input rejected by a domain rule (e.g. an invalid phone number).
class ValidationError extends AppFailure {
  const ValidationError(String field) : super('invalid-$field');
}
