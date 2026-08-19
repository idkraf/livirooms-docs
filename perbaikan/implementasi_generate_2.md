# Implementasi Generate_2 — Hotel & Property Restructuring

> **Sumber:** `docs/perbaikan/data_ramping.md` + `docs/perbaikan/generate_2/laravel/`
> **Target:** Migrasi arsitektur JSONB → Relational + Polymorphic untuk module Hotels & Properties
> **Tanggal:** 2026-08-18

---

## 0. Prasyarat

1. Backup database produksi/staging:
   ```bash
   pg_dump -Fc -f backup_before_generate2.dump "$DB_DATABASE"
   ```
2. Pastikan semua test hijau sebelum mulai:
   ```bash
   cd laravel && php artisan test
   ```
3. Pastikan Flutter `flutter analyze` bersih.

---

## 1. Ringkasan Perubahan

| Aspek | Sebelum | Sesudah |
|-------|---------|---------|
| Media | `properties.gallery` (jsonb), `room_types.images` (jsonb) | 1 tabel `media` (polymorphic) |
| Fasilitas | `properties.facilities` (jsonb), `hotels.facility_groups` (jsonb), `room_types.facilities` (jsonb) | 1 master `facilities` + 1 pivot `model_has_facilities` |
| Hotel metadata | `hotels.policies`, `hotels.score`, `hotels.facility_groups`, `hotels.transport_points`, `hotels.faqs`, `hotels.review_quotes` (semua jsonb) | Tabel relasional terpisah |
| Property detail | `properties_other` (1 tabel 34 kolom) | 15+ tabel relasional |
| Total tabel baru | 34 | ~24 (hemat 10) |

---

## 2. Struktur Referensi

Semua file referensi sudah ada di:
```
docs/perbaikan/generate_2/laravel/
├── app/
│   ├── Controllers/        (akan diisi saat tahap 4)
│   └── Models/             (34 model files — SUDAH LENGKAP)
├── database/
│   ├── migrations/         (29 migration files — SUDAH LENGKAP)
│   └── seeders/            (33 seeder files — SUDAH LENGKAP)
```

**Strategi:** Copy file referensi → adapt → integrate → test.

---

## 3. Tahapan Eksekusi

### Tahap 1: Core Infrastructure (Hari 1)
- [ ] 1.1 Copy 29 migrations referensi → `laravel/database/migrations/`
- [ ] 1.2 Copy 34 model files referensi → `laravel/app/Models/`
- [ ] 1.3 Run `php artisan migrate` — harus clean
- [ ] 1.4 Update `Property.php` dan `Hotel.php` di app aktual dengan relasi baru
- [ ] 1.5 Update `RoomType.php` di app aktual

### Tahap 2: Seeders (Hari 1-2)
- [ ] 2.1 Copy 33 seeders referensi → `laravel/database/seeders/`
- [ ] 2.2 Update `DatabaseSeeder.php` untuk include seeders baru
- [ ] 2.3 Run `php artisan db:seed` — verify data counts

### Tahap 3: Controllers & Resources (Hari 2-3)
- [ ] 3.1 Update `PropertyController` — ganti JSONB access dengan relasi
- [ ] 3.2 Update `HotelApiController` — ganti `toArray()` dengan `HotelResource`
- [ ] 3.3 Update `HostHotelController` — sama
- [ ] 3.4 Update `PropertyResource` — map dari relasi baru
- [ ] 3.5 Update `HotelResource` — map dari relasi baru
- [ ] 3.6 Update `HostHotelResource` jika ada

### Tahap 4: Admin (Livewire/Blade) (Hari 3-4)
- [ ] 4.1 Update `WizardForm.php` (Hotels) — facility groups → `model_has_facilities`
- [ ] 4.2 Update `PropertyWizardForm.php` — facilities → `model_has_facilities`, gallery → `media`
- [ ] 4.3 Update Blade views yang akses JSONB langsung

### Tahap 5: Flutter (Hari 4-5)
- [ ] 5.1 Update `Property.fromJson()` — parse dari struktur relational API
- [ ] 5.2 Update `Hotel.fromJson()` — parse dari struktur relational API
- [ ] 5.3 Update dummy fixtures (`GET_properties_id.json`, `GET_hotels_id.json`)
- [ ] 5.4 Update `DummyApiClient` jika endpoint berubah

### Tahap 6: Migration Data (Hari 5)
- [ ] 6.1 Backfill `media` dari `properties.gallery` dan `room_types.images`
- [ ] 6.2 Backfill `model_has_facilities` dari JSONB facilities
- [ ] 6.3 Backfill `hotel_policies`, `hotel_faqs`, dll dari JSONB hotels
- [ ] 6.4 Backfill `property_other_core` + tabel pecahan dari `properties_other`
- [ ] 6.5 Verify: `SELECT COUNT(*) FROM media`, `model_has_facilities`, dll

### Tahap 7: Cleanup (Hari 5-6)
- [ ] 7.1 Drop kolom JSONB lama: `properties.gallery`, `properties.facilities`, `hotels.policies`, `hotels.score`, `hotels.facility_groups`, `hotels.transport_points`, `hotels.faqs`, `hotels.review_quotes`, `room_types.images`, `room_types.facilities`
- [ ] 7.2 Drop tabel `properties_other`
- [ ] 7.3 Remove accessor JSONB di model yang tidak diperlukan
- [ ] 7.4 Run full test suite + Flutter analyze

---

## 4. Catatan Implementasi Penting

### 4.1 Backward Compatibility
- API response shape **TIDAK BERUBAH** — Flutter tetap menerima JSON yang sama
- Perubahan hanya di dalam Laravel: controller mengisi response dari relasi, bukan JSONB
- Accessor `getPriceFromAttribute()` dst tetap bekerja

### 4.2 Data Migration Strategy
1. **Jangan drop JSONB sebelum data di-migrate**
2. Buat migration backfill terpisah untuk setiap tabel
3. Verify counts sebelum drop kolom

### 4.3 Flutter Impact
- `Property.fromJson()` dan `Hotel.fromJson()` **TIDAK PERLU DIUBAH** selama API response shape tetap sama
- Yang berubah: controller mengirim data yang sama dari sumber relational

### 4.4 Rollback Plan
Jika ada masalah:
```bash
php artisan migrate:rollback --step=29  # rollback semua migration baru
# JSONB columns masih ada, aplikasi tetap jalan
```

---

## 5. File Checklist

### Migrations (29 files)
```
2026_08_18_000001_create_facilities_table.php
2026_08_18_000002_create_media_table.php
2026_08_18_000003_create_model_has_facilities_table.php
2026_08_18_000004_create_property_pricing_options_table.php
2026_08_18_000005_create_property_special_prices_table.php
2026_08_18_000006_create_property_add_ons_table.php
2026_08_18_000007_create_property_payment_plans_table.php
2026_08_18_000008_create_property_payment_plan_entries_table.php
2026_08_18_000009_create_property_promos_table.php
2026_08_18_000010_create_property_other_core_table.php
2026_08_18_000011_create_property_extra_descriptions_table.php
2026_08_18_000012_create_property_review_summaries_table.php
2026_08_18_000013_create_property_review_breakdowns_table.php
2026_08_18_000014_create_property_specs_table.php
2026_08_18_000015_create_property_bed_facilities_table.php
2026_08_18_000016_create_property_building_facilities_table.php
2026_08_18_000017_create_property_building_facilities_all_table.php
2026_08_18_000018_create_property_room_furniture_table.php
2026_08_18_000019_create_property_room_furniture_groups_table.php
2026_08_18_000020_create_property_room_furniture_items_table.php
2026_08_18_000021_create_property_check_in_notes_table.php
2026_08_18_000022_create_property_deposit_notes_table.php
2026_08_18_000023_create_property_unit_details_table.php
2026_08_18_000024_create_property_nearby_places_table.php
2026_08_18_000025_create_property_building_units_table.php
2026_08_18_000026_create_hotel_policies_table.php
2026_08_18_000027_create_hotel_score_components_table.php
2026_08_18_000028_create_hotel_transport_points_table.php
2026_08_18_000029_create_hotel_faqs_table.php
2026_08_18_000030_create_hotel_review_quotes_table.php
```

### Models (34 files)
```
Media.php, Facility.php, ModelHasFacility.php
PropertyOtherCore.php, PropertyExtraDescription.php, PropertyReviewSummary.php
PropertyReviewBreakdown.php, PropertySpec.php, PropertyBedFacility.php
PropertyBuildingFacility.php, PropertyBuildingFacilityAll.php
PropertyRoomFurniture.php, PropertyRoomFurnitureGroup.php, PropertyRoomFurnitureItem.php
PropertyCheckInNote.php, PropertyDepositNote.php, PropertyUnitDetail.php
PropertyNearbyPlace.php, PropertyBuildingUnit.php
PropertyPricingOption.php, PropertySpecialPrice.php, PropertyAddOn.php
PropertyPaymentPlan.php, PropertyPaymentPlanEntry.php, PropertyPromo.php
HotelPolicy.php, HotelScoreComponent.php, HotelTransportPoint.php
HotelFaq.php, HotelReviewQuote.php
```

### Seeders (33 files)
```
DatabaseSeeder.php (updated), FacilitySeeder.php
PropertyMediaSeeder.php, PropertyFacilitySeeder.php, PropertyGuestMediaSeeder.php
RoomTypeMediaSeeder.php, RoomTypeFacilitySeeder.php
PropertyOtherCoreSeeder.php, PropertyExtraDescriptionSeeder.php
PropertyReviewSummarySeeder.php, PropertyReviewBreakdownSeeder.php
PropertySpecSeeder.php, PropertyBedFacilitySeeder.php
PropertyBuildingFacilitySeeder.php, PropertyBuildingFacilityAllSeeder.php
PropertyRoomFurnitureSeeder.php, PropertyRoomFurnitureGroupSeeder.php
PropertyRoomFurnitureItemSeeder.php, PropertyCheckInNoteSeeder.php
PropertyDepositNoteSeeder.php, PropertyUnitDetailSeeder.php
PropertyNearbyPlaceSeeder.php, PropertyBuildingUnitSeeder.php
PropertyPricingOptionSeeder.php, PropertySpecialPriceSeeder.php
PropertyAddOnSeeder.php, PropertyPaymentPlanSeeder.php
PropertyPaymentPlanEntrySeeder.php, PropertyPromoSeeder.php
HotelPolicySeeder.php, HotelScoreComponentSeeder.php
HotelTransportPointSeeder.php, HotelFaqSeeder.php
HotelReviewQuoteSeeder.php, HotelFacilityGroupSeeder.php
```

---

## 6. Verifikasi

Setiap tahap harus lulus:
```bash
cd laravel
php artisan migrate:fresh --seed
php artisan test
cd ../flutter && flutter analyze
```

Target akhir:
- 0 error di Laravel tests
- 0 error di Flutter analyze
- API response shape sama seperti sebelum restrukturisasi
