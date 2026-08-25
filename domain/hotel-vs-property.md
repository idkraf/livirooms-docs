# Master Context — Accommodation: Property vs Hotel Architecture (Laravel 12)

> **Fungsi file ini.** Master contract dan arsitektur data PostgreSQL untuk entitas akomodasi (Hotel & Property) di `laravel/`.
> Berisi kontrak definisi, relasi 21 tabel ternormalisasi (3NF), mekanika inventaris, transformasi API Resources, dan invarian sistem.
>
> **Status:** Sesuai hasil audit v3 (2026-08-25). 100% konsisten dengan payload master [`GET_hotels_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id_new.json) dan [`GET_properties_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_properties_id_new.json).

---

## 1. Arsitektur Terpadu: Satu Entitas Akar `accommodations`

Hotel dan Property disatukan dalam satu entitas akar `accommodations` dengan diskriminator `booking_mode`:

- **`booking_mode = 'room'` (Hotel):** Dijual per tipe kamar (`unit_types`), stok dikelola per allotment harian (`total_inventory` / `remaining`).
- **`booking_mode = 'unit'` (Property):** Dijual per unit utuh (apartemen, villa, rumah, kost), memiliki tepat **1 baris `unit_types`** internal yang menjadi sumber tunggal kapasitas (`max_guests`, `bedrooms`, `bathrooms`) dan harga (`unit_type_prices`).

### Kenapa Bukan Dua Tabel Paralel atau JSON Blob?
1. **Zero JSON Blob:** Menghindari kolom `display_meta` yang tidak bisa di-query, di-index, atau divalidasi. Seluruh 9 field UI telah dipetakan ke kolom asli (`intro`, `map_preview`, `price_caption`, `is_flash_sale`), accessor turunan (`type_label`, `area_label`, `extra_media_count`), atau tabel terpisah (`accommodation_description_paragraphs`, `accommodation_details`).
2. **Single Source of Truth untuk Harga & Kapasitas:** Tidak ada lagi duplikasi kolom `guest_capacity`, `bedrooms`, `bathrooms`, `has_breakfast`, `price_from`, `price_original` di tabel `accommodations`. Semua dibaca on-the-fly dari `unit_types` via relasi `cheapestUnitType()` (`HasOne::ofMany`).
3. **Penyatuan Satelit dengan Konteks:** `facility_items` melayani 3 kebutuhan (`facility`, `furniture`, `spec`) lewat kolom `context`, menghindari duplikasi tabel dengan struktur serupa.

---

## 2. Peta Relasi 21 Tabel Produk

```
users (host) ──host_id──► accommodations ◄──city_id── cities
                               │ ◄──building_list_id── building_lists
    ┌──────────────────────────┴───────────────────────────────────────────────────────┐
    │                                                                                  │
    ├── unit_types (1:N) ──► unit_type_prices (1:N, daily/weekly/monthly)              │
    │                    ──► unit_type_images (1:N)                                    │
    │                                                                                  │
    ├── galleries (1:N, source: gallery | guest_media, is_cover)                       │
    ├── reviews (1:N) ──► review_photos (1:N)                                          │
    ├── accommodation_policies (1:N, section: general | check_in | deposit | cancellation) │
    ├── accommodation_questions (1:N, author_name/role & asked_by)                     │
    ├── nearby_points (1:N, transport & POI)                                           │
    │                                                                                  │
    ├── facility_groups (1:N, category, icon)                                          │
    ├── facility_items (1:N, context: facility | furniture | spec)                     │
    ├── facility_tags (1:N, string tag)                                                │
    │                                                                                  │
    ├── room_furniture_groups (1:N) ──► room_furniture_items (1:N, is_bed_config)      │
    ├── bed_facilities (1:N, ringkasan ranjang)                                       │
    │                                                                                  │
    ├── accommodation_description_paragraphs (1:N, description_extra)                  │
    └── accommodation_details (1:N, simple value | complex)                            │
          └── accommodation_detail_groups (1:N)                                        │
                └── accommodation_detail_lines (1:N, label + amount)                   │
```

---

## 3. Daftar 21 Model & Tabel

| # | Model Eloquent | Tabel Database | Peran & Keterangan |
|---|---|---|---|
| 1 | `Accommodation` | `accommodations` | Entitas akar (Hotel & Property). Diskriminator `booking_mode` (`room`/`unit`). |
| 2 | `BuildingList` | `building_lists` | Master data gedung/tower (`building_list` & `building_units`). |
| 3 | `UnitType` | `unit_types` | Sumber tunggal harga & kapasitas (`base_price`, `max_guests`, `bedrooms`, `bathrooms`). |
| 4 | `UnitTypePrice` | `unit_type_prices` | Harga periodik (`daily`, `weekly`, `monthly`) + deposit & cleaning fee. |
| 5 | `UnitTypeImage` | `unit_type_images` | Galeri foto khusus tipe kamar. |
| 6 | `FacilityGroup` | `facility_groups` | Kategori fasilitas ber-icon (Hotel style). |
| 7 | `FacilityItem` | `facility_items` | Item fasilitas dengan `context` (`facility`, `furniture`, `spec`). |
| 8 | `FacilityTag` | `facility_tags` | Tag fasilitas ringkas (array of string). |
| 9 | `Gallery` | `galleries` | Galeri foto utama (`source: gallery`) dan foto tamu (`source: guest_media`). |
| 10 | `Review` | `reviews` | Ulasan seragam skala 1-10. Rating agregat dihitung di level Accommodation. |
| 11 | `ReviewPhoto` | `review_photos` | Foto lampiran review. |
| 12 | `AccommodationPolicy` | `accommodation_policies` | Kebijakan terstruktur (`general`), kartu info (`check_in`, `deposit`), dan kebijakan pembatalan (`cancellation`). |
| 13 | `AccommodationQuestion` | `accommodation_questions` | Tanya jawab pengelola hotel (`author_role`) dan Q&A properti (`asked_by`). |
| 14 | `NearbyPoint` | `nearby_points` | Titik minat sekitar (stasiun, halte, bandara, mall). |
| 15 | `RoomFurnitureGroup` | `room_furniture_groups` | Grup ruangan furnitur (mis. Master Bedroom, Second Bedroom). |
| 16 | `RoomFurnitureItem` | `room_furniture_items` | Item furnitur + flag `is_bed_config` untuk konfigurasi ranjang. |
| 17 | `BedFacility` | `bed_facilities` | Ringkasan tipe ranjang di listing. |
| 18 | `AccommodationDescriptionParagraph` | `accommodation_description_paragraphs` | Paragraf tambahan untuk Property `description_extra`. |
| 19 | `AccommodationDetail` | `accommodation_details` | Rincian detail unit (bentuk sederhana `value` atau kompleks `groups`). |
| 20 | `AccommodationDetailGroup` | `accommodation_detail_groups` | Sub-grup detail kompleks (mis. "Mobil", "Motor"). |
| 21 | `AccommodationDetailLine` | `accommodation_detail_lines` | Baris tarif/biaya dalam sub-grup (mis. "Biaya kartu: 50.000"). |

---

## 4. Transformasi API Resource (`AccommodationResource`)

`App\Http\Resources\AccommodationResource` secara cerdas mengarahkan format output JSON berdasarkan `booking_mode`:

- Jika `booking_mode === 'room'`: memanggil `hotelShape()` → menghasilkan payload persis [`GET_hotels_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id_new.json).
- Jika `booking_mode === 'unit'`: memanggil `propertyShape()` → menghasilkan payload persis [`GET_properties_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_properties_id_new.json).

### Kontrak Eager Loading Wajib (Bebas N+1)
```php
// Eager Loading Hotel
Accommodation::hotels()->with([
    'city', 'buildingList', 'galleries',
    'policies', 'questions', 'nearbyPoints',
    'facilityGroups.items', 'cheapestUnitType',
    'unitTypes.images', 'unitTypes.facilityItems',
])->findOrFail($id);

// Eager Loading Property
Accommodation::properties()->with([
    'city', 'buildingList', 'host', 'galleries',
    'policies', 'questions', 'nearbyPoints',
    'facilityItems', 'facilityTags', 'bedFacilities',
    'roomFurnitureGroups.items', 'roomFurnitureGroups.bedConfig',
    'reviews.photos',
    'cheapestUnitType.prices',
    'descriptionParagraphs', 'details.groups.lines',
])->findOrFail($id);
```

---

## 5. Livewire Wizard Form (Admin & Mitra)

Manajemen Add/Edit Property dan Hotel di admin panel ditangani oleh dua komponen Livewire 4 terpisah yang mengimplementasikan multi-step wizard:

1. **`App\Livewire\Properties\WizardForm` (`livewire.properties.wizard_form`):**
   - **Tab 1 (Info Dasar):** Host, Kota, Gedung/Tower, Tipe Properti, Nama, Alamat, Status.
   - **Tab 2 (Kapasitas & Fasilitas):** Kapasitas Tamu, Kamar Tidur, Kamar Mandi, Luas m², Fasilitas checkbox.
   - **Tab 3 (Harga & Biaya):** Periode Sewa (harian/mingguan/bulanan/tahunan), Tarif Sewa, Cleaning Fee, Deposit, Service Fee.
   - **Tab 4 (Galeri & Konten):** Upload Galeri, Intro Marketing, Heading Paragraf, Flash Sale toggle.
   - **Persistence:** Menyimpan ke `accommodations` (`booking_mode = 'unit'`), `unit_types` (1 baris representasi), `unit_type_prices`, `facility_items` (`context = 'facility'`), dan `galleries`.

2. **`App\Livewire\Hotels\WizardForm` (`livewire.hotels.wizard_form`):**
   - **Tab 1 (Identitas Hotel):** Host, Kota Destinasi, Nama Hotel, Bintang (1-5), Tahun Buka, Jam Check-in/Check-out, Deposit Jaminan.
   - **Tab 2 (Tipe Kamar):** Repeater dinamis tipe kamar dengan ranjang, tarif dasar, coret harga, kapasitas, sarapan, dan fasilitas kamar.
   - **Tab 3 (Fasilitas & Kebijakan):** Checklist fasilitas 8-tab, aturan resepsionis 24 jam, anak, extra bed, deskripsi check-in/out.
   - **Tab 4 (Transit, FAQ & Galeri):** Repeater titik transit sekitar (jarak, durasi, icon), FAQ manager hotel, dan upload foto galeri.
   - **Persistence:** Menyimpan ke `accommodations` (`booking_mode = 'room'`), multiple `unit_types`, `accommodation_policies` (`section = 'general'`), `nearby_points`, `accommodation_questions`, dan `galleries`.

---

## 6. Invarian Utama yang Tidak Boleh Dilanggar

1. **`booking_mode` adalah satu-satunya diskriminator stok.** `'room'` untuk multi-room hotel, `'unit'` untuk single-unit property.
2. **`unit_types` adalah satu-satunya sumber harga & kapasitas.** Jangan pernah menambahkan kembali kolom `guest_capacity` atau `price_from` ke tabel `accommodations`.
3. **Seluruh field UI memiliki rumah relasional yang sah.** Tidak diperbolehkan menggunakan kolom JSON blob generik (`display_meta`).
4. **Relasi `cheapestUnitType()` wajib di-eager-load.** Accessor `price_from`, `bedrooms`, `bathrooms`, `has_breakfast` bergantung pada relasi ini.
5. **Setiap perubahan status pembayaran hanya bersumber dari Midtrans S2S Webhook.** Callback browser tidak boleh memutasi status transaksi.