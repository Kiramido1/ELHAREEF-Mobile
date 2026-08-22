import React, { useState } from 'react';
import {
  Platform,
  Pressable,
  StyleProp,
  TextInput,
  TextInputProps,
  TextStyle,
  View,
} from 'react-native';
import { useI18n } from '../i18n';
import { brand, fonts, radius, useTheme } from '../theme';
import { EyeIcon, EyeOffIcon } from './icons';

/**
 * Text input matching the design: 1.5px ink14 border, radius 13, card bg,
 * green border on focus.
 */
export function Input({
  style,
  ...rest
}: TextInputProps & { style?: StyleProp<TextStyle> }) {
  const { colors } = useTheme();
  const { isRTL } = useI18n();
  const [focused, setFocused] = useState(false);
  return (
    <TextInput
      placeholderTextColor={colors.ink45}
      {...rest}
      onFocus={(e) => {
        setFocused(true);
        rest.onFocus?.(e);
      }}
      onBlur={(e) => {
        setFocused(false);
        rest.onBlur?.(e);
      }}
      style={[
        {
          paddingVertical: 15,
          paddingHorizontal: 16,
          borderWidth: 1.5,
          borderColor: focused ? brand.green : colors.ink14,
          borderRadius: radius.input,
          fontSize: 15,
          fontFamily: isRTL ? fonts.arabic : fonts.regular,
          backgroundColor: colors.card,
          color: colors.ink,
          textAlign: isRTL ? 'right' : 'left',
          // The focus ring is drawn by the border color; suppress the web UA outline.
          ...(Platform.OS === 'web' ? ({ outlineWidth: 0 } as TextStyle) : null),
        },
        style,
      ]}
    />
  );
}

/**
 * Secure input with a show/hide eye toggle, matching the design's input
 * styling. The toggle sits at the trailing edge (leading edge in RTL).
 */
export function PasswordInput({
  error = false,
  style,
  ...rest
}: TextInputProps & { error?: boolean; style?: StyleProp<TextStyle> }) {
  const { colors } = useTheme();
  const { isRTL, t } = useI18n();
  const [hidden, setHidden] = useState(true);
  return (
    <View style={{ justifyContent: 'center' }}>
      <Input
        {...rest}
        secureTextEntry={hidden}
        autoCapitalize="none"
        autoCorrect={false}
        textContentType="password"
        style={[
          error ? { borderColor: brand.danger } : null,
          isRTL ? { paddingLeft: 48 } : { paddingRight: 48 },
          style,
        ]}
      />
      <Pressable
        onPress={() => setHidden((h) => !h)}
        hitSlop={10}
        accessibilityRole="button"
        accessibilityLabel={hidden ? t('showPw') : t('hidePw')}
        style={{
          position: 'absolute',
          [isRTL ? 'left' : 'right']: 16,
        }}
      >
        {hidden ? (
          <EyeIcon size={19} color={colors.ink45} />
        ) : (
          <EyeOffIcon size={19} color={colors.ink45} />
        )}
      </Pressable>
    </View>
  );
}
