import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safeway/core/di/theme_providers.dart';
import 'dart:async';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitForTheme(ProviderContainer container, ThemeMode expected,
      {Duration timeout = const Duration(seconds: 1)}) async {
    final end = DateTime.now().add(timeout);
    while (container.read(themeNotifierProvider) != expected) {
      if (DateTime.now().isAfter(end)) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  group('ThemeNotifier', () {
    test('loads initial value from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      final container = ProviderContainer();
      await waitForTheme(container, ThemeMode.dark);

      expect(container.read(themeNotifierProvider), equals(ThemeMode.dark));
      container.dispose();
    });

    test('setMode persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.setMode(ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
      expect(container.read(themeNotifierProvider), equals(ThemeMode.light));

      container.dispose();
    });

    test('toggle switches between light and dark', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

      final container = ProviderContainer();
      await waitForTheme(container, ThemeMode.light);

      final notifier = container.read(themeNotifierProvider.notifier);
      await notifier.toggle();

      await waitForTheme(container, ThemeMode.dark);
      expect(container.read(themeNotifierProvider), equals(ThemeMode.dark));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');

      container.dispose();
    });
  });
}
