import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../widgets/detail_primitives.dart';

/// `DAFTAR FURNITUR RUANGAN`
/// (`property_detail_screen_2_tab_facilities_show_bottom_sheet_fruniture_ruangan.jpeg`).
///
/// One block per room: the room name, its `✓` furniture rows, then a grey
/// `Bed Config :` panel whose entries are prefixed with a red dash.
class RoomFurnitureSheet extends StatelessWidget {
  final List<RoomFurnitureGroup> groups;

  const RoomFurnitureSheet({super.key, required this.groups});

  static Future<void> show(
    BuildContext context, {
    required List<RoomFurnitureGroup> groups,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomFurnitureSheet(groups: groups),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'DAFTAR FURNITUR RUANGAN',
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: groups.length,
        separatorBuilder: (_, __) => DT.sectionGap,
        itemBuilder: (_, i) => _RoomBlock(group: groups[i]),
      ),
    );
  }
}

class _RoomBlock extends StatelessWidget {
  final RoomFurnitureGroup group;

  const _RoomBlock({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(DT.gutter, 18, DT.gutter, 4),
            child: Text(group.roomName, style: DT.sectionTitle),
          ),
          for (var i = 0; i < group.items.length; i++)
            CheckListTile(
              label: group.items[i],
              showDivider: i != group.items.length - 1,
            ),
          if (group.bedConfig.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(DT.gutter, 16, DT.gutter, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DT.fill,
                  borderRadius: BorderRadius.circular(DT.tileRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bed Config :', style: DT.bodyStrong),
                    const SizedBox(height: 8),
                    for (final line in group.bedConfig)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '-',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: DT.brand,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(line, style: DT.bodyMuted)),
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
