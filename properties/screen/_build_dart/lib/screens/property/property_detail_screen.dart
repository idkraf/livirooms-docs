import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/host_info.dart';
import '../../models/property.dart';
import '../../models/review.dart';
import '../../models/unit_pricing.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/chat_service.dart';
import '../../services/property_service.dart';
import '../../services/wishlist_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/state_views.dart';
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
import '../chat/chat_room_screen.dart';
import 'rincian_unit_screen.dart';
import 'sheets/building_facilities_sheet.dart';
import 'sheets/description_sheet.dart';
import 'sheets/qna_sheet.dart';
import 'sheets/reviews_sheet.dart';
import 'sheets/room_furniture_sheet.dart';

IconData _facilityIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('wifi') || n.contains('wi-fi')) return Icons.wifi;
  if (n.contains('ac') || n.contains('air')) return Icons.ac_unit;
  if (n.contains('pool') || n.contains('kolam')) return Icons.pool;
  if (n.contains('park')) return Icons.local_parking;
  if (n.contains('breakfast') || n.contains('sarapan'))
    return Icons.free_breakfast;
  if (n.contains('gym') || n.contains('fitness')) return Icons.fitness_center;
  if (n.contains('tv')) return Icons.tv;
  if (n.contains('kitchen') || n.contains('dapur')) return Icons.kitchen;
  if (n.contains('wash') || n.contains('laundry') || n.contains('cuci')) {
    return Icons.local_laundry_service;
  }
  if (n.contains('security') || n.contains('keamanan')) return Icons.security;
  if (n.contains('elevator') || n.contains('lift')) return Icons.elevator;
  return Icons.check_circle_outline;
}

class PropertyDetailScreen extends StatefulWidget {
  final Property? property;
  final int? propertyId;

  final VoidCallback? onSelectUnit;
  final VoidCallback? onContactHost;
  final VoidCallback? onShare;
  final VoidCallback? onOpenMap;
  final VoidCallback? onSeeBuildingUnits;
  final ValueChanged<int>? onOpenGallery;
  final ValueChanged<bool>? onFavoriteChanged;

  const PropertyDetailScreen({
    super.key,
    this.property,
    this.propertyId,
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

  final PropertyService _service = PropertyService();
  final WishlistService _wishlist = WishlistService();
  final ChatService _chat = ChatService();

  Property? _property;
  Object? _error;
  bool _loading = false;

  List<Review> _reviews = [];
  bool _favorite = false;
  bool _startingChat = false;

  List<String> _blockedDates = [];
  bool _loadingAvailability = false;

  HostInfo? _host;
  bool _loadingHost = false;

  late Property _detail;
  int _activeTab = 0;
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    if (_property == null) {
      _fetchProperty();
    } else {
      _detail = _property!;
      _loadReviews();
      _loadAvailability();
      _loadHost();
    }
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PropertyDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property != widget.property && widget.property != null) {
      _property = widget.property;
      _detail = widget.property!;
      _loadReviews();
      _loadAvailability();
      _loadHost();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  List<GlobalKey> get _anchors => [
    _facilitiesKey,
    _infoKey,
    _detailsKey,
    _locationKey,
  ];

  void _onScroll() {
    if (_jumping) return;
    final offset = _controller.offset;
    var active = 0;
    for (var i = 0; i < _anchors.length; i++) {
      final anchor = _anchorOffset(_anchors[i]);
      if (anchor != null && offset >= anchor - 4) active = i;
    }
    if (active != _activeTab) setState(() => _activeTab = active);
  }

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

  Future<void> _fetchProperty() async {
    final id = widget.propertyId ?? widget.property?.id;
    if (id == null) {
      setState(() => _error = 'Properti tidak ditemukan.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _service.detail(id);
      if (!mounted) return;
      setState(() {
        _property = p;
        _detail = p;
        _loading = false;
      });
      _loadReviews();
      _loadAvailability();
      _loadHost();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    final id = _property?.id;
    if (id == null) return;
    try {
      final res = await _service.reviews(id);
      if (!mounted) return;
      setState(() => _reviews = res.data.take(3).toList());
    } catch (_) {
      // Reviews are non-critical; ignore failures silently.
    }
  }

  Future<void> _loadAvailability() async {
    final id = _property?.id;
    if (id == null) return;
    setState(() => _loadingAvailability = true);
    try {
      final dates = await _service.availability(id);
      if (!mounted) return;
      setState(() => _blockedDates = dates);
    } catch (_) {
      // Availability is non-critical; ignore failures silently.
    } finally {
      if (mounted) setState(() => _loadingAvailability = false);
    }
  }

  Future<void> _loadHost() async {
    final id = _property?.id;
    if (id == null) return;
    setState(() => _loadingHost = true);
    try {
      final host = await _service.host(id);
      if (!mounted) return;
      setState(() => _host = host);
    } catch (_) {
      // Host info is non-critical; ignore failures silently.
    } finally {
      if (mounted) setState(() => _loadingHost = false);
    }
  }

  void _toggleFavorite() {
    final next = !_favorite;
    setState(() => _favorite = next);
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

  void _openRoomFurniture() =>
      RoomFurnitureSheet.show(context, groups: _detail.roomFurnitureGroups);

  void _openDescription() => DescriptionSheet.show(context, _detail);

  Future<void> _chatHost() async {
    final p = _property;
    if (p == null || _startingChat) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      Navigator.pushNamed(context, Routes.login);
      return;
    }

    setState(() => _startingChat = true);
    try {
      final conv = await _chat.start(recipientId: p.hostId, propertyId: p.id);
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        Routes.chatRoom,
        arguments: ChatRoomArgs(conversationId: conv.id, title: p.name),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memulai chat: $e')));
    } finally {
      if (mounted) setState(() => _startingChat = false);
    }
  }

  Future<void> _bookNow() async {
    final p = _property;
    if (p == null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      Navigator.pushNamed(context, Routes.login);
      return;
    }

    final uniqueTypes = p.prices.map((e) => e.priceType).toSet();
    if (uniqueTypes.isEmpty) return;

    final periods = uniqueTypes
        .map((t) => RentalPeriodX.fromApi(t))
        .toSet()
        .toList();

    setState(() => _loading = true);
    try {
      final entries = <RentalPeriod, UnitPricing>{};
      for (final period in periods) {
        final pricing = await _service.pricing(p.id, priceType: period.apiValue);
        if (mounted) entries[period] = pricing;
      }
      if (!mounted) return;
      final initial = periods.isNotEmpty ? periods.first : RentalPeriod.daily;
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RincianUnitScreen(
            pricing: entries,
            initialPeriod: initial,
            onSubmit: (draft) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pesanan ${draft.period.label} diajukan')),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat rincian harga: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingView());
    }
    if (_error != null || _property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: 'Gagal memuat detail properti.\n$_error',
          onRetry: _fetchProperty,
        ),
      );
    }

    final detail = _detail;
    return Scaffold(
      backgroundColor: DT.canvas,
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          DetailGalleryHeader(
            title: detail.name,
            gallery: detail.galleryItems,
            extraMediaCount: 0,
            isFavorite: _favorite,
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
                  onOpenMap: widget.onOpenMap ?? _openMap,
                ),
                DescriptionCard(detail: detail, onSeeAll: _openDescription),
                DT.sectionGap,
                if (detail.guestMedia.isNotEmpty)
                  GuestMediaSection(
                    media: detail.guestMedia,
                    onTap: widget.onOpenGallery,
                  ),
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
        onPrimary: widget.onSelectUnit ?? _bookNow,
        onSecondary: widget.onContactHost ?? _chatHost,
      ),
    );
  }

  void _openMap() {
    final lat = _detail.latitude;
    final lng = _detail.longitude;
    final address = _detail.address;
    final query = lat != null && lng != null
        ? '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}'
        : Uri.encodeComponent(address);
    if (query.isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
