import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gera e guarda a chave do SQLCipher.
/// - 256 bits aleatórios (CSPRNG): nunca derivada de senha ou ID do aparelho.
/// - Armazenada no Android Keystore (EncryptedSharedPreferences), fora do banco.
/// - Só é lida APÓS a biometria (ver AuthController) e descartada ao travar.
/// Nota: o Keystore aqui não exige biometria por si só; o bloqueio é garantido pelo
/// fluxo do app. Para amarrar a chave ao hardware biométrico, troque por `biometric_storage`.
class KeyManager {
  KeyManager([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true));

  static const _keyName = 'db_key_v1';
  final FlutterSecureStorage _storage;

  Future<String> getOrCreateKey() async {
    var key = await _storage.read(key: _keyName);
    if (key == null) {
      final rnd = Random.secure();
      key = base64UrlEncode(List<int>.generate(32, (_) => rnd.nextInt(256)));
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }
}
