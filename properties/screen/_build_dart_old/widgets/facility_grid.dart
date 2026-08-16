import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../utils/detail_icons.dart';
import 'detail_primitives.dart';

/// `Fasilitas` — the first anchored section of the detail screen
/// (`property_detail_screen_2_tab_facilities.jpg`).
///
/// Three sub-blocks: `Fasilitas Kasur` (wide 3-up tiles with a red glyph),
/// `Fasilitas Gedung` and `Furnitur Ruangan` (narrow 4-up tiles with a grey
/// glyph, each with a `Lihat Semua` link that opens a full-screen sheet).
class FacilitiesSection extends StatelessWidget {
  final PropertyDetail detail;
  final VoidCallback? onSeeBuildingFacilities;
  final VoidCallback? onSeeRoomFurniture;

  const FacilitiesSection({
    super.key,
    required this.detail,
    this.onSeeBuildingFacilities,
    this.onSeeRoomFurniture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Fasilitas',
            padding: EdgeInsets.fromLTRB(DT.gutter, 6, DT.gutter, 4),
          ),
          if (detail.bedFacilities.isNotEmpty) ...[
            const _SubHeader(title: 'Fasilitas Kasur'),
            FacilityTileGrid(
              items: detail.bedFacilities,
              columns: 3,
              glyphColor: DT.brand,
              tileHeight: 96,
              labelMaxLines: 2,
            ),
          ],
          if (detail.buildingFacilities.isNotEmpty) ...[
            _SubHeader(
              title: 'Fasilitas Gedung',
              actionLabel: 'Lihat Semua (${detail.buildingFacilitiesTotal})',
              onAction: onSeeBuildingFacilities,
            ),
            FacilityTileGrid(
              items: detail.buildingFacilities,
              columns: 4,
              glyphColor: DT.textSecondary,
            ),
          ],
          if (detail.roomFurniture.isNotEmpty) ...[
            _SubHeader(
              title: 'Furnitur Ruangan',
              actionLabel: 'Lihat Semua',
              onAction: onSeeRoomFurniture,
            ),
            FacilityTileGrid(
              items: detail.roomFurniture,
              columns: 4,
              glyphColor: DT.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SubHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => SectionHeader(
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
        style: DT.subsectionTitle,
        padding: const EdgeInsets.fromLTRB(DT.gutter, 16, DT.gutter, 12),
      );
}

/// Fixed-column grid of grey facility tiles.
///
/// Uses a plain `Row`/`Column` build rather than `GridView` so it can live
/// inside the detail screen's single scroll view without a nested scrollable.
class FacilityTileGrid extends StatelessWidget {
  final List<FacilityItem> items;
  final int columns;
  final Color glyphColor;
  final double tileHeight;
  final int labelMaxLines;

  const FacilityTileGrid({
    super.key,
    required this.items,
    this.columns = 4,
    this.glyphColor = DT.textSecondary,
    this.tileHeight = 88,
    this.labelMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < items.length; start += columns) {
      final end = (start + columns).clamp(0, items.length);
      final slice = items.sublist(start, end);
      rows.add(Padding(
        padding: EdgeInsets.only(top: start == 0 ? 0 : 10),
        child: Row(
          children: [
            for (var i = 0; i < columns; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: i < slice.length
                    ? _Tile(
                        item: slice[i],
                        glyphColor: glyphColor,
                        height: tileHeight,
                        labelMaxLines: labelMaxLines,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
      child: Column(children: rows),
    );
  }
}

class _Tile extends StatelessWidget {
  final FacilityItem item;
  final Color glyphColor;
  final double height;
  final int labelMaxLines;

  const _Tile({
    required this.item,
    required this.glyphColor,
    required this.height,
    required this.labelMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: DT.fill,
        borderRadius: BorderRadius.circular(DT.tileRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(DetailIcons.of(item.iconKey), size: 28, color: glyphColor),
          const SizedBox(height: 8),
          Text(
            item.displayLabel,
            textAlign: TextAlign.center,
            maxLines: labelMaxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: DT.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
