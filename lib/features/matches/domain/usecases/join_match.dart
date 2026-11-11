import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/domain/repositories/match_repository.dart';

class JoinMatch {
  const JoinMatch(this._repo);
  final MatchRepository _repo;

  Future<Match> call(Match match) {
    if (match.isFull) throw const MatchFullError();
    if (match.hostedByMe) throw const ValidationError('host-cannot-join');
    return _repo.join(match.id);
  }
}
