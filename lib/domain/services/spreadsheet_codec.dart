import 'dart:typed_data';

import '../entities/fin_transaction.dart';

enum SpreadsheetFormat { csv, xlsx }

/// Porta (interface) implementada na camada de dados; o domínio não conhece `csv`/`excel`.
abstract class SpreadsheetCodec {
  Uint8List encode(List<FinTransaction> items, SpreadsheetFormat format);

  /// Lança [FormatException] com mensagem amigável se o arquivo for inválido.
  List<FinTransaction> decode(Uint8List bytes, SpreadsheetFormat format);
}
