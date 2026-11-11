import 'package:elhareef/features/pitches/domain/entities/pitch.dart';

abstract interface class PitchRepository {
  /// All pitches near the user.
  Future<List<Pitch>> getPitches();

  /// Synchronous lookup for pitches already on the client (selection state).
  Pitch byId(int id);

  /// Every pitch on the client, without a round-trip.
  List<Pitch> get cached;
}
