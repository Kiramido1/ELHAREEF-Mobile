import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { LinearGradient } from 'expo-linear-gradient';
import React, { useEffect, useRef, useState } from 'react';
import { Animated, Easing, Pressable, View } from 'react-native';
import { BackButton, Row } from '../components/ui';
import { Txt } from '../components/Txt';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { brand, onboardingGradients, radius, useTheme } from '../theme';
import { Screen } from '../components/ui';

type Props = NativeStackScreenProps<RootStackParamList, 'Onboarding'>;

const SLIDES = [
  {
    title: ['Every pitch in the city, in your pocket', 'كل ملاعب المدينة في جيبك'],
    body: [
      'Real availability, real prices, real distances — from 5-a-side cages to full grounds.',
      'مواعيد حقيقية وأسعار حقيقية ومسافات حقيقية — من ملاعب الخماسي للملاعب الكبيرة.',
    ],
    cta: ['Next', 'التالي'],
  },
  {
    title: ['Book in seconds, not phone calls', 'احجز في ثواني، من غير مكالمات'],
    body: [
      'Pick a date, a free slot, and how long you play. Done before the ad break ends.',
      'اختار اليوم والمعاد الفاضي ومدة اللعب. هتخلص قبل ما الإعلان يخلص.',
    ],
    cta: ['Next', 'التالي'],
  },
  {
    title: ['Missing players? Not anymore.', 'ناقصك لاعيبة؟ مش تاني.'],
    body: [
      'Post your match and nearby hareefa fill the empty spots. Chat, coordinate, play.',
      'انشر ماتشك والحريف القريبين هيكملوا الأماكن الفاضية. اتكلموا ونسقوا والعبوا.',
    ],
    cta: ['Get started', 'يلا نبدأ'],
  },
] as const;

function Slide0Art() {
  return (
    <>
      <View
        style={{
          position: 'absolute',
          top: 18,
          bottom: 18,
          left: 18,
          right: 18,
          borderWidth: 2,
          borderColor: 'rgba(251,252,250,.35)',
          borderRadius: 14,
        }}
      />
      <View
        style={{
          position: 'absolute',
          top: 18,
          bottom: 18,
          left: '50%',
          width: 2,
          backgroundColor: 'rgba(251,252,250,.35)',
        }}
      />
      <View
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          width: 92,
          height: 92,
          marginTop: -46,
          marginLeft: -46,
          borderWidth: 2,
          borderColor: 'rgba(251,252,250,.4)',
          borderRadius: 46,
        }}
      />
      <View
        style={{
          position: 'absolute',
          bottom: 30,
          left: 34,
          backgroundColor: brand.lime,
          paddingVertical: 7,
          paddingHorizontal: 12,
          borderRadius: radius.pill,
        }}
      >
        <Txt w={700} size={12} color={brand.navy}>
          2.1 km away
        </Txt>
      </View>
      <View
        style={{
          position: 'absolute',
          top: 34,
          right: 34,
          backgroundColor: '#FDFEFC',
          paddingVertical: 7,
          paddingHorizontal: 12,
          borderRadius: radius.pill,
        }}
      >
        <Txt w={700} size={12} color="#0b1533">
          ★ 4.8
        </Txt>
      </View>
    </>
  );
}

function Slide1Art() {
  return (
    <View style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, alignItems: 'center', justifyContent: 'center', gap: 10 }}>
      <View style={{ backgroundColor: '#FDFEFC', borderRadius: 12, paddingVertical: 11, paddingHorizontal: 22 }}>
        <Txt w={600} size={14} color="#7f8a9e">
          6:00 PM
        </Txt>
      </View>
      <View
        style={{
          backgroundColor: brand.lime,
          borderRadius: 12,
          paddingVertical: 12,
          paddingHorizontal: 26,
          shadowColor: brand.navy,
          shadowOpacity: 0.28,
          shadowRadius: 22,
          shadowOffset: { width: 0, height: 8 },
          elevation: 6,
        }}
      >
        <Txt w={700} size={15} color={brand.navy}>
          8:00 PM ✓
        </Txt>
      </View>
      <View style={{ backgroundColor: '#FDFEFC', borderRadius: 12, paddingVertical: 11, paddingHorizontal: 22 }}>
        <Txt w={600} size={14} color="#7f8a9e">
          10:00 PM
        </Txt>
      </View>
    </View>
  );
}

function Slide2Art({ navyBtn, ink4 }: { navyBtn: string; ink4: string }) {
  const bubble = (bg: string, fg: string, label: string, dashed = false, first = false) => (
    <View
      key={label}
      style={{
        width: 58,
        height: 58,
        borderRadius: 29,
        backgroundColor: bg,
        alignItems: 'center',
        justifyContent: 'center',
        borderWidth: 3,
        borderColor: dashed ? ink4 : brand.green,
        borderStyle: dashed ? 'dashed' : 'solid',
        marginLeft: first ? 0 : -12,
      }}
    >
      <Txt w={dashed ? 800 : 700} size={15} color={fg}>
        {label}
      </Txt>
    </View>
  );
  return (
    <View style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ flexDirection: 'row' }}>
        {bubble('#FDFEFC', '#0b1533', 'A', false, true)}
        {bubble(navyBtn, brand.cloud, 'O')}
        {bubble('#FDFEFC', '#0b1533', 'K')}
        {bubble(brand.lime, brand.navy, '+2', true)}
      </View>
    </View>
  );
}

export function OnboardingScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { lang, t } = useI18n();
  const li = lang === 'ar' ? 1 : 0;
  const [ob, setOb] = useState(0);
  const dirRef = useRef(1);
  const slideAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    slideAnim.setValue(dirRef.current * 30);
    Animated.timing(slideAnim, {
      toValue: 0,
      duration: 500,
      easing: Easing.bezier(0.16, 1, 0.3, 1),
      useNativeDriver: true,
    }).start();
  }, [ob, slideAnim]);

  const slide = SLIDES[ob];
  const grad = onboardingGradients[ob];

  const next = () => {
    if (ob < 2) {
      dirRef.current = 1;
      setOb(ob + 1);
    } else {
      navigation.replace('Login');
    }
  };
  const back = () => {
    dirRef.current = -1;
    setOb(Math.max(0, ob - 1));
  };

  return (
    <Screen style={{ paddingHorizontal: 24, paddingBottom: 40 }}>
      <Row style={{ alignItems: 'center', justifyContent: 'space-between', marginTop: 12 }}>
        {ob > 0 ? <BackButton onPress={back} /> : <View style={{ width: 38 }} />}
        <Pressable onPress={() => navigation.replace('Login')} hitSlop={8} accessibilityRole="button">
          <Txt w={500} size={14} color={colors.ink5}>
            {t('skip')}
          </Txt>
        </Pressable>
      </Row>
      <View style={{ flex: 1, justifyContent: 'center', gap: 30 }}>
        <Animated.View
          style={{
            opacity: slideAnim.interpolate({ inputRange: [-30, 0, 30], outputRange: [0, 1, 0] }),
            transform: [{ translateX: slideAnim }],
          }}
        >
          <LinearGradient
            colors={grad}
            start={{ x: 0, y: 0 }}
            end={{ x: 0.8, y: 1 }}
            style={{ height: 300, borderRadius: radius.onboarding, overflow: 'hidden' }}
          >
            {ob === 0 ? <Slide0Art /> : ob === 1 ? <Slide1Art /> : <Slide2Art navyBtn={colors.navyBtn} ink4={colors.ink4} />}
          </LinearGradient>
        </Animated.View>
        <Animated.View
          style={{
            opacity: slideAnim.interpolate({ inputRange: [-30, 0, 30], outputRange: [0, 1, 0] }),
            transform: [{ translateX: slideAnim }],
          }}
        >
          <Txt w={800} size={27} lineHeight={31} letterSpacing={-0.27}>
            {slide.title[li]}
          </Txt>
          <Txt size={15} lineHeight={24} color={colors.ink6} style={{ marginTop: 10 }}>
            {slide.body[li]}
          </Txt>
        </Animated.View>
      </View>
      <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
        <Row style={{ gap: 6 }}>
          {[0, 1, 2].map((i) => (
            <View
              key={i}
              style={{
                width: ob === i ? 22 : 7,
                height: 7,
                borderRadius: 99,
                backgroundColor: ob === i ? brand.green : colors.ink15,
              }}
            />
          ))}
        </Row>
        <Pressable
          onPress={next}
          accessibilityRole="button"
          style={({ pressed }) => ({
            backgroundColor: brand.green,
            paddingVertical: 15,
            paddingHorizontal: 30,
            borderRadius: radius.card14,
            transform: [{ scale: pressed ? 0.94 : 1 }],
          })}
        >
          <Txt w={600} size={15} color="#fff">
            {slide.cta[li]}
          </Txt>
        </Pressable>
      </Row>
    </Screen>
  );
}
