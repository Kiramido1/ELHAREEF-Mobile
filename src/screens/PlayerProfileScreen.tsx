import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { ScrollView, View } from 'react-native';
import { Txt } from '../components/Txt';
import { Avatar, BackButton, Button, Card, Row, Screen } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { getMatch } from '../services/matches';
import { brand, layout, radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'PlayerProfile'>;

function StatCard({ value, label, valueColor }: { value: string; label: string; valueColor?: string }) {
  const { colors } = useTheme();
  return (
    <Card radiusValue={radius.card15} style={{ flex: 1, paddingVertical: 14, alignItems: 'center' }}>
      <Txt w={800} size={20} color={valueColor} style={{ textAlign: 'center' }}>
        {value}
      </Txt>
      <Txt w={600} size={11.5} color={colors.ink55} style={{ marginTop: 2, textAlign: 'center' }}>
        {label}
      </Txt>
    </Card>
  );
}

export function PlayerProfileScreen({ navigation, route }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const match = getMatch(route.params.matchId);
  const org = pick(match.org, match.orgAr);

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: layout.screenX, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.goBack()} />
          <Txt w={800} size={18}>
            {t('playerT')}
          </Txt>
        </Row>

        <View style={{ marginTop: 20, alignItems: 'center' }}>
          <Avatar initial={match.initial} palette="navy" size={92} fontSize={30} borderColor={brand.green} />
          <Txt w={800} size={21} style={{ marginTop: 12, textAlign: 'center' }}>
            {org}
          </Txt>
          <Txt size={13} color={colors.ink55} style={{ marginTop: 3, textAlign: 'center' }}>
            {t('playerMeta')}
          </Txt>
          <Row style={{ marginTop: 12, gap: 8 }}>
            <View style={{ backgroundColor: colors.tint, paddingVertical: 7, paddingHorizontal: 13, borderRadius: radius.pill }}>
              <Txt w={700} size={12.5}>
                {t('midfielder')}
              </Txt>
            </View>
            <View style={{ backgroundColor: colors.limeChip, paddingVertical: 7, paddingHorizontal: 13, borderRadius: radius.pill }}>
              <Txt w={700} size={12.5} color={colors.limeChipFg}>
                {t('intermediate')}
              </Txt>
            </View>
          </Row>
        </View>

        <Row style={{ marginTop: 20, gap: 10 }}>
          <StatCard value="42" label={t('matchesW')} />
          <StatCard value="★ 4.8" label={t('rating')} valueColor={brand.green} />
          <StatCard value="12" label={t('hosted')} />
        </Row>

        <Txt w={700} size={15} style={{ marginTop: 20 }}>
          {t('about')}
        </Txt>
        <Txt size={13.5} lineHeight={21.5} color={colors.ink7} style={{ marginTop: 7 }}>
          {t('playerBio')}
        </Txt>

        <Txt w={700} size={15} style={{ marginTop: 18 }}>
          {t('usually')}
        </Txt>
        <Row style={{ gap: 8, flexWrap: 'wrap', marginTop: 9 }}>
          {[t('weeknights'), t('fridays')].map((label) => (
            <View
              key={label}
              style={{
                borderWidth: 1.5,
                borderColor: colors.ink12,
                paddingVertical: 8,
                paddingHorizontal: 13,
                borderRadius: radius.pill,
                backgroundColor: colors.card,
              }}
            >
              <Txt w={600} size={12.5}>
                {label}
              </Txt>
            </View>
          ))}
        </Row>

        <Txt w={700} size={15} style={{ marginTop: 18 }}>
          {t('reviews')}
        </Txt>
        <Card radiusValue={radius.card14} style={{ marginTop: 9, paddingVertical: 13, paddingHorizontal: 15 }}>
          <Row style={{ justifyContent: 'space-between' }}>
            <Txt w={700} size={13}>
              Karim S.
            </Txt>
            <Txt w={700} size={13} color={brand.green}>
              ★★★★★
            </Txt>
          </Row>
          <Txt size={13} lineHeight={19.5} color={colors.ink65} style={{ marginTop: 5 }}>
            {t('rev3')}
          </Txt>
        </Card>

        <Button
          label={t('message')}
          onPress={() => navigation.navigate('Chat')}
          size={15}
          paddingV={15}
          style={{ marginTop: 22 }}
        />
      </ScrollView>
    </Screen>
  );
}
