// Port of src/services/pitches.ts (mock repository).
import '../types.dart';
import 'network.dart';

/// Business-rule props from the design (`pricePerHour`, `bookingFee`).
const pricePerHour = 200;
const bookingFee = 20;

const allPitches = <Pitch>[
  Pitch(id: 0, name: 'Dream Sports Arena', area: 'Fayoum City', dist: '2.1 km', rating: '4.8', reviews: 124, price: pricePerHour, type: '8-a-side', availableNow: true, gradIndex: 0),
  Pitch(id: 1, name: 'Green Field Club', area: 'Sinnuris', dist: '3.4 km', rating: '4.6', reviews: 89, price: 180, type: '5-a-side', availableNow: false, gradIndex: 1),
  Pitch(id: 2, name: 'Champions Park', area: 'Tamiya', dist: '4.0 km', rating: '4.9', reviews: 203, price: 250, type: '7-a-side', availableNow: true, gradIndex: 2),
  Pitch(id: 3, name: 'Victory Grounds', area: 'Ibsheway', dist: '8.2 km', rating: '4.5', reviews: 61, price: 150, type: '11-a-side', availableNow: false, gradIndex: 3),
];

Future<List<Pitch>> listPitches() => simulateRequest(allPitches, 700);

/// Synchronous accessor for data already on the client (selection state).
Pitch getPitch(int id) => id >= 0 && id < allPitches.length ? allPitches[id] : allPitches[0];

/// Real pitch photography, indexed by pitch id.
const pitchPhotos = [
  'assets/pitches/pitch-0.jpg',
  'assets/pitches/pitch-1.jpg',
  'assets/pitches/pitch-2.jpg',
  'assets/pitches/pitch-3.jpg',
];
