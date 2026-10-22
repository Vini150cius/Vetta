enum TxType { income, expense }

/// Lançamento financeiro. `planned = true` representa algo FUTURO/previsto
/// (ex.: fatura que vence mês que vem); só entra no saldo real quando marcado como realizado.
class FinTransaction {
  const FinTransaction({
    this.id,
    required this.type,
    required this.amountCents,
    this.description = '',
    required this.category,
    this.place = '',
    required this.date,
    this.planned = false,
  });

  final int? id;
  final TxType type;
  final int amountCents; // sempre positivo; o sinal vem de [type]
  final String description;
  final String category;
  final String place;
  final DateTime date;
  final bool planned;

  FinTransaction copyWith({
    TxType? type,
    int? amountCents,
    String? description,
    String? category,
    String? place,
    DateTime? date,
    bool? planned,
  }) =>
      FinTransaction(
        id: id,
        type: type ?? this.type,
        amountCents: amountCents ?? this.amountCents,
        description: description ?? this.description,
        category: category ?? this.category,
        place: place ?? this.place,
        date: date ?? this.date,
        planned: planned ?? this.planned,
      );
}
