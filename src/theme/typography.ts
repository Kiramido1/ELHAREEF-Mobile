/**
 * Type scale from the approved design.
 * Archivo carries headings & UI; IBM Plex Sans Arabic carries Arabic text.
 * Design weights used: 400 / 500 / 600 / 700 / 800 (Archivo), 400 / 600 (Arabic).
 */
export const fonts = {
  regular: 'Archivo_400Regular',
  medium: 'Archivo_500Medium',
  semiBold: 'Archivo_600SemiBold',
  bold: 'Archivo_700Bold',
  extraBold: 'Archivo_800ExtraBold',
  arabic: 'IBMPlexSansArabic_400Regular',
  arabicSemiBold: 'IBMPlexSansArabic_600SemiBold',
} as const;

/** Maps a design font-weight to the matching loaded font family. */
export const fontFor = (weight: 400 | 500 | 600 | 700 | 800): string =>
  ({
    400: fonts.regular,
    500: fonts.medium,
    600: fonts.semiBold,
    700: fonts.bold,
    800: fonts.extraBold,
  })[weight];

export const fontSize = {
  micro: 10.5,
  tiny: 11,
  caption: 11.5,
  small: 12,
  smallPlus: 12.5,
  body: 13,
  bodyPlus: 13.5,
  base: 14,
  basePlus: 14.5,
  medium: 15,
  mediumPlus: 15.5,
  subtitle: 16,
  subtitlePlus: 16.5,
  sectionTitle: 17,
  headerTitle: 18,
  price: 19,
  statValue: 20,
  greeting: 21,
  pitchName: 22,
  pageTitle: 23,
  stateTitle: 24,
  confirmTitle: 25,
  obTitle: 27,
  authTitle: 28,
} as const;
