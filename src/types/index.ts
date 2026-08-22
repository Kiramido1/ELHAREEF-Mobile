export type PitchType = '5-a-side' | '7-a-side' | '8-a-side' | '11-a-side';
export type SkillLevel = 'Beginner' | 'Intermediate' | 'Advanced' | 'Any level';

export interface Pitch {
  id: number;
  name: string;
  area: string;
  dist: string;
  rating: string;
  reviews: number;
  price: number;
  type: PitchType;
  availableNow: boolean;
  /** Index into the shared pitch gradient palette. */
  gradIndex: number;
}

export type JoinStatus = 'none' | 'pending' | 'joined';

export interface Match {
  id: number;
  org: string;
  orgAr: string;
  initial: string;
  /** Avatar palette slot: 'navy' | 'tint' | 'green' — resolved by theme. */
  avatar: 'navy' | 'tint' | 'green';
  pitch: string;
  area: string;
  day: string;
  time: string;
  durHours: 1 | 2;
  joined: number;
  total: number;
  level: SkillLevel;
  gradIndex: number;
  desc: string;
  descAr: string;
}

export type BookingStatus = 'confirmed' | 'completed' | 'cancelled';

export interface BookingRecord {
  id: string;
  pitch: string;
  date: string;
  dateAr: string;
  time: string;
  timeAr: string;
  dur: string;
  durAr: string;
  status: BookingStatus;
  price: number;
}

export interface ChatMessage {
  id: number;
  kind: 'system' | 'other' | 'mine';
  text: string;
  textAr?: string;
  who?: string;
  whoAr?: string;
  initial?: string;
  avatar?: 'navy' | 'tint';
}

export interface NotificationItem {
  id: number;
  unread: boolean;
  dot: 'green' | 'lime' | 'muted' | 'danger';
  text: string;
  textAr: string;
  time: string;
  timeAr: string;
}
