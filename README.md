<div align="center">

<img src="assets/brand/splash-logo.png" alt="ELHAREEF" width="220" />

# ELHAREEF — Book. Play. Win. ⚽

**The football pitch booking & matchmaking app for the Egyptian market.**
Book a pitch in seconds, post your match, and let nearby *hareefa* fill the empty spots.

[![Expo](https://img.shields.io/badge/Expo-SDK%2057-000020?logo=expo&logoColor=white)](https://expo.dev)
[![React Native](https://img.shields.io/badge/React%20Native-0.86-61DAFB?logo=react&logoColor=white)](https://reactnative.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![i18n](https://img.shields.io/badge/i18n-English%20%7C%20%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-24A551)](#-localization--rtl)
[![Made in Fayoum](https://img.shields.io/badge/Made%20in-Fayoum%20%F0%9F%87%AA%F0%9F%87%AC-BDF961)](#)

</div>

---

## 📱 Screenshots

| Splash | Home | Search | Pitch details |
|:---:|:---:|:---:|:---:|
| ![Splash](docs/screenshots/splash.png) | ![Home](docs/screenshots/home.png) | ![Search](docs/screenshots/search.png) | ![Pitch details](docs/screenshots/pitch-details.png) |

| Booking | Summary | Confirmed | Booking details |
|:---:|:---:|:---:|:---:|
| ![Booking](docs/screenshots/booking.png) | ![Summary](docs/screenshots/summary.png) | ![Confirmed](docs/screenshots/confirmed.png) | ![Booking details](docs/screenshots/booking-details.png) |

| Match discovery | Match details | Squad chat | Forgot password |
|:---:|:---:|:---:|:---:|
| ![Discovery](docs/screenshots/discover.png) | ![Match details](docs/screenshots/match-details.png) | ![Chat](docs/screenshots/chat.png) | ![Forgot password](docs/screenshots/forgot-password.png) |

| Dark mode | العربية (RTL) |
|:---:|:---:|
| ![Dark mode](docs/screenshots/home-dark.png) | ![Arabic RTL](docs/screenshots/home-arabic.png) |

---

## ✨ Features

### 🏟️ Pitch booking
- Browse nearby pitches with real photos, ratings, prices, and live availability
- Search & filter by pitch type (5/7/8/11-a-side), price, and distance
- 3-step booking: **date → start time → duration** with live price calculation
- **Repeat weekly** — lock the same slot for 4 weeks with a deposit
- Pay in full or deposit-only · card or wallet · graceful payment-failure recovery

### 👥 Find players (matchmaking)
- Post your match — nearby players fill the empty spots
- Live capacity: joining a match updates `6/8 → 7/8` everywhere in real time
- Join lifecycle: request → pending → joined, with a **match-full** fallback state
- Player profiles with ratings, stats, and match history

### 💬 Squad chat
- Real-time-ready chat UI with sender/receiver bubbles, system events, and quick replies
- Structured so a WebSocket backend plugs in without touching the UI

### 🎨 Experience
- **Full Arabic (Egyptian) localization + RTL** — flips layout, fonts, and chevrons correctly
- **Dark mode** with a complete parallel token palette
- Smooth, finger-tracked **scroll-reveal** animations and soft selection cross-fades
- Loading skeletons, empty states, offline state, and friendly error recovery
- Secure auth screens: password with show/hide, validation, and a 3-step **forgot-password** flow (SMS code → new password)

---

## 🚀 Getting started

```bash
# 1 · Install dependencies
npm install

# 2 · Start the dev server
npm start          # scan the QR with Expo Go

# Platform shortcuts
npm run android    # Android device/emulator
npm run ios        # iOS simulator (macOS)
npm run web        # Web preview at http://localhost:8081
```

> **Requirements:** Node 20+, npm 10+, and the [Expo Go](https://expo.dev/go) app for on-device preview.

---

## 🏗️ Architecture

```
src/
├── theme/         Design tokens — colors (light + dark), typography, spacing, radii, shadows
├── i18n/          Full EN/AR dictionary + RTL-aware translation hooks
├── types/         Domain models (Pitch, Match, BookingRecord, ChatMessage, …)
├── services/      Mock repositories with simulated latency & failure modes
│                  (pitches · matches · bookings · chat · players · network)
├── state/         React contexts — BookingContext (selections + price math),
│                  MatchesContext (join lifecycle), ChatContext (thread)
├── components/    Design-system primitives — Txt, Button, Chip, Segmented,
│                  ToggleSwitch, ProgressBar, Avatar, Card, Input, PasswordInput,
│                  PitchArt, Skeleton, TabBar, anim (motion system), icons/
├── navigation/    Typed root stack + bottom tabs (custom tab bar)
├── screens/       26 screens — every flow from splash to settings
└── constants/     Static asset maps (pitch photography)
```

**Design principles**

- **Single source of truth for tokens** — every color, radius, and font weight lives in `src/theme/`; screens never hard-code values.
- **UI ⇄ data separation** — screens only consume async service signatures. Swapping the mock bodies in `src/services/` for real endpoints requires **zero UI changes**.
- **Typed navigation** — full `RootStackParamList` / `MainTabParamList` coverage; no stringly-typed routes.
- **Native-driver motion** — the animation system (`components/anim.tsx`) runs on the UI thread: screen transitions, selection cross-fades, scroll-linked reveals, and spring toggles.

---

## 🧮 Business logic

| Rule | Implementation |
|---|---|
| Price | `duration × pitch rate × sessions` (+ 20 EGP booking fee) |
| Weekly repeat | 4 sessions, deposit locks all slots |
| Deposit | `max(50, 25% of total, rounded to 5 EGP)` |
| Slots | 4 PM – 10 PM, busy slots disabled with strikethrough |
| Join capacity | Server-confirmed; a full match returns `MatchFullError` → designed "match full" state |
| Payments | First card attempt declines (demo of the failure state); retry & cash-at-venue succeed |

---

## 🌍 Localization & RTL

The app ships with a complete **English / Egyptian-Arabic** dictionary (`src/i18n/translations.ts`).
Switching to العربية from Settings flips — live, without a reload:

- Text, fonts (Archivo ↔ IBM Plex Sans Arabic), and alignment
- Row direction, tab order, and chevron mirroring (bidi-aware)
- Dates, prices, and pluralization (ساعة / ساعتين / ٣ ساعات)

---

## 🎨 Design system

| Token | Value |
|---|---|
| Pitch Navy | `#061533` |
| Turf Green | `#24A551` |
| Kick Lime | `#BDF961` |
| Pitch Tint | `#F0F9E4` |
| Cloud White | `#FBFCFA` |

Typography: **Archivo** (400–800) for UI · **IBM Plex Sans Arabic** (400/600) for Arabic.
Dark mode redefines the full palette (`src/theme/colors.ts`) — no ad-hoc dark overrides.

---

## 🛣️ Roadmap

- [ ] Real backend (REST + WebSocket chat)
- [ ] Phone-number OTP authentication
- [ ] Payment gateway integration (card / mobile wallet)
- [ ] Push notifications (match reminders, join requests)
- [ ] Player ratings & reviews
- [ ] Venue-owner dashboard

---

## 🧰 Tech stack

`Expo SDK 57` · `React Native 0.86` · `TypeScript (strict)` · `React Navigation 7` · `react-native-svg` · `expo-linear-gradient` · `@expo-google-fonts`

---

<div align="center">

**ELHAREEF v1.0 · Made in Fayoum 🇪🇬**

</div>
