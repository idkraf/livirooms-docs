/// Formatting helpers that reproduce the exact strings shown in the mockups.
///
/// The mockups render money as `IDR 14,100,000` (ISO code + comma grouping),
/// not as the app-wide `Rp 14.100.000` produced by
/// `flutter/lib/utils/formatters.dart`. Dates read `16 Agt 2026` — note the
/// `Agt` abbreviation, which `intl`'s `id_ID` locale spells `Agu`.
///
/// Deliberately dependency-free (no `intl`) so this folder compiles on its own.
class Fmt {
  Fmt._();

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agt',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// `14100000` → `IDR 14,100,000`.
  static String idr(num? amount) => 'IDR ${grouped(amount)}';

  /// `14100000` → `14,100,000` (no currency prefix).
  static String grouped(num? amount) {
    final rounded = (amount ?? 0).round();
    final negative = rounded < 0;
    final digits = rounded.abs().toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return negative ? '-${out.toString()}' : out.toString();
  }

  /// A negative money line as the summary card renders it: `- IDR 50,000`.
  static String idrDeduction(num? amount) => '- ${idr((amount ?? 0).abs())}';

  /// `DateTime(2026, 8, 16)` → `16 Agt 2026`.
  static String date(DateTime? d) =>
      d == null ? '-' : '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  /// `16 Agt 2026 - 17 Agt 2026`.
  static String dateRange(DateTime? from, DateTime? to) =>
      '${date(from)} - ${date(to)}';

  /// `5.0` → `5.0`; `5` → `5.0`.
  static String score(num? value) => (value ?? 0).toStringAsFixed(1);

  /// Masks a reviewer name the way the review sheet does:
  /// `Muhammad Cahyo` → `M******* C****`.
  static String maskName(String name) => name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w.length == 1 ? w : '${w[0]}${'*' * (w.length - 1)}')
      .join(' ');
}
