import '../utils/fmt.dart';

/// Domain models for the "Rincian Unit" screen (mockups 16–24).
///
/// Maps onto `property_prices` (`price_type` = daily|weekly|monthly|yearly,
/// `amount`, `service_fee`, `cleaning_fee`, `deposit`) plus the pieces the
/// backend does not model yet: inclusion lists, tiered long-stay discounts,
/// add-ons, promo codes and yearly installment plans.

// ------------------------------------------------------------------ period

/// The three segments of the top control. `weekly` exists in the DB enum but
/// the mockups expose only these three.
enum RentalPeriod { daily, monthly, yearly }

extension RentalPeriodX on RentalPeriod {
  /// Segment caption.
  String get label {
    switch (this) {
      case RentalPeriod.daily:
        return 'Harian';
      case RentalPeriod.monthly:
        return 'Bulanan';
      case RentalPeriod.yearly:
        return 'Tahunan';
    }
  }

  /// Noun used in `Total harga untuk 1 malam` / `1 bulan` / `1 tahun`.
  String get unitNoun {
    switch (this) {
      case RentalPeriod.daily:
        return 'malam';
      case RentalPeriod.monthly:
        return 'bulan';
      case RentalPeriod.yearly:
        return 'tahun';
    }
  }

  /// Label above the duration dropdown. `null` for daily — the daily card
  /// has no duration selector, only the date range.
  String? get durationLabel {
    switch (this) {
      case RentalPeriod.daily:
        return null;
      case RentalPeriod.monthly:
        return 'Bulan';
      case RentalPeriod.yearly:
        return 'Tahun';
    }
  }

  /// `price_type` value sent to the API.
  String get apiValue {
    switch (this) {
      case RentalPeriod.daily:
        return 'daily';
      case RentalPeriod.monthly:
        return 'monthly';
      case RentalPeriod.yearly:
        return 'yearly';
    }
  }

  static RentalPeriod fromApi(String? raw) {
    switch (raw) {
      case 'monthly':
        return RentalPeriod.monthly;
      case 'yearly':
        return RentalPeriod.yearly;
      default:
        return RentalPeriod.daily;
    }
  }
}

// --------------------------------------------------------------- inclusions

/// The `Termasuk` / `Tidak Termasuk` table. The yearly tab supplies only
/// `excluded`, which collapses the table to a single full-width column.
class InclusionList {
  final List<String> included;
  final List<String> excluded;

  /// Rows shown before the `tampilkan selengkapnya` link expands the table.
  final int collapsedRows;

  const InclusionList({
    this.included = const [],
    this.excluded = const [],
    this.collapsedRows = 5,
  });

  bool get isTwoColumn => included.isNotEmpty && excluded.isNotEmpty;

  bool get isExpandable =>
      included.length > collapsedRows || excluded.length > collapsedRows;

  factory InclusionList.fromJson(Map<String, dynamic> json) => InclusionList(
        included: _strings(json['included']),
        excluded: _strings(json['excluded']),
      );
}

/// One row of `Harga Spesial (Diskon):` — `4+ day(s)` → `5%`.
class SpecialPriceTier {
  final int minNights;
  final double discountPercent;

  const SpecialPriceTier({
    required this.minNights,
    required this.discountPercent,
  });

  String get label => '$minNights+ day(s)';

  String get discountLabel =>
      '${discountPercent == discountPercent.roundToDouble() ? discountPercent.round() : discountPercent}%';

  factory SpecialPriceTier.fromJson(Map<String, dynamic> json) =>
      SpecialPriceTier(
        minNights: json['min_nights'] as int? ?? 0,
        discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
      );
}

// ------------------------------------------------------------------ add-ons

/// A checkbox row of the `Pilih Add On` card.
class AddOn {
  final String id;
  final String name;

  /// Duration suffix rendered in parentheses — `1 Malam`, `1 Bulan`.
  final String? durationNote;

  /// `null` renders no price (the mockup's unchecked "Dust Mite Cleaning
  /// Service" row shows only the info icon).
  final num? price;

  /// Body of the tooltip behind the ⓘ icon.
  final String info;
  final bool selectedByDefault;

  const AddOn({
    required this.id,
    required this.name,
    this.durationNote,
    this.price,
    this.info = '',
    this.selectedByDefault = false,
  });

  String get displayName =>
      durationNote == null ? name : '$name ($durationNote)';

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
        id: '${json['id'] ?? json['name'] ?? ''}',
        name: '${json['name'] ?? ''}',
        durationNote: json['duration_note'] as String?,
        price: json['price'] as num?,
        info: '${json['info'] ?? ''}',
        selectedByDefault: json['selected'] == true,
      );
}

// ------------------------------------------------------------- installments

/// One row of the `Jadwal Pembayaran` table.
class InstallmentEntry {
  final DateTime date;
  final num amount;

  const InstallmentEntry({required this.date, required this.amount});

  factory InstallmentEntry.fromJson(Map<String, dynamic> json) =>
      InstallmentEntry(
        date: DateTime.tryParse('${json['date']}') ?? DateTime(2026),
        amount: (json['amount'] as num?) ?? 0,
      );
}

/// An option of the `Cicilan / Rencana pembayaran` dropdown.
class InstallmentPlan {
  final String id;

  /// `Bayar Penuh`, `Cicilan 12x`.
  final String name;

  /// `bayar setiap bulan` — appended in parentheses inside the picker.
  final String? cadence;

  /// 1 for `Bayar Penuh`.
  final int installments;

  final List<InstallmentEntry> entries;

  /// The `Total` row of the schedule. Kept explicit rather than summed so it
  /// can carry the backend's own rounding (see README — the mockup's printed
  /// total and its visible rows do not add up).
  final num? total;

  const InstallmentPlan({
    required this.id,
    required this.name,
    this.cadence,
    this.installments = 1,
    this.entries = const [],
    this.total,
  });

  bool get isFullPayment => installments <= 1;

  num get scheduleTotal =>
      total ?? entries.fold<num>(0, (sum, e) => sum + e.amount);

  /// Label inside the picker list: `Cicilan 12x (bayar setiap bulan)`.
  String get pickerLabel => cadence == null ? name : '$name ($cadence)';

  /// Label inside the closed dropdown: `Cicilan 12x (IDR 135,217,500)`.
  String get fieldLabel =>
      isFullPayment ? name : '$name (${Fmt.idr(scheduleTotal)})';

  /// Gross amount of the first schedule row — service fee included. The
  /// `Ringkasan` card splits it back out as `Pembayaran Pertama` +
  /// `Service Fee`.
  num get firstDue => entries.isEmpty ? scheduleTotal : entries.first.amount;

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) =>
      InstallmentPlan(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        cadence: json['cadence'] as String?,
        installments: json['installments'] as int? ?? 1,
        entries: (json['entries'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(InstallmentEntry.fromJson)
            .toList(),
        total: json['total'] as num?,
      );
}

// -------------------------------------------------------------------- promo

class AppliedPromo {
  final String code;

  /// Amount deducted — rendered green as `Anda menghemat - IDR 50,000`.
  final num savings;

  const AppliedPromo({required this.code, required this.savings});

  String get savingsLabel => 'Anda menghemat ${Fmt.idrDeduction(savings)}';

  factory AppliedPromo.fromJson(Map<String, dynamic> json) => AppliedPromo(
        code: '${json['code'] ?? ''}',
        savings: (json['savings'] as num?) ?? 0,
      );
}

// ------------------------------------------------------------ summary rows

/// A single `label ... value` line of the `Ringkasan` card.
class SummaryLine {
  final String label;
  final String value;

  /// Deductions render red-free but negative-signed; the mockup keeps them
  /// in the default ink colour, so this only affects the sign.
  final bool isDeduction;

  const SummaryLine(this.label, this.value, {this.isDeduction = false});
}

// ---------------------------------------------------------------- aggregate

/// Everything one segment of the Rincian Unit screen needs.
class UnitPricing {
  final RentalPeriod period;

  // unit card
  final String propertyName;
  final String? thumbnailUrl;
  final int bedrooms;
  final int bathrooms;
  final DateTime checkIn;
  final DateTime checkOut;

  /// Selected duration in `period` units (nights for daily).
  final int duration;

  /// Options offered by the duration dropdown, e.g. `[1, 2, 3, 6, 12]`.
  final List<int> durationOptions;

  // money
  /// `Total harga untuk N malam/bulan/tahun`.
  final num basePrice;
  final num serviceFee;

  final InclusionList inclusions;
  final List<SpecialPriceTier> specialPrices;
  final List<AddOn> addOns;
  final List<InstallmentPlan> plans;
  final AppliedPromo? promo;

  /// Footnote under the installment schedule.
  final String scheduleNote;

  const UnitPricing({
    required this.period,
    required this.propertyName,
    required this.checkIn,
    required this.checkOut,
    this.thumbnailUrl,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.duration = 1,
    this.durationOptions = const [1],
    this.basePrice = 0,
    this.serviceFee = 0,
    this.inclusions = const InclusionList(),
    this.specialPrices = const [],
    this.addOns = const [],
    this.plans = const [],
    this.promo,
    this.scheduleNote = '',
  });

  /// `16 Agt 2026 - 17 Agt 2026`.
  String get stayRange => Fmt.dateRange(checkIn, checkOut);

  /// Text of the duration dropdown — `1 bulan`.
  String get durationText => '$duration ${period.unitNoun}';

  String durationOptionText(int value) => '$value ${period.unitNoun}';

  /// Only the yearly tab offers installments.
  bool get supportsInstallments =>
      period == RentalPeriod.yearly && plans.isNotEmpty;

  factory UnitPricing.fromJson(Map<String, dynamic> json) => UnitPricing(
        period: RentalPeriodX.fromApi(json['price_type'] as String?),
        propertyName: '${json['property_name'] ?? ''}',
        thumbnailUrl: json['thumbnail'] as String?,
        bedrooms: json['bedrooms'] as int? ?? 0,
        bathrooms: json['bathrooms'] as int? ?? 0,
        checkIn: DateTime.tryParse('${json['check_in']}') ?? DateTime(2026),
        checkOut: DateTime.tryParse('${json['check_out']}') ?? DateTime(2026),
        duration: json['duration'] as int? ?? 1,
        durationOptions: (json['duration_options'] as List<dynamic>? ?? const [])
            .whereType<num>()
            .map((e) => e.toInt())
            .toList(),
        basePrice: (json['base_price'] as num?) ?? 0,
        serviceFee: (json['service_fee'] as num?) ?? 0,
        inclusions: json['inclusions'] is Map<String, dynamic>
            ? InclusionList.fromJson(json['inclusions'] as Map<String, dynamic>)
            : const InclusionList(),
        specialPrices: (json['special_prices'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SpecialPriceTier.fromJson)
            .toList(),
        addOns: (json['add_ons'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AddOn.fromJson)
            .toList(),
        plans: (json['payment_plans'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(InstallmentPlan.fromJson)
            .toList(),
        promo: json['promo'] is Map<String, dynamic>
            ? AppliedPromo.fromJson(json['promo'] as Map<String, dynamic>)
            : null,
        scheduleNote: '${json['schedule_note'] ?? ''}',
      );

  UnitPricing copyWith({
    int? duration,
    AppliedPromo? promo,
    bool clearPromo = false,
  }) =>
      UnitPricing(
        period: period,
        propertyName: propertyName,
        thumbnailUrl: thumbnailUrl,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        checkIn: checkIn,
        checkOut: checkOut,
        duration: duration ?? this.duration,
        durationOptions: durationOptions,
        basePrice: basePrice,
        serviceFee: serviceFee,
        inclusions: inclusions,
        specialPrices: specialPrices,
        addOns: addOns,
        plans: plans,
        promo: clearPromo ? null : (promo ?? this.promo),
        scheduleNote: scheduleNote,
      );
}

List<String> _strings(dynamic v) =>
    v is List ? v.map((e) => '$e').toList() : const <String>[];
