import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { Txt } from '../components/Txt';
import { BackButton, Card, Row, Screen, ToggleSwitch } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Settings'>;

function SectionLabel({ children }: { children: string }) {
  const { colors } = useTheme();
  return (
    <Txt w={700} size={11.5} color={colors.ink4} letterSpacing={0.8} style={{ marginTop: 18, textTransform: 'uppercase' }}>
      {children}
    </Txt>
  );
}

export function SettingsScreen({ navigation }: Props) {
  const { colors, dark, toggleDark } = useTheme();
  const { t, lang, setLang, isRTL } = useI18n();
  const [toggles, setToggles] = useState({ rem: true, upd: true, mkt: false });

  const notifRows: { key: keyof typeof toggles; label: string; sub: string }[] = [
    { key: 'rem', label: t('remLabel'), sub: t('remSub') },
    { key: 'upd', label: t('updLabel'), sub: t('updSub') },
    { key: 'mkt', label: t('mktLabel'), sub: t('mktSub') },
  ];

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.goBack()} />
          <Txt w={800} size={18}>
            {t('settingsTitle')}
          </Txt>
        </Row>

        <SectionLabel>{t('secAppear')}</SectionLabel>
        <Card radiusValue={radius.card17} style={{ marginTop: 9 }}>
          <Row style={{ alignItems: 'center', justifyContent: 'space-between', paddingVertical: 14, paddingHorizontal: 17 }}>
            <View>
              <Txt w={600} size={14}>
                {t('dark')}
              </Txt>
              <Txt size={12} color={colors.ink5} style={{ marginTop: 2 }}>
                {t('darkSub')}
              </Txt>
            </View>
            <ToggleSwitch value={dark} onToggle={toggleDark} />
          </Row>
        </Card>

        <SectionLabel>{t('notifTitle')}</SectionLabel>
        <Card radiusValue={radius.card17} style={{ marginTop: 9 }}>
          {notifRows.map((row, i) => (
            <Row
              key={row.key}
              style={{
                alignItems: 'center',
                justifyContent: 'space-between',
                borderBottomWidth: i < notifRows.length - 1 ? 1 : 0,
                borderBottomColor: colors.ink06,
                paddingVertical: 14,
                paddingHorizontal: 17,
              }}
            >
              <View>
                <Txt w={600} size={14}>
                  {row.label}
                </Txt>
                <Txt size={12} color={colors.ink5} style={{ marginTop: 2 }}>
                  {row.sub}
                </Txt>
              </View>
              <ToggleSwitch
                value={toggles[row.key]}
                onToggle={() => setToggles((tg) => ({ ...tg, [row.key]: !tg[row.key] }))}
              />
            </Row>
          ))}
        </Card>

        <SectionLabel>{t('secGeneral')}</SectionLabel>
        <Card radiusValue={radius.card17} style={{ marginTop: 9 }}>
          <Row
            style={{
              alignItems: 'center',
              justifyContent: 'space-between',
              borderBottomWidth: 1,
              borderBottomColor: colors.ink06,
              paddingVertical: 15,
              paddingHorizontal: 17,
            }}
          >
            <Txt w={600} size={14}>
              {t('language')}
            </Txt>
            <Row style={{ gap: 5, backgroundColor: colors.tint, borderRadius: radius.md, padding: 3 }}>
              <Pressable
                onPress={() => setLang('en')}
                accessibilityRole="button"
                accessibilityState={{ selected: lang === 'en' }}
                style={{
                  paddingVertical: 6,
                  paddingHorizontal: 12,
                  borderRadius: radius.sm,
                  backgroundColor: lang === 'en' ? colors.navyBtn : 'transparent',
                }}
              >
                <Txt w={700} size={12} color={lang === 'en' ? '#fff' : colors.ink6}>
                  English
                </Txt>
              </Pressable>
              <Pressable
                onPress={() => setLang('ar')}
                accessibilityRole="button"
                accessibilityState={{ selected: lang === 'ar' }}
                style={{
                  paddingVertical: 6,
                  paddingHorizontal: 12,
                  borderRadius: radius.sm,
                  backgroundColor: lang === 'ar' ? colors.navyBtn : 'transparent',
                }}
              >
                <Txt ar w={700} size={12} color={lang === 'ar' ? '#fff' : colors.ink6}>
                  العربية
                </Txt>
              </Pressable>
            </Row>
          </Row>
          <Row
            style={{
              alignItems: 'center',
              justifyContent: 'space-between',
              borderBottomWidth: 1,
              borderBottomColor: colors.ink06,
              paddingVertical: 15,
              paddingHorizontal: 17,
            }}
          >
            <Txt w={600} size={14}>
              {t('paymentMethods')}
            </Txt>
            <Txt size={12} color={colors.ink45}>
              {t('cashSub')} ›
            </Txt>
          </Row>
          <Row
            style={{
              alignItems: 'center',
              justifyContent: 'space-between',
              borderBottomWidth: 1,
              borderBottomColor: colors.ink06,
              paddingVertical: 15,
              paddingHorizontal: 17,
            }}
          >
            <Txt w={600} size={14}>
              {t('privacy')}
            </Txt>
            <Txt size={12} color={colors.ink45}>
              {t('pubProfile')} ›
            </Txt>
          </Row>
          <Row style={{ alignItems: 'center', justifyContent: 'space-between', paddingVertical: 15, paddingHorizontal: 17 }}>
            <Txt w={600} size={14}>
              {t('help')}
            </Txt>
            <Txt size={16} color={colors.ink3}>
              ›
            </Txt>
          </Row>
        </Card>

        <Txt size={11.5} color={colors.ink4} style={{ marginTop: 16, textAlign: 'center' }}>
          {t('version')}
        </Txt>
      </ScrollView>
    </Screen>
  );
}
