import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { ScrollView, View } from 'react-native';
import { Txt } from '../components/Txt';
import { BackButton, Row, Screen } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { NOTIFICATIONS_EARLIER, NOTIFICATIONS_TODAY } from '../services/players';
import { brand, layout, radius, useTheme } from '../theme';
import { NotificationItem } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Notifications'>;

function NotificationRow({ item }: { item: NotificationItem }) {
  const { colors } = useTheme();
  const { pick, isRTL } = useI18n();
  const dotColor =
    item.dot === 'green'
      ? brand.green
      : item.dot === 'lime'
        ? brand.lime
        : item.dot === 'danger'
          ? brand.danger
          : colors.ink25;
  return (
    <View
      style={{
        flexDirection: isRTL ? 'row-reverse' : 'row',
        gap: 12,
        alignItems: 'flex-start',
        borderWidth: 1,
        borderColor: colors.ink08,
        borderRadius: radius.card15,
        backgroundColor: item.unread ? colors.tint : colors.card,
        paddingVertical: 13,
        paddingHorizontal: 15,
      }}
    >
      <View style={{ width: 9, height: 9, borderRadius: 4.5, backgroundColor: dotColor, marginTop: 5 }} />
      <View style={{ flex: 1 }}>
        <Txt size={13.5} lineHeight={20}>
          {pick(item.text, item.textAr)}
        </Txt>
        <Txt w={600} size={11.5} color={colors.ink45} style={{ marginTop: 3 }}>
          {pick(item.time, item.timeAr)}
        </Txt>
      </View>
    </View>
  );
}

export function NotificationsScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t } = useI18n();
  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: layout.screenX, paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.goBack()} />
          <Txt w={800} size={18}>
            {t('notifTitle')}
          </Txt>
        </Row>

        <Txt w={700} size={11.5} color={colors.ink4} letterSpacing={0.8} style={{ marginTop: 18, textTransform: 'uppercase' }}>
          {t('today')}
        </Txt>
        <View style={{ gap: 9, marginTop: 9 }}>
          {NOTIFICATIONS_TODAY.map((n) => (
            <NotificationRow key={n.id} item={n} />
          ))}
        </View>

        <Txt w={700} size={11.5} color={colors.ink4} letterSpacing={0.8} style={{ marginTop: 18, textTransform: 'uppercase' }}>
          {t('earlier')}
        </Txt>
        <View style={{ gap: 9, marginTop: 9 }}>
          {NOTIFICATIONS_EARLIER.map((n) => (
            <NotificationRow key={n.id} item={n} />
          ))}
        </View>
      </ScrollView>
    </Screen>
  );
}
