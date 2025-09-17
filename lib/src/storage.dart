import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for simple key-value persistence used by the showcase.
abstract class ShowcaseStorage {
  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);
}

/// In-memory storage fallback (useful for tests or when persistence disabled).
class MemoryShowcaseStorage implements ShowcaseStorage {
  final Map<String, bool> _store = <String, bool>{};

  @override
  Future<bool?> readBool(String key) async => _store[key];

  @override
  Future<void> writeBool(String key, bool value) async {
    _store[key] = value;
  }
}

/// SharedPreferences-backed storage for mobile/desktop/web.
class SharedPrefsShowcaseStorage implements ShowcaseStorage {
  SharedPrefsShowcaseStorage();

  @override
  Future<bool?> readBool(String key) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[nextgen_showcase] SharedPreferences read error: $e');
      }
      return null;
    }
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[nextgen_showcase] SharedPreferences write error: $e');
      }
    }
  }
}
