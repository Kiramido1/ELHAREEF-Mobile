import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect, useRef } from 'react';
import { Animated, Easing, Platform, Pressable, View } from 'react-native';
import Svg, { Circle, Defs, RadialGradient, Stop } from 'react-native-svg';
import { Txt } from '../components/Txt';
import { RootStackParamList } from '../navigation/types';
import { brand } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Splash'>;

// Animated.loop stalls after one cycle on react-native-web with the native
// driver; loops fall back to the JS driver on web.
const LOOP_DRIVER = Platform.OS !== 'web';

export function SplashScreen({ navigation }: Props) {
  const mark = useRef(new Animated.Value(0)).current;
  const fade1 = useRef(new Animated.Value(0)).current;
  const fade2 = useRef(new Animated.Value(0)).current;
  const glow = useRef(new Animated.Value(0)).current;
  const loader = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(mark, {
      toValue: 1,
      duration: 1000,
      easing: Easing.bezier(0.16, 1, 0.3, 1),
      useNativeDriver: true,
    }).start();
    Animated.timing(fade1, { toValue: 1, duration: 700, delay: 900, useNativeDriver: true }).start();
    Animated.timing(fade2, { toValue: 1, duration: 700, delay: 1200, useNativeDriver: true }).start();
    Animated.loop(
      Animated.sequence([
        Animated.timing(glow, { toValue: 1, duration: 1600, useNativeDriver: LOOP_DRIVER }),
        Animated.timing(glow, { toValue: 0, duration: 1600, useNativeDriver: LOOP_DRIVER }),
      ]),
    ).start();
    Animated.loop(
      Animated.timing(loader, {
        toValue: 1,
        duration: 1100,
        easing: Easing.inOut(Easing.ease),
        useNativeDriver: LOOP_DRIVER,
      }),
    ).start();
    const timer = setTimeout(() => navigation.replace('Onboarding'), 2600);
    return () => clearTimeout(timer);
  }, [mark, fade1, fade2, glow, loader, navigation]);

  return (
    <Pressable
      onPress={() => navigation.replace('Onboarding')}
      style={{ flex: 1, backgroundColor: brand.navy, alignItems: 'center', justifyContent: 'center' }}
    >
      <StatusBar style="light" />
      <View style={{ alignItems: 'center' }}>
        <Animated.View
          style={{
            position: 'absolute',
            width: 300,
            height: 300,
            opacity: glow.interpolate({ inputRange: [0, 1], outputRange: [0.35, 0.7] }),
            transform: [{ scale: glow.interpolate({ inputRange: [0, 1], outputRange: [1, 1.18] }) }],
          }}
        >
          <Svg width={300} height={300}>
            <Defs>
              <RadialGradient id="glow" cx="50%" cy="50%" r="50%">
                <Stop offset="0" stopColor={brand.green} stopOpacity={0.32} />
                <Stop offset="0.65" stopColor={brand.green} stopOpacity={0} />
              </RadialGradient>
            </Defs>
            <Circle cx={150} cy={150} r={150} fill="url(#glow)" />
          </Svg>
        </Animated.View>
        <Animated.Image
          source={require('../../assets/brand/splash-logo.png')}
          style={{
            width: 222,
            height: 135,
            resizeMode: 'contain',
            opacity: mark,
            transform: [{ scale: mark.interpolate({ inputRange: [0, 1], outputRange: [0.92, 1] }) }],
          }}
        />
      </View>
      <Animated.View style={{ opacity: fade1, marginTop: 16 }}>
        <Txt ar w={600} size={15} color={brand.green} style={{ writingDirection: 'rtl' }}>
          الحريف — ملعبك والعبها صح
        </Txt>
      </Animated.View>
      <Animated.View
        style={{ position: 'absolute', bottom: 52, alignItems: 'center', gap: 16, opacity: fade2 }}
      >
        <View
          style={{
            width: 132,
            height: 4,
            borderRadius: 99,
            backgroundColor: 'rgba(251,252,250,.14)',
            overflow: 'hidden',
          }}
        >
          {/* Kick Lime runner sweeping across the track. */}
          <Animated.View
            style={{
              width: 58,
              height: '100%',
              borderRadius: 99,
              backgroundColor: brand.lime,
              transform: [
                {
                  translateX: loader.interpolate({
                    inputRange: [0, 1],
                    outputRange: [-58, 132],
                  }),
                },
              ],
            }}
          />
        </View>
        <Txt size={13} color={brand.cloud} style={{ textAlign: 'center' }}>
          <Txt w={700} size={13} color={brand.cloud}>
            ELHAREEF
          </Txt>{' '}
          <Txt size={13} color="rgba(251,252,250,.75)">
            — Book. Play. Win.
          </Txt>
        </Txt>
      </Animated.View>
    </Pressable>
  );
}
