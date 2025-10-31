import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemePref = 'theme_mode'; // 'light' | 'dark' | 'system'

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeNotifier(this.ref) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_kThemePref) ?? 'system';
      state = _fromString(value);
    } catch (_) {
      // Se falhar ao carregar, mantém ThemeMode.system como padrão.
      state = ThemeMode.system;
    }
  }

  ThemeMode _fromString(String s) {
    if (s == 'dark') return ThemeMode.dark;
    if (s == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  String _toString(ThemeMode mode) {
    if (mode == ThemeMode.dark) return 'dark';
    if (mode == ThemeMode.light) return 'light';
    return 'system';
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemePref, _toString(mode));
    } catch (_) {
      // ignora erros de persistência
    }
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
      (ref) => ThemeNotifier(ref),
);