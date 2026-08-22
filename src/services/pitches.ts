import { Pitch } from '../types';
import { simulateRequest } from './network';

/** Business-rule props from the design (`pricePerHour`, `bookingFee`). */
export const PRICE_PER_HOUR = 200;
export const BOOKING_FEE = 20;

const PITCHES: Pitch[] = [
  {
    id: 0,
    name: 'Dream Sports Arena',
    area: 'Fayoum City',
    dist: '2.1 km',
    rating: '4.8',
    reviews: 124,
    price: PRICE_PER_HOUR,
    type: '8-a-side',
    availableNow: true,
    gradIndex: 0,
  },
  {
    id: 1,
    name: 'Green Field Club',
    area: 'Sinnuris',
    dist: '3.4 km',
    rating: '4.6',
    reviews: 89,
    price: 180,
    type: '5-a-side',
    availableNow: false,
    gradIndex: 1,
  },
  {
    id: 2,
    name: 'Champions Park',
    area: 'Tamiya',
    dist: '4.0 km',
    rating: '4.9',
    reviews: 203,
    price: 250,
    type: '7-a-side',
    availableNow: true,
    gradIndex: 2,
  },
  {
    id: 3,
    name: 'Victory Grounds',
    area: 'Ibsheway',
    dist: '8.2 km',
    rating: '4.5',
    reviews: 61,
    price: 150,
    type: '11-a-side',
    availableNow: false,
    gradIndex: 3,
  },
];

export function listPitches(): Promise<Pitch[]> {
  return simulateRequest(PITCHES, 700);
}

/** Synchronous accessors for data already on the client (selection state). */
export function getPitch(id: number): Pitch {
  return PITCHES[id] ?? PITCHES[0];
}

export const allPitches = PITCHES;
