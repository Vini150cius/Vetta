import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

/// Tema claro/escuro/sistema. Não é dado sensível, então usa SharedPreferences
/// (e fica disponível já na tela de bloqueio).
class ThemeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final i = (await SharedPreferences.getInstance()).getInt(_key);
    if (i != null && i >= 0 && i < ThemeMode.values.length)
      state = ThemeMode.values[i];
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await (await SharedPreferences.getInstance()).setInt(_key, mode.index);
  }
}
