import '../../domain/entities/fin_transaction.dart';

/// Conversão entidade <-> linha do SQLite (o domínio não conhece nomes de colunas).
class TransactionModel {
  TransactionModel._();

  static Map<String, Object?> toMap(FinTransaction t) => {
        if (t.id != null) 'id': t.id,
        'type': t.type.index,
        'amount_cents': t.amountCents,
        'description': t.description,
        'category': t.category,
        'place': t.place,
        'date': t.date.millisecondsSinceEpoch,
        'planned': t.planned ? 1 : 0,
      };

  static FinTransaction fromMap(Map<String, Object?> m) => FinTransaction(
        id: m['id'] as int,
        type: TxType.values[m['type'] as int],
        amountCents: m['amount_cents'] as int,
        description: m['description'] as String,
        category: m['category'] as String,
        place: m['place'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        planned: (m['planned'] as int) == 1,
      );
}
