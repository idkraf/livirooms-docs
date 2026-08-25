# Master Context — Accommodations: Backend & Frontend Architecture (Laravel 12 & Flutter)

> **Fungsi file ini.** Master reference komprehensif arsitektur data PostgreSQL, Laravel 12 Backend, API Resources, dan integrasi Flutter Frontend untuk seluruh entitas akomodasi (Hotel & Property) di ekosistem **Livirooms**.
>
> **Status:** 100% konsisten dengan skema 3NF PostgreSQL (21 tabel), Laravel 12, dan payload kontrak master [`GET_hotels_id.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id.json) serta [`GET_properties_id.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_properties_id.json).

---

# BAGIAN I: ARSITEKTUR BACKEND (LARAVEL 12)

## 1. Arsitektur Terpadu: Satu Entitas Akar `accommodations`

Hotel dan Property disatukan dalam satu entitas akar `accommodations` dengan diskriminator `booking_mode`:

- **`booking_mode = 'room'` (Hotel OTA):**
  - Dijual per tipe kamar (`unit_types`).
  - Mendukung banyak tipe kamar (mis. Deluxe, Executive Suite, Family Suite).
  - Stok dikelola per allotment harian (`total_inventory` / `remaining`).
  - Harga listing (`price_from`) dan kapasitas diturunkan otomatis dari kamar termurah aktif melalui relasi `cheapestUnitType()`.

- **`booking_mode = 'unit'` (Property Rental):**
  - Dijual per unit utuh (Apartemen, Villa, Rumah, Kost Eksklusif).
  - Memiliki tepat **1 baris `unit_types`** internal yang dibuat otomatis sebagai Single Source of Truth (SSoT) spesifikasi fisik (`max_guests`, `bedrooms`, `bathrooms`, `room_size_sqm`) dan harga multi-durasi (`unit_type_prices`: harian, mingguan, bulanan, tahunan).

### Tiga Pilar Arsitektur 3NF:
1. **Zero JSON Blob:** Semua data tampilan terstruktur ke kolom skema asli (`intro`, `map_preview`, `price_caption`, `is_flash_sale`), accessor turunan (`type_label`, `area_label`, `extra_media_count`, `cancellation_policy`), atau tabel relasional satelit (`accommodation_description_paragraphs`, `accommodation_details`).
2. **Single Source of Truth (SSoT) untuk Harga & Kapasitas:** Tidak ada duplikasi kolom `guest_capacity`, `bedrooms`, `bathrooms`, `has_breakfast`, `price_from`, `price_original` di tabel `accommodations`. Semua dihitung on-the-fly dari `unit_types` via `cheapestUnitType()` (`HasOne::ofMany`).
3. **Penyatuan Satelit Multi-Konteks:** Tabel `facility_items` melayani 3 kebutuhan (`context = 'facility' | 'furniture' | 'spec'`) untuk efisiensi skema tanpa redundansi struktur.

---

## 2. Diagram Relasi Lengkap 21 Tabel Produk (PostgreSQL)

```
                          ┌──────────────────────────┐
                          │       users (host)       │
                          └─────────────┬────────────┘
                                        │ host_id
                                        ▼
┌──────────────────┐  city_id   ┌──────────────────────────┐   building_list_id   ┌──────────────────┐
│      cities      │◄───────────┤      accommodations      ├─────────────────────►│  building_lists  │
└──────────────────┘            └─────────────┬────────────┘                      └──────────────────┘
                                              │
    ┌─────────────────────────────────────────┼───────────────────────────────────────────┐
    │                                         │                                           │
    ▼ (1:N)                                   ▼ (1:N)                                     ▼ (1:N)
┌──────────────────────────┐        ┌──────────────────────────┐        ┌──────────────────────────┐
│        unit_types        │        │        galleries         │        │         reviews          │
├──────────────────────────┤        ├──────────────────────────┤        ├──────────────────────────┤
│ id, name, slug,          │        │ id, accommodation_id,    │        │ id, accommodation_id,    │
│ capacity_adults,         │        │ url, caption, source,    │        │ user_name, rating (1-10),│
│ capacity_children,       │        │ is_cover, sort_order     │        │ period_label, comment,   │
│ max_guests, bedrooms,    │        └──────────────────────────┘        │ host_reply               │
│ bathrooms, base_price,   │                                            └────────────┬─────────────┘
│ price_original, etc.     │                                                         │ (1:N)
└───────────┬──────────────┘                                                         ▼
            │                                                           ┌──────────────────────────┐
    ┌───────┴─────────────────────────────────┐                         │      review_photos       │
    │ (1:N)                                   │ (1:N)                   ├──────────────────────────┤
    ▼                                         ▼                         │ id, review_id, url,      │
┌──────────────────────────┐        ┌──────────────────────────┐        │ sort_order               │
│     unit_type_prices     │        │     unit_type_images     │        └──────────────────────────┘
├──────────────────────────┤        ├──────────────────────────┤
│ id, unit_type_id,        │        │ id, unit_type_id, url,   │
│ price_type, amount,      │        │ caption, sort_order      │
│ cleaning_fee, deposit,   │        └──────────────────────────┘
│ service_fee              │
└──────────────────────────┘

    ┌─────────────────────────────────────────┼───────────────────────────────────────────┐
    │                                         │                                           │
    ▼ (1:N)                                   ▼ (1:N)                                     ▼ (1:N)
┌──────────────────────────┐        ┌──────────────────────────┐        ┌──────────────────────────┐
│  accommodation_policies  │        │ accommodation_questions  │        │      nearby_points       │
├──────────────────────────┤        ├──────────────────────────┤        ├──────────────────────────┤
│ id, accommodation_id,    │        │ id, accommodation_id,    │        │ id, accommodation_id,    │
│ section (general |       │        │ question, answer,        │        │ name, type, distance,    │
│ check_in | deposit |     │        │ author_name, author_role,│        │ duration, icon, tone,    │
│ cancellation),           │        │ asked_by, sort_order     │        │ sort_order               │
│ cancellation_policy, etc.│        └──────────────────────────┘        └──────────────────────────┘
└──────────────────────────┘

    ┌─────────────────────────────────────────┼───────────────────────────────────────────┐
    │                                         │                                           │
    ▼ (1:N)                                   ▼ (1:N)                                     ▼ (1:N)
┌──────────────────────────┐        ┌──────────────────────────┐        ┌──────────────────────────┐
│     facility_groups      │        │      facility_items      │        │      facility_tags       │
├──────────────────────────┤        ├──────────────────────────┤        ├──────────────────────────┤
│ id, accommodation_id,    │        │ id, facility_group_id,   │        │ id, accommodation_id,    │
│ unit_type_id (nullable), │        │ accommodation_id,        │        │ unit_type_id (nullable), │
│ category, icon,          │        │ unit_type_id (nullable), │        │ name, sort_order         │
│ sort_order               │        │ context (facility |      │        └──────────────────────────┘
└───────────┬──────────────┘        │ furniture | spec),       │
            │ (1:N)                 │ name, icon, is_available │
            ▼                       │ badge, count, sort_order │
┌──────────────────────────┐        └──────────────────────────┘
│  (facility_items linked) │
└──────────────────────────┘

    ┌─────────────────────────────────────────┼───────────────────────────────────────────┐
    │                                         │                                           │
    ▼ (1:N)                                   ▼ (1:N)                                     ▼ (1:N)
┌──────────────────────────┐        ┌──────────────────────────┐        ┌──────────────────────────┐
│  room_furniture_groups   │        │      bed_facilities      │        │  accommodation_desc_...  │
├──────────────────────────┤        ├──────────────────────────┤        ├──────────────────────────┤
│ id, accommodation_id,    │        │ id, accommodation_id,    │        │ id, accommodation_id,    │
│ unit_type_id (nullable), │        │ icon, label, note, count,│        │ paragraph, sort_order    │
│ room, sort_order         │        │ sort_order               │        └──────────────────────────┘
└───────────┬──────────────┘        └──────────────────────────┘
            │ (1:N)
            ▼
┌──────────────────────────┐
│   room_furniture_items   │
├──────────────────────────┤
│ id, room_furniture_..._id│
│ name, is_bed_config,     │
│ sort_order               │
└──────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                     │
    ▼ (1:N)                                                                               │
┌──────────────────────────┐                                                              │
│  accommodation_details   │                                                              │
├──────────────────────────┤                                                              │
│ id, accommodation_id,    │                                                              │
│ icon, label, value,      │                                                              │
│ sort_order               │                                                              │
└───────────┬──────────────┘                                                              │
            │ (1:N, mode kompleks)                                                        │
            ▼                                                                             │
┌──────────────────────────┐                                                              │
│ accommodation_detail_... │                                                              │
├──────────────────────────┤                                                              │
│ id, detail_id, title,    │                                                              │
│ sort_order               │                                                              │
└───────────┬──────────────┘                                                              │
            │ (1:N)                                                                       │
            ▼                                                                             │
┌──────────────────────────┐                                                              │
│ accommodation_detail_... │                                                              │
├──────────────────────────┤                                                              │
│ id, group_id, label,     │                                                              │
│ amount (decimal:2),      │                                                              │
│ sort_order               │                                                              │
└──────────────────────────┘                                                              │
```

---

## 3. Rincian 21 Model Eloquent & Tabel Database

| # | Model Eloquent | Tabel Database | Peran Arsitektur |
|---|---|---|---|
| 1 | [`Accommodation`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/Accommodation.php) | `accommodations` | Root Entity (Hotel & Property). Memegang identitas inti, koordinat, jam check-in/out, rating terhitung. |
| 2 | [`BuildingList`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/BuildingList.php) | `building_lists` | Master tower/gedung apartemen (`building_list` / `building_units`). |
| 3 | [`UnitType`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/UnitType.php) | `unit_types` | **Single Source of Truth** harga, kapasitas (`max_guests`, `bedrooms`, `bathrooms`, `base_price`). |
| 4 | [`UnitTypePrice`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/UnitTypePrice.php) | `unit_type_prices` | Harga periodik Property (`daily`, `weekly`, `monthly`, `yearly`) + deposit & cleaning fee. |
| 5 | [`UnitTypeImage`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/UnitTypeImage.php) | `unit_type_images` | Foto galeri spesifik tipe kamar hotel. |
| 6 | [`FacilityGroup`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/FacilityGroup.php) | `facility_groups` | Kategori fasilitas bertingkat ber-ikon (Hotel). |
| 7 | [`FacilityItem`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/FacilityItem.php) | `facility_items` | Item fasilitas multi-konteks (`context = facility | furniture | spec`). |
| 8 | [`FacilityTag`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/FacilityTag.php) | `facility_tags` | Tag/chip fasilitas ringkas pada kartu listing. |
| 9 | [`Gallery`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/Gallery.php) | `galleries` | Media galeri utama (`source = gallery`) dan foto tamu (`source = guest_media`). |
| 10 | [`Review`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/Review.php) | `reviews` | Ulasan seragam skala 1.0 - 10.0 dengan rating agregat otomatis. |
| 11 | [`ReviewPhoto`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/ReviewPhoto.php) | `review_photos` | Foto lampiran bukti ulasan dari tamu. |
| 12 | [`AccommodationPolicy`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/AccommodationPolicy.php) | `accommodation_policies` | Kebijakan terstruktur: `general`, `check_in`, `deposit`, dan `cancellation`. |
| 13 | [`AccommodationQuestion`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/AccommodationQuestion.php) | `accommodation_questions` | Tanya jawab manajemen hotel (`author_role`) dan FAQ properti (`asked_by`). |
| 14 | [`NearbyPoint`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/NearbyPoint.php) | `nearby_points` | POI & transit terdekat (stasiun, halte, bandara, mall, jarak & durasi). |
| 15 | [`RoomFurnitureGroup`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/RoomFurnitureGroup.php) | `room_furniture_groups` | Grup ruangan perabot (mis. Master Bedroom, Living Room). |
| 16 | [`RoomFurnitureItem`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/RoomFurnitureItem.php) | `room_furniture_items` | Item perabot + flag `is_bed_config` untuk konfigurasi ranjang. |
| 17 | [`BedFacility`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/BedFacility.php) | `bed_facilities` | Kartu ringkasan ranjang (King Bed, Single Bed, ukuran & jumlah). |
| 18 | [`AccommodationDescriptionParagraph`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/AccommodationDescriptionParagraph.php) | `accommodation_description_paragraphs` | Paragraf long-form tambahan (`description_extra`). |
| 19 | [`AccommodationDetail`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/AccommodationDetail.php) | `accommodation_details` | Rincian detail unit (mode sederhana `value` atau kompleks `groups`). |
| 20 | [`AccommodationDetailGroup`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/AccommodationDetailGroup.php) | `accommodation_detail_groups` | Sub-grup detail kompleks (mis. "Parkir Mobil", "Parkir Motor"). |
| 21 | [`AccommodationDetailLine`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/AccommodationDetailLine.php) | `accommodation_detail_lines` | Baris tarif dalam sub-grup (label + amount). |

---

## 4. API Resources & Eager Loading Contract (Zero N+1)

Transformasi data dilakukan oleh [`AccommodationResource`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Resources/AccommodationResource.php) yang secara otomatis mencabangkan output JSON sesuai `booking_mode`:
- **`booking_mode === 'room'`:** memanggil `hotelShape()` → menghasilkan JSON identik dengan [`GET_hotels_id.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id.json).
- **`booking_mode === 'unit'`:** memanggil `propertyShape()` → menghasilkan JSON identik dengan [`GET_properties_id.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_properties_id.json).

### Kontrak Eager Loading Wajib di Controller:
```php
// Hotel (booking_mode = 'room')
Accommodation::hotels()->with([
    'city', 'buildingList', 'galleries',
    'policies', 'questions', 'nearbyPoints',
    'facilityGroups.items', 'cheapestUnitType',
    'unitTypes.images', 'unitTypes.facilityItems',
])->findOrFail($id);

// Property (booking_mode = 'unit')
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

## 5. Livewire 4 Multi-Step Form Wizards (Admin Panel)

1. **[`App\Livewire\Properties\WizardForm`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Livewire/Properties/WizardForm.php):**
   - **Tab 1 (Info Dasar):** Host, Kota, Gedung/Tower, Tipe Properti, Nama, Alamat, Status.
   - **Tab 2 (Kapasitas & Fasilitas):** Kapasitas Tamu, Kamar Tidur, Kamar Mandi, Luas m², Checklist Fasilitas.
   - **Tab 3 (Harga & Biaya):** Periode Sewa, Tarif Pokok, Cleaning Fee, Deposit, Service Fee.
   - **Tab 4 (Galeri & Konten):** Upload Foto, Intro Marketing, Heading Paragraf, Flash Sale toggle.
   - **Persistence:** Dalam satu `DB::transaction()`, menyimpan ke `accommodations` (`booking_mode = 'unit'`), `unit_types` (1 baris representasi), `unit_type_prices`, `accommodation_policies` (`section = 'cancellation'`), `facility_items`, dan `galleries`.

2. **[`App\Livewire\Hotels\WizardForm`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Livewire/Hotels/WizardForm.php):**
   - **Tab 1 (Identitas Hotel):** Host, Kota, Nama Hotel, Bintang (1-5), Tahun Buka, Jam Check-in/Out, Deposit, Kebijakan Pembatalan.
   - **Tab 2 (Tipe Kamar):** Repeater dinamis tipe kamar (nama, ranjang, tarif dasar, harga coret, kapasitas dewasa/anak, sarapan, fasilitas kamar).
   - **Tab 3 (Fasilitas & Kebijakan):** Checklist fasilitas bertingkat 8 kategori, aturan resepsionis 24 jam, kebijakan anak, extra bed.
   - **Tab 4 (Transit, FAQ & Galeri):** Repeater titik transit sekitar (jarak, durasi, ikon), FAQ manajer hotel, dan upload galeri.
   - **Persistence:** Dalam satu `DB::transaction()`, menyimpan ke `accommodations` (`booking_mode = 'room'`), multiple `unit_types`, `accommodation_policies` (`section = 'general'` & `section = 'cancellation'`), `nearby_points`, `accommodation_questions`, dan `galleries`.

---

# BAGIAN II: INTEGRASI FLUTTER FRONTEND

## 1. Aliran Konsumsi Data & Model Dart

Aplikasi Flutter Livirooms mengonsumsi data akomodasi melalui REST API dengan arsitektur **Provider** dan package `http`:

```
Backend API (JSON Envelope)
  ├── GET /api/v1/hotels/{id}        ──► HotelDetailResponse.fromJson() ──► Hotel Model
  ├── GET /api/v1/properties/{id}    ──► PropertyDetailResponse.fromJson() ──► PropertyDetail Model
  └── GET /api/v1/accommodations/{id}──► Auto-detected via booking_mode
```

### Pemetaan Field Payload Master ke Model Dart:

| Field JSON Payload | Tipe Data | Model Dart Target | Komponen UI Flutter |
|---|---|---|---|
| `id` / `property_id` | `int` | `id` | Primary Key & Identitas Navigasi |
| `name` | `String` | `name` | Judul AppBar & Header Layar |
| `booking_mode` | `String` | `bookingMode` | Pengarah Rendering UI (`'room'` vs `'unit'`) |
| `rating` | `double` | `rating` | Badge Skor Rating (Skala 1.0 - 10.0) |
| `rating_label` | `String` | `ratingLabel` | Label Kualitatif ("Istimewa", "Sangat Baik") |
| `review_count` | `int` | `reviewCount` | Teks Jumlah Ulasan "(428 ulasan)" |
| `price_from` | `int` | `priceFrom` | Teks Harga Kartu "Mulai dari Rp 685.000 /malam" |
| `price_original` | `int?` | `priceOriginal` | Teks Harga Coret Diskon |
| `gallery` | `List<String>` | `gallery` | `CarouselSlider` / PageView Header Foto |
| `cover_image` | `String?` | `coverImage` | Thumbnail Listing & Hero Animation |
| `building_list` / `building_units` | `Map` | `BuildingList` | Kartu Info Kawasan / Gedung Hunian |
| `facility_tags` | `List<String>` | `facilityTags` | `Wrap` Chip Fasilitas Ringkas |
| `facilities` | `List<FacilityGroup>` | `facilities` | Grid / List Fasilitas Hotel Berkelompok |
| `policy_notes` | `Map` | `PolicyNotes` | Accordion / Card Aturan Check-in & Jam Resepsionis |
| `cancellation_policy` | `String?` | `cancellationPolicy` | Badge / Accordion Kebijakan Pembatalan |
| `questions` | `List<Question>` | `questions` | Accordion FAQ Tanya Jawab Manajer |
| `nearby_points` | `List<NearbyPoint>` | `nearbyPoints` | List Akses Transportasi & POI Terdekat |
| `unit_types` | `List<RoomType>` | `roomTypes` | List Kartu Pilihan Kamar Hotel (Pemesanan Kamar) |
| `specs` | `List<PropertySpec>` | `specs` | Grid Spesifikasi Properti (Luas, Kamar, Furnished) |
| `room_furniture_groups` | `List<FurnitureGroup>` | `furnitureGroups` | List Detail Perabot & Bed Config per Ruangan |
| `unit_detail` | `List<UnitDetail>` | `unitDetails` | List Rincian Biaya & Spesifikasi Unit Lengkap |
| `reviews` | `List<Review>` | `reviews` | List Card Ulasan Tamu + Galeri Foto Tamu |

---

## 2. Navigasi & Tampilan Layar (Screens)

### 1. Layar Hotel Detail (`HotelDetailScreen`)
- **Header Foto:** Carousel foto galeri hotel dengan counter indeks dan tombol favorit/share.
- **Header Info:** Nama hotel, bintang (1-5 bintang), rating badge (1-10), lokasi kota.
- **Blok Pilihan Kamar (`unit_types`):**
  - Render kartu per tipe kamar (Deluxe, Suite, dll).
  - Menampilkan foto kamar (`images`), konfigurasi ranjang (`bed_configuration`), luas m², sisa stok (`remaining`), sarapan (`has_breakfast`), dan harga dasar (`base_price`).
  - Tombol "Pilih Kamar" mengarahkan ke form pemilihan jumlah kamar & checkout.
- **Blok Fasilitas (`facilities`):** Tab / Grid kategori fasilitas (Fasilitas Utama, Restoran, Spa, Transportasi).
- **Blok Akses & Lokasi (`nearby_points`):** Menampilkan stasiun, halte, bandara dengan durasi dan jarak.
- **Blok Kebijakan & FAQ (`policy_notes`, `questions`):** Jam check-in/out, deposit jaminan, dan FAQ manajer.

### 2. Layar Property Detail (`PropertyDetailScreen`)
- **Header Banner & Info:** Cover image, nama unit/apartemen, tipe hunian, harga sewa per bulan/hari.
- **Spesifikasi Cepat (`specs`):** Ikon kapasitas tamu, jumlah kamar tidur, kamar mandi, dan luas unit.
- **Konfigurasi Ranjang (`bed_facilities`):** Kartu visual jenis dan ukuran kasur per kamar.
- **Perabot & Ruangan (`room_furniture_groups`):** Rincian perlengkapan Master Bedroom, Dapur, Living Room.
- **Rincian Biaya Unit (`unit_detail`):** Detail biaya sewa, biaya parkir motor/mobil bulanan, biaya kartu akses.
- **Kebijakan Pembatalan & Catatan Check-in (`check_in_notes`, `cancellation_policy`).
- **Bottom Bar Sewa:** Menampilkan pilihan opsi sewa (Harian / Bulanan / Tahunan) dan tombol "Sewa Sekarang".

---

## 3. Alur Transaksi & Pembayaran (Midtrans Snap Flow)

```
[Flutter App] ── 1. POST /api/v1/bookings ──► [Laravel Backend]
                                                    │
                                             2. Create Booking (status: pending)
                                             3. Request Snap Token ke Midtrans API
                                                    │
[Flutter App] ◄── 4. Return snap_token & redirect_url ─┘
     │
5. Buka Midtrans Snap WebView
     │
6. Tamu Selesaikan Pembayaran di Payment Gateway
     │
     ├──► 7. Midtrans Server-to-Server (S2S) Webhook ──► [Laravel Webhook Handler]
     │                                                           │
     │                                                    8. DB Transaction:
     │                                                       - Mutasi Status Booking -> 'confirmed'
     │                                                       - Catat Settlement di payments
     │                                                       - Kirim Notifikasi / Push Notification
     │
     └──► 9. Redirect Browser / WebView ke Deep Link:
             livirooms://payment-result?order_id={id}&status={status}
                     │
             10. Ditangkap oleh Flutter DeepLinkHandler
                     │
             11. Arahkan ke Layar BookingSuccessScreen / BookingFailedScreen
```

---

## 4. Sembilan Invarian Utama Sistem (System Invariants)

1. **`booking_mode` adalah satu-satunya diskriminator stok.** `'room'` untuk multi-room hotel OTA, `'unit'` untuk single-unit rental properti.
2. **`unit_types` adalah satu-satunya sumber kebenaran (SSoT) harga & kapasitas.** Tidak ada kolom kapasitas atau tarif sewa di tabel `accommodations`.
3. **Seluruh field antarmuka memiliki entitas relasional yang valid.** Dilarang menambahkan kolom JSON blob generik (`display_meta`).
4. **Relasi `cheapestUnitType()` wajib di-eager-load.** Accessor `price_from`, `bedrooms`, `bathrooms`, `has_breakfast` bergantung pada relasi ini.
5. **Kebijakan pembatalan dikelola di `accommodation_policies`.** Disimpan pada baris dengan `section = 'cancellation'`.
6. **Satu-satunya sumber perubahan status pembayaran adalah Midtrans S2S Webhook.** Callback browser atau deep link frontend tidak boleh mengubah status pembayaran.
7. **Skala rating seragam 1.0 - 10.0.** Seluruh rating dihitung dari rata-rata tabel `reviews`.
8. **Eager loading bebas N+1 wajib diterapkan pada seluruh endpoint API.**
9. **Dokumentasi `docs/` wajib selalu sinkron dengan implementasi kode aktif.**
