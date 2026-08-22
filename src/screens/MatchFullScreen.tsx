import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { Alert, View } from 'react-native';
import { Txt } from '../components/Txt';
import { BackButton, Button, Card, Row, Screen, StatusPill } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { getMatch } from '../services/matches';
import { radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'MatchFull'>;

export function MatchFullScreen({ navigation, route }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const match = getMatch(route.params.matchId);

  const joinWaitlist = () =>
    Alert.alert(
      t('waitlist'),
      pick(
        "You're on the waitlist. We'll notify you if a spot opens up.",
        'انت في قايمة الانتظار. هنبعتلك إشعار لو مكان فضي.',
      ),
      [{ text: 'OK', onPress: () => navigation.goBack() }],
    );

  return (
    <Screen style={{ paddingHorizontal: 24, paddingBottom: 40 }}>
      <Row style={{ alignItems: 'center', gap: 12 }}>
        <BackButton onPress={() => navigation.goBack()} />
        <Txt w={800} size={18}>
          {t('matchDetails')}
        </Txt>
      </Row>

      <Card style={{ marginTop: 16, paddingVertical: 16, paddingHorizontal: 17, opacity: 0.75 }}>
        <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
          <Txt w={800} size={15}>
            {match.pitch}
          </Txt>
          <StatusPill label={t('fullChip')} bg={colors.navyBtn} fg="#fff" size={10.5} weight={800} />
        </Row>
        <Txt size={12.5} color={colors.ink55} style={{ marginTop: 5 }}>
          {t('mm5')}
        </Txt>
        <View
          style={{
            marginTop: 12,
            height: 6,
            borderRadius: radius.pill,
            backgroundColor: colors.navyBtn,
          }}
        />
      </Card>

      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <View
          style={{
            width: 88,
            height: 88,
            borderRadius: 44,
            backgroundColor: colors.tint,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Txt w={800} size={26} style={{ textAlign: 'center' }}>
            {match.total}/{match.total}
          </Txt>
        </View>
        <Txt w={800} size={18} style={{ marginTop: 16, textAlign: 'center' }}>
          {t('fullT')}
        </Txt>
        <Txt
          size={13.5}
          lineHeight={21}
          color={colors.ink55}
          style={{ marginTop: 8, maxWidth: 260, textAlign: 'center' }}
        >
          {t('fullSub')}
        </Txt>
      </View>

      <View style={{ gap: 10 }}>
        <Button label={t('waitlist')} variant="outline" size={14} weight={600} paddingV={14} onPress={joinWaitlist} />
        <Button label={t('anotherMatch')} size={15} paddingV={15} onPress={() => navigation.goBack()} />
      </View>
    </Screen>
  );
}
