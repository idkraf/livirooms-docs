# Generate 2: Arsitektur Database Streamlined (Normalized & Polymorphic)

> **Direktori ini** berisi file migration, model, dan seeder hasil generate dari
> `docs/perbaikan/data_ramping.md`.
>
> **Perbedaan utama** dari generate pertama:
> - **1 tabel universal `media`** (polymorphic) menggantikan `property_media`, `room_type_media`, dsb.
> - **1 master `facilities` + 1 pivot `model_has_facilities`** (polymorphic) menggantikan
>   `property_facilities`, `hotel_facility_groups`, `hotel_facilities`, `room_type_facilities`.
> - Total tabel baru: **~24** (vs 34 di generate pertama).

---

## Struktur Direktori

```
generate_2/
└── laravel/
    ├── database/
    │   ├── migrations/     ← 34 file migration baru
    │   └── seeders/        ← 22 file seeder + DatabaseSeeder
    └── app/
        └── Models/         ← 18 file model baru
```

---

## Daftar Migration

| No | File | Tabel |
|----|------|-------|
| 1 | `2026_08_18_000001_create_facilities_table.php` | `facilities` |
| 2 | `2026_08_18_000002_create_media_table.php` | `media` |
| 3 | `2026_08_18_000003_create_model_has_facilities_table.php` | `model_has_facilities` |
| 4 | `2026_08_18_000004_create_property_pricing_options_table.php` | `property_pricing_options` |
| 5 | `2026_08_18_000005_create_property_special_prices_table.php` | `property_special_prices` |
| 6 | `2026_08_18_000006_create_property_add_ons_table.php` | `property_add_ons` |
| 7 | `2026_08_18_000007_create_property_payment_plans_table.php` | `property_payment_plans` |
| 8 | `2026_08_18_000008_create_property_payment_plan_entries_table.php` | `property_payment_plan_entries` |
| 9 | `2026_08_18_000009_create_property_promos_table.php` | `property_promos` |
| 10 | `2026_08_18_000010_create_property_other_core_table.php` | `property_other_core` |
| 11 | `2026_08_18_000011_create_property_extra_descriptions_table.php` | `property_extra_descriptions` |
| 12 | `2026_08_18_000012_create_property_review_summaries_table.php` | `property_review_summaries` |
| 13 | `2026_08_18_000013_create_property_specs_table.php` | `property_specs` |
| 14 | `2026_08_18_000014_create_property_bed_facilities_table.php` | `property_bed_facilities` |
| 15 | `2026_08_18_000015_create_property_building_facilities_table.php` | `property_building_facilities` |
| 16 | `2026_08_18_000016_create_property_building_facilities_all_table.php` | `property_building_facilities_all` |
| 17 | `2026_08_18_000017_create_property_room_furniture_table.php` | `property_room_furniture` |
| 18 | `2026_08_18_000018_create_property_room_furniture_groups_table.php` | `property_room_furniture_groups` |
| 19 | `2026_08_18_000019_create_property_room_furniture_items_table.php` | `property_room_furniture_items` |
| 20 | `2026_08_18_000020_create_property_check_in_notes_table.php` | `property_check_in_notes` |
| 21 | `2026_08_18_000021_create_property_deposit_notes_table.php` | `property_deposit_notes` |
| 22 | `2026_08_18_000022_create_property_unit_details_table.php` | `property_unit_details` |
| 23 | `2026_08_18_000023_create_property_nearby_places_table.php` | `property_nearby_places` |
| 24 | `2026_08_18_000025_create_property_building_units_table.php` | `property_building_units` |
| 25 | `2026_08_18_000026_create_hotel_policies_table.php` | `hotel_policies` |
| 26 | `2026_08_18_000027_create_hotel_score_components_table.php` | `hotel_score_components` |
| 27 | `2026_08_18_000030_create_hotel_transport_points_table.php` | `hotel_transport_points` |
| 28 | `2026_08_18_000031_create_hotel_faqs_table.php` | `hotel_faqs` |
| 29 | `2026_08_18_000032_create_hotel_review_quotes_table.php` | `hotel_review_quotes` |

**Catatan:** Tabel `properties`, `hotels`, `room_types`, `room_inventories`, `property_prices`,
`property_questions`, `property_recommendations`, `property_search_logs` **sudah ada** dan tidak
dibuat ulang di direktori ini.

---

## Daftar Model

| No | Model | Tabel |
|----|-------|-------|
| 1 | `Media` | `media` |
| 2 | `Facility` | `facilities` |
| 3 | `ModelHasFacility` | `model_has_facilities` |
| 4 | `Property` | `properties` |
| 5 | `PropertyPricingOption` | `property_pricing_options` |
| 6 | `PropertySpecialPrice` | `property_special_prices` |
| 7 | `PropertyAddOn` | `property_add_ons` |
| 8 | `PropertyPaymentPlan` | `property_payment_plans` |
| 9 | `PropertyPaymentPlanEntry` | `property_payment_plan_entries` |
| 10 | `PropertyPromo` | `property_promos` |
| 11 | `PropertyOtherCore` | `property_other_core` |
| 12 | `PropertyExtraDescription` | `property_extra_descriptions` |
| 13 | `PropertyReviewSummary` | `property_review_summaries` |
| 14 | `PropertyReviewBreakdown` | `property_review_breakdowns` |
| 15 | `PropertySpec` | `property_specs` |
| 16 | `PropertyBedFacility` | `property_bed_facilities` |
| 17 | `PropertyBuildingFacility` | `property_building_facilities` |
| 18 | `PropertyBuildingFacilityAll` | `property_building_facilities_all` |
| 19 | `PropertyRoomFurniture` | `property_room_furniture` |
| 20 | `PropertyRoomFurnitureGroup` | `property_room_furniture_groups` |
| 21 | `PropertyRoomFurnitureItem` | `property_room_furniture_items` |
| 22 | `PropertyCheckInNote` | `property_check_in_notes` |
| 23 | `PropertyDepositNote` | `property_deposit_notes` |
| 24 | `PropertyUnitDetail` | `property_unit_details` |
| 25 | `PropertyNearbyPlace` | `property_nearby_places` |
| 26 | `PropertyGuestMedia` | `property_guest_media` |
| 27 | `PropertyBuildingUnit` | `property_building_units` |
| 28 | `Hotel` | `hotels` |
| 29 | `HotelPolicy` | `hotel_policies` |
| 30 | `HotelScoreComponent` | `hotel_score_components` |
| 31 | `HotelTransportPoint` | `hotel_transport_points` |
| 32 | `HotelFaq` | `hotel_faqs` |
| 33 | `HotelReviewQuote` | `hotel_review_quotes` |
| 34 | `RoomType` | `room_types` |

---

## Daftar Seeder

| No | Seeder | Tujuan |
|----|--------|--------|
| 1 | `DatabaseSeeder` | Utama, menyeed semua seeder lainnya |
| 2 | `FacilitySeeder` | Master data fasilitas |
| 3 | `PropertyMediaSeeder` | Media untuk properties & hotels via `media` polymorphic |
| 4 | `PropertyFacilitySeeder` | Fasilitas untuk properties via `model_has_facilities` |
| 5 | `PropertyPricingOptionSeeder` | Opsi durasi pricing |
| 6 | `PropertySpecialPriceSeeder` | Diskon berdasarkan jumlah malam |
| 7 | `PropertyAddOnSeeder` | Add-ons layanan tambahan |
| 8 | `PropertyPaymentPlanSeeder` | Rencana cicilan |
| 9 | `PropertyPromoSeeder` | Kode promo |
| 10 | `PropertyOtherCoreSeeder` | Data display core properti |
| 11 | `PropertyExtraDescriptionSeeder` | Deskripsi ekstra properti |
| 12 | `PropertyReviewSummarySeeder` | Ringkasan review |
| 13 | `PropertyReviewBreakdownSeeder` | Breakdown rating review |
| 14 | `PropertySpecSeeder` | Spesifikasi properti |
| 15 | `PropertyBedFacilitySeeder` | Fasilitas tempat tidur |
| 16 | `PropertyBuildingFacilitySeeder` | Fasilitas gedung |
| 17 | `PropertyBuildingFacilityAllSeeder` | Semua fasilitas gedung |
| 18 | `PropertyRoomFurnitureSeeder` | Perabot kamar |
| 19 | `PropertyRoomFurnitureGroupSeeder` | Grup perabot kamar |
| 20 | `PropertyCheckInNoteSeeder` | Catatan check-in |
| 21 | `PropertyDepositNoteSeeder` | Catatan deposit |
| 22 | `PropertyUnitDetailSeeder` | Detail unit |
| 23 | `PropertyNearbyPlaceSeeder` | Tempat terdekat |
| 24 | `PropertyGuestMediaSeeder` | Media tamu (kosong) |
| 25 | `PropertyBuildingUnitSeeder` | Unit gedung |
| 26 | `HotelPolicySeeder` | Kebijakan hotel |
| 27 | `HotelScoreComponentSeeder` | Komponen skor hotel |
| 28 | `HotelFacilityGroupSeeder` | Grup fasilitas hotel |
| 29 | `HotelTransportPointSeeder` | Titik transit hotel |
| 30 | `HotelFaqSeeder` | FAQ hotel |
| 31 | `HotelReviewQuoteSeeder` | Kutipan review hotel |
| 32 | `RoomTypeMediaSeeder` | Media room type via `media` polymorphic |
| 33 | `RoomTypeFacilitySeeder` | Fasilitas room type via `model_has_facilities` |

---

## Relasi Polymorphic

### Media
```php
// Property.php
public function media(): MorphMany {
    return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
}

// Hotel.php
public function media(): MorphMany {
    return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
}

// RoomType.php
public function media(): MorphMany {
    return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
}
```

### Facilities
```php
// Property.php
public function facilities(): MorphToMany {
    return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
        ->withPivot('is_available', 'badge', 'sort_order')
        ->orderBy('sort_order');
}

// Hotel.php
public function facilities(): MorphToMany {
    return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
        ->withPivot('is_available', 'badge', 'sort_order')
        ->orderBy('sort_order');
}

// RoomType.php
public function facilities(): MorphToMany {
    return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
        ->withPivot('is_available', 'sort_order')
        ->orderBy('sort_order');
}
```

---

## Cara Pakai

1. Salin folder `laravel/database/migrations/*` ke `laravel/database/migrations/` di project.
2. Salin folder `laravel/app/Models/*` ke `laravel/app/Models/` di project.
3. Salin folder `laravel/database/seeders/*` ke `laravel/database/seeders/` di project.
4. Jalankan `php artisan migrate:fresh --seed`.

**Penting:** Pastikan model `Property`, `Hotel`, `RoomType` yang sudah ada di project
di-update dengan relasi polymorphic sesuai yang didokumentasikan di `data_ramping.md`.

---

## Catatan

- File ini hanya berisi **schema baru**. Data migration dari JSONB lama ke tabel baru
  harus dilakukan terpisah.
- Booking & Payment system **tidak disentuh** sesuai instruksi.
- Semua `sort_order` ditambahkan agar urutan tampil di Flutter tetap terjaga.
