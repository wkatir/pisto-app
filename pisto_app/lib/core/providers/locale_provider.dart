import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../i18n/translations.g.dart';

const _localeKey = 'locale';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  LocaleNotifier();

  final _storage = const FlutterSecureStorage();

  @override
  Locale build() {
    _loadLocale();
    return LocaleSettings.currentLocale.flutterLocale;
  }

  Future<void> _loadLocale() async {
    final stored = await _storage.read(key: _localeKey);
    if (stored != null) {
      final appLocale = AppLocale.values.where((l) => l.name == stored).firstOrNull;
      if (appLocale != null) {
        LocaleSettings.setLocale(appLocale);
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    final appLocale = AppLocale.values.where((l) => l.flutterLocale == locale).firstOrNull
        ?? AppLocale.en;
    await LocaleSettings.setLocale(appLocale);
    state = appLocale.flutterLocale;
    await _storage.write(key: _localeKey, value: appLocale.name);
  }

  void toggleLocale() {
    final current = LocaleSettings.currentLocale;
    final next = current == AppLocale.en ? AppLocale.es : AppLocale.en;
    setLocale(next.flutterLocale);
  }
}
