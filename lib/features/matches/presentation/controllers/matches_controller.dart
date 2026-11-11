// Matches state: discover list, join/leave lifecycle, hosting a match.
import 'package:flutter/foundation.dart';

import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/domain/repositories/match_repository.dart';
import 'package:elhareef/features/matches/domain/usecases/host_match.dart';
import 'package:elhareef/features/matches/domain/usecases/join_match.dart';
import 'package:elhareef/features/matches/domain/usecases/leave_match.dart';

class CreateMatchDraft {
  const CreateMatchDraft({
    this.need = 2,
    this.level = 'Intermediate',
    this.privacy = 'public',
    this.description = '',
  });
  final int need;
  final String level;

  /// 'public' | 'friends'
  final String privacy;
  final String description;

  CreateMatchDraft copyWith({int? need, String? level, String? privacy, String? description}) => CreateMatchDraft(
        need: need ?? this.need,
        level: level ?? this.level,
        privacy: privacy ?? this.privacy,
        description: description ?? this.description,
      );
}

class MatchesController extends ChangeNotifier {
  MatchesController({required MatchRepository repository, required Clock clock})
      : _repo = repository,
        _clock = clock,
        _join = JoinMatch(repository),
        _leave = LeaveMatch(repository, clock),
        _host = HostMatch(repository);

  final MatchRepository _repo;
  final Clock _clock;
  final JoinMatch _join;
  final LeaveMatch _leave;
  final HostMatch _host;

  /// The player's own level (from their profile).
  static const myLevel = 'Intermediate';

  List<Match> matches = const [];
  Set<int> _joined = {};
  final Map<int, JoinStatus> _pending = {};
  bool loaded = false;
  bool posting = false;
  CreateMatchDraft draft = const CreateMatchDraft();

  DateTime get now => _clock.now();

  JoinStatus statusOf(int matchId) =>
      _pending[matchId] ?? (_joined.contains(matchId) ? JoinStatus.joined : JoinStatus.none);

  Match byId(int id) => matches.firstWhere((m) => m.id == id, orElse: () => matches.first);

  List<Match> discover(MatchFilter filter) => MatchRules.discover(matches, filter, now: now, myLevel: myLevel);

  List<Match> get hosted => [for (final m in matches) if (m.hostedByMe && !m.isOverAt(now)) m];
  List<Match> get joinedUpcoming => [for (final m in matches) if (_joined.contains(m.id) && !m.isOverAt(now)) m];
  List<Match> get completed =>
      [for (final m in matches) if ((_joined.contains(m.id) || m.hostedByMe) && m.isOverAt(now)) m];

  Future<void> refresh() async {
    try {
      final list = await _repo.getMatches();
      _joined = await _repo.joinedIds();
      matches = list;
      loaded = true;
    } on NetworkError {
      // Keep the last known list.
    }
    notifyListeners();
  }

  void setDraft({int? need, String? level, String? privacy, String? description}) {
    draft = draft.copyWith(need: need, level: level, privacy: privacy, description: description);
    notifyListeners();
  }

  /// pending → joined; rethrows [MatchFullError] / [NetworkError].
  Future<void> join(int matchId) async {
    if (statusOf(matchId) != JoinStatus.none) return;
    _pending[matchId] = JoinStatus.pending;
    notifyListeners();
    try {
      await _join(byId(matchId));
      _joined = {..._joined, matchId};
    } finally {
      _pending.remove(matchId);
      await _reload();
    }
  }

  Future<bool> leave(int matchId) async {
    try {
      await _leave(byId(matchId));
      _joined = {..._joined}..remove(matchId);
      await _reload();
      return true;
    } on AppFailure {
      return false;
    }
  }

  /// Post a match for the booking described by the arguments.
  Future<Match?> host({
    required int pitchId,
    required String pitch,
    required String area,
    required DateTime kickoff,
    required int durHours,
    required int squadSize,
    required String hostName,
  }) async {
    if (posting) return null;
    posting = true;
    notifyListeners();
    try {
      final m = await _host(HostMatchRequest(
        pitchId: pitchId,
        pitch: pitch,
        area: area,
        kickoff: kickoff,
        durHours: durHours,
        squadSize: squadSize,
        need: draft.need.clamp(1, squadSize - 1),
        level: draft.level,
        isPublic: draft.privacy == 'public',
        description: draft.description.trim(),
        hostName: hostName,
      ));
      draft = const CreateMatchDraft();
      await _reload();
      return m;
    } on AppFailure {
      return null;
    } finally {
      posting = false;
      notifyListeners();
    }
  }

  Future<void> _reload() async {
    try {
      matches = await _repo.getMatches();
      _joined = await _repo.joinedIds();
    } on NetworkError {
      // Keep the current state.
    }
    notifyListeners();
  }
}
