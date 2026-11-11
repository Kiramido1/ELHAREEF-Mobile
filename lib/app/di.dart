// Composition root: the only place that knows concrete implementations.
// Screens see controllers; controllers see domain interfaces/use cases.
import 'package:flutter/widgets.dart';

import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/storage/key_value_store.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:elhareef/features/auth/presentation/controllers/session_controller.dart';
import 'package:elhareef/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:elhareef/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:elhareef/features/chat/presentation/controllers/chat_controller.dart';
import 'package:elhareef/features/matches/data/datasources/match_local_datasource.dart';
import 'package:elhareef/features/matches/data/repositories/match_repository_impl.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart';
import 'package:elhareef/features/pitches/data/repositories/pitch_repository_impl.dart';
import 'package:elhareef/features/pitches/presentation/controllers/pitches_controller.dart';

class AppDependencies {
  AppDependencies({required KeyValueStore store, Clock clock = const Clock(), bool declineFirstCardPayment = true})
      : theme = ThemeController(store: store),
        i18n = I18n(store: store),
        session = SessionController(AuthRepositoryImpl(store)),
        chat = ChatController(const ChatRepositoryImpl()) {
    final pitchRepo = PitchRepositoryImpl(const PitchMockDatasource());
    final bookingRepo = BookingRepositoryImpl(
      BookingLocalDatasource(store, clock),
      declineFirstCardPayment: declineFirstCardPayment,
    );
    pitches = PitchesController(pitchRepo);
    booking = BookingController(bookings: bookingRepo, pitches: pitchRepo, clock: clock);
    bookings = BookingsController(repository: bookingRepo, clock: clock);
    matches = MatchesController(repository: MatchRepositoryImpl(MatchLocalDatasource(store, clock)), clock: clock);
  }

  final ThemeController theme;
  final I18n i18n;
  final SessionController session;
  final ChatController chat;
  late final PitchesController pitches;
  late final BookingController booking;
  late final BookingsController bookings;
  late final MatchesController matches;

  /// Warm the lists the tabs show.
  Future<void> warmUp() => Future.wait([bookings.refresh(), matches.refresh()]);
}

/// Provides every controller to the widget tree.
class AppScopes extends StatelessWidget {
  const AppScopes({super.key, required this.deps, required this.child});
  final AppDependencies deps;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scope<ThemeController>(
        value: deps.theme,
        child: Scope<I18n>(
          value: deps.i18n,
          child: Scope<SessionController>(
            value: deps.session,
            child: Scope<PitchesController>(
              value: deps.pitches,
              child: Scope<BookingController>(
                value: deps.booking,
                child: Scope<BookingsController>(
                  value: deps.bookings,
                  child: Scope<MatchesController>(
                    value: deps.matches,
                    child: Scope<ChatController>(value: deps.chat, child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
