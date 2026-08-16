# Property Module — Laravel API Design

> **Isolation folder**: `docs\properties\screen\_build_laravel\`
> **Status**: design complete — no production files modified.

---

## 1. Flutter Contract Reference

All Laravel responses must satisfy the Flutter model contract defined in `_build_dart\lib\models\property.dart`.

### 1.1 Property model keys

| Flutter field | Type | JSON key | DB column / source |
|---|---|---|---|
| `id` | `int` | `id` | `properties.id` |
| `hostId` | `int` | `host_id` | `properties.host_id` |
| `cityId` | `int?` | `city_id` | `properties.city_id` |
| `cityName` | `String?` | `city_name` | `cities.name` (joined) |
| `province` | `String?` | `province` | `properties.province` |
| `propertyType` | `String` | `property_type` | `properties.property_type` |
| `bookingMode` | `String` | `booking_mode` | `properties.booking_mode` |
| `name` | `String` | `name` | `properties.name` |
| `buildingName` | `String?` | `building_name` | `properties.building_name` |
| `description` | `String?` | `description` | `properties.description` |
| `address` | `String` | `address` | `properties.address` |
| `latitude` | `double?` | `latitude` | `properties.latitude` |
| `longitude` | `double?` | `longitude` | `properties.longitude` |
| `guestCapacity` | `int` | `guest_capacity` | `properties.guest_capacity` |
| `bedrooms` | `int` | `bedrooms` | `properties.bedrooms` |
| `facilities` | `List<String>` | `facilities` | `properties.facilities` (json) |
| `gallery` | `List<String>` | `gallery` | `properties.gallery` (json) |
| `cover` | `String?` | `cover` / `cover_image` | `properties.cover` / `properties.cover_image` |
| `status` | `String` | `status` | `properties.status` |
| `priceFrom` | `double?` | `price_from` | `properties.price_from` |
| `rating` | `double?` | `rating` | `properties.rating` |
| `reviewCount` | `int?` | `review_count` | `properties.review_count` |
| `prices` | `List<PropertyPrice>` | `prices` | joined from `property_prices` |
| `starRating` | `int?` | `star_rating` | `properties.star_rating` |
| `checkInTime` | `String?` | `check_in_time` | `properties.check_in_time` |
| `checkOutTime` | `String?` | `check_out_time` | `properties.check_out_time` |
| `hasBreakfast` | `bool` | `has_breakfast` | `properties.has_breakfast` |
| `typeLabel` | `String` | `type_label` | derived from `property_type` |
| `areaLabel` | `String` | `area_label` | derived from `city_name` / `province` |
| `extraMediaCount` | `int` | `extra_media_count` | `properties.extra_media_count` |
| `specs` | `List<SpecItem>` | `specs` | `properties.specs` (json) |
| `isFavorite` | `bool` | `is_favorite` | `properties.is_favorite` |
| `reviewSummary` | `ReviewSummary` | `review_summary` | aggregated from `reviews` |
| `reviews` | `List<PropertyReview>` | `reviews` | from `/properties/{id}/reviews` |
| `questionCount` | `int` | `question_count` | count from `property_questions` |
| `questions` | `List<PropertyQuestion>` | `questions` | from `/properties/{id}/questions` |
| `bedFacilities` | `List<FacilityItem>` | `bed_facilities` | `properties.bed_facilities` (json) |
| `buildingFacilities` | `List<FacilityItem>` | `building_facilities` | `properties.building_facilities` (json) |
| `buildingFacilitiesAll` | `List<String>` | `building_facilities_all` | `properties.building_facilities_all` (json) |
| `roomFurniture` | `List<FacilityItem>` | `room_furniture` | `properties.room_furniture` (json) |
| `roomFurnitureGroups` | `List<RoomFurnitureGroup>` | `room_furniture_groups` | `properties.room_furniture_groups` (json) |
| `checkInNotes` | `List<InfoNote>` | `check_in_notes` | `properties.check_in_notes` (json) |
| `depositAmount` | `num?` | `deposit_amount` | `properties.deposit_amount` |
| `depositNotes` | `List<InfoNote>` | `deposit_notes` | `properties.deposit_notes` (json) |
| `unitDetailRows` | `List<UnitDetailRow>` | `unit_detail` | `properties.unit_detail` (json) |
| `intro` | `String` | `intro` | `properties.intro` |
| `descriptionExtra` | `List<String>` | `description_extra` | `properties.description_extra` (json) |
| `descriptionExtraHeading` | `String` | `description_extra_heading` | `properties.description_extra_heading` |
| `mapPreviewUrl` | `String?` | `map_preview` | `properties.map_preview` |
| `nearbyPlaces` | `List<NearbyPlace>` | `nearby` | `properties.nearby` (json) |
| `guestMedia` | `List<GalleryItem>` | `guest_media` | `properties.guest_media` (json) |
| `buildingUnits` | `BuildingUnitsTeaser?` | `building_units` | `properties.building_units` (json) |
| `priceCaption` | `String` | `price_caption` | `properties.price_caption` |
| `priceAmount` | `num` | `price_from` | `properties.price_from` |
| `isFlashSale` | `bool` | `is_flash_sale` | `properties.is_flash_sale` |

### 1.2 UnitPricing model keys

| Flutter field | Type | JSON key | DB column / source |
|---|---|---|---|
| `period` | `RentalPeriod` | `price_type` | `property_prices.price_type` |
| `propertyName` | `String` | `property_name` | `properties.name` |
| `thumbnailUrl` | `String?` | `thumbnail` | derived from `properties.cover` |
| `bedrooms` | `int` | `bedrooms` | `properties.bedrooms` |
| `bathrooms` | `int` | `bathrooms` | not in properties table; add if needed |
| `checkIn` | `DateTime` | `check_in` | request param |
| `checkOut` | `DateTime` | `check_out` | request param |
| `duration` | `int` | `duration` | computed from check_in / check_out |
| `durationOptions` | `List<int>` | `duration_options` | static per price_type |
| `basePrice` | `num` | `base_price` | `property_prices.amount` |
| `serviceFee` | `num` | `service_fee` | `property_prices.service_fee` |
| `inclusions` | `InclusionList` | `inclusions` | static or config |
| `specialPrices` | `List<SpecialPriceTier>` | `special_prices` | static or config |
| `addOns` | `List<AddOn>` | `add_ons` | static or config |
| `plans` | `List<InstallmentPlan>` | `payment_plans` | static or config |
| `promo` | `AppliedPromo?` | `promo` | from promo engine |
| `scheduleNote` | `String` | `schedule_note` | static or config |

---

## 2. API Endpoints

### 2.1 Properties

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/properties` | optional | Search/list properties |
| `GET` | `/api/properties/{id}` | optional | Property detail (rich payload) |
| `GET` | `/api/properties/{id}/reviews` | optional | Paginated reviews |
| `GET` | `/api/properties/{id}/availability` | optional | Date availability |
| `GET` | `/api/properties/{id}/host` | optional | Host info |
| `GET` | `/api/properties/{id}/pricing` | optional | Unit pricing for a period |
| `GET` | `/api/properties/{id}/questions` | optional | Q&A list |
| `POST` | `/api/conversations` | required | Start chat with host |

### 2.2 Response shapes

**`GET /api/properties/{id}`**

```json
{
  "status": true,
  "code": 200,
  "message": "Detail properti berhasil dimuat.",
  "data": {
    "id": 1,
    "host_id": 10,
    "city_id": 1,
    "city_name": "Bali",
    "province": "Bali",
    "property_type": "apartment",
    "booking_mode": "unit",
    "name": "Sunset Beach Apartment",
    "building_name": "Sunset Towers",
    "description": "...",
    "intro": "...",
    "address": "...",
    "latitude": -8.65,
    "longitude": 115.2167,
    "guest_capacity": 4,
    "bedrooms": 2,
    "facilities": ["WiFi", "Pool"],
    "gallery": ["url1", "url2"],
    "cover": "url",
    "cover_image": "url",
    "status": "active",
    "price_from": 500000,
    "rating": 4.8,
    "review_count": 12,
    "prices": [],
    "star_rating": null,
    "check_in_time": null,
    "check_out_time": null,
    "has_breakfast": false,
    "type_label": "Apartment",
    "area_label": "Bali",
    "extra_media_count": 0,
    "specs": [],
    "is_favorite": false,
    "review_summary": {},
    "reviews": [],
    "question_count": 0,
    "questions": [],
    "bed_facilities": [],
    "building_facilities": [],
    "building_facilities_all": [],
    "room_furniture": [],
    "room_furniture_groups": [],
    "check_in_notes": [],
    "deposit_amount": 11175000,
    "deposit_notes": [],
    "unit_detail": [],
    "nearby": [],
    "guest_media": [],
    "building_units": {},
    "price_caption": "per bulan mulai dari",
    "is_flash_sale": true
  }
}
```

**`GET /api/properties/{id}/reviews`**

```json
{
  "status": true,
  "code": 200,
  "data": [
    {
      "id": 1,
      "property_id": 1,
      "user_id": 2,
      "rating": 5,
      "comment": "...",
      "host_reply": "...",
      "photos": [],
      "period_label": "Sewa Harian",
      "created_at": "2026-07-20T14:30:00+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 2
  }
}
```

**`GET /api/properties/{id}/pricing?price_type=monthly`**

```json
{
  "status": true,
  "code": 200,
  "data": {
    "property_id": 1,
    "property_name": "Sunset Beach Apartment",
    "thumbnail": "https://example.com/gallery1/1.jpg",
    "bedrooms": 2,
    "bathrooms": 2,
    "check_in": "2026-08-16",
    "check_out": "2026-08-17",
    "duration": 1,
    "duration_options": [1, 2, 3, 6, 12],
    "base_price": 14000000,
    "service_fee": 260000,
    "inclusions": {
      "included": [],
      "excluded": [],
      "collapsed_rows": 5
    },
    "special_prices": [],
    "add_ons": [],
    "payment_plans": [],
    "promo": null,
    "schedule_note": ""
  }
}
```

---

## 3. Database Schema

### 3.1 `properties` table

Production-owned. Migration: `laravel\database\migrations\2026_07_14_080100_create_properties_table.php`

Base columns only — all rich detail columns are in `properties_other` or dedicated tables.

### 3.2 `properties_other` table

Stores JSON-rich fields that do not belong in the base `properties` table.

Migration: `docs\properties\screen\_build_laravel\database\migrations\2026_08_16_000001_create_properties_other_table.php`

| Column | Type | Notes |
|---|---|---|
| `id` | `bigIncrements` | |
| `property_id` | `foreignId` | FK to `properties`, cascade delete, unique |
| `province` | `string` | nullable |
| `cover` | `string` | nullable |
| `cover_image` | `string` | nullable |
| `price_from` | `decimal(15,2)` | nullable |
| `rating` | `decimal(3,2)` | nullable |
| `review_count` | `unsignedInteger` | default 0 |
| `star_rating` | `unsignedTinyInteger` | nullable |
| `check_in_time` | `time` | nullable |
| `check_out_time` | `time` | nullable |
| `has_breakfast` | `boolean` | default false |
| `type_label` | `string` | nullable |
| `area_label` | `string` | nullable |
| `extra_media_count` | `unsignedInteger` | default 0 |
| `specs` | `json` | nullable |
| `is_favorite` | `boolean` | default false |
| `intro` | `text` | nullable |
| `description_extra` | `json` | nullable |
| `description_extra_heading` | `string` | nullable |
| `map_preview` | `string` | nullable |
| `price_caption` | `string` | default `per bulan mulai dari` |
| `is_flash_sale` | `boolean` | default false |
| `bed_facilities` | `json` | nullable |
| `building_facilities` | `json` | nullable |
| `building_facilities_all` | `json` | nullable |
| `room_furniture` | `json` | nullable |
| `room_furniture_groups` | `json` | nullable |
| `check_in_notes` | `json` | nullable |
| `deposit_amount` | `decimal(15,2)` | nullable |
| `deposit_notes` | `json` | nullable |
| `unit_detail` | `json` | nullable |
| `nearby` | `json` | nullable |
| `guest_media` | `json` | nullable |
| `building_units` | `json` | nullable |
| `review_summary` | `json` | nullable |
| `timestamps` | | |

### 3.2 `property_questions` table (new)

| Column | Type | Notes |
|---|---|---|
| `id` | `bigIncrements` | |
| `property_id` | `foreignId` | FK to `properties`, cascade delete |
| `asked_by` | `foreignId` | nullable, FK to `users` |
| `question` | `text` | |
| `answer` | `text` | nullable |
| `created_at` | `timestamp` | nullable |
| `timestamps` | | |

### 3.3 Existing tables (production-owned — not duplicated in `_build_laravel`)

| Table | Production migration/model | Status |
|---|---|---|
| `reviews` | `laravel\database\migrations\...\reviews_table.php` + `laravel\app\Models\Review.php` | Production-owned; use production |
| `property_prices` | `2026_07_14_080500_create_property_prices_table.php` | Production-owned; use production migration/model |
| `property_search_logs` | `2026_07_14_080200_create_property_search_logs_table.php` | Production-owned; use production migration/model |
| `property_recommendations` | `2026_07_14_080700_create_property_recommendations_table.php` | Production-owned; no duplicate in `_build_laravel` |

---

## 4. Model Specifications

### 4.1 Property

Production-owned. Model: `laravel\app\Models\Property.php`

Base columns only. Rich fields are loaded via `properties_other` relationship.

```php
class Property extends Model
{
    protected $fillable = [
        'host_id',
        'city_id',
        'property_type',
        'booking_mode',
        'name',
        'building_name',
        'description',
        'address',
        'latitude',
        'longitude',
        'guest_capacity',
        'bedrooms',
        'facilities',
        'gallery',
        'status',
        'cancellation_policy',
    ];

    protected $casts = [
        'gallery' => 'array',
        'facilities' => 'array',
    ];

    public function host(): BelongsTo { return $this->belongsTo(User::class, 'host_id'); }
    public function city(): BelongsTo { return $this->belongsTo(City::class); }
    public function prices(): HasMany { return $this->hasMany(PropertyPrice::class); }
    public function reviews(): HasMany { return $this->hasMany(Review::class); }
    public function availabilities(): HasMany { return $this->hasMany(Availability::class); }
    public function bookings(): HasMany { return $this->hasMany(Booking::class); }
    public function hotel(): HasOne { return $this->hasOne(Hotel::class); }
    public function roomTypes(): HasManyThrough { return $this->hasManyThrough(RoomType::class, Hotel::class); }
    public function masterFacilities(): BelongsToMany { return $this->belongsToMany(Facility::class, 'facility_property'); }

    public function other(): HasOne { return $this->hasOne(PropertyOther::class); }
}
```

### 4.2 PropertyOther

```php
class PropertyOther extends Model
{
    protected $table = 'properties_other';

    protected $fillable = [
        'property_id',
        'province',
        'cover',
        'cover_image',
        'price_from',
        'rating',
        'review_count',
        'star_rating',
        'check_in_time',
        'check_out_time',
        'has_breakfast',
        'type_label',
        'area_label',
        'extra_media_count',
        'specs',
        'is_favorite',
        'intro',
        'description_extra',
        'description_extra_heading',
        'map_preview',
        'price_caption',
        'is_flash_sale',
        'bed_facilities',
        'building_facilities',
        'building_facilities_all',
        'room_furniture',
        'room_furniture_groups',
        'check_in_notes',
        'deposit_amount',
        'deposit_notes',
        'unit_detail',
        'nearby',
        'guest_media',
        'building_units',
        'review_summary',
    ];

    protected $casts = [
        'price_from' => 'decimal:2',
        'rating' => 'decimal:2',
        'specs' => 'array',
        'is_favorite' => 'boolean',
        'description_extra' => 'array',
        'bed_facilities' => 'array',
        'building_facilities' => 'array',
        'building_facilities_all' => 'array',
        'room_furniture' => 'array',
        'room_furniture_groups' => 'array',
        'check_in_notes' => 'array',
        'deposit_amount' => 'decimal:2',
        'deposit_notes' => 'array',
        'unit_detail' => 'array',
        'nearby' => 'array',
        'guest_media' => 'array',
        'building_units' => 'array',
        'review_summary' => 'array',
        'is_flash_sale' => 'boolean',
        'has_breakfast' => 'boolean',
    ];

    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
}
```

### 4.3 PropertyPrice

**Production-owned.** Model: `laravel\app\Models\PropertyPrice.php`
Migration: `laravel\database\migrations\2026_07_14_080500_create_property_prices_table.php`

```php
class PropertyPrice extends Model
{
    protected $table = 'property_prices';

    protected $fillable = [
        'property_id',
        'price_type',
        'amount',
        'cleaning_fee',
        'deposit',
        'service_fee',
        'extra_guest_fee',
    ];

    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
}
```

### 4.4 Review

**Production-owned.** Model: `laravel\app\Models\Review.php`
Table: `reviews`

```php
class Review extends Model
{
    protected $table = 'reviews';

    protected $fillable = [
        'booking_id',
        'property_id',
        'user_id',
        'rating',
        'comment',
        'host_reply',
        'photos',
    ];

    public function booking(): BelongsTo { return $this->belongsTo(Booking::class); }
    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
```

### 4.5 PropertyQuestion

```php
class PropertyQuestion extends Model
{
    protected $fillable = [
        'property_id', 'asked_by', 'question', 'answer', 'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
    public function asker(): BelongsTo { return $this->belongsTo(User::class, 'asked_by'); }
}
```

### 4.6 PropertyRecommendation

**Production-owned.** Model: `laravel\app\Models\PropertyRecommendation.php`
Migration: `laravel\database\migrations\2026_07_14_080700_create_property_recommendations_table.php`

```php
class PropertyRecommendation extends Model
{
    protected $table = 'property_recommendations';

    protected $fillable = [
        'property_id',
        'type',
        'poi_category',
        'priority',
    ];

    protected $casts = [
        'poi_category' => PoiCategory::class,
    ];

    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
}
```

### 4.7 PropertySearchLog

**Production-owned.** Model: `laravel\app\Models\PropertySearchLog.php`
Migration: `laravel\database\migrations\2026_07_14_080200_create_property_search_logs_table.php`

```php
class PropertySearchLog extends Model
{
    protected $table = 'property_search_logs';

    protected $fillable = [
        'user_id',
        'keyword',
        'filters',
        'results_count',
        'ip_address',
    ];

    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
```

---

## 5. Controllers

### 5.1 PropertyController

```php
class PropertyController extends Controller
{
    public function index(Request $request): JsonResponse;
    public function show(int $id): JsonResponse;
    public function reviews(int $id, Request $request): JsonResponse;
    public function availability(int $id, Request $request): JsonResponse;
    public function host(int $id): JsonResponse;
    public function pricing(int $id, Request $request): JsonResponse;
    public function questions(int $id): JsonResponse;
}
```

### 5.2 ConversationController (chat)

```php
class ConversationController extends Controller
{
    public function index(Request $request): JsonResponse;
    public function store(Request $request): JsonResponse;
    public function show(int $id): JsonResponse;
    public function messages(int $id, Request $request): JsonResponse;
    public function storeMessage(int $id, Request $request): JsonResponse;
}
```

---

## 6. Routes

```php
Route::prefix('properties')->group(function () {
    Route::get('/', [PropertyController::class, 'index']);
    Route::get('{id}', [PropertyController::class, 'show']);
    Route::get('{id}/reviews', [PropertyController::class, 'reviews']);
    Route::get('{id}/availability', [PropertyController::class, 'availability']);
    Route::get('{id}/host', [PropertyController::class, 'host']);
    Route::get('{id}/pricing', [PropertyController::class, 'pricing']);
    Route::get('{id}/questions', [PropertyController::class, 'questions']);
});

Route::prefix('conversations')->group(function () {
    Route::get('/', [ConversationController::class, 'index']);
    Route::post('/', [ConversationController::class, 'store']);
    Route::get('{id}', [ConversationController::class, 'show']);
    Route::get('{id}/messages', [ConversationController::class, 'messages']);
    Route::post('{id}/messages', [ConversationController::class, 'storeMessage']);
});
```

---

## 7. Migration Audit vs Production

### 7.1 Production migrations (do not duplicate)

| Production file | Status | Action |
|---|---|---|
| `2026_07_14_080100_create_properties_table.php` | base only | Use as-is; rich columns live in `properties_other` |
| `2026_07_14_080200_create_property_search_logs_table.php` | production-owned | Use production migration/model; no duplicate in `_build_laravel` |
| `2026_07_14_080700_create_property_recommendations_table.php` | production-owned | Use production migration/model; no duplicate in `_build_laravel` |
| `2026_07_14_080500_create_property_prices_table.php` | production-owned | Use production migration/model; no duplicate in `_build_laravel` |

### 7.2 New migrations in `_build_laravel`

| New file | Purpose |
|---|---|
| `2026_08_16_000001_create_properties_other_table.php` | JSON-rich fields from `GET_properties_id.json` not in base `properties` |
| `2026_08_16_000004_create_property_questions_table.php` | Stores Q&A |

Note: `reviews` are handled by the production table `reviews` and model `laravel\app\Models\Review.php`. No duplicate in `_build_laravel`.

Note: `property_recommendations` is handled by the production migration `laravel\database\migrations\2026_07_14_080700_create_property_recommendations_table.php` and model `laravel\app\Models\PropertyRecommendation.php`. No duplicate in `_build_laravel`.

### 7.3 `properties_other` columns (new table)

These columns exist in the Flutter contract (`GET_properties_id.json`) but are NOT in the production `properties` table.

| Column | Type | Source key |
|---|---|---|
| `province` | `string` | `province` |
| `cover` | `string` | `cover` |
| `cover_image` | `string` | `cover_image` |
| `price_from` | `decimal(15,2)` | `price_from` |
| `rating` | `decimal(3,2)` | `rating` |
| `review_count` | `unsignedInteger` | `review_count` |
| `star_rating` | `unsignedTinyInteger` | `star_rating` |
| `check_in_time` | `time` | `check_in_time` |
| `check_out_time` | `time` | `check_out_time` |
| `has_breakfast` | `boolean` | `has_breakfast` |
| `type_label` | `string` | `type_label` |
| `area_label` | `string` | `area_label` |
| `extra_media_count` | `unsignedInteger` | `extra_media_count` |
| `specs` | `json` | `specs` |
| `is_favorite` | `boolean` | `is_favorite` |
| `intro` | `text` | `intro` |
| `description_extra` | `json` | `description_extra` |
| `description_extra_heading` | `string` | `description_extra_heading` |
| `map_preview` | `string` | `map_preview` |
| `price_caption` | `string` | `price_caption` |
| `is_flash_sale` | `boolean` | `is_flash_sale` |
| `bed_facilities` | `json` | `bed_facilities` |
| `building_facilities` | `json` | `building_facilities` |
| `building_facilities_all` | `json` | `building_facilities_all` |
| `room_furniture` | `json` | `room_furniture` |
| `room_furniture_groups` | `json` | `room_furniture_groups` |
| `check_in_notes` | `json` | `check_in_notes` |
| `deposit_amount` | `decimal(15,2)` | `deposit_amount` |
| `deposit_notes` | `json` | `deposit_notes` |
| `unit_detail` | `json` | `unit_detail` |
| `nearby` | `json` | `nearby` |
| `guest_media` | `json` | `guest_media` |
| `building_units` | `json` | `building_units` |
| `review_summary` | `json` | `review_summary` |

---

## 8. Seeder Mapping

### 8.1 Production → `_build_laravel` mapping

| Production seeder | `_build_laravel` seeder | Changes |
|---|---|---|
| `PropertySeeder.php` | *(production-owned)* | Use production seeder for base `properties` table |
| `PropertyPriceSeeder.php` | *(production-owned)* | Use production seeder; no duplicate in `_build_laravel` |
| `PropertyRecommendationSeeder.php` | *(production-owned)* | Use production seeder; no duplicate in `_build_laravel` |
| `PropertySearchLogSeeder.php` | *(production-owned)* | Use production seeder; no duplicate in `_build_laravel` |
| — | `PropertiesOtherSeeder.php` | New: seeds `properties_other` table with rich JSON fields |
| — | `PropertyQuestionSeeder.php` | New: seeds `property_questions` table |

### 8.2 Data alignment

All seeders in `_build_laravel` produce data that matches the Flutter fixture `GET_properties_id.json`:
- Same property name, address, coordinates
- Same facilities, gallery URLs
- Same question/answer pairs
- Same nearby places and unit details

Note: Reviews are seeded by the production seeder into the production `reviews` table using `laravel\app\Models\Review.php`.


