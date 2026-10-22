/// Movimentação do "dinheiro guardado": positivo = guardou, negativo = retirou.
class SavingsEntry {
  const SavingsEntry(
      {this.id, required this.amountCents, this.note = '', required this.date});

  final int? id;
  final int amountCents;
  final String note;
  final DateTime date;
}
