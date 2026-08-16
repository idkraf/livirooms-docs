import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import 'detail_primitives.dart';
import 'location_section.dart';

/// `Pengantar` — the short teaser card that opens the Details section
/// (`property_detail_screen_4_tab_details.jpg`).
class IntroCard extends StatelessWidget {
  final String intro;

  const IntroCard({super.key, required this.intro});

  @override
  Widget build(BuildContext context) {
    if (intro.isEmpty) return const SizedBox.shrink();
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: TitledCard(
        title: 'Pengantar',
        child: Text(intro, style: DT.bodyMuted),
      ),
    );
  }
}

/// `Deskripsi` + `Sekitar` — the fourth anchored section
/// (`property_detail_screen_6.jpg`).
///
/// The body is clamped to [collapsedLines]; `Lihat Semua` opens the draggable
/// bottom sheet in `sheets/description_sheet.dart`
/// (`..._6_show_bottom_sheet_descripton.jpeg`).
class DescriptionCard extends StatelessWidget {
  final PropertyDetail detail;
  final VoidCallback? onSeeAll;
  final int collapsedLines;

  const DescriptionCard({
    super.key,
    required this.detail,
    this.onSeeAll,
    this.collapsedLines = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 20),
      child: TitledCard(
        title: 'Deskripsi',
        actionLabel: 'Lihat Semua',
        onAction: onSeeAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.description,
              maxLines: collapsedLines,
              overflow: TextOverflow.ellipsis,
              style: DT.bodyMuted,
            ),
            if (detail.nearbyPlaces.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: DT.divider),
              const SizedBox(height: 16),
              const Text('Sekitar', style: DT.cardTitle),
              const SizedBox(height: 14),
              NearbyGrid(places: detail.nearbyPlaces),
            ],
          ],
        ),
      ),
    );
  }
}
