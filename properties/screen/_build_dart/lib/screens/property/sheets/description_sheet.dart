import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../config/theme.dart';

/// The description bottom sheet
/// (`property_detail_screen_6_show_bottom_sheet_descripton.jpeg`).
///
/// The only true `showModalBottomSheet` in the set — it has a drag handle and
/// no AppBar, unlike the full-screen red-header routes. Extra paragraphs and
/// the `Rekomendasi Tempat Rekreasi Terdekat:` heading appear here and nowhere
/// else.
class DescriptionSheet extends StatelessWidget {
  final Property detail;

  const DescriptionSheet({super.key, required this.detail});

  static Future<void> show(BuildContext context, Property detail) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DT.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => DescriptionSheet(detail: detail),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .9,
      minChildSize: .5,
      maxChildSize: .95,
      expand: false,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: DT.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(DT.gutter, 8, DT.gutter, 28),
              children: [
                const Text('Deskripsi', style: DT.sectionTitle),
                const SizedBox(height: 14),
                if (detail.intro.isNotEmpty) ...[
                  Text(detail.intro, style: DT.bodyMuted),
                  const SizedBox(height: 14),
                ],
                Text(detail.description, style: DT.bodyMuted),
                if (detail.descriptionExtraHeading.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(detail.descriptionExtraHeading, style: DT.bodyStrong),
                ],
                for (final paragraph in detail.descriptionExtra)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(paragraph, style: DT.bodyMuted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








