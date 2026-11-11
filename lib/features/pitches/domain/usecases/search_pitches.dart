import 'package:elhareef/features/pitches/domain/entities/pitch.dart';
import 'package:elhareef/features/pitches/domain/entities/pitch_filter.dart';
import 'package:elhareef/features/pitches/domain/repositories/pitch_repository.dart';

/// Pitches matching [PitchFilter], nearest first.
class SearchPitches {
  const SearchPitches(this._repo);
  final PitchRepository _repo;

  List<Pitch> call(PitchFilter filter) =>
      filter.apply(_repo.cached)..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
}
