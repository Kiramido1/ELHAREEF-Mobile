import 'package:elhareef/features/matches/domain/entities/match.dart';

class HostMatchRequest {
  const HostMatchRequest({
    required this.pitchId,
    required this.pitch,
    required this.area,
    required this.kickoff,
    required this.durHours,
    required this.squadSize,
    required this.need,
    required this.level,
    required this.isPublic,
    required this.description,
    required this.hostName,
  });

  final int pitchId;
  final String pitch, area;
  final DateTime kickoff;
  final int durHours, squadSize, need;
  final String level;
  final bool isPublic;
  final String description, hostName;
}

abstract interface class MatchRepository {
  /// Every match the user can see, including the ones they host.
  Future<List<Match>> getMatches();

  /// Ids of the matches the user has joined (not hosted).
  Future<Set<int>> joinedIds();

  /// Throws [MatchFullError] when the match filled up first.
  Future<Match> join(int matchId);
  Future<Match> leave(int matchId);
  Future<Match> host(HostMatchRequest request);
}
