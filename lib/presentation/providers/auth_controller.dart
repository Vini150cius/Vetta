import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di_providers.dart';

enum AuthStatus { locked, authenticating, unlocked }

class AuthState {
  const AuthState(this.status, {this.message});
  final AuthStatus status;
  final String? message;
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Fica `true` só com o app desbloqueado; os providers de dados dependem disso.
final isUnlockedProvider = Provider<bool>(
  (ref) =>
      ref.watch(authControllerProvider.select((s) => s.status)) ==
      AuthStatus.unlocked,
);

/// Porta de entrada da segurança:
///   biometria OK → lê a chave do Keystore → abre o SQLCipher → UI liberada.
///   travar       → UI bloqueada → fecha o banco (a chave não fica em memória).
class AuthController extends Notifier<AuthState> {
  bool _autoLockSuspended = false;

  @override
  AuthState build() => const AuthState(AuthStatus.locked);

  Future<void> unlock() async {
    if (state.status != AuthStatus.locked) return;
    state = const AuthState(AuthStatus.authenticating);

    final result = await ref.read(biometricServiceProvider).authenticate();
    if (!result.success) {
      state = AuthState(AuthStatus.locked, message: result.message);
      return;
    }
    try {
      final key = await ref
          .read(keyManagerProvider)
          .getOrCreateKey(); // só após a biometria
      await ref.read(appDatabaseProvider).open(key);
      state = const AuthState(AuthStatus.unlocked);
      // Limpa exportações antigas (arquivos em texto puro) deixadas no cache.
      ref.read(fileExchangeProvider).purgeExports().catchError((_) {});
    } catch (_) {
      state = const AuthState(AuthStatus.locked,
          message: 'Não foi possível abrir o banco criptografado.');
    }
  }

  /// [auto] = veio do ciclo de vida (app foi para segundo plano).
  Future<void> lock({bool auto = false}) async {
    if (state.status != AuthStatus.unlocked) return;
    if (auto && _autoLockSuspended) return;
    state = const AuthState(AuthStatus.locked); // UI sai de cena primeiro...
    await ref.read(appDatabaseProvider).close(); // ...depois o banco é fechado.
  }

  /// Evita travar enquanto um seletor de arquivos / share sheet do Android está aberto.
  Future<T> withoutAutoLock<T>(Future<T> Function() action) async {
    _autoLockSuspended = true;
    try {
      return await action();
    } finally {
      _autoLockSuspended = false;
    }
  }
}
