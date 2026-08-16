import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../utils/detail_icons.dart';
import 'detail_primitives.dart';

/// Title, `Apartment` tag + area pin, and the icon spec strip —
/// the block directly under the gallery in `property_detail_screen_1.jpg`.
class DetailOverviewBlock extends StatelessWidget {
  final PropertyDetail detail;

  const DetailOverviewBlock({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.fromLTRB(DT.gutter, 22, DT.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.title, style: DT.screenTitle),
          const SizedBox(height: 20),
          Row(
            children: [
              if (detail.typeLabel.isNotEmpty) ...[
                ToneTag(label: detail.typeLabel),
                const SizedBox(width: 14),
              ],
              const Icon(Icons.location_on_outlined,
                  size: 22, color: DT.textPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  detail.areaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: DT.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (detail.specs.isNotEmpty) ...[
            const SizedBox(height: 22),
            DetailSpecStrip(specs: detail.specs),
          ],
        ],
      ),
    );
  }
}

/// `Full Furnished · 3 · 2 · 100m2 · 5500 W`.
///
/// Scrolls horizontally rather than wrapping — a 4BR unit with a long
/// furnishing label would otherwise overflow on a narrow screen.
class DetailSpecStrip extends StatelessWidget {
  final List<SpecItem> specs;

  const DetailSpecStrip({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: [
          for (final spec in specs)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Row(
                children: [
                  Icon(DetailIcons.of(spec.iconKey),
                      size: 21, color: DT.brand),
                  const SizedBox(width: 7),
                  Text(
                    spec.label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: DT.textPrimary,
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
