import '../models/host_info.dart';
import '../models/insurance_plan.dart';
import '../models/paginated.dart';
import '../models/property.dart';
import '../models/review.dart';
import '../models/unit_pricing.dart';
import 'api_client.dart';

class PropertyService {
  PropertyService({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  Future<Paginated<Property>> search({
    String? q,
    int? cityId,
    String? propertyType,
    int? guests,
    int? bedrooms,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
  }) async {
    final res = await _api.get('properties', auth: false, query: {
      'q': q,
      'city_id': cityId,
      'property_type': propertyType,
      'guests': guests,
      'bedrooms': bedrooms,
      'min_price': minPrice,
      'max_price': maxPrice,
      'sort': sort,
      'page': page,
    });
    return Paginated.fromResponse(res, Property.fromJson);
  }

  Future<Property> detail(int id) async {
    final res = await _api.get('properties/$id', auth: false);
    return Property.fromJson(res.dataMap);
  }

  Future<Property> detailRich(int id) async {
    final res = await _api.get('properties/$id/detail', auth: false);
    return Property.fromJson(res.dataMap);
  }

  Future<UnitPricing> pricing(int propertyId, {String? priceType}) async {
    final query = <String, dynamic>{};
    if (priceType != null) query['price_type'] = priceType;
    final res = await _api.get(
      'properties/$propertyId/pricing',
      auth: false,
      query: query.isEmpty ? null : query,
    );
    return UnitPricing.fromJson(res.dataMap);
  }

  Future<Paginated<Review>> reviews(int propertyId, {int page = 1}) async {
    final res = await _api.get(
      'properties/$propertyId/reviews',
      auth: false,
      query: {'page': page},
    );
    return Paginated.fromResponse(res, Review.fromJson);
  }

  Future<List<String>> availability(int propertyId,
      {String? from, String? to}) async {
    final res = await _api.get(
      'properties/$propertyId/availability',
      auth: false,
      query: {'from': from, 'to': to},
    );

    return res.dataObjects
        .where((e) => e['is_available'] == false)
        .map((e) => '${e['date']}')
        .where((d) => d.isNotEmpty && d != 'null')
        .toList();
  }

  Future<HostInfo> host(int propertyId) async {
    final res = await _api.get('properties/$propertyId/host', auth: false);
    return HostInfo.fromJson(res.dataMap);
  }

  Future<List<InsurancePlan>> getInsurancePlans() async {
    final res = await _api.get('insurance/plans', auth: false);
    return res.dataObjects.map(InsurancePlan.fromJson).toList();
  }
}



