import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/domain/repositories/match_repository.dart';

class HostMatch {
  const HostMatch(this._repo);
  final MatchRepository _repo;

  Future<Match> call(HostMatchRequest r) {
    if (r.need < 1 || r.need >= r.squadSize) throw const ValidationError('need');
    if (!matchLevels.contains(r.level)) throw const ValidationError('level');
    return _repo.host(r);
  }
}
