import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/domain/repositories/match_repository.dart';

/// Players can leave a joined match until kick-off; hosts cannot leave.
class LeaveMatch {
  const LeaveMatch(this._repo, this._clock);
  final MatchRepository _repo;
  final Clock _clock;

  Future<Match> call(Match match) {
    if (match.hostedByMe || match.hasStartedAt(_clock.now())) throw const ValidationError('leave');
    return _repo.leave(match.id);
  }
}
