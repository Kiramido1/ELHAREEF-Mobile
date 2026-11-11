import 'package:flutter/foundation.dart';

import 'package:elhareef/features/pitches/domain/entities/pitch.dart';
import 'package:elhareef/features/pitches/domain/entities/pitch_filter.dart';
import 'package:elhareef/features/pitches/domain/repositories/pitch_repository.dart';
import 'package:elhareef/features/pitches/domain/usecases/search_pitches.dart';

/// Read-only pitch catalogue for Home, Search and Pitch details.
class PitchesController extends ChangeNotifier {
  PitchesController(this._repo) : _search = SearchPitches(_repo);
  final PitchRepository _repo;
  final SearchPitches _search;

  List<Pitch> get all => _repo.cached;

  /// Fetch from the source (shows loading/offline states on Home).
  Future<List<Pitch>> load() => _repo.getPitches();
  Pitch byId(int id) => _repo.byId(id);
  List<Pitch> search(PitchFilter filter) => _search(filter);
}
