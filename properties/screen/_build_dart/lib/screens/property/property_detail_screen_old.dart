import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;

import '../../models/property.dart';
import 'sheets/building_facilities_sheet.dart';
import 'sheets/description_sheet.dart';
import 'sheets/qna_sheet.dart';
import 'sheets/reviews_sheet.dart';
import 'sheets/room_furniture_sheet.dart';
import '../../config/theme.dart';
import '../../widgets/building_units_card.dart';
import '../../widgets/description_card.dart';
import '../../widgets/detail_action_row.dart';
import '../../widgets/detail_gallery_header.dart';
import '../../widgets/detail_overview_block.dart';
import '../../widgets/facility_grid.dart';
import '../../widgets/guest_media_section.dart';
import '../../widgets/info_segmented.dart';
import '../../widgets/location_section.dart';
import '../../widgets/review_summary_card.dart';
import '../../widgets/section_tab_strip.dart';
import '../../widgets/sticky_price_bar.dart';

/// Property detail — mockups `property_detail_screen_1` … `_7` plus their five
/// sheet variants.
///
/// **One screen, not five tabs.** The `Facilities | Info | Details | Location`
/// strip is a section navigator over a single `CustomScrollView`: tapping
/// animates to an anchor and the active item is derived from the scroll offset.
/// The screenshots confirm this — the Details shot shows `Pengantar` *and* the
/// top of `Peta Lokasi`, and the Location shot shows `Peta Lokasi` *and*
/// `Deskripsi`, which a `TabBarView` could not produce.
///
/// Sliver order matters: the strip sits *after* the title/actions block, so at
/// offset 0 it is below the fold (screen 1 shows no strip) and pins under the
/// collapsed AppBar as soon as it reaches the top (screens 2–7).
class PropertyDetailScreen extends StatefulWidget {
  final Property detail;

  /// `PILIH UNIT` — pushes the Rincian Unit screen in the real app.
  final VoidCallback? onSelectUnit;

  /// `HUBUNGI HOST`.
  final VoidCallback? onContactHost;

  /// `Bagikan`. `share_plus` is **not** in `flutter/pubspec.yaml`, so sharing
  /// is left to the host app (see README).
  final VoidCallback? onShare;

  /// Tapping the static map preview — deep-link out with `url_launcher`.
  final VoidCallback? onOpenMap;

  /// `Lihat Semua Unit!` on the building teaser.
  final VoidCallback? onSeeBuildingUnits;

  /// A gallery tile was tapped, with its index into `detail.gallery`.
  final ValueChanged<int>? onOpenGallery;

  final ValueChanged<bool>? onFavoriteChanged;

  const PropertyDetailScreen({
    super.key,
    required this.detail,
    this.onSelectUnit,
    this.onContactHost,
    this.onShare,
    this.onOpenMap,
    this.onSeeBuildingUnits,
    this.onOpenGallery,
    this.onFavoriteChanged,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  static const List<String> _tabLabels = [
    'Facilities',
    'Info',
    'Details',
    'Location',
  ];

  final ScrollController _controller = ScrollController();
  final GlobalKey _facilitiesKey = GlobalKey();
  final GlobalKey _infoKey = GlobalKey();
  final GlobalKey _detailsKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();

  late Property _detail = widget.detail;
  int _activeTab = 0;

  /// Suppresses the scroll-spy while an anchored jump is animating, otherwise
  /// the intermediate offsets would flicker the active tab.
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PropertyDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail != widget.detail) _detail = widget.detail;
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  List<GlobalKey> get _anchors =>
      [_facilitiesKey, _infoKey, _detailsKey, _locationKey];

  // ------------------------------------------------------------ scroll spy

  void _onScroll() {
    if (_jumping) return;
    final offset = _controller.offset;
    var active = 0;
    for (var i = 0; i < _anchors.length; i++) {
      final anchor = _anchorOffset(_anchors[i]);
      // 4px of slack so the section that is flush against the pinned strip
      // counts as active rather than the one above it.
      if (anchor != null && offset >= anchor - 4) active = i;
    }
    if (active != _activeTab) setState(() => _activeTab = active);
  }

  /// Scroll offset at which [key]'s section sits directly under the pinned
  /// tab strip.
  double? _anchorOffset(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    final viewport = RenderAbstractViewport.of(box);
    return viewport.getOffsetToReveal(box, 0).offset - DT.tabStripHeight;
  }

  Future<void> _goToSection(int index) async {
    final target = _anchorOffset(_anchors[index]);
    if (target == null) return;
    setState(() {
      _activeTab = index;
      _jumping = true;
    });
    await _controller.animateTo(
      target.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    if (mounted) setState(() => _jumping = false);
  }

  // ---------------------------------------------------------------- actions

  void _toggleFavorite() {
    final next = !_detail.isFavorite;
    setState(() => _detail = _detail.copyWith(isFavorite: next));
    widget.onFavoriteChanged?.call(next);
  }

  void _openReviews() {
    if (_detail.hasReviews) {
      ReviewsSheet.show(
        context,
        summary: _detail.reviewSummary,
        reviews: _detail.reviews,
      );
    }
  }

  void _openDiscussion() =>
      QnaSheet.show(context, questions: _detail.questions);

  void _openBuildingFacilities() => BuildingFacilitiesSheet.show(
        context,
        facilities: _detail.buildingFacilitiesAll.isNotEmpty
            ? _detail.buildingFacilitiesAll
            : _detail.buildingFacilities.map((f) => f.label).toList(),
      );

  void _openRoomFurniture() => RoomFurnitureSheet.show(
        context,
        groups: _detail.roomFurnitureGroups,
      );

  void _openDescription() => DescriptionSheet.show(context, _detail);

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      backgroundColor: DT.canvas,
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          DetailGalleryHeader(
            title: detail.name,
            gallery: detail.galleryItems,
            extraMediaCount: detail.extraMediaCount,
            isFavorite: detail.isFavorite,
            onFavoriteToggle: _toggleFavorite,
            onMediaTap: widget.onOpenGallery,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                DetailOverviewBlock(detail: detail),
                DetailActionRow(
                  reviewCount: detail.reviewSummary.total,
                  reviewScore: detail.hasReviews
                      ? detail.reviewSummary.average
                      : null,
                  questionCount: detail.questionCount,
                  onReviewTap: _openReviews,
                  onDiscussionTap: _openDiscussion,
                  onShareTap: widget.onShare,
                ),
                if (detail.hasReviews)
                  ReviewSummaryCard(
                    summary: detail.reviewSummary,
                    reviews: detail.reviews,
                    onSeeAll: _openReviews,
                  ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SectionTabStripDelegate(
              labels: _tabLabels,
              activeIndex: _activeTab,
              onSelected: _goToSection,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                FacilitiesSection(
                  key: _facilitiesKey,
                  detail: detail,
                  onSeeBuildingFacilities: _openBuildingFacilities,
                  onSeeRoomFurniture: _openRoomFurniture,
                ),
                DT.sectionGap,
                InfoSection(key: _infoKey, detail: detail),
                DT.sectionGap,
                IntroCard(key: _detailsKey, intro: detail.intro),
                DT.sectionGap,
                LocationSection(
                  key: _locationKey,
                  detail: detail,
                  onOpenMap: widget.onOpenMap,
                ),
                DescriptionCard(detail: detail, onSeeAll: _openDescription),
                DT.sectionGap,
                GuestMediaSection(media: detail.guestMedia),
                if (detail.buildingUnits != null)
                  BuildingUnitsCard(
                    teaser: detail.buildingUnits!,
                    onTap: widget.onSeeBuildingUnits,
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: StickyPriceBar(
        caption: detail.priceCaption,
        amount: detail.priceAmount,
        isFlashSale: detail.isFlashSale,
        onPrimary: widget.onSelectUnit,
        onSecondary: widget.onContactHost,
      ),
    );
  }
}






