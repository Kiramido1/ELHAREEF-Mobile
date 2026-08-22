import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { SelectFade } from '../components/anim';
import { Txt } from '../components/Txt';
import { BackButton, Card, Row, Screen, ToggleSwitch } from '../components/ui';
import { useI18n, areaAr } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import {
  BOOKING_MONTHS,
  BUSY_HOURS,
  DURATIONS,
  SLOT_HOURS,
  WEEKDAY_SHORT_AR,
  WEEKDAY_SHORT_EN,
  useBooking,
  useBookingDerived,
} from '../state/BookingContext';
import { brand, layout, radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Booking'>;

export function BookingScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick, lang, isRTL } = useI18n();
  const insets = useSafeAreaInsets();
  const booking = useBooking();
  const derived = useBookingDerived();

  const monthDef = BOOKING_MONTHS[booking.calMonth];
  const weekdays = lang === 'ar' ? WEEKDAY_SHORT_AR : WEEKDAY_SHORT_EN;
  // Week starts Saturday, matching the design's calendar offset.
  const calOffset = (new Date(2026, monthDef.monthIndex, 1).getDay() + 1) % 7;

  const cells: { day: number | null; past: boolean; selected: boolean }[] = [];
  for (let i = 0; i < calOffset; i++) cells.push({ day: null, past: false, selected: false });
  for (let d = 1; d <= monthDef.length; d++) {
    const past = booking.calMonth === 0 && d < 21;
    const selected = booking.selMonth === booking.calMonth && booking.selDay === d;
    cells.push({ day: d, past, selected });
  }

  const durLabel = (h: number) =>
    lang === 'ar'
      ? h === 1
        ? 'ساعة'
        : h === 2
          ? 'ساعتين'
          : `${h} ساعات`
      : `${h} ${h === 1 ? 'hour' : 'hours'}`;

  const areaLabel = pick(derived.pitch.area, areaAr[derived.pitch.area] ?? derived.pitch.area);
  const noTime = !derived.timePicked;

  return (
    <Screen>
      <Row style={{ alignItems: 'center', gap: 12, paddingHorizontal: layout.screenX }}>
        <BackButton onPress={() => navigation.goBack()} />
        <View>
          <Txt w={800} size={16.5}>
            {derived.pitch.name}
          </Txt>
          <Txt size={12} color={colors.ink55}>
            {areaLabel} · {derived.pitch.price} {t('egphr')}
          </Txt>
        </View>
      </Row>

      <ScrollView
        contentContainerStyle={{ paddingTop: 6, paddingHorizontal: layout.screenX, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Step 1 — date */}
        <Row style={{ marginTop: 16, alignItems: 'center', justifyContent: 'space-between' }}>
          <Txt w={700} size={15}>
            {t('step1')}
          </Txt>
          <Row style={{ alignItems: 'center', gap: 6 }}>
            <Pressable
              onPress={() => booking.setCalMonth(0)}
              accessibilityRole="button"
              style={{
                width: 30,
                height: 30,
                borderRadius: radius.chip9,
                borderWidth: 1.5,
                borderColor: colors.ink12,
                backgroundColor: colors.card,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Txt size={15} color={booking.calMonth === 1 ? colors.ink : colors.ink25} style={{ marginTop: -2, textAlign: 'center' }}>
                ‹
              </Txt>
            </Pressable>
            <Txt w={700} size={13} style={{ minWidth: 112, textAlign: 'center' }}>
              {pick(monthDef.nameEn, monthDef.nameAr)}
            </Txt>
            <Pressable
              onPress={() => booking.setCalMonth(1)}
              accessibilityRole="button"
              style={{
                width: 30,
                height: 30,
                borderRadius: radius.chip9,
                borderWidth: 1.5,
                borderColor: colors.ink12,
                backgroundColor: colors.card,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Txt size={15} color={booking.calMonth === 0 ? colors.ink : colors.ink25} style={{ marginTop: -2, textAlign: 'center' }}>
                ›
              </Txt>
            </Pressable>
          </Row>
        </Row>
        <Card radiusValue={radius.box} style={{ marginTop: 10, paddingTop: 12, paddingHorizontal: 12, paddingBottom: 14 }}>
          <View style={{ flexDirection: 'row' }}>
            {weekdays.map((w) => (
              <Txt key={w} w={700} size={10.5} color={colors.ink4} style={{ flex: 1, textAlign: 'center', paddingVertical: 4 }}>
                {w}
              </Txt>
            ))}
          </View>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', marginTop: 2 }}>
            {cells.map((c, i) => (
              <Pressable
                key={i}
                disabled={c.day === null || c.past}
                onPress={() => c.day && booking.selectDay(booking.calMonth, c.day)}
                accessibilityRole="button"
                accessibilityState={{ selected: c.selected, disabled: c.past }}
                style={{ width: `${100 / 7}%` }}
              >
                <SelectFade
                  on={c.selected}
                  off={
                    <View style={{ paddingVertical: 9, borderRadius: radius.md, alignItems: 'center' }}>
                      <Txt
                        w={600}
                        size={13}
                        color={c.day === null ? 'transparent' : c.past ? colors.ink25 : colors.ink}
                        style={{ textAlign: 'center' }}
                      >
                        {c.day ?? ''}
                      </Txt>
                    </View>
                  }
                  over={
                    <View
                      style={{
                        width: '100%',
                        height: '100%',
                        borderRadius: radius.md,
                        backgroundColor: brand.green,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <Txt w={800} size={13} color="#fff" style={{ textAlign: 'center' }}>
                        {c.day ?? ''}
                      </Txt>
                    </View>
                  }
                />
              </Pressable>
            ))}
          </View>
        </Card>

        {/* Step 2 — time */}
        <Txt w={700} size={15} style={{ marginTop: 20 }}>
          {t('step2')}
        </Txt>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', marginTop: 10, marginHorizontal: -4 }}>
          {SLOT_HOURS.map((h) => {
            const busy = BUSY_HOURS.includes(h);
            const on = booking.selTime === h;
            return (
              <View key={h} style={{ width: '33.33%', padding: 4 }}>
                <Pressable
                  disabled={busy}
                  onPress={() => booking.selectTime(h)}
                  accessibilityRole="button"
                  accessibilityState={{ selected: on, disabled: busy }}
                >
                  <SelectFade
                    on={on}
                    off={
                      <View
                        style={{
                          paddingVertical: 13,
                          borderRadius: radius.input12,
                          borderWidth: 1.5,
                          borderColor: colors.ink12,
                          backgroundColor: busy ? colors.tint : colors.card,
                          alignItems: 'center',
                        }}
                      >
                        <Txt
                          w={600}
                          size={13.5}
                          color={busy ? colors.ink3 : colors.ink}
                          style={{ textDecorationLine: busy ? 'line-through' : 'none', textAlign: 'center' }}
                        >
                          {derived.fmtHour(h)}
                        </Txt>
                      </View>
                    }
                    over={
                      <View
                        style={{
                          width: '100%',
                          height: '100%',
                          borderRadius: radius.input12,
                          borderWidth: 1.5,
                          borderColor: brand.green,
                          backgroundColor: brand.green,
                          alignItems: 'center',
                          justifyContent: 'center',
                        }}
                      >
                        <Txt w={600} size={13.5} color="#fff" style={{ textAlign: 'center' }}>
                          {derived.fmtHour(h)}
                        </Txt>
                      </View>
                    }
                  />
                </Pressable>
              </View>
            );
          })}
        </View>

        {/* Step 3 — duration */}
        <Txt w={700} size={15} style={{ marginTop: 20 }}>
          {t('step3')}
        </Txt>
        <Row style={{ gap: 8, marginTop: 10 }}>
          {DURATIONS.map((h) => {
            const on = booking.selDur === h;
            return (
              <Pressable
                key={h}
                onPress={() => booking.selectDur(h)}
                accessibilityRole="button"
                accessibilityState={{ selected: on }}
                style={{ flex: 1 }}
              >
                <SelectFade
                  on={on}
                  off={
                    <View
                      style={{
                        paddingVertical: 13,
                        borderRadius: radius.input12,
                        borderWidth: 1.5,
                        borderColor: colors.ink12,
                        backgroundColor: colors.card,
                        alignItems: 'center',
                      }}
                    >
                      <Txt w={700} size={13.5} style={{ textAlign: 'center' }}>
                        {durLabel(h)}
                      </Txt>
                    </View>
                  }
                  over={
                    <View
                      style={{
                        width: '100%',
                        height: '100%',
                        borderRadius: radius.input12,
                        borderWidth: 1.5,
                        borderColor: brand.green,
                        backgroundColor: brand.green,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <Txt w={700} size={13.5} color="#fff" style={{ textAlign: 'center' }}>
                        {durLabel(h)}
                      </Txt>
                    </View>
                  }
                />
              </Pressable>
            );
          })}
        </Row>

        {/* Repeat weekly */}
        <View
          style={{
            marginTop: 20,
            borderWidth: 1.5,
            borderColor: booking.recur ? 'rgba(36,165,81,.45)' : colors.ink12,
            backgroundColor: booking.recur ? colors.tint : colors.card,
            borderRadius: radius.box,
            paddingVertical: 14,
            paddingHorizontal: 16,
          }}
        >
          <Row style={{ alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
            <View style={{ flexShrink: 1 }}>
              <Txt w={800} size={14.5}>
                {t('repeatW')}
              </Txt>
              <Txt size={12} color={colors.ink55} style={{ marginTop: 3 }}>
                {t('repeatSub')}
              </Txt>
            </View>
            <ToggleSwitch value={booking.recur} onToggle={booking.toggleRecur} />
          </Row>
          {booking.recur ? (
            <>
              <Row style={{ gap: 7, flexWrap: 'wrap', marginTop: 12 }}>
                {derived.recurDates.map((d) => (
                  <View
                    key={d}
                    style={{
                      backgroundColor: colors.card,
                      borderWidth: 1.5,
                      borderColor: 'rgba(36,165,81,.4)',
                      paddingVertical: 6,
                      paddingHorizontal: 11,
                      borderRadius: radius.pill,
                    }}
                  >
                    <Txt w={700} size={12} color={brand.green}>
                      {d}
                    </Txt>
                  </View>
                ))}
              </Row>
              <Txt size={12} lineHeight={18} color={colors.ink65} style={{ marginTop: 10 }}>
                {t('repeatNote')}
              </Txt>
            </>
          ) : null}
        </View>

        {/* Selection summary */}
        {derived.timePicked ? (
          <Row
            style={{
              marginTop: 18,
              borderWidth: 1.5,
              borderColor: 'rgba(36,165,81,.35)',
              backgroundColor: colors.tint,
              borderRadius: radius.box,
              paddingVertical: 15,
              paddingHorizontal: 17,
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <View>
              <Txt w={800} size={15.5}>
                {derived.rangeStr}
              </Txt>
              <Txt size={12.5} color={colors.ink6} style={{ marginTop: 3 }}>
                {derived.dateStr} · {derived.durStr}
              </Txt>
            </View>
            <Txt w={800} size={18} color={brand.green}>
              {derived.price}{' '}
              <Txt w={600} size={11} color={colors.ink5}>
                EGP
              </Txt>
            </Txt>
          </Row>
        ) : null}
      </ScrollView>

      {/* Sticky continue */}
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
          disabled={noTime}
          onPress={() => navigation.navigate('Summary')}
          accessibilityRole="button"
          accessibilityState={{ disabled: noTime }}
          style={({ pressed }) => ({
            backgroundColor: noTime ? colors.disabled : brand.green,
            paddingVertical: 16,
            borderRadius: radius.card14,
            alignItems: 'center',
            transform: [{ scale: pressed && !noTime ? 0.97 : 1 }],
          })}
        >
          <Txt w={700} size={15.5} color={noTime ? colors.ink35 : '#fff'}>
            {noTime ? t('pickStartTime') : `${t('continue')} · ${derived.total} ${t('egp')}`}
          </Txt>
        </Pressable>
      </View>
    </Screen>
  );
}
