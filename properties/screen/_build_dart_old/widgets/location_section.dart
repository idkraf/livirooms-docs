import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../utils/detail_icons.dart';
import 'detail_primitives.dart';

/// `Peta Lokasi` — the third anchored section
/// (`property_detail_screen_5_tab_location.jpg`).
///
/// No maps package is installed in `flutter/pubspec.yaml`
/// (`google_maps_flutter` is absent), so this renders a static preview image
/// and hands the tap back through [onOpenMap] — wire it to `url_launcher`
/// with a `https://maps.google.com/?q=lat,lng` URL, the same approach as
/// `_mapPlaceholder()` in the current `property_detail_screen.dart`.
class LocationSection extends StatelessWidget {
  final PropertyDetail detail;
  final VoidCallback? onOpenMap;

  const LocationSection({super.key, required this.detail, this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Peta Lokasi',
            padding: EdgeInsets.fromLTRB(DT.gutter, 20, DT.gutter, 12),
          ),
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onOpenMap,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(DT.cardRadius),
                        ),
                        child: NetImage(
                          url: detail.mapPreviewUrl,
                          height: 190,
                          width: double.infinity,
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            size: 42,
                            color: DT.brand,
                            shadows: [
                              Shadow(
                                color: DT.fade(Colors.black, .25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DT.gutter),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DT.fill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.place_outlined,
                            size: 22, color: DT.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(detail.address, style: DT.bodyMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The `Sekitar` grid at the bottom of the Deskripsi card — two columns of
/// pastel badges cycling `DT.pastels`.
class NearbyGrid extends StatelessWidget {
  final List<NearbyPlace> places;

  const NearbyGrid({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < places.length; start += 2) {
      final left = places[start];
      final right = start + 1 < places.length ? places[start + 1] : null;
      rows.add(Padding(
        padding: EdgeInsets.only(top: start == 0 ? 0 : 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Place(place: left, tone: start)),
            const SizedBox(width: 12),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : _Place(place: right, tone: start + 1),
            ),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _Place extends StatelessWidget {
  final NearbyPlace place;
  final int tone;

  const _Place({required this.place, required this.tone});

  @override
  Widget build(BuildContext context) {
    final toneIndex = place.tone != 0 ? place.tone : tone;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftIconBadge(
          icon: DetailIcons.of(place.iconKey),
          fill: DT.pastelFill(toneIndex),
          glyph: DT.pastelGlyph(toneIndex),
          size: 34,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              place.name,
              style: const TextStyle(
                fontSize: 14,
                height: 1.3,
                color: DT.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
