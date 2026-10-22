import 'fin_transaction.dart';

/// Critérios combinados com AND (ex.: categoria "Eletrônicos" E local "Shopee").
/// Dentro de cada conjunto vale OR (ex.: "Eletrônicos" OU "Lazer").
class TransactionFilter {
  const TransactionFilter({
    this.from,
    this.to,
    this.categories = const {},
    this.places = const {},
    this.type,
    this.planned,
  });

  final DateTime? from; // inclusivo
  final DateTime? to; // exclusivo
  final Set<String> categories;
  final Set<String> places;
  final TxType? type;
  final bool? planned;

  bool get hasAttributeFilters =>
      categories.isNotEmpty || places.isNotEmpty || type != null;

  TransactionFilter copyWith({
    DateTime? from,
    DateTime? to,
    Set<String>? categories,
    Set<String>? places,
    TxType? type,
    bool clearType = false,
    bool? planned,
  }) =>
      TransactionFilter(
        from: from ?? this.from,
        to: to ?? this.to,
        categories: categories ?? this.categories,
        places: places ?? this.places,
        type: clearType ? null : (type ?? this.type),
        planned: planned ?? this.planned,
      );
}
