# Vetta — MVP Flutter (Android, offline-first)

## Como rodar
```bash
flutter create . --platforms=android --project-name financas_app --org com.seudominio   # gera a pasta android/
# (mantenha lib/, test/ e pubspec.yaml deste projeto)
flutter pub get
flutter run
flutter test
```

## Ajustes obrigatórios no Android (após `flutter create`)
1. `android/app/build.gradle(.kts)`: `minSdk = 23` (flutter_secure_storage e local_auth).
2. `MainActivity`: substitua pelo arquivo `android_setup/MainActivity.kt` (ajuste o `package`).
3. `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
   <application android:allowBackup="false" android:fullBackupContent="false" ...>
   ```
   `allowBackup=false` é essencial: o banco criptografado não pode ser restaurado sem a chave (que fica no Keystore).
4. `res/values/styles.xml` e `res/values-night/styles.xml`: troque o `parent` de `LaunchTheme` e `NormalTheme` para `Theme.AppCompat.DayNight` (exigência do BiometricPrompt).

## Arquitetura (Clean Architecture)
```
lib/
├─ core/            # utilitários, tema, segurança (KeyManager, BiometricService), roteador
├─ domain/          # entidades, interfaces de repositório, casos de uso (Dart puro)
├─ data/            # SQLCipher, models, repositórios, CSV/XLSX, share/picker
└─ presentation/    # providers Riverpod, páginas, widgets
```
Dependências sempre apontam para dentro: presentation → domain ← data.
**Riverpod** foi escolhido por DI tipada, providers derivados (mês/semana/filtros → consulta) e autoDispose.

## Fluxo de segurança
1. App abre em `/lock` (nenhuma rota de dados existe sem biometria).
2. `BiometricService` exige impressão digital (`biometricOnly`).
3. Só então `KeyManager` lê a chave AES-256 do Keystore e `AppDatabase.open()` abre o SQLCipher.
4. Ao ir para segundo plano (ou "Bloquear agora"): UI trava, banco é fechado, nada fica aberto.

## Limitações conhecidas
- A chave no Keystore não é *amarrada* à biometria por hardware; o bloqueio é imposto pelo fluxo do app. Para exigir isso no nível do SO, use `biometric_storage`.
- Export CSV/XLSX sai do cofre em texto puro (o app avisa antes de exportar).
- Importação não detecta duplicatas (reimportar o mesmo arquivo duplica lançamentos).
- Código escrito sem compilador disponível no ambiente de geração: rode `flutter analyze` e ajuste detalhes de versão de pacotes se necessário.
