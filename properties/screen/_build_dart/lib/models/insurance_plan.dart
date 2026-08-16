class InsurancePlan {
  final int id;
  final String name;
  final String code;
  final String premiumType; // 'fixed_per_night' | 'percentage'
  final double premiumAmount;
  final double coverageAmount;
  final Map<String, dynamic>? coverageDetails;
  final String? providerName;

  InsurancePlan({
    required this.id,
    required this.name,
    required this.code,
    required this.premiumType,
    required this.premiumAmount,
    required this.coverageAmount,
    this.coverageDetails,
    this.providerName,
  });

  factory InsurancePlan.fromJson(Map<String, dynamic> json) => InsurancePlan(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        code: json['code'] as String? ?? '',
        premiumType: json['premium_type'] as String? ?? 'fixed_per_night',
        premiumAmount: _toDouble(json['premium_amount']),
        coverageAmount: _toDouble(json['coverage_amount']),
        coverageDetails: json['coverage_details'] is Map
            ? Map<String, dynamic>.from(json['coverage_details'] as Map)
            : null,
        providerName: (json['provider'] is Map)
            ? json['provider']['name'] as String?
            : null,
      );

  /// Calculate premium for a given booking
  double calculatePremium(int nights, int guests, {double roomSubtotal = 0}) {
    if (premiumType == 'percentage') {
      return (roomSubtotal * (premiumAmount / 100));
    }
    // Fixed per night per guest — matches Laravel: premium_amount * nights * guests
    return premiumAmount * nights * guests;
  }

  /// User-facing label for the premium price
  String premiumLabel(int nights, int guests, {double roomSubtotal = 0}) {
    final p = calculatePremium(nights, guests, roomSubtotal: roomSubtotal);
    return 'Rp ${p.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
