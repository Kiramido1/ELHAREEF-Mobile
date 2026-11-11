import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart';
import 'package:elhareef/features/pitches/domain/entities/pitch.dart';
import 'package:elhareef/features/pitches/domain/repositories/pitch_repository.dart';

class PitchRepositoryImpl implements PitchRepository {
  PitchRepositoryImpl(this._source);
  final PitchMockDatasource _source;

  @override
  Future<List<Pitch>> getPitches() => _source.fetchAll();

  @override
  List<Pitch> get cached => _source.all;

  @override
  Pitch byId(int id) => cached.firstWhere((p) => p.id == id, orElse: () => cached.first);
}
