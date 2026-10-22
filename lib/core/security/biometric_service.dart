import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricResult {
  const BiometricResult(this.success, [this.message]);
  final bool success;
  final String? message;
}

/// Exige biometria (impressão digital) — `biometricOnly: true` bloqueia o fallback por PIN/padrão.
class BiometricService {
  final _auth = LocalAuthentication();

  Future<BiometricResult> authenticate() async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return const BiometricResult(
            false, 'Este aparelho não suporta biometria.');
      }
      if ((await _auth.getAvailableBiometrics()).isEmpty) {
        return const BiometricResult(false,
            'Cadastre uma impressão digital nas configurações do Android.');
      }
      final ok = await _auth.authenticate(
        localizedReason: 'Autentique-se para acessar suas finanças',
        options:
            const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      return ok
          ? const BiometricResult(true)
          : const BiometricResult(false, 'Autenticação cancelada.');
    } on PlatformException catch (e) {
      return BiometricResult(
          false, e.message ?? 'Erro na autenticação biométrica.');
    }
  }
}
