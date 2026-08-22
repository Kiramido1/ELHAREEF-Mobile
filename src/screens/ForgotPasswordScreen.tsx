import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Animated,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  TextInput,
  View,
} from 'react-native';
import { Input, PasswordInput } from '../components/Input';
import { Txt } from '../components/Txt';
import { BackButton, Button, Row, Screen } from '../components/ui';
import { CheckIcon } from '../components/icons';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { simulateRequest } from '../services/network';
import { brand, fonts, radius, shadows, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'ForgotPassword'>;

type Step = 'phone' | 'code' | 'password' | 'done';

const CODE_LENGTH = 4;

function CodeInput({
  code,
  setCode,
  error,
}: {
  code: string[];
  setCode: (code: string[]) => void;
  error: boolean;
}) {
  const { colors } = useTheme();
  const refs = useRef<(TextInput | null)[]>([]);
  const [focusedIndex, setFocusedIndex] = useState(0);

  const handleChange = (text: string, i: number) => {
    const digits = text.replace(/\D/g, '');
    const next = [...code];
    if (digits.length === 0) {
      next[i] = '';
      setCode(next);
      return;
    }
    // Support paste of the full code into any box.
    for (let k = 0; k < digits.length && i + k < CODE_LENGTH; k++) {
      next[i + k] = digits[k];
    }
    setCode(next);
    const target = Math.min(i + digits.length, CODE_LENGTH - 1);
    refs.current[target]?.focus();
  };

  const handleKeyPress = (key: string, i: number) => {
    if (key === 'Backspace' && !code[i] && i > 0) {
      refs.current[i - 1]?.focus();
    }
  };

  return (
    <View style={{ flexDirection: 'row', gap: 12, justifyContent: 'center' }}>
      {Array.from({ length: CODE_LENGTH }).map((_, i) => (
        <TextInput
          key={i}
          ref={(r) => {
            refs.current[i] = r;
          }}
          value={code[i]}
          onChangeText={(text) => handleChange(text, i)}
          onKeyPress={({ nativeEvent }) => handleKeyPress(nativeEvent.key, i)}
          onFocus={() => setFocusedIndex(i)}
          keyboardType="number-pad"
          maxLength={CODE_LENGTH}
          selectTextOnFocus
          accessibilityLabel={`Digit ${i + 1}`}
          style={{
            width: 62,
            height: 62,
            borderWidth: 1.5,
            borderColor: error ? brand.danger : focusedIndex === i ? brand.green : colors.ink14,
            borderRadius: radius.card14,
            backgroundColor: colors.card,
            textAlign: 'center',
            fontSize: 24,
            fontFamily: fonts.extraBold,
            color: colors.ink,
          }}
        />
      ))}
    </View>
  );
}

export function ForgotPasswordScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t } = useI18n();
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState<string[]>(Array(CODE_LENGTH).fill(''));
  const [pw, setPw] = useState('');
  const [pw2, setPw2] = useState('');
  const [showErrors, setShowErrors] = useState(false);
  const [busy, setBusy] = useState(false);
  const [resendIn, setResendIn] = useState(59);
  const pop = useRef(new Animated.Value(0)).current;

  // Resend countdown while on the code step.
  useEffect(() => {
    if (step !== 'code' || resendIn <= 0) return;
    const timer = setTimeout(() => setResendIn((v) => v - 1), 1000);
    return () => clearTimeout(timer);
  }, [step, resendIn]);

  useEffect(() => {
    if (step === 'done') {
      Animated.spring(pop, { toValue: 1, friction: 5, tension: 90, useNativeDriver: true }).start();
    }
  }, [step, pop]);

  const phoneInvalid = showErrors && phone.replace(/\D/g, '').length < 9;
  const codeInvalid = showErrors && code.join('').length < CODE_LENGTH;
  const pwInvalid = showErrors && pw.length < 6;
  const pw2Invalid = showErrors && pw.length >= 6 && pw2 !== pw;

  const advance = async (valid: boolean, next: Step) => {
    if (!valid) {
      setShowErrors(true);
      return;
    }
    setBusy(true);
    await simulateRequest(null, 700);
    setBusy(false);
    setShowErrors(false);
    if (next === 'code') setResendIn(59);
    setStep(next);
  };

  const resend = async () => {
    setBusy(true);
    await simulateRequest(null, 500);
    setBusy(false);
    setResendIn(59);
    setCode(Array(CODE_LENGTH).fill(''));
  };

  const primaryAction = () => {
    if (step === 'phone') return advance(phone.replace(/\D/g, '').length >= 9, 'code');
    if (step === 'code') return advance(code.join('').length === CODE_LENGTH, 'password');
    if (step === 'password') return advance(pw.length >= 6 && pw2 === pw, 'done');
    return navigation.goBack();
  };

  const primaryLabel =
    step === 'phone'
      ? t('fpSend')
      : step === 'code'
        ? t('fpVerify')
        : step === 'password'
          ? t('fpReset')
          : t('fpBackToLogin');

  if (step === 'done') {
    return (
      <Screen style={{ paddingHorizontal: 24, paddingBottom: 40 }}>
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <Animated.View
            style={[
              {
                width: 92,
                height: 92,
                borderRadius: 46,
                backgroundColor: brand.green,
                alignItems: 'center',
                justifyContent: 'center',
                opacity: pop,
                transform: [{ scale: pop.interpolate({ inputRange: [0, 1], outputRange: [0.4, 1] }) }],
              },
              shadows.confirmPop,
            ]}
          >
            <CheckIcon size={44} color="#fff" />
          </Animated.View>
          <Txt w={800} size={25} letterSpacing={-0.25} style={{ marginTop: 22, textAlign: 'center' }}>
            {t('fpDoneTitle')}
          </Txt>
          <Txt
            size={14}
            lineHeight={22}
            color={colors.ink6}
            style={{ marginTop: 9, maxWidth: 280, textAlign: 'center' }}
          >
            {t('fpDoneSub')}
          </Txt>
        </View>
        <Button label={t('fpBackToLogin')} onPress={() => navigation.goBack()} />
      </Screen>
    );
  }

  return (
    <Screen>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView
          contentContainerStyle={{ flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 }}
          keyboardShouldPersistTaps="handled"
        >
          <Row>
            <BackButton
              onPress={() =>
                step === 'phone'
                  ? navigation.goBack()
                  : setStep(step === 'code' ? 'phone' : 'code')
              }
            />
          </Row>

          {step === 'phone' ? (
            <>
              <Txt w={800} size={28} letterSpacing={-0.28} style={{ marginTop: 18 }}>
                {t('fpTitle')}
              </Txt>
              <Txt size={14.5} lineHeight={22} color={colors.ink6} style={{ marginTop: 8 }}>
                {t('fpSub')}
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
                  autoFocus
                  style={{ flex: 1, borderColor: phoneInvalid ? brand.danger : undefined }}
                  accessibilityLabel={t('phone')}
                />
              </Row>
              {phoneInvalid ? (
                <Txt size={12} color={brand.danger} style={{ marginTop: 5 }}>
                  {t('phoneError')}
                </Txt>
              ) : null}
            </>
          ) : null}

          {step === 'code' ? (
            <>
              <Txt w={800} size={28} letterSpacing={-0.28} style={{ marginTop: 18 }}>
                {t('fpCodeTitle')}
              </Txt>
              <Txt size={14.5} lineHeight={22} color={colors.ink6} style={{ marginTop: 8 }}>
                {t('fpCodeSub')}{' '}
                <Txt w={700} size={14.5}>
                  +20 {phone}
                </Txt>
              </Txt>
              <View style={{ marginTop: 28 }}>
                <CodeInput code={code} setCode={setCode} error={codeInvalid} />
              </View>
              {codeInvalid ? (
                <Txt size={12} color={brand.danger} style={{ marginTop: 8, textAlign: 'center' }}>
                  {t('fpCodeError')}
                </Txt>
              ) : null}
              <View style={{ marginTop: 18, alignItems: 'center' }}>
                {resendIn > 0 ? (
                  <Txt size={13} color={colors.ink5}>
                    {t('fpResendIn')} 0:{String(resendIn).padStart(2, '0')}
                  </Txt>
                ) : (
                  <Pressable onPress={resend} hitSlop={8} accessibilityRole="button">
                    <Txt w={600} size={13} color={brand.green}>
                      {t('fpResend')}
                    </Txt>
                  </Pressable>
                )}
              </View>
            </>
          ) : null}

          {step === 'password' ? (
            <>
              <Txt w={800} size={28} letterSpacing={-0.28} style={{ marginTop: 18 }}>
                {t('fpNewTitle')}
              </Txt>
              <Txt size={14.5} lineHeight={22} color={colors.ink6} style={{ marginTop: 8 }}>
                {t('fpNewSub')}
              </Txt>
              <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 28 }}>
                {t('fpNewPw')}
              </Txt>
              <View style={{ marginTop: 8 }}>
                <PasswordInput
                  placeholder={t('passwordPh')}
                  value={pw}
                  onChangeText={setPw}
                  error={pwInvalid}
                  accessibilityLabel={t('fpNewPw')}
                />
              </View>
              {pwInvalid ? (
                <Txt size={12} color={brand.danger} style={{ marginTop: 5 }}>
                  {t('pwError')}
                </Txt>
              ) : null}
              <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 16 }}>
                {t('fpConfirmPw')}
              </Txt>
              <View style={{ marginTop: 8 }}>
                <PasswordInput
                  placeholder={t('passwordPh')}
                  value={pw2}
                  onChangeText={setPw2}
                  error={pw2Invalid}
                  accessibilityLabel={t('fpConfirmPw')}
                />
              </View>
              {pw2Invalid ? (
                <Txt size={12} color={brand.danger} style={{ marginTop: 5 }}>
                  {t('fpMatchError')}
                </Txt>
              ) : null}
            </>
          ) : null}

          <View style={{ marginTop: 'auto', paddingTop: 28 }}>
            {busy ? (
              <View
                style={{
                  backgroundColor: brand.green,
                  paddingVertical: 16,
                  borderRadius: radius.card14,
                  alignItems: 'center',
                }}
              >
                <ActivityIndicator color="#fff" />
              </View>
            ) : (
              <Button label={primaryLabel} onPress={primaryAction} weight={600} />
            )}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </Screen>
  );
}
