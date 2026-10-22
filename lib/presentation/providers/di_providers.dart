import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/biometric_service.dart';
import '../../core/security/key_manager.dart';
import '../../data/datasources/app_database.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/services/file_exchange_service.dart';
import '../../data/services/spreadsheet_codec_impl.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/services/spreadsheet_codec.dart';

/// Injeção de dependências: a UI só enxerga interfaces do domínio.
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final keyManagerProvider = Provider<KeyManager>((ref) => KeyManager());
final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());
final fileExchangeProvider =
    Provider<FileExchangeService>((ref) => FileExchangeService());
final spreadsheetCodecProvider =
    Provider<SpreadsheetCodec>((ref) => SpreadsheetCodecImpl());

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final savingsRepositoryProvider = Provider<SavingsRepository>(
  (ref) => SavingsRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.watch(appDatabaseProvider)),
);
