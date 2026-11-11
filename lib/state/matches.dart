// Port of src/state/MatchesContext.tsx.
import 'package:flutter/foundation.dart';

import '../services/matches.dart' as svc;
import '../services/network.dart';
import '../types.dart';

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

  CreateMatchDraft copyWith({int? need, String? level, String? privacy, String? description}) =>
      CreateMatchDraft(
        need: need ?? this.need,
        level: level ?? this.level,
        privacy: privacy ?? this.privacy,
        description: description ?? this.description,
      );
}

class MatchesController extends ChangeNotifier {
  List<Match> matches = List.of(svc.allMatches);
  final Map<int, JoinStatus> joinStatus = {};
  bool posted = false;
  int selMatchId = 0;
  CreateMatchDraft draft = const CreateMatchDraft();

  JoinStatus statusOf(int matchId) => joinStatus[matchId] ?? 'none';
  Match byId(int id) => matches.firstWhere((m) => m.id == id, orElse: () => matches[0]);

  void selectMatch(int id) {
    selMatchId = id;
    notifyListeners();
  }

  void setDraft({int? need, String? level, String? privacy, String? description}) {
    draft = draft.copyWith(need: need, level: level, privacy: privacy, description: description);
    notifyListeners();
  }

  void postMatch() {
    posted = true;
    notifyListeners();
  }

  void _update(int matchId, Match Function(Match) f) =>
      matches = [for (final m in matches) m.id == matchId ? f(m) : m];

  /// Ask to join a match: pending → joined after the mock server accepts,
  /// incrementing the joined count. Rethrows [MatchFullError] when the match
  /// filled up first (design's "match full" state).
  Future<void> join(int matchId) async {
    joinStatus[matchId] = 'pending';
    notifyListeners();
    try {
      await svc.requestJoin(matchId);
      joinStatus[matchId] = 'joined';
      _update(matchId, (m) => m.copyWith(joined: m.joined + 1 > m.total ? m.total : m.joined + 1));
      notifyListeners();
    } catch (e) {
      joinStatus[matchId] = 'none';
      // The match filled while the request was pending — reflect it.
      if (e is MatchFullError) _update(matchId, (m) => m.copyWith(joined: m.total));
      notifyListeners();
      rethrow;
    }
  }
}
