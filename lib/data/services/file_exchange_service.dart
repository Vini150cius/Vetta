import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/services/spreadsheet_codec.dart';

/// ATENÇÃO: exportar tira os dados do cofre criptografado — o arquivo gerado é texto puro.
/// Por isso gravamos só em cache temporário e apagamos sobras no próximo desbloqueio.
class FileExchangeService {
  static const _prefix = 'financas_export_';

  Future<void> shareBytes(String fileName, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)]);
    // Não apagamos aqui: no Android o share retorna antes do app destino ler o arquivo.
  }

  Future<void> purgeExports() async {
    final dir = await getTemporaryDirectory();
    await for (final e in dir.list()) {
      if (e is File && p.basename(e.path).startsWith(_prefix)) {
        await e.delete();
      }
    }
  }

  Future<({Uint8List bytes, SpreadsheetFormat format})?>
      pickSpreadsheet() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx'],
      withData: true,
    );
    final file = res?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    final isXlsx = (file.extension ?? '').toLowerCase() == 'xlsx';
    return (
      bytes: bytes,
      format: isXlsx ? SpreadsheetFormat.xlsx : SpreadsheetFormat.csv
    );
  }
}
