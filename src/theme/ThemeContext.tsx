import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import { ThemeColors, darkColors, lightColors } from './colors';

interface ThemeValue {
  dark: boolean;
  colors: ThemeColors;
  toggleDark: () => void;
}

const ThemeContext = createContext<ThemeValue | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [dark, setDark] = useState(false);
  const toggleDark = useCallback(() => setDark((d) => !d), []);
  const value = useMemo<ThemeValue>(
    () => ({ dark, colors: dark ? darkColors : lightColors, toggleDark }),
    [dark, toggleDark],
  );
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): ThemeValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}
