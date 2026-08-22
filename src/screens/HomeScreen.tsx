import { CompositeScreenProps } from '@react-navigation/native';
import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useCallback, useEffect, useState } from 'react';
import { Animated, FlatList, Image, Pressable, ScrollView, View } from 'react-native';
import { PitchArt } from '../components/PitchArt';
import { Skeleton } from '../components/Skeleton';
import { Txt } from '../components/Txt';
import { Avatar, Card, Chip, ProgressBar, Row, Screen, SectionHeader } from '../components/ui';
import { RevealOnScroll, useScrollReveal } from '../components/anim';
import { SearchIcon } from '../components/icons';
import { pitchPhotos } from '../constants/pitchPhotos';
import { useI18n, areaAr, dayAr, typeAr } from '../i18n';
import { MainTabParamList, RootStackParamList } from '../navigation/types';
import { listPitches } from '../services/pitches';
import { NetworkError } from '../services/network';
import { useMatches } from '../state/MatchesContext';
import { brand, layout, radius, useTheme } from '../theme';
import { Match, Pitch } from '../types';

type Props = CompositeScreenProps<
  BottomTabScreenProps<MainTabParamList, 'Home'>,
  NativeStackScreenProps<RootStackParamList>
>;

function HomeSkeleton() {
  const { colors } = useTheme();
  const { t } = useI18n();
  const block = (style: object) => <Skeleton style={style} />;
  return (
    <View style={{ paddingHorizontal: layout.screenX }}>
      <Row style={{ alignItems: 'center', gap: 11 }}>
        {block({ width: 42, height: 42, borderRadius: 21 })}
        <View style={{ flex: 1, gap: 7 }}>
          {block({ width: 90, height: 11, borderRadius: 6 })}
          {block({ width: 130, height: 14, borderRadius: 6 })}
        </View>
        {block({ width: 42, height: 42, borderRadius: 21 })}
      </Row>
      {block({ marginTop: 16, height: 50, borderRadius: radius.card14 })}
      {block({ marginTop: 14, height: 150, borderRadius: radius.hero })}
      {block({ marginTop: 22, width: 140, height: 16, borderRadius: 6 })}
      <Row style={{ marginTop: 12, gap: 14 }}>
        {block({ width: 236, height: 210, borderRadius: radius.card })}
        {block({ width: 236, height: 210, borderRadius: radius.card })}
      </Row>
      <Txt w={600} size={12.5} color={colors.ink45} style={{ marginTop: 24, textAlign: 'center' }}>
        {t('finding')}
      </Txt>
    </View>
  );
}

function PitchCard({ pitch, onPress }: { pitch: Pitch; onPress: () => void }) {
  const { colors } = useTheme();
  const { t, pick, lang } = useI18n();
  const typeLabel = pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
  const areaLabel = pick(pitch.area, areaAr[pitch.area] ?? pitch.area);
  const distLabel = lang === 'ar' ? pitch.dist.replace(' km', ' كم') : pitch.dist;
  return (
    <Pressable onPress={onPress} accessibilityRole="button" accessibilityLabel={pitch.name}>
      {({ pressed }) => (
        <Card style={{ width: 236, overflow: 'hidden', opacity: pressed ? 0.85 : 1 }}>
          <PitchArt gradIndex={pitch.gradIndex} photo={pitchPhotos[pitch.id]} style={{ height: 118 }}>
            <View
              style={{
                position: 'absolute',
                top: 9,
                right: 9,
                backgroundColor: 'rgba(3,8,20,.75)',
                paddingVertical: 5,
                paddingHorizontal: 9,
                borderRadius: radius.pill,
              }}
            >
              <Txt w={700} size={11} color={brand.cloud}>
                ★ {pitch.rating}
              </Txt>
            </View>
            {pitch.availableNow ? (
              <View
                style={{
                  position: 'absolute',
                  bottom: 9,
                  left: 9,
                  backgroundColor: brand.lime,
                  paddingVertical: 5,
                  paddingHorizontal: 9,
                  borderRadius: radius.pill,
                }}
              >
                <Txt w={700} size={10.5} color={brand.navy}>
                  {t('availableNow')}
                </Txt>
              </View>
            ) : null}
          </PitchArt>
          <View style={{ paddingTop: 12, paddingHorizontal: 14, paddingBottom: 14 }}>
            <Txt w={700} size={14.5}>
              {pitch.name}
            </Txt>
            <Txt size={12} color={colors.ink55} style={{ marginTop: 4 }}>
              {areaLabel} · {distLabel}
            </Txt>
            <Row style={{ marginTop: 9, alignItems: 'center', justifyContent: 'space-between' }}>
              <Txt w={700} size={13.5} color={brand.green}>
                {pitch.price}
                <Txt w={500} size={11.5} color={colors.ink45}>
                  {t('perHrShort')}
                </Txt>
              </Txt>
              <View
                style={{
                  backgroundColor: colors.tint,
                  paddingVertical: 4,
                  paddingHorizontal: 8,
                  borderRadius: radius.xs,
                }}
              >
                <Txt w={600} size={11} color={colors.ink5}>
                  {typeLabel}
                </Txt>
              </View>
            </Row>
          </View>
        </Card>
      )}
    </Pressable>
  );
}

function HomeMatchCard({ match, onOpen }: { match: Match; onOpen: () => void }) {
  const { colors } = useTheme();
  const { t, pick, lang } = useI18n();
  const needed = match.total - match.joined;
  const needsLabel =
    lang === 'ar' ? `محتاج ${needed} لاعيبة` : `Needs ${needed} player${needed === 1 ? '' : 's'}`;
  const day = pick(match.day, dayAr[match.day] ?? match.day);
  const time = lang === 'ar' ? match.time.replace(' PM', ' م').replace(' AM', ' ص') : match.time;
  return (
    <Card style={{ paddingVertical: 15, paddingHorizontal: 16 }}>
      <Row style={{ alignItems: 'center', gap: 11 }}>
        <Avatar initial={match.initial} palette={match.avatar} size={40} fontSize={14} />
        <View style={{ flex: 1 }}>
          <Txt w={700} size={14.5}>
            {needsLabel}
          </Txt>
          <Txt size={12} color={colors.ink55} style={{ marginTop: 2 }}>
            {match.pitch} · {day} {time}
          </Txt>
        </View>
        <View
          style={{
            backgroundColor: colors.tint,
            paddingVertical: 5,
            paddingHorizontal: 10,
            borderRadius: radius.pill,
          }}
        >
          <Txt w={700} size={12}>
            {match.joined}/{match.total}
          </Txt>
        </View>
      </Row>
      <View style={{ marginTop: 12 }}>
        <ProgressBar pct={(match.joined / match.total) * 100} />
      </View>
      <Pressable
        onPress={onOpen}
        accessibilityRole="button"
        style={({ pressed }) => ({
          marginTop: 12,
          backgroundColor: colors.navyBtn,
          paddingVertical: 12,
          borderRadius: radius.action,
          alignItems: 'center',
          transform: [{ scale: pressed ? 0.97 : 1 }],
        })}
      >
        <Txt w={600} size={13.5} color="#fff">
          {t('joinMatch')}
        </Txt>
      </Pressable>
    </Card>
  );
}

export function HomeScreen({ navigation }: Props) {
  const { colors, dark } = useTheme();
  const { t, lang } = useI18n();
  const { matches } = useMatches();
  const [pitches, setPitches] = useState<Pitch[] | null>(null);
  const [chip, setChip] = useState(0);

  const load = useCallback(() => {
    setPitches(null);
    listPitches()
      .then(setPitches)
      .catch((e) => {
        if (e instanceof NetworkError) navigation.navigate('Offline');
      });
  }, [navigation]);

  useEffect(load, [load]);

  const { scrollY, onScroll } = useScrollReveal();

  const chips =
    lang === 'ar'
      ? ['قريب مني', 'متاح دلوقتي', 'النهارده', 'بكرة', 'الأشهر', 'الأرخص']
      : ['Near me', 'Available now', 'Today', 'Tomorrow', 'Popular', 'Lowest price'];

  return (
    <Screen>
      {pitches === null ? (
        <HomeSkeleton />
      ) : (
        <Animated.ScrollView
          contentContainerStyle={{ paddingBottom: 24 }}
          showsVerticalScrollIndicator={false}
          onScroll={onScroll}
          scrollEventThrottle={16}
        >
          {/* Header */}
          <Row
            style={{
              alignItems: 'center',
              justifyContent: 'space-between',
              paddingHorizontal: layout.screenX,
            }}
          >
            <Row style={{ alignItems: 'center', gap: 11 }}>
              <Image
                source={
                  dark
                    ? require('../../assets/brand/symbol-reverse.png')
                    : require('../../assets/brand/symbol.png')
                }
                style={{ width: 42, height: 28, resizeMode: 'contain' }}
                accessibilityLabel="ELHAREEF"
              />
              <View>
                <Txt w={500} size={11.5} color={colors.ink5}>
                  {t('playingIn')}
                </Txt>
                <Txt w={700} size={15}>
                  {t('cairo')}{' '}
                  <Txt size={12} color={brand.green}>
                    ▾
                  </Txt>
                </Txt>
              </View>
            </Row>
            <Pressable
              onPress={() => navigation.navigate('Profile')}
              accessibilityRole="button"
              accessibilityLabel={t('nav4')}
            >
              <Avatar initial="Y" palette="navy" size={42} fontSize={15} />
            </Pressable>
          </Row>

          {/* Greeting */}
          <View style={{ paddingHorizontal: layout.screenX, marginTop: 16 }}>
            <Txt w={800} size={21} letterSpacing={-0.21}>
              {t('greetName')}{' '}
              <Txt ar w={600} size={17} color={brand.green}>
                — يلا نلعب؟
              </Txt>
            </Txt>
          </View>

          {/* Search bar */}
          <Pressable
            onPress={() => navigation.navigate('Search')}
            accessibilityRole="search"
            style={({ pressed }) => ({
              flexDirection: lang === 'ar' ? 'row-reverse' : 'row',
              alignItems: 'center',
              gap: 10,
              marginTop: 14,
              marginHorizontal: layout.screenX,
              paddingVertical: 14,
              paddingHorizontal: 16,
              borderWidth: 1.5,
              borderColor: colors.ink1,
              borderRadius: radius.card14,
              backgroundColor: colors.card,
              opacity: pressed ? 0.8 : 1,
            })}
          >
            <SearchIcon size={18} color={colors.ink45} />
            <Txt size={14.5} color={colors.ink45}>
              {t('searchPh')}
            </Txt>
          </Pressable>

          {/* Quick chips */}
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 8, paddingHorizontal: layout.screenX, paddingTop: 14, paddingBottom: 4 }}
          >
            {chips.map((label, i) => (
              <Chip key={label} label={label} selected={chip === i} onPress={() => setChip(i)} />
            ))}
          </ScrollView>

          {/* Hero banner */}
          <Pressable
            onPress={() => navigation.navigate('Booking')}
            accessibilityRole="button"
            accessibilityLabel={t('bookPitch')}
            style={({ pressed }) => ({
              marginTop: 14,
              marginHorizontal: layout.screenX,
              padding: 22,
              borderRadius: radius.hero,
              backgroundColor: colors.navyBtn,
              overflow: 'hidden',
              transform: [{ scale: pressed ? 0.98 : 1 }],
            })}
          >
            <View
              pointerEvents="none"
              style={{
                position: 'absolute',
                top: -40,
                right: -40,
                width: 160,
                height: 160,
                borderWidth: 2,
                borderColor: 'rgba(189,249,97,.22)',
                borderRadius: 80,
              }}
            />
            <View
              pointerEvents="none"
              style={{
                position: 'absolute',
                top: 8,
                right: 8,
                width: 64,
                height: 64,
                borderWidth: 2,
                borderColor: 'rgba(36,165,81,.4)',
                borderRadius: 32,
              }}
            />
            <Txt w={700} size={12} color={brand.lime} letterSpacing={0.96} style={{ textTransform: 'uppercase' }}>
              {t('tonightAt')}
            </Txt>
            <Txt w={800} size={21} color={brand.cloud} letterSpacing={-0.21} style={{ marginTop: 7 }}>
              {t('bookPitch')}
            </Txt>
            <Txt size={13.5} color="rgba(251,252,250,.65)" style={{ marginTop: 5 }}>
              {lang === 'ar'
                ? '8:00 م فاضية · 200 جنيه/ساعة · على بعد 2.1 كم'
                : '8:00 PM free · 200 EGP/hr · 2.1 km away'}
            </Txt>
            <View
              style={{
                marginTop: 14,
                alignSelf: lang === 'ar' ? 'flex-end' : 'flex-start',
                flexDirection: 'row',
                alignItems: 'center',
                gap: 8,
                backgroundColor: brand.lime,
                paddingVertical: 10,
                paddingHorizontal: 16,
                borderRadius: radius.pill,
              }}
            >
              <Txt w={700} size={13.5} color={brand.navy}>
                {t('bookNow')} <Txt size={15} color={brand.navy}>›</Txt>
              </Txt>
            </View>
          </Pressable>

          {/* Nearby pitches */}
          <View style={{ marginTop: 26 }}>
            <SectionHeader
              title={t('nearby')}
              actionLabel={t('seeAll')}
              onAction={() => navigation.navigate('Search')}
            />
          </View>
          <FlatList
            horizontal
            data={pitches}
            keyExtractor={(p) => String(p.id)}
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 14, paddingHorizontal: layout.screenX, paddingTop: 12, paddingBottom: 6 }}
            renderItem={({ item }) => (
              <PitchCard pitch={item} onPress={() => navigation.navigate('Pitch', { pitchId: item.id })} />
            )}
          />

          {/* Looking for players */}
          <View style={{ marginTop: 24 }}>
            <SectionHeader
              title={t('looking')}
              actionLabel={t('seeAll')}
              onAction={() => navigation.navigate('Discover')}
            />
          </View>
          <View style={{ gap: 12, paddingHorizontal: layout.screenX, paddingTop: 12 }}>
            {matches.slice(0, 2).map((m) => (
              <RevealOnScroll key={m.id} scrollY={scrollY}>
                <HomeMatchCard
                  match={m}
                  onOpen={() => navigation.navigate('MatchDetails', { matchId: m.id })}
                />
              </RevealOnScroll>
            ))}
          </View>
        </Animated.ScrollView>
      )}
    </Screen>
  );
}
