# `_build_dart` — Property Module Implementation

> **Status**: implementation complete.
> **Scope**: merged legacy data models and UI into a single `Property` model; old UI now runs on the current `Property` class. Gallery stays flat `List<String>` per current development.
> **Related docs**: see `docs\properties\screen\_build_laravel\` for Laravel API design, migrations, and seeders.

---

## 1. Flutter File Inventory

### 1.1 Models (`lib/models/`)

| File | Classes / Types | Purpose |
|---|---|---|
| `property.dart` | `PropertyPrice`, `Property`, `MediaKind`, `GalleryItem`, `SpecItem`, `FacilityItem`, `RoomFurnitureGroup`, `InfoTone`, `InfoNote`, `LabeledAmount`, `UnitDetailGroup`, `UnitDetailRow`, `NearbyPlace`, `BuildingUnitsTeaser`, `ReviewScore`, `ReviewSummary`, `PropertyReview`, `PropertyQuestion` | Unified property model — contains all fields from old `property_detail.dart` plus original `Property` fields |
| `review.dart` | `Review` | Paginated review item from `/properties/{id}/reviews` |
| `unit_pricing.dart` | `RentalPeriod`, `RentalPeriodX`, `InclusionList`, `SpecialPriceTier`, `AddOn`, `InstallmentEntry`, `InstallmentPlan`, `AppliedPromo`, `SummaryLine`, `UnitPricing` | Pricing detail for `RincianUnitScreen` |
| `host_info.dart` | `HostInfo` | Host profile from `/properties/{id}/host` |
| `paginated.dart` | `Paginated<T>` | Generic paginated envelope |
| `api_response.dart` | `ApiResponse` | API envelope parser |
| `chat.dart` | `Conversation`, `Message` | Chat payloads |
| `insurance_plan.dart` | `InsurancePlan` | Insurance options |
| `property_recommendation.dart` | `PropertyRecommendation` | Recommendation item |

### 1.2 Screens (`lib/screens/property/`)

| File | Widget | Purpose |
|---|---|---|
| `property_detail_screen.dart` | `PropertyDetailScreen` | Main detail screen — scroll-spy layout with anchored sections |
| `property_detail_screen_old.dart` | `PropertyDetailScreen` | Reference copy of old scroll-spy UI |
| `rincian_unit_screen.dart` | `RincianUnitScreen` | Unit pricing / booking draft screen |

### 1.3 Sheets (`lib/screens/property/sheets/`)

| File | Widget | Purpose |
|---|---|---|
| `building_facilities_sheet.dart` | `BuildingFacilitiesSheet` | Full building facilities list |
| `description_sheet.dart` | `DescriptionSheet` | Full description with extra paragraphs |
| `payment_plan_sheet.dart` | `PaymentPlanSheet` | Installment plan picker |
| `qna_sheet.dart` | `QnaSheet` | Questions & answers |
| `reviews_sheet.dart` | `ReviewsSheet` | Full reviews list |
| `room_furniture_sheet.dart` | `RoomFurnitureSheet` | Room furniture grouped by room |

### 1.4 Widgets (`lib/widgets/`)

| File | Widget | Purpose |
|---|---|---|
| `detail_gallery_header.dart` | `DetailGalleryHeader` | Collapsing gallery hero + thumbnails |
| `detail_overview_block.dart` | `DetailOverviewBlock` | Title, type tag, area, specs strip |
| `detail_action_row.dart` | `DetailActionRow` | Reviews / discussion / share actions |
| `review_summary_card.dart` | `ReviewSummaryCard` | Score breakdown + review preview |
| `facility_grid.dart` | `FacilitiesSection` | Bed / building / room furniture grids |
| `info_segmented.dart` | `InfoSection` | Check-in / deposit / unit detail tabs |
| `location_section.dart` | `LocationSection` | Map preview + nearby places |
| `description_card.dart` | `DescriptionCard` | Description + nearby places mini-grid |
| `guest_media_section.dart` | `GuestMediaSection` | Horizontal guest media scroll |
| `building_units_card.dart` | `BuildingUnitsCard` | Building units teaser |
| `section_tab_strip.dart` | `SectionTabStripDelegate` | Pinned section navigator |
| `sticky_price_bar.dart` | `StickyPriceBar` | Bottom price bar with PESAN / HUBUNGI HOST |
| `detail_primitives.dart` | `SectionHeader`, `ToneTag`, `BrandButton`, `BrandOutlineButton`, etc. | Shared primitives |
| `add_on_selector.dart` | `AddOnSelector` | Add-on toggles for pricing |
| `inclusion_table.dart` | `InclusionTable` | Included / excluded amenities |
| `installment_schedule.dart` | `InstallmentSchedule` | Installment timeline |
| `price_summary_card.dart` | `PriceSummaryCard` | Price breakdown card |
| `promo_row.dart` | `PromoRow` | Promo code input |
| `unit_stay_card.dart` | `UnitStayCard` | Stay duration selector |
| `property_card.dart` | `PropertyCard` | Search result card |
| `state_views.dart` | `LoadingView`, `ErrorView`, `EmptyView` | State placeholders |
| `app_network_image.dart` | `NetImage` | Network image with placeholder |

### 1.5 Services (`lib/services/`)

| File | Class | Methods |
|---|---|---|
| `property_service.dart` | `PropertyService` | `search()`, `detail()`, `detailRich()`, `pricing()`, `reviews()`, `availability()`, `host()`, `getInsurancePlans()` |
| `chat_service.dart` | `ChatService` | `conversations()`, `start()`, `messages()`, `send()` |
| `wishlist_service.dart` | `WishlistService` | `toggle()` |
| `api_client.dart` | `ApiClient` | HTTP transport |
| `dummy_api_client.dart` | `DummyApiClient` | Local JSON fixture transport |

### 1.6 Config & Utils

| File | Purpose |
|---|---|
| `config/theme.dart` | `AppColors`, `AppTheme`, legacy `DT` tokens |
| `utils/fmt.dart` | `Fmt.idr()`, `Fmt.maskName()` |
| `utils/formatters.dart` | Additional formatters |
| `utils/detail_icons.dart` | Icon map for detail screen |
| `router.dart` | Route constants + `RouteTable` |

---

## 2. API Contract

### 2.1 Endpoints used by `property_detail_screen.dart`

| Method | Endpoint | Service method | Fixture | Response type |
|---|---|---|---|---|
| `GET` | `/properties/{id}` | `PropertyService.detail(id)` | `GET_properties_id.json` | `Property` |
| `GET` | `/properties/{id}/reviews?page=1` | `PropertyService.reviews(id)` | `GET_properties_id_reviews.json` | `Paginated<Review>` |
| `GET` | `/properties/{id}/availability` | `PropertyService.availability(id)` | `GET_properties_id_availability.json` | `List<String>` (blocked dates) |
| `GET` | `/properties/{id}/host` | `PropertyService.host(id)` | `GET_properties_id_host.json` | `HostInfo` |
| `POST` | `/conversations` | `ChatService.start(recipientId, propertyId)` | `POST_conversations.json` | `Conversation` |
| `GET` | `/properties/{id}/pricing?price_type={type}` | `PropertyService.pricing(id, priceType)` | `GET_properties_id_pricing.json` | `UnitPricing` |

### 2.2 Dummy API routes

Defined in `lib/services/dummy_api_client.dart`:

```
'GET properties/{id}'              -> GET_properties_id
'GET properties/{id}/reviews'      -> GET_properties_id_reviews
'GET properties/{id}/availability' -> GET_properties_id_availability
'GET properties/{id}/host'         -> GET_properties_id_host
'POST conversations'               -> POST_conversations
'GET properties/{id}/pricing'      -> GET_properties_id_pricing
```

### 2.3 Envelope format

All endpoints return:

```json
{
  "status": true,
  "code": 200,
  "message": "...",
  "data": { ... },
  "meta": null,
  "errors": null
}
```

`meta` is used for pagination in list endpoints.

---

## 3. Model Merge: `property_detail.dart` → `property.dart`

### 3.1 What was merged

All nested types from `property_detail.dart` were appended to `property.dart`:

| Type | Purpose |
|---|---|
| `MediaKind` enum | Photo / video / panorama |
| `GalleryItem` | Gallery item with kind + thumbnail |
| `SpecItem` | Icon strip entry (Full Furnished, 2, 100m2) |
| `FacilityItem` | Facility tile with note + count |
| `RoomFurnitureGroup` | Room furniture grouped by room name |
| `InfoTone` enum | warning / brand / info / success |
| `InfoNote` | Check-in / deposit info panel |
| `LabeledAmount` | Money line (Biaya kartu : 50,000) |
| `UnitDetailGroup` | Sub-group under Parkir (Mobil / Motor) |
| `UnitDetailRow` | Unit detail row (Gedung, Tower, Lantai, Parkir) |
| `NearbyPlace` | Nearby place entry |
| `BuildingUnitsTeaser` | Building units teaser card |
| `ReviewScore` | Score breakdown entry |
| `ReviewSummary` | Review summary + breakdown |
| `PropertyReview` | Individual review |
| `PropertyQuestion` | Q&A entry |

### 3.2 New `Property` fields (appended at bottom)

| Field | Type | JSON key | Default |
|---|---|---|---|
| `typeLabel` | `String` | `type_label` | `''` |
| `areaLabel` | `String` | `area_label` / `city_name` | `''` |
| `extraMediaCount` | `int` | `extra_media_count` | `0` |
| `specs` | `List<SpecItem>` | `specs` | `[]` |
| `isFavorite` | `bool` | `is_favorite` | `false` |
| `reviewSummary` | `ReviewSummary` | `review_summary` | empty |
| `reviews` | `List<PropertyReview>` | `reviews` | `[]` |
| `questionCount` | `int` | `question_count` | `0` |
| `questions` | `List<PropertyQuestion>` | `questions` | `[]` |
| `bedFacilities` | `List<FacilityItem>` | `bed_facilities` | `[]` |
| `buildingFacilities` | `List<FacilityItem>` | `building_facilities` | `[]` |
| `buildingFacilitiesAll` | `List<String>` | `building_facilities_all` | `[]` |
| `roomFurniture` | `List<FacilityItem>` | `room_furniture` | `[]` |
| `roomFurnitureGroups` | `List<RoomFurnitureGroup>` | `room_furniture_groups` | `[]` |
| `checkInNotes` | `List<InfoNote>` | `check_in_notes` | `[]` |
| `depositAmount` | `num?` | `deposit_amount` | `null` |
| `depositNotes` | `List<InfoNote>` | `deposit_notes` | `[]` |
| `unitDetailRows` | `List<UnitDetailRow>` | `unit_detail` | `[]` |
| `intro` | `String` | `intro` | `''` |
| `descriptionExtra` | `List<String>` | `description_extra` | `[]` |
| `descriptionExtraHeading` | `String` | `description_extra_heading` | `''` |
| `mapPreviewUrl` | `String?` | `map_preview` | `null` |
| `nearbyPlaces` | `List<NearbyPlace>` | `nearby` | `[]` |
| `guestMedia` | `List<GalleryItem>` | `guest_media` | `[]` |
| `buildingUnits` | `BuildingUnitsTeaser?` | `building_units` | `null` |
| `priceCaption` | `String` | `price_caption` | `'per bulan mulai dari'` |
| `priceAmount` | `num` | `price_from` | `0` |
| `isFlashSale` | `bool` | `is_flash_sale` | `false` |

### 3.3 Helper getters

| Getter | Returns | Purpose |
|---|---|---|
| `galleryItems` | `List<GalleryItem>` | Converts flat `gallery: List<String>` to `GalleryItem(url: ...)` for old widgets |
| `hasReviews` | `bool` | `reviewSummary.total > 0` |
| `buildingFacilitiesTotal` | `int` | `buildingFacilitiesAll.isEmpty ? buildingFacilities.length : buildingFacilitiesAll.length` |

### 3.4 `copyWith`

Full `copyWith` supports all fields (original + new) for immutable updates.

---

## 4. JSON Merge: `GET_properties_id_detail.json` → `GET_properties_id.json`

### 4.1 New keys appended

All 27 new keys from the detail payload were appended to `assets/GET_properties_id.json` inside the `data` object. No existing keys were modified or reordered.

| New key | Type | Source |
|---|---|---|
| `type_label` | string | `property_type` label |
| `area_label` | string | `city_name` / `province` |
| `extra_media_count` | int | gallery extra count |
| `specs` | array | icon strip |
| `is_favorite` | bool | favorite flag |
| `intro` | string | intro text |
| `description_extra` | array | extra description paragraphs |
| `description_extra_heading` | string | extra description heading |
| `map_preview` | string | static map thumbnail |
| `price_caption` | string | sticky bar caption |
| `is_flash_sale` | bool | flash sale flag |
| `bed_facilities` | array | bed facility tiles |
| `building_facilities` | array | building facility tiles |
| `building_facilities_all` | array | full building facilities list |
| `room_furniture` | array | room furniture tiles |
| `room_furniture_groups` | array | room furniture grouped |
| `check_in_notes` | array | check-in info notes |
| `deposit_amount` | number | deposit amount |
| `deposit_notes` | array | deposit info notes |
| `unit_detail` | array | unit detail rows |
| `nearby` | array | nearby places |
| `guest_media` | array | guest media gallery |
| `building_units` | object | building units teaser |
| `review_summary` | object | review summary + breakdown |
| `reviews` | array | review items |
| `question_count` | int | question count |
| `questions` | array | Q&A items |

`assets/GET_properties_id_detail.json` was deleted.

---

## 5. UI Architecture: `property_detail_screen.dart`

### 5.1 Layout

```
Scaffold
  CustomScrollView
    SliverAppBar (pinned, collapsing)
      DetailGalleryHeader
    SliverToBoxAdapter
      DetailOverviewBlock
      DetailActionRow
      ReviewSummaryCard (conditional)
    SliverPersistentHeader (pinned)
      SectionTabStripDelegate [Facilities | Info | Details | Location]
    SliverToBoxAdapter
      FacilitiesSection (_facilitiesKey)
      InfoSection (_infoKey)
      IntroCard (_detailsKey)
      LocationSection (_locationKey)
      DescriptionCard
      GuestMediaSection (conditional)
      BuildingUnitsCard (conditional)
  bottomNavigationBar
    StickyPriceBar
```

### 5.2 Scroll-spy

- `_controller` listens to scroll offset
- `_anchorOffset()` computes offset for each section key
- `_activeTab` updates when scroll crosses section anchor
- `_goToSection()` animates to anchor when tab is tapped

### 5.3 Data flow

1. `initState()`: if `widget.property` is null, call `_fetchProperty()`; else use pre-loaded property
2. `_fetchProperty()`: calls `PropertyService.detail(id)`, then `_loadReviews()`, `_loadAvailability()`, `_loadHost()`
3. `_loadReviews()`: calls `PropertyService.reviews(id)`, takes first 3
4. `_loadAvailability()`: calls `PropertyService.availability(id)`, stores blocked dates
5. `_loadHost()`: calls `PropertyService.host(id)`, stores host info

### 5.4 Actions

| Action | Method | Destination |
|---|---|---|
| `PILIH UNIT` | `_bookNow()` | `RincianUnitScreen` with fetched `UnitPricing` per period |
| `HUBUNGI HOST` | `_chatHost()` | `ChatRoomScreen` |
| Favorite toggle | `_toggleFavorite()` | `widget.onFavoriteChanged` |
| Review tap | `_openReviews()` | `ReviewsSheet` |
| Discussion tap | `_openDiscussion()` | `QnaSheet` |
| Building facilities | `_openBuildingFacilities()` | `BuildingFacilitiesSheet` |
| Room furniture | `_openRoomFurniture()` | `RoomFurnitureSheet` |
| Description | `_openDescription()` | `DescriptionSheet` |
| Map tap | `_openMap()` | External Google Maps URL |
| Share | `widget.onShare` | Host app callback |

### 5.5 `_bookNow()` flow

1. Verify auth (redirect to login if needed)
2. Extract unique `priceType` values from `Property.prices`
3. Map to `RentalPeriod` enum
4. Fetch `UnitPricing` for each period via `PropertyService.pricing()`
5. Navigate to `RincianUnitScreen` with `Map<RentalPeriod, UnitPricing>`

---

## 6. `RincianUnitScreen` Wiring

| Prop | Type | Source |
|---|---|---|
| `pricing` | `Map<RentalPeriod, UnitPricing>` | Fetched by `_bookNow()` |
| `initialPeriod` | `RentalPeriod` | First period from property prices |
| `onPeriodChanged` | `ValueChanged<RentalPeriod>` | Not used in demo |
| `onSubmit` | `ValueChanged<BookingDraft>` | SnackBar confirmation |

`BookingDraft` contains: `period`, `duration`, `checkIn`, `checkOut`, `addOnIds`, `planId`, `promoCode`, `payableAmount`.

---

## 7. Theme Consolidation

Single source of truth: `lib/config/theme.dart` (294 lines).

- `AppColors` — brand palette (Navy `#0E2340`, Gold `#F4A93B`, etc.)
- `AppTheme` — Material 3 theme
- Legacy `DT` tokens — `DT.canvas`, `DT.surface`, `DT.textPrimary`, `DT.divider`, `DT.brand`, `DT.accent`, `DT.gutter`, `DT.cardRadius`, `DT.tileRadius`, `DT.tabStripHeight`, `DT.sectionGap`, `DT.fade()`, `DT.pastels`, etc.

Old `lib/theme/detail_tokens.dart` was deleted. All widgets now import `../config/theme.dart` or `../../config/theme.dart`.

---

## 8. Gallery Contract

- `Property.gallery` is `List<String>` (flat URLs)
- `Property.guestMedia` is `List<GalleryItem>` (for guest media section)
- `Property.galleryItems` getter converts flat strings to `GalleryItem(url: ...)` for old widgets
- Current display in `property_detail_screen.dart` uses `DetailGalleryHeader` with `galleryItems`
- No `kind` (`photo`/`video`/`panorama`), no `thumbnailUrl`, no `extraMediaCount` in main gallery

---

## 9. Dummy API Fixtures

### 9.1 Available fixtures

| Fixture | Endpoint | Used by |
|---|---|---|
| `GET_properties_id.json` | `GET /properties/{id}` | `_fetchProperty()` |
| `GET_properties_id_reviews.json` | `GET /properties/{id}/reviews` | `_loadReviews()` |
| `GET_properties_id_availability.json` | `GET /properties/{id}/availability` | `_loadAvailability()` |
| `GET_properties_id_host.json` | `GET /properties/{id}/host` | `_loadHost()` |
| `GET_properties_id_pricing.json` | `GET /properties/{id}/pricing` | `_bookNow()` → `RincianUnitScreen` |
| `POST_conversations.json` | `POST /conversations` | `_chatHost()` |

### 9.2 Fixture compatibility

- `GET_properties_id.json` contains all 53 keys required by `Property.fromJson`
- `GET_properties_id_reviews.json` matches `Paginated<Review>` envelope
- `GET_properties_id_availability.json` matches `List<String>` blocked dates
- `GET_properties_id_host.json` matches `HostInfo.fromJson`
- `GET_properties_id_pricing.json` matches `UnitPricing.fromJson`
- `POST_conversations.json` matches `Conversation.fromJson`

---

## 10. Constraints

- **No changes to `flutter/lib/` or `laravel/`**
- **Single theme file**: `lib/config/theme.dart`
- **Single property model**: `lib/models/property.dart`
- **Gallery stays flat** — no backend schema changes

---

## 11. Verification Checklist

- [x] `Property.fromJson` parses `assets/GET_properties_id.json` without errors
- [x] `UnitPricing.fromJson` parses `assets/GET_properties_id_pricing.json` without errors
- [x] `DummyApiClient` serves all fixtures via `_loadEnvelope`
- [x] `PropertyService.detail(1)` returns a fully populated `Property`
- [x] `PropertyService.pricing(1, priceType: 'monthly')` returns a fully populated `UnitPricing`
- [x] `property_detail_screen.dart` renders old scroll-spy UI with `Property` data
- [x] `property_detail_screen_old.dart` compiles against `Property`
- [x] All widgets and sheets compile against `Property`
- [x] No remaining references to `property_detail.dart` or `PropertyDetail` type
- [x] `_bookNow()` navigates to `RincianUnitScreen` with fetched pricing data

---

## 12. Related Documentation

- **Laravel API design**: `docs\properties\screen\_build_laravel\docs\API_SPEC.md`
- **Laravel migrations**: `docs\properties\screen\_build_laravel\database\migrations\`
- **Laravel seeders**: `docs\properties\screen\_build_laravel\database\seeders\`
