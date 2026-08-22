import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import { TranslationKey, ar, en } from './translations';

export type Lang = 'en' | 'ar';

interface I18nValue {
  lang: Lang;
  isRTL: boolean;
  setLang: (lang: Lang) => void;
  /** Look up a string in the current language. */
  t: (key: TranslationKey) => string;
  /** Pick between raw English/Arabic strings (for data-layer values). */
  pick: (english: string, arabic: string) => string;
}

const I18nContext = createContext<I18nValue | null>(null);

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLang] = useState<Lang>('en');
  const t = useCallback((key: TranslationKey) => (lang === 'ar' ? ar[key] : en[key]), [lang]);
  const pick = useCallback(
    (english: string, arabic: string) => (lang === 'ar' ? arabic : english),
    [lang],
  );
  const value = useMemo<I18nValue>(
    () => ({ lang, isRTL: lang === 'ar', setLang, t, pick }),
    [lang, t, pick],
  );
  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n(): I18nValue {
  const ctx = useContext(I18nContext);
  if (!ctx) throw new Error('useI18n must be used within I18nProvider');
  return ctx;
}

export { typeAr, areaAr, dayAr, levelAr } from './translations';
export type { TranslationKey };
