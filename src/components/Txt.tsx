import React from 'react';
import { StyleProp, Text, TextProps, TextStyle } from 'react-native';
import { useI18n } from '../i18n';
import { fontFor, fonts, useTheme } from '../theme';

type Weight = 400 | 500 | 600 | 700 | 800;

interface TxtProps extends TextProps {
  /** Design font-weight (Archivo 400–800). */
  w?: Weight;
  size?: number;
  color?: string;
  /** Force the Arabic face (IBM Plex Sans Arabic) regardless of language. */
  ar?: boolean;
  lineHeight?: number;
  letterSpacing?: number;
  center?: boolean;
  style?: StyleProp<TextStyle>;
  children: React.ReactNode;
}

/**
 * Text primitive that maps design font-weights onto the loaded Archivo
 * faces, switching to IBM Plex Sans Arabic when Arabic is active.
 */
export function Txt({
  w = 400,
  size = 14,
  color,
  ar = false,
  lineHeight,
  letterSpacing,
  center = false,
  style,
  children,
  ...rest
}: TxtProps) {
  const { colors } = useTheme();
  const { isRTL } = useI18n();
  const arabic = ar || isRTL;
  const fontFamily = arabic ? (w >= 600 ? fonts.arabicSemiBold : fonts.arabic) : fontFor(w);
  return (
    <Text
      {...rest}
      style={[
        {
          fontFamily,
          fontSize: size,
          color: color ?? colors.ink,
          lineHeight,
          letterSpacing,
          textAlign: center ? 'center' : isRTL ? 'right' : 'left',
          writingDirection: isRTL ? 'rtl' : 'ltr',
        },
        style,
      ]}
    >
      {children}
    </Text>
  );
}
