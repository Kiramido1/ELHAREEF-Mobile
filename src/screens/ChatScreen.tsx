import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useRef, useState } from 'react';
import {
  Alert,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { MsgIn } from '../components/anim';
import { Input } from '../components/Input';
import { Txt } from '../components/Txt';
import { Avatar, BackButton, Row, Screen } from '../components/ui';
import { SendIcon } from '../components/icons';
import { useI18n } from '../i18n';
import { RootStackParamList } from '../navigation/types';
import { useChat } from '../state/ChatContext';
import { brand, layout, radius, useTheme } from '../theme';
import { ChatMessage } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Chat'>;

function MessageRow({ msg }: { msg: ChatMessage }) {
  const { colors } = useTheme();
  const { pick, isRTL } = useI18n();
  const text = msg.textAr ? pick(msg.text, msg.textAr) : msg.text;

  if (msg.kind === 'system') {
    return (
      <View
        style={{
          alignSelf: 'center',
          backgroundColor: colors.tint,
          paddingVertical: 6,
          paddingHorizontal: 13,
          borderRadius: radius.pill,
        }}
      >
        <Txt w={600} size={11.5} color={colors.ink5}>
          {text}
        </Txt>
      </View>
    );
  }

  if (msg.kind === 'mine') {
    return (
      <View
        style={{
          alignSelf: isRTL ? 'flex-start' : 'flex-end',
          maxWidth: '82%',
          backgroundColor: colors.navyBtn,
          borderTopLeftRadius: 16,
          borderTopRightRadius: 16,
          borderBottomLeftRadius: isRTL ? 5 : 16,
          borderBottomRightRadius: isRTL ? 16 : 5,
          paddingVertical: 10,
          paddingHorizontal: 13,
        }}
      >
        <Txt size={13.5} lineHeight={19.5} color={brand.cloud}>
          {text}
        </Txt>
      </View>
    );
  }

  const who = msg.whoAr ? pick(msg.who ?? '', msg.whoAr) : (msg.who ?? '');
  return (
    <Row style={{ gap: 8, alignItems: 'flex-end', maxWidth: '82%', alignSelf: isRTL ? 'flex-end' : 'flex-start' }}>
      <Avatar initial={msg.initial ?? '?'} palette={msg.avatar ?? 'tint'} size={28} fontSize={10.5} />
      <View style={{ flexShrink: 1 }}>
        <Txt w={700} size={10.5} color={colors.ink5} style={{ marginBottom: 3, marginHorizontal: 4 }}>
          {who}
        </Txt>
        <View
          style={{
            backgroundColor: colors.card,
            borderWidth: 1,
            borderColor: colors.ink08,
            borderTopLeftRadius: 16,
            borderTopRightRadius: 16,
            borderBottomLeftRadius: isRTL ? 16 : 5,
            borderBottomRightRadius: isRTL ? 5 : 16,
            paddingVertical: 10,
            paddingHorizontal: 13,
          }}
        >
          <Txt size={13.5} lineHeight={19.5}>
            {text}
          </Txt>
        </View>
      </View>
    </Row>
  );
}

export function ChatScreen({ navigation }: Props) {
  const { colors, dark } = useTheme();
  const { t, pick } = useI18n();
  const insets = useSafeAreaInsets();
  const { messages, send } = useChat();
  const [draft, setDraft] = useState('');
  const listRef = useRef<FlatList<ChatMessage>>(null);

  const doSend = (text: string) => {
    if (!text.trim()) return;
    setDraft('');
    send(text).catch(() =>
      Alert.alert(
        pick('Message not sent', 'الرسالة متبعتتش'),
        pick('Check your connection and try again.', 'اتأكد من النت وحاول تاني.'),
      ),
    );
  };

  const quicks = [
    { label: t('onWay') },
    { label: t('arrived') },
    {
      label: t('sharePin'),
      text: pick(
        'Pitch pin: Dream Sports Arena, Gate 2 — maps.app/eh84213',
        'لوكيشن الملعب: دريم سبورتس أرينا، بوابة 2 — maps.app/eh84213',
      ),
    },
  ];

  const avatarBorder = dark ? colors.bg : brand.cloud;

  return (
    <Screen>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        {/* Chat header */}
        <Row
          style={{
            alignItems: 'center',
            gap: 11,
            paddingHorizontal: 16,
            paddingBottom: 12,
            borderBottomWidth: 1,
            borderBottomColor: colors.ink08,
          }}
        >
          <BackButton onPress={() => navigation.goBack()} size={36} />
          <View style={{ flex: 1, minWidth: 0 }}>
            <Txt w={800} size={14.5} numberOfLines={1}>
              {t('chatTitle')}
            </Txt>
            <Txt w={600} size={11.5} color={brand.green}>
              {t('chatSub')}
            </Txt>
          </View>
          <View style={{ flexDirection: 'row' }}>
            <View style={{ borderWidth: 2, borderColor: avatarBorder, borderRadius: 17 }}>
              <Avatar initial="A" palette="navy" size={30} fontSize={11} />
            </View>
            <View style={{ borderWidth: 2, borderColor: avatarBorder, borderRadius: 17, marginLeft: -8 }}>
              <Avatar initial="O" palette="tint" size={30} fontSize={11} />
            </View>
            <View style={{ borderWidth: 2, borderColor: avatarBorder, borderRadius: 17, marginLeft: -8 }}>
              <Avatar initial="+5" palette="green" size={30} fontSize={10} />
            </View>
          </View>
        </Row>

        {/* Messages */}
        <FlatList
          ref={listRef}
          data={messages}
          keyExtractor={(m) => String(m.id)}
          renderItem={({ item }) => (
            <MsgIn>
              <MessageRow msg={item} />
            </MsgIn>
          )}
          contentContainerStyle={{ paddingTop: 16, paddingHorizontal: 16, paddingBottom: 8, gap: 10 }}
          onContentSizeChange={() => listRef.current?.scrollToEnd({ animated: true })}
          showsVerticalScrollIndicator={false}
        />

        {/* Quick replies */}
        <Row style={{ gap: 8, paddingHorizontal: 16, paddingTop: 6, paddingBottom: 4 }}>
          {quicks.map((qk) => (
            <Pressable
              key={qk.label}
              onPress={() => doSend(qk.text ?? qk.label)}
              accessibilityRole="button"
              style={({ pressed }) => ({
                borderWidth: 1.5,
                borderColor: colors.ink12,
                backgroundColor: colors.card,
                paddingVertical: 8,
                paddingHorizontal: 12,
                borderRadius: radius.pill,
                transform: [{ scale: pressed ? 0.95 : 1 }],
              })}
            >
              <Txt w={600} size={12}>
                {qk.label}
              </Txt>
            </Pressable>
          ))}
        </Row>

        {/* Composer */}
        <Row
          style={{
            gap: 9,
            alignItems: 'center',
            paddingHorizontal: 16,
            paddingTop: 8,
            paddingBottom: Math.max(insets.bottom, 14) + 12,
            backgroundColor: colors.bg,
          }}
        >
          <Input
            value={draft}
            onChangeText={setDraft}
            placeholder={t('msgPh')}
            onSubmitEditing={() => doSend(draft)}
            returnKeyType="send"
            style={{ flex: 1, borderRadius: radius.pill, paddingVertical: 13, fontSize: 14 }}
            accessibilityLabel={t('msgPh')}
          />
          <Pressable
            onPress={() => doSend(draft)}
            accessibilityRole="button"
            accessibilityLabel={pick('Send', 'إرسال')}
            style={({ pressed }) => ({
              width: 46,
              height: 46,
              borderRadius: 23,
              backgroundColor: brand.green,
              alignItems: 'center',
              justifyContent: 'center',
              transform: [{ scale: pressed ? 0.92 : 1 }],
            })}
          >
            <SendIcon size={19} color="#fff" />
          </Pressable>
        </Row>
      </KeyboardAvoidingView>
    </Screen>
  );
}
