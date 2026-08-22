import { useIsFocused } from '@react-navigation/native';
import React, { useEffect, useRef, useState } from 'react';
import { Animated, Dimensions, Easing, StyleProp, View, ViewStyle } from 'react-native';

/** The design's signature curve — used by ehScreen / ehPick / ehMsgIn. */
export const easeOutExpo = Easing.bezier(0.16, 1, 0.3, 1);

/**
 * The design's `ehScreen` entrance (fade + 14px rise, 450ms,
 * cubic-bezier(.16,1,.3,1)), replayed on every focus — going forward and
 * coming back. The fade is compressed into the first ~35% of the timeline
 * (≈60ms with this front-loaded curve), so components read as fully clear
 * almost immediately while the soft rise carries the rest of the motion.
 */
export function ScreenEntrance({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}) {
  const anim = useRef(new Animated.Value(1)).current;
  const focused = useIsFocused();

  useEffect(() => {
    if (focused) {
      anim.setValue(0);
      Animated.timing(anim, {
        toValue: 1,
        duration: 450,
        easing: easeOutExpo,
        useNativeDriver: true,
      }).start();
    }
  }, [focused, anim]);

  return (
    <Animated.View
      style={[
        {
          flex: 1,
          opacity: anim.interpolate({ inputRange: [0, 0.35, 1], outputRange: [0, 1, 1] }),
          transform: [
            { translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [14, 0] }) },
          ],
        },
        style,
      ]}
    >
      {children}
    </Animated.View>
  );
}

/**
 * Gentle selection transition: the "selected" look cross-fades over the
 * unselected one (no scaling, no bounce — just a soft colour change).
 * `off` renders in flow and defines the size; `over` is layered on top and
 * fades in/out with `on`.
 */
export function SelectFade({
  on,
  off,
  over,
  duration = 260,
  style,
}: {
  on: boolean;
  off: React.ReactNode;
  over: React.ReactNode;
  duration?: number;
  style?: StyleProp<ViewStyle>;
}) {
  const anim = useRef(new Animated.Value(on ? 1 : 0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: on ? 1 : 0,
      duration,
      easing: Easing.bezier(0.4, 0, 0.2, 1),
      useNativeDriver: true,
    }).start();
  }, [on, anim, duration]);

  return (
    <View style={style}>
      {off}
      <Animated.View
        pointerEvents="none"
        style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, opacity: anim }}
      >
        {over}
      </Animated.View>
    </View>
  );
}

/**
 * Chat-message entrance (design's `ehMsgIn`): fade + 12px rise + slight
 * scale-up on mount, 300ms.
 */
export function MsgIn({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}) {
  const anim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: 1,
      duration: 450,
      easing: easeOutExpo,
      useNativeDriver: true,
    }).start();
  }, [anim]);

  return (
    <Animated.View
      style={[
        {
          opacity: anim,
          transform: [
            { translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [12, 0] }) },
            { scale: anim.interpolate({ inputRange: [0, 1], outputRange: [0.94, 1] }) },
          ],
        },
        style,
      ]}
    >
      {children}
    </Animated.View>
  );
}

/** Staggered section entrance for list/section reveals (fade + 16px rise). */
export function FadeInUp({
  children,
  delay = 0,
  style,
}: {
  children: React.ReactNode;
  delay?: number;
  style?: StyleProp<ViewStyle>;
}) {
  const anim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: 1,
      duration: 700,
      delay,
      easing: easeOutExpo,
      useNativeDriver: true,
    }).start();
  }, [anim, delay]);

  return (
    <Animated.View
      style={[
        {
          opacity: anim,
          transform: [
            { translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [16, 0] }) },
          ],
        },
        style,
      ]}
    >
      {children}
    </Animated.View>
  );
}

/* ------------------------------------------------------- Scroll reveal */

/**
 * Shared scroll driver: attach `onScroll` to an Animated.ScrollView /
 * Animated.FlatList and pass `scrollY` to RevealOnScroll children.
 */
export function useScrollReveal() {
  const scrollY = useRef(new Animated.Value(0)).current;
  const onScroll = Animated.event([{ nativeEvent: { contentOffset: { y: scrollY } } }], {
    useNativeDriver: true,
  });
  return { scrollY, onScroll };
}

/**
 * Reveals its content as it scrolls into view: a soft 18px rise + fade tied
 * directly to the finger (scroll position), not a timer. Content already on
 * screen renders fully visible.
 */
export function RevealOnScroll({
  scrollY,
  children,
  style,
}: {
  scrollY: Animated.Value;
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}) {
  const ref = useRef<View>(null);
  const [top, setTop] = useState<number | null>(null);

  const onLayout = () => {
    // Position within the viewport at current scroll ≈ content offset trigger.
    ref.current?.measureInWindow((_x, y) => setTop(y));
  };

  const winH = Dimensions.get('window').height;
  // Not yet measured, or already visible on first paint → show as-is.
  if (top === null || top < winH - 40) {
    return (
      <View ref={ref} onLayout={onLayout} style={style}>
        {children}
      </View>
    );
  }

  const start = top - winH; // item's top touches the viewport bottom
  // Completes within 140px of scrolling — short enough that even the last
  // card on a page always finishes its reveal before the scroll runs out
  // (a longer distance left bottom cards stuck semi-transparent).
  const end = start + 140;
  return (
    <Animated.View
      ref={ref}
      onLayout={onLayout}
      style={[
        {
          opacity: scrollY.interpolate({
            inputRange: [start, end],
            outputRange: [0, 1],
            extrapolate: 'clamp',
          }),
          transform: [
            {
              translateY: scrollY.interpolate({
                inputRange: [start, end],
                outputRange: [20, 0],
                extrapolate: 'clamp',
              }),
            },
            {
              // Simple extra touch: the card grows gently as it reveals.
              scale: scrollY.interpolate({
                inputRange: [start, end],
                outputRange: [0.97, 1],
                extrapolate: 'clamp',
              }),
            },
          ],
        },
        style,
      ]}
    >
      {children}
    </Animated.View>
  );
}
