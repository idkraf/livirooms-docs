import '../models/property.dart';
import 'api_client.dart';

class WishlistService {
  WishlistService({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  Future<List<Property>> list() async {
    final res = await _api.get('wishlists');
    return res.dataObjects.map(Property.fromJson).toList();
  }

  /// Toggles the wishlist state; returns `true` if the property is now saved.
  /// The server decides the resulting state, so the UI never has to guess.
  Future<bool> toggle(int propertyId) async {
    final res = await _api.post('wishlists/$propertyId');
    return res.dataMap['wishlisted'] as bool? ?? true;
  }

  Future<void> remove(int propertyId) async {
    await _api.delete('wishlists/$propertyId');
  }
}
