import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/features/matches/data/datasources/match_local_datasource.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl(this._local);
  final MatchLocalDatasource _local;

  late final List<Match> _seed = _local.seed();
  late Set<int> _joined = _local.loadJoined();
  late List<Match> _hosted = _local.loadHosted();
  final Map<int, int> _filled = {};

  Match _withMe(Match m) {
    if (_filled.containsKey(m.id)) return m.copyWith(joined: _filled[m.id]);
    // The seeded past match already counts the user in its squad.
    final mine = _joined.contains(m.id) && !MatchLocalDatasource.seededJoined.contains(m.id);
    return mine ? m.copyWith(joined: (m.joined + 1).clamp(0, m.total)) : m;
  }

  List<Match> get _all => [for (final m in _seed) _withMe(m), ..._hosted];

  Match _byId(int id) => _all.firstWhere((m) => m.id == id, orElse: () => throw const ValidationError('match'));

  @override
  Future<List<Match>> getMatches() => simulateRequest(_all, 300);

  @override
  Future<Set<int>> joinedIds() async => {..._joined};

  @override
  Future<Match> join(int matchId) async {
    if (matchId == MatchLocalDatasource.fillsUpWhileJoiningId && !_joined.contains(matchId)) {
      await simulateRequest(null, 900);
      _filled[matchId] = _byId(matchId).total;
      throw const MatchFullError();
    }
    await simulateRequest(null, 1100);
    if (_byId(matchId).isFull) throw const MatchFullError();
    _joined = {..._joined, matchId};
    await _local.saveJoined(_joined);
    return _byId(matchId);
  }

  @override
  Future<Match> leave(int matchId) async {
    await simulateRequest(null, 500);
    _joined = {..._joined}..remove(matchId);
    await _local.saveJoined(_joined);
    return _byId(matchId);
  }

  @override
  Future<Match> host(HostMatchRequest r) async {
    await simulateRequest(null, 600);
    final nextId = _all.fold<int>(99, (max, m) => m.id > max ? m.id : max) + 1;
    final match = Match(
      id: nextId,
      org: r.hostName,
      orgAr: r.hostName,
      initial: r.hostName.isEmpty ? '?' : r.hostName.substring(0, 1).toUpperCase(),
      avatar: 'navy',
      pitchId: r.pitchId,
      pitch: r.pitch,
      area: r.area,
      kickoff: r.kickoff,
      durHours: r.durHours,
      joined: r.squadSize - r.need,
      total: r.squadSize,
      level: r.level,
      gradIndex: r.pitchId % 4,
      desc: r.description,
      descAr: r.description,
      distanceKm: 0,
      hostedByMe: true,
      isPublic: r.isPublic,
    );
    _hosted = [..._hosted, match];
    await _local.saveHosted(_hosted);
    return match;
  }
}
