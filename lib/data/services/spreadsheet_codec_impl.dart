import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../core/utils/money.dart';
import '../../domain/entities/fin_transaction.dart';
import '../../domain/services/spreadsheet_codec.dart';

/// Layout (CSV e XLSX): Data | Tipo | Valor | Descricao | Categoria | Local | Status
/// CSV: UTF-8 com BOM e separador ";" — abre direto no Excel pt-BR; o Google Sheets
/// detecta sozinho. Na importação aceitamos ";" ou "," e valores "12,50" ou "12.50".
class SpreadsheetCodecImpl implements SpreadsheetCodec {
  static const _header = [
    'Data',
    'Tipo',
    'Valor',
    'Descricao',
    'Categoria',
    'Local',
    'Status'
  ];
  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Uint8List encode(List<FinTransaction> items, SpreadsheetFormat format) =>
      format == SpreadsheetFormat.csv ? _encodeCsv(items) : _encodeXlsx(items);

  @override
  List<FinTransaction> decode(Uint8List bytes, SpreadsheetFormat format) =>
      format == SpreadsheetFormat.csv ? _decodeCsv(bytes) : _decodeXlsx(bytes);

  // ---------- exportação ----------
  Uint8List _encodeCsv(List<FinTransaction> items) {
    final rows = <List<dynamic>>[
      _header,
      for (final t in items)
        [
          _dateFmt.format(t.date),
          t.type == TxType.income ? 'Receita' : 'Despesa',
          (t.amountCents / 100).toStringAsFixed(2).replaceAll('.', ','),
          t.description,
          t.category,
          t.place,
          t.planned ? 'Previsto' : 'Realizado',
        ],
    ];
    final text = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);
    return Uint8List.fromList(utf8.encode('\uFEFF$text'));
  }

  Uint8List _encodeXlsx(List<FinTransaction> items) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) excel.rename(defaultSheet, 'Transacoes');
    final sheet = excel['Transacoes'];
    sheet.appendRow(_header.map<CellValue>((h) => TextCellValue(h)).toList());
    for (final t in items) {
      sheet.appendRow(<CellValue>[
        TextCellValue(_dateFmt.format(t.date)),
        TextCellValue(t.type == TxType.income ? 'Receita' : 'Despesa'),
        DoubleCellValue(t.amountCents / 100),
        TextCellValue(t.description),
        TextCellValue(t.category),
        TextCellValue(t.place),
        TextCellValue(t.planned ? 'Previsto' : 'Realizado'),
      ]);
    }
    final bytes = excel.encode();
    if (bytes == null)
      throw const FormatException('Não foi possível gerar o arquivo XLSX.');
    return Uint8List.fromList(bytes);
  }

  // ---------- importação ----------
  List<FinTransaction> _decodeCsv(Uint8List bytes) {
    var text =
        utf8.decode(bytes, allowMalformed: true).replaceAll('\r\n', '\n');
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    final delimiter = text.split('\n').first.contains(';') ? ';' : ',';
    final rows = CsvToListConverter(
            fieldDelimiter: delimiter, eol: '\n', shouldParseNumbers: false)
        .convert(text);
    return _toTransactions(
        rows.map((r) => r.map((c) => c.toString()).toList()).toList());
  }

  List<FinTransaction> _decodeXlsx(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) throw const FormatException('Planilha vazia.');
    final sheet = excel.tables.values.first;
    return _toTransactions(sheet.rows
        .map((r) => r.map((c) => _cellText(c?.value)).toList())
        .toList());
  }

  static String _cellText(CellValue? v) {
    if (v == null) return '';
    if (v is DateCellValue) {
      return '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}';
    }
    if (v is TextCellValue) {
      // Em versões recentes do `excel`, o texto pode vir como TextSpan.
      final dynamic inner = (v as dynamic).value;
      return inner is String ? inner : '${(inner as dynamic).text ?? inner}';
    }
    return v.toString();
  }

  List<FinTransaction> _toTransactions(List<List<String>> rows) {
    if (rows.length < 2) return const [];
    final header = rows.first.map(_norm).toList();
    int col(String name) => header.indexOf(name);
    final iDate = col('data'), iType = col('tipo'), iAmount = col('valor');
    final iDesc = col('descricao'),
        iCat = col('categoria'),
        iPlace = col('local'),
        iStatus = col('status');
    if (iDate < 0 || iType < 0 || iAmount < 0) {
      throw const FormatException(
          'Cabeçalho inválido. Use: Data;Tipo;Valor;Descricao;Categoria;Local;Status');
    }
    String cell(List<String> r, int i) =>
        i >= 0 && i < r.length ? r[i].trim() : '';

    final out = <FinTransaction>[];
    for (var line = 1; line < rows.length; line++) {
      final r = rows[line];
      if (r.every((c) => c.trim().isEmpty)) continue;
      final date = _parseDate(cell(r, iDate));
      final cents = Money.parseCents(cell(r, iAmount));
      if (date == null || cents == null || cents == 0) {
        throw FormatException('Linha ${line + 1} inválida (data ou valor).');
      }
      final type = _norm(cell(r, iType));
      final status = _norm(cell(r, iStatus));
      final category = cell(r, iCat);
      out.add(FinTransaction(
        type: const {'receita', 'ganho', 'entrada'}.contains(type)
            ? TxType.income
            : TxType.expense,
        amountCents: cents.abs(),
        description: cell(r, iDesc),
        category: category.isEmpty ? 'Outros' : category,
        place: cell(r, iPlace),
        date: date,
        planned: status.startsWith('prev') ||
            status.startsWith('plan') ||
            status.startsWith('futur'),
      ));
    }
    return out;
  }

  static String _norm(String s) {
    const from = 'áàâãéêíóôõúç';
    const to = 'aaaaeeiooouc';
    var r = s.trim().toLowerCase();
    for (var i = 0; i < from.length; i++) {
      r = r.replaceAll(from[i], to[i]);
    }
    return r;
  }

  static DateTime? _parseDate(String s) {
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(s);
    if (m != null)
      return DateTime(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
    final iso = DateTime.tryParse(s);
    return iso == null ? null : DateTime(iso.year, iso.month, iso.day);
  }
}
