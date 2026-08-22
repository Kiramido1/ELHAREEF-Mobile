import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { Image, KeyboardAvoidingView, Platform, Pressable, ScrollView, View } from 'react-native';
import { Input, PasswordInput } from '../components/Input';
import { Txt } from '../components/Txt';
import { Button, Row, Screen } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { brand, radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Login'>;

export function LoginScreen({ navigation }: Props) {
  const { colors, dark } = useTheme();
  const { t } = useI18n();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [showErrors, setShowErrors] = useState(false);

  const phoneInvalid = showErrors && phone.replace(/\D/g, '').length < 9;
  const pwInvalid = showErrors && password.length < 6;

  const goHome = () => navigation.replace('Tabs');

  const submit = () => {
    if (phone.replace(/\D/g, '').length < 9 || password.length < 6) {
      setShowErrors(true);
      return;
    }
    goHome();
  };

  const forgot = () => navigation.navigate('ForgotPassword');

  return (
    <Screen>
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={{ flexGrow: 1, paddingHorizontal: 24, paddingTop: 18, paddingBottom: 40 }}
          keyboardShouldPersistTaps="handled"
        >
          <Image
            source={
              dark
                ? require('../../assets/brand/symbol-reverse.png')
                : require('../../assets/brand/symbol.png')
            }
            style={{ width: 76, height: 50, resizeMode: 'contain', marginBottom: 22 }}
            accessibilityLabel="ELHAREEF"
          />
          <Txt w={800} size={28} letterSpacing={-0.28}>
            {t('welcome')}
          </Txt>
          <Txt size={14.5} lineHeight={22} color={colors.ink6} style={{ marginTop: 8 }}>
            {t('loginSub')}
          </Txt>

          <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 28 }}>
            {t('phone')}
          </Txt>
          <Row style={{ gap: 10, marginTop: 8 }}>
            <View
              style={{
                justifyContent: 'center',
                paddingHorizontal: 14,
                borderWidth: 1.5,
                borderColor: colors.ink14,
                borderRadius: radius.input,
                backgroundColor: colors.card,
              }}
            >
              <Txt w={600} size={15}>
                +20
              </Txt>
            </View>
            <Input
              placeholder="10 1234 5678"
              keyboardType="phone-pad"
              value={phone}
              onChangeText={setPhone}
              style={{ flex: 1, borderColor: phoneInvalid ? brand.danger : undefined }}
              accessibilityLabel={t('phone')}
            />
          </Row>
          {phoneInvalid ? (
            <Txt size={12} color={brand.danger} style={{ marginTop: 5 }}>
              {t('phoneError')}
            </Txt>
          ) : null}

          <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 16 }}>
            {t('password')}
          </Txt>
          <View style={{ marginTop: 8 }}>
            <PasswordInput
              placeholder={t('passwordPh')}
              value={password}
              onChangeText={setPassword}
              error={pwInvalid}
              onSubmitEditing={submit}
              returnKeyType="go"
              accessibilityLabel={t('password')}
            />
          </View>
          {pwInvalid ? (
            <Txt size={12} color={brand.danger} style={{ marginTop: 5 }}>
              {t('pwError')}
            </Txt>
          ) : null}
          <Pressable onPress={forgot} hitSlop={6} accessibilityRole="button" style={{ alignSelf: 'flex-end', marginTop: 8 }}>
            <Txt w={600} size={12.5} color={brand.green}>
              {t('forgotPw')}
            </Txt>
          </Pressable>

          <Button label={t('continue')} onPress={submit} style={{ marginTop: 16 }} weight={600} />
          <Row style={{ alignItems: 'center', gap: 12, marginVertical: 26 }}>
            <View style={{ flex: 1, height: 1, backgroundColor: colors.ink1 }} />
            <Txt size={12.5} color={colors.ink35}>
              {t('or')}
            </Txt>
            <View style={{ flex: 1, height: 1, backgroundColor: colors.ink1 }} />
          </Row>
          <Button
            label={t('google')}
            onPress={goHome}
            variant="outline"
            size={14.5}
            weight={600}
            paddingV={14}
            style={{ marginBottom: 10 }}
          />
          <Button label={t('apple')} onPress={goHome} variant="outline" size={14.5} weight={600} paddingV={14} />
          <View style={{ marginTop: 'auto', paddingTop: 28, alignItems: 'center' }}>
            <Txt size={14} color={colors.ink6} style={{ textAlign: 'center' }}>
              {t('newTo')}{' '}
              <Txt
                w={600}
                size={14}
                color={brand.green}
                onPress={() => navigation.navigate('Signup')}
                accessibilityRole="link"
              >
                {t('createAcc')}
              </Txt>
            </Txt>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </Screen>
  );
}
