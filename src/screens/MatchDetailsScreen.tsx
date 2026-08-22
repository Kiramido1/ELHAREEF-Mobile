import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { PitchArt } from '../components/PitchArt';
import { pitchPhotos } from '../constants/pitchPhotos';
import { Txt } from '../components/Txt';
import { Avatar, BackButton, Card, Row, Screen } from '../components/ui';
import { dayAr, levelAr, useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { MatchFullError, NetworkError } from '../services/network';
import { ROSTER_AR, ROSTER_EN } from '../services/players';
import { useMatches } from '../state/MatchesContext';
import { brand, layout, radius, useTheme } from '../theme';
import { AvatarPalette } from '../components/ui';

type Props = NativeStackScreenProps<RootStackParamList, 'MatchDetails'>;

export function MatchDetailsScreen({ navigation, route }: Props) {
  const { colors } = useTheme();
  const { t, pick, lang, isRTL } = useI18n();
  const insets = useSafeAreaInsets();
  const { matches, joinStatus, join } = useMatches();
  const match = matches.find((m) => m.id === route.params.matchId) ?? matches[0];
  const status = joinStatus[match.id];
  const needed = match.total - match.joined;

  const day = pick(match.day, dayAr[match.day] ?? match.day);
  const time = lang === 'ar' ? match.time.replace(' PM', ' م').replace(' AM', ' ص') : match.time;
  const dur =
    lang === 'ar' ? (match.durHours === 1 ? 'ساعة' : 'ساعتين') : `${match.durHours} hour${match.durHours === 1 ? '' : 's'}`;
  const level = pick(match.level, levelAr[match.level] ?? match.level);
  const org = pick(match.org, match.orgAr);
  const names = lang === 'ar' ? ROSTER_AR : ROSTER_EN;

  const slots: { label: string; name: string; palette: AvatarPalette }[] = [];
  for (let i = 0; i < match.total; i++) {
    if (i < match.joined) {
      slots.push({ label: names[i][0], name: names[i], palette: i % 2 ? 'tint' : 'navy' });
    } else {
      slots.push({ label: '+', name: pick('Open', 'فاضي'), palette: 'open' });
    }
  }

  const joinLabel =
    status === 'joined'
      ? t('openSquadChat')
      : status === 'pending'
        ? lang === 'ar'
          ? `الطلب اتبعت — في انتظار ${match.orgAr.split(' ')[0]}`
          : `Request sent — waiting for ${match.org.split(' ')[0]}`
        : t('requestToJoin');
  const joinBg = status === 'pending' ? colors.tint : status === 'joined' ? colors.navyBtn : brand.green;
  const joinFg = status === 'pending' ? colors.ink55 : '#fff';

  const handleJoin = () => {
    if (status === 'joined') return navigation.navigate('Chat');
    if (status === 'pending') return;
    if (needed === 0) return navigation.navigate('MatchFull', { matchId: match.id });
    join(match.id).catch((e) => {
      if (e instanceof MatchFullError) navigation.navigate('MatchFull', { matchId: match.id });
      else if (e instanceof NetworkError) navigation.navigate('Offline');
    });
  };

  return (
    <Screen>
      <Row style={{ alignItems: 'center', gap: 12, paddingHorizontal: layout.screenX }}>
        <BackButton onPress={() => navigation.goBack()} />
        <Txt w={800} size={18}>
          {t('matchDetails')}
        </Txt>
      </Row>

      <ScrollView
        contentContainerStyle={{ paddingTop: 16, paddingHorizontal: layout.screenX, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
      >
        <Card style={{ overflow: 'hidden' }}>
          <PitchArt
            gradIndex={match.gradIndex}
            photo={pitchPhotos[match.gradIndex]}
            style={{ height: 96 }}
          >
            <View style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, backgroundColor: 'rgba(3,8,20,.22)' }} />
            <Txt
              w={800}
              size={16}
              color={brand.cloud}
              style={{
                position: 'absolute',
                bottom: 10,
                left: 14,
                textShadowColor: 'rgba(3,8,20,.5)',
                textShadowRadius: 6,
                textShadowOffset: { width: 0, height: 1 },
              }}
            >
              {match.pitch}
            </Txt>
          </PitchArt>
          <Row style={{ paddingVertical: 14, paddingHorizontal: 16, gap: 16 }}>
            <View>
              <Txt w={600} size={11.5} color={colors.ink5}>
                {t('date')}
              </Txt>
              <Txt w={800} size={13} style={{ marginTop: 2 }}>
                {day}
              </Txt>
            </View>
            <View>
              <Txt w={600} size={11.5} color={colors.ink5}>
                {t('kickoff')}
              </Txt>
              <Txt w={800} size={13} style={{ marginTop: 2 }}>
                {time}
              </Txt>
            </View>
            <View>
              <Txt w={600} size={11.5} color={colors.ink5}>
                {t('duration')}
              </Txt>
              <Txt w={800} size={13} style={{ marginTop: 2 }}>
                {dur}
              </Txt>
            </View>
            <View style={{ marginLeft: isRTL ? 0 : 'auto', marginRight: isRTL ? 'auto' : 0 }}>
              <Txt w={600} size={11.5} color={colors.ink5}>
                {t('level')}
              </Txt>
              <Txt w={800} size={13} color={brand.green} style={{ marginTop: 2 }}>
                {level}
              </Txt>
            </View>
          </Row>
        </Card>

        <Pressable
          onPress={() => navigation.navigate('PlayerProfile', { matchId: match.id })}
          accessibilityRole="button"
          accessibilityLabel={org}
        >
          {({ pressed }) => (
            <Card
              radiusValue={radius.box}
              style={{
                marginTop: 14,
                flexDirection: isRTL ? 'row-reverse' : 'row',
                alignItems: 'center',
                gap: 12,
                paddingVertical: 13,
                paddingHorizontal: 15,
                opacity: pressed ? 0.85 : 1,
              }}
            >
              <Avatar initial={match.initial} palette={match.avatar} size={42} fontSize={14} />
              <View style={{ flex: 1 }}>
                <Txt w={700} size={14.5}>
                  {org}
                </Txt>
                <Txt size={12} color={colors.ink55}>
                  {t('orgMeta')}
                </Txt>
              </View>
              <Txt size={17} color={colors.ink35}>
                ›
              </Txt>
            </Card>
          )}
        </Pressable>

        <Row style={{ marginTop: 18, alignItems: 'baseline', justifyContent: 'space-between' }}>
          <Txt w={700} size={15}>
            {t('playersT')} · {match.joined}/{match.total}
          </Txt>
          <Txt w={700} size={12.5} color={brand.green}>
            {needed} {t('spotsLeft')}
          </Txt>
        </Row>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', marginTop: 11, marginHorizontal: -5 }}>
          {slots.map((s, i) => (
            <View key={i} style={{ width: '20%', alignItems: 'center', gap: 5, paddingVertical: 5 }}>
              <Avatar initial={s.label} palette={s.palette} size={50} fontSize={14} />
              <Txt w={600} size={10.5} color={colors.ink55} style={{ textAlign: 'center' }}>
                {s.name}
              </Txt>
            </View>
          ))}
        </View>

        <Txt w={700} size={15} style={{ marginTop: 18 }}>
          {t('aboutMatch')}
        </Txt>
        <Txt size={13.5} lineHeight={21.5} color={colors.ink7} style={{ marginTop: 7 }}>
          {pick(match.desc, match.descAr)}
        </Txt>
        <View
          style={{
            marginTop: 12,
            borderWidth: 1,
            borderColor: colors.ink08,
            borderRadius: radius.input,
            backgroundColor: colors.tint,
            paddingVertical: 12,
            paddingHorizontal: 14,
          }}
        >
          <Txt size={12.5} lineHeight={19} color={colors.ink75}>
            {t('matchTips')}
          </Txt>
        </View>
      </ScrollView>

      <View
        style={{
          backgroundColor: colors.bar,
          borderTopWidth: 1,
          borderTopColor: colors.ink08,
          paddingTop: 14,
          paddingHorizontal: layout.screenX,
          paddingBottom: Math.max(insets.bottom, 14) + 12,
        }}
      >
        <Pressable
          onPress={handleJoin}
          accessibilityRole="button"
          accessibilityState={{ disabled: status === 'pending' }}
          style={({ pressed }) => ({
            backgroundColor: joinBg,
            paddingVertical: 16,
            borderRadius: radius.card14,
            alignItems: 'center',
            transform: [{ scale: pressed && status !== 'pending' ? 0.97 : 1 }],
          })}
        >
          <Txt w={700} size={15.5} color={joinFg}>
            {joinLabel}
          </Txt>
        </Pressable>
      </View>
    </Screen>
  );
}
