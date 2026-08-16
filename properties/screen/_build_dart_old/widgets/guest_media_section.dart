import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import 'detail_primitives.dart';

/// `Foto/Video dari Tamu` — the 16:9 media card near the bottom of
/// `property_detail_screen_7.jpg`.
///
/// Horizontally scrollable once more than one item exists; the mockup only
/// ever shows a single full-width card.
class GuestMediaSection extends StatelessWidget {
  final List<GalleryItem> media;
  final ValueChanged<int>? onTap;

  const GuestMediaSection({super.key, required this.media, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Foto/Video dari Tamu',
            padding: EdgeInsets.fromLTRB(DT.gutter, 20, DT.gutter, 12),
          ),
          if (media.length == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
              child: _MediaCard(item: media.first, onTap: () => onTap?.call(0)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
              child: Row(
                children: [
                  for (var i = 0; i < media.length; i++)
                    Padding(
                      padding: EdgeInsets.only(right: i == media.length - 1 ? 0 : 12),
                      child: SizedBox(
                        width: 280,
                        child: _MediaCard(
                          item: media[i],
                          onTap: () => onTap?.call(i),
                        ),
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

class _MediaCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback? onTap;

  const _MediaCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DT.cardRadius),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetImage(url: item.previewUrl),
              if (item.kind != MediaKind.photo)
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: DT.fade(Colors.white, .92),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 36, color: DT.textPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
