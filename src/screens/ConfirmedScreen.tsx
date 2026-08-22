import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useEffect, useRef } from 'react';
import { Animated, ScrollView, View } from 'react-native';
import { Txt } from '../components/Txt';
import { Avatar, Button, Card, Row, Screen } from '../components/ui';
import { CheckIcon } from '../components/icons';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { BOOKING_ID } from '../services/bookings';
import { useBookingDerived } from '../state/BookingContext';
import { brand, radius, shadows, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Confirmed'>;

export function ConfirmedScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t } = useI18n();
  const derived = useBookingDerived();
  const pop = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.spring(pop, { toValue: 1, friction: 5, tension: 90, useNativeDriver: true }).start();
  }, [pop]);

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, paddingTop: 28, paddingHorizontal: 24, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View
          style={[
            {
              alignSelf: 'center',
              width: 92,
              height: 92,
              borderRadius: 46,
              backgroundColor: brand.green,
              alignItems: 'center',
              justifyContent: 'center',
              opacity: pop,
              transform: [{ scale: pop.interpolate({ inputRange: [0, 1], outputRange: [0.4, 1] }) }],
            },
            shadows.confirmPop,
          ]}
        >
          <CheckIcon size={44} color="#fff" />
        </Animated.View>
        <Txt w={800} size={25} letterSpacing={-0.25} style={{ marginTop: 22, textAlign: 'center' }}>
          {t('confirmedT')}
        </Txt>
        <Txt ar size={14} color={brand.green} style={{ marginTop: 6, textAlign: 'center', writingDirection: 'rtl' }}>
          يلا، الملعب محجوز!
        </Txt>

        <Card style={{ marginTop: 20, paddingVertical: 17, paddingHorizontal: 18 }}>
          <Txt w={800} size={16.5}>
            {derived.pitch.name}
          </Txt>
          <Txt size={13.5} color={colors.ink6} style={{ marginTop: 5 }}>
            {derived.dateStr} · {derived.rangeStr} · {derived.durStr}
          </Txt>
          <Row
            style={{
              marginTop: 13,
              alignItems: 'center',
              justifyContent: 'space-between',
              backgroundColor: colors.tint,
              borderRadius: radius.action,
              paddingVertical: 11,
              paddingHorizontal: 14,
            }}
          >
            <Txt w={600} size={12} color={colors.ink55}>
              {t('bookingId')}
            </Txt>
            <Txt w={800} size={14} letterSpacing={0.84}>
              {BOOKING_ID}
            </Txt>
          </Row>
        </Card>

        <Row
          style={{
            marginTop: 18,
            borderWidth: 1.5,
            borderColor: colors.limeBd,
            backgroundColor: colors.limeTint,
            borderRadius: radius.box,
            paddingVertical: 14,
            paddingHorizontal: 16,
            gap: 12,
            alignItems: 'center',
          }}
        >
          <Avatar initial="6/8" palette="navy" size={38} fontSize={13} />
          <Txt size={13} lineHeight={19.5} style={{ flex: 1 }}>
            {t('missingP')}
          </Txt>
        </Row>

        <View style={{ marginTop: 'auto', paddingTop: 24, gap: 10 }}>
          <Button label={t('findPlayers')} variant="navy" onPress={() => navigation.navigate('FindPlayers')} />
          <Button
            label={t('viewBooking')}
            variant="outline"
            size={14.5}
            weight={600}
            paddingV={14}
            onPress={() => navigation.navigate('BookingDetails')}
          />
        </View>
      </ScrollView>
    </Screen>
  );
}
