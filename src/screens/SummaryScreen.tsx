import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, View } from 'react-native';
import { PitchArt } from '../components/PitchArt';
import { pitchPhotos } from '../constants/pitchPhotos';
import { Txt } from '../components/Txt';
import { BackButton, Card, RadioOptionCard, Row, Screen } from '../components/ui';
import { typeAr, useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { confirmBooking } from '../services/bookings';
import { NetworkError, PaymentDeclinedError } from '../services/network';
import { useBooking, useBookingDerived } from '../state/BookingContext';
import { brand, layout, radius, shadows, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Summary'>;

function SummaryRow({ label, value, valueColor, bold }: { label: string; value: string; valueColor?: string; bold?: boolean }) {
  const { colors } = useTheme();
  return (
    <Row style={{ justifyContent: 'space-between' }}>
      <Txt size={13.5} color={colors.ink55}>
        {label}
      </Txt>
      <Txt w={bold ? 700 : 600} size={13.5} color={valueColor}>
        {value}
      </Txt>
    </Row>
  );
}

export function SummaryScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const booking = useBooking();
  const derived = useBookingDerived();
  const [submitting, setSubmitting] = useState(false);

  const typeLabel = pick(derived.pitch.type, typeAr[derived.pitch.type] ?? derived.pitch.type);
  const lineLabel = `${t('pitchWord')} · ${derived.durStr}${booking.recur ? t('x4weeks') : ''}`;

  const confirm = async () => {
    if (submitting) return;
    setSubmitting(true);
    try {
      await confirmBooking(booking.payMethod);
      navigation.navigate('Confirmed');
    } catch (e) {
      if (e instanceof PaymentDeclinedError) navigation.navigate('PaymentFailed');
      else if (e instanceof NetworkError) navigation.navigate('Offline');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, paddingHorizontal: layout.screenX, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.goBack()} />
          <Txt w={800} size={18}>
            {t('sumTitle')}
          </Txt>
        </Row>

        <Card style={{ marginTop: 18, overflow: 'hidden' }}>
          <PitchArt
            gradIndex={derived.pitch.gradIndex}
            photo={pitchPhotos[derived.pitch.id]}
            style={{ height: 86 }}
          >
            <View style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, backgroundColor: 'rgba(3,8,20,.22)' }} />
            <Txt
              w={800}
              size={15}
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
              {derived.pitch.name}
            </Txt>
          </PitchArt>
          <View style={{ paddingVertical: 15, paddingHorizontal: 17, gap: 11 }}>
            <SummaryRow label={t('date')} value={derived.dateStr} bold />
            <SummaryRow label={t('time')} value={derived.rangeStr} bold />
            <SummaryRow label={t('duration')} value={derived.durStr} bold />
            <SummaryRow label={t('pitchType')} value={typeLabel} bold />
            {booking.recur ? (
              <SummaryRow label={t('schedule')} value={t('weekly4')} valueColor={brand.green} bold />
            ) : null}
            <View style={{ borderTopWidth: 1, borderStyle: 'dashed', borderColor: colors.ink12, marginVertical: 2 }} />
            <SummaryRow label={lineLabel} value={`${derived.price} ${t('egp')}`} />
            <SummaryRow label={t('fee')} value={`${derived.fee} ${t('egp')}`} />
            <Row style={{ justifyContent: 'space-between' }}>
              <Txt w={800} size={16}>
                {t('total')}
              </Txt>
              <Txt w={800} size={16} color={brand.green}>
                {derived.total} {t('egp')}
              </Txt>
            </Row>
            {booking.payMode === 'deposit' ? (
              <>
                <Row style={{ justifyContent: 'space-between' }}>
                  <Txt size={12.5} color={colors.ink55}>
                    {t('dueNow')}
                  </Txt>
                  <Txt w={800} size={12.5} color={brand.green}>
                    {derived.deposit} {t('egp')}
                  </Txt>
                </Row>
                <Row style={{ justifyContent: 'space-between' }}>
                  <Txt size={12.5} color={colors.ink55}>
                    {t('atVenue')}
                  </Txt>
                  <Txt w={600} size={12.5}>
                    {derived.remaining} {t('egp')}
                  </Txt>
                </Row>
              </>
            ) : null}
          </View>
        </Card>

        <Txt w={700} size={13} color={colors.ink6} style={{ marginTop: 18 }}>
          {t('howMuch')}
        </Txt>
        <View style={{ gap: 9, marginTop: 9 }}>
          <RadioOptionCard
            label={t('payFullLabel')}
            sub={pick(
              `${derived.total} EGP now · nothing at the venue`,
              `${derived.total} جنيه دلوقتي · مفيش حاجة في الملعب`,
            )}
            selected={booking.payMode === 'full'}
            onPress={() => booking.setPayMode('full')}
          />
          <RadioOptionCard
            label={t('payDepositLabel')}
            sub={pick(
              `${derived.deposit} EGP now · ${derived.remaining} EGP at the venue`,
              `${derived.deposit} جنيه دلوقتي · ${derived.remaining} جنيه في الملعب`,
            )}
            selected={booking.payMode === 'deposit'}
            onPress={() => booking.setPayMode('deposit')}
          />
        </View>

        <Txt w={700} size={13} color={colors.ink6} style={{ marginTop: 16 }}>
          {t('payWith')}
        </Txt>
        <View style={{ gap: 9, marginTop: 9 }}>
          <RadioOptionCard
            label={t('cardLabel')}
            sub={t('cardSub')}
            selected={booking.payMethod === 'card'}
            onPress={() => booking.setPayMethod('card')}
          />
          <RadioOptionCard
            label={t('walletLabel')}
            sub={t('walletSub')}
            selected={booking.payMethod === 'wallet'}
            onPress={() => booking.setPayMethod('wallet')}
          />
        </View>

        <Txt size={12} lineHeight={18.5} color={colors.ink5} style={{ marginTop: 14 }}>
          {t('cancelNote')}
        </Txt>

        <Pressable
          onPress={confirm}
          disabled={submitting}
          accessibilityRole="button"
          accessibilityState={{ disabled: submitting, busy: submitting }}
          style={({ pressed }) => [
            {
              marginTop: 'auto',
              backgroundColor: brand.green,
              paddingVertical: 17,
              borderRadius: radius.card14,
              alignItems: 'center',
              marginBottom: 4,
              transform: [{ scale: pressed && !submitting ? 0.97 : 1 }],
            },
            shadows.confirmCta,
          ]}
        >
          {submitting ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Txt w={700} size={16} color="#fff">
              {t('confirmBk')} · {derived.dueNow} {t('egp')}
            </Txt>
          )}
        </Pressable>
      </ScrollView>
    </Screen>
  );
}
