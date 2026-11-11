// Root widget and route table.
import 'package:elhareef/app/main_tabs.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/presentation/offline_screen.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:elhareef/features/auth/presentation/screens/login_screen.dart';
import 'package:elhareef/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:elhareef/features/auth/presentation/screens/signup_screen.dart';
import 'package:elhareef/features/auth/presentation/screens/splash_screen.dart';
import 'package:elhareef/features/booking/presentation/screens/booking_details_screen.dart';
import 'package:elhareef/features/booking/presentation/screens/booking_screen.dart';
import 'package:elhareef/features/booking/presentation/screens/confirmed_screen.dart';
import 'package:elhareef/features/booking/presentation/screens/payment_failed_screen.dart';
import 'package:elhareef/features/booking/presentation/screens/summary_screen.dart';
import 'package:elhareef/features/chat/presentation/screens/chat_screen.dart';
import 'package:elhareef/features/matches/presentation/screens/create_match_screen.dart';
import 'package:elhareef/features/matches/presentation/screens/find_players_screen.dart';
import 'package:elhareef/features/matches/presentation/screens/match_details_screen.dart';
import 'package:elhareef/features/matches/presentation/screens/match_full_screen.dart';
import 'package:elhareef/features/matches/presentation/screens/player_profile_screen.dart';
import 'package:elhareef/features/pitches/presentation/screens/pitch_details_screen.dart';
import 'package:elhareef/features/pitches/presentation/screens/search_screen.dart';
import 'package:elhareef/features/profile/presentation/screens/notifications_screen.dart';
import 'package:elhareef/features/profile/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Route name → screen.
Widget screenFor(String? name, Object? args) => switch (name) {
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
      'Confirmed' => ConfirmedScreen(bookingId: args as String?),
      'FindPlayers' => FindPlayersScreen(bookingId: args as String?),
      'CreateMatch' => CreateMatchScreen(bookingId: args as String?),
      'MatchDetails' => MatchDetailsScreen(matchId: args as int),
      'MatchFull' => MatchFullScreen(matchId: args as int),
      'PlayerProfile' => PlayerProfileScreen(matchId: args as int),
      'Chat' => const ChatScreen(),
      'BookingDetails' => BookingDetailsScreen(bookingId: args as String?),
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
        onGenerateRoute: (s) => instantRoute(s, (_) => screenFor(s.name, s.arguments)),
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
