// Simulated network layer shared by every mock repository (port of
// src/services/network.ts). Swapping in a real API later only means replacing
// the bodies of the service functions — screens depend on the async
// signatures alone.

class NetworkError implements Exception {
  @override
  String toString() => 'network-unavailable';
}

class MatchFullError implements Exception {
  @override
  String toString() => 'match-full';
}

class PaymentDeclinedError implements Exception {
  @override
  String toString() => 'payment-declined';
}

bool _offline = false;

/// Toggle the simulated connection (used to exercise the offline state).
void setOffline(bool value) => _offline = value;
bool isOffline() => _offline;

/// Resolve after simulated latency, or throw [NetworkError] when offline.
Future<T> simulateRequest<T>(T result, [int latencyMs = 450]) async {
  await Future<void>.delayed(Duration(milliseconds: latencyMs));
  if (_offline) throw NetworkError();
  return result;
}
