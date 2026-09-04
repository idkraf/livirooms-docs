# Drift Register — Docs & Klaim vs Kode

> **Fungsi file ini.** Daftar status selisih terverifikasi, perbaikan arsitektur data modeling, dan catatan integrasi sistem.
>
> **Status per 2026-08-26:** Flutter→Laravel accommodation creation flow audit selesai. Drift kritis ditemukan dan direkonsiliasi.
> **Update per 2026-08-27:** Relasi `Accommodation::bookings()` ditambahkan untuk menghilangkan `BadMethodCallException` di `ReportController::propertyPerformanceReport()`.
> **Update per 2026-08-27:** `Property.php` dan `Hotel.php` dihapus. Semua relasi terkonsolidasi di `Accommodation.php`. `HotelFaq` diubah menjadi `AccommodationFaq` (tabel `accommodation_faqs`). `HotelScoreComponent` diubah menjadi `AccommodationScoreComponent` (tabel `accommodation_score_components`). `AccommodationReviewQuote` dihapus; review quotes tidak lagi disimpan secara terpisah.
> **Update per 2026-08-27:** Resource audit selesai. `PresentsProperty` trait dibersihkan dari referensi `PropertyOther` yang sudah dihapus. `AccommodationQuestionResource::toPropertyArray()` diselaraskan dengan Flutter `HotelFaqItem`. `NearbyPointResource::toPropertyArray()` diselaraskan dengan Flutter `TransportPoint`.
> **Update per 2026-08-27:** `Accommodation::updateScoreComponents()` ditambahkan untuk men-sinkronkan rata-rata rating review ke tabel `accommodation_score_components` (component `basic`). Event `created`, `updated` (hanya jika `rating` berubah), dan `deleted` pada model `Review` memicu penyaluran otomatis. `ReviewController::store()` juga memanggilnya secara eksplisit sebagai safety net.
> **Update per 2026-08-27:** Audit `Accommodations\WizardForm` + blade selesai. Accessor rekursif `getCheckInTimeAttribute()`/`getCheckOutTimeAttribute()` dihapus. Validasi `prices` kini kondisional via `required_if:booking_mode,unit`. `has_breakfast` dipindah ke `unit_types`, tidak lagi disimpan ke tabel `accommodations`. Default transit icon diubah ke `map-pin`. Semua 23 test Livewire wizard lolos.
> **Update per 2026-08-30:** `AndroidManifest.xml` diperbaiki: referensi `@mipmap/launcher_icon` diganti `@mipmap/ic_launcher` dan meta-data Firebase `com.google.firebase.messaging.default_notification_icon` (menunjuk ke `@drawable/logo_launcher` yang tidak ada) dihapus karena Firebase tidak digunakan. Build debug Android kini berhasil link resource.
> **Update per 2026-08-29:** WizardForm icon inputs diganti dari free-text menjadi `<select>` dropdown dengan opsi Flutter-mapped yang valid. `HotelNormalizer` diintegrasikan ke pipeline `save()` untuk sanitasi `facility_groups`, `transport_points`, `faqs`, `questions`, dan `room_images`. Autocomplete suggestions disinkronkan dari master data `AccommodationSeeder` dan model `FacilityItem`/`NearbyPoint`. Dropdown `booking_mode` ditambahkan di Tab 1.
> **Update per 2026-09-03:** `HotelApiController::getFilterMetadata` diubah dari `->pluck('star_rating')` menjadi `->get()->pluck('star_rating')` karena `star_rating` bukan kolom fisik di tabel `accommodations`, melainkan accessor komputasi yang dihasilkan dari `selectRaw`. PostgreSQL gagal menguraikan alias `star_rating` pada query builder `pluck` tanpa `get()` terlebih dahulu.
> **Update per 2026-09-04:** Sinkronisasi endpoint rincian harga sewa (`GET accommodations/{id}/pricing` dan `properties/{id}/pricing`). `PropertyController::pricing` diperbarui dengan `UnitTypeResource` & `UnitTypePriceResource` untuk memastikan seluruh nilai nominal bertipe integer murni (menghindari type cast exception pada Dart). Model Dart `UnitPricing` & child models dilengkapi parser angka defensif `_toNum`/`_toInt`. Resolver rental period pada `RincianUnitScreen` diselaraskan agar memilih periode valid yang tersedia di database.

---

## 1. Status Resolusi Arsitektur (Selesai Direkonsiliasi)

| Topik | Isu Lama | Status & Solusi Baru |
|---|---|---|
| **Data Modeling Hotel vs Property** | Tabel paralel tidak konsisten & JSON blob `display_meta` tak terstruktur | ✅ **Terselesaikan:** 21 tabel ternormalisasi 3NF dengan single root `accommodations` & `booking_mode`. |
| **Harga & Kapasitas** | Duplikasi harga di properti dan room type | ✅ **Terselesaikan:** Single source of truth pada `unit_types` + `unit_type_prices`. Relasi `cheapestUnitType()` (`HasOne::ofMany`). |
| **Transformasi Output API** | Resource monolitik campur aduk | ✅ **Terselesaikan:** `AccommodationResource` auto-branching `hotelShape()` & `propertyShape()`, 100% cocok dengan master fixture JSON. |
| **Admin Form Wizards** | Form Livewire belum mendukung relasi ternormalisasi | ✅ **Terselesaikan:** `Properties\WizardForm` & `Hotels\WizardForm` mendukung 4-step wizard transaksional (`DB::transaction`). |
| **Flutter→Laravel Creation Drift** | Flutter `AccommodationFormScreen` mengirim 15+ field (facility_groups, policies, faqs, transport_points, gallery, star_rating) tapi Laravel `HostHotelController::store()` hanya menerima 11 field dasar | ✅ **Terselesaikan:** Controller `store()` kini menerima dan memproses semua field yang dikirim Flutter form. |

---

## 2. Flutter→Laravel Accommodation Creation Flow

### Alur Lengkap (Flutter Form → Laravel API)

```
Flutter AccommodationFormScreen
  ├── _submitHotel()
  │   ├── hotelPayload → POST host/hotels
  │   │   ├── name, star_rating, open_year, check_in_time, check_out_time
  │   │   ├── description, address, latitude, longitude
  │   │   ├── facility_groups[] → facility_groups table
  │   │   ├── policies{} → accommodation_policies table
  │   │   ├── deposit_amount, cancellation_policy
  │   │   ├── faqs[], transport_points[]
  │   │   └── gallery[] → galleries table
  │   └── roomTypesPayload[] → POST host/hotels/{id}/room-types
  │       ├── name, description, capacity_adults, capacity_children
  │       ├── max_guests, room_size_sqm, bed_configuration
  │       ├── base_price, price_original, breakfast_included
  │       ├── has_window, no_smoking, free_wifi, total_inventory
  │       └── facilities[], images[]
  └── _submitUnit()
      └── buildPropertyPayload() → POST host/properties
```

### Field Mapping: Flutter → Laravel → DB

| Flutter Field | Laravel Controller | DB Table | Status |
|---|---|---|---|
| name, address, description | `store()` validated | `accommodations` | ✅ |
| star_rating | `store()` validated | computed from reviews | ✅ |
| open_year, check_in_time, check_out_time | `store()` validated | `accommodations` | ✅ |
| cancellation_policy | `store()` validated | `accommodation_policies` | ✅ |
| deposit_amount | `store()` validated | `accommodations` | ✅ |
| facility_groups | `store()` processed | `facility_groups` + `facility_items` | ✅ |
| policies (child, extra_bed, smoking) | `store()` processed | `accommodation_policies` | ✅ |
| faqs | `store()` processed | `accommodation_questions` | ✅ |
| transport_points | `store()` processed | `nearby_points` | ✅ |
| gallery | `store()` processed | `galleries` | ✅ |
| room_types[] | `storeRoomType()` | `unit_types` | ✅ |
| room_type.prices | via unit type | `unit_type_prices` | ✅ |

### Perbandingan dengan Seeder

| Entitas | Seeder | Flutter Form | Catatan |
|---|---|---|---|
| Accommodation | ✅ Full fields | ✅ Full fields | Konsisten |
| UnitType (room) | ✅ 2 types (Merlynn) | ✅ Dynamic | Flutter dinamis |
| UnitTypePrice | ✅ daily price | Via room type | Konsisten |
| Gallery | ✅ 5 photos | ✅ Dynamic upload | Konsisten |
| Policy | ✅ cancellation + check_in | ✅ cancellation + general | Konsisten |
| FacilityGroup | ✅ 1 group + 6 items | ✅ Dynamic | Konsisten |
| FacilityTag | ✅ 4 tags | Via facility_tags | Konsisten |
| NearbyPoint | ✅ 3 points | ✅ Dynamic | Konsisten |
| Question (FAQ) | ✅ 2 FAQs | ✅ Dynamic | Konsisten |
| Review | ✅ 1 review + photo | ❌ Not in form | Reviews come from guests |

---

## 3. Catatan Integrasi Aktif

### 1. Model `Room` (Fisik)
Stok kamar hotel sepenuhnya menggunakan counter `unit_types.remaining` (real-time) dan bukan penomoran kamar fisik. Tabel `room_inventories` (daily calendar) sudah dihapus di refactoring terakhir.

### 2. Push Notification & Maps
- Parameter `AppConfig.googleMapsApiKey` dan endpoint token `POST devices/fcm-token` tersedia di backend untuk ekspansi masa depan tanpa memblokir runtime Flutter.

### 3. Known Resource Issues (Fixed)
- `AccommodationResource`: N+1 risk pada `question_count` → fixed dengan `whenLoaded()`
- `AccommodationHotelListResource`: null-cast pada `rating_label` → fixed
- `AccommodationListResource`: N+1 risk pada `city`, `rating` accessors → fixed
