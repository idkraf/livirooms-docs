import 'package:intl/intl.dart';

/// Shared formatting helpers (currency, dates) used across screens.
class Formatters {
  Formatters._();

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  static String rupiah(num? amount) => _rupiah.format(amount ?? 0);

  static String rupiahCompact(num? amount) => _compact.format(amount ?? 0);

  static String date(DateTime? d) =>
      d == null ? '-' : DateFormat('d MMM yyyy', 'id_ID').format(d);

  static String dateLong(DateTime? d) =>
      d == null ? '-' : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

  static String dateRange(DateTime? from, DateTime? to) {
    if (from == null || to == null) return '-';
    final f = DateFormat('d MMM', 'id_ID');
    return '${f.format(from)} - ${DateFormat('d MMM yyyy', 'id_ID').format(to)}';
  }

  static String time(DateTime? d) =>
      d == null ? '' : DateFormat('HH:mm', 'id_ID').format(d);

  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Monday-first, matching [DateTime.weekday] (1 = Monday … 7 = Sunday).
  static const List<String> _daysShort = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];

  /// `DateTime(2026, 8, 15)` → `15 Agt`.
  ///
  /// Hand-rolled instead of delegating to [DateFormat] for two reasons: `intl`'s
  /// `id_ID` locale abbreviates August as `Agu` where the hotel design says
  /// `Agt`, and `DateFormat` with an explicit locale throws unless
  /// `initializeDateFormatting` has run — `main()` calls it, a widget test does
  /// not. These two helpers therefore render identically in tests and in the app.
  static String dayMonthShort(DateTime? d) =>
      d == null ? '-' : '${d.day} ${_monthsShort[d.month - 1]}';

  /// `DateTime(2026, 8, 15)` → `Sab, 15 Agt`.
  static String weekdayDayMonthShort(DateTime? d) => d == null
      ? '-'
      : '${_daysShort[d.weekday - 1]}, ${dayMonthShort(d)}';

  /// Same as [dayMonthShort] but takes the `yyyy-MM-dd` strings the hotel search
  /// query carries. An unparseable value yields `-` rather than a slice of the
  /// raw string — `'2026-08-15'.substring(5)` used to render as `08-15`.
  static String isoDayMonthShort(String? iso) =>
      dayMonthShort(iso == null ? null : DateTime.tryParse(iso));

  /// Same as [weekdayDayMonthShort], from a `yyyy-MM-dd` string.
  static String isoWeekdayDayMonthShort(String? iso) =>
      weekdayDayMonthShort(iso == null ? null : DateTime.tryParse(iso));

  /// `DateTime(2026, 8, 14, 11, 57)` → `14 Agt 2026, 11.57`.
  ///
  /// The dot between hour and minute is the mockup's, not a typo: #36 prints the
  /// voucher validity as `Berlaku mulai 14 Agt 2026, 11.57 sampai 21 Agt 2026,
  /// 22.59`. Hand-rolled for the same two reasons as [dayMonthShort].
  static String dayMonthYearDotTime(DateTime? d) => d == null
      ? '-'
      : '${dayMonthShort(d)} ${d.year}, '
          '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

  /// `'15:00:00'` / `'15:00'` → `'15:00'`. The API sends hotel check-in and
  /// check-out as `TIME` strings with seconds; the card shows minutes.
  static String hourMinute(String? time) {
    if (time == null || time.length < 4) return '-';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }

  static String relative(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return date(d);
  }

  /// Maps backend status enums to human-friendly Indonesian labels.
  static String statusLabel(String status) {
    const map = {
      'waiting_payment': 'Menunggu Pembayaran',
      'waiting_confirmation': 'Menunggu Konfirmasi',
      'confirmed': 'Dikonfirmasi',
      'paid': 'Lunas',
      'waiting_checkin': 'Menunggu Check-in',
      'staying': 'Sedang Menginap',
      'checkin': 'Check-in',
      'completed': 'Selesai',
      'cancelled': 'Dibatalkan',
      'pending': 'Menunggu',
      'failed': 'Gagal',
      'active': 'Aktif',
      'inactive': 'Nonaktif',
      'maintenance': 'Maintenance',
      'approved': 'Disetujui',
      'rejected': 'Ditolak',
    };
    return map[status] ?? status;
  }

  static String paymentMethodLabel(String method) {
    switch (method) {
      case 'virtual_account':
        return 'Virtual Account';
      case 'qris':
        return 'QRIS';
      case 'ewallet':
        return 'E-Wallet';
      case 'credit_card':
        return 'Kartu Kredit';
      case 'paylater':
        return 'PayLater';
      default:
        return method;
    }
  }

  static String paymentStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Berhasil';
      case 'failed':
        return 'Gagal';
      case 'expired':
        return 'Kedaluwarsa';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return status;
    }
  }

  static String dateTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
