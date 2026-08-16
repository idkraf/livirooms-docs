import 'package:flutter/material.dart';

/// Maps the icon keys used by the mockups onto Material icons.
///
/// The designs use custom illustrated glyphs (red beds, grey line icons for
/// building facilities). Until those assets land, these are the closest
/// Material equivalents; swap the body for `ImageIcon(AssetImage(...))` once
/// the icon set is exported.
class DetailIcons {
  DetailIcons._();

  static const Map<String, IconData> _byKey = {
    // Unit spec strip
    'furnished': Icons.weekend_rounded,
    'bedroom': Icons.king_bed_rounded,
    'bathroom': Icons.bathtub_rounded,
    'size': Icons.crop_free_rounded,
    'electricity': Icons.bolt_rounded,

    // Beds
    'king_bed': Icons.king_bed_rounded,
    'single_bed': Icons.single_bed_rounded,

    // Building facilities
    'pool': Icons.pool_rounded,
    'security': Icons.videocam_outlined,
    'access_card': Icons.badge_outlined,
    'elevator': Icons.elevator_outlined,
    'gym': Icons.fitness_center_rounded,
    'parking': Icons.local_parking_rounded,
    'minimarket': Icons.local_convenience_store_outlined,
    'cafe': Icons.local_cafe_outlined,
    'playground': Icons.child_friendly_outlined,
    'basketball': Icons.sports_basketball_outlined,
    'tennis': Icons.sports_tennis_outlined,

    // Room furniture
    'water_heater': Icons.water_damage_outlined,
    'kitchen_utensil': Icons.restaurant_rounded,
    'washing_machine': Icons.local_laundry_service_outlined,
    'ac': Icons.ac_unit_rounded,
    'tv': Icons.tv_rounded,
    'fridge': Icons.kitchen_outlined,
    'wifi': Icons.wifi_rounded,
    'wardrobe': Icons.door_sliding_outlined,
    'mirror': Icons.crop_portrait_rounded,
    'iron': Icons.iron_outlined,
    'lamp': Icons.light_outlined,

    // Info panels
    'info': Icons.priority_high_rounded,
    'cleaning': Icons.cleaning_services_rounded,
    'terms': Icons.info_outline_rounded,
    'money': Icons.payments_outlined,
    'building': Icons.apartment_rounded,
    'calendar': Icons.calendar_month_rounded,
    'car': Icons.directions_car_filled_outlined,
    'motorcycle': Icons.two_wheeler_outlined,
    'map': Icons.map_outlined,
    'place': Icons.storefront_outlined,
    'promo': Icons.local_offer_outlined,
  };

  static IconData of(String? key) =>
      _byKey[key] ?? _guess(key ?? '') ?? Icons.check_rounded;

  /// Fallback for free-text facility labels coming straight from the API
  /// (`properties.facilities` is an unstructured JSON array).
  static IconData? _guess(String raw) {
    final n = raw.toLowerCase();
    if (n.contains('pool') || n.contains('renang')) return Icons.pool_rounded;
    if (n.contains('gym') || n.contains('fitness')) {
      return Icons.fitness_center_rounded;
    }
    if (n.contains('security') || n.contains('keamanan')) {
      return Icons.videocam_outlined;
    }
    if (n.contains('lift') || n.contains('elevator')) {
      return Icons.elevator_outlined;
    }
    if (n.contains('card') || n.contains('kartu')) return Icons.badge_outlined;
    if (n.contains('wifi') || n.contains('internet')) return Icons.wifi_rounded;
    if (n.contains('ac') || n.contains('air cond')) return Icons.ac_unit_rounded;
    if (n.contains('tv')) return Icons.tv_rounded;
    if (n.contains('kitchen') || n.contains('dapur')) {
      return Icons.restaurant_rounded;
    }
    if (n.contains('wash') || n.contains('cuci') || n.contains('laundry')) {
      return Icons.local_laundry_service_outlined;
    }
    if (n.contains('heater')) return Icons.water_damage_outlined;
    if (n.contains('bed') || n.contains('kasur')) {
      return Icons.king_bed_rounded;
    }
    if (n.contains('park')) return Icons.local_parking_rounded;
    return null;
  }
}
