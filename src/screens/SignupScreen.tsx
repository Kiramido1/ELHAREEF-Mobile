import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, View } from 'react-native';
import { Input, PasswordInput } from '../components/Input';
import { Txt } from '../components/Txt';
import { BackButton, Button, Chip, Row, Screen, Segmented } from '../components/ui';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { radius, useTheme } from '../theme';

type Props = NativeStackScreenProps<RootStackParamList, 'Signup'>;

export function SignupScreen({ navigation }: Props) {
  const { colors } = useTheme();
  const { t, pick } = useI18n();
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [pos, setPos] = useState(2);
  const [skill, setSkill] = useState(1);
  const [showErrors, setShowErrors] = useState(false);

  const positions = [
    pick('Goalkeeper', 'حارس'),
    pick('Defender', 'مدافع'),
    pick('Midfielder', 'وسط'),
    pick('Winger', 'جناح'),
    pick('Striker', 'مهاجم'),
  ];

  const nameInvalid = showErrors && name.trim().length < 2;
  const phoneInvalid = showErrors && phone.replace(/\D/g, '').length < 9;
  const pwInvalid = showErrors && password.length < 6;

  const submit = () => {
    if (name.trim().length < 2 || phone.replace(/\D/g, '').length < 9 || password.length < 6) {
      setShowErrors(true);
      return;
    }
    navigation.replace('Tabs');
  };

  return (
    <Screen>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView
          contentContainerStyle={{ flexGrow: 1, paddingHorizontal: 24, paddingTop: 8, paddingBottom: 40 }}
          keyboardShouldPersistTaps="handled"
        >
          <Row style={{ marginBottom: 18 }}>
            <BackButton onPress={() => navigation.goBack()} />
          </Row>
          <Txt w={800} size={28} letterSpacing={-0.28}>
            {t('createAcc')}
          </Txt>
          <Txt size={14.5} color={colors.ink6} style={{ marginTop: 8 }}>
            {t('signupSub')}
          </Txt>
          <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 26 }}>
            {t('fullName')}
          </Txt>
          <Input
            placeholder="Youssef Adel"
            value={name}
            onChangeText={setName}
            style={{ marginTop: 8, borderColor: nameInvalid ? '#d64545' : undefined }}
            accessibilityLabel={t('fullName')}
          />
          {nameInvalid ? (
            <Txt size={12} color="#d64545" style={{ marginTop: 5 }}>
              {pick('Please enter your full name.', 'من فضلك اكتب اسمك بالكامل.')}
            </Txt>
          ) : null}
          <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 16 }}>
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
              style={{ flex: 1, borderColor: phoneInvalid ? '#d64545' : undefined }}
              accessibilityLabel={t('phone')}
            />
          </Row>
          {phoneInvalid ? (
            <Txt size={12} color="#d64545" style={{ marginTop: 5 }}>
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
              accessibilityLabel={t('password')}
            />
          </View>
          {pwInvalid ? (
            <Txt size={12} color="#d64545" style={{ marginTop: 5 }}>
              {t('pwError')}
            </Txt>
          ) : null}
          <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 20 }}>
            {t('prefPos')}
          </Txt>
          <Row style={{ flexWrap: 'wrap', gap: 8, marginTop: 9 }}>
            {positions.map((label, i) => (
              <Chip
                key={label}
                label={label}
                selected={pos === i}
                onPress={() => setPos(i)}
                paddingV={9}
                paddingH={15}
                size={13.5}
              />
            ))}
          </Row>
          <Txt w={600} size={12.5} color={colors.ink65} style={{ marginTop: 20 }}>
            {t('skill')}
          </Txt>
          <View style={{ marginTop: 9 }}>
            <Segmented
              options={[pick('Beginner', 'مبتدئ'), pick('Intermediate', 'متوسط'), pick('Advanced', 'متقدم')]}
              selectedIndex={skill}
              onSelect={setSkill}
            />
          </View>
          <View style={{ marginTop: 'auto', paddingTop: 28 }}>
            <Button label={t('createAcc')} onPress={submit} weight={600} />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </Screen>
  );
}
