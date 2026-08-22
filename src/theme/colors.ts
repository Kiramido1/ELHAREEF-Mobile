/**
 * ELHAREEF design tokens — extracted verbatim from the approved Claude
 * Design (`ELHAREEF App.dc.html` `:root` / `[data-theme="dark"]` blocks).
 *
 * Brand constants (identical in both themes):
 *   Pitch Navy #061533 · Turf Green #24A551 · Kick Lime #BDF961
 *   Pitch Tint #F0F9E4 · Cloud White #FBFCFA
 */
export const brand = {
  navy: '#061533',
  green: '#24A551',
  greenHover: '#1e8f46',
  lime: '#BDF961',
  tint: '#F0F9E4',
  cloud: '#FBFCFA',
  danger: '#d64545',
  dangerBg: 'rgba(214,69,69,.1)',
  dangerBd: 'rgba(214,69,69,.35)',
  phoneShell: '#0a0d16',
} as const;

export interface ThemeColors {
  bg: string;
  card: string;
  tint: string;
  bar: string;
  ink: string;
  navyBtn: string;
  chipOn: string;
  chipOnFg: string;
  segOn: string;
  disabled: string;
  chipGray: string;
  shim2: string;
  avatarNavy: string;
  limeBd: string;
  limeChip: string;
  limeChipFg: string;
  limeTint: string;
  ink06: string;
  ink08: string;
  ink1: string;
  ink12: string;
  ink14: string;
  ink15: string;
  ink25: string;
  ink3: string;
  ink35: string;
  ink4: string;
  ink45: string;
  ink5: string;
  ink55: string;
  ink6: string;
  ink65: string;
  ink7: string;
  ink75: string;
}

export const lightColors: ThemeColors = {
  bg: '#FBFCFA',
  card: '#ffffff',
  tint: '#F0F9E4',
  bar: 'rgba(251,252,250,.95)',
  ink: '#061533',
  navyBtn: '#061533',
  chipOn: '#061533',
  chipOnFg: '#fff',
  segOn: '#fff',
  disabled: '#e4e9e2',
  chipGray: '#eef1f5',
  shim2: '#e2eed2',
  avatarNavy: '#061533',
  limeBd: '#BDF961',
  limeChip: '#BDF961',
  limeChipFg: '#061533',
  limeTint: 'rgba(189,249,97,.21)',
  ink06: 'rgba(6,21,51,.06)',
  ink08: 'rgba(6,21,51,.08)',
  ink1: 'rgba(6,21,51,.1)',
  ink12: 'rgba(6,21,51,.12)',
  ink14: 'rgba(6,21,51,.14)',
  ink15: 'rgba(6,21,51,.15)',
  ink25: 'rgba(6,21,51,.25)',
  ink3: 'rgba(6,21,51,.3)',
  ink35: 'rgba(6,21,51,.35)',
  ink4: 'rgba(6,21,51,.4)',
  ink45: 'rgba(6,21,51,.45)',
  ink5: 'rgba(6,21,51,.5)',
  ink55: 'rgba(6,21,51,.55)',
  ink6: 'rgba(6,21,51,.6)',
  ink65: 'rgba(6,21,51,.65)',
  ink7: 'rgba(6,21,51,.7)',
  ink75: 'rgba(6,21,51,.75)',
};

export const darkColors: ThemeColors = {
  bg: '#0C1220',
  card: '#131A2C',
  tint: '#1A2338',
  bar: 'rgba(12,18,32,.93)',
  ink: '#E6ECF7',
  navyBtn: '#243356',
  chipOn: '#DFE7F4',
  chipOnFg: '#0F172A',
  segOn: '#253251',
  disabled: '#1D2740',
  chipGray: '#1A2338',
  shim2: '#222F4E',
  avatarNavy: '#2B3A61',
  limeBd: 'rgba(189,249,97,.35)',
  limeChip: 'rgba(189,249,97,.14)',
  limeChipFg: '#BDF961',
  limeTint: 'rgba(189,249,97,.07)',
  ink06: 'rgba(226,233,246,.07)',
  ink08: 'rgba(226,233,246,.09)',
  ink1: 'rgba(226,233,246,.11)',
  ink12: 'rgba(226,233,246,.13)',
  ink14: 'rgba(226,233,246,.15)',
  ink15: 'rgba(226,233,246,.17)',
  ink25: 'rgba(226,233,246,.28)',
  ink3: 'rgba(226,233,246,.33)',
  ink35: 'rgba(226,233,246,.38)',
  ink4: 'rgba(226,233,246,.44)',
  ink45: 'rgba(226,233,246,.5)',
  ink5: 'rgba(226,233,246,.55)',
  ink55: 'rgba(226,233,246,.6)',
  ink6: 'rgba(226,233,246,.66)',
  ink65: 'rgba(226,233,246,.7)',
  ink7: 'rgba(226,233,246,.74)',
  ink75: 'rgba(226,233,246,.78)',
};

/** Pitch-card gradient pairs, in design order (`grads` array). */
export const pitchGradients: [string, string][] = [
  ['#2fae5c', '#187a3d'],
  ['#3cb96a', '#1d8746'],
  ['#28a155', '#0f6c33'],
  ['#45c076', '#24A551'],
];

/** Onboarding hero gradients, per slide (`obData[].bg`). */
export const onboardingGradients: [string, string][] = [
  ['#24A551', '#0f6c33'],
  ['#061533', '#0d2a5e'],
  ['#187a3d', '#061533'],
];
