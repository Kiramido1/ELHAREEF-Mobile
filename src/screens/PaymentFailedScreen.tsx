import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Animated, Pressable, View } from 'react-native';
import { Txt } from '../components/Txt';
import { Button, Card, Row, Screen } from '../components/ui';
import { CrossIcon } from '../components/icons';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { confirmBookingCash } from '../services/bookings';
import { useBookingDerived } from '../state/BookingContext';
import { brand, radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'PaymentFailed'>;

export function PaymentFailedScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t } = useI18n();
  const derived = useBookingDerived();
  const pop = useRef(new Animated.Value(0)).current;
  const [paying, setPaying] = useState(false);

  useEffect(() => {
    Animated.spring(pop, { toValue: 1, friction: 5, tension: 90, useNativeDriver: true }).start();
  }, [pop]);

  const payCash = () => {
    if (paying) return;
    setPaying(true);
    confirmBookingCash()
      .then(() => navigation.replace('Confirmed'))
      .finally(() => setPaying(false));
  };

  return (
    <Screen style={{ paddingHorizontal: 24, paddingBottom: 40 }}>
      <Animated.View
        style={{
          alignSelf: 'center',
          marginTop: 28,
          width: 92,
          height: 92,
          borderRadius: 46,
          backgroundColor: 'rgba(214,69,69,.12)',
          alignItems: 'center',
          justifyContent: 'center',
          opacity: pop,
          transform: [{ scale: pop.interpolate({ inputRange: [0, 1], outputRange: [0.4, 1] }) }],
        }}
      >
        <CrossIcon size={38} color={brand.danger} />
      </Animated.View>
      <Txt w={800} size={24} style={{ marginTop: 22, textAlign: 'center' }}>
        {t('payFailed')}
      </Txt>
      <Txt size={14} lineHeight={22.5} color={colors.ink6} style={{ marginTop: 9, paddingHorizontal: 14, textAlign: 'center' }}>
        {t('payFailedSub')}
      </Txt>
      <Card
        radiusValue={radius.box}
        style={{
          marginTop: 20,
          paddingVertical: 14,
          paddingHorizontal: 16,
          flexDirection: 'row',
          justifyContent: 'space-between',
        }}
      >
        <Txt size={13.5} color={colors.ink55}>
          {derived.pitch.name} · {derived.durStr}
        </Txt>
        <Txt w={800} size={13.5}>
          {derived.total} {t('egp')}
        </Txt>
      </Card>
      <View style={{ marginTop: 'auto', gap: 10 }}>
        <Button label={t('retryPay')} size={15} onPress={() => navigation.goBack()} />
        {paying ? (
          <Pressable
            disabled
            style={{
              borderWidth: 1.5,
              borderColor: colors.ink14,
              backgroundColor: colors.card,
              paddingVertical: 14,
              borderRadius: radius.card14,
              alignItems: 'center',
            }}
          >
            <ActivityIndicator color={colors.ink55} />
          </Pressable>
        ) : (
          <Button label={t('payCashInstead')} variant="outline" size={14} weight={600} paddingV={14} onPress={payCash} />
        )}
      </View>
    </Screen>
  );
}
