import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _prefix = 'mara_gym_';
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  T read<T>(String key, T fallback) {
    final raw = _prefs.getString(_prefix + key);
    if (raw == null) {
      return fallback;
    }

    try {
      return jsonDecode(raw) as T;
    } catch (e) {
      remove(key);
      return fallback;
    }
  }

  Future<void> write<T>(String key, T value) async {
    await _prefs.setString(_prefix + key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await _prefs.remove(_prefix + key);
  }
}
