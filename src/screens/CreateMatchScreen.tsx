import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { KeyboardAvoidingView, Platform, Pressable, ScrollView, View } from 'react-native';
import { SelectFade } from '../components/anim';
import { Input } from '../components/Input';
import { Txt } from '../components/Txt';
import { BackButton, Button, Chip, Row, Screen, Segmented } from '../components/ui';
import { levelAr, useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { useBookingDerived } from '../state/BookingContext';
import { useMatches } from '../state/MatchesContext';
import { brand, radius, useTheme } from '../theme';
import { SkillLevel } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'CreateMatch'>;

const LEVELS: SkillLevel[] = ['Beginner', 'Intermediate', 'Advanced', 'Any level'];

export function CreateMatchScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick, lang } = useI18n();
  const derived = useBookingDerived();
  const { draft, setDraft, postMatch } = useMatches();

  const needStr =
    lang === 'ar'
      ? draft.need === 1
        ? 'لاعيب واحد'
        : `${draft.need} لاعيبة`
      : `${draft.need} player${draft.need === 1 ? '' : 's'}`;

  const post = () => {
    postMatch();
    navigation.navigate('Tabs', { screen: 'Discover' });
  };

  return (
    <Screen>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView
          contentContainerStyle={{ flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 }}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <Row style={{ alignItems: 'center', gap: 12 }}>
            <BackButton onPress={() => navigation.goBack()} />
            <Txt w={800} size={18}>
              {t('createMatch')}
            </Txt>
          </Row>

          <View
            style={{
              marginTop: 16,
              borderWidth: 1,
              borderColor: colors.ink08,
              borderRadius: radius.card14,
              backgroundColor: colors.tint,
              paddingVertical: 13,
              paddingHorizontal: 15,
            }}
          >
            <Txt size={13} lineHeight={19.5}>
              <Txt w={700} size={13}>
                {derived.pitch.name}
              </Txt>{' '}
              · {derived.dateStr} · {derived.rangeStr}
            </Txt>
          </View>

          <Txt w={700} size={13} color={colors.ink65} style={{ marginTop: 20 }}>
            {t('playersNeeded')}
          </Txt>
          <Row style={{ gap: 8, marginTop: 9 }}>
            {[1, 2, 3, 4, 5].map((n) => {
              const on = draft.need === n;
              return (
                <Pressable
                  key={n}
                  onPress={() => setDraft({ need: n })}
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
                        <Txt w={800} size={15} style={{ textAlign: 'center' }}>
                          {n}
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
                        <Txt w={800} size={15} color="#fff" style={{ textAlign: 'center' }}>
                          {n}
                        </Txt>
                      </View>
                    }
                  />
                </Pressable>
              );
            })}
          </Row>

          <Txt w={700} size={13} color={colors.ink65} style={{ marginTop: 20 }}>
            {t('skill')}
          </Txt>
          <Row style={{ gap: 8, marginTop: 9, flexWrap: 'wrap' }}>
            {LEVELS.map((level) => (
              <Chip
                key={level}
                label={pick(level, levelAr[level] ?? level)}
                selected={draft.level === level}
                onPress={() => setDraft({ level })}
                paddingV={10}
                paddingH={16}
                size={13.5}
              />
            ))}
          </Row>

          <Txt w={700} size={13} color={colors.ink65} style={{ marginTop: 20 }}>
            {t('desc')}{' '}
            <Txt w={500} size={13} color={colors.ink4}>
              {t('optional')}
            </Txt>
          </Txt>
          <Input
            placeholder={t('descPh')}
            value={draft.description}
            onChangeText={(description) => setDraft({ description })}
            multiline
            maxLength={280}
            style={{ marginTop: 9, height: 76, paddingVertical: 13, paddingHorizontal: 15, fontSize: 14, textAlignVertical: 'top' }}
            accessibilityLabel={t('desc')}
          />

          <Txt w={700} size={13} color={colors.ink65} style={{ marginTop: 20 }}>
            {t('whoJoin')}
          </Txt>
          <View style={{ marginTop: 9 }}>
            <Segmented
              options={[pick('Public', 'عام'), pick('Friends only', 'الأصحاب بس')]}
              selectedIndex={draft.privacy === 'public' ? 0 : 1}
              onSelect={(i) => setDraft({ privacy: i === 0 ? 'public' : 'friends' })}
              paddingV={11}
            />
          </View>

          <View style={{ marginTop: 'auto', paddingTop: 28 }}>
            <Button label={`${t('postMatch')} ${needStr}`} onPress={post} />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </Screen>
  );
}
