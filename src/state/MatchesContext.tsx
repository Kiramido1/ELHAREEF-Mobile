import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import * as matchesService from '../services/matches';
import { MatchFullError } from '../services/network';
import { JoinStatus, Match, SkillLevel } from '../types';

interface CreateMatchDraft {
  need: number;
  level: SkillLevel;
  privacy: 'public' | 'friends';
  description: string;
}

interface MatchesValue {
  matches: Match[];
  joinStatus: Record<number, JoinStatus>;
  posted: boolean;
  draft: CreateMatchDraft;
  selMatchId: number;
  selectMatch: (id: number) => void;
  setDraft: (patch: Partial<CreateMatchDraft>) => void;
  postMatch: () => void;
  /**
   * Ask to join a match: pending → joined after the mock server accepts,
   * incrementing the joined count. Rejects with MatchFullError when the
   * match filled up first (design's "match full" state).
   */
  join: (matchId: number) => Promise<void>;
}

const MatchesContext = createContext<MatchesValue | null>(null);

export function MatchesProvider({ children }: { children: React.ReactNode }) {
  const [matches, setMatches] = useState<Match[]>(matchesService.allMatches);
  const [joinStatus, setJoinStatus] = useState<Record<number, JoinStatus>>({});
  const [posted, setPosted] = useState(false);
  const [selMatchId, setSelMatchId] = useState(0);
  const [draft, setDraftState] = useState<CreateMatchDraft>({
    need: 2,
    level: 'Intermediate',
    privacy: 'public',
    description: '',
  });

  const setDraft = useCallback(
    (patch: Partial<CreateMatchDraft>) => setDraftState((d) => ({ ...d, ...patch })),
    [],
  );
  const postMatch = useCallback(() => setPosted(true), []);
  const selectMatch = useCallback((id: number) => setSelMatchId(id), []);

  const join = useCallback(async (matchId: number) => {
    setJoinStatus((j) => ({ ...j, [matchId]: 'pending' }));
    try {
      await matchesService.requestJoin(matchId);
      setJoinStatus((j) => ({ ...j, [matchId]: 'joined' }));
      setMatches((ms) =>
        ms.map((m) =>
          m.id === matchId ? { ...m, joined: Math.min(m.total, m.joined + 1) } : m,
        ),
      );
    } catch (e) {
      setJoinStatus((j) => ({ ...j, [matchId]: 'none' }));
      if (e instanceof MatchFullError) {
        // The match filled while the request was pending — reflect it.
        setMatches((ms) => ms.map((m) => (m.id === matchId ? { ...m, joined: m.total } : m)));
      }
      throw e;
    }
  }, []);

  const value = useMemo<MatchesValue>(
    () => ({ matches, joinStatus, posted, draft, selMatchId, selectMatch, setDraft, postMatch, join }),
    [matches, joinStatus, posted, draft, selMatchId, selectMatch, setDraft, postMatch, join],
  );

  return <MatchesContext.Provider value={value}>{children}</MatchesContext.Provider>;
}

export function useMatches(): MatchesValue {
  const ctx = useContext(MatchesContext);
  if (!ctx) throw new Error('useMatches must be used within MatchesProvider');
  return ctx;
}
