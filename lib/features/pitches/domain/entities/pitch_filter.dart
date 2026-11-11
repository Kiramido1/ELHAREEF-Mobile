// Search + filter rules for the pitch list. Pure and immutable so the
// screen only holds a PitchFilter and renders `filter.apply(pitches)`.
import 'package:elhareef/features/pitches/domain/entities/pitch.dart';

enum PriceBand {
  any(null, null),
  under150(null, 150),
  mid(150, 220),
  over220(220, null);

  const PriceBand(this.min, this.max);
  final int? min, max;

  /// [min] inclusive, [max] exclusive (150 belongs to "150–220").
  bool contains(int price) => (min == null || price >= min!) && (max == null || price < max!);
}

enum DistanceBand {
  under3(3),
  under5(5),
  anywhere(null);

  const DistanceBand(this.maxKm);
  final double? maxKm;
  bool contains(double km) => maxKm == null || km < maxKm!;
}

class PitchFilter {
  const PitchFilter({this.query = '', this.type, this.price = PriceBand.any, this.distance = DistanceBand.anywhere});

  final String query;

  /// One of [pitchTypes], or null for all.
  final String? type;
  final PriceBand price;
  final DistanceBand distance;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isDefault => !hasQuery && type == null && price == PriceBand.any && distance == DistanceBand.anywhere;

  PitchFilter copyWith({String? query, String? Function()? type, PriceBand? price, DistanceBand? distance}) =>
      PitchFilter(
        query: query ?? this.query,
        type: type != null ? type() : this.type,
        price: price ?? this.price,
        distance: distance ?? this.distance,
      );

  /// Every whitespace-separated term must appear in the pitch's name, area
  /// (EN or AR), type or one of its facilities (EN or AR).
  bool matches(Pitch p) {
    if (type != null && p.type != type) return false;
    if (!price.contains(p.price)) return false;
    if (!distance.contains(p.distanceKm)) return false;
    final terms = query.toLowerCase().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (terms.isEmpty) return true;
    final haystack = [
      p.name,
      p.area,
      p.areaAr,
      p.type,
      for (final f in p.facilities) ...[f.en, f.ar],
    ].join(' ').toLowerCase();
    return terms.every(haystack.contains);
  }

  List<Pitch> apply(Iterable<Pitch> pitches) => pitches.where(matches).toList();
}
