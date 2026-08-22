import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { CompositeScreenProps } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { Animated, Pressable, ScrollView, View } from 'react-native';
import { RevealOnScroll, useScrollReveal } from '../components/anim';
import { Txt } from '../components/Txt';
import { BackButton, Button, Card, Row, Screen, Segmented, StatusPill } from '../components/ui';
import { CalendarIcon } from '../components/icons';
import { useI18n } from '../i18n';
import { MainTabParamList, RootStackParamList } from '../navigation/types';
import { PAST_BOOKINGS } from '../services/bookings';
import { useBookingDerived } from '../state/BookingContext';
import { brand, layout, radius, useTheme } from '../theme';
import { BookingRecord, BookingStatus } from '../types';

type Props = CompositeScreenProps<
  BottomTabScreenProps<MainTabParamList, 'Bookings'>,
  NativeStackScreenProps<RootStackParamList>
>;

const TABS: BookingStatus[] = ['confirmed', 'completed', 'cancelled'];

export function BookingsScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const derived = useBookingDerived();
  const [tab, setTab] = useState(0);
  const { scrollY, onScroll } = useScrollReveal();

  // The live booking from the current flow leads the Upcoming tab.
  const liveBooking: BookingRecord = {
    id: 'EH-84213',
    pitch: derived.pitch.name,
    date: derived.dateStr,
    dateAr: derived.dateStr,
    time: derived.rangeStr,
    timeAr: derived.rangeStr,
    dur: derived.durStr,
    durAr: derived.durStr,
    status: 'confirmed',
    price: derived.total,
  };

  const byStatus = (status: BookingStatus) =>
    PAST_BOOKINGS.filter((b) => b.status === status);
  const list: BookingRecord[] =
    tab === 0 ? [liveBooking, ...byStatus('confirmed')] : byStatus(TABS[tab]);

  const statusLabel = (s: BookingStatus) =>
    s === 'confirmed' ? t('confirmedStatus') : s === 'completed' ? t('completedStatus') : t('cancelledStatus');
  const statusColors = (s: BookingStatus) =>
    s === 'confirmed'
      ? { bg: colors.tint, fg: brand.green }
      : s === 'completed'
        ? { bg: colors.chipGray, fg: colors.ink6 }
        : { bg: brand.dangerBg, fg: brand.danger };

  return (
    <Screen>
      <Animated.ScrollView
        contentContainerStyle={{ paddingHorizontal: layout.screenX, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
        onScroll={onScroll}
        scrollEventThrottle={16}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.navigate('Home')} />
          <Txt w={800} size={23} letterSpacing={-0.23}>
            {t('bookTitle')}
          </Txt>
        </Row>
        <View style={{ marginTop: 14 }}>
          <Segmented
            options={[t('upcoming'), t('completedTab'), t('cancelledTab')]}
            selectedIndex={tab}
            onSelect={setTab}
          />
        </View>

        {list.length === 0 ? (
          <View style={{ marginTop: 46, alignItems: 'center', paddingHorizontal: 24 }}>
            <View
              style={{
                width: 74,
                height: 74,
                borderRadius: 37,
                backgroundColor: colors.tint,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <CalendarIcon size={30} color={brand.green} />
            </View>
            <Txt w={800} size={16} style={{ marginTop: 14, textAlign: 'center' }}>
              {t('emptyBk')}
            </Txt>
            <Txt size={13} lineHeight={19.5} color={colors.ink55} style={{ marginTop: 6, textAlign: 'center' }}>
              {t('emptyBkSub')}
            </Txt>
            <Button
              label={t('bookPitchBtn')}
              onPress={() => navigation.navigate('Booking')}
              size={14}
              paddingV={13}
              style={{ marginTop: 16, paddingHorizontal: 24, borderRadius: radius.input }}
            />
          </View>
        ) : (
          <View style={{ marginTop: 16, gap: 13 }}>
            {list.map((b) => {
              const sc = statusColors(b.status);
              return (
                <RevealOnScroll key={b.id} scrollY={scrollY}>
                <Card radiusValue={radius.card17} style={{ paddingVertical: 15, paddingHorizontal: 16 }}>
                  <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
                    <Txt w={700} size={15}>
                      {b.pitch}
                    </Txt>
                    <StatusPill label={statusLabel(b.status)} bg={sc.bg} fg={sc.fg} />
                  </Row>
                  <Txt size={12.5} color={colors.ink55} style={{ marginTop: 5 }}>
                    {pick(b.date, b.dateAr)} · {pick(b.time, b.timeAr)} · {pick(b.dur, b.durAr)}
                  </Txt>
                  <Row style={{ marginTop: 10, alignItems: 'center', justifyContent: 'space-between' }}>
                    <Txt w={800} size={14}>
                      {b.price} {t('egp')}
                    </Txt>
                    <Row style={{ gap: 8 }}>
                      {b.status === 'confirmed' ? (
                        <>
                          <Pressable
                            onPress={() => navigation.navigate('CreateMatch')}
                            accessibilityRole="button"
                            style={({ pressed }) => ({
                              borderWidth: 1.5,
                              borderColor: colors.ink14,
                              backgroundColor: colors.card,
                              paddingVertical: 9,
                              paddingHorizontal: 13,
                              borderRadius: radius.md,
                              transform: [{ scale: pressed ? 0.95 : 1 }],
                            })}
                          >
                            <Txt w={700} size={12}>
                              {t('findPlayers')}
                            </Txt>
                          </Pressable>
                          <Pressable
                            onPress={() => navigation.navigate('BookingDetails')}
                            accessibilityRole="button"
                            style={({ pressed }) => ({
                              backgroundColor: colors.navyBtn,
                              paddingVertical: 9,
                              paddingHorizontal: 13,
                              borderRadius: radius.md,
                              transform: [{ scale: pressed ? 0.95 : 1 }],
                            })}
                          >
                            <Txt w={700} size={12} color="#fff">
                              {t('view')}
                            </Txt>
                          </Pressable>
                        </>
                      ) : b.status === 'completed' ? (
                        <Pressable
                          onPress={() => navigation.navigate('Booking')}
                          accessibilityRole="button"
                          style={({ pressed }) => ({
                            backgroundColor: colors.tint,
                            paddingVertical: 9,
                            paddingHorizontal: 13,
                            borderRadius: radius.md,
                            transform: [{ scale: pressed ? 0.95 : 1 }],
                          })}
                        >
                          <Txt w={700} size={12}>
                            {t('bookAgain')}
                          </Txt>
                        </Pressable>
                      ) : (
                        <Txt w={600} size={12} color={colors.ink5} style={{ paddingVertical: 9 }}>
                          {t('refunded')}
                        </Txt>
                      )}
                    </Row>
                  </Row>
                </Card>
                </RevealOnScroll>
              );
            })}
          </View>
        )}
      </Animated.ScrollView>
    </Screen>
  );
}
