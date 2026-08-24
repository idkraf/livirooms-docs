# Master Context — Property vs Hotel (Laravel)

> **Fungsi file ini.** Brief wajib-baca sebelum menyentuh apa pun yang berkaitan
> dengan properti atau hotel di `laravel/`. Isinya *kontrak* — definisi, relasi,
> inventaris, dan invarian yang tidak boleh dilanggar. Bukan tutorial, bukan
> narasi implementasi.
>
> Untuk narasi mendalam per fitur, dokumen ini **menunjuk**, tidak menyalin:
> - `docs/properties/system.md` — model unit, harga per periode, pencarian
> - `docs/hotel/01-database-migration.md` … `07-compatibility-map.md` — modul OTA
> - `docs/payments/flow.md` — booking → order → payment → webhook
>
> **Snapshot per 2026-08-20.** Layer Resource sedang aktif direfaktor hari ini
> (lihat §8). Angka & baris kode diverifikasi langsung dari kode pada tanggal itu.

---

## 1. Dua konsep, satu tabel induk

### `Property` — entitas dasar

Tabel `properties` menampung **semua** listing yang bisa dijual: apartemen,
rumah, villa, hotel residence, guest house, kost eksklusif, **dan** hotel.
Isinya fakta fisik bangunan:

`host_id`, `city_id`, `property_type`, `booking_mode`, `name`, `building_name`,
`description`, `address`, `latitude`, `longitude`, `guest_capacity`, `bedrooms`,
`bathrooms`, `status`, `cancellation_policy`, `gallery`, `facilities`.

Dalam bentuk defaultnya, Property dijual **sebagai satu unit utuh**: tamu
menyewa seluruh hunian untuk satu periode. Periodenya harian / mingguan /
bulanan / tahunan lewat `property_prices`.

### `Hotel` — entitas ekstensi, bukan entitas paralel

`hotels` **tidak punya** nama, alamat, maupun koordinat. Ia hanya menyimpan
tambahan khas hotel komersial: `star_rating`, `open_year`, `check_in_time`,
`check_out_time`, `deposit_amount`, plus blok JSONB (`score`,
`facility_groups`, `transport_points`, `faqs`, `review_quotes`, `policies`).

Foreign key-nya dideklarasikan `->unique()`, jadi relasinya **1:1 ketat** —
`laravel/database/migrations/2026_08_13_000002_create_hotels_table.php:12`.
Konsekuensinya: **setiap hotel selalu punya baris `properties`.** Hotel
memperluas Property, tidak pernah menggantikannya.

---

## 2. Diskriminator — satu-satunya sakelar

`properties.booking_mode`, ditambahkan di
`2026_08_13_000001_update_properties_for_hotels.php:12`. Dua nilai:

| Nilai | Arti |
|---|---|
| `'unit'` (default) | Sewa seluruh unit. Stok = ada/tidak ada booking bentrok. |
| `'room'` | Sewa per kamar. Stok = counter allotment harian. |

**Jangan pernah menyimpulkan mode dari `property_type`.** Migration yang sama
memang melebarkan CHECK constraint PostgreSQL agar menerima `'hotel'` sebagai
tipe, tapi `hotel_residence` dan `guest_house` tetap sah berjalan sebagai
`booking_mode = 'unit'`.

> `property_type` mendeskripsikan **bangunannya**.
> `booking_mode` mendeskripsikan **cara stoknya dijual**.

Di sisi transaksi, cerminnya adalah `bookings.booking_type` (`'unit'` | `'room'`)
— `2026_08_13_000006_update_bookings_for_hotels.php:11`. Nilainya **wajib
konsisten** dengan `booking_mode` properti induknya.

### Dua mekanika ketersediaan yang benar-benar berbeda

**Mode unit** — tersedia = **tidak ada booking yang bentrok**. Query memakai
`whereDoesntHave('bookings', …)` terhadap baris yang statusnya bukan
`cancelled`/`expired`. Tabel `availabilities` menambah pemblokiran per tanggal
(termasuk `is_buffer`).

**Mode room** — tersedia = **counter**. `room_inventories` menyimpan satu baris
per `room_type_id` × `date` berisi `allotment`, `booked_count`, `price`,
`is_closed`. Tipe kamar baru bisa dibooking kalau
`(allotment - booked_count) >= rooms_count` **untuk setiap malam** yang diminta
— `app/Models/RoomType.php:76` (`scopeAvailableForDates`).

---

## 3. Peta relasi

```
users ──host_id──► properties ◄──city_id── cities
                        │
    property_type: apartment | house | villa | hotel_residence
                 | guest_house | exclusive_kost | hotel
    booking_mode:  'unit' ──────────┐        'room' ──────────┐
                                    │                         │
   ┌─────────────── MODE UNIT ──────┘                         │
   │  availabilities        (1 baris / tanggal / property)    │
   │  property_prices       (daily|weekly|monthly|yearly)     │
   │  property_pricing_options, property_special_prices,      │
   │  property_add_ons, property_payment_plans (+entries),    │
   │  property_promos, property_unit_details, …               │
   │                                                          │
   └── hotels  (1:1, property_id UNIQUE, cascade) ◄───────────┘
         ├── room_types (1:N)
         │     ├── room_inventories (1 baris / tanggal / room_type)
         │     │     allotment · booked_count · price · is_closed
         │     └── rooms (1:N)   ⚠ tabel ada, model TIDAK dipakai — §10
         ├── hotel_policies (1:1)
         ├── hotel_score_components (1:N)
         ├── hotel_transport_points (1:N)
         ├── hotel_faqs (1:N)
         └── hotel_review_quotes (1:N)
```

Sisi transaksi:

```
bookings
  │ property_id ──► properties
  │ booking_type: 'unit' | 'room'   ← wajib cocok dgn properties.booking_mode
  ├── booking_rooms (1:N)      hanya saat booking_type = 'room'
  │     room_type_id · quantity · price_per_night · subtotal
  │     room_number · room_name · guest_first_name · guest_last_name
  ├── booking_insurances (1:1) ──► insurance_plans ──► insurance_providers
  └── orders (1:1) ──► payments (1:N)
```

### Deklarasi Eloquent

| Relasi | Lokasi |
|---|---|
| `Property hasOne Hotel` | `app/Models/Property.php:186` |
| `Property hasMany PropertyPrice` | `app/Models/Property.php:66` |
| `Property hasOne PropertyOther` (nama method: `other()`) | `app/Models/Property.php:96` |
| `Property morphMany Media` · `morphToMany Facility` | `app/Models/Property.php:54-64` |
| `Property hasMany Booking` · `hasMany Review` | `app/Models/Property.php:191-199` |
| `Hotel belongsTo Property` | `app/Models/Hotel.php:43` |
| `Hotel hasMany RoomType` | `app/Models/Hotel.php:73` |
| `Hotel hasMany RoomType` ter-filter `is_active` (`activeRoomTypes`) | `app/Models/Hotel.php:78` |
| `Hotel hasOne HotelPolicy` · `hasMany` score/transport/faq/quote | `app/Models/Hotel.php:48-71` |
| `RoomType belongsTo Hotel` | `app/Models/RoomType.php:54` |
| `RoomType hasMany RoomInventory` | `app/Models/RoomType.php:71` |
| `RoomInventory belongsTo RoomType` | `app/Models/RoomInventory.php:38` |
| `Booking hasMany BookingRoom` | `app/Models/Booking.php:88` |
| `Booking belongsToMany RoomType` via `booking_rooms` | `app/Models/Booking.php:93` |
| `Booking hasOne BookingInsurance` | `app/Models/Booking.php:100` |

### Accessor turunan yang dipakai API

- `Hotel::getPriceFromAttribute()` — `app/Models/Hotel.php:95`. Harga headline
  hotel **tidak pernah disimpan** di `hotels`; selalu dihitung dari
  `base_price` room type aktif termurah.
- `Booking::getIsHotelAttribute()` — `app/Models/Booking.php:106`, mengembalikan
  `booking_type === 'room'`. Pasangannya `scopeHotel()` / `scopeUnit()`
  (`:120-128`) dipakai job & laporan untuk memisahkan dua alur.

---

## 4. Migration

97 file di `laravel/database/migrations/`. Yang relevan:

### Layer properti dasar

| File | Isi |
|---|---|
| `2026_07_14_080100_create_properties_table.php` | tabel akar |
| `2026_07_14_080300_create_bookings_table.php` | transaksi |
| `2026_07_14_080400_create_availabilities_table.php` | blocking tanggal mode unit |
| `2026_07_14_080500_create_property_prices_table.php` | harga per periode |
| `2026_08_08_000002_add_city_id_to_properties_table.php` | relasi kota |
| `2026_08_09_121226_add_is_buffer_to_availabilities_table.php` | buffer antar-booking |
| `2026_08_09_121257_add_cancellation_policy_to_properties_table.php` | |
| `2026_08_18_000001_add_bathrooms_to_properties_table.php` | |

### Jembatan hotel — seri `2026_08_13` (9 migration yang membuat pemisahan ini)

| File | Isi |
|---|---|
| `000001_update_properties_for_hotels.php` | **`booking_mode`** + pelebaran CHECK `property_type` |
| `000002_create_hotels_table.php` | ekstensi 1:1 |
| `000003_create_room_types_table.php` | |
| `000004_create_rooms_table.php` | kamar fisik — lihat §10 |
| `000005_create_room_inventories_table.php` | allotment harian |
| `000006_update_bookings_for_hotels.php` | **`booking_type`** + kolom tamu OTA |
| `000007_create_booking_rooms_table.php` | |
| `000008_create_master_facilities_tables.php` | `facilities` master |
| `000009_create_insurance_tables.php` | `insurance_providers`, `insurance_plans`, `booking_insurances` |

Lalu `2026_08_15_000001_add_hotel_ota_columns.php` menambah kolom OTA ke
`hotels`, `room_types`, `bookings`, dan `booking_rooms` dalam satu migration.

### Klaster detail properti — `2026_08_18_000005`–`000027` (23 migration)

Normalisasi apa yang dulu berupa JSON di `properties`: `media`,
`model_has_facilities`, `property_pricing_options`, `property_special_prices`,
`property_add_ons`, `property_payment_plans` (+`_entries`), `property_promos`,
`property_other_core`, `property_extra_descriptions`, `property_review_tables`,
`property_specs`, `property_bed_facilities`, `property_building_facilities`
(+`_all`), `property_room_furniture` (+`_groups`, `_items`),
`property_check_in_notes`, `property_deposit_notes`, `property_unit_details`,
`property_nearby_places`, `property_building_units`.

### Klaster detail hotel — `2026_08_18_000028`–`000032` (5 migration)

Padanan tabel untuk kolom JSONB di `hotels`: `hotel_policies`,
`hotel_score_components`, `hotel_transport_points`, `hotel_faqs`,
`hotel_review_quotes`.

**Kedua jalur penyimpanan masih hidup berdampingan** — tabel ternormalisasi
*dan* kolom JSONB. `HotelResource` membaca tabel dulu, fallback ke JSONB.
Jangan hapus kolom JSONB-nya (§9).

---

## 5. Model

74 file di `laravel/app/Models/`.

| Kelompok | Model |
|---|---|
| **Pasangan inti** | `Property`, `Hotel` |
| **Rantai kamar** | `RoomType`, `RoomInventory`, `Room`, `BookingRoom` |
| **Satelit hotel** | `HotelPolicy`, `HotelScoreComponent`, `HotelTransportPoint`, `HotelFaq`, `HotelReviewQuote` |
| **Harga & stok** | `PropertyPrice`, `PropertyPricingOption`, `PropertySpecialPrice`, `PropertyPromo`, `PropertyAddOn`, `PropertyPaymentPlan`, `PropertyPaymentPlanEntry`, `Availability` |
| **Detail properti** | `PropertyOther`, `PropertySpec`, `PropertyUnitDetail`, `PropertyNearbyPlace`, `PropertyBuildingUnit`, `PropertyExtraDescription`, `PropertyCheckInNote`, `PropertyDepositNote`, `PropertyBedFacility`, `PropertyBuildingFacility`, `PropertyBuildingFacilityAll`, `PropertyRoomFurniture` (+`Group`, `Item`), `PropertyReviewSummary`, `PropertyReviewBreakdown`, `PropertyQuestion`, `PropertyGuestMedia` |
| **Bersama** | `Booking`, `Media`, `Facility`, `ModelHasFacility`, `City` |
| **Asuransi** | `InsuranceProvider`, `InsurancePlan`, `BookingInsurance` |

Catatan: `laravel/CLAUDE.md` masih menulis "33 model" — itu drift.

---

## 6. API & Controller

File route: `laravel/routes/api_mobile.php` — **84 endpoint** di bawah prefix
`api/v1` (21 publik, 63 di balik `auth:sanctum`).

| Endpoint | Controller & method |
|---|---|
| `GET properties` | `Api/PropertyController::index` — **pencarian dual-mode** (`:21`) |
| `GET properties/{property}` | `Api/PropertyController::show` (`:205`) |
| `GET properties/{property}/pricing` | `Api/PropertyController::pricing` (`:223`) |
| `GET properties/{property}/availability` | `Api/PropertyController::availability` (`:263`) |
| `GET properties/{property}/host` | `Api/PropertyController::host` (`:414`) |
| `GET properties/{property}/reviews` | `Api/ReviewController::index` |
| `GET hotels` | `Api/HotelApiController::index` (`:26`) |
| `GET hotels/{hotel}` | `Api/HotelApiController::show` (`:211`) |
| `GET hotels/{hotel}/room-types` | `Api/HotelApiController::roomTypes` (`:234`) |
| `GET home` | `Api/HomeController::index` — feed campur unit + hotel |
| `POST booking-property` | `Api/BookingController::storeProperty` (`:243`) |
| `POST booking-hotels` | `Api/BookingController::storeHotel` (`:289`) |
| `POST bookings` | `Api/BookingController::store` (`:209`) — **legacy**, dispatch via `booking_type` |
| `GET host/properties*` | `Api/PropertyController::hostIndex` / `hostShow` / `store` / `update` / `destroy` |
| `GET host/hotels*`, `host/room-types/*` | `Api/HostHotelController` |
| `GET insurance/plans` | `Api/InsuranceApiController::plans` |

### Jantung dual-mode

`app/Http/Controllers/Api/PropertyController.php:104-130` — satu grup `where()`
dengan dua cabang:

- cabang pertama: `booking_mode = 'room'` → `whereHas('hotel.roomTypes')` →
  `whereHas('inventories')` dengan `'=', $nightsCount` (wajib ada baris
  inventory untuk **setiap** malam)
- cabang `orWhere()`: `booking_mode = 'unit'` → `whereDoesntHave('bookings')`

Di `BookingController`, pemisahan berlanjut sebagai `storeHotelBooking():410` +
`holdRoomInventory():615` versus `storeUnitBooking():653`.

### Scheduler & Job (`laravel/routes/console.php`)

| Job | Jadwal | Fungsi |
|---|---|---|
| `CancelExpiredBookingsJob` | tiap 5 menit | batalkan booking hotel belum bayar (expiry 30 menit), lepas stok |
| `ExtendHotelInventoriesJob` | harian 00:00 | perpanjang jendela inventory 30 hari berjalan |
| `SyncInsuranceStatusJob` | tiap jam | sinkron status polis dgn provider |
| `payments:cancel-expired` | tiap 10 menit | sapu payment pending > 60 menit |

Helper `generateDateRange()` ada di `laravel/bootstrap/helpers.php:536`.
Observer: `RoomTypeObserver` (jaminan inventory), `BookingObserver`.
Normalizer: `app/Support/HotelNormalizer.php`.

---

## 7. Admin panel — hotel bukan modul mandiri

**Tidak ada** `Admin/HotelController`, **tidak ada** `HotelDataTable`, dan
**tidak ada** route admin untuk hotel. CRUD hotel dicapai dari dalam halaman
properti:

- tombol "Hotel Wizard" — `resources/views/admin/properties/index.blade.php:39`
- komponen — `<livewire:hotels.hotel-wizard-modal>` di file yang sama, `:67`
- tombol per baris — `resources/views/admin/properties/columns/_actions.blade.php:5-11`,
  muncul hanya bila `$property->hotel()->exists()`

Livewire yang ada: `app/Livewire/Hotels/` (`Form`, `WizardForm`, `HotelModal`,
`HotelWizardModal`), `RoomTypes/`, `RoomInventories/`, `BookingRooms/`.

⚠️ **`app/Livewire/Hotels/Form.php:140` adalah baris yang membalik
`properties.booking_mode` menjadi `'room'` saat simpan.** Hotel yang dibuat
tanpa update itu tidak akan pernah muncul di pencarian.

---

## 8. Resource — SEDANG DIREFAKTOR (per 2026-08-20)

`laravel/app/Http/Resources/` saat ini berisi 9 file + `Concerns/`.
Refaktor memecah `PropertyResource` yang monolitik menjadi resource per-endpoint
dengan **key set tetap** (jumlah key konstan, tidak ada key yang hilang saat
relasi kosong). Helper bersama: `Concerns/PresentsProperty.php`.

| Resource | Untuk | Status |
|---|---|---|
| `PropertyListResource` (26 key) | `GET properties` | ✅ **terpasang** — `PropertyController.php:204` |
| `PropertyNHotelResource` | feed home campur unit+hotel | ✅ **terpasang** — `HomeController.php:42-45` |
| `PropertyDetailResource` (60 key) | `GET properties/{property}` | ⚠️ **sudah dibuat, di-`use`, belum dipakai** — `show()` masih `PropertyResource` (`:222`) |
| `PropertyPricingResource` (18 key) | `GET properties/{property}/pricing` | ⚠️ sama — belum dipanggil |
| `PropertyHostResource` (8 key) | `GET properties/{property}/host` | ⚠️ sama — belum dipanggil |
| `PropertyResource` (lama) | masih dipakai `show`, `hostIndex`, `hostShow`, `store`, `update`, `CityController`, `WishlistController`, `Front/FrontController` | 🔻 sedang ditinggalkan |
| `HotelResource` | `GET hotels/{hotel}` — `HotelApiController.php:229` | ✅ terpasang |
| `BannerResource`, `CityResource` | — | ✅ |

**Kalau kamu melanjutkan refaktor ini:** tiga resource di baris ⚠️ hanya perlu
di-*wire* ke method-nya. Jangan hapus `PropertyResource` sebelum 7 pemakai
lainnya pindah.

### Cara `PropertyNHotelResource` menyatukan dua mode

Feed home mencampur listing unit (tarif di `property_prices`) dengan hotel
(tarif di `room_types`). Resource ini mendeteksi mode lalu memetakan keduanya ke
**satu set key datar**, sehingga konsumen tidak perlu bercabang. Ia menerima
root `Property` (hotel datang sebagai Property dengan `hotel` ter-eager-load —
ini yang dihasilkan `RecommendationService`) maupun root `Hotel` telanjang.

Perhatikan pemilihan `id`-nya: baris hotel memakai `hotels.id` (karena dibuka
lewat `GET hotels/{hotel}`), baris unit memakai `properties.id`. Satu tap
handler melayani keduanya.

`PropertyResource` yang lama menangani dua mode lewat guard di `:33`:
`booking_mode === 'room' && relationLoaded('hotel') && hotel->relationLoaded('roomTypes')`.

---

## 9. Invarian — jangan dilanggar

1. **`properties.booking_mode` adalah satu-satunya sumber kebenaran mode.**
   Jangan menyimpulkan dari `property_type`, dan jangan dari sekadar adanya
   baris `hotels`.
2. **Hotel wajib punya Property lebih dulu.** `hotels.property_id` UNIQUE +
   cascade delete. Membuat hotel tanpa membalik `booking_mode` → tidak terlihat
   di pencarian (`Livewire/Hotels/Form.php:140`).
3. **`bookings.booking_type` wajib cocok** dengan `booking_mode` induknya.
   `Booking::scopeHotel()` memfilter tepat `'room'`.
4. **Jangan bypass counter stok dengan raw update.** CHECK constraint
   `booked_count <= allotment` di `room_inventories` adalah pertahanan terakhir
   terhadap overselling. Ambil stok lewat `holdRoomInventory()`.
5. **Tidak ada baris inventory = tidak tersedia, bukan tak terbatas.**
   `scopeAvailableForDates` menuntut satu baris inventory untuk **setiap** malam
   (`'=', $nightsCount`). Jendela 30 hari dijaga `ExtendHotelInventoriesJob` +
   `RoomType::ensureInventory()` + `RoomTypeObserver`.
6. **Ada tiga jalur checkout, bukan dua.** `booking-property`, `booking-hotels`,
   dan `bookings` (legacy, dispatch keduanya). Menambah validasi di satu jalur
   tanpa yang lain menciptakan celah.
7. **Eager load itu wajib, bukan optimasi.** Lupa `->with('hotel.roomTypes')`
   membuat `price_from` diam-diam jadi `0` di `PropertyResource` (`(int) null`).
   Docblock `PropertyNHotelResource` mencantumkan daftar eager load yang benar.
8. **Kolom JSONB di `hotels` masih terpakai.** `HotelResource` membaca tabel
   ternormalisasi lalu fallback ke JSONB via `relationCollectionData()`. Kedua
   jalur hidup — jangan hapus kolomnya.
9. **Amplop API: kunci `status` (bool), bukan `success`** —
   `app/Support/ApiResponse.php:62-69`.

---

## 10. Temuan & drift

| Hal | Realita |
|---|---|
| `App\Models\Room` | **Orphan.** Tabel `rooms` ada, tapi `Room::class` tidak direferensikan di mana pun dalam `laravel/app/`. Stok mode room sepenuhnya counter `room_inventories`; penomoran kamar fisik tidak dipakai. |
| `App\Models\PropertyOther` | **Canonical.** `Property::other()` mengarah ke `PropertyOther` (`properties_other`). Tabel ini menyimpan semua data display properti: gallery, cover, facilities, pricing, dll. |
| Komentar `BookingController.php:764` | **Basi.** Menyebut aturan rumah ada di `properties_other`, padahal baris di bawahnya membaca `$property->other?->check_in_time` → `properties_other`. Kodenya benar, komentarnya salah. |
| Timestamp migration ganda | Dua file memakai `2026_08_16_000001` (`add_children_ages_to_bookings` & `create_properties_other_table`). Urutan jatuh ke alfabet nama file — jalan, tapi rapuh. |
| Admin hotel | Tidak ada controller/DataTable/route mandiri — lihat §7. |
| `laravel/CLAUDE.md` | Menulis "33 model"; aktual 74. |

---

## 11. Template prompt

Pakai ini saat membuka tugas hotel/properti. Ganti bagian dalam `<>`.

```text
Baca docs/domain/hotel-vs-property.md dulu sebagai konteks arsitektur.

Tugas: <apa yang harus dikerjakan>
Mode yang terdampak: <unit | room | keduanya>

Batasan:
- Hanya sentuh laravel/. Jangan jalankan test atau migrate.
- Hormati §9 (Invarian) di dokumen itu — khususnya:
  · booking_mode adalah satu-satunya diskriminator
  · jangan bypass counter room_inventories
  · kalau menyentuh checkout, cek KETIGA jalur (booking-property,
    booking-hotels, bookings legacy)
  · sertakan eager load; price_from jadi 0 tanpa hotel.roomTypes
- Kalau menambah field ke response, ikuti pola key-set tetap di
  Concerns/PresentsProperty (key tidak boleh hilang saat relasi kosong).

Sebelum menulis kode, sebutkan: file apa yang akan diubah dan invarian
mana yang berpotensi tersentuh.
```

---

## 12. Titik masuk kode

Kalau harus buka kode, mulai dari sini — bukan dari pencarian buta:

| Pertanyaan | File |
|---|---|
| Bagaimana pencarian membedakan dua mode? | `app/Http/Controllers/Api/PropertyController.php:104-130` |
| Bagaimana stok kamar diambil? | `app/Http/Controllers/Api/BookingController.php:615` |
| Bagaimana booking unit dibuat? | `app/Http/Controllers/Api/BookingController.php:653` |
| Bagaimana booking hotel dibuat? | `app/Http/Controllers/Api/BookingController.php:410` |
| Bagaimana hotel jadi satu baris feed? | `app/Http/Resources/PropertyNHotelResource.php` |
| Bagaimana detail hotel dirakit? | `app/Http/Resources/HotelResource.php` + `app/Support/HotelNormalizer.php` |
| Bagaimana `booking_mode` di-set? | `app/Livewire/Hotels/Form.php:140` |
| Di mana jadwal job hotel? | `routes/console.php` |
