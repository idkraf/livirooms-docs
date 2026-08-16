import '../utils/fmt.dart';

/// Domain models for the property-detail screen (mockups 1–15).
///
/// Field names in `fromJson` follow the Laravel API's snake_case
/// (`app/Support/ApiResponse.php` wraps everything in `{success, message,
/// data}` — these factories expect the unwrapped `data` object). Several
/// sections do not exist in the backend yet (see `docs/properties/system.md`,
/// "Yang Belum Diimplementasikan"); those parse defensively and default to
/// empty so the UI degrades to hiding the section.

// ---------------------------------------------------------------- gallery

enum MediaKind { photo, video, panorama }

class GalleryItem {
  final String url;
  final MediaKind kind;

  /// Still frame for `video` / `panorama` entries.
  final String? thumbnailUrl;

  const GalleryItem({
    required this.url,
    this.kind = MediaKind.photo,
    this.thumbnailUrl,
  });

  String get previewUrl => thumbnailUrl ?? url;

  factory GalleryItem.fromJson(Map<String, dynamic> json) => GalleryItem(
        url: '${json['url'] ?? json['path'] ?? ''}',
        kind: _kind('${json['kind'] ?? json['type'] ?? 'photo'}'),
        thumbnailUrl: json['thumbnail'] as String?,
      );

  static MediaKind _kind(String raw) {
    switch (raw) {
      case 'video':
        return MediaKind.video;
      case 'panorama':
      case '360':
        return MediaKind.panorama;
      default:
        return MediaKind.photo;
    }
  }
}

// ------------------------------------------------------------------ spec

/// One entry of the icon strip under the title:
/// `Full Furnished · 3 · 2 · 100m2 · 5500 W`.
class SpecItem {
  final String iconKey;
  final String label;

  const SpecItem({required this.iconKey, required this.label});

  factory SpecItem.fromJson(Map<String, dynamic> json) => SpecItem(
        iconKey: '${json['icon'] ?? ''}',
        label: '${json['label'] ?? ''}',
      );
}

// -------------------------------------------------------------- facility

/// A grey facility tile. `note` is the parenthesised second line of the bed
/// tiles (`King Bed` / `(180x200)`); `count` renders as `AC (4)`.
class FacilityItem {
  final String iconKey;
  final String label;
  final String? note;
  final int? count;

  const FacilityItem({
    required this.iconKey,
    required this.label,
    this.note,
    this.count,
  });

  String get displayLabel => count == null ? label : '$label ($count)';

  factory FacilityItem.fromJson(Map<String, dynamic> json) => FacilityItem(
        iconKey: '${json['icon'] ?? json['label'] ?? ''}',
        label: '${json['label'] ?? ''}',
        note: json['note'] as String?,
        count: json['count'] as int?,
      );
}

/// One room block of the "Daftar Furnitur Ruangan" sheet.
class RoomFurnitureGroup {
  final String roomName;
  final List<String> items;

  /// Rendered in the grey "Bed Config :" block under the checklist.
  final List<String> bedConfig;

  const RoomFurnitureGroup({
    required this.roomName,
    this.items = const [],
    this.bedConfig = const [],
  });

  factory RoomFurnitureGroup.fromJson(Map<String, dynamic> json) =>
      RoomFurnitureGroup(
        roomName: '${json['room'] ?? json['name'] ?? ''}',
        items: _strings(json['items']),
        bedConfig: _strings(json['bed_config']),
      );
}

// ------------------------------------------------------------------ info

/// Colour role of an `InfoNote` leading badge.
enum InfoTone { warning, brand, info, success }

/// A labelled paragraph inside the Check In Info / Deposit panels — grey
/// caption on top, bold body underneath, tinted circular icon on the left.
class InfoNote {
  final String iconKey;
  final InfoTone tone;
  final String title;

  /// Paragraphs; rendered with a blank line between them.
  final List<String> paragraphs;

  const InfoNote({
    required this.iconKey,
    required this.title,
    this.tone = InfoTone.info,
    this.paragraphs = const [],
  });

  factory InfoNote.fromJson(Map<String, dynamic> json) => InfoNote(
        iconKey: '${json['icon'] ?? 'info'}',
        title: '${json['title'] ?? ''}',
        tone: _tone('${json['tone'] ?? 'info'}'),
        paragraphs: _strings(json['paragraphs'] ?? json['body']),
      );

  static InfoTone _tone(String raw) {
    switch (raw) {
      case 'warning':
        return InfoTone.warning;
      case 'brand':
      case 'danger':
        return InfoTone.brand;
      case 'success':
        return InfoTone.success;
      default:
        return InfoTone.info;
    }
  }
}

/// `Biaya kartu : IDR 50,000` — a money line nested under a parking group.
class LabeledAmount {
  final String label;
  final num amount;

  const LabeledAmount({required this.label, required this.amount});

  String get display => '$label : ${Fmt.idr(amount)}';

  factory LabeledAmount.fromJson(Map<String, dynamic> json) => LabeledAmount(
        label: '${json['label'] ?? ''}',
        amount: (json['amount'] as num?) ?? 0,
      );
}

/// A bolded sub-group of a `UnitDetailRow` — `Mobil` / `Motor` under Parkir.
class UnitDetailGroup {
  final String title;
  final List<LabeledAmount> lines;

  const UnitDetailGroup({required this.title, this.lines = const []});

  factory UnitDetailGroup.fromJson(Map<String, dynamic> json) =>
      UnitDetailGroup(
        title: '${json['title'] ?? ''}',
        lines: (json['lines'] as List<dynamic>? ?? const [])
            .map((e) => LabeledAmount.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One row of the Unit Detail panel: Gedung / Tower / Lantai / Property
/// Tayang Sejak / Parkir.
class UnitDetailRow {
  final String iconKey;
  final String label;
  final String? value;
  final List<UnitDetailGroup> groups;

  const UnitDetailRow({
    required this.iconKey,
    required this.label,
    this.value,
    this.groups = const [],
  });

  factory UnitDetailRow.fromJson(Map<String, dynamic> json) => UnitDetailRow(
        iconKey: '${json['icon'] ?? 'building'}',
        label: '${json['label'] ?? ''}',
        value: json['value'] as String?,
        groups: (json['groups'] as List<dynamic>? ?? const [])
            .map((e) => UnitDetailGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// -------------------------------------------------------------- location

/// An entry of the "Sekitar" grid. `tone` picks one of the pastel badge
/// colours cycled by `LocationSection`.
class NearbyPlace {
  final String name;
  final String iconKey;
  final int tone;

  const NearbyPlace({required this.name, this.iconKey = 'place', this.tone = 0});

  factory NearbyPlace.fromJson(Map<String, dynamic> json) => NearbyPlace(
        name: '${json['name'] ?? ''}',
        iconKey: '${json['icon'] ?? 'place'}',
        tone: json['tone'] as int? ?? 0,
      );
}

/// "Lihat Unit Lain di Gedung Ini" teaser card.
class BuildingUnitsTeaser {
  final String buildingName;
  final String? imageUrl;
  final int availableUnits;
  final String prompt;
  final String ctaLabel;

  const BuildingUnitsTeaser({
    required this.buildingName,
    this.imageUrl,
    this.availableUnits = 0,
    this.prompt = 'Ingin lihat unit lain di gedung ini?',
    this.ctaLabel = 'Lihat Semua Unit!',
  });

  factory BuildingUnitsTeaser.fromJson(Map<String, dynamic> json) =>
      BuildingUnitsTeaser(
        buildingName: '${json['building_name'] ?? ''}',
        imageUrl: json['image'] as String?,
        availableUnits: json['available_units'] as int? ?? 0,
      );
}

// --------------------------------------------------------------- reviews

/// One row of the six-way score breakdown in the Ulasan screen.
class ReviewScore {
  final String iconKey;
  final String label;
  final double value;

  const ReviewScore({
    required this.iconKey,
    required this.label,
    required this.value,
  });

  factory ReviewScore.fromJson(Map<String, dynamic> json) => ReviewScore(
        iconKey: '${json['icon'] ?? ''}',
        label: '${json['label'] ?? ''}',
        value: (json['value'] as num?)?.toDouble() ?? 0,
      );
}

class ReviewSummary {
  final double average;
  final int total;

  /// Qualitative label next to the score badge — `Istimewa`.
  final String label;
  final List<ReviewScore> breakdown;

  const ReviewSummary({
    required this.average,
    required this.total,
    this.label = '',
    this.breakdown = const [],
  });

  bool get isEmpty => total == 0;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => ReviewSummary(
        average: (json['average'] as num?)?.toDouble() ?? 0,
        total: json['total'] as int? ?? 0,
        label: '${json['label'] ?? ''}',
        breakdown: (json['breakdown'] as List<dynamic>? ?? const [])
            .map((e) => ReviewScore.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PropertyReview {
  final String authorName;
  final double score;

  /// `Sewa Harian` / `Sewa Bulanan` chip.
  final String periodLabel;
  final DateTime? createdAt;
  final String comment;

  const PropertyReview({
    required this.authorName,
    required this.score,
    this.periodLabel = '',
    this.createdAt,
    this.comment = '',
  });

  /// The list masks names — `Muhammad Cahyo` → `M******* C****`.
  String get maskedName => Fmt.maskName(authorName);

  factory PropertyReview.fromJson(Map<String, dynamic> json) => PropertyReview(
        authorName: '${json['user_name'] ?? json['author'] ?? ''}',
        score: (json['rating'] as num?)?.toDouble() ?? 0,
        periodLabel: '${json['period_label'] ?? ''}',
        createdAt: DateTime.tryParse('${json['created_at']}'),
        comment: '${json['comment'] ?? ''}',
      );
}

class PropertyQuestion {
  final String question;
  final String? answer;
  final String askedBy;
  final DateTime? createdAt;

  const PropertyQuestion({
    required this.question,
    this.answer,
    this.askedBy = '',
    this.createdAt,
  });

  factory PropertyQuestion.fromJson(Map<String, dynamic> json) =>
      PropertyQuestion(
        question: '${json['question'] ?? ''}',
        answer: json['answer'] as String?,
        askedBy: '${json['asked_by'] ?? ''}',
        createdAt: DateTime.tryParse('${json['created_at']}'),
      );
}

// --------------------------------------------------------------- aggregate

/// Everything the detail screen renders. One object, one screen — the four
/// tabs are anchors into this same payload, not separate requests.
class PropertyDetail {
  final int id;
  final String title;

  /// Amber tag left of the location pin — `Apartment`.
  final String typeLabel;

  /// Text next to the pin — `Pinangsia`.
  final String areaLabel;

  final List<GalleryItem> gallery;

  /// Drives the `+38` overlay on the last gallery thumbnail.
  final int extraMediaCount;

  final List<SpecItem> specs;
  final bool isFavorite;

  // reviews / discussion
  final ReviewSummary reviewSummary;
  final List<PropertyReview> reviews;
  final int questionCount;
  final List<PropertyQuestion> questions;

  // facilities
  final List<FacilityItem> bedFacilities;
  final List<FacilityItem> buildingFacilities;
  final List<String> buildingFacilitiesAll;
  final List<FacilityItem> roomFurniture;
  final List<RoomFurnitureGroup> roomFurnitureGroups;

  // info
  final List<InfoNote> checkInNotes;
  final num? depositAmount;
  final List<InfoNote> depositNotes;
  final List<UnitDetailRow> unitDetailRows;

  // details / location
  final String intro;
  final String description;

  /// Extra paragraphs + heading shown only inside the description sheet.
  final List<String> descriptionExtra;
  final String descriptionExtraHeading;

  final String address;
  final double? latitude;
  final double? longitude;

  /// Static map thumbnail. No maps package is installed (see README), so the
  /// card renders this image and deep-links out via `url_launcher`.
  final String? mapPreviewUrl;

  final List<NearbyPlace> nearbyPlaces;
  final List<GalleryItem> guestMedia;
  final BuildingUnitsTeaser? buildingUnits;

  // sticky bar
  /// `per bulan mulai dari` / `per tahun mulai dari`.
  final String priceCaption;
  final num priceAmount;
  final bool isFlashSale;

  const PropertyDetail({
    required this.id,
    required this.title,
    this.typeLabel = '',
    this.areaLabel = '',
    this.gallery = const [],
    this.extraMediaCount = 0,
    this.specs = const [],
    this.isFavorite = false,
    this.reviewSummary = const ReviewSummary(average: 0, total: 0),
    this.reviews = const [],
    this.questionCount = 0,
    this.questions = const [],
    this.bedFacilities = const [],
    this.buildingFacilities = const [],
    this.buildingFacilitiesAll = const [],
    this.roomFurniture = const [],
    this.roomFurnitureGroups = const [],
    this.checkInNotes = const [],
    this.depositAmount,
    this.depositNotes = const [],
    this.unitDetailRows = const [],
    this.intro = '',
    this.description = '',
    this.descriptionExtra = const [],
    this.descriptionExtraHeading = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.mapPreviewUrl,
    this.nearbyPlaces = const [],
    this.guestMedia = const [],
    this.buildingUnits,
    this.priceCaption = 'per bulan mulai dari',
    this.priceAmount = 0,
    this.isFlashSale = false,
  });

  bool get hasReviews => reviewSummary.total > 0;

  /// `Fasilitas Gedung` shows a `Lihat Semua (5)` link only when the full
  /// list is longer than the four visible tiles.
  int get buildingFacilitiesTotal => buildingFacilitiesAll.isEmpty
      ? buildingFacilities.length
      : buildingFacilitiesAll.length;

  factory PropertyDetail.fromJson(Map<String, dynamic> json) => PropertyDetail(
        id: json['id'] as int? ?? 0,
        title: '${json['name'] ?? json['title'] ?? ''}',
        typeLabel: '${json['type_label'] ?? ''}',
        areaLabel: '${json['area_label'] ?? json['city_name'] ?? ''}',
        gallery: _list(json['gallery'], GalleryItem.fromJson),
        extraMediaCount: json['extra_media_count'] as int? ?? 0,
        specs: _list(json['specs'], SpecItem.fromJson),
        isFavorite: json['is_favorite'] == true,
        reviewSummary: json['review_summary'] is Map<String, dynamic>
            ? ReviewSummary.fromJson(
                json['review_summary'] as Map<String, dynamic>)
            : const ReviewSummary(average: 0, total: 0),
        reviews: _list(json['reviews'], PropertyReview.fromJson),
        questionCount: json['question_count'] as int? ?? 0,
        questions: _list(json['questions'], PropertyQuestion.fromJson),
        bedFacilities: _list(json['bed_facilities'], FacilityItem.fromJson),
        buildingFacilities:
            _list(json['building_facilities'], FacilityItem.fromJson),
        buildingFacilitiesAll: _strings(json['building_facilities_all']),
        roomFurniture: _list(json['room_furniture'], FacilityItem.fromJson),
        roomFurnitureGroups:
            _list(json['room_furniture_groups'], RoomFurnitureGroup.fromJson),
        checkInNotes: _list(json['check_in_notes'], InfoNote.fromJson),
        depositAmount: json['deposit_amount'] as num?,
        depositNotes: _list(json['deposit_notes'], InfoNote.fromJson),
        unitDetailRows: _list(json['unit_detail'], UnitDetailRow.fromJson),
        intro: '${json['intro'] ?? ''}',
        description: '${json['description'] ?? ''}',
        descriptionExtra: _strings(json['description_extra']),
        descriptionExtraHeading: '${json['description_extra_heading'] ?? ''}',
        address: '${json['address'] ?? ''}',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        mapPreviewUrl: json['map_preview'] as String?,
        nearbyPlaces: _list(json['nearby'], NearbyPlace.fromJson),
        guestMedia: _list(json['guest_media'], GalleryItem.fromJson),
        buildingUnits: json['building_units'] is Map<String, dynamic>
            ? BuildingUnitsTeaser.fromJson(
                json['building_units'] as Map<String, dynamic>)
            : null,
        priceCaption: '${json['price_caption'] ?? 'per bulan mulai dari'}',
        priceAmount: (json['price_from'] as num?) ?? 0,
        isFlashSale: json['is_flash_sale'] == true,
      );

  PropertyDetail copyWith({bool? isFavorite}) => PropertyDetail(
        id: id,
        title: title,
        typeLabel: typeLabel,
        areaLabel: areaLabel,
        gallery: gallery,
        extraMediaCount: extraMediaCount,
        specs: specs,
        isFavorite: isFavorite ?? this.isFavorite,
        reviewSummary: reviewSummary,
        reviews: reviews,
        questionCount: questionCount,
        questions: questions,
        bedFacilities: bedFacilities,
        buildingFacilities: buildingFacilities,
        buildingFacilitiesAll: buildingFacilitiesAll,
        roomFurniture: roomFurniture,
        roomFurnitureGroups: roomFurnitureGroups,
        checkInNotes: checkInNotes,
        depositAmount: depositAmount,
        depositNotes: depositNotes,
        unitDetailRows: unitDetailRows,
        intro: intro,
        description: description,
        descriptionExtra: descriptionExtra,
        descriptionExtraHeading: descriptionExtraHeading,
        address: address,
        latitude: latitude,
        longitude: longitude,
        mapPreviewUrl: mapPreviewUrl,
        nearbyPlaces: nearbyPlaces,
        guestMedia: guestMedia,
        buildingUnits: buildingUnits,
        priceCaption: priceCaption,
        priceAmount: priceAmount,
        isFlashSale: isFlashSale,
      );
}

// ----------------------------------------------------------------- helpers

List<String> _strings(dynamic v) =>
    v is List ? v.map((e) => '$e').toList() : const <String>[];

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) parse) => v is List
    ? v.whereType<Map<String, dynamic>>().map(parse).toList(growable: false)
    : <T>[];
