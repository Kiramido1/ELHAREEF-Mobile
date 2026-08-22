import React, { useEffect, useRef } from 'react';
import {
  Animated,
  Easing,
  Pressable,
  StyleProp,
  View,
  ViewProps,
  ViewStyle,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useI18n } from '../i18n';
import { brand, layout, radius, useTheme } from '../theme';
import { ScreenEntrance, SelectFade } from './anim';
import { Txt } from './Txt';

/* ---------------------------------------------------------------- Row */

/** RTL-aware horizontal flex row. */
export function Row({
  style,
  children,
  ...rest
}: ViewProps & { children?: React.ReactNode }) {
  const { isRTL } = useI18n();
  return (
    <View
      {...rest}
      style={[{ flexDirection: isRTL ? 'row-reverse' : 'row' }, style]}
    >
      {children}
    </View>
  );
}

/* -------------------------------------------------------------- Screen */

interface ScreenProps {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  /** Skip the top inset (screens drawing under the status bar, e.g. pitch hero). */
  edgeToEdge?: boolean;
}

export function Screen({ children, style, edgeToEdge = false }: ScreenProps) {
  const { colors } = useTheme();
  const insets = useSafeAreaInsets();
  return (
    <View style={{ flex: 1, backgroundColor: colors.bg }}>
      <ScreenEntrance
        style={[
          { paddingTop: edgeToEdge ? 0 : insets.top + layout.headerTop },
          style,
        ]}
      >
        {children}
      </ScreenEntrance>
    </View>
  );
}

/* ---------------------------------------------------------- BackButton */

export function BackButton({ onPress, size = 38 }: { onPress: () => void; size?: number }) {
  const { colors } = useTheme();
  const { isRTL, t } = useI18n();
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={t('skip') === 'Skip' ? 'Back' : 'رجوع'}
      hitSlop={8}
      style={({ pressed }) => ({
        width: size,
        height: size,
        borderRadius: size / 2,
        borderWidth: 1.5,
        borderColor: colors.ink12,
        backgroundColor: colors.card,
        alignItems: 'center',
        justifyContent: 'center',
        transform: [{ scale: pressed ? 0.94 : 1 }],
      })}
    >
      {/* '‹' is bidi-mirrored automatically in RTL, same as the design markup. */}
      <Txt size={18} color={colors.ink} style={{ marginTop: -2, textAlign: 'center' }}>
        ‹
      </Txt>
    </Pressable>
  );
}

/* ------------------------------------------------------- PrimaryButton */

interface ButtonProps {
  label: string;
  onPress?: () => void;
  variant?: 'green' | 'navy' | 'outline' | 'ghost' | 'danger-outline';
  disabled?: boolean;
  disabledLabelColor?: string;
  size?: number;
  weight?: 600 | 700;
  paddingV?: number;
  style?: StyleProp<ViewStyle>;
}

export function Button({
  label,
  onPress,
  variant = 'green',
  disabled = false,
  disabledLabelColor,
  size = 15.5,
  weight = 700,
  paddingV = 16,
  style,
}: ButtonProps) {
  const { colors } = useTheme();
  const bg =
    disabled
      ? colors.disabled
      : variant === 'green'
        ? brand.green
        : variant === 'navy'
          ? colors.navyBtn
          : colors.card;
  const fg =
    disabled
      ? (disabledLabelColor ?? colors.ink35)
      : variant === 'outline'
        ? colors.ink
        : variant === 'danger-outline'
          ? brand.danger
          : '#fff';
  const borderColor =
    variant === 'outline' ? colors.ink14 : variant === 'danger-outline' ? brand.dangerBd : 'transparent';
  return (
    <Pressable
      onPress={disabled ? undefined : onPress}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled }}
      style={({ pressed }) => [
        {
          backgroundColor: variant === 'ghost' ? 'transparent' : bg,
          borderWidth: variant === 'outline' || variant === 'danger-outline' ? 1.5 : 0,
          borderColor,
          paddingVertical: paddingV,
          borderRadius: radius.card14,
          alignItems: 'center',
          justifyContent: 'center',
          transform: [{ scale: pressed && !disabled ? 0.94 : 1 }],
        },
        style,
      ]}
    >
      <Txt w={weight} size={size} color={variant === 'ghost' ? colors.ink55 : fg} style={{ textAlign: 'center' }}>
        {label}
      </Txt>
    </Pressable>
  );
}

/* ---------------------------------------------------------------- Chip */

interface ChipProps {
  label: string;
  selected?: boolean;
  onPress?: () => void;
  paddingV?: number;
  paddingH?: number;
  size?: number;
}

export function Chip({
  label,
  selected = false,
  onPress,
  paddingV = 8,
  paddingH = 14,
  size = 13,
}: ChipProps) {
  const { colors } = useTheme();
  const box = (on: boolean): ViewStyle => ({
    borderWidth: 1.5,
    borderColor: on ? colors.chipOn : colors.ink14,
    backgroundColor: on ? colors.chipOn : colors.card,
    paddingVertical: paddingV,
    paddingHorizontal: paddingH,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
  });
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityState={{ selected }}
      style={({ pressed }) => ({ transform: [{ scale: pressed ? 0.96 : 1 }] })}
    >
      <SelectFade
        on={selected}
        off={
          <View style={box(false)}>
            <Txt w={600} size={size}>
              {label}
            </Txt>
          </View>
        }
        over={
          <View style={[box(true), { width: '100%', height: '100%' }]}>
            <Txt w={600} size={size} color={colors.chipOnFg}>
              {label}
            </Txt>
          </View>
        }
      />
    </Pressable>
  );
}

/* ----------------------------------------------------------- Segmented */

interface SegmentedProps {
  options: string[];
  selectedIndex: number;
  onSelect: (index: number) => void;
  paddingV?: number;
}

export function Segmented({ options, selectedIndex, onSelect, paddingV = 10 }: SegmentedProps) {
  const { colors } = useTheme();
  const { isRTL } = useI18n();
  return (
    <View
      style={{
        flexDirection: isRTL ? 'row-reverse' : 'row',
        backgroundColor: colors.tint,
        borderRadius: radius.input,
        padding: 4,
        gap: 4,
      }}
    >
      {options.map((label, i) => (
        <SegmentedItem
          key={label}
          label={label}
          on={i === selectedIndex}
          onPress={() => onSelect(i)}
          paddingV={paddingV}
        />
      ))}
    </View>
  );
}

function SegmentedItem({
  label,
  on,
  onPress,
  paddingV,
}: {
  label: string;
  on: boolean;
  onPress: () => void;
  paddingV: number;
}) {
  const { colors } = useTheme();
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityState={{ selected: on }}
      style={{ flex: 1 }}
    >
      <SelectFade
        on={on}
        off={
          <View style={{ paddingVertical: paddingV, borderRadius: radius.md, alignItems: 'center' }}>
            <Txt w={600} size={13} color={colors.ink55}>
              {label}
            </Txt>
          </View>
        }
        over={
          <View
            style={{
              width: '100%',
              height: '100%',
              backgroundColor: colors.segOn,
              borderRadius: radius.md,
              alignItems: 'center',
              justifyContent: 'center',
              shadowColor: '#030814',
              shadowOpacity: 0.12,
              shadowRadius: 4,
              shadowOffset: { width: 0, height: 1 },
              elevation: 2,
            }}
          >
            <Txt w={600} size={13}>
              {label}
            </Txt>
          </View>
        }
      />
    </Pressable>
  );
}

/* -------------------------------------------------------- ToggleSwitch */

export function ToggleSwitch({ value, onToggle }: { value: boolean; onToggle: () => void }) {
  const { colors } = useTheme();
  const anim = useRef(new Animated.Value(value ? 1 : 0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: value ? 1 : 0,
      duration: 320,
      easing: Easing.bezier(0.16, 1, 0.3, 1),
      useNativeDriver: false,
    }).start();
  }, [value, anim]);

  return (
    <Pressable
      onPress={onToggle}
      accessibilityRole="switch"
      accessibilityState={{ checked: value }}
    >
      <Animated.View
        style={{
          width: 46,
          height: 27,
          borderRadius: radius.pill,
          backgroundColor: anim.interpolate({
            inputRange: [0, 1],
            outputRange: [colors.ink15, brand.green],
          }),
          justifyContent: 'center',
        }}
      >
        <Animated.View
          style={{
            position: 'absolute',
            top: 3,
            left: anim.interpolate({ inputRange: [0, 1], outputRange: [3, 22] }),
            width: 21,
            height: 21,
            borderRadius: 10.5,
            backgroundColor: colors.card,
            shadowColor: '#030814',
            shadowOpacity: 0.25,
            shadowRadius: 3,
            shadowOffset: { width: 0, height: 1 },
            elevation: 2,
          }}
        />
      </Animated.View>
    </Pressable>
  );
}

/* ----------------------------------------------------- RadioOptionCard */

interface RadioOptionCardProps {
  label: string;
  sub: string;
  selected: boolean;
  onPress: () => void;
}

export function RadioOptionCard({ label, sub, selected, onPress }: RadioOptionCardProps) {
  const { colors } = useTheme();
  const { isRTL } = useI18n();
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="radio"
      accessibilityState={{ selected }}
      style={{
        flexDirection: isRTL ? 'row-reverse' : 'row',
        alignItems: 'center',
        gap: 12,
        borderWidth: 1.5,
        borderColor: selected ? brand.green : colors.ink12,
        backgroundColor: selected ? colors.tint : colors.card,
        borderRadius: radius.card14,
        paddingVertical: 14,
        paddingHorizontal: 15,
      }}
    >
      <View
        style={{
          width: 19,
          height: 19,
          borderRadius: 9.5,
          borderWidth: 2,
          borderColor: selected ? brand.green : colors.ink3,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <View
          style={{
            width: 9,
            height: 9,
            borderRadius: 4.5,
            backgroundColor: selected ? brand.green : 'transparent',
          }}
        />
      </View>
      <View style={{ flex: 1 }}>
        <Txt w={700} size={14}>
          {label}
        </Txt>
        <Txt size={12} color={colors.ink55}>
          {sub}
        </Txt>
      </View>
    </Pressable>
  );
}

/* --------------------------------------------------------- ProgressBar */

export function ProgressBar({ pct, height = 6 }: { pct: number; height?: number }) {
  const { colors } = useTheme();
  const { isRTL } = useI18n();
  const clamped = Math.min(100, Math.max(0, pct));
  const anim = useRef(new Animated.Value(clamped)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: clamped,
      duration: 900,
      easing: Easing.bezier(0.16, 1, 0.3, 1),
      useNativeDriver: false,
    }).start();
  }, [clamped, anim]);

  return (
    <View
      style={{
        height,
        borderRadius: radius.pill,
        backgroundColor: colors.tint,
        overflow: 'hidden',
      }}
    >
      <Animated.View
        style={{
          height: '100%',
          width: anim.interpolate({ inputRange: [0, 100], outputRange: ['0%', '100%'] }),
          backgroundColor: brand.green,
          borderRadius: radius.pill,
          alignSelf: isRTL ? 'flex-end' : 'flex-start',
        }}
      />
    </View>
  );
}

/* -------------------------------------------------------------- Avatar */

export type AvatarPalette = 'navy' | 'tint' | 'green' | 'lime' | 'open' | 'needed';

export function Avatar({
  initial,
  palette,
  size = 40,
  fontSize = 14,
  borderColor,
}: {
  initial: string;
  palette: AvatarPalette;
  size?: number;
  fontSize?: number;
  borderColor?: string;
}) {
  const { colors } = useTheme();
  const map: Record<AvatarPalette, { bg: string; fg: string; dashed?: boolean }> = {
    navy: { bg: colors.avatarNavy, fg: brand.lime },
    tint: { bg: colors.tint, fg: brand.green },
    green: { bg: brand.green, fg: '#fff' },
    lime: { bg: brand.lime, fg: brand.navy },
    open: { bg: colors.card, fg: colors.ink35, dashed: true },
    needed: { bg: colors.card, fg: colors.ink3, dashed: true },
  };
  const p = map[palette];
  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: size / 2,
        backgroundColor: p.bg,
        alignItems: 'center',
        justifyContent: 'center',
        borderWidth: p.dashed ? 2 : borderColor ? 3 : 0,
        borderColor: p.dashed ? colors.ink25 : borderColor,
        borderStyle: p.dashed ? 'dashed' : 'solid',
      }}
    >
      <Txt w={800} size={fontSize} color={p.fg} style={{ textAlign: 'center' }}>
        {initial}
      </Txt>
    </View>
  );
}

/* ---------------------------------------------------------- StatusPill */

export function StatusPill({
  label,
  bg,
  fg,
  size = 11,
  weight = 700,
}: {
  label: string;
  bg: string;
  fg: string;
  size?: number;
  weight?: 700 | 800;
}) {
  return (
    <View
      style={{
        backgroundColor: bg,
        paddingVertical: 5,
        paddingHorizontal: 10,
        borderRadius: radius.pill,
      }}
    >
      <Txt w={weight} size={size} color={fg}>
        {label}
      </Txt>
    </View>
  );
}

/* -------------------------------------------------------------- Card */

export function Card({
  children,
  style,
  radiusValue = radius.card,
  lime = false,
}: {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  radiusValue?: number;
  lime?: boolean;
}) {
  const { colors } = useTheme();
  return (
    <View
      style={[
        {
          borderWidth: lime ? 1.5 : 1,
          borderColor: lime ? colors.limeBd : colors.ink08,
          borderRadius: radiusValue,
          backgroundColor: colors.card,
          shadowColor: '#061533',
          shadowOpacity: 0.05,
          shadowRadius: 3,
          shadowOffset: { width: 0, height: 1 },
          elevation: 1,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}

/* -------------------------------------------------- SectionHeader */

export function SectionHeader({
  title,
  actionLabel,
  onAction,
}: {
  title: string;
  actionLabel?: string;
  onAction?: () => void;
}) {
  const { colors } = useTheme();
  const { isRTL } = useI18n();
  return (
    <Row
      style={{
        alignItems: 'baseline',
        justifyContent: 'space-between',
        paddingHorizontal: layout.screenX,
      }}
    >
      <Txt w={700} size={17}>
        {title}
      </Txt>
      {actionLabel && onAction ? (
        <Pressable onPress={onAction} hitSlop={8} accessibilityRole="button">
          <Txt w={600} size={13} color={brand.green}>
            {actionLabel} ›
          </Txt>
        </Pressable>
      ) : null}
    </Row>
  );
}
