// ELHAREEF — Flutter port of the Expo / React Native app (App.tsx +
// src/navigation/index.tsx).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'i18n/i18n.dart';
import 'navigation/nav.dart';
import 'navigation/tabs.dart';
import 'scope.dart';
import 'screens/booking_details_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/confirmed_screen.dart';
import 'screens/create_match_screen.dart';
import 'screens/find_players_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/match_details_screen.dart';
import 'screens/match_full_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/offline_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/payment_failed_screen.dart';
import 'screens/pitch_details_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/summary_screen.dart';
import 'theme/colors.dart';
import 'theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const AppScopes(child: ElhareefApp()));
}

Widget _screenFor(String? name, Object? args) => switch (name) {
      'Splash' => const SplashScreen(),
      'Onboarding' => const OnboardingScreen(),
      'Login' => const LoginScreen(),
      'Signup' => const SignupScreen(),
      'ForgotPassword' => const ForgotPasswordScreen(),
      'Tabs' => const MainTabs(),
      'Search' => SearchScreen(openFilters: args == true),
      'Pitch' => PitchDetailsScreen(pitchId: args as int),
      'Booking' => const BookingScreen(),
      'Summary' => const SummaryScreen(),
      'Confirmed' => const ConfirmedScreen(),
      'FindPlayers' => const FindPlayersScreen(),
      'CreateMatch' => const CreateMatchScreen(),
      'MatchDetails' => MatchDetailsScreen(matchId: args as int),
      'MatchFull' => MatchFullScreen(matchId: args as int),
      'PlayerProfile' => PlayerProfileScreen(matchId: args as int),
      'Chat' => const ChatScreen(),
      'BookingDetails' => const BookingDetailsScreen(),
      'Notifications' => const NotificationsScreen(),
      'Settings' => const SettingsScreen(),
      'PaymentFailed' => const PaymentFailedScreen(),
      'Offline' => const OfflineScreen(),
      _ => throw ArgumentError('Unknown route $name'),
    };

class ElhareefApp extends StatelessWidget {
  const ElhareefApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeController>().dark;
    final c = context.colors;
    final i18n = context.watch<I18n>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: c.bar,
      ),
      child: MaterialApp(
        title: 'ELHAREEF',
        debugShowCheckedModeBanner: false,
        navigatorKey: navKey,
        navigatorObservers: [routeObserver, stackTracker],
        initialRoute: 'Splash',
        onGenerateRoute: (s) => instantRoute(s, (_) => _screenFor(s.name, s.arguments)),
        locale: Locale(i18n.lang),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          brightness: dark ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: c.bg,
          canvasColor: c.bg,
          fontFamily: i18n.isRTL ? Fonts.arabic : Fonts.archivo,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Brand.green,
            primary: Brand.green,
            brightness: dark ? Brightness.dark : Brightness.light,
            surface: c.card,
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Brand.green,
            selectionHandleColor: Brand.green,
            selectionColor: Brand.green.withValues(alpha: .3),
          ),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        // Every screen gets a Material ancestor (TextField needs one).
        builder: (context, child) => Material(color: c.bg, child: child),
      ),
    );
  }
}
