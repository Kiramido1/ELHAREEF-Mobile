import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { Image, ImageSourcePropType, StyleProp, View, ViewStyle } from 'react-native';
import { pitchGradients } from '../theme';

/**
 * Pitch visual: real pitch photo over the brand gradient (the gradient shows
 * while the image loads, or wherever no photo is supplied — the design's own
 * fallback layer).
 */
interface PitchArtProps {
  gradIndex: number;
  style?: StyleProp<ViewStyle>;
  /** Pitch photograph rendered cover over the gradient. */
  photo?: ImageSourcePropType;
  /** Draw inset pitch lines (used on hero/summary cards). */
  lines?: boolean;
  /** Draw the small centre circle (booking-details hero). */
  circle?: boolean;
  inset?: number;
  children?: React.ReactNode;
}

export function PitchArt({
  gradIndex,
  style,
  photo,
  lines = false,
  circle = false,
  inset = 10,
  children,
}: PitchArtProps) {
  const [from, to] = pitchGradients[gradIndex % pitchGradients.length];
  return (
    <LinearGradient
      colors={[from, to]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={[{ overflow: 'hidden' }, style]}
    >
      {photo ? (
        <Image
          source={photo}
          resizeMode="cover"
          style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, width: '100%', height: '100%' }}
        />
      ) : null}
      {lines ? (
        <View
          pointerEvents="none"
          style={{
            position: 'absolute',
            top: inset,
            bottom: inset,
            left: inset,
            right: inset,
            borderWidth: 1.5,
            borderColor: 'rgba(251,252,250,.35)',
            borderRadius: 8,
          }}
        />
      ) : null}
      {circle ? (
        <View
          pointerEvents="none"
          style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            width: 40,
            height: 40,
            marginTop: -20,
            marginLeft: -20,
            borderWidth: 1.5,
            borderColor: 'rgba(251,252,250,.4)',
            borderRadius: 20,
          }}
        />
      ) : null}
      {children}
    </LinearGradient>
  );
}
