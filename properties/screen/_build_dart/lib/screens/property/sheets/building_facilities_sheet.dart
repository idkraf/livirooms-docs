import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../widgets/detail_primitives.dart';

/// `DAFTAR FASILITAS GEDUNG` — the full building-facility list behind
/// `Lihat Semua (5)`
/// (`property_detail_screen_2_tab_facilities_show_bottom_sheet_fasilitas_gedung.jpeg`).
///
/// A flat white list of `✓ label` rows.
class BuildingFacilitiesSheet extends StatelessWidget {
  final List<String> facilities;

  const BuildingFacilitiesSheet({super.key, required this.facilities});

  static Future<void> show(
    BuildContext context, {
    required List<String> facilities,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuildingFacilitiesSheet(facilities: facilities),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'DAFTAR FASILITAS GEDUNG',
      background: DT.surface,
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: facilities.length,
        itemBuilder: (_, i) => CheckListTile(
          label: facilities[i],
          showDivider: i != facilities.length - 1,
        ),
      ),
    );
  }
}





