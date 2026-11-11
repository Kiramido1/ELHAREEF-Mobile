// Mock pitch datasource (swap for an HTTP datasource when the API exists).
import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/features/pitches/domain/entities/pitch.dart';

/// Flat booking fee added to every booking (EGP).
const bookingFee = 20;

const _all = [
  Facility.parking,
  Facility.changingRooms,
  Facility.showers,
  Facility.floodlights,
  Facility.cafeteria,
  Facility.wifi,
  Facility.ballRental,
];

const seedPitches = <Pitch>[
  Pitch(
    id: 0,
    name: 'Dream Sports Arena',
    area: 'Fayoum City',
    areaAr: 'مدينة الفيوم',
    distanceKm: 2.1,
    rating: '4.8',
    reviews: 124,
    price: 200,
    type: '8-a-side',
    availableNow: true,
    gradIndex: 0,
    facilities: _all,
  ),
  Pitch(
    id: 1,
    name: 'Green Field Club',
    area: 'Sinnuris',
    areaAr: 'سنورس',
    distanceKm: 3.4,
    rating: '4.6',
    reviews: 89,
    price: 180,
    type: '5-a-side',
    availableNow: false,
    gradIndex: 1,
    facilities: [Facility.parking, Facility.changingRooms, Facility.floodlights, Facility.ballRental],
  ),
  Pitch(
    id: 2,
    name: 'Champions Park',
    area: 'Tamiya',
    areaAr: 'طامية',
    distanceKm: 4.0,
    rating: '4.9',
    reviews: 203,
    price: 250,
    type: '7-a-side',
    availableNow: true,
    gradIndex: 2,
    facilities: [
      Facility.parking,
      Facility.changingRooms,
      Facility.showers,
      Facility.floodlights,
      Facility.cafeteria,
      Facility.wifi,
    ],
  ),
  Pitch(
    id: 3,
    name: 'Victory Grounds',
    area: 'Ibsheway',
    areaAr: 'إبشواي',
    distanceKm: 8.2,
    rating: '4.5',
    reviews: 61,
    price: 150,
    type: '11-a-side',
    availableNow: false,
    gradIndex: 3,
    facilities: [Facility.parking, Facility.floodlights, Facility.showers],
  ),
];

/// Real pitch photography, indexed by pitch id.
const pitchPhotos = [
  'assets/pitches/pitch-0.jpg',
  'assets/pitches/pitch-1.jpg',
  'assets/pitches/pitch-2.jpg',
  'assets/pitches/pitch-3.jpg',
];

class PitchMockDatasource {
  const PitchMockDatasource();
  List<Pitch> get all => seedPitches;
  Future<List<Pitch>> fetchAll() => simulateRequest(seedPitches, 700);
}
