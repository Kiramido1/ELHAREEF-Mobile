// Seed matches (relative to "now", so the demo never shows stale dates) and
// on-device persistence of the user's joins and hosted matches.
import 'dart:convert';

import 'package:elhareef/core/storage/key_value_store.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';

class MatchLocalDatasource {
  MatchLocalDatasource(this._store, this._clock);

  static const _joinedKey = 'matches.joined.v1';
  static const _hostedKey = 'matches.hosted.v1';

  /// Karim's Sunday game fills up while a join request is in flight — the
  /// designed "This match just filled up" state.
  static const fillsUpWhileJoiningId = 2;

  final KeyValueStore _store;
  final Clock _clock;

  List<Match> seed() {
    final now = _clock.now();
    final today = dayOf(now);
    DateTime at(int days, int hour) => DateTime(today.year, today.month, today.day + days, hour);
    // Tonight's game rolls to tomorrow once it has started.
    final tonight = now.hour < 20 ? at(0, 20) : at(1, 20);
    return [
      Match(id: 0, org: 'Ahmed Hassan', orgAr: 'أحمد حسن', initial: 'A', avatar: 'navy', pitchId: 0, pitch: 'Dream Sports Arena', area: 'Fayoum City', kickoff: tonight, durHours: 2, joined: 6, total: 8, level: 'Intermediate', gradIndex: 0, distanceKm: 2.1, desc: 'Friendly match, intermediate level. We split the pitch cost evenly and rotate keepers every 20 minutes.', descAr: 'ماتش ودي مستوى متوسط. بنقسم تكلفة الملعب بالتساوي وبنبدل الحارس كل 20 دقيقة.'),
      Match(id: 1, org: 'Omar Tarek', orgAr: 'عمر طارق', initial: 'O', avatar: 'tint', pitchId: 1, pitch: 'Green Field Club', area: 'Sinnuris', kickoff: at(2, 19), durHours: 1, joined: 8, total: 10, level: 'Advanced', gradIndex: 1, distanceKm: 3.4, desc: 'Fast-paced game, advanced players only please.', descAr: 'لعب سريع، للمتقدمين بس.'),
      Match(id: fillsUpWhileJoiningId, org: 'Karim Said', orgAr: 'كريم سعيد', initial: 'K', avatar: 'green', pitchId: 2, pitch: 'Champions Park', area: 'Tamiya', kickoff: at(3, 21), durHours: 2, joined: 4, total: 10, level: 'Any level', gradIndex: 2, distanceKm: 4.0, desc: 'Casual game, everyone welcome.', descAr: 'ماتش حبي، الكل مرحب بيه.'),
      Match(id: 3, org: 'Karim Said', orgAr: 'كريم سعيد', initial: 'K', avatar: 'green', pitchId: 2, pitch: 'Champions Park', area: 'Tamiya', kickoff: at(-5, 21), durHours: 2, joined: 10, total: 10, level: 'Any level', gradIndex: 2, distanceKm: 4.0, desc: 'Casual game, everyone welcome.', descAr: 'ماتش حبي، الكل مرحب بيه.'),
    ];
  }

  /// The past match the seed user played in, so "Completed" isn't empty.
  static const seededJoined = {3};

  Set<int> loadJoined() {
    final raw = _store.getString(_joinedKey);
    if (raw == null) return {...seededJoined};
    try {
      return {for (final v in jsonDecode(raw) as List) v as int};
    } on Object {
      return {...seededJoined};
    }
  }

  Future<void> saveJoined(Set<int> ids) => _store.setString(_joinedKey, jsonEncode(ids.toList()));

  List<Match> loadHosted() {
    final raw = _store.getString(_hostedKey);
    if (raw == null) return [];
    try {
      return [for (final j in jsonDecode(raw) as List) _fromJson((j as Map).cast<String, Object?>())];
    } on Object {
      return [];
    }
  }

  Future<void> saveHosted(List<Match> hosted) => _store.setString(_hostedKey, jsonEncode([for (final m in hosted) _toJson(m)]));

  static Map<String, Object?> _toJson(Match m) => {
        'id': m.id,
        'org': m.org,
        'pitchId': m.pitchId,
        'pitch': m.pitch,
        'area': m.area,
        'kickoff': m.kickoff.toIso8601String(),
        'durHours': m.durHours,
        'joined': m.joined,
        'total': m.total,
        'level': m.level,
        'desc': m.desc,
        'isPublic': m.isPublic,
      };

  static Match _fromJson(Map<String, Object?> j) {
    final org = j['org']! as String;
    return Match(
      id: j['id']! as int,
      org: org,
      orgAr: org,
      initial: org.isEmpty ? '?' : org.substring(0, 1).toUpperCase(),
      avatar: 'navy',
      pitchId: j['pitchId']! as int,
      pitch: j['pitch']! as String,
      area: j['area']! as String,
      kickoff: DateTime.parse(j['kickoff']! as String),
      durHours: j['durHours']! as int,
      joined: j['joined']! as int,
      total: j['total']! as int,
      level: j['level']! as String,
      gradIndex: (j['pitchId']! as int) % 4,
      desc: j['desc']! as String,
      descAr: j['desc']! as String,
      distanceKm: 0,
      hostedByMe: true,
      isPublic: j['isPublic']! as bool,
    );
  }
}
