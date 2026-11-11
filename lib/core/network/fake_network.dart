// Simulated transport shared by every mock datasource. Replacing the mocks
// with a real API means swapping the datasource implementations only —
// repositories, use cases and screens depend on the domain interfaces.
import 'package:elhareef/core/error/failures.dart';

export 'package:elhareef/core/error/failures.dart';

bool _offline = false;

/// Toggle the simulated connection (used by tests and the offline state).
void setOffline(bool value) => _offline = value;
bool isOffline() => _offline;

/// Resolve after simulated latency, or throw [NetworkError] when offline.
Future<T> simulateRequest<T>(T result, [int latencyMs = 450]) async {
  await Future<void>.delayed(Duration(milliseconds: latencyMs));
  if (_offline) throw const NetworkError();
  return result;
}
