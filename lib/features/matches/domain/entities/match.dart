// Pick-up match entity and its join lifecycle. Pure Dart.

enum JoinStatus { none, pending, joined }

/// Levels as shown on chips ('Any level' matches every player).
const matchLevels = ['Beginner', 'Intermediate', 'Advanced', 'Any level'];

class Match {
  const Match({
    required this.id,
    required this.org,
    required this.orgAr,
    required this.initial,
    required this.avatar,
    required this.pitchId,
    required this.pitch,
    required this.area,
    required this.kickoff,
    required this.durHours,
    required this.joined,
    required this.total,
    required this.level,
    required this.gradIndex,
    required this.desc,
    required this.descAr,
    required this.distanceKm,
    this.hostedByMe = false,
    this.isPublic = true,
  });

  final int id;
  final String org, orgAr, initial;

  /// 'navy' | 'tint' | 'green'
  final String avatar;
  final int pitchId;
  final String pitch, area;
  final DateTime kickoff;
  final int durHours, joined, total;

  /// One of [matchLevels].
  final String level;
  final int gradIndex;
  final String desc, descAr;
  final double distanceKm;
  final bool hostedByMe, isPublic;

  int get needed => total - joined;
  bool get isFull => joined >= total;
  DateTime get end => kickoff.add(Duration(hours: durHours));
  bool isOverAt(DateTime now) => end.isBefore(now);
  bool hasStartedAt(DateTime now) => !kickoff.isAfter(now);

  Match copyWith({int? joined}) => Match(
        id: id,
        org: org,
        orgAr: orgAr,
        initial: initial,
        avatar: avatar,
        pitchId: pitchId,
        pitch: pitch,
        area: area,
        kickoff: kickoff,
        durHours: durHours,
        joined: joined ?? this.joined,
        total: total,
        level: level,
        gradIndex: gradIndex,
        desc: desc,
        descAr: descAr,
        distanceKm: distanceKm,
        hostedByMe: hostedByMe,
        isPublic: isPublic,
      );
}

enum MatchFilter { all, today, nearMe, myLevel }

/// Discover-list rules: upcoming public matches, filtered and sorted.
abstract final class MatchRules {
  static const nearMeKm = 5.0;

  static List<Match> discover(Iterable<Match> matches, MatchFilter filter, {required DateTime now, required String myLevel}) {
    bool sameDay(DateTime a) => a.year == now.year && a.month == now.month && a.day == now.day;
    final list = matches.where((m) => !m.hostedByMe && m.isPublic && !m.isOverAt(now)).where((m) => switch (filter) {
          MatchFilter.all => true,
          MatchFilter.today => sameDay(m.kickoff),
          MatchFilter.nearMe => m.distanceKm <= nearMeKm,
          MatchFilter.myLevel => m.level == myLevel || m.level == 'Any level',
        }).toList();
    list.sort((a, b) => filter == MatchFilter.nearMe ? a.distanceKm.compareTo(b.distanceKm) : a.kickoff.compareTo(b.kickoff));
    return list;
  }
}
