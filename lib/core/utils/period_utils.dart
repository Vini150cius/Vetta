/// Intervalo [start, end) — `end` é exclusivo.
class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);
}

class PeriodUtils {
  PeriodUtils._();

  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateRange month(DateTime ref) => DateRange(
      DateTime(ref.year, ref.month), DateTime(ref.year, ref.month + 1));

  static DateRange year(int y) => DateRange(DateTime(y), DateTime(y + 1));

  /// Semanas do mês em blocos fixos: 1–7, 8–14, 15–21, 22–28, 29–fim.
  /// (Determinístico e fácil de entender, ao contrário de semanas ISO que cruzam meses.)
  static List<DateRange> weeksOfMonth(DateTime ref) {
    final lastDay = DateTime(ref.year, ref.month + 1, 0).day;
    final weeks = <DateRange>[];
    for (var s = 1; s <= lastDay; s += 7) {
      final e = s + 7 > lastDay + 1 ? lastDay + 1 : s + 7;
      weeks.add(DateRange(
          DateTime(ref.year, ref.month, s), DateTime(ref.year, ref.month, e)));
    }
    return weeks;
  }
}
