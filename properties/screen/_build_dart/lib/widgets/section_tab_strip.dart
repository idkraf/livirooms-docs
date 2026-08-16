import 'package:flutter/material.dart';

import '../config/theme.dart';

/// The `Facilities | Info | Details | Location` strip.
///
/// Despite looking like a `TabBar`, in the mockups it is a **section
/// navigator**: screens 2–7 are one continuously scrolling page (the Details
/// shot shows `Pengantar` *and* `Peta Lokasi`; the Location shot shows
/// `Peta Lokasi` *and* `Deskripsi`). Tapping scrolls to an anchor and the
/// active item is derived from the scroll offset — see
/// `property_detail_screen.dart`.
///
/// Wrapped in a `SliverPersistentHeader(pinned: true)` so it sticks directly
/// under the collapsed AppBar.
class SectionTabStrip extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  const SectionTabStrip({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DT.tabStripHeight,
      color: DT.surface,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: _Tab(
                      label: labels[i],
                      active: i == activeIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: DT.divider),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? DT.brand : DT.textSecondary,
                ),
              ),
            ),
          ),
          if (active)
            const Positioned(
              left: 12,
              right: 12,
              bottom: 0,
              child: SizedBox(
                height: 3,
                child: ColoredBox(color: DT.brand),
              ),
            ),
        ],
      ),
    );
  }
}

/// `SliverPersistentHeaderDelegate` for [SectionTabStrip] — fixed height, so
/// `minExtent == maxExtent` and it simply pins.
class SectionTabStripDelegate extends SliverPersistentHeaderDelegate {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  const SectionTabStripDelegate({
    required this.labels,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  double get minExtent => DT.tabStripHeight;

  @override
  double get maxExtent => DT.tabStripHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SectionTabStrip(
      labels: labels,
      activeIndex: activeIndex,
      onSelected: onSelected,
    );
  }

  @override
  bool shouldRebuild(SectionTabStripDelegate oldDelegate) =>
      oldDelegate.activeIndex != activeIndex || oldDelegate.labels != labels;
}




