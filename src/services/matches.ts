import { Match } from '../types';
import { MatchFullError, simulateRequest } from './network';

const MATCHES: Match[] = [
  {
    id: 0,
    org: 'Ahmed Hassan',
    orgAr: 'أحمد حسن',
    initial: 'A',
    avatar: 'navy',
    pitch: 'Dream Sports Arena',
    area: 'Fayoum City',
    day: 'Friday',
    time: '8:00 PM',
    durHours: 2,
    joined: 6,
    total: 8,
    level: 'Intermediate',
    gradIndex: 0,
    desc: 'Friendly match, intermediate level. We split the pitch cost evenly and rotate keepers every 20 minutes.',
    descAr: 'ماتش ودي مستوى متوسط. بنقسم تكلفة الملعب بالتساوي وبنبدل الحارس كل 20 دقيقة.',
  },
  {
    id: 1,
    org: 'Omar Tarek',
    orgAr: 'عمر طارق',
    initial: 'O',
    avatar: 'tint',
    pitch: 'Green Field Club',
    area: 'Sinnuris',
    day: 'Saturday',
    time: '7:00 PM',
    durHours: 1,
    joined: 8,
    total: 10,
    level: 'Advanced',
    gradIndex: 1,
    desc: 'Fast-paced game, advanced players only please.',
    descAr: 'لعب سريع، للمتقدمين بس.',
  },
  {
    id: 2,
    org: 'Karim Said',
    orgAr: 'كريم سعيد',
    initial: 'K',
    avatar: 'green',
    pitch: 'Champions Park',
    area: 'Tamiya',
    day: 'Sunday',
    time: '9:00 PM',
    durHours: 2,
    joined: 4,
    total: 10,
    level: 'Any level',
    gradIndex: 2,
    desc: 'Casual Sunday game, everyone welcome.',
    descAr: 'ماتش حبي يوم الأحد، الكل مرحب بيه.',
  },
];

export function listMatches(): Promise<Match[]> {
  return simulateRequest(MATCHES, 500);
}

export function getMatch(id: number): Match {
  return MATCHES[id] ?? MATCHES[0];
}

export const allMatches = MATCHES;

/**
 * Request to join a match. Karim's casual Sunday game (id 2) fills up while
 * the request is in flight — the server answers with MatchFullError, which
 * drives the designed "This match just filled up" state.
 */
export function requestJoin(matchId: number): Promise<{ matchId: number }> {
  if (matchId === 2) {
    return simulateRequest(null, 900).then(() => {
      throw new MatchFullError();
    });
  }
  return simulateRequest({ matchId }, 1100);
}
