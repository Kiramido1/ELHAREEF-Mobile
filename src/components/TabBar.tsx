import { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import React, { useEffect, useRef } from 'react';
import { Animated, Pressable, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useI18n } from '../i18n';
import { brand, useTheme } from '../theme';
import { Txt } from './Txt';
import { CalendarIcon, HomeIcon, PlayersIcon, ProfileIcon, SearchIcon } from './icons';

const ICONS = {
  Home: HomeIcon,
  Discover: SearchIcon,
  Bookings: CalendarIcon,
  MyMatches: PlayersIcon,
  Profile: ProfileIcon,
} as const;

const LABEL_KEYS = {
  Home: 'nav0',
  Discover: 'nav1',
  Bookings: 'nav2',
  MyMatches: 'nav3',
  Profile: 'nav4',
} as const;

/** Subtle spring pop on the icon when its tab becomes active. */
function TabIcon({ focused, children }: { focused: boolean; children: React.ReactNode }) {
  const anim = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    if (focused) {
      anim.setValue(0.8);
      Animated.spring(anim, { toValue: 1, friction: 5, tension: 90, useNativeDriver: true }).start();
    }
  }, [focused, anim]);
  return <Animated.View style={{ transform: [{ scale: anim }] }}>{children}</Animated.View>;
}

/** Bottom tab bar matching the design: 22px stroke icons + 10.5px labels. */
export function TabBar({ state, navigation }: BottomTabBarProps) {
  const { colors } = useTheme();
  const { t, isRTL } = useI18n();
  const insets = useSafeAreaInsets();

  return (
    <View
      style={{
        flexDirection: isRTL ? 'row-reverse' : 'row',
        backgroundColor: colors.bar,
        borderTopWidth: 1,
        borderTopColor: colors.ink08,
        paddingTop: 9,
        paddingHorizontal: 8,
        paddingBottom: Math.max(insets.bottom, 12) + 10,
      }}
    >
      {state.routes.map((route, index) => {
        const focused = state.index === index;
        const name = route.name as keyof typeof ICONS;
        const Icon = ICONS[name];
        const color = focused ? brand.green : colors.ink4;
        return (
          <Pressable
            key={route.key}
            accessibilityRole="button"
            accessibilityState={{ selected: focused }}
            accessibilityLabel={t(LABEL_KEYS[name])}
            onPress={() => {
              const event = navigation.emit({
                type: 'tabPress',
                target: route.key,
                canPreventDefault: true,
              });
              if (!focused && !event.defaultPrevented) {
                navigation.navigate(route.name);
              }
            }}
            style={{ flex: 1, alignItems: 'center', gap: 4 }}
          >
            <TabIcon focused={focused}>
              <Icon size={22} color={color} />
            </TabIcon>
            <Txt w={700} size={10.5} color={color} style={{ textAlign: 'center' }}>
              {t(LABEL_KEYS[name])}
            </Txt>
          </Pressable>
        );
      })}
    </View>
  );
}
