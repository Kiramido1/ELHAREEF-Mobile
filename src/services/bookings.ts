import { BookingRecord } from '../types';
import { PaymentDeclinedError, simulateRequest } from './network';

export const BOOKING_ID = 'EH-84213';

/** Static history shown in My bookings (design's `BK` table, minus the live row). */
export const PAST_BOOKINGS: BookingRecord[] = [
  {
    id: 'EH-83550',
    pitch: 'Green Field Club',
    date: 'Sunday, Aug 30',
    dateAr: 'الأحد، 30 أغسطس',
    time: '7:00 PM – 8:00 PM',
    timeAr: '7:00 م – 8:00 م',
    dur: '1 hour',
    durAr: 'ساعة',
    status: 'confirmed',
    price: 200,
  },
  {
    id: 'EH-82101',
    pitch: 'Champions Park',
    date: 'Sunday, Aug 9',
    dateAr: 'الأحد، 9 أغسطس',
    time: '9:00 PM – 11:00 PM',
    timeAr: '9:00 م – 11:00 م',
    dur: '2 hours',
    durAr: 'ساعتين',
    status: 'completed',
    price: 520,
  },
  {
    id: 'EH-81766',
    pitch: 'Victory Grounds',
    date: 'Tuesday, Jul 28',
    dateAr: 'الثلاثاء، 28 يوليو',
    time: '6:00 PM – 7:00 PM',
    timeAr: '6:00 م – 7:00 م',
    dur: '1 hour',
    durAr: 'ساعة',
    status: 'completed',
    price: 170,
  },
  {
    id: 'EH-80412',
    pitch: 'Green Field Club',
    date: 'Wednesday, Jul 15',
    dateAr: 'الأربعاء، 15 يوليو',
    time: '8:00 PM – 9:00 PM',
    timeAr: '8:00 م – 9:00 م',
    dur: '1 hour',
    durAr: 'ساعة',
    status: 'cancelled',
    price: 200,
  },
];

let cardAttempts = 0;

/**
 * Confirm a booking. Card payments are declined on the first attempt
 * (exercising the designed "Payment failed" state); the retry succeeds.
 * Wallet payments always go through.
 */
export function confirmBooking(paymentMethod: 'card' | 'wallet'): Promise<{ bookingId: string }> {
  if (paymentMethod === 'card') {
    cardAttempts += 1;
    if (cardAttempts % 2 === 1) {
      return simulateRequest(null, 900).then(() => {
        throw new PaymentDeclinedError();
      });
    }
  }
  return simulateRequest({ bookingId: BOOKING_ID }, 800);
}

/** Cash-at-venue path from the failure screen — always succeeds. */
export function confirmBookingCash(): Promise<{ bookingId: string }> {
  return simulateRequest({ bookingId: BOOKING_ID }, 500);
}
