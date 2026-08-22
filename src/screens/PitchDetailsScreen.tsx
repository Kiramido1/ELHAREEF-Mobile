import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect } from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { ScreenEntrance } from '../components/anim';
import { PitchArt } from '../components/PitchArt';
import { Txt } from '../components/Txt';
import { Button, Card, Row } from '../components/ui';
import { pitchPhotos } from '../constants/pitchPhotos';
import { areaAr, typeAr, useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { getPitch } from '../services/pitches';
import { BUSY_HOURS, SLOT_HOURS, useBooking } from '../state/BookingContext';
import { brand, layout, radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Pitch'>;

export function PitchDetailsScreen({ navigation, route }: Props) {
  const { colors, dark } = useTheme();
  const { t, pick, lang, isRTL } = useI18n();
  const insets = useSafeAreaInsets();
  const booking = useBooking();
  const pitch = getPitch(route.params.pitchId);

  useEffect(() => {
    booking.selectPitch(route.params.pitchId);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [route.params.pitchId]);

  const areaLabel = pick(pitch.area, areaAr[pitch.area] ?? pitch.area);
  const typeLabel = pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
  const distLabel = lang === 'ar' ? pitch.dist.replace(' km', ' كم') : pitch.dist;
  const meta =
    lang === 'ar'
      ? `${areaLabel}، الفيوم · ${distLabel} · ${pitch.reviews} تقييم`
      : `${areaLabel}, Fayoum · ${distLabel} away · ${pitch.reviews} reviews`;

  const facilities =
    lang === 'ar'
      ? ['باركينج', 'غرف تغيير', 'دُش', 'كشافات', 'كافيتريا', 'Wi-Fi', 'تأجير كور']
      : ['Parking', 'Changing rooms', 'Showers', 'Floodlights', 'Cafeteria', 'Wi-Fi', 'Ball rental'];

  const fmtSlot = (h: number) => `${((h + 11) % 12) + 1} ${h % 24 >= 12 ? t('pm') : t('am')}`;

  return (
    <View style={{ flex: 1, backgroundColor: colors.bg }}>
      <StatusBar style="light" />
      <ScreenEntrance>
      <ScrollView contentContainerStyle={{ paddingBottom: 8 }} showsVerticalScrollIndicator={false}>
        {/* Hero */}
        <PitchArt gradIndex={pitch.gradIndex} photo={pitchPhotos[pitch.id]} style={{ height: 270 }}>
          <Pressable
            onPress={() => navigation.goBack()}
            accessibilityRole="button"
            accessibilityLabel="Back"
            style={({ pressed }) => ({
              position: 'absolute',
              top: insets.top + 6,
              left: 18,
              width: 38,
              height: 38,
              borderRadius: 19,
              backgroundColor: colors.card,
              alignItems: 'center',
              justifyContent: 'center',
              shadowColor: '#030814',
              shadowOpacity: 0.25,
              shadowRadius: 6,
              shadowOffset: { width: 0, height: 1 },
              elevation: 4,
              transform: [{ scale: pressed ? 0.94 : 1 }],
            })}
          >
            <Txt size={18} style={{ marginTop: -2, textAlign: 'center' }}>‹</Txt>
          </Pressable>
          <View
            style={{
              position: 'absolute',
              bottom: 14,
              right: 16,
              backgroundColor: 'rgba(3,8,20,.75)',
              paddingVertical: 5,
              paddingHorizontal: 10,
              borderRadius: radius.pill,
            }}
          >
            <Txt w={600} size={11} color={brand.cloud}>
              {t('photos')}
            </Txt>
          </View>
        </PitchArt>

        <View style={{ paddingTop: 18, paddingHorizontal: layout.screenX }}>
          <Row style={{ alignItems: 'flex-start', justifyContent: 'space-between', gap: 10 }}>
            <Txt w={800} size={22} letterSpacing={-0.22} style={{ flexShrink: 1 }}>
              {pitch.name}
            </Txt>
            <View style={{ backgroundColor: colors.tint, paddingVertical: 6, paddingHorizontal: 11, borderRadius: radius.pill }}>
              <Txt w={700} size={13}>
                ★ {pitch.rating}
              </Txt>
            </View>
          </Row>
          <Txt size={13.5} color={colors.ink6} style={{ marginTop: 6 }}>
            {meta}
          </Txt>
          <Row style={{ marginTop: 14, gap: 8 }}>
            <View style={{ backgroundColor: colors.limeChip, paddingVertical: 6, paddingHorizontal: 11, borderRadius: radius.sm }}>
              <Txt w={700} size={12} color={colors.limeChipFg}>
                {typeLabel}
              </Txt>
            </View>
            <View style={{ backgroundColor: colors.tint, paddingVertical: 6, paddingHorizontal: 11, borderRadius: radius.sm }}>
              <Txt w={600} size={12} color={colors.ink6}>
                {t('turf')}
              </Txt>
            </View>
            <View style={{ backgroundColor: colors.tint, paddingVertical: 6, paddingHorizontal: 11, borderRadius: radius.sm }}>
              <Txt w={600} size={12} color={colors.ink6}>
                {t('floodlit')}
              </Txt>
            </View>
          </Row>

          <Txt w={700} size={15.5} style={{ marginTop: 22 }}>
            {t('facilitiesT')}
          </Txt>
          <Row style={{ flexWrap: 'wrap', gap: 8, marginTop: 10 }}>
            {facilities.map((f) => (
              <View
                key={f}
                style={{
                  borderWidth: 1.5,
                  borderColor: colors.ink1,
                  paddingVertical: 8,
                  paddingHorizontal: 13,
                  borderRadius: radius.pill,
                  backgroundColor: colors.card,
                }}
              >
                <Txt w={500} size={13}>
                  {f}
                </Txt>
              </View>
            ))}
          </Row>

          <Row style={{ marginTop: 22, alignItems: 'baseline', justifyContent: 'space-between' }}>
            <Txt w={700} size={15.5}>
              {t('tonightSlots')}
            </Txt>
            <Txt size={12} color={colors.ink5}>
              {t('fridayAug')}
            </Txt>
          </Row>
          <Row style={{ flexWrap: 'wrap', gap: 8, marginTop: 10 }}>
            {SLOT_HOURS.map((h) => {
              const busy = BUSY_HOURS.includes(h);
              return (
                <View
                  key={h}
                  style={{
                    paddingVertical: 9,
                    paddingHorizontal: 13,
                    borderRadius: radius.md,
                    borderWidth: 1.5,
                    borderColor: busy ? colors.ink08 : 'rgba(36,165,81,.4)',
                    backgroundColor: busy ? colors.tint : colors.card,
                  }}
                >
                  <Txt
                    w={600}
                    size={13}
                    color={busy ? colors.ink3 : brand.green}
                    style={{ textDecorationLine: busy ? 'line-through' : 'none' }}
                  >
                    {fmtSlot(h)}
                  </Txt>
                </View>
              );
            })}
          </Row>

          <Txt w={700} size={15.5} style={{ marginTop: 22 }}>
            {t('reviews')}
          </Txt>
          <View style={{ gap: 10, marginTop: 10, marginBottom: 24 }}>
            {[
              { who: 'Karim S.', stars: '★★★★★', text: t('rev1') },
              { who: 'Omar T.', stars: '★★★★☆', text: t('rev2') },
            ].map((r) => (
              <Card key={r.who} radiusValue={radius.card14} style={{ paddingVertical: 13, paddingHorizontal: 15 }}>
                <Row style={{ justifyContent: 'space-between' }}>
                  <Txt w={700} size={13}>
                    {r.who}
                  </Txt>
                  <Txt w={700} size={13} color={brand.green}>
                    {r.stars}
                  </Txt>
                </Row>
                <Txt size={13} lineHeight={19.5} color={colors.ink65} style={{ marginTop: 5 }}>
                  {r.text}
                </Txt>
              </Card>
            ))}
          </View>
        </View>
      </ScrollView>

      {/* Sticky booking bar */}
      <Row
        style={{
          alignItems: 'center',
          gap: 14,
          backgroundColor: colors.bar,
          borderTopWidth: 1,
          borderTopColor: colors.ink08,
          paddingTop: 14,
          paddingHorizontal: layout.screenX,
          paddingBottom: Math.max(insets.bottom, 14) + 12,
        }}
      >
        <View>
          <Txt w={800} size={19}>
            {pitch.price}{' '}
            <Txt w={500} size={12} color={colors.ink5}>
              {t('egphr')}
            </Txt>
          </Txt>
          <Txt w={600} size={11.5} color={brand.green}>
            {t('freeCancel')}
          </Txt>
        </View>
        <Button
          label={t('bookThis')}
          onPress={() => navigation.navigate('Booking')}
          style={{ flex: 1 }}
        />
      </Row>
      </ScreenEntrance>
    </View>
  );
}
