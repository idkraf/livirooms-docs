# Modul Hotel — Audit Eksekusi (AI-Ready Spec)

> **Status dokumen:** hasil audit ulang 2026-08-18 terhadap kode nyata (bukan asumsi).
> Setiap klaim di dokumen ini sudah diverifikasi dengan membaca file sumbernya, dan
> baris yang dikutip adalah baris sebenarnya pada commit saat audit dijalankan.
>
> **Dokumen ini adalah prompt eksekusi.** Bagian §4 (file yang di-update), §5 (file yang
> dibuat baru), dan §6 (langkah eksekusi) dirancang untuk bisa dijalankan berurutan oleh
> AI/developer tanpa perlu menebak apa pun.

Folder ini menyimpan fixture dummy untuk endpoint detail hotel:

- `GET_hotels_id.json` — detail hotel publik (tamu/konsumen) → dipakai `DummyApiClient` untuk `GET hotels/{id}`
- `GET_host_hotels_id.json` — detail hotel sisi host/mitra → dipakai `DummyApiClient` untuk `GET host/hotels/{id}`

---

## 0. Cara pakai dokumen ini

| Kalau kamu… | Baca bagian |
|---|---|
| Mau tahu apa yang rusak sekarang | §1 Status board |
| Baru baca versi lama readme ini | §2 **Koreksi klaim salah** (wajib — versi lama menyuruh menulis kode yang tidak perlu) |
| Perlu tahu bentuk data sebenarnya | §3 Ground truth (DB ↔ API ↔ fixture ↔ form) |
| Mau langsung mengerjakan | §4 → §5 → §6 → §7 |

Aturan kerja:

1. **Kerjakan urut prioritas** (P0 → P1 → P2). P0 adalah blocker fungsional: fitur mati, bukan kosmetik.
2. **Jangan buat migration untuk kolom yang sudah ada.** §3.1 adalah daftar kolom otoritatif.
3. **Setiap endpoint baru wajib ditambahkan di dua tempat** — `_RealApiClient` (otomatis, lewat path) dan `dummy_api_client.dart` (manual). Kalau lupa, mode `--dart-define=DUMMY_API=true` pecah.
4. Bahasa kode & komentar: **Inggris**. Bahasa dokumen: **Indonesia**.

---

## 1. Status board

Legenda: 🔴 blocker (fitur mati) · 🟠 data salah/hilang diam-diam · 🟡 tidak lengkap · ✅ sudah benar

| # | Temuan | Sev | Bukti |
|---|--------|-----|-------|
| B-1 | **Form host Flutter tidak punya jalur update.** `hotel_service.dart` hanya punya `createHotelForProperty()` → selalu `POST host/hotels`. Mode edit ikut POST, lalu ditolak `abort_if($property->hotel()->exists(), 422)`. | 🔴 | [hotel_service.dart:114-126](../../lib/services/hotel_service.dart#L114-L126), [HostHotelController.php:78](../../../laravel/app/Http/Controllers/Api/HostHotelController.php#L78) |
| B-2 | **`_loadHotelData()` selalu gagal** — `_policyToJson` memanggil `p.smokingPolicy` dan `_roomTypeToJson` memanggil `rt.totalInventory`; kedua getter tidak ada di model. Karena param bertipe `dynamic`, error baru muncul saat runtime (`NoSuchMethodError`) dan **ditelan `catch (_)`**. Efek: mode edit tampil kosong tanpa pesan error. | 🔴 | [hotel_form_screen.dart:186](../../lib/screens/mitra/hotel_form_screen.dart#L186), [:206](../../lib/screens/mitra/hotel_form_screen.dart#L206), [:228](../../lib/screens/mitra/hotel_form_screen.dart#L228) vs [hotel.dart:302-349](../../lib/models/hotel.dart#L302-L349), [hotel.dart:351-401](../../lib/models/hotel.dart#L351-L401) |
| B-3 | **Form host membaca endpoint publik.** `getHotelDetail()` memanggil `GET hotels/{id}` dengan `auth: false`, padahal ini form host. Konsekuensi: `status` dan `cover` tidak pernah tersedia, dan hotel non-publik tidak bisa dibuka. Endpoint `GET host/hotels/{hotel}` ada tapi tidak dipakai. | 🔴 | [hotel_service.dart:25-28](../../lib/services/hotel_service.dart#L25-L28), [api_mobile.php](../../../laravel/routes/api_mobile.php) |
| B-4 | **`HotelSeeder` tidak pernah membuat `room_inventories`.** Grep `RoomInventory\|room_inventories` di seluruh `database/seeders/` → 0 hasil. Akibatnya `GET hotels?check_in=…&check_out=…` (via `scopeAvailableForDates`) dan `GET hotels/{id}/room-types` bertanggal **selalu kosong** di database hasil seed. | 🔴 | [RoomType.php](../../../laravel/app/Models/RoomType.php), [HotelSeeder.php](../../../laravel/database/seeders/HotelSeeder.php) |
| B-5 | **`WizardForm::edit()` tidak memulihkan `selected_facilities`.** Nilainya tetap default hardcoded 5 item. Saat `save()`, `hotels.facility_groups` **dan** `properties.facilities` ditimpa daftar default itu → data fasilitas hilang setiap kali admin mengedit hotel. | 🟠 | [WizardForm.php:53](../../../laravel/app/Livewire/Hotels/WizardForm.php#L53), [:261-315](../../../laravel/app/Livewire/Hotels/WizardForm.php#L261-L315), [:346](../../../laravel/app/Livewire/Hotels/WizardForm.php#L346), [:385-391](../../../laravel/app/Livewire/Hotels/WizardForm.php#L385-L391) |
| B-6 | **`score_label` dan `review_count` tidak punya kolom di mana pun.** Tidak ada di `create_hotels_table` maupun `add_hotel_ota_columns`. Flutter membacanya dan selalu jatuh ke default `'Luar Biasa'` / `0`. | 🟠 | [create_hotels_table.php](../../../laravel/database/migrations/2026_08_13_000002_create_hotels_table.php), [add_hotel_ota_columns.php](../../../laravel/database/migrations/2026_08_15_000001_add_hotel_ota_columns.php), [hotel.dart:171-172](../../lib/models/hotel.dart#L171-L172) |
| B-7 | **Skala `score` tidak konsisten.** DB: JSONB 6 komponen PSI skala 0–5 (`basic: 4.8`). Fixture: angka tunggal skala 0–10 (`9.4`). Flutter mengambil `score['basic']` → UI menampilkan **4.8** padahal desain mengharapkan **9.4**. | 🟠 | [HotelSeeder.php](../../../laravel/database/seeders/HotelSeeder.php), `GET_hotels_id.json`, [hotel.dart:144-150](../../lib/models/hotel.dart#L144-L150) |
| B-8 | **`WizardForm::save()` membuat room type tanpa inventory** dan tanpa `description` / `facilities` / `images`; room type yang dihapus dari wizard **tidak pernah dihapus** dari DB. | 🟠 | [WizardForm.php:406-432](../../../laravel/app/Livewire/Hotels/WizardForm.php#L406-L432) |
| B-9 | **Gallery Flutter mengirim path lokal device sebagai URL.** `_gallery.add(picked.path)` lalu dikirim apa adanya ke `properties.gallery`. Tidak ada endpoint upload multipart. | 🟠 | [hotel_form_screen.dart](../../lib/screens/mitra/hotel_form_screen.dart) |
| B-10 | `HostHotelController@store`/`@update` **tidak menerima `name`** → host tidak bisa mengubah nama properti. Form Flutter juga tidak mengirimnya. | 🟡 | [HostHotelController.php:95-101](../../../laravel/app/Http/Controllers/Api/HostHotelController.php#L95-L101), [:191-197](../../../laravel/app/Http/Controllers/Api/HostHotelController.php#L191-L197) |
| B-11 | `transport_points` **tidak punya UI sama sekali** di form Flutter, walau controller sudah menerimanya. | 🟡 | [HostHotelController.php:64](../../../laravel/app/Http/Controllers/Api/HostHotelController.php#L64) |
| B-12 | Fixture `GET_host_hotels_id.json` memakai key room type yang **tidak pernah dikeluarkan controller mana pun**: `original_price`, `max_adults`, `max_children`, `photos`. Key sebenarnya: `price_original`, `capacity_adults`, `capacity_children`, `images`. | 🟡 | `GET_host_hotels_id.json` vs [RoomType.php](../../../laravel/app/Models/RoomType.php) |
| B-13 | `HostHotelController@show` tidak mengeluarkan `price_from`, `price_original`, `cover`, dan `status` top-level — padahal fixture host punya semuanya. | 🟡 | [HostHotelController.php:118-147](../../../laravel/app/Http/Controllers/Api/HostHotelController.php#L118-L147) |
| B-14 | Seeder: `facility_groups[].items` berupa **string biasa**, sedangkan `WizardForm` dan fixture menulis **objek** `{name, is_available, badge}`. (Model Flutter sudah menormalisasi keduanya, jadi ini konsistensi data, bukan crash.) | 🟡 | [HotelSeeder.php](../../../laravel/database/seeders/HotelSeeder.php), [hotel.dart:261-277](../../lib/models/hotel.dart#L261-L277) |
| B-15 | Seeder & kedua form: `faqs` tanpa `author_name` / `author_role`. Flutter menambal dengan default `'Manager akomodasi'` / `'Staff Hotel'`. | 🟡 | [hotel.dart:488-493](../../lib/models/hotel.dart#L488-L493) |
| B-16 | Seeder: `transport_points[].icon` tidak ada (**`duration` justru sudah ada** — lihat §2 K-4). | 🟡 | [HotelSeeder.php](../../../laravel/database/seeders/HotelSeeder.php) |
| B-17 | Seeder: `room_types.images` = array of string; fixture = array of `{url, caption}`. Model Flutter sudah menormalisasi (`_flattenStringList`), tapi `caption` hilang. | 🟡 | [hotel.dart:21-38](../../lib/models/hotel.dart#L21-L38), [:463](../../lib/models/hotel.dart#L463) |
| B-18 | Tidak ada route `DELETE` untuk hotel maupun room type. Wizard admin & form Flutter hanya bisa menambah/mengubah. | 🟡 | [api_mobile.php](../../../laravel/routes/api_mobile.php) |
| B-19 | `WizardForm::save()` hardcode `property_type = 'hotel_residence'` padahal repo mendukung 6 tipe properti. | 🟡 | [WizardForm.php:335](../../../laravel/app/Livewire/Hotels/WizardForm.php#L335) |
| B-20 | Tabel `properties_other` menduplikasi field Hotel (`cover`, `price_from`, `rating`, `review_count`, `star_rating`, `check_in_time`, `check_out_time`) → sumber kebenaran ambigu. | 🟡 | [create_properties_other_table.php](../../../laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php) |
| B-21 | `WizardForm::rules()` memvalidasi key `facility_groups`, tapi komponen tidak punya property publik bernama itu → rule mati (no-op). | 🟡 | [WizardForm.php:92](../../../laravel/app/Livewire/Hotels/WizardForm.php#L92) |

---

## 2. Koreksi terhadap versi lama readme ini ⚠️

Versi sebelumnya menempatkan beberapa klaim sebagai **P0**. Klaim-klaim berikut **SALAH** dan
sudah dihapus. Jangan kerjakan.

| # | Klaim lama | Kenyataan terverifikasi |
|---|-----------|-------------------------|
| **K-1** | “`HotelApiController@show` belum mengembalikan `review_quotes`, `facility_groups`, `transport_points`, `policies`, `faqs`” — disertai snippet 5 baris `$data[…] = $hotel->…` sebagai **P0 #1**. | **SALAH.** [HotelApiController.php:208](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L208) memanggil `$hotel->toArray()`, dan `Hotel` **tidak punya `$hidden`** — jadi kelima kolom JSONB itu (plus `score` dan `deposit_amount`) **sudah ikut terserialisasi**. Snippet lama hanya menulis ulang nilai yang sama. **Tidak ada pekerjaan di sini.** |
| **K-2** | `score`, `score_label`, `review_count` didaftarkan sebagai “Kolom hotels”. | **SALAH sebagian.** Hanya `score` yang punya kolom (JSONB, [add_hotel_ota_columns.php](../../../laravel/database/migrations/2026_08_15_000001_add_hotel_ota_columns.php)). `score_label` dan `review_count` **tidak ada kolomnya di tabel mana pun** → lihat B-6. |
| **K-3** | “`active_room_types.images` adalah relasi yang tidak di-eager-load.” | **SALAH.** `images` adalah **kolom JSONB** di `room_types` dengan cast `array` ([RoomType.php](../../../laravel/app/Models/RoomType.php)). Tidak ada relasi `images`. Nilainya selalu muncul di response. |
| **K-4** | “Seeder tidak menyimpan `transport_points[].duration`.” | **SALAH.** `duration` sudah ada di seeder (mis. `'8 mnt berkendara'`). Yang benar-benar hilang hanya **`icon`** → B-16. |
| **K-5** | “`HotelSeeder` membuat 4 hotel contoh.” | **SALAH.** Ada **5**: Merlynn, Grand Cemara, YELLO, Artotel, MaxOne. |
| **K-6** | “`status` di-hardcode `active` saat submit Flutter.” | **SALAH.** `status` **tidak pernah dikirim sama sekali** di payload. `_submit({String status = 'active'})` hanya memakai nilainya untuk teks snackbar. |
| **K-7** | “Semua field WizardForm sudah tertangkap ✅ — tidak ada gap.” | **SALAH.** Lihat B-5 (fasilitas hilang saat edit) dan B-8 (room type tanpa inventory/description/facilities/images, tanpa delete). |
| **K-8** | Kontingensi “kalau kolom `facility_groups`/`transport_points`/`faqs`/`review_quotes` belum ada, jalankan migration ini”. | **Tidak relevan.** Keempat kolom pasti ada di `2026_08_15_000001_add_hotel_ota_columns.php`. Menjalankan migration itu akan gagal (duplicate column). Blok tersebut sudah dihapus. |

**Yang tetap valid dari versi lama:** B-10 (`name` tidak diterima controller), B-11
(`transport_points` tanpa UI Flutter), B-14, B-15, B-17, B-20, dan rekomendasi arsitektur
“pertahankan JSONB” (§3.5 / D-4).

---

## 3. Ground truth

### 3.1 Kolom yang benar-benar ada (otoritatif — jangan bikin migration untuk ini)

**`hotels`** — sumber: `2026_08_13_000002_create_hotels_table.php` + `2026_08_15_000001_add_hotel_ota_columns.php`

| Kolom | Tipe | Migration | Cast di `Hotel.php` |
|---|---|---|---|
| `id` | bigint | 000002 | — |
| `property_id` | FK unique → properties | 000002 | — |
| `star_rating` | integer | 000002 | `integer` |
| `check_in_time` | time | 000002 | — |
| `check_out_time` | time | 000002 | — |
| `policies` | **jsonb** | 000002 | `array` |
| `open_year` | integer | 000001 (0815) | `integer` |
| `score` | **jsonb** | 000001 (0815) | `array` |
| `facility_groups` | **jsonb** | 000001 (0815) | `array` |
| `transport_points` | **jsonb** | 000001 (0815) | `array` |
| `faqs` | **jsonb** | 000001 (0815) | `array` |
| `review_quotes` | **jsonb** | 000001 (0815) | `array` |
| `deposit_amount` | decimal(12,2) default 0 | 000001 (0815) | `decimal:2` |
| `created_at` / `updated_at` | timestamps | 000002 | — |

❌ **TIDAK ADA:** `score_label`, `review_count`, `cover`, `status` (status ada di `properties`, bukan `hotels`).

**`room_types`** — `facilities` dan `images` adalah **kolom jsonb** (cast `array`), **bukan relasi**.
Kolom lain: `hotel_id`, `name`, `slug`, `description`, `bed_configuration`, `base_price`,
`price_original`, `total_inventory`, `capacity_adults`, `capacity_children`, `max_guests`,
`room_size_sqm`, `breakfast_included`, `has_window`, `no_smoking`, `free_wifi`, `is_active`.

**`room_inventories`** — `room_type_id`, `date`, `allotment`, `booked_count`, `price`, `is_closed`.
Unique `(room_type_id, date)`. **Satu baris per malam wajib ada** agar `scopeAvailableForDates` lolos.

**`properties`** (yang dipakai modul hotel) — `host_id`, `city_id`, `property_type`, `booking_mode`,
`name`, `building_name`, `description`, `address`, `latitude`, `longitude`, `gallery` (jsonb),
`facilities` (jsonb), `cancellation_policy`, `status`.
`latitude`/`longitude` **tidak di-cast** → PostgreSQL mengirim string `"-6.1944400"`.

### 3.2 Atribut turunan (accessor) yang sudah ada di `Hotel.php`

| Atribut | Method | Catatan |
|---|---|---|
| `price_from` | `getPriceFromAttribute()` | harga terendah room type aktif; **tidak** di `$appends` — harus di-set manual oleh controller |
| `price_original` | `getPriceOriginalAttribute()` | idem |
| `overall_score` | `getOverallScoreAttribute()` | mengembalikan `$this->score['basic']` (skala 0–5) |

### 3.3 Matriks field: DB → API publik → fixture → Flutter model

| Field | Kolom DB | `HotelApiController@show` | `GET_hotels_id.json` | `hotel.dart` | Verdict |
|---|---|---|---|---|---|
| `id`, `property_id`, `star_rating`, `open_year`, `check_in_time`, `check_out_time` | ✅ | ✅ `toArray()` :208 | ✅ | ✅ | ✅ |
| `policies` | ✅ jsonb | ✅ `toArray()` :208 | ✅ 12 key | ✅ `HotelPolicy` | ✅ (K-1) |
| `facility_groups` | ✅ jsonb | ✅ `toArray()` :208 | ✅ objek | ✅ normalisasi string/objek | ✅ (K-1) |
| `transport_points` | ✅ jsonb | ✅ `toArray()` :208 | ✅ + `duration` + `icon` | ⚠️ **tanpa `duration`** | 🟡 model perlu `duration` |
| `faqs` | ✅ jsonb | ✅ `toArray()` :208 | ✅ + author | ✅ default author | 🟡 seeder/form tanpa author |
| `review_quotes` | ✅ jsonb | ✅ `toArray()` :208 | ✅ | ✅ | ✅ (K-1) |
| `deposit_amount` | ✅ decimal | ✅ `toArray()` :208 | ✅ | ✅ `_toDouble` | ✅ |
| `score` | ✅ jsonb (map 0–5) | ✅ `toArray()` :208 | ⚠️ angka 0–10 | ⚠️ ambil `['basic']` | 🟠 B-7 |
| `score_label` | ❌ **tidak ada** | ❌ | ✅ `"Luar Biasa"` | dibaca, selalu default | 🟠 B-6 |
| `review_count` | ❌ **tidak ada** | ❌ | ✅ `428` | dibaca, selalu `0` | 🟠 B-6 |
| `name`, `description`, `address`, `gallery`, `latitude`, `longitude`, `city_name` | di `properties` | ✅ diflatten :209-215 | ✅ | ✅ | ✅ |
| `cancellation_policy` | `properties` | ✅ :221 | ✅ | ✅ | ✅ |
| `price_from` / `price_original` | accessor | ✅ :227-228 | ✅ | ✅ | ✅ |
| `active_room_types` | relasi + `remaining` | ✅ :232-237 | ✅ | ✅ | ✅ |
| `active_room_types[].images` | ✅ jsonb | ✅ | `[{url, caption}]` | flatten → string | 🟡 `caption` hilang (B-17) |
| `active_room_types[].facilities` | ✅ jsonb | ✅ | campur string & objek | flatten → string | 🟡 seeder kosong (B-14) |
| `property` (nested) | relasi | ✅ :199-202 | ✅ | ✅ | ✅ |

### 3.4 Matriks field: form host Flutter → API host → DB

| Field form | Dikirim `_submit()`? | Diterima `HostHotelController`? | Tersimpan ke | Verdict |
|---|---|---|---|---|
| `property_id` | ✅ | ✅ `store` only | — | ✅ |
| `star_rating`, `open_year`, `check_in_time`, `check_out_time` | ✅ | ✅ | `hotels` | ✅ |
| `description`, `address`, `latitude`, `longitude`, `cancellation_policy` | ✅ | ✅ | `properties` | ✅ |
| `gallery` | ✅ | ✅ | `properties.gallery` | 🟠 isinya path lokal (B-9) |
| `facility_groups`, `policies`, `deposit_amount`, `review_quotes`, `faqs` | ✅ | ✅ | `hotels` | ✅ |
| **`name`** | ❌ | ❌ | — | 🟡 B-10 |
| **`transport_points`** | ❌ (tidak ada UI) | ✅ | `hotels` | 🟡 B-11 |
| **`status`** | ❌ | ❌ | — | 🟡 K-6 |
| `room_types[]` | ✅ (POST terpisah per item) | ✅ `storeRoomType` | `room_types` + inventory 30 hari | ✅ create · ❌ tidak ada jalur update/delete |

Payload room type Flutter **sudah lengkap** dan cocok dengan validasi `storeRoomType`
(`name`, `description`, `capacity_adults`, `capacity_children`, `max_guests`, `room_size_sqm`,
`bed_configuration`, `base_price`, `price_original`, `breakfast_included`, `has_window`,
`no_smoking`, `free_wifi`, `total_inventory`, `is_active`, `facilities`, `images`).
Yang rusak bukan payload-nya, tapi **tidak ada jalur edit** (B-1) dan **loader edit crash** (B-2).

### 3.5 Keputusan arsitektur yang harus diambil sebelum eksekusi

#### D-1 — `score_label` & `review_count`: kolom baru atau accessor? **→ Pilih accessor (rekomendasi)**

Keduanya adalah data **turunan**, bukan input host:

- `review_count` = `Property::reviews()` sudah ada (`HasMany`), `Review` punya kolom `rating`.
- `score_label` = fungsi dari nilai skor.

Maka: **tidak perlu migration**. Tambahkan accessor di `Hotel.php` + `$appends`. Ini juga
otomatis memperbaiki B-6 untuk endpoint host maupun publik sekaligus.

> Alternatif (tidak direkomendasikan): buat kolom `score_label` + `review_count` di `hotels`,
> lalu isi lewat job/observer. Menambah state yang bisa basi tanpa manfaat query.

#### D-2 — Skala `score`: 0–5 atau 0–10? **→ Tambah `score_overall` skala 0–10, `score` tetap apa adanya**

`hotels.score` adalah JSONB PSI 6 komponen skala 0–5 dan sudah dipakai admin panel + `dashboard()`.
Mengubah maknanya berisiko. Solusi non-breaking: API mengeluarkan **field baru** `score_overall`
(0–10, hasil `basic * 2`) di samping `score` yang tidak diubah, lalu `hotel.dart` memprioritaskan
`score_overall`.

#### D-3 — `properties_other` vs `hotels` (B-20) → **Dokumentasikan, jangan konsolidasi sekarang**

Konsolidasi menyentuh 20+ kolom dan modul non-hotel. Untuk sekarang: **`hotels` adalah sumber
kebenaran untuk properti bertipe hotel**; `properties_other` hanya untuk tipe non-hotel.
Catat aturan ini di `docs/hotel/02-models-relationships.md` dan jangan tulis field hotel ke
`properties_other`. Konsolidasi dijadikan backlog terpisah (P3).

#### D-4 — JSONB vs tabel relasional → **Pertahankan JSONB** (tetap seperti versi lama)

`facility_groups`, `transport_points`, `faqs`, `review_quotes`, `policies` selalu dibaca
bersamaan dengan detail hotel dan tidak pernah difilter di SQL. Pecah ke tabel relasional
menambah kompleksitas tanpa manfaat. Yang dibutuhkan hanya **standardisasi bentuk**.
Tinjau ulang hanya jika muncul fitur: filter by transit type, manajemen FAQ terpaginasi, atau
kategori fasilitas dinamis.

---

## 4. FILE YANG PERLU DI-UPDATE

Path relatif dari root repo `rental.apartemen/`. Kolom **Task** merujuk ke §6.

### 4.1 Laravel — Backend

| # | File | Yang diubah | Untuk | Prio | Task |
|---|------|-------------|-------|------|------|
| U-1 | `laravel/app/Models/Hotel.php` | Tambah accessor `getScoreLabelAttribute()`, `getReviewCountAttribute()`, `getScoreOverallAttribute()`. **Jangan** tambah ke `$appends` global (hindari N+1 di listing) — biarkan controller yang `->append()`. | B-6, B-7 / D-1, D-2 | **P0** | T-01 |
| U-2 | `laravel/app/Http/Controllers/Api/HotelApiController.php` | Di `show()`: eager-load `property.reviews` (atau `withCount`), lalu `$hotel->append([...])` sebelum `toArray()`. Tambah normalisasi `transport_points` (isi `icon` default), `facility_groups.items` (string → objek), `faqs` (isi author default), dan `room_types.images` (string → `{url, caption}`). Di `index()`: `withCount` reviews + append `score_label`/`score_overall` untuk kartu hasil pencarian. **JANGAN tambahkan 5 baris `$data['policies'] = …` dsb — itu klaim K-1 yang salah.** | B-6, B-7, B-14, B-15, B-16, B-17 | **P0** | T-02, T-09 |
| U-3 | `laravel/app/Http/Controllers/Api/HostHotelController.php` | (a) `store()` + `update()`: tambah `'name' => ['nullable','string','max:255']` ke validasi dan `'name'` ke `$propertyData`. (b) `update()`: terima `status`. (c) `show()`: tambah `price_from`, `price_original`, `status` top-level, `cover` (gallery[0]), dan append atribut turunan agar bentuknya sama dengan `GET_host_hotels_id.json`. (d) Tambah method `destroy()` dan `destroyRoomType()`. (e) Normalisasi key room type agar konsisten (`price_original`, `capacity_adults`, `capacity_children`, `images`). | B-10, B-12, B-13, B-18, K-6 | **P0** / P1 | T-03, T-10 |
| U-4 | `laravel/routes/api_mobile.php` | Tambah 2 route: `DELETE host/hotels/{hotel}` → `destroy`, `DELETE host/room-types/{roomType}` → `destroyRoomType`. Tambah `POST host/hotels/{hotel}/gallery` (upload multipart) bila T-12 dikerjakan. | B-18, B-9 | P1 | T-10, T-12 |
| U-5 | `laravel/database/seeders/HotelSeeder.php` | (a) Ubah `facility_groups[].items` dari string → objek `{name, is_available, badge}`. (b) Tambah `icon` di setiap `transport_points` (**`duration` sudah ada — jangan disentuh**). (c) Tambah `author_name`/`author_role` di setiap `faqs`. (d) Standardisasi `policies` ke 12 key untuk kelima hotel. (e) Ubah `room_types.images` → `[{url, caption}]`. (f) Isi `room_types.facilities` (saat ini tidak pernah di-set). (g) Panggil generator inventory setelah room type dibuat. | B-4, B-14, B-15, B-16, B-17 | **P0** (khusus g) / P1 | T-04, T-05 |
| U-6 | `laravel/app/Livewire/Hotels/WizardForm.php` | (a) `edit()`: pulihkan `selected_facilities` dari `facility_groups` (atau `property->facilities`) — **blocker data loss**. (b) `edit()`: petakan juga `description`, `facilities`, `images`, `is_active` per room type. (c) `save()`: sertakan 4 field itu di `$roomPayload`. (d) `save()`: hapus room type yang dibuang dari wizard. (e) `save()`: generate `room_inventories` 30 hari untuk room type baru. (f) `save()`: ganti hardcode `property_type` jadi property `$property_type` dengan default `'hotel_residence'`. (g) Tambah input `duration` + `icon` di `addTransitPoint()` dan `author_name`/`author_role` di `addFaq()`. (h) Hapus rule mati `facility_groups` di `rules()`. | B-5, B-8, B-15, B-16, B-19, B-21 | **P0** (a) / P1 | T-06, T-07 |
| U-7 | `laravel/resources/views/livewire/hotels/wizard_form.blade.php` | Tab 4: tambah input `duration` (text) + `icon` (select) untuk transit, dan `author_name`/`author_role` untuk FAQ. Tab 2: tambah input `description` + `facilities` per room type. | B-8, B-15, B-16 | P1 | T-07 |
| U-8 | `laravel/app/Models/RoomType.php` | Tambah helper `ensureInventory(int $days)` supaya generator inventory tidak diduplikasi di 3 tempat (controller, wizard, seeder). | B-4, B-8 | P1 | T-05 |

### 4.2 Flutter — Mobile

| # | File | Yang diubah | Untuk | Prio | Task |
|---|------|-------------|-------|------|------|
| U-9 | `flutter/lib/services/hotel_service.dart` | (a) Tambah `getHostHotelDetail(int hotelId)` → `GET host/hotels/{id}` dengan `auth: true`. (b) Tambah `updateHotelForProperty(int hotelId, Map payload, List roomTypes)` → `PUT host/hotels/{id}` + `PUT host/room-types/{id}` untuk room type yang punya `id`, `POST host/hotels/{id}/room-types` untuk yang baru. (c) Tambah `deleteRoomType(int id)` dan `deleteHotel(int id)`. | B-1, B-3, B-18 | **P0** | T-08, T-10 |
| U-10 | `flutter/lib/screens/mitra/hotel_form_screen.dart` | (a) `_loadHotelData()`: pakai `getHostHotelDetail`, dan **hapus `catch (_)` bisu** → tampilkan pesan error. (b) Perbaiki `_policyToJson` (buang `p.smokingPolicy`) dan `_roomTypeToJson` (buang `rt.totalInventory`, jangan kirim `sizeSqm` bertipe String ke field numerik). (c) Beri **tipe konkret** pada param `_policyToJson`/`_roomTypeToJson`/`_facilityGroupToJson`/`_faqToJson` (`HotelPolicy`, `HotelRoomItem`, …) supaya error seperti ini ketangkap saat compile, bukan runtime. (d) `_submit()`: percabangan create vs update; kirim `name`, `transport_points`, `status`. (e) Tab baru/section untuk `transport_points` (name, type, distance, duration, icon). (f) Simpan `id` room type saat load agar bisa di-`PUT`. | B-1, B-2, B-3, B-10, B-11, K-6 | **P0** | T-08, T-11 |
| U-11 | `flutter/lib/models/hotel.dart` | (a) `HotelPolicy`: tambah `smokingPolicy`, `depositAmount`, `depositCurrency`, dan 3 boolean (`receptionist24h`, `allowChildren`, `extraBedAvailable`) agar round-trip form tidak kehilangan data. (b) `HotelTransportPoint`: tambah `duration`. (c) `HotelRoomItem`: tambah `totalInventory` dan simpan `caption` gambar (mis. `List<HotelRoomImage>`). (d) `Hotel.fromJson`: prioritaskan `score_overall` sebelum `score`. | B-2, B-7, B-17, dan 🟡 `duration` | **P0** (a,b,c) | T-11 |
| U-12 | `flutter/lib/services/dummy_api_client.dart` | Daftarkan mapping untuk endpoint baru: `DELETE host/hotels/{id}`, `DELETE host/room-types/{id}`, `POST host/hotels/{id}/gallery`. Tanpa ini mode `DUMMY_API=true` pecah. | B-18, B-9 | P1 | T-10, T-12 |
| U-13 | `flutter/assets/json/GET_host_hotels_id.json` | Selaraskan dengan output nyata `HostHotelController@show`: `original_price` → `price_original`, `max_adults` → `capacity_adults`, `max_children` → `capacity_children`, `photos` → `images`. Tambah `price_from`, `price_original`, `score_label`, `review_count`, `score_overall`, `transport_points`, `faqs`. | B-12, B-13 | P1 | T-10 |
| U-14 | `flutter/assets/json/GET_hotels_id.json` | Tambah `score_overall` (0–10) di samping `score`. Samakan bentuk `active_room_types[].facilities` (pilih **satu**: array objek `{name}`) — sekarang Executive Room pakai string dan Prada Suite pakai objek. | B-7, B-14 | P1 | T-09 |
| U-15 | `flutter/assets/json/PUT_host_hotels_id.json` | Pastikan fixture response `PUT` ada dan bentuknya sama dengan `GET_host_hotels_id.json` (mapping-nya sudah terdaftar di `dummy_api_client.dart`, jadi file-nya wajib ada dan konsisten). | B-1 | P1 | T-08 |

### 4.3 Dokumentasi

| # | File | Yang diubah | Prio | Task |
|---|------|-------------|------|------|
| U-16 | `docs/hotel/02-models-relationships.md` | Catat keputusan D-3 (`hotels` = sumber kebenaran untuk tipe hotel, `properties_other` untuk non-hotel) dan atribut turunan baru dari D-1/D-2. | P1 | T-14 |
| U-17 | `docs/hotel/06-hotel-management-flow.md` | Perbarui alur host: create vs update, endpoint DELETE baru, alur upload gallery. | P1 | T-14 |
| U-18 | `docs/INDEX.md` | Tambahkan pointer ke dokumen ini bila belum terdaftar. | P2 | T-14 |

---

## 5. FILE YANG PERLU DIBUAT BARU

| # | File baru | Jenis | Isi / tujuan | Prio | Task |
|---|-----------|-------|--------------|------|------|
| N-1 | `laravel/database/seeders/RoomInventorySeeder.php` | **Seeder** | Generate `room_inventories` 90 hari ke depan untuk **semua** `room_types` aktif (allotment = `total_inventory`, price = `base_price`, `booked_count` = 0, `is_closed` = false). Pakai `upsert` agar idempoten. Daftarkan di `DatabaseSeeder` **setelah** `HotelSeeder`. **Ini memperbaiki B-4** — tanpa ini pencarian hotel bertanggal selalu kosong. | **P0** | T-05 |
| N-2 | `laravel/app/Http/Resources/HotelResource.php` | **API Resource** | Satu tempat normalisasi bentuk response publik: `score_overall`, `score_label`, `review_count`, `transport_points[].icon` default, `facility_groups[].items` → objek, `faqs[]` author default, `active_room_types[].images` → `{url, caption}`. Dipakai `HotelApiController@show`. Menghilangkan duplikasi normalisasi antara controller publik & host. Folder `app/Http/Resources/` **belum ada** — buat sekalian. | **P0** | T-02 |
| N-3 | `laravel/app/Http/Resources/HostHotelResource.php` | **API Resource** | Bentuk response host: semua field `HotelResource` + `status`, `cover`, `price_from`, `price_original`, `room_types` (bukan `active_room_types`), `property` nested. Menjadi kontrak untuk `GET_host_hotels_id.json`. | P1 | T-10 |
| N-4 | `laravel/app/Support/HotelNormalizer.php` | **Support class** | Fungsi statis murni yang dipakai bersama oleh kedua Resource **dan** oleh `HotelSeeder`/`WizardForm` saat menulis: `facilityGroups(array): array`, `transportPoints(array): array`, `faqs(array): array`, `roomImages(array): array`, `policies(array): array` (isi 12 key), `scoreLabel(float): string`. Satu definisi bentuk data untuk baca **dan** tulis. | **P0** | T-02 |
| N-5 | `laravel/app/Http/Controllers/Api/HostGalleryController.php` | **Controller** | Endpoint `POST host/hotels/{hotel}/gallery` — terima multipart `images[]`, validasi `image|max:2048`, simpan ke disk `public` di `hotels/gallery`, kembalikan array path relatif. **Memperbaiki B-9**: sekarang Flutter mengirim path lokal device sebagai URL. (Boleh juga ditaruh sebagai method di `HostHotelController`; file terpisah lebih rapi.) | P1 | T-12 |
| N-6 | `laravel/tests/Feature/Api/HotelDetailTest.php` | **Test** | Assert `GET /api/v1/hotels/{id}` mengembalikan `score_overall`, `score_label`, `review_count`, `policies` 12 key, `facility_groups[].items[].name`, `transport_points[].icon`, `transport_points[].duration`, `faqs[].author_name`, `active_room_types[].images[].url`. Ini yang mengunci K-1..K-4 agar tidak regresi. | **P0** | T-13 |
| N-7 | `laravel/tests/Feature/Api/HostHotelCrudTest.php` | **Test** | Assert alur host lengkap: `POST host/hotels` → `PUT host/hotels/{id}` (**harus 200, bukan 422** — ini regression test untuk B-1), `PUT host/room-types/{id}`, `DELETE`, dan `name` benar-benar tersimpan ke `properties`. | **P0** | T-13 |
| N-8 | `laravel/tests/Feature/Api/HotelAvailabilityTest.php` | **Test** | Seed hotel + room type + inventory, lalu assert `GET hotels?check_in=…&check_out=…` **mengembalikan hotel** (bukan array kosong). Regression test untuk B-4. | **P0** | T-13 |
| N-9 | `flutter/test/models/hotel_test.dart` | **Test** | Parse `assets/json/GET_hotels_id.json` dan `GET_host_hotels_id.json` lewat `Hotel.fromJson`, assert tidak ada field yang jatuh ke default secara diam-diam (`reviewCount != 0`, `score` sesuai, `transportPoints.first.duration` terisi, `policy.smokingPolicy` terisi). Ini yang akan menangkap kelas bug B-2. | **P0** | T-13 |
| N-10 | `flutter/lib/models/hotel_transport_type.dart` *(opsional)* | **Enum/mapper** | Peta `type` mesin (`train`, `bus`, `airport`, `mall`, `attraction`) ↔ label Indonesia (`Stasiun Kereta`, `Bandara`, …) ↔ nama ikon. Saat ini seeder menulis nilai mesin, fixture menulis label Indonesia, dan UI menerima apa saja → inkonsistensi tampilan. | P2 | T-11 |
| N-11 | `laravel/database/migrations/*_add_score_label_and_review_count_to_hotels_table.php` | **Migration** | ⛔ **JANGAN DIBUAT** kecuali D-1 ditolak. Keputusan default: `score_label` & `review_count` adalah **accessor**, bukan kolom. Dicatat di sini supaya tidak ada yang “berinisiatif” membuatnya. | — | — |

> **Ringkasan jawaban atas pertanyaan “apa yang perlu dibuat baru?”**
> **Tidak ada migration baru.** Semua kolom yang dibutuhkan sudah ada (§3.1). Yang baru adalah:
> **1 seeder** (N-1), **2 API Resource + 1 Support class** (N-2, N-3, N-4), **1 controller upload**
> (N-5), **4 file test** (N-6..N-9), dan **1 mapper opsional Flutter** (N-10).

---

## 6. Langkah eksekusi

Urutan ini disusun agar setiap task bisa diverifikasi sendiri sebelum lanjut. Jangan lompat:
T-02 bergantung pada T-01, T-08 bergantung pada T-03.

### Gelombang P0 — blocker fungsional (T-01 … T-08)

#### T-01 · Accessor turunan di `Hotel.php`  → U-1

File: `laravel/app/Models/Hotel.php`

```php
/**
 * Guest review count, taken from the property's reviews.
 *
 * `hotels` has no `review_count` column and never had one; the fixture that
 * documents this endpoint shows the number, so it is computed here instead of
 * stored. Prefers the `reviews_count` from `withCount()` when the caller loaded
 * it, so a paginated listing does not fire one query per row.
 */
public function getReviewCountAttribute(): int
{
    $prop = $this->property;
    if (!$prop) {
        return 0;
    }

    return (int) ($prop->reviews_count ?? $prop->reviews()->count());
}

/** Overall score on the 0-10 scale the OTA screens use (`score.basic` is 0-5). */
public function getScoreOverallAttribute(): ?float
{
    $basic = $this->score['basic'] ?? null;

    return $basic === null ? null : round((float) $basic * 2, 1);
}

/** Human label for `score_overall` — matches the wording in GET_hotels_id.json. */
public function getScoreLabelAttribute(): string
{
    return \App\Support\HotelNormalizer::scoreLabel($this->score_overall ?? 0.0);
}
```

**Jangan** menambahkan ketiganya ke `$appends` — `getReviewCountAttribute` menyentuh relasi,
dan `$appends` global akan memicu N+1 di `index()`. Controller yang memanggil `->append()`.

Verifikasi: `php artisan tinker --execute="dump(App\Models\Hotel::with('property')->first()->only([]) + ['label' => App\Models\Hotel::with('property')->first()->score_label]);"`

#### T-02 · `HotelNormalizer` + `HotelResource` + wiring `show()`  → N-4, N-2, U-2

1. Buat folder `laravel/app/Http/Resources/` (belum ada).
2. Buat `laravel/app/Support/HotelNormalizer.php` dengan method statis:

```php
public static function scoreLabel(float $score): string
{
    return match (true) {
        $score >= 9.0 => 'Luar Biasa',
        $score >= 8.0 => 'Sangat Bagus',
        $score >= 7.0 => 'Bagus',
        $score >= 6.0 => 'Memuaskan',
        $score > 0.0  => 'Cukup',
        default       => 'Belum Ada Ulasan',
    };
}

/** `['AC', ...]` and `[{name: 'AC'}, ...]` both become `[{name, is_available, badge}]`. */
public static function facilityGroups(?array $groups): array { /* … */ }

/** Fills the `icon` each seeded point is missing, deriving it from `type`. */
public static function transportPoints(?array $points): array { /* … */ }

/** Fills `author_name` / `author_role` so the app does not have to invent them. */
public static function faqs(?array $faqs): array { /* … */ }

/** `['a.jpg']` and `[{url, caption}]` both become `[{url, caption}]`. */
public static function roomImages(?array $images): array { /* … */ }

/** Guarantees the 12 keys GET_hotels_id.json documents. */
public static function policies(?array $policies, ?string $checkIn, ?string $checkOut, float $deposit): array { /* … */ }
```

Peta `type` → `icon` untuk `transportPoints()`: `train`→`train`, `metro`/`mrt`→`subway`,
`bus`→`bus`, `airport`→`plane`, `mall`→`shopping-bag`, `attraction`→`map-pin`, default →`map-pin`.

3. Buat `HotelResource` yang memakai normalizer, lalu ubah `show()`:

```php
// HotelApiController@show — SEBELUM `$hotel->toArray()`
$hotel->load([
    'property:id,name,city_id,address,gallery,description,latitude,longitude,status,cancellation_policy',
    'property.city:id,name',
    'activeRoomTypes.inventories',
]);
$hotel->property?->loadCount('reviews');            // fills reviews_count for the accessor
$hotel->append(['score_overall', 'score_label', 'review_count']);
```

> Catatan: `loadCount('reviews')` **tidak bisa** dipanggil pada `Hotel` — relasi `reviews()`
> ada di `Property`, bukan `Hotel`. Panggil pada `$hotel->property` seperti di atas.

4. Ganti `return ApiResponse::success($data, …)` menjadi
   `return ApiResponse::success((new HotelResource($hotel))->resolve(), 'Detail hotel berhasil dimuat.');`
   — pastikan `HotelResource` tetap memproduksi **semua** key yang sudah dihasilkan versi lama
   (`name`, `description`, `address`, `gallery`, `latitude`, `longitude`, `city_name`,
   `cancellation_policy`, `price_from`, `price_original`, `active_room_types` beserta `remaining`,
   `property`). Jangan mengurangi key — Flutter dan fixture bergantung padanya.

⚠️ **Yang TIDAK boleh dilakukan di task ini:** menambah 5 baris
`$data['policies'] = $hotel->policies ?? [];` dan seterusnya. Kelima field itu sudah ada di
response lewat `toArray()`. Lihat K-1.

#### T-03 · `HostHotelController`: terima `name` + `status`  → U-3 (a,b)

`store()` dan `update()`, tambahkan ke `$request->validate([...])`:

```php
'name'   => ['nullable', 'string', 'max:255'],
'status' => ['nullable', 'in:active,inactive,draft'],   // update() saja
```

lalu di kedua tempat penyusunan `$propertyData`:

```php
$propertyData = collect($data)->only([
    'name',                 // ← BARU (B-10)
    'description',
    'address',
    'latitude',
    'longitude',
    'cancellation_policy',
    'status',               // ← BARU, hanya di update()
])->toArray();
```

Perhatikan `update()` memakai `array_filter($propertyData, fn ($v) => $v !== null)` — ini sudah
benar dan tidak perlu diubah; `name` yang tidak dikirim akan diabaikan, bukan dikosongkan.

Verifikasi: `php artisan test --filter=HostHotelCrudTest` (dibuat di T-13).

#### T-04 · Standardisasi bentuk data di `HotelSeeder`  → U-5 (a–f)

```php
// (a) facility_groups items: string → objek
'items' => array_map(
    fn ($n) => ['name' => $n, 'is_available' => true, 'badge' => null],
    ['3 Kolam Renang', 'Pusat Kebugaran / Gym', /* … */],
),

// (b) transport_points: `duration` SUDAH ADA, tambahkan HANYA `icon`
['name' => 'Stasiun Gambir', 'type' => 'train', 'distance' => '2.1 km',
 'duration' => '8 mnt berkendara', 'icon' => 'train'],

// (c) faqs: tambah author
['question' => '…', 'answer' => '…',
 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],

// (e) room_types.images: string → objek
'images' => [
    ['url' => 'hotels/gallery/merlynn_2.jpg', 'caption' => 'Executive Room'],
],

// (f) room_types.facilities — saat ini TIDAK PERNAH di-set
'facilities' => ['Bathtub Marmer', 'AC', 'TV Kabel', 'Kulkas Mini', 'Brankas'],
```

(d) `policies` harus punya 12 key yang sama untuk kelima hotel — reuse
`HotelNormalizer::policies()` dari T-02 supaya bentuknya tidak bisa berbeda lagi.

#### T-05 · Inventory: helper + seeder baru  → U-8, N-1, U-5 (g)

Ini yang memperbaiki **B-4** (pencarian bertanggal selalu kosong).

1. `RoomType::ensureInventory(int $days = 90): void` — pindahkan logika
   `generateRollingInventory()` dari `HostHotelController` ke model, lalu controller memanggil
   helper itu (hindari tiga salinan logika yang sama).
2. Buat `laravel/database/seeders/RoomInventorySeeder.php`:

```php
public function run(): void
{
    RoomType::where('is_active', true)
        ->chunkById(100, fn ($types) => $types->each->ensureInventory(90));
}
```

3. Daftarkan di `DatabaseSeeder` **setelah** `HotelSeeder`.

Verifikasi:
```bash
php artisan migrate:fresh --seed
php artisan tinker --execute="dump(App\Models\RoomInventory::count());"      # harus > 0
curl "http://127.0.0.1:8000/api/v1/hotels?check_in=$(date -d '+3 days' +%F)&check_out=$(date -d '+5 days' +%F)"
# data harus TIDAK kosong
```

#### T-06 · `WizardForm`: hentikan data loss fasilitas  → U-6 (a)

Di `edit()`, setelah blok `$this->transport_points = …`, tambahkan:

```php
// `selected_facilities` drives both `hotels.facility_groups` and
// `properties.facilities` on save(). Without restoring it here, every edit
// overwrites the host's facilities with the hardcoded default list.
$groups = $hotel->facility_groups ?? [];
$restored = [];
foreach ($groups as $group) {
    foreach ($group['items'] ?? [] as $item) {
        $restored[] = is_array($item) ? ($item['name'] ?? '') : (string) $item;
    }
}
$restored = array_values(array_filter(array_unique($restored)));
if ($restored !== []) {
    $this->selected_facilities = $restored;
} elseif (is_array($p?->facilities) && $p->facilities !== []) {
    $this->selected_facilities = $p->facilities;
}
```

Verifikasi manual: buka wizard admin untuk hotel yang sudah punya fasilitas custom → simpan tanpa
mengubah apa pun → `hotels.facility_groups` **harus tetap sama**.

#### T-07 · `WizardForm`: room type lengkap + hapus + inventory  → U-6 (b–h), U-7

- `edit()` mapping room type: tambah `'description'`, `'facilities'`, `'images'`, `'is_active'`.
- `save()` `$roomPayload`: tambah 4 key yang sama.
- `save()` hapus room type yang dibuang:

```php
$keptIds = collect($this->room_types)->pluck('id')->filter()->all();
$hotel->roomTypes()->whereNotIn('id', $keptIds ?: [0])->delete();
```
  (letakkan **setelah** loop create/update, dan pertimbangkan soft-delete bila ada booking aktif).
- `save()` setelah `RoomType::create(...)`: `$roomType->ensureInventory(30);`
- `property_type`: ganti hardcode `'hotel_residence'` dengan public property
  `public string $property_type = 'hotel_residence';` + select di Tab 1.
- Hapus baris rule `'facility_groups' => 'nullable|array',` (property-nya tidak ada → no-op).
- Blade Tab 4: input `duration` + select `icon`; input `author_name`/`author_role` untuk FAQ.

#### T-08 · Flutter: jalur update + perbaiki loader edit  → U-9, U-10 (a–d), U-15

Ini memperbaiki **B-1, B-2, B-3** sekaligus — tiga blocker terberat.

1. `hotel_service.dart`:

```dart
/// Host-side detail. The form used to read `hotels/{id}` (public, unauthenticated),
/// which never carries `status` or `cover` and 404s on an unpublished hotel.
Future<Hotel> getHostHotelDetail(int hotelId) async {
  final res = await _api.get('host/hotels/$hotelId', auth: true);
  return Hotel.fromJson(res.dataMap);
}

/// Edit path. `POST host/hotels` is create-only — the server rejects a second
/// POST for the same property with 422, so edit mode must PUT.
Future<Map<String, dynamic>> updateHotelForProperty(
  int hotelId,
  Map<String, dynamic> hotelPayload,
  List<Map<String, dynamic>> roomTypes,
) async {
  final res = await _api.put('host/hotels/$hotelId', body: hotelPayload, auth: true);
  for (final rt in roomTypes) {
    final id = rt['id'] as int?;
    if (id != null) {
      await _api.put('host/room-types/$id', body: rt, auth: true);
    } else {
      await _api.post('host/hotels/$hotelId/room-types', body: rt, auth: true);
    }
  }
  return res.dataMap;
}
```

2. `hotel_form_screen.dart` — `_loadHotelData()`:
   - ganti `getHotelDetail` → `getHostHotelDetail`;
   - **hapus `catch (_)` bisu**, ganti dengan `catch (e)` yang men-`setState` pesan error dan
     menampilkan snackbar. Selama blok ini bisu, setiap bug loader tidak terlihat.
   - buang `'smoking_policy': p.smokingPolicy` (pakai `_smokingPolicy` milik state, atau
     tambahkan field-nya ke `HotelPolicy` di T-11);
   - buang `'total_inventory': rt.totalInventory` (tambahkan field-nya di T-11);
   - `'room_size_sqm': rt.sizeSqm` mengirim String `"35 m²"` ke field numerik — kirim angkanya.
   - beri tipe konkret pada parameter keempat helper `_*ToJson` (bukan `dynamic`), supaya
     kesalahan seperti ini gagal saat `flutter analyze`, bukan saat user menekan tombol.

3. `_submit()`:

```dart
if (_isEdit) {
  await _service.updateHotelForProperty(widget.hotelId!, hotelPayload, roomTypesPayload);
} else {
  await _service.createHotelForProperty(hotelPayload, roomTypesPayload);
}
```
   dan tambahkan ke `hotelPayload`: `'name': _nameCtrl.text.trim()`,
   `'transport_points': _transportPoints`, `'status': status`.

4. Pastikan `flutter/assets/json/PUT_host_hotels_id.json` ada dan konsisten (mapping-nya sudah
   terdaftar di `dummy_api_client.dart`).

Verifikasi: `flutter analyze` harus bersih, lalu jalankan mode dummy dan mode nyata untuk
create **dan** edit.

### Gelombang P1 (T-09 … T-12)

| Task | Isi | File |
|---|---|---|
| **T-09** | Normalisasi response publik selesai: `index()` juga append `score_label`/`score_overall`; samakan bentuk `facilities` di `GET_hotels_id.json`; tambah `score_overall` di fixture. | U-2, U-14 |
| **T-10** | `HostHotelResource` + `show()` mengeluarkan `status`/`cover`/`price_from`/`price_original`; route + method `DELETE`; selaraskan `GET_host_hotels_id.json`; daftarkan di `dummy_api_client.dart`; tambah `deleteHotel`/`deleteRoomType` di service Flutter. | N-3, U-3, U-4, U-12, U-13, U-9 |
| **T-11** | Model Flutter: `HotelPolicy.smokingPolicy` + deposit + 3 boolean; `HotelTransportPoint.duration`; `HotelRoomItem.totalInventory` + caption gambar; `score_overall` diprioritaskan; UI section `transport_points` (name/type/distance/duration/icon); mapper tipe transit opsional. | U-11, U-10 (e), N-10 |
| **T-12** | Upload gallery nyata: `HostGalleryController` + route `POST host/hotels/{hotel}/gallery`; Flutter mengunggah file lalu mengirim path hasil upload (bukan `picked.path`); mapping dummy. | N-5, U-4, U-10, U-12 |

### Gelombang P2 (T-13, T-14)

| Task | Isi | File |
|---|---|---|
| **T-13** | Tulis 4 file test pengunci: detail publik, CRUD host (PUT harus 200), availability bertanggal, parsing model Flutter dari fixture. | N-6, N-7, N-8, N-9 |
| **T-14** | Sinkronkan dokumentasi (D-3, atribut turunan, alur host baru, endpoint DELETE & upload). Jalankan `/sync-docs`. | U-16, U-17, U-18 |

---

## 7. Verifikasi & acceptance

### 7.1 Perintah

```bash
# Laravel
cd laravel
php artisan migrate:fresh --seed          # harus lolos tanpa error
php artisan test                          # seluruh suite
php artisan test --filter=HotelDetailTest
php artisan test --filter=HostHotelCrudTest
php artisan test --filter=HotelAvailabilityTest
./vendor/bin/pint                         # formatter

# Flutter
cd ../flutter
flutter analyze                           # WAJIB bersih — B-2 lolos justru karena `dynamic`
flutter test
flutter run --dart-define=DUMMY_API=true                                  # mode fixture
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1        # mode nyata
```

> Catatan: test Laravel memakai SQLite in-memory sedangkan produksi PostgreSQL. SQLite **tidak**
> menegakkan CHECK constraint, jadi bug ENUM (`status`, `property_type`, `booking_mode`) hanya
> muncul di PostgreSQL. Setelah `php artisan test` hijau, jalankan juga
> `php artisan migrate:fresh --seed` pada koneksi `pgsql` yang sebenarnya.

### 7.2 Acceptance per blocker

| Blocker | Cara membuktikan sudah beres |
|---|---|
| B-1 | Edit hotel dari app host → tersimpan, **tanpa** 422 `"Hotel sudah terdaftar untuk properti ini."` |
| B-2 | Buka form edit → semua tab terisi data nyata (bukan default). `flutter analyze` bersih. |
| B-3 | Matikan publikasi hotel (`properties.status != active`) → form host **masih** bisa membukanya. |
| B-4 | `GET /api/v1/hotels?check_in=<+3d>&check_out=<+5d>` → `data` tidak kosong; `RoomInventory::count() > 0`. |
| B-5 | Edit hotel dengan fasilitas custom, simpan tanpa perubahan → `hotels.facility_groups` identik sebelum/sesudah. |
| B-6 | `GET /api/v1/hotels/{id}` memuat `score_label` ≠ `null` dan `review_count` sesuai jumlah baris `reviews`. |
| B-7 | Response memuat `score_overall` skala 0–10; UI menampilkan angka yang sama dengan fixture. |
| B-8 | Wizard admin: tambah room type → ada baris `room_inventories`; hapus room type dari wizard → baris DB ikut hilang; `description`/`facilities`/`images` tersimpan. |
| B-9 | `properties.gallery` berisi path `hotels/gallery/…`, **tidak** ada `/data/user/0/…` atau `C:\…`. |
| B-10 | Ubah nama hotel dari app host → `properties.name` berubah. |
| B-11 | Tab transit di app host bisa menambah titik → tersimpan di `hotels.transport_points` lengkap dengan `duration` + `icon`. |
| B-12/B-13 | `flutter run --dart-define=DUMMY_API=true` dan mode nyata menghasilkan tampilan **identik** pada layar form host. |
| B-14..B-17 | `php artisan db:seed --class=HotelSeeder` lalu cek `faqs[].author_name`, `transport_points[].icon`, `facility_groups[].items[].name`, `room_types.images[].url` terisi. |
| B-18 | `DELETE /api/v1/host/room-types/{id}` mengembalikan 200 dan barisnya hilang. |

### 7.3 Checklist final

**P0**
- [ ] T-01 accessor `score_label` / `review_count` / `score_overall` di `Hotel.php`
- [ ] T-02 `HotelNormalizer` + `HotelResource` + `show()` di-wire (⚠️ **tanpa** 5 baris K-1)
- [ ] T-03 `HostHotelController` menerima `name` (+`status` di `update`)
- [ ] T-04 bentuk data `HotelSeeder` distandardisasi (`icon`, author, items objek, images objek, facilities)
- [ ] T-05 `RoomType::ensureInventory()` + `RoomInventorySeeder` + terdaftar di `DatabaseSeeder`
- [ ] T-06 `WizardForm::edit()` memulihkan `selected_facilities`
- [ ] T-07 room type wizard lengkap + delete + inventory
- [ ] T-08 Flutter: `getHostHotelDetail`, `updateHotelForProperty`, loader edit tidak crash & tidak bisu, kirim `name`/`transport_points`/`status`

**P1**
- [ ] T-09 normalisasi response publik + fixture publik selaras
- [ ] T-10 `HostHotelResource`, route DELETE, fixture host selaras, mapping dummy
- [ ] T-11 model Flutter lengkap + UI transit
- [ ] T-12 upload gallery nyata

**P2**
- [ ] T-13 4 file test pengunci hijau
- [ ] T-14 dokumentasi tersinkron (`/sync-docs`)

---

## 8. Lampiran — pemetaan field form host

`flutter/lib/screens/mitra/hotel_form_screen.dart` (5 tab; Tab 4 “Inventaris” masih display-only).

| Field JSON host | Field form | Tab | Status |
|---|---|---|---|
| `property_id` | `widget.propertyId` | — | ✅ constructor |
| `star_rating` | `_starRating` | 1 | ✅ |
| `open_year` | `_openYear` | 1 | ✅ |
| `check_in_time` / `check_out_time` | `_checkInTime` / `_checkOutTime` | 1 | ✅ |
| `name` | `_nameCtrl` | 1 | 🟡 ada di form, **tidak dikirim** (B-10) |
| `description` | `_descCtrl` | 1 | ✅ |
| `address` | `_addressCtrl` | 1 | ✅ |
| `latitude` / `longitude` | `_latitude` / `_longitude` | 1 | ✅ |
| `cancellation_policy` | `_cancellationPolicyCtrl` | 1 | ✅ |
| `facility_groups` | `_facilityGroups` | 2 | ✅ objek `{name, is_available, badge}` |
| `policies` | `_receptionist24h`, `_allowChildren`, `_extraBedAvailable`, `_childPolicy`, `_extraBedPolicy`, `_smokingPolicy` | 2 | ✅ kirim · 🔴 **load crash** (B-2) |
| `deposit_amount` | `_depositCtrl` | 2 | ✅ |
| `room_types` | `_roomTypes` | 3 | ✅ create · ❌ tanpa update/delete (B-1) |
| *(inventaris)* | — | 4 | 🟡 display-only, belum bisa mengubah allotment/harga per tanggal |
| `gallery` | `_gallery` | 5 | 🟠 path lokal device (B-9) |
| `review_quotes` | `_reviewQuotes` | 5 | ✅ |
| `faqs` | `_faqs` | 5 | 🟡 tanpa author (B-15) |
| **`transport_points`** | — | — | 🟡 **tidak ada UI** (B-11) |
| `status` | param `_submit({status})` | — | 🟡 hanya untuk teks snackbar, tidak dikirim (K-6) |

### Field yang memang tidak boleh ada di form

| Field | Alasan |
|---|---|
| `id`, `created_at`, `updated_at` | server-generated |
| `score`, `score_overall`, `score_label`, `review_count` | turunan/read-only (D-1, D-2) |
| `price_from`, `price_original` | accessor dari room type termurah |
| `city_name` | turunan dari `property.city` |
| `cover` | turunan `gallery[0]` (host-only) |
| `meta`, `errors` | bagian amplop `ApiResponse` |

### Perbedaan struktural kedua fixture

| Aspek | `GET_hotels_id.json` (publik) | `GET_host_hotels_id.json` (host) |
|---|---|---|
| Room types | `active_room_types` — kaya: inventory, images, bed config | `room_types` — sederhana, **key-nya salah** (B-12) |
| `cover` | ❌ | ✅ |
| `status` | ❌ | ✅ top-level |
| `policies` | 12 key lengkap | 3 boolean saja |
| `facility_groups.items` | objek `{name, is_available, badge}` | string biasa |
| `gallery` | 5 gambar | 3 gambar |
| `transport_points` / `faqs` / `review_quotes` | ✅ | ❌ (padahal host yang mengisinya) |
| `property` nested | ✅ | ✅ |

Setelah T-10 selesai, kedua fixture harus dihasilkan dari `HotelResource` /
`HostHotelResource` yang sama, sehingga perbedaan tinggal soal *scope* (host punya
`status`/`cover`, publik hanya room type aktif) — bukan soal nama key.
