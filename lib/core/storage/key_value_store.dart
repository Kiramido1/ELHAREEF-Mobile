// Minimal persistence port. The app uses [SharedPrefsStore]; tests use
// [MemoryStore]. Keeping the interface tiny keeps the data layer swappable.
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  String? getString(String key);
  bool? getBool(String key);
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore._(this._prefs);
  final SharedPreferences _prefs;

  static Future<SharedPrefsStore> open() async => SharedPrefsStore._(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  bool? getBool(String key) => _prefs.getBool(key);
  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, Object>? seed]) : _data = {...?seed};
  final Map<String, Object> _data;

  @override
  String? getString(String key) => _data[key] as String?;
  @override
  bool? getBool(String key) => _data[key] as bool?;
  @override
  Future<void> setString(String key, String value) async => _data[key] = value;
  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;
  @override
  Future<void> remove(String key) async => _data.remove(key);
}
