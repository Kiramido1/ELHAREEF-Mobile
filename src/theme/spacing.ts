/** Layout constants shared across screens, from the approved design. */
export const layout = {
  /** Horizontal screen padding used by most screens. */
  screenX: 20,
  /** Horizontal padding on auth / state screens. */
  screenXWide: 24,
  /** Top offset below the status bar used by content screens (62px in design at 390×844). */
  headerTop: 10,
  /** Bottom padding on scrollers so content clears the tab bar (110px in design). */
  tabBarClearance: 110,
  /** Circular back-button diameter. */
  backButton: 38,
} as const;

export const radius = {
  xs: 6,
  sm: 8,
  chip9: 9,
  md: 10,
  action: 11,
  input12: 12,
  input: 13,
  card14: 14,
  card15: 15,
  box: 16,
  card17: 17,
  card: 18,
  hero: 20,
  onboarding: 24,
  sheet: 26,
  pill: 999,
} as const;

export const shadows = {
  card: {
    shadowColor: '#061533',
    shadowOpacity: 0.05,
    shadowRadius: 3,
    shadowOffset: { width: 0, height: 1 },
    elevation: 1,
  },
  confirmPop: {
    shadowColor: '#24A551',
    shadowOpacity: 0.4,
    shadowRadius: 34,
    shadowOffset: { width: 0, height: 14 },
    elevation: 8,
  },
  confirmCta: {
    shadowColor: '#24A551',
    shadowOpacity: 0.35,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 10 },
    elevation: 6,
  },
  timeSelected: {
    shadowColor: '#061533',
    shadowOpacity: 0.28,
    shadowRadius: 22,
    shadowOffset: { width: 0, height: 8 },
    elevation: 5,
  },
} as const;
