import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { Alert, ScrollView, View } from 'react-native';
import { PitchArt } from '../components/PitchArt';
import { pitchPhotos } from '../constants/pitchPhotos';
import { Txt } from '../components/Txt';
import { BackButton, Button, Card, Row, Screen, StatusPill } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { BOOKING_ID } from '../services/bookings';
import { useBooking, useBookingDerived } from '../state/BookingContext';
import { brand, layout, radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'BookingDetails'>;

function DetailRow({ label, value, valueColor, wide }: { label: string; value: string; valueColor?: string; wide?: boolean }) {
  const { colors } = useTheme();
  return (
    <Row style={{ justifyContent: 'space-between' }}>
      <Txt size={13.5} color={colors.ink55}>
        {label}
      </Txt>
      <Txt w={700} size={13.5} color={valueColor} letterSpacing={wide ? 0.68 : undefined}>
        {value}
      </Txt>
    </Row>
  );
}

export function BookingDetailsScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const booking = useBooking();
  const derived = useBookingDerived();

  const payLabel =
    (booking.payMethod === 'card' ? t('cardLabel') : t('walletLabel')) +
    (booking.payMode === 'deposit' ? t('depositPaid') : '');

  const confirmCancel = () =>
    Alert.alert(
      t('cancelBk'),
      pick(
        'Cancel this booking? Free cancellation applies until Friday 8:00 AM.',
        'إلغاء الحجز ده؟ الإلغاء المجاني متاح حتى الجمعة 8 صباحًا.',
      ),
      [
        { text: pick('Keep booking', 'خليه'), style: 'cancel' },
        {
          text: t('cancelBk'),
          style: 'destructive',
          onPress: () => navigation.navigate('Tabs', { screen: 'Bookings' }),
        },
      ],
    );

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, paddingHorizontal: layout.screenX, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.goBack()} />
          <Txt w={800} size={18}>
            {t('bkDetails')}
          </Txt>
        </Row>

        <Card style={{ marginTop: 16, overflow: 'hidden' }}>
          <PitchArt
            gradIndex={derived.pitch.gradIndex}
            photo={pitchPhotos[derived.pitch.id]}
            style={{ height: 110 }}
          >
            <View style={{ position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, backgroundColor: 'rgba(3,8,20,.22)' }} />
            <Txt
              w={800}
              size={16}
              color={brand.cloud}
              style={{
                position: 'absolute',
                bottom: 11,
                left: 15,
                textShadowColor: 'rgba(3,8,20,.5)',
                textShadowRadius: 6,
                textShadowOffset: { width: 0, height: 1 },
              }}
            >
              {derived.pitch.name}
            </Txt>
            <View style={{ position: 'absolute', top: 11, right: 11 }}>
              <StatusPill label={t('confirmedChip')} bg={brand.lime} fg={brand.navy} size={10.5} weight={800} />
            </View>
          </PitchArt>
          <View style={{ paddingVertical: 15, paddingHorizontal: 17, gap: 11 }}>
            <DetailRow label={t('bookingId')} value={BOOKING_ID} wide />
            <DetailRow label={t('date')} value={derived.dateStr} />
            <DetailRow label={t('time')} value={derived.rangeStr} />
            <DetailRow label={t('duration')} value={derived.durStr} />
            {booking.recur ? <DetailRow label={t('schedule')} value={t('weekly4')} valueColor={brand.green} /> : null}
            <DetailRow label={t('payment')} value={payLabel} />
            <View style={{ borderTopWidth: 1, borderStyle: 'dashed', borderColor: colors.ink12 }} />
            <Row style={{ justifyContent: 'space-between' }}>
              <Txt w={800} size={15}>
                {t('total')}
              </Txt>
              <Txt w={800} size={15} color={brand.green}>
                {derived.total} {t('egp')}
              </Txt>
            </Row>
          </View>
        </Card>

        <View
          style={{
            marginTop: 14,
            borderWidth: 1,
            borderColor: colors.ink08,
            borderRadius: radius.card14,
            backgroundColor: colors.tint,
            paddingVertical: 12,
            paddingHorizontal: 15,
          }}
        >
          <Txt size={12.5} lineHeight={19.5} color={colors.ink75}>
            {t('gateNote')}
          </Txt>
        </View>

        <View style={{ marginTop: 'auto', paddingTop: 24, gap: 10 }}>
          <Button
            label={t('findForMatch')}
            onPress={() => navigation.navigate('CreateMatch')}
            size={15}
            paddingV={15}
          />
          <Button
            label={t('cancelBk')}
            variant="danger-outline"
            size={14}
            weight={600}
            paddingV={13}
            onPress={confirmCancel}
          />
        </View>
      </ScrollView>
    </Screen>
  );
}
