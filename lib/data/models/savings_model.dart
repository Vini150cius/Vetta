import '../../domain/entities/savings_entry.dart';

class SavingsModel {
  SavingsModel._();

  static Map<String, Object?> toMap(SavingsEntry e) => {
        if (e.id != null) 'id': e.id,
        'amount_cents': e.amountCents,
        'note': e.note,
        'date': e.date.millisecondsSinceEpoch,
      };

  static SavingsEntry fromMap(Map<String, Object?> m) => SavingsEntry(
        id: m['id'] as int,
        amountCents: m['amount_cents'] as int,
        note: m['note'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      );
}
