import React, { createContext, useContext, useMemo, useState } from 'react';
import { useI18n } from '../i18n';
import { BOOKING_FEE, getPitch } from '../services/pitches';
import { Pitch } from '../types';

export type PayMode = 'full' | 'deposit';
export type PayMethod = 'card' | 'wallet';

interface BookingState {
  selPitchId: number;
  calMonth: 0 | 1;
  selMonth: 0 | 1;
  selDay: number;
  selTime: number | null;
  selDur: 1 | 2 | 3 | 4;
  recur: boolean;
  payMode: PayMode;
  payMethod: PayMethod;
}

interface BookingActions {
  selectPitch: (id: number) => void;
  setCalMonth: (m: 0 | 1) => void;
  selectDay: (month: 0 | 1, day: number) => void;
  selectTime: (hour: number) => void;
  selectDur: (hours: 1 | 2 | 3 | 4) => void;
  toggleRecur: () => void;
  setPayMode: (mode: PayMode) => void;
  setPayMethod: (method: PayMethod) => void;
  resetSelections: () => void;
}

const initialState: BookingState = {
  selPitchId: 0,
  calMonth: 0,
  selMonth: 0,
  selDay: 21,
  selTime: null,
  selDur: 2,
  recur: false,
  payMode: 'full',
  payMethod: 'card',
};

const BookingContext = createContext<(BookingState & BookingActions) | null>(null);

export function BookingProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<BookingState>(initialState);

  const actions = useMemo<BookingActions>(
    () => ({
      selectPitch: (id) => setState((s) => ({ ...s, selPitchId: id })),
      setCalMonth: (m) => setState((s) => ({ ...s, calMonth: m })),
      selectDay: (month, day) => setState((s) => ({ ...s, selMonth: month, selDay: day })),
      selectTime: (hour) => setState((s) => ({ ...s, selTime: hour })),
      selectDur: (hours) => setState((s) => ({ ...s, selDur: hours })),
      toggleRecur: () =>
        setState((s) => ({ ...s, recur: !s.recur, payMode: !s.recur ? 'deposit' : 'full' })),
      setPayMode: (mode) => setState((s) => ({ ...s, payMode: mode })),
      setPayMethod: (method) => setState((s) => ({ ...s, payMethod: method })),
      resetSelections: () => setState(initialState),
    }),
    [],
  );

  const value = useMemo(() => ({ ...state, ...actions }), [state, actions]);
  return <BookingContext.Provider value={value}>{children}</BookingContext.Provider>;
}

export function useBooking() {
  const ctx = useContext(BookingContext);
  if (!ctx) throw new Error('useBooking must be used within BookingProvider');
  return ctx;
}

/** Booking months exposed to the calendar (Aug/Sep 2026, as designed). */
export const BOOKING_MONTHS = [
  { nameEn: 'August 2026', nameAr: 'أغسطس 2026', monthIndex: 7, length: 31 },
  { nameEn: 'September 2026', nameAr: 'سبتمبر 2026', monthIndex: 8, length: 30 },
] as const;

/** Bookable start hours and the busy ones (line-through in the design). */
export const SLOT_HOURS = [16, 17, 18, 19, 20, 21, 22];
export const BUSY_HOURS = [17, 19];
export const DURATIONS: (1 | 2 | 3 | 4)[] = [1, 2, 3, 4];

export interface BookingDerived {
  pitch: Pitch;
  /** 12-hour clock formatter, localized AM/PM. */
  fmtHour: (h: number) => string;
  dateStr: string;
  shortDate: (offsetWeeks: number) => string;
  rangeStr: string;
  durStr: string;
  startStr: string;
  timePicked: boolean;
  sessions: number;
  price: number;
  fee: number;
  total: number;
  deposit: number;
  remaining: number;
  dueNow: number;
  recurDates: string[];
}

const WEEKDAYS_EN = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const WEEKDAYS_AR = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
const MONTHS_EN = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const MONTHS_AR = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

export const WEEKDAY_SHORT_EN = ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];
export const WEEKDAY_SHORT_AR = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

/** All derived booking values (price math identical to the design script). */
export function useBookingDerived(): BookingDerived {
  const booking = useBooking();
  const { lang, t } = useI18n();
  const en = lang === 'en';

  return useMemo(() => {
    const pitch = getPitch(booking.selPitchId);
    const fmtHour = (h: number) =>
      `${((h + 11) % 12) + 1}:00 ${h % 24 >= 12 ? t('pm') : t('am')}`;

    const weekdays = en ? WEEKDAYS_EN : WEEKDAYS_AR;
    const months = en ? MONTHS_EN : MONTHS_AR;
    const fdate = (dt: Date) =>
      en
        ? `${weekdays[dt.getDay()]}, ${months[dt.getMonth()]} ${dt.getDate()}`
        : `${weekdays[dt.getDay()]}، ${dt.getDate()} ${months[dt.getMonth()]}`;
    const fshort = (dt: Date) =>
      en ? `${months[dt.getMonth()]} ${dt.getDate()}` : `${dt.getDate()} ${months[dt.getMonth()]}`;

    const monthDef = BOOKING_MONTHS[booking.selMonth];
    const selDate = new Date(2026, monthDef.monthIndex, booking.selDay);
    const t0 = booking.selTime ?? 20;

    const recurDates: string[] = [];
    for (let k = 0; k < 4; k++) {
      recurDates.push(fshort(new Date(2026, monthDef.monthIndex, booking.selDay + 7 * k)));
    }

    const sessions = booking.recur ? 4 : 1;
    const price = booking.selDur * pitch.price * sessions;
    const fee = BOOKING_FEE;
    const total = price + fee;
    const deposit = Math.max(50, Math.round((total * 0.25) / 5) * 5);
    const dueNow = booking.payMode === 'deposit' ? deposit : total;

    const durStr = en
      ? `${booking.selDur} ${booking.selDur === 1 ? 'hour' : 'hours'}`
      : booking.selDur === 1
        ? 'ساعة'
        : booking.selDur === 2
          ? 'ساعتين'
          : `${booking.selDur} ساعات`;

    return {
      pitch,
      fmtHour,
      dateStr: fdate(selDate),
      shortDate: (k: number) => fshort(new Date(2026, monthDef.monthIndex, booking.selDay + 7 * k)),
      rangeStr: `${fmtHour(t0)} – ${fmtHour(t0 + booking.selDur)}`,
      durStr,
      startStr: fmtHour(t0),
      timePicked: booking.selTime !== null,
      sessions,
      price,
      fee,
      total,
      deposit,
      remaining: total - deposit,
      dueNow,
      recurDates,
    };
  }, [booking, en, t]);
}
