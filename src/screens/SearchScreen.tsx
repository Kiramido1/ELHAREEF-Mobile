import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useMemo, useState } from 'react';
import { Animated, FlatList, Modal, Pressable, ScrollView, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { RevealOnScroll, useScrollReveal } from '../components/anim';
import { Input } from '../components/Input';
import { PitchArt } from '../components/PitchArt';
import { Txt } from '../components/Txt';
import { BackButton, Button, Card, Chip, Row, Screen } from '../components/ui';
import { FilterIcon, SearchIcon } from '../components/icons';
import { pitchPhotos } from '../constants/pitchPhotos';
import { areaAr, typeAr, useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { allPitches } from '../services/pitches';
import { brand, layout, radius, useTheme } from '../theme';
import { Pitch, PitchType } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Search'>;

const TYPE_NAMES: ('All' | PitchType)[] = ['All', '5-a-side', '7-a-side', '8-a-side', '11-a-side'];

function ResultRow({ pitch, onPress }: { pitch: Pitch; onPress: () => void }) {
  const { colors } = useTheme();
  const { t, pick, lang, isRTL } = useI18n();
  const typeLabel = pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
  const areaLabel = pick(pitch.area, areaAr[pitch.area] ?? pitch.area);
  const distLabel = lang === 'ar' ? pitch.dist.replace(' km', ' كم') : pitch.dist;
  return (
    <Pressable onPress={onPress} accessibilityRole="button" accessibilityLabel={pitch.name}>
      {({ pressed }) => (
        <Card
          radiusValue={radius.card17}
          style={{
            flexDirection: isRTL ? 'row-reverse' : 'row',
            gap: 13,
            padding: 11,
            opacity: pressed ? 0.85 : 1,
          }}
        >
          <PitchArt
            gradIndex={pitch.gradIndex}
            photo={pitchPhotos[pitch.id]}
            style={{ width: 96, height: 96, borderRadius: radius.input12 }}
          />
          <View style={{ flex: 1, minWidth: 0, paddingVertical: 3 }}>
            <Row style={{ alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
              <Txt w={700} size={15} numberOfLines={1} style={{ flexShrink: 1 }}>
                {pitch.name}
              </Txt>
              <Txt w={700} size={12}>
                ★ {pitch.rating}
              </Txt>
            </Row>
            <Txt size={12.5} color={colors.ink55} style={{ marginTop: 3 }}>
              {areaLabel} · {distLabel}
            </Txt>
            <Row style={{ marginTop: 6, gap: 6 }}>
              <View style={{ backgroundColor: colors.tint, paddingVertical: 4, paddingHorizontal: 8, borderRadius: radius.xs }}>
                <Txt w={600} size={11} color={colors.ink55}>
                  {typeLabel}
                </Txt>
              </View>
              {pitch.availableNow ? (
                <View style={{ backgroundColor: colors.limeChip, paddingVertical: 4, paddingHorizontal: 8, borderRadius: radius.xs }}>
                  <Txt w={700} size={11} color={colors.limeChipFg}>
                    {t('availableNow')}
                  </Txt>
                </View>
              ) : null}
            </Row>
            <Txt w={700} size={14} color={brand.green} style={{ marginTop: 7 }}>
              {pitch.price}{' '}
              <Txt w={500} size={11.5} color={colors.ink45}>
                {t('egphr')}
              </Txt>
            </Txt>
          </View>
        </Card>
      )}
    </Pressable>
  );
}

function NoResults({
  onFindAnotherTime,
  onClearFilters,
}: {
  onFindAnotherTime: () => void;
  onClearFilters: () => void;
}) {
  const { colors } = useTheme();
  const { t } = useI18n();
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 24, paddingTop: 60 }}>
      <View
        style={{
          width: 96,
          height: 96,
          borderRadius: 48,
          backgroundColor: colors.tint,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <SearchIcon size={38} color={brand.green} />
        <View
          style={{
            position: 'absolute',
            top: -2,
            right: -2,
            width: 26,
            height: 26,
            borderRadius: 13,
            backgroundColor: colors.navyBtn,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Txt w={800} size={13} color="#fff">
            0
          </Txt>
        </View>
      </View>
      <Txt w={800} size={18} style={{ marginTop: 18, textAlign: 'center' }}>
        {t('noPitches')}
      </Txt>
      <Txt
        size={13.5}
        lineHeight={21}
        color={colors.ink55}
        style={{ marginTop: 8, maxWidth: 270, textAlign: 'center' }}
      >
        {t('noPitchesSub')}
      </Txt>
      <Button
        label={t('anotherTime')}
        onPress={onFindAnotherTime}
        size={14.5}
        paddingV={14}
        style={{ marginTop: 20, paddingHorizontal: 26, borderRadius: radius.input }}
      />
      <Pressable onPress={onClearFilters} style={{ marginTop: 10, padding: 8 }} accessibilityRole="button">
        <Txt w={600} size={13.5} color={brand.green}>
          {t('clearFilters')}
        </Txt>
      </Pressable>
    </View>
  );
}

export function SearchScreen({ navigation, route }: Props) {
  const { colors } = useTheme();
  const { t, pick, isRTL } = useI18n();
  const insets = useSafeAreaInsets();
  const [q, setQ] = useState('');
  const [ftype, setFtype] = useState(0);
  const [fprice, setFprice] = useState(0);
  const [fdist, setFdist] = useState(0);
  const [sheet, setSheet] = useState(route.params?.openFilters ?? false);
  const { scrollY, onScroll } = useScrollReveal();

  const results = useMemo(() => {
    const query = q.toLowerCase();
    let list = allPitches.filter(
      (p) => !query || `${p.name} ${p.area}`.toLowerCase().includes(query),
    );
    if (ftype > 0) list = list.filter((p) => p.type === TYPE_NAMES[ftype]);
    return list;
  }, [q, ftype]);

  const clearFilters = () => {
    setQ('');
    setFtype(0);
    setFprice(0);
    setFdist(0);
  };

  const typeChips = TYPE_NAMES.map((name) => pick(name, typeAr[name] ?? name));
  const priceChips = [pick('Under 150', 'أقل من 150'), '150–220', '+220'];
  const distChips = [pick('Under 3 km', 'أقل من 3 كم'), pick('Under 5 km', 'أقل من 5 كم'), pick('Anywhere', 'أي مكان')];

  return (
    <Screen>
      {/* Search header */}
      <Row style={{ alignItems: 'center', gap: 10, paddingHorizontal: layout.screenX }}>
        <BackButton onPress={() => navigation.goBack()} />
        <Row
          style={{
            flex: 1,
            alignItems: 'center',
            gap: 9,
            paddingHorizontal: 14,
            borderWidth: 1.5,
            borderColor: brand.green,
            borderRadius: radius.input,
            backgroundColor: colors.card,
          }}
        >
          <SearchIcon size={17} color={colors.ink45} />
          <Input
            value={q}
            onChangeText={setQ}
            placeholder={pick('Pitch name, area, facility...', 'اسم الملعب، المنطقة، المرافق...')}
            autoFocus
            style={{
              flex: 1,
              borderWidth: 0,
              paddingHorizontal: 0,
              paddingVertical: 11,
              fontSize: 14.5,
              backgroundColor: 'transparent',
            }}
            accessibilityLabel={t('searchT')}
          />
        </Row>
        <Pressable
          onPress={() => setSheet(true)}
          accessibilityRole="button"
          accessibilityLabel={t('filters')}
          style={({ pressed }) => ({
            width: 42,
            height: 42,
            borderRadius: radius.input,
            backgroundColor: colors.navyBtn,
            alignItems: 'center',
            justifyContent: 'center',
            transform: [{ scale: pressed ? 0.94 : 1 }],
          })}
        >
          <FilterIcon size={17} color={brand.lime} />
        </Pressable>
      </Row>

      {/* Type chips */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={{ flexGrow: 0 }}
        contentContainerStyle={{ gap: 8, paddingHorizontal: layout.screenX, paddingTop: 13, paddingBottom: 4 }}
      >
        {typeChips.map((label, i) => (
          <Chip key={label} label={label} selected={ftype === i} onPress={() => setFtype(i)} />
        ))}
      </ScrollView>

      {results.length === 0 ? (
        <NoResults
          onFindAnotherTime={() => navigation.navigate('Booking')}
          onClearFilters={() => {
            clearFilters();
            setSheet(true);
          }}
        />
      ) : (
        <>
          <Txt size={12.5} color={colors.ink5} style={{ paddingHorizontal: layout.screenX, paddingTop: 10 }}>
            {results.length} {t('resultsMeta')}
          </Txt>
          <Animated.FlatList
            data={results}
            keyExtractor={(p) => String(p.id)}
            contentContainerStyle={{ gap: 13, paddingHorizontal: layout.screenX, paddingTop: 12, paddingBottom: 40 }}
            onScroll={onScroll}
            scrollEventThrottle={16}
            renderItem={({ item }) => (
              <RevealOnScroll scrollY={scrollY}>
                <ResultRow pitch={item} onPress={() => navigation.navigate('Pitch', { pitchId: item.id })} />
              </RevealOnScroll>
            )}
          />
        </>
      )}

      {/* Filters bottom sheet */}
      <Modal visible={sheet} transparent animationType="slide" onRequestClose={() => setSheet(false)}>
        <Pressable
          style={{ flex: 1, backgroundColor: 'rgba(3,8,20,.55)' }}
          onPress={() => setSheet(false)}
          accessibilityRole="button"
          accessibilityLabel={t('reset')}
        />
        <View
          style={{
            backgroundColor: colors.bg,
            borderTopLeftRadius: radius.sheet,
            borderTopRightRadius: radius.sheet,
            paddingTop: 14,
            paddingHorizontal: 22,
            paddingBottom: Math.max(insets.bottom, 16) + 14,
          }}
        >
          <View
            style={{
              width: 40,
              height: 4,
              borderRadius: 99,
              backgroundColor: colors.ink15,
              alignSelf: 'center',
              marginBottom: 14,
            }}
          />
          <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
            <Txt w={800} size={18}>
              {t('filters')}
            </Txt>
            <Pressable onPress={clearFilters} hitSlop={8} accessibilityRole="button">
              <Txt w={600} size={13} color={colors.ink5}>
                {t('reset')}
              </Txt>
            </Pressable>
          </Row>
          <Txt w={700} size={12.5} color={colors.ink6} style={{ marginTop: 16 }}>
            {t('pricePerHr')}
          </Txt>
          <Row style={{ gap: 8, marginTop: 8 }}>
            {priceChips.map((label, i) => (
              <Chip key={label} label={label} selected={fprice === i} onPress={() => setFprice(i)} paddingV={9} />
            ))}
          </Row>
          <Txt w={700} size={12.5} color={colors.ink6} style={{ marginTop: 16 }}>
            {t('pitchType')}
          </Txt>
          <Row style={{ gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
            {typeChips.slice(1).map((label, i) => (
              <Chip
                key={label}
                label={label}
                selected={ftype === i + 1}
                onPress={() => setFtype(i + 1)}
                paddingV={9}
              />
            ))}
          </Row>
          <Txt w={700} size={12.5} color={colors.ink6} style={{ marginTop: 16 }}>
            {t('distance')}
          </Txt>
          <Row style={{ gap: 8, marginTop: 8 }}>
            {distChips.map((label, i) => (
              <Chip key={label} label={label} selected={fdist === i} onPress={() => setFdist(i)} paddingV={9} />
            ))}
          </Row>
          <Button
            label={`${t('show')} ${results.length} ${t('pitchesWord')}`}
            onPress={() => setSheet(false)}
            size={15}
            weight={600}
            paddingV={15}
            style={{ marginTop: 22 }}
          />
        </View>
      </Modal>
    </Screen>
  );
}
