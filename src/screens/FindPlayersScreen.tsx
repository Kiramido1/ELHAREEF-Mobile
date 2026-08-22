import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { ScrollView, View } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { Txt } from '../components/Txt';
import { Avatar, BackButton, Button, Card, Row, Screen } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { SQUAD_AR, SQUAD_EN } from '../services/players';
import { useBookingDerived } from '../state/BookingContext';
import { brand, useTheme } from '../theme';
import { AvatarPalette } from '../components/ui';

type Props = NativeStackScreenProps<RootStackParamList, 'FindPlayers'>;

/** 75% completion ring (design's conic-gradient 270°). */
function CompletionRing() {
  const { colors } = useTheme();
  const r = 22;
  const c = 2 * Math.PI * r;
  return (
    <View style={{ width: 52, height: 52, alignItems: 'center', justifyContent: 'center' }}>
      <Svg width={52} height={52} style={{ position: 'absolute', transform: [{ rotate: '-90deg' }] }}>
        <Circle cx={26} cy={26} r={r} stroke={colors.tint} strokeWidth={7} fill="none" />
        <Circle
          cx={26}
          cy={26}
          r={r}
          stroke={brand.green}
          strokeWidth={7}
          fill="none"
          strokeDasharray={`${c * 0.75} ${c}`}
        />
      </Svg>
      <Txt w={800} size={11.5} style={{ textAlign: 'center' }}>
        75%
      </Txt>
    </View>
  );
}

export function FindPlayersScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, lang } = useI18n();
  const derived = useBookingDerived();
  const names = lang === 'ar' ? SQUAD_AR : SQUAD_EN;

  const squad: { label: string; name: string; palette: AvatarPalette }[] = [];
  for (let i = 0; i < 8; i++) {
    if (i < 6) {
      squad.push({
        label: names[i][0],
        name: names[i],
        palette: i === 0 ? 'navy' : i % 2 ? 'tint' : 'green',
      });
    } else {
      squad.push({ label: '?', name: lang === 'ar' ? 'ناقص' : 'Needed', palette: 'needed' });
    }
  }

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.goBack()} />
          <Txt w={800} size={18}>
            {t('needPlayersT')}
          </Txt>
        </Row>
        <Txt size={14} lineHeight={21.5} color={colors.ink6} style={{ marginTop: 10 }}>
          {t('squadFor')} {derived.pitch.name} · {derived.dateStr} · {derived.startStr}
        </Txt>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', marginTop: 24, marginHorizontal: -6 }}>
          {squad.map((s, i) => (
            <View key={i} style={{ width: '25%', alignItems: 'center', gap: 6, paddingVertical: 6 }}>
              <Avatar initial={s.label} palette={s.palette} size={62} fontSize={17} />
              <Txt w={600} size={11} color={colors.ink55} style={{ textAlign: 'center' }}>
                {s.name}
              </Txt>
            </View>
          ))}
        </View>

        <Card
          radiusValue={16}
          style={{
            marginTop: 26,
            paddingVertical: 16,
            paddingHorizontal: 17,
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <View>
            <Txt w={800} size={14.5}>
              {t('sixOf8')}
            </Txt>
            <Txt size={12.5} color={colors.ink55} style={{ marginTop: 3 }}>
              {t('need2')}
            </Txt>
          </View>
          <CompletionRing />
        </Card>

        <View style={{ marginTop: 'auto', paddingTop: 24, gap: 10 }}>
          <Button label={t('findPlayers')} onPress={() => navigation.navigate('CreateMatch')} />
          <Button
            label={t('skipFull')}
            variant="ghost"
            size={14}
            weight={600}
            paddingV={12}
            onPress={() => navigation.navigate('Tabs', { screen: 'Home' })}
          />
        </View>
      </ScrollView>
    </Screen>
  );
}
