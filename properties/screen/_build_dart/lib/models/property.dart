class PropertyPrice {
  final String priceType; // daily | weekly | monthly | yearly
  final double amount;
  final double? cleaningFee;
  final double? deposit;
  final double? serviceFee;

  PropertyPrice({
    required this.priceType,
    required this.amount,
    this.cleaningFee,
    this.deposit,
    this.serviceFee,
  });

  factory PropertyPrice.fromJson(Map<String, dynamic> json) => PropertyPrice(
        priceType: json['price_type'] as String,
        amount: _toDouble(json['amount']),
        cleaningFee: _toDoubleOrNull(json['cleaning_fee']),
        deposit: _toDoubleOrNull(json['deposit']),
        serviceFee: _toDoubleOrNull(json['service_fee']),
      );
}

// ------------------------------------------------------------------ gallery

enum MediaKind { photo, video, panorama }

class GalleryItem {
  final String url;
  final MediaKind kind;
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

  factory GalleryItem.fromUrl(String url) => GalleryItem(url: url);

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

class RoomFurnitureGroup {
  final String roomName;
  final List<String> items;
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

enum InfoTone { warning, brand, info, success }

class InfoNote {
  final String iconKey;
  final InfoTone tone;
  final String title;
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

class LabeledAmount {
  final String label;
  final num amount;

  const LabeledAmount({required this.label, required this.amount});

  String get display => '$label : $amount';

  factory LabeledAmount.fromJson(Map<String, dynamic> json) => LabeledAmount(
        label: '${json['label'] ?? ''}',
        amount: (json['amount'] as num?) ?? 0,
      );
}

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

  String get maskedName {
    final parts = authorName.split(' ');
    return parts.map((p) {
      if (p.isEmpty) return p;
      return p[0] + '*' * (p.length - 1);
    }).join(' ');
  }

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

// ------------------------------------------------------------------ main

class Property {
  final int id;
  final int hostId;
  final int? cityId;
  final String? cityName;
  final String? province;
  final String propertyType;
  final String bookingMode; // 'unit' | 'room'
  final String name;
  final String? buildingName;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final int guestCapacity;
  final int bedrooms;
  final List<String> facilities;
  final List<String> gallery;
  final String? cover;
  final String status;
  final double? priceFrom;
  final double? rating;
  final int? reviewCount;
  final List<PropertyPrice> prices;

  // Hotel-specific fields
  final int? starRating;
  final String? checkInTime;
  final String? checkOutTime;
  final bool hasBreakfast;

  // Rich detail fields (new, added at bottom)
  final String typeLabel;
  final String areaLabel;
  final int extraMediaCount;
  final List<SpecItem> specs;
  final bool isFavorite;
  final ReviewSummary reviewSummary;
  final List<PropertyReview> reviews;
  final int questionCount;
  final List<PropertyQuestion> questions;
  final List<FacilityItem> bedFacilities;
  final List<FacilityItem> buildingFacilities;
  final List<String> buildingFacilitiesAll;
  final List<FacilityItem> roomFurniture;
  final List<RoomFurnitureGroup> roomFurnitureGroups;
  final List<InfoNote> checkInNotes;
  final num? depositAmount;
  final List<InfoNote> depositNotes;
  final List<UnitDetailRow> unitDetailRows;
  final String intro;
  final List<String> descriptionExtra;
  final String descriptionExtraHeading;
  final String? mapPreviewUrl;
  final List<NearbyPlace> nearbyPlaces;
  final List<GalleryItem> guestMedia;
  final BuildingUnitsTeaser? buildingUnits;
  final String priceCaption;
  final num priceAmount;
  final bool isFlashSale;

  Property({
    required this.id,
    required this.hostId,
    this.cityId,
    this.cityName,
    this.province,
    required this.propertyType,
    this.bookingMode = 'unit',
    required this.name,
    this.buildingName,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.guestCapacity,
    required this.bedrooms,
    required this.facilities,
    required this.gallery,
    this.cover,
    required this.status,
    this.priceFrom,
    this.rating,
    this.reviewCount,
    this.prices = const [],
    this.starRating,
    this.checkInTime,
    this.checkOutTime,
    this.hasBreakfast = false,
    this.typeLabel = '',
    this.areaLabel = '',
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
    this.descriptionExtra = const [],
    this.descriptionExtraHeading = '',
    this.mapPreviewUrl,
    this.nearbyPlaces = const [],
    this.guestMedia = const [],
    this.buildingUnits,
    this.priceCaption = 'per bulan mulai dari',
    this.priceAmount = 0,
    this.isFlashSale = false,
  });

  List<GalleryItem> get galleryItems =>
      gallery.map((url) => GalleryItem(url: url)).toList();

  bool get hasReviews => reviewSummary.total > 0;

  int get buildingFacilitiesTotal => buildingFacilitiesAll.isEmpty
      ? buildingFacilities.length
      : buildingFacilitiesAll.length;

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['id'] as int,
        hostId: json['host_id'] as int? ?? 0,
        cityId: json['city_id'] as int?,
        cityName: json['city_name'] as String?,
        province: json['province'] as String?,
        propertyType: json['property_type'] as String? ?? '',
        bookingMode: json['booking_mode'] as String? ?? 'unit',
        name: json['name'] as String? ?? '',
        buildingName: json['building_name'] as String?,
        description: json['description'] as String?,
        address: json['address'] as String? ?? '',
        latitude: _toDoubleOrNull(json['latitude']),
        longitude: _toDoubleOrNull(json['longitude']),
        guestCapacity: json['guest_capacity'] as int? ?? 1,
        bedrooms: json['bedrooms'] as int? ?? 1,
        facilities: _toStringList(json['facilities']),
        gallery: _toStringList(json['gallery']),
        cover: (json['cover'] ?? json['cover_image']) as String?,
        status: json['status'] as String? ?? 'active',
        priceFrom: _toDoubleOrNull(json['price_from']),
        rating: _toDoubleOrNull(json['rating']),
        reviewCount: json['review_count'] as int?,
        prices: (json['prices'] as List<dynamic>? ?? const [])
            .map((e) => PropertyPrice.fromJson(e as Map<String, dynamic>))
            .toList(),
        starRating: json['star_rating'] as int?,
        checkInTime: json['check_in_time'] as String?,
        checkOutTime: json['check_out_time'] as String?,
        hasBreakfast: json['has_breakfast'] == true || json['has_breakfast'] == 1,
        typeLabel: '${json['type_label'] ?? ''}',
        areaLabel: '${json['area_label'] ?? json['city_name'] ?? ''}',
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
        descriptionExtra: _strings(json['description_extra']),
        descriptionExtraHeading: '${json['description_extra_heading'] ?? ''}',
        mapPreviewUrl: json['map_preview'] as String?,
        nearbyPlaces: _list(json['nearby'], NearbyPlace.fromJson),
        guestMedia: _guestMediaList(json['guest_media']),
        buildingUnits: json['building_units'] is Map<String, dynamic>
            ? BuildingUnitsTeaser.fromJson(
                json['building_units'] as Map<String, dynamic>)
            : null,
        priceCaption: '${json['price_caption'] ?? 'per bulan mulai dari'}',
        priceAmount: (json['price_from'] as num?) ?? 0,
        isFlashSale: json['is_flash_sale'] == true,
      );

  Property copyWith({
    int? id,
    int? hostId,
    int? cityId,
    String? cityName,
    String? province,
    String? propertyType,
    String? bookingMode,
    String? name,
    String? buildingName,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? guestCapacity,
    int? bedrooms,
    List<String>? facilities,
    List<String>? gallery,
    String? cover,
    String? status,
    double? priceFrom,
    double? rating,
    int? reviewCount,
    List<PropertyPrice>? prices,
    int? starRating,
    String? checkInTime,
    String? checkOutTime,
    bool? hasBreakfast,
    String? typeLabel,
    String? areaLabel,
    int? extraMediaCount,
    List<SpecItem>? specs,
    bool? isFavorite,
    ReviewSummary? reviewSummary,
    List<PropertyReview>? reviews,
    int? questionCount,
    List<PropertyQuestion>? questions,
    List<FacilityItem>? bedFacilities,
    List<FacilityItem>? buildingFacilities,
    List<String>? buildingFacilitiesAll,
    List<FacilityItem>? roomFurniture,
    List<RoomFurnitureGroup>? roomFurnitureGroups,
    List<InfoNote>? checkInNotes,
    num? depositAmount,
    List<InfoNote>? depositNotes,
    List<UnitDetailRow>? unitDetailRows,
    String? intro,
    List<String>? descriptionExtra,
    String? descriptionExtraHeading,
    String? mapPreviewUrl,
    List<NearbyPlace>? nearbyPlaces,
    List<GalleryItem>? guestMedia,
    BuildingUnitsTeaser? buildingUnits,
    String? priceCaption,
    num? priceAmount,
    bool? isFlashSale,
  }) =>
      Property(
        id: id ?? this.id,
        hostId: hostId ?? this.hostId,
        cityId: cityId ?? this.cityId,
        cityName: cityName ?? this.cityName,
        province: province ?? this.province,
        propertyType: propertyType ?? this.propertyType,
        bookingMode: bookingMode ?? this.bookingMode,
        name: name ?? this.name,
        buildingName: buildingName ?? this.buildingName,
        description: description ?? this.description,
        address: address ?? this.address,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        guestCapacity: guestCapacity ?? this.guestCapacity,
        bedrooms: bedrooms ?? this.bedrooms,
        facilities: facilities ?? this.facilities,
        gallery: gallery ?? this.gallery,
        cover: cover ?? this.cover,
        status: status ?? this.status,
        priceFrom: priceFrom ?? this.priceFrom,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        prices: prices ?? this.prices,
        starRating: starRating ?? this.starRating,
        checkInTime: checkInTime ?? this.checkInTime,
        checkOutTime: checkOutTime ?? this.checkOutTime,
        hasBreakfast: hasBreakfast ?? this.hasBreakfast,
        typeLabel: typeLabel ?? this.typeLabel,
        areaLabel: areaLabel ?? this.areaLabel,
        extraMediaCount: extraMediaCount ?? this.extraMediaCount,
        specs: specs ?? this.specs,
        isFavorite: isFavorite ?? this.isFavorite,
        reviewSummary: reviewSummary ?? this.reviewSummary,
        reviews: reviews ?? this.reviews,
        questionCount: questionCount ?? this.questionCount,
        questions: questions ?? this.questions,
        bedFacilities: bedFacilities ?? this.bedFacilities,
        buildingFacilities: buildingFacilities ?? this.buildingFacilities,
        buildingFacilitiesAll: buildingFacilitiesAll ?? this.buildingFacilitiesAll,
        roomFurniture: roomFurniture ?? this.roomFurniture,
        roomFurnitureGroups: roomFurnitureGroups ?? this.roomFurnitureGroups,
        checkInNotes: checkInNotes ?? this.checkInNotes,
        depositAmount: depositAmount ?? this.depositAmount,
        depositNotes: depositNotes ?? this.depositNotes,
        unitDetailRows: unitDetailRows ?? this.unitDetailRows,
        intro: intro ?? this.intro,
        descriptionExtra: descriptionExtra ?? this.descriptionExtra,
        descriptionExtraHeading:
            descriptionExtraHeading ?? this.descriptionExtraHeading,
        mapPreviewUrl: mapPreviewUrl ?? this.mapPreviewUrl,
        nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
        guestMedia: guestMedia ?? this.guestMedia,
        buildingUnits: buildingUnits ?? this.buildingUnits,
        priceCaption: priceCaption ?? this.priceCaption,
        priceAmount: priceAmount ?? this.priceAmount,
        isFlashSale: isFlashSale ?? this.isFlashSale,
      );
}

// ----------------------------------------------------------------- helpers

List<String> _strings(dynamic v) =>
    v is List ? v.map((e) => '$e').toList() : const <String>[];

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) parse) =>
    v is List
        ? v.whereType<Map<String, dynamic>>().map(parse).toList(growable: false)
        : <T>[];

List<GalleryItem> _guestMediaList(dynamic v) {
  if (v is List) {
    return v.map((e) {
      if (e is String) return GalleryItem(url: e);
      if (e is Map<String, dynamic>) return GalleryItem.fromJson(e);
      return const GalleryItem(url: '');
    }).toList(growable: false);
  }
  return const <GalleryItem>[];
}

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
double? _toDoubleOrNull(dynamic v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
