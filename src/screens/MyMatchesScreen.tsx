import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { CompositeScreenProps } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { Alert, Pressable, ScrollView, View } from 'react-native';
import { Txt } from '../components/Txt';
import { BackButton, Card, ProgressBar, Row, Screen, Segmented, StatusPill } from '../components/ui';
import { useI18n } from '../i18n';
import { MainTabParamList, RootStackParamList } from '../navigation/types';
import { brand, layout, radius, useTheme } from '../theme';

type Props = CompositeScreenProps<
  BottomTabScreenProps<MainTabParamList, 'MyMatches'>,
  NativeStackScreenProps<RootStackParamList>
>;

export function MyMatchesScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const [tab, setTab] = useState(0);

  const actionButton = (
    label: string,
    onPress: () => void,
    kind: 'navy' | 'outline' | 'danger',
    flex = 1,
  ) => (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      style={({ pressed }) => ({
        flex,
        borderWidth: kind === 'navy' ? 0 : 1.5,
        borderColor: kind === 'danger' ? 'rgba(214,69,69,.3)' : colors.ink14,
        backgroundColor: kind === 'navy' ? colors.navyBtn : colors.card,
        paddingVertical: 11,
        borderRadius: radius.action,
        alignItems: 'center',
        transform: [{ scale: pressed ? 0.97 : 1 }],
      })}
    >
      <Txt
        w={kind === 'navy' ? 700 : 600}
        size={13}
        color={kind === 'navy' ? '#fff' : kind === 'danger' ? brand.danger : colors.ink}
      >
        {label}
      </Txt>
    </Pressable>
  );

  return (
    <Screen>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: layout.screenX, paddingBottom: 24 }}
        showsVerticalScrollIndicator={false}
      >
        <Row style={{ alignItems: 'center', gap: 12 }}>
          <BackButton onPress={() => navigation.navigate('Home')} />
          <Txt w={800} size={23} letterSpacing={-0.23}>
            {t('matchTitle')}
          </Txt>
        </Row>
        <View style={{ marginTop: 14 }}>
          <Segmented
            options={[t('hostingTab'), t('joinedTab'), t('completedTab')]}
            selectedIndex={tab}
            onSelect={setTab}
          />
        </View>

        {tab === 0 ? (
          <Card lime style={{ marginTop: 16, paddingVertical: 16, paddingHorizontal: 17 }}>
            <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
              <Txt w={800} size={15}>
                Dream Sports Arena
              </Txt>
              <StatusPill label={t('hosting')} bg={colors.limeChip} fg={colors.limeChipFg} size={10.5} weight={800} />
            </Row>
            <Txt size={12.5} color={colors.ink55} style={{ marginTop: 5 }}>
              {t('mm1')}
            </Txt>
            <Row style={{ marginTop: 13, alignItems: 'center', gap: 12 }}>
              <View style={{ flex: 1 }}>
                <ProgressBar pct={87.5} height={7} />
              </View>
              <Txt w={800} size={13}>
                7/8
              </Txt>
            </Row>
            <Txt w={700} size={12.5} color={brand.green} style={{ marginTop: 5 }}>
              {t('mm2')}
            </Txt>
            <Row style={{ marginTop: 13, gap: 9 }}>
              {actionButton(t('squadChat'), () => navigation.navigate('Chat'), 'outline')}
              {actionButton(t('openMatch'), () => navigation.navigate('MatchDetails', { matchId: 0 }), 'navy', 1.4)}
            </Row>
          </Card>
        ) : null}

        {tab === 1 ? (
          <Card style={{ marginTop: 16, paddingVertical: 16, paddingHorizontal: 17 }}>
            <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
              <Txt w={800} size={15}>
                Green Field Club
              </Txt>
              <StatusPill label={t('joinedChip')} bg={colors.tint} fg={brand.green} size={10.5} weight={800} />
            </Row>
            <Txt size={12.5} color={colors.ink55} style={{ marginTop: 5 }}>
              {t('mm3')}
            </Txt>
            <Row style={{ marginTop: 13, gap: 9 }}>
              {actionButton(t('squadChat'), () => navigation.navigate('Chat'), 'navy')}
              {actionButton(
                t('leave'),
                () =>
                  Alert.alert(t('leave'), pick('Leave this match?', 'تنسحب من الماتش ده؟'), [
                    { text: pick('Stay', 'خليك'), style: 'cancel' },
                    { text: t('leave'), style: 'destructive' },
                  ]),
                'danger',
              )}
            </Row>
          </Card>
        ) : null}

        {tab === 2 ? (
          <Card style={{ marginTop: 16, paddingVertical: 16, paddingHorizontal: 17 }}>
            <Row style={{ alignItems: 'center', justifyContent: 'space-between' }}>
              <Txt w={800} size={15}>
                Champions Park
              </Txt>
              <StatusPill label={t('played')} bg={colors.tint} fg={colors.ink55} size={10.5} />
            </Row>
            <Txt size={12.5} color={colors.ink55} style={{ marginTop: 5 }}>
              {t('mm4')}
            </Txt>
            <View style={{ marginTop: 13 }}>
              {actionButton(
                t('rate'),
                () =>
                  Alert.alert(
                    t('rate'),
                    pick('Player ratings are coming soon.', 'تقييم اللاعيبة جاي قريب.'),
                  ),
                'outline',
              )}
            </View>
          </Card>
        ) : null}
      </ScrollView>
    </Screen>
  );
}
