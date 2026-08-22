import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React from 'react';
import { Pressable, View } from 'react-native';
import { Txt } from '../components/Txt';
import { Button, Screen } from '../components/ui';
import { WifiOffIcon } from '../components/icons';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { setOffline } from '../services/network';
import { brand, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Offline'>;

export function OfflineScreen({ navigation }: Props) {
  const { colors, dark } = useTheme();
  const { t } = useI18n();

  const retry = () => {
    setOffline(false);
    navigation.goBack();
  };

  return (
    <Screen style={{ alignItems: 'center', justifyContent: 'center', padding: 24 }}>
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
        <WifiOffIcon size={40} color={dark ? colors.ink : brand.navy} slashColor={brand.danger} />
      </View>
      <Txt w={800} size={19} style={{ marginTop: 20, textAlign: 'center' }}>
        {t('offline')}
      </Txt>
      <Txt
        size={13.5}
        lineHeight={21}
        color={colors.ink55}
        style={{ marginTop: 8, maxWidth: 250, textAlign: 'center' }}
      >
        {t('offlineSub')}
      </Txt>
      <Button
        label={t('retry')}
        size={14.5}
        paddingV={14}
        onPress={retry}
        style={{ marginTop: 20, paddingHorizontal: 30, borderRadius: 13 }}
      />
      <Pressable
        onPress={() => navigation.navigate('Tabs', { screen: 'Bookings' })}
        style={{ marginTop: 10, padding: 8 }}
        accessibilityRole="button"
      >
        <Txt w={600} size={13.5} color={brand.green}>
          {t('savedBk')}
        </Txt>
      </Pressable>
    </Screen>
  );
}
