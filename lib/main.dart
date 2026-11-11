// ELHAREEF — football pitch booking & matchmaking.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elhareef/app/app.dart';
import 'package:elhareef/app/di.dart';
import 'package:elhareef/core/storage/key_value_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final deps = AppDependencies(store: await SharedPrefsStore.open());
  unawaited(deps.warmUp()); // splash covers the load
  runApp(AppScopes(deps: deps, child: const ElhareefApp()));
}
