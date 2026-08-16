class HostInfo {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isVerified;
  final String? companyName;
  final String? joinedAt;
  final int totalProperties;

  HostInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isVerified,
    this.companyName,
    this.joinedAt,
    required this.totalProperties,
  });

  factory HostInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return HostInfo(
      id: data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}') ?? 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] as String?,
      isVerified: data['is_verified'] == true || data['is_verified'] == 1 || data['is_verified'] == '1',
      companyName: data['company_name'] as String?,
      joinedAt: data['joined_at'] as String?,
      totalProperties: data['total_properties'] is int
          ? data['total_properties'] as int
          : int.tryParse('${data['total_properties']}') ?? 0,
    );
  }
}
