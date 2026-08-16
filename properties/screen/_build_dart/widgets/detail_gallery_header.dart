import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import 'detail_primitives.dart';

/// Collapsing gallery header — `property_detail_screen_1.jpg` expanded,
/// `property_detail_screen_2…7` collapsed.
///
/// Expanded: full-bleed hero above a row of three thumbnails; the back and
/// favourite buttons float as white circles and no title is shown.
/// Collapsed: a plain white AppBar with the uppercase, ellipsised title.
/// Both states are the same sliver — the circles fade into flat icons as the
/// header shrinks.
class DetailGalleryHeader extends StatelessWidget {
  final String title;
  final List<GalleryItem> gallery;

  /// Renders the `+38` overlay on the third thumbnail.
  final int extraMediaCount;

  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  /// Index into [gallery]; the `+N` tile reports the last visible index.
  final ValueChanged<int>? onMediaTap;

  static const double heroHeight = 300;
  static const double thumbHeight = 148;

  const DetailGalleryHeader({
    super.key,
    required this.title,
    this.gallery = const [],
    this.extraMediaCount = 0,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final expanded = heroHeight + thumbHeight;
    final collapsed = kToolbarHeight + topPad;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: DT.surface,
      surfaceTintColor: DT.surface,
      systemOverlayStyle: null,
      automaticallyImplyLeading: false,
      expandedHeight: expanded,
      collapsedHeight: kToolbarHeight,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // 0 = fully expanded, 1 = pinned.
          final t = expanded == collapsed
              ? 1.0
              : ((expanded + topPad - constraints.maxHeight) /
                      (expanded + topPad - collapsed))
                  .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _media(),
              ),
              // Fades the artwork out into the white pinned AppBar.
              IgnorePointer(
                child: ColoredBox(color: DT.fade(DT.surface, t)),
              ),
              Positioned(
                top: topPad,
                left: 0,
                right: 0,
                height: kToolbarHeight,
                child: _toolbar(context, t),
              ),
              if (t > .98)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Divider(height: 1, thickness: 1, color: DT.divider),
                ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------ media

  Widget _media() {
    final hero = gallery.isEmpty ? null : gallery.first;
    final thumbs = gallery.length > 1 ? gallery.sublist(1) : const <GalleryItem>[];
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onMediaTap?.call(0),
            child: NetImage(url: hero?.previewUrl, fit: BoxFit.cover),
          ),
        ),
        SizedBox(
          height: thumbHeight,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
                    child: _thumb(
                      i < thumbs.length ? thumbs[i] : null,
                      index: i + 1,
                      isLast: i == 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _thumb(GalleryItem? item, {required int index, required bool isLast}) {
    final showCount = isLast && extraMediaCount > 0;
    return GestureDetector(
      onTap: () => onMediaTap?.call(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(url: item?.previewUrl, fit: BoxFit.cover),
          if (item?.kind == MediaKind.video && !showCount)
            const Center(child: _PlayGlyph()),
          if (item?.kind == MediaKind.panorama && !showCount)
            const Center(child: _PanoramaGlyph()),
          if (showCount) ...[
            ColoredBox(color: DT.fade(Colors.black, .35)),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+$extraMediaCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.photo_library_rounded,
                      color: Colors.white, size: 34),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- toolbar

  Widget _toolbar(BuildContext context, double t) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * (1 - t) + 4 * t),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back,
            collapse: t,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Opacity(
              opacity: t,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: DT.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          _HeaderButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            collapse: t,
            iconColor: isFavorite ? DT.textPrimary : DT.textPrimary,
            onTap: onFavoriteToggle,
          ),
        ],
      ),
    );
  }
}

/// Circle-on-photo when expanded, flat icon when pinned.
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final double collapse;
  final VoidCallback? onTap;
  final Color iconColor;

  const _HeaderButton({
    required this.icon,
    required this.collapse,
    this.onTap,
    this.iconColor = DT.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final size = 46 - 6 * collapse;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: DT.fade(DT.surface, 1 - collapse),
          shape: BoxShape.circle,
          boxShadow: collapse > .5
              ? null
              : [
                  BoxShadow(
                    color: DT.fade(Colors.black, .12 * (1 - collapse)),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 26, color: iconColor),
      ),
    );
  }
}

class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph();

  @override
  Widget build(BuildContext context) => Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.play_arrow_rounded, size: 38),
      );
}

/// The `360°` badge on the panorama thumbnail.
class _PanoramaGlyph extends StatelessWidget {
  const _PanoramaGlyph();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '360°',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DT.textPrimary,
              ),
            ),
            Icon(Icons.rotate_right_rounded, size: 20, color: DT.brand),
          ],
        ),
      );
}
