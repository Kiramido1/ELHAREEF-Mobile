import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import * as chatService from '../services/chat';
import { ChatMessage } from '../types';

interface ChatValue {
  messages: ChatMessage[];
  /** Send a message; resolves when the mock server acknowledges it. */
  send: (text: string) => Promise<void>;
}

const ChatContext = createContext<ChatValue | null>(null);

export function ChatProvider({ children }: { children: React.ReactNode }) {
  const [messages, setMessages] = useState<ChatMessage[]>(chatService.SEED_MESSAGES);

  const send = useCallback(async (text: string) => {
    const trimmed = text.trim();
    if (!trimmed) return;
    await chatService.sendMessage(trimmed);
    setMessages((msgs) => [...msgs, { id: msgs.length, kind: 'mine', text: trimmed }]);
  }, []);

  const value = useMemo<ChatValue>(() => ({ messages, send }), [messages, send]);
  return <ChatContext.Provider value={value}>{children}</ChatContext.Provider>;
}

export function useChat(): ChatValue {
  const ctx = useContext(ChatContext);
  if (!ctx) throw new Error('useChat must be used within ChatProvider');
  return ctx;
}
