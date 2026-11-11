// Pitch entity — pure Dart, no Flutter or transport types.

enum Facility {
  parking('Parking', 'باركينج'),
  changingRooms('Changing rooms', 'غرف تغيير'),
  showers('Showers', 'دُش'),
  floodlights('Floodlights', 'كشافات'),
  cafeteria('Cafeteria', 'كافيتريا'),
  wifi('Wi-Fi', 'Wi-Fi'),
  ballRental('Ball rental', 'تأجير كور');

  const Facility(this.en, this.ar);
  final String en, ar;
}

/// Pitch formats, as shown on chips and cards.
const pitchTypes = ['5-a-side', '7-a-side', '8-a-side', '11-a-side'];

class Pitch {
  const Pitch({
    required this.id,
    required this.name,
    required this.area,
    required this.areaAr,
    required this.distanceKm,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.type,
    required this.availableNow,
    required this.gradIndex,
    required this.facilities,
  });

  final int id;
  final String name, area, areaAr;
  final double distanceKm;
  final String rating;
  final int reviews;

  /// EGP per hour.
  final int price;

  /// One of [pitchTypes].
  final String type;
  final bool availableNow;
  final int gradIndex;
  final List<Facility> facilities;

  /// "2.1 km" (display helper kept for the existing cards).
  String get dist => '${distanceKm.toStringAsFixed(1)} km';

  @override
  bool operator ==(Object other) => other is Pitch && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
