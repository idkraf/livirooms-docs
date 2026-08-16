import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import 'detail_primitives.dart';

/// `Lihat Unit Lain di Gedung Ini` — the closing teaser of
/// `property_detail_screen_7.jpg`.
///
/// Portrait thumbnail on the left; building name, prompt, an amber
/// `3 Unit Tersedia 🔥` line and a brand-tinted `Lihat Semua Unit!` pill with
/// a red circular arrow on the right.
class BuildingUnitsCard extends StatelessWidget {
  final BuildingUnitsTeaser teaser;
  final VoidCallback? onTap;

  const BuildingUnitsCard({super.key, required this.teaser, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Lihat Unit Lain di Gedung Ini',
            padding: EdgeInsets.fromLTRB(DT.gutter, 12, DT.gutter, 12),
          ),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: SectionCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetImage(
                    url: teaser.imageUrl,
                    width: 88,
                    height: 116,
                    radius: BorderRadius.circular(DT.tileRadius),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teaser.buildingName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: DT.cardTitle,
                        ),
                        const SizedBox(height: 6),
                        Text(teaser.prompt, style: DT.caption),
                        if (teaser.availableUnits > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${teaser.availableUnits} Unit Tersedia',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: DT.accent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.local_fire_department_rounded,
                                  size: 16, color: DT.accent),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        _CtaPill(label: teaser.ctaLabel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaPill extends StatelessWidget {
  final String label;

  const _CtaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: DT.brandSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: DT.brand,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: DT.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_forward_rounded,
                size: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
