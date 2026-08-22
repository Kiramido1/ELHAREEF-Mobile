import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { CommonActions, CompositeScreenProps } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { Pressable, ScrollView, View } from 'react-native';
import { Txt } from '../components/Txt';
import { Avatar, BackButton, Card, Row, Screen } from '../components/ui';
import { useI18n } from '../i18n';
import { MainTabParamList, RootStackParamList } from '../navigation/types';
import { brand, layout, radius, useTheme } from '../theme';

type Props = CompositeScreenProps<
  BottomTabScreenProps<MainTabParamList, 'Profile'>,
  NativeStackScreenProps<RootStackParamList>
>;

function StatCard({ value, label, valueColor }: { value: string; label: string; valueColor?: string }) {
  const { colors } = useTheme();
  return (
    <Card radiusValue={radius.card15} style={{ flex: 1, paddingVertical: 13, alignItems: 'center' }}>
      <Txt w={800} size={19} color={valueColor} style={{ textAlign: 'center' }}>
        {value}
      </Txt>
      <Txt w={600} size={11} color={colors.ink55} style={{ marginTop: 2, textAlign: 'center' }}>
        {label}
      </Txt>
    </Card>
  );
}

export function ProfileScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, isRTL } = useI18n();

  const menu: { label: string; sub: string; go: () => void }[] = [
    { label: t('paymentMethods'), sub: t('cashSub'), go: () => navigation.navigate('Settings') },
    { label: t('notifTitle'), sub: t('allOn'), go: () => navigation.navigate('Notifications') },
    { label: t('privacy'), sub: t('pubProfile'), go: () => navigation.navigate('Settings') },
    { label: t('myReviews'), sub: t('myReviewsSub'), go: () => navigation.navigate('PlayerProfile', { matchId: 0 }) },
    { label: t('help'), sub: '', go: () => navigation.navigate('Settings') },
    { label: t('settingsTitle'), sub: '', go: () => navigation.navigate('Settings') },
  ];

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: layout.screenX, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ marginBottom: 16 }}>
          <BackButton onPress={() => navigation.navigate('Home')} />
        </Row>
        <Row style={{ alignItems: 'center', gap: 15 }}>
          <Avatar initial="Y" palette="navy" size={70} fontSize={24} borderColor={brand.green} />
          <View style={{ flex: 1 }}>
            <Txt w={800} size={20}>
              Youssef Adel
            </Txt>
            <Txt size={13} color={colors.ink55} style={{ marginTop: 2 }}>
              +20 10 1234 5678
            </Txt>
            <Row style={{ marginTop: 7, gap: 6 }}>
              <View style={{ backgroundColor: colors.tint, paddingVertical: 5, paddingHorizontal: 10, borderRadius: radius.pill }}>
                <Txt w={700} size={11.5}>
                  {t('midfielder')}
                </Txt>
              </View>
              <View style={{ backgroundColor: colors.limeChip, paddingVertical: 5, paddingHorizontal: 10, borderRadius: radius.pill }}>
                <Txt w={700} size={11.5} color={colors.limeChipFg}>
                  {t('intermediate')}
                </Txt>
              </View>
            </Row>
          </View>
          <Pressable onPress={() => navigation.navigate('Settings')} hitSlop={8} accessibilityRole="button">
            <Txt w={700} size={13} color={brand.green}>
              {t('edit')}
            </Txt>
          </Pressable>
        </Row>

        <Row style={{ marginTop: 18, gap: 10 }}>
          <StatCard value="18" label={t('matchesW')} />
          <StatCard value="12" label={t('bookingsW')} />
          <StatCard value="★ 4.7" label={t('rating')} valueColor={brand.green} />
        </Row>

        <Card radiusValue={radius.card17} style={{ marginTop: 18, overflow: 'hidden' }}>
          {menu.map((item, i) => (
            <Pressable
              key={item.label}
              onPress={item.go}
              accessibilityRole="button"
              style={({ pressed }) => ({
                flexDirection: isRTL ? 'row-reverse' : 'row',
                alignItems: 'center',
                justifyContent: 'space-between',
                borderBottomWidth: i < menu.length - 1 ? 1 : 0,
                borderBottomColor: colors.ink06,
                backgroundColor: pressed ? colors.tint : colors.card,
                paddingVertical: 15,
                paddingHorizontal: 17,
              })}
            >
              <Txt w={600} size={14}>
                {item.label}
              </Txt>
              <Row style={{ alignItems: 'center', gap: 8 }}>
                {item.sub ? (
                  <Txt size={12} color={colors.ink45}>
                    {item.sub}
                  </Txt>
                ) : null}
                <Txt size={16} color={colors.ink3}>
                  ›
                </Txt>
              </Row>
            </Pressable>
          ))}
        </Card>

        <Pressable
          onPress={() =>
            (navigation.getParent() ?? navigation).dispatch(
              CommonActions.reset({ index: 0, routes: [{ name: 'Login' }] }),
            )
          }
          accessibilityRole="button"
          style={{ marginTop: 16, paddingVertical: 12, alignItems: 'center' }}
        >
          <Txt w={600} size={14} color={brand.danger}>
            {t('logout')}
          </Txt>
        </Pressable>
      </ScrollView>
    </Screen>
  );
}
