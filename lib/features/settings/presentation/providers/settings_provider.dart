import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Theme mode ───────────────────────────────────────────────────────────────

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setDark() => state = ThemeMode.dark;
  void setLight() => state = ThemeMode.light;
  void setSystem() => state = ThemeMode.system;
  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

// ─── Currency ─────────────────────────────────────────────────────────────────

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(
  CurrencyNotifier.new,
);

class CurrencyNotifier extends Notifier<String> {
  @override
  String build() => '₹ INR';

  void setCurrency(String currency) => state = currency;
}
