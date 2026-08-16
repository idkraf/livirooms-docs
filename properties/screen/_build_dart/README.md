# `_build_dart` — Enhancement Implementation

> **Status**: implementation complete.
> **Scope**: merged legacy data models and UI into a single `Property` model; old UI now runs on the current `Property` class. Gallery stays flat `List<String>` per current development.

---

## 1. What Changed

### 1.1 Model merge: `property_detail.dart` → `property.dart`

`lib/models/property_detail.dart` was merged into `lib/models/property.dart`. No keys were duplicated or removed — existing `Property` fields were preserved, and all new fields from `PropertyDetail` were appended at the bottom.

**New nested types added to `property.dart`:**
- `MediaKind` enum, `GalleryItem` class
- `SpecItem`, `FacilityItem`, `RoomFurnitureGroup`
- `InfoTone` enum, `InfoNote`, `LabeledAmount`, `UnitDetailGroup`, `UnitDetailRow`
- `NearbyPlace`, `BuildingUnitsTeaser`
- `ReviewScore`, `ReviewSummary`, `PropertyReview`, `PropertyQuestion`

**New fields added to `Property` (at bottom of class):**
- `typeLabel`, `areaLabel`, `extraMediaCount`, `specs`, `isFavorite`
- `reviewSummary`, `reviews`, `questionCount`, `questions`
- `bedFacilities`, `buildingFacilities`, `buildingFacilitiesAll`
- `roomFurniture`, `roomFurnitureGroups`
- `checkInNotes`, `depositAmount`, `depositNotes`, `unitDetailRows`
- `intro`, `descriptionExtra`, `descriptionExtraHeading`
- `mapPreviewUrl`, `nearbyPlaces`, `guestMedia`
- `buildingUnits`, `priceCaption`, `priceAmount`, `isFlashSale`

`Property.fromJson` now parses all new keys. Existing key mappings were kept unchanged; new mappings were appended at the bottom.

Helper getters added:
- `List<GalleryItem> get galleryItems` — converts flat `gallery: List<String>` to `GalleryItem` objects for old widgets
- `bool get hasReviews`
- `int get buildingFacilitiesTotal`
- `Property copyWith({...})` — full copyWith for all fields

### 1.2 JSON merge: `GET_properties_id_detail.json` → `GET_properties_id.json`

All new keys from the detail payload were appended to `assets/GET_properties_id.json` inside the `data` object, after the existing keys. No existing keys were modified or reordered.

New keys added:
- `type_label`, `area_label`, `extra_media_count`
- `specs`, `is_favorite`, `intro`
- `description_extra`, `description_extra_heading`
- `map_preview`, `price_caption`, `is_flash_sale`
- `bed_facilities`, `building_facilities`, `building_facilities_all`
- `room_furniture`, `room_furniture_groups`
- `check_in_notes`, `deposit_amount`, `deposit_notes`
- `unit_detail`, `nearby`, `guest_media`
- `building_units`, `review_summary`, `reviews`, `question_count`, `questions`

`assets/GET_properties_id_detail.json` was deleted.

### 1.3 UI change: `property_detail_screen.dart` now uses old scroll-spy layout

`lib/screens/property/property_detail_screen.dart` was rewritten to match the old `property_detail_screen_old.dart` UI structure (scroll-spy with `Facilities | Info | Details | Location` anchors, sticky price bar, section sheets) but driven by the unified `Property` model.

Key differences from previous tab-based version:
- `CustomScrollView` with `SliverPersistentHeader` section strip
- Scroll-spy active tab derived from scroll offset
- Anchored section navigation via `_goToSection`
- `DetailGalleryHeader`, `DetailOverviewBlock`, `DetailActionRow`, `ReviewSummaryCard`
- `FacilitiesSection`, `InfoSection`, `IntroCard`, `LocationSection`, `DescriptionCard`
- `GuestMediaSection`, `BuildingUnitsCard`
- `StickyPriceBar` with caption, amount, flash-sale tag
- Data fetching preserved: `_fetchProperty`, `_loadReviews`, `_loadAvailability`, `_loadHost`
- Actions preserved: `_toggleFavorite`, `_chatHost`, `_bookNow`

### 1.4 All widgets and sheets updated to `Property`

Every widget and sheet that previously imported `models/property_detail.dart` now imports `models/property.dart`. Type parameters changed from `PropertyDetail` to `Property`.

| File | Change |
|---|---|
| `widgets/description_card.dart` | `PropertyDetail` → `Property` |
| `widgets/detail_overview_block.dart` | `PropertyDetail` → `Property` |
| `widgets/facility_grid.dart` | `PropertyDetail` → `Property` |
| `widgets/info_segmented.dart` | `PropertyDetail` → `Property` |
| `widgets/location_section.dart` | `PropertyDetail` → `Property` |
| `widgets/detail_gallery_header.dart` | receives `detail.galleryItems` (`List<GalleryItem>`) |
| `widgets/guest_media_section.dart` | receives `detail.guestMedia` (`List<GalleryItem>`) |
| `screens/property/sheets/description_sheet.dart` | `PropertyDetail` → `Property` |
| `screens/property/property_detail_screen_old.dart` | `PropertyDetail` → `Property` |

`property_detail_screen_old.dart` is kept as a reference copy of the old UI. It now compiles against `Property` as well.

### 1.5 `property_service.dart`

- `detailRich(int id)` now returns `Property` instead of `PropertyDetail`
- `pricing(int propertyId, {String? priceType})` unchanged — returns `UnitPricing`

### 1.6 Dummy API routes

`lib/services/dummy_api_client.dart` routes remain:
- `GET properties/{id}` → `GET_properties_id`
- `GET properties/{id}/detail` → `GET_properties_id_detail` (fixture deleted; route kept for compatibility)
- `GET properties/{id}/pricing` → `GET_properties_id_pricing`

---

## 2. Current File Map

```
lib/
  models/
    property.dart              ← unified model (old + new fields)
    property_recommendation.dart
    review.dart
    unit_pricing.dart
  screens/
    property/
      property_detail_screen.dart       ← old scroll-spy UI, Property model
      property_detail_screen_old.dart   ← reference copy, Property model
      rincian_unit_screen.dart
      sheets/
        building_facilities_sheet.dart
        description_sheet.dart
        payment_plan_sheet.dart
        qna_sheet.dart
        reviews_sheet.dart
        room_furniture_sheet.dart
  widgets/
    add_on_selector.dart
    building_units_card.dart
    description_card.dart
    detail_action_row.dart
    detail_gallery_header.dart
    detail_overview_block.dart
    detail_primitives.dart
    facility_grid.dart
    guest_media_section.dart
    inclusion_table.dart
    info_segmented.dart
    installment_schedule.dart
    location_section.dart
    price_summary_card.dart
    promo_row.dart
    property_card.dart
    review_summary_card.dart
    section_tab_strip.dart
    state_views.dart
    sticky_price_bar.dart
    unit_stay_card.dart
assets/
  GET_properties_id.json        ← merged detail + base payload
  GET_properties_id_pricing.json
  GET_properties_id_availability.json
  GET_properties_id_host.json
  GET_properties_id_reviews.json
  GET_properties.json
```

---

## 3. Gallery Contract

- `Property.gallery` is `List<String>` (flat URLs)
- `Property.guestMedia` is `List<GalleryItem>` (for guest media section)
- `Property.galleryItems` getter converts flat strings to `GalleryItem(url: ...)` for old widgets
- Current display in `property_detail_screen.dart` uses `DetailGalleryHeader` with `galleryItems`
- No `kind` (`photo`/`video`/`panorama`), no `thumbnailUrl`, no `extraMediaCount` in main gallery

---

## 4. Constraints

- **No changes to `flutter/lib/` or `laravel/`**
- **Single theme file**: `lib/config/theme.dart` contains both `AppColors`/`AppTheme` and legacy `DT` tokens
- **Single property model**: `lib/models/property.dart` contains all fields; `property_detail.dart` deleted
- **Gallery stays flat** — no backend schema changes

---

## 5. Verification Checklist

- [ ] `Property.fromJson` parses `assets/GET_properties_id.json` without errors
- [ ] `UnitPricing.fromJson` parses `assets/GET_properties_id_pricing.json` without errors
- [ ] `DummyApiClient` serves both fixtures via `_loadEnvelope`
- [ ] `PropertyService.detail(1)` returns a fully populated `Property`
- [ ] `PropertyService.pricing(1, priceType: 'monthly')` returns a fully populated `UnitPricing`
- [ ] `property_detail_screen.dart` renders old scroll-spy UI with `Property` data
- [ ] `property_detail_screen_old.dart` compiles against `Property`
- [ ] All widgets and sheets compile against `Property`
- [ ] No remaining references to `property_detail.dart` or `PropertyDetail` type
