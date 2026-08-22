import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { CompositeScreenProps } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useEffect, useRef, useState } from 'react';
import { Animated, Platform, Pressable, ScrollView, View } from 'react-native';
import { RevealOnScroll, useScrollReveal } from '../components/anim';
import { Txt } from '../components/Txt';
import { Avatar, BackButton, Card, Chip, ProgressBar, Row, Screen } from '../components/ui';
import { areaAr, dayAr, levelAr, useI18n } from '../i18n';
import { MainTabParamList, RootStackParamList } from '../navigation/types';
import { MatchFullError, NetworkError } from '../services/network';
import { useMatches } from '../state/MatchesContext';
import { brand, layout, radius, useTheme } from '../theme';
import { JoinStatus, Match } from '../types';

type Props = CompositeScreenProps<
  BottomTabScreenProps<MainTabParamList, 'Discover'>,
  NativeStackScreenProps<RootStackParamList>
>;

function PulsingDot() {
  const anim = useRef(new Animated.Value(0.25)).current;
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(anim, { toValue: 1, duration: 700, useNativeDriver: Platform.OS !== 'web' }),
        Animated.timing(anim, { toValue: 0.25, duration: 700, useNativeDriver: Platform.OS !== 'web' }),
      ]),
    ).start();
  }, [anim]);
  return (
    <Animated.View
      style={{ width: 9, height: 9, borderRadius: 4.5, backgroundColor: brand.green, opacity: anim }}
    />
  );
}

function MatchCard({
  match,
  status,
  onDetails,
  onJoin,
}: {
  match: Match;
  status: JoinStatus | undefined;
  onDetails: () => void;
  onJoin: () => void;
}) {
  const { colors } = useTheme();
  const { t, pick, lang } = useI18n();
  const needed = match.total - match.joined;
  const full = needed === 0 && status !== 'joined';
  const day = pick(match.day, dayAr[match.day] ?? match.day);
  const time = lang === 'ar' ? match.time.replace(' PM', ' م').replace(' AM', ' ص') : match.time;
  const dur =
    lang === 'ar' ? (match.durHours === 1 ? 'ساعة' : 'ساعتين') : `${match.durHours} hour${match.durHours === 1 ? '' : 's'}`;
  const level = pick(match.level, levelAr[match.level] ?? match.level);
  const areaLabel = pick(match.area, areaAr[match.area] ?? match.area);
  const org = pick(match.org, match.orgAr);

  const joinLabel = full
    ? pick(`FULL ${match.total}/${match.total}`, `كامل ${match.total}/${match.total}`)
    : status === 'joined'
      ? t('openChat')
      : status === 'pending'
        ? t('requestSent')
        : lang === 'ar'
          ? `انضم · محتاجين ${needed}`
          : `Join match · ${needed} needed`;
  const joinBg = full
    ? colors.navyBtn
    : status === 'joined'
      ? colors.tint
      : status === 'pending'
        ? colors.tint
        : brand.green;
  const joinFg = full ? '#fff' : status === 'joined' ? brand.green : status === 'pending' ? colors.ink55 : '#fff';

  return (
    <Card style={{ paddingVertical: 15, paddingHorizontal: 16 }}>
      <Pressable onPress={onDetails} accessibilityRole="button" accessibilityLabel={org}>
        <Row style={{ alignItems: 'center', gap: 11 }}>
          <Avatar initial={match.initial} palette={match.avatar} size={44} fontSize={15} />
          <View style={{ flex: 1, minWidth: 0 }}>
            <Txt w={700} size={15}>
              {org}
            </Txt>
            <Txt size={12.5} color={colors.ink55} style={{ marginTop: 2 }}>
              {match.pitch} · {areaLabel}
            </Txt>
          </View>
          <View style={{ backgroundColor: colors.tint, paddingVertical: 5, paddingHorizontal: 10, borderRadius: radius.pill }}>
            <Txt w={700} size={11.5} color={colors.ink6}>
              {level}
            </Txt>
          </View>
        </Row>
      </Pressable>
      <Row style={{ marginTop: 12, gap: 14, alignItems: 'baseline' }}>
        <Txt size={12.5} color={colors.ink6}>
          <Txt w={700} size={12.5}>
            {day}
          </Txt>{' '}
          · {time}
        </Txt>
        <Txt size={12.5} color={colors.ink6}>
          {dur}
        </Txt>
        <View style={{ flex: 1 }} />
        <Txt w={700} size={12.5}>
          {match.joined}/{match.total} {t('playersWord')}
        </Txt>
      </Row>
      <View style={{ marginTop: 9 }}>
        <ProgressBar pct={(match.joined / match.total) * 100} />
      </View>
      <Row style={{ marginTop: 12, gap: 9 }}>
        <Pressable
          onPress={onDetails}
          accessibilityRole="button"
          style={({ pressed }) => ({
            flex: 1,
            borderWidth: 1.5,
            borderColor: colors.ink14,
            backgroundColor: colors.card,
            paddingVertical: 11,
            borderRadius: radius.action,
            alignItems: 'center',
            transform: [{ scale: pressed ? 0.97 : 1 }],
          })}
        >
          <Txt w={600} size={13}>
            {t('details')}
          </Txt>
        </Pressable>
        <Pressable
          onPress={onJoin}
          accessibilityRole="button"
          accessibilityState={{ disabled: status === 'pending' }}
          style={({ pressed }) => ({
            flex: 1.4,
            backgroundColor: joinBg,
            paddingVertical: 11,
            borderRadius: radius.action,
            alignItems: 'center',
            transform: [{ scale: pressed && status !== 'pending' ? 0.97 : 1 }],
          })}
        >
          <Txt w={700} size={13} color={joinFg}>
            {joinLabel}
          </Txt>
        </Pressable>
      </Row>
    </Card>
  );
}

export function DiscoverScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, lang } = useI18n();
  const { matches, joinStatus, posted, draft, join, selectMatch } = useMatches();
  const [chip, setChip] = useState(0);
  const { scrollY, onScroll } = useScrollReveal();
  const derivedPitchName = 'Dream Sports Arena';

  const chips =
    lang === 'ar'
      ? ['كل الماتشات', 'النهارده', 'قريب مني', 'مستوايا']
      : ['All matches', 'Today', 'Near me', 'My level'];

  const needStr =
    lang === 'ar'
      ? draft.need === 1
        ? 'لاعيب واحد'
        : `${draft.need} لاعيبة`
      : `${draft.need} player${draft.need === 1 ? '' : 's'}`;

  const handleJoin = (match: Match) => {
    const status = joinStatus[match.id];
    if (status === 'joined') return navigation.navigate('Chat');
    if (status === 'pending') return;
    if (match.total - match.joined === 0) {
      return navigation.navigate('MatchFull', { matchId: match.id });
    }
    join(match.id).catch((e) => {
      if (e instanceof MatchFullError) navigation.navigate('MatchFull', { matchId: match.id });
      else if (e instanceof NetworkError) navigation.navigate('Offline');
    });
  };

  return (
    <Screen>
      <Animated.ScrollView
        contentContainerStyle={{ paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
        onScroll={onScroll}
        scrollEventThrottle={16}
      >
        <View style={{ paddingHorizontal: layout.screenX }}>
          <Row style={{ alignItems: 'center', gap: 12 }}>
            <BackButton onPress={() => navigation.navigate('Home')} />
            <View style={{ flex: 1 }}>
              <Txt w={800} size={23} letterSpacing={-0.23}>
                {t('findTitle')}
              </Txt>
              <Txt size={13.5} color={colors.ink6} style={{ marginTop: 5 }}>
                {t('findSub')}
              </Txt>
            </View>
          </Row>
        </View>

        {posted ? (
          <Row
            style={{
              marginTop: 14,
              marginHorizontal: layout.screenX,
              borderWidth: 1.5,
              borderColor: colors.limeBd,
              backgroundColor: colors.limeTint,
              borderRadius: radius.box,
              paddingVertical: 13,
              paddingHorizontal: 16,
              alignItems: 'center',
              gap: 11,
            }}
          >
            <PulsingDot />
            <Txt size={13} lineHeight={18.5} style={{ flex: 1 }}>
              <Txt w={700} size={13}>
                {t('matchLive')}
              </Txt>{' '}
              {derivedPitchName} · {t('needsWord')} {needStr}.
            </Txt>
            <Pressable
              onPress={() => navigation.navigate('MyMatches')}
              accessibilityRole="button"
              style={({ pressed }) => ({
                backgroundColor: colors.navyBtn,
                paddingVertical: 8,
                paddingHorizontal: 12,
                borderRadius: radius.chip9,
                transform: [{ scale: pressed ? 0.95 : 1 }],
              })}
            >
              <Txt w={700} size={12} color="#fff">
                {t('manage')}
              </Txt>
            </Pressable>
          </Row>
        ) : null}

        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{ gap: 8, paddingHorizontal: layout.screenX, paddingTop: 14, paddingBottom: 4 }}
        >
          {chips.map((label, i) => (
            <Chip key={label} label={label} selected={chip === i} onPress={() => setChip(i)} />
          ))}
        </ScrollView>

        <View style={{ gap: 13, paddingHorizontal: layout.screenX, paddingTop: 12 }}>
          {matches.map((m) => (
            <RevealOnScroll key={m.id} scrollY={scrollY}>
              <MatchCard
                match={m}
                status={joinStatus[m.id]}
                onDetails={() => {
                  selectMatch(m.id);
                  navigation.navigate('MatchDetails', { matchId: m.id });
                }}
                onJoin={() => handleJoin(m)}
              />
            </RevealOnScroll>
          ))}
        </View>
      </Animated.ScrollView>
    </Screen>
  );
}
