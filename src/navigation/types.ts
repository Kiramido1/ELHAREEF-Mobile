import type { NavigatorScreenParams } from '@react-navigation/native';

export type MainTabParamList = {
  Home: undefined;
  Discover: undefined;
  Bookings: undefined;
  MyMatches: undefined;
  Profile: undefined;
};

export type RootStackParamList = {
  Splash: undefined;
  Onboarding: undefined;
  Login: undefined;
  Signup: undefined;
  ForgotPassword: undefined;
  Tabs: NavigatorScreenParams<MainTabParamList> | undefined;
  Search: { openFilters?: boolean } | undefined;
  Pitch: { pitchId: number };
  Booking: undefined;
  Summary: undefined;
  Confirmed: undefined;
  FindPlayers: undefined;
  CreateMatch: undefined;
  MatchDetails: { matchId: number };
  MatchFull: { matchId: number };
  PlayerProfile: { matchId: number };
  Chat: undefined;
  BookingDetails: undefined;
  Notifications: undefined;
  Settings: undefined;
  PaymentFailed: undefined;
  Offline: undefined;
};
