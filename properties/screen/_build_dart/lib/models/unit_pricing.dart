enum RentalPeriod { daily, monthly, yearly }

extension RentalPeriodX on RentalPeriod {
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

class InclusionList {
  final List<String> included;
  final List<String> excluded;
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

class AddOn {
  final String id;
  final String name;
  final String? durationNote;
  final num? price;
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

class InstallmentPlan {
  final String id;
  final String name;
  final String? cadence;
  final int installments;
  final List<InstallmentEntry> entries;
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

  String get pickerLabel => cadence == null ? name : '$name ($cadence)';

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

class AppliedPromo {
  final String code;
  final num savings;

  const AppliedPromo({required this.code, required this.savings});

  factory AppliedPromo.fromJson(Map<String, dynamic> json) => AppliedPromo(
        code: '${json['code'] ?? ''}',
        savings: (json['savings'] as num?) ?? 0,
      );
}

class SummaryLine {
  final String label;
  final String value;
  final bool isDeduction;

  const SummaryLine(this.label, this.value, {this.isDeduction = false});
}

class UnitPricing {
  final RentalPeriod period;
  final String propertyName;
  final String? thumbnailUrl;
  final int bedrooms;
  final int bathrooms;
  final DateTime checkIn;
  final DateTime checkOut;
  final int duration;
  final List<int> durationOptions;
  final num basePrice;
  final num serviceFee;
  final InclusionList inclusions;
  final List<SpecialPriceTier> specialPrices;
  final List<AddOn> addOns;
  final List<InstallmentPlan> plans;
  final AppliedPromo? promo;
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

  String get stayRange =>
      '${_fmtDate(checkIn)} - ${_fmtDate(checkOut)}';

  String get durationText => '$duration ${period.unitNoun}';

  String durationOptionText(int value) => '$value ${period.unitNoun}';

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

String _fmtDate(DateTime d) =>
    '${d.day} ${_month(d.month)} ${d.year}';

String _month(int m) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  return names[m - 1];
}
