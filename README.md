<div align="center">

<img src="assets/brand/splash-logo.png" alt="ELHAREEF" width="220" />

# ELHAREEF — Book. Play. Win. ⚽

**The football pitch booking & matchmaking app for the Egyptian market.**
Book a pitch in seconds, post your match, and let nearby *hareefa* fill the empty spots.

[![Flutter](https://img.shields.io/badge/Flutter-3-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)](https://dart.dev)
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
## 🚀 Getting started

```bash
flutter pub get
flutter run                 # Android device/emulator (iOS needs macOS + Xcode)
flutter analyze             # static analysis (clean)
flutter test                # domain/repository/controller tests + every-screen render test
flutter build apk --release # signed with the debug key until a keystore is set up
```

> **Requirements:** Flutter 3 (Dart SDK ^3.13).

---

## 🏗️ Architecture

Feature-first **Clean Architecture** — each feature owns its `domain`, `data` and `presentation` layers.

```
lib/
├── main.dart                 Opens storage, builds the composition root, runs the app
├── app/                      App shell: route table (app.dart), DI root (di.dart), bottom tabs
├── core/
│   ├── di/                   Scope<T> (InheritedNotifier) + context.watch/read
│   ├── error/                Sealed AppFailure (network, match full, payment declined, slot taken, validation)
│   ├── i18n/                 EN/AR dictionaries, Formatters (dates, plurals, hours), persisted language
│   ├── navigation/           Navigator helpers
│   ├── network/              Simulated transport for the mock datasources
│   ├── storage/              KeyValueStore port → SharedPrefsStore (app) / MemoryStore (tests)
│   ├── theme/                Tokens, light/dark palettes, persisted ThemeController
│   ├── time/                 Injectable Clock (FixedClock in tests)
│   └── widgets/              Design-system primitives, inputs, media, motion, toast
└── features/
    ├── auth/                 Session, Egyptian phone validation, onboarding-once
    ├── pitches/              Pitch catalogue, search & filters (price · distance · type · text)
    ├── booking/              Booking rules, quote, confirm/cancel use cases, history
    ├── matches/              Discover, join/leave/host use cases, my matches
    ├── chat/                 Squad chat thread
    └── profile/              Profile, settings, notifications
        └── <feature>/
            ├── domain/       Entities, repository interfaces, use cases (pure Dart)
            ├── data/         Datasources, models, repository implementations
            └── presentation/ ChangeNotifier controllers, screens
```

**Design principles**

- **Dependency rule** — `domain` is pure Dart and imports nothing from `data` or Flutter; screens talk to controllers, controllers to use cases/repository interfaces.
- **One composition root** — `lib/app/di.dart` is the only place that knows concrete implementations. Swapping a mock datasource for a real API changes nothing above the data layer.
- **Use cases where rules live** — `ConfirmBooking`, `CancelBooking`, `JoinMatch`, `LeaveMatch`, `HostMatch`, `SignIn`/`SignUp`. Plain reads go straight through the repository (no pass-through use cases).
- **No heavy state library** — built-in `ChangeNotifier` controllers exposed via `InheritedNotifier`.
- **Deterministic time** — every date rule reads an injected `Clock`, so tests pin "now".
- **Single source of truth for tokens** — every color, radius and font weight lives in `lib/core/theme/`.

---

## 🧮 Business logic

| Rule | Implementation |
|---|---|
| Price | `duration × pitch rate × sessions` (+ 20 EGP booking fee) |
| Weekly repeat | 4 sessions, deposit locks all slots |
| Deposit | `max(50, 25% of total, rounded to 5 EGP)` |
| Slots | Start 4 PM – 10 PM, venue closes at midnight; busy and past hours disabled |
| Overlap | A booking can't cover a busy hour or run past closing — longer durations are disabled |
| Booking window | Today through the next 60 days |
| Cancellation | Any upcoming booking; free until 12 h before kick-off |
| Slot hold | 10 minutes after a declined payment, with a live countdown |
| Join capacity | Server-confirmed; a full match returns `MatchFullError` → designed "match full" state |
| Payments | First card attempt per session declines (demo of the failure state); retry & cash-at-venue succeed |
| Phone | Egyptian mobile only: `01[0125]` + 8 digits (accepts `0…`, `+20…`) |
| Persistence | Session, onboarding, language, theme, bookings, joined/hosted matches (`shared_preferences`) |

---

## 🌍 Localization & RTL

The app ships with a complete **English / Egyptian-Arabic** dictionary (`lib/core/i18n/`).
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
Dark mode redefines the full palette (`lib/core/theme/colors.dart`) — no ad-hoc dark overrides.

---

## ⚠️ Known limitations

- **No backend** — all services return hard-coded data after a simulated delay (`lib/core/network/fake_network.dart`); bookings and match membership are persisted on-device only, including the designed failure paths (first card payment declines, a match fills up, offline).
- **iOS** is configured (bundle id `com.elhareef.app`, icon, launch screen) but not yet built — requires macOS/Xcode.
- **Release signing** uses the debug key until a release keystore (`android/key.properties`) is configured.

---

## 🛣️ Roadmap

- [ ] Real backend (REST + WebSocket chat)
- [ ] Phone-number OTP authentication
- [ ] Payment gateway integration (card / mobile wallet)
- [ ] Push notifications (match reminders, join requests)
- [ ] Release keystore + Play Store listing
- [ ] Venue-owner dashboard

---

## 🧰 Tech stack

`Flutter 3` · `Dart 3` · `flutter_svg` · `flutter_localizations` · `shared_preferences` · bundled Archivo & IBM Plex Sans Arabic fonts

---

<div align="center">

**ELHAREEF v1.0 · Made in Fayoum 🇪🇬**

</div>
