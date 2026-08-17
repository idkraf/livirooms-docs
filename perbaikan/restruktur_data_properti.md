# Audit & Restrukturisasi Data: Hotels & Properties

> **Dokumen:** Rencana arsitektur database relasional baru untuk modul Hotels & Properties.
> **Sumber audit:** `flutter/assets/json/readme_hotels_host.md` + `readme_properties_host.md`.
> **Konteks:** Migrasi dari schema JSONB-heavy ke tabel relasional penuh, dengan tetap mempertahankan
> compatibility dengan Flutter form dan API response. Booking & payment system **tidak disentuh**.

---

## 1. Ringkasan Eksekutif

### 1.1 Tujuan
- Menghilangkan penyimpanan JSON blob untuk data terstruktur yang memiliki siklus hidup (CRUD) atau perlu di-query.
- Menciptakan single source of truth untuk setiap entity tanpa duplikasi nilai.
- Mempertahankan bentuk response API yang sama agar Flutter tidak patah.

### 1.2 Skop
- **Termasuk:** Hotels, Room Types, Room Inventories, Properties, Property Prices, Property Questions,
  Property Recommendations, Property Search Logs, dan semua JSONB display fields di `properties_other`.
- **Tidak termasuk:** Booking transactions, Payment systems, User auth, Cities, Reviews.

### 1.3 Ringkasan Perubahan
| Aspek | Saat ini | Setelah |
|-------|----------|---------|
| JSONB collections | 15+ kolom JSONB di `hotels` + `properties_other` | Dipecah menjadi 25+ tabel relasional |
| Media | `gallery` (JSONB) | `property_media` + `room_type_media` |
| Fasilitas | `facilities` (JSONB) + `facility_groups` (JSONB) | Tabel pivot + tabel group |
| Pricing detail | Hardcoded di controller | `property_special_prices`, `property_add_ons`, `property_payment_plans` |
| Hotel policies | `policies` (JSONB 12 key) | `hotel_policies` (1 row per hotel) |
| Hotel scores | `score` (JSONB 6 component) | `hotel_score_components` |
| Room inventories | `room_inventories` (sudah relasional, ikut di-recreate) | Tetap relasional, diperbaiki struktur |
| `properties_other` | 30+ kolom campuran JSONB & scalar | Dihapus, data Didistribusi ke 15+ tabel |

---

## 2. Inventory & Konsolidasi Parameter

### 2.1 Modul Hotel — Semua Field

#### 2.1.1 `hotels` (Core Hotel Header)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK unique → `properties.id` |
| `star_rating` | integer | 1-5 bintang |
| `check_in_time` | time | Default 14:00 |
| `check_out_time` | time | Default 12:00 |
| `open_year` | integer | Tahun beroperasi |
| `deposit_amount` | decimal(12,2) | Deposit guarantee |
| `created_at` / `updated_at` | timestamp | — |

**JSONB yang dipecah:**
- `policies` → `hotel_policies`
- `score` → `hotel_score_components`
- `facility_groups` → `hotel_facility_groups` + `hotel_facilities`
- `transport_points` → `hotel_transport_points`
- `faqs` → `hotel_faqs`
- `review_quotes` → `hotel_review_quotes`

**Derived / Accessor (tidak disimpan):**
- `price_from` = harga terendah `room_types.base_price` yang aktif
- `price_original` = harga asli room type
- `overall_score` = `score.basic * 2` (skala 0-10)
- `score_label` = label tekstual dari `overall_score`
- `review_count` = jumlah reviews dari `properties.reviews`
- `cover` = `property.gallery[0]`
- `city_name` = relasi `property.city.name`

#### 2.1.2 `room_types`
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → `hotels.id` |
| `name` | varchar | Nama tipe kamar |
| `slug` | varchar | URL-friendly |
| `description` | text | Deskripsi |
| `bed_configuration` | varchar | Contoh: "1 King Bed" |
| `base_price` | decimal(15,2) | Harga nett |
| `price_original` | decimal(15,2) | Harga sebelum diskon |
| `total_inventory` | integer | Total unit fisik |
| `capacity_adults` | integer | Max dewasa |
| `capacity_children` | integer | Max anak |
| `max_guests` | integer | Max total |
| `room_size_sqm` | varchar | Ukuran ("35 m²") |
| `breakfast_included` | boolean | |
| `has_window` | boolean | |
| `no_smoking` | boolean | |
| `free_wifi` | boolean | |
| `is_active` | boolean | |

**JSONB yang dipecah:**
- `facilities` → `room_type_facilities`
- `images` → `room_type_media`

#### 2.1.3 `room_inventories`
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `room_type_id` | bigint | FK → `room_types.id` |
| `date` | date | Tanggal inventori |
| `allotment` | integer | Total unit tersedia |
| `booked_count` | integer | Sudah dibooking |
| `price` | decimal(15,2) | Harga per malam |
| `is_closed` | boolean | Inventori tutup |
| `created_at` / `updated_at` | timestamp | — |
| **Unique** | | `room_type_id + date` |

#### 2.1.4 `hotel_policies` (Baru — pecahan dari `hotels.policies`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK unique → `hotels.id` |
| `receptionist_24h` | boolean | |
| `allow_children` | boolean | |
| `extra_bed_available` | boolean | |
| `child_policy` | text | |
| `extra_bed_policy` | text | |
| `smoking_policy` | text | |
| `deposit_amount` | decimal(12,2) | |
| `deposit_currency` | varchar(3) | ISO 4217 |
| `created_at` / `updated_at` | timestamp | — |

#### 2.1.5 `hotel_score_components` (Baru — pecahan dari `hotels.score`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → `hotels.id` |
| `component` | enum | `basic`, `cleanliness`, `service`, `location`, `value`, `room` |
| `score` | decimal(3,2) | Skala 0–5 |
| `created_at` / `updated_at` | timestamp | — |
| **Unique** | | `hotel_id + component` |

#### 2.1.6 `hotel_facility_groups` (Baru — pecahan dari `hotels.facility_groups`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → `hotels.id` |
| `name` | varchar | Nama grup |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.1.7 `hotel_facilities` (Baru — item dalam grup)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_facility_group_id` | bigint | FK → `hotel_facility_groups.id` |
| `name` | varchar | Nama fasilitas |
| `is_available` | boolean | |
| `badge` | varchar | Contoh: "Baru", "Premium" |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.1.8 `hotel_transport_points` (Baru — pecahan dari `hotels.transport_points`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → `hotels.id` |
| `name` | varchar | Nama titik |
| `type` | varchar | `train`, `metro`, `bus`, `airport`, `mall`, `attraction` |
| `distance` | varchar | Contoh: "2.1 km" |
| `duration` | varchar | Contoh: "8 mnt berkendara" |
| `icon` | varchar | Nama icon/emoji |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.1.9 `hotel_faqs` (Baru — pecahan dari `hotels.faqs`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → `hotels.id` |
| `question` | text | |
| `answer` | text | |
| `author_name` | varchar | |
| `author_role` | varchar | |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.1.10 `hotel_review_quotes` (Baru — pecahan dari `hotels.review_quotes`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → `hotels.id` |
| `quote` | text | Kutipan review |
| `author_name` | varchar | |
| `author_role` | varchar | |
| `rating` | integer | 1-10 |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.1.11 `room_type_facilities` (Baru — pecahan dari `room_types.facilities`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `room_type_id` | bigint | FK → `room_types.id` |
| `name` | varchar | Nama fasilitas |
| `is_available` | boolean | |
| `sort_order` | integer | |

#### 2.1.12 `room_type_media` (Baru — pecahan dari `room_types.images`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `room_type_id` | bigint | FK → `room_types.id` |
| `url` | varchar | Path gambar |
| `caption` | varchar | Caption opsional |
| `sort_order` | integer | |

---

### 2.2 Modul Property — Semua Field

#### 2.2.1 `properties` (Core Property Header)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `host_id` | bigint | FK → `users.id` |
| `city_id` | bigint | FK → `cities.id` |
| `property_type` | enum | `apartment`, `house`, `villa`, `hotel_residence`, `guest_house`, `exclusive_kost` |
| `booking_mode` | enum | `unit`, `room` |
| `name` | varchar | Nama properti |
| `building_name` | varchar | Nama gedung |
| `description` | text | |
| `address` | varchar | |
| `latitude` | decimal(10,7) | |
| `longitude` | decimal(10,7) | |
| `guest_capacity` | integer | |
| `bedrooms` | integer | |
| `bathrooms` | integer | **BARU** — tidak ada di schema lama |
| `facilities` | **dihapus** | Dipindah ke `property_facilities` |
| `gallery` | **dihapus** | Dipindah ke `property_media` |
| `status` | enum | `active`, `inactive`, `draft` |
| `cancellation_policy` | text | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.2 `property_media` (Baru — pecahan dari `properties.gallery`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `url` | varchar | Path/URL gambar |
| `caption` | varchar | Caption opsional |
| `sort_order` | integer | Urutan tampil |
| `is_cover` | boolean | true = gambar utama |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.3 `property_facilities` (Baru — pecahan dari `properties.facilities`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `facility_id` | bigint | FK → `facilities.id` (nullable) |
| `name` | varchar | Snapshot nama (jika tidak ada master) |
| `is_available` | boolean | |
| `badge` | varchar | |
| `sort_order` | integer | |

#### 2.2.4 `property_prices` (Existing — dipertahankan & distandardisasi)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `price_type` | enum | `daily`, `weekly`, `monthly`, `yearly` |
| `amount` | decimal(15,2) | Harga |
| `cleaning_fee` | decimal(15,2) | |
| `deposit` | decimal(15,2) | |
| `service_fee` | decimal(15,2) | |
| `created_at` / `updated_at` | timestamp | — |
| **Unique** | | `property_id + price_type` |

#### 2.2.5 `property_pricing_options` (Baru — pecahan dari `duration_options`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `nights` | integer | Jumlah malam |
| `sort_order` | integer | |

#### 2.2.6 `property_special_prices` (Baru — pecahan dari `special_prices`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `min_nights` | integer | Min malam |
| `discount_percent` | integer | 0-100 |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.7 `property_add_ons` (Baru — pecahan dari `add_ons`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `name` | varchar | |
| `duration_note` | varchar | |
| `price` | decimal(15,2) | |
| `info` | text | |
| `is_selected` | boolean | Default false |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.8 `property_payment_plans` (Baru — pecahan dari `payment_plans`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `name` | varchar | Nama plan |
| `cadence` | varchar | Cicilan: bulanan, mingguan |
| `installments` | integer | Jumlah cicilan |
| `total` | decimal(15,2) | Total bayar |
| `sort_order` | integer | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.9 `property_payment_plan_entries` (Baru — pecahan dari `payment_plans[].entries`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_payment_plan_id` | bigint | FK → `property_payment_plans.id` |
| `date` | date | Tanggal jatuh tempo |
| `amount` | decimal(15,2) | Nominal cicilan |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.10 `property_promos` (Baru — pecahan dari `promo`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `code` | varchar | Kode promo |
| `discount_type` | varchar | `percent`, `fixed` |
| `discount_value` | decimal(15,2) | |
| `valid_from` | date | |
| `valid_until` | date | |
| `is_active` | boolean | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.11 `property_other_core` (Baru — scalar fields dari `properties_other`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK unique → `properties.id` |
| `province` | varchar | |
| `price_from` | decimal(15,2) | Derived, bisa di-cache |
| `star_rating` | decimal(3,1) | |
| `check_in_time` | time | |
| `check_out_time` | time | |
| `has_breakfast` | boolean | |
| `type_label` | varchar | Label tipe properti |
| `area_label` | varchar | Label kota/area |
| `extra_media_count` | integer | Jumlah media selain cover |
| `intro` | text | Headline singkat |
| `description_extra_heading` | varchar | |
| `map_preview` | varchar | URL gambar peta |
| `price_caption` | varchar | Contoh: "per bulan mulai dari" |
| `is_flash_sale` | boolean | |
| `deposit_amount` | decimal(15,2) | Deposit host |
| `schedule_note` | text | Catatan jadwal harga |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.12 `property_extra_descriptions` (Baru — pecahan dari `description_extra`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `text` | text | Paragraf deskripsi |
| `sort_order` | integer | |

#### 2.2.13 `property_review_summaries` (Baru — pecahan dari `review_summary`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK unique → `properties.id` |
| `average` | decimal(3,2) | Rata-rata rating |
| `total` | integer | Total review |
| `label` | varchar | Contoh: "Luarbiasa" |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.14 `property_review_breakdowns` (Baru — pecahan dari `review_summary.breakdown`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_review_summary_id` | bigint | FK → `property_review_summaries.id` |
| `rating` | integer | 1-5 bintang |
| `count` | integer | Jumlah review |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.15 `property_specs` (Baru — pecahan dari `specs`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | Nama icon |
| `label` | varchar | Contoh: "Luas" |
| `value` | varchar | Contoh: "200 m²" |
| `sort_order` | integer | |

#### 2.2.16 `property_bed_facilities` (Baru — pecahan dari `bed_facilities`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | |
| `label` | varchar | Contoh: "1 King Bed" |
| `sort_order` | integer | |

#### 2.2.17 `property_building_facilities` (Baru — pecahan dari `building_facilities`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | |
| `label` | varchar | Contoh: "Kolam Renang" |
| `is_highlighted` | boolean | |
| `sort_order` | integer | |

#### 2.2.18 `property_building_facilities_all` (Baru — pecahan dari `building_facilities_all`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `name` | varchar | Nama fasilitas |
| `sort_order` | integer | |

#### 2.2.19 `property_room_furniture` (Baru — pecahan dari `room_furniture`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | |
| `label` | varchar | Contoh: "AC", "Kulkas" |
| `sort_order` | integer | |

#### 2.2.20 `property_room_furniture_groups` (Baru — grup dari `room_furniture_groups`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `name` | varchar | Nama grup (misal: "Kamar Mandi") |
| `sort_order` | integer | |

#### 2.2.21 `property_room_furniture_items` (Baru — item dalam grup)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_room_furniture_group_id` | bigint | FK → `property_room_furniture_groups.id` |
| `icon` | varchar | |
| `label` | varchar | |
| `sort_order` | integer | |

#### 2.2.22 `property_check_in_notes` (Baru — pecahan dari `check_in_notes`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | |
| `text` | text | Catatan check-in |
| `tone` | varchar | `info`, `warning`, `success` |
| `sort_order` | integer | |

#### 2.2.23 `property_deposit_notes` (Baru — pecahan dari `deposit_notes`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | |
| `text` | text | Catatan deposit |
| `sort_order` | integer | |

#### 2.2.24 `property_unit_details` (Baru — pecahan dari `unit_detail`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `icon` | varchar | |
| `label` | varchar | Contoh: "Luas" |
| `value` | varchar | Contoh: "45 m²" |
| `sort_order` | integer | |

#### 2.2.25 `property_nearby_places` (Baru — pecahan dari `nearby`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `name` | varchar | Nama tempat |
| `type` | varchar | `mall`, `hospital`, `school`, dll |
| `distance` | varchar | Contoh: "1.2 km" |
| `icon` | varchar | |
| `sort_order` | integer | |

#### 2.2.26 `property_guest_media` (Baru — pecahan dari `guest_media`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `url` | varchar | URL media |
| `type` | varchar | `image`, `video` |
| `sort_order` | integer | |

#### 2.2.27 `property_building_units` (Baru — pecahan dari `building_units`)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `type` | varchar | Tipe unit |
| `count` | integer | Jumlah unit |
| `icon` | varchar | |
| `sort_order` | integer | |

#### 2.2.28 `property_questions` (Existing — dipertahankan)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `question` | text | |
| `answer` | text | |
| `asked_by` | bigint | FK → `users.id` (nullable) |
| `sort_order` | integer | |
| `is_active` | boolean | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.29 `property_recommendations` (Existing — dipertahankan)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → `properties.id` |
| `name` | varchar | |
| `description` | text | |
| `image` | varchar | |
| `sort_order` | integer | |
| `is_active` | boolean | |
| `created_at` / `updated_at` | timestamp | — |

#### 2.2.30 `property_search_logs` (Existing — dipertahankan)
| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `user_id` | bigint | FK → `users.id` (nullable) |
| `filters` | jsonb | Parameter pencarian (dipertahankan JSONB — dinamis) |
| `created_at` / `updated_at` | timestamp | — |

---

### 2.3 Entitas Bersama / Master Data

| Entity | Keterangan |
|--------|------------|
| `users` | Host/owner properti. Sudah ada. |
| `cities` | Kota lokasi properti. Sudah ada. |
| `facilities` | Master data fasilitas (id, name, icon, category). **Dibuat baru** untuk mendukung pivot `property_facilities` dan `hotel_facilities`. |

---

## 3. Arsitektur Database Relasional Baru

### 3.1 Diagram Konseptual (Text ERD)

```
users (1) ────< (N) properties (1) ────< (N) property_media
                  │                      (N) property_facilities
                  │                      (N) property_prices
                  │                      (N) property_pricing_options
                  │                      (N) property_special_prices
                  │                      (N) property_add_ons
                  │                      (N) property_payment_plans
                  │                      (N) property_payment_plan_entries
                  │                      (N) property_promos
                  │                      (N) property_extra_descriptions
                  │                      (1) property_other_core
                  │                      (1) property_review_summary
                  │                      (N) property_review_breakdowns
                  │                      (N) property_specs
                  │                      (N) property_bed_facilities
                  │                      (N) property_building_facilities
                  │                      (N) property_building_facilities_all
                  │                      (N) property_room_furniture
                  │                      (N) property_room_furniture_groups
                  │                      (N) property_room_furniture_items
                  │                      (N) property_check_in_notes
                  │                      (N) property_deposit_notes
                  │                      (N) property_unit_details
                  │                      (N) property_nearby_places
                  │                      (N) property_guest_media
                  │                      (N) property_building_units
                  │                      (N) property_questions
                  │                      (N) property_recommendations
                  │                      (N) property_search_logs
                  │
                  │ (1) ────< (N) hotels
                  │                      (N) hotel_policies
                  │                      (N) hotel_score_components
                  │                      (N) hotel_facility_groups
                  │                      (N) hotel_facilities
                  │                      (N) hotel_transport_points
                  │                      (N) hotel_faqs
                  │                      (N) hotel_review_quotes
                  │                      (N) room_types
                  │                             (N) room_type_facilities
                  │                             (N) room_type_media
                  │                             (N) room_inventories
                  │
cities (1) ────< (N) properties
facilities (1) ────< (N) property_facilities
facilities (1) ────< (N) hotel_facilities
```

### 3.2 Prinsip Normalisasi yang Diterapkan

| Prinsip | Implementasi |
|---------|-------------|
| **1NF** | Tidak ada array/multi-value di satu kolom. Setiap value punya baris sendiri. |
| **2NF** | Tidak ada partial dependency. Key tabel adalah PK. |
| **3NF** | Tidak ada transitive dependency. Field turunan dihitung via accessor, tidak disimpan kecuali untuk performa (`price_from`, `review_summary`). |
| **JSONB retention** | Hanya untuk `property_search_logs.filters` yang strukturnya benar-benar dinamis. Semua struktur yang known schema dipecah. |

### 3.3 Tabel Inti & Master Data

#### `users` (Existing — tidak diubah)
- `id`, `name`, `email`, `email_verified_at`, `password`, `phone`, `role`, timestamps

#### `cities` (Existing — tidak diubah)
- `id`, `province_id`, `name`, `slug`, timestamps

#### `facilities` (Baru — Master Data Fasilitas)
| Field | Tipe |
|-------|------|
| `id` | bigint PK |
| `name` | varchar |
| `icon` | varchar |
| `category` | enum: `property`, `room`, `building` |
| `is_active` | boolean |
| `created_at` / `updated_at` | timestamp |

**Alasan:** Fasilitas di form adalah daftar referensi (AC, WiFi, Kolam Renang, dll).
Dengan master table, kita bisa:
- Menjamin konsistensi penulisan (`WiFi` vs `Wifi` vs `wi-fi`).
- Menambahkan icon globally.
- Mengategorikan fasilitas per jenis properti/room.

### 3.4 Tabel Properties (Normalized)

Struktur baru menggantikan `properties` + `properties_other` + JSONB galeri/fasilitas.

**Tabel utama: `properties`**
- Menyimpan data identitas, lokasi, ketentuan, dan status properti.
- Kolom JSONB yang lama (`gallery`, `facilities`) **dihapus**.

**Tabel pendukung:**
- `property_media` — menggantikan `gallery`.
- `property_facilities` — menggantikan `facilities`.
- `property_other_core` — scalar display fields yang tadinya di `properties_other`.
- `property_extra_descriptions`, `property_specs`, `property_bed_facilities`, dst. — array display fields.

### 3.5 Tabel Hotels (Normalized)

**Tabel utama: `hotels`**
- Menyimpan identitas hotel, operasional, dan deposit.
- Semua JSONB (`policies`, `score`, `facility_groups`, `transport_points`, `faqs`, `review_quotes`) **dihapus**.

**Tabel pendukung:**
- `hotel_policies` — 1 row per hotel.
- `hotel_score_components` — 6 rows per hotel.
- `hotel_facility_groups` + `hotel_facilities` — menggantikan `facility_groups`.
- `hotel_transport_points` — menggantikan `transport_points`.
- `hotel_faqs` — menggantikan `faqs`.
- `hotel_review_quotes` — menggantikan `review_quotes`.

### 3.6 Tabel Pricing & Inventory

- `property_prices` — sudah relasional, dipertahankan.
- `property_pricing_options` — durasi stay yang tersedia (1, 2, 3, 6, 12 malam).
- `property_special_prices` — aturan diskon berdasarkan jumlah malam.
- `property_add_ons` — layanan tambahan (asuransi, late checkout, dll).
- `property_payment_plans` + `property_payment_plan_entries` — cicilan.
- `property_promos` — kode promo.
- `room_inventories` — inventori harian per tipe kamar (sudah relasional, dipertahankan).

### 3.7 Tabel Content & UI Display

Tabel-tabel ini berasal dari `properties_other` yang tadinya JSONB. Semua dipecah menjadi tabel
relasional dengan `sort_order` agar urutan tampilan di Flutter tetap terjaga.

**Catatan performa:** Property detail page akan melakukan ~15 JOIN. Untuk mengamankan performa:
- Controller **wajib** eager-load via `with()`.
-pertimbangkan API response caching (Redis) untuk field yang jarang berubah (`specs`, `building_facilities`).
- Field `price_from`, `review_summary` bisa di-cache di `property_other_core` karena mahal dihitung realtime.

### 3.8 Tabel Relasi Transaksional

- `property_questions` — Q&A dari calon tamu.
- `property_recommendations` — Rekomendasi properti lain.
- `property_search_logs` — Log pencarian (JSONB filters dipertahankan karena filter dinamis).

---

## 4. Rencana Migration

### 4.1 Tabel yang Dihapus (Drop)

Berdasarkan daftar migration lama yang akan dihapus/diganti:

| Tabel | Migration Lama | Alasan Penghapusan |
|-------|---------------|-------------------|
| `availabilities` | `2026_07_14_080400_create_availabilities_table.php` | Digantikan `room_inventories` (lebih spesifik untuk hotel). |
| `rooms` | `2026_08_13_000004_create_rooms_table.php` | Tidak ada relasi yang jelas; data rol dipindah ke `room_types` + `room_inventories`. |
| `properties` | `2026_07_14_080100_create_properties_table.php` | Akan di-recreate dengan struktur baru (tanpa JSONB). |
| `property_search_logs` | `2026_07_14_080200_create_property_search_logs_table.php` | Akan di-recreate (struktur sama). |
| `property_prices` | `2026_07_14_080500_create_property_prices_table.php` | Akan di-recreate dengan unique constraint `property_id + price_type`. |
| `property_recommendations` | `2026_07_14_080700_create_property_recommendations_table.php` | Akan di-recreate. |
| `properties_other` | `2026_08_16_000001_create_properties_other_table.php` | **Dihapus permanen.** Data didistribusi ke 15+ tabel baru. |
| `hotels` | `2026_08_13_000002_create_hotels_table.php` | Akan di-recreate tanpa JSONB. |
| `room_types` | `2026_08_13_000003_create_room_types_table.php` | Akan di-recreate tanpa JSONB `facilities` & `images`. |
| `room_inventories` | `2026_08_13_000005_create_room_inventories_table.php` | Akan di-recreate (struktur sama, ditambah index). |
| `property_questions` | `2026_08_16_000004_create_property_questions_table.php` | Akan di-recreate. |

**Catatan:** Migration tambahan lama (`add_cancellation_policy`, `add_unique_price_type`, `update_properties_for_hotels`, `add_hotel_ota_columns`) ikut dihapus karena fungsinya sudah tercakup dalam struktur baru.

### 4.2 Tabel Baru yang Dibuat

#### A. Master & Core
| No | Tabel | Sumber Data |
|----|-------|-------------|
| 1 | `facilities` | Baru — master data fasilitas |
| 2 | `properties` | recreate dari tabel lama |
| 3 | `property_media` | JSONB `gallery` |
| 4 | `property_facilities` | JSONB `facilities` |
| 5 | `property_prices` | recreate dari tabel lama |
| 6 | `property_pricing_options` | JSONB `duration_options` |
| 7 | `property_special_prices` | JSONB `special_prices` |
| 8 | `property_add_ons` | JSONB `add_ons` |
| 9 | `property_payment_plans` | JSONB `payment_plans` |
| 10 | `property_payment_plan_entries` | nested `payment_plans[].entries` |
| 11 | `property_promos` | JSONB `promo` |
| 12 | `property_other_core` | scalar `properties_other` |
| 13 | `property_extra_descriptions` | JSONB `description_extra` |
| 14 | `property_review_summaries` | JSONB `review_summary` |
| 15 | `property_review_breakdowns` | nested `review_summary.breakdown` |
| 16 | `property_specs` | JSONB `specs` |
| 17 | `property_bed_facilities` | JSONB `bed_facilities` |
| 18 | `property_building_facilities` | JSONB `building_facilities` |
| 19 | `property_building_facilities_all` | JSONB `building_facilities_all` |
| 20 | `property_room_furniture` | JSONB `room_furniture` |
| 21 | `property_room_furniture_groups` | JSONB `room_furniture_groups` |
| 22 | `property_room_furniture_items` | nested `room_furniture_groups[].items` |
| 23 | `property_check_in_notes` | JSONB `check_in_notes` |
| 24 | `property_deposit_notes` | JSONB `deposit_notes` |
| 25 | `property_unit_details` | JSONB `unit_detail` |
| 26 | `property_nearby_places` | JSONB `nearby` |
| 27 | `property_guest_media` | JSONB `guest_media` |
| 28 | `property_building_units` | JSONB `building_units` |
| 29 | `property_questions` | recreate |
| 30 | `property_recommendations` | recreate |
| 31 | `property_search_logs` | recreate (struktur sama) |

#### B. Hotels Module
| No | Tabel | Sumber Data |
|----|-------|-------------|
| 32 | `hotels` | recreate |
| 33 | `hotel_policies` | JSONB `policies` |
| 34 | `hotel_score_components` | JSONB `score` |
| 35 | `hotel_facility_groups` | JSONB `facility_groups` (group level) |
| 36 | `hotel_facilities` | JSONB `facility_groups[].items` |
| 37 | `hotel_transport_points` | JSONB `transport_points` |
| 38 | `hotel_faqs` | JSONB `faqs` |
| 39 | `hotel_review_quotes` | JSONB `review_quotes` |
| 40 | `room_types` | recreate (tanpa JSONB) |
| 41 | `room_type_facilities` | JSONB `facilities` |
| 42 | `room_type_media` | JSONB `images` |
| 43 | `room_inventories` | recreate |

### 4.3 Tabel yang Diubah (Alter)

| Tabel | Perubahan |
|-------|-----------|
| `properties` | Drop kolom: `gallery`, `facilities`. Tambah kolom: `bathrooms`. |
| `hotels` | Drop kolom: `policies`, `score`, `facility_groups`, `transport_points`, `faqs`, `review_quotes`. |
| `room_types` | Drop kolom: `facilities`, `images`. |

### 4.4 Strategi Migrasi Data

Karena ini adalah penggantian schema total (bukan alter bertahap), langkah yang disarankan:

#### Tahap 1: Fresh Database (Paling Aman untuk Dev/Staging)
```bash
php artisan migrate:fresh --seed
```
- Cocok untuk lingkungan development/staging.
- Semua data lama hilang, schema baru dibuat bersih.

#### Tahap 2: Data Migration (Jika Perlu Pertahankan Data Lama)
Jika ada data produksi yang harus dipindah:

1. **Backup** database produksi.
2. Buat migration sementara (one-off) untuk:
   - Membaca JSONB lama (`properties.gallery`, `hotels.policies`, dst).
   - Insert ke tabel baru.
   - Contoh: `hotel_policies` diisi dari `hotels.policies->receptionist_24h`, dst.
3. Jalankan migration baru.
4. Verifikasi hitung baris: `SELECT COUNT(*) FROM hotels` vs `SELECT COUNT(*) FROM hotel_policies`.
5. Hapus kolom JSONB lama.

**Catatan:** Dokumentasi ini fokus pada schema baru. Data migration script harus ditulis terpisah
setelah schema baru berjalan.

---

## 5. Perencanaan Model Laravel

### 5.1 Daftar Model Baru & Yang Dipertahankan

#### Modul Property
| Model | Tabel | Jenis |
|-------|-------|-------|
| `App\Models\Property` | `properties` | Core model |
| `App\Models\PropertyMedia` | `property_media` | Baru |
| `App\Models\PropertyFacility` | `property_facilities` | Baru |
| `App\Models\PropertyPrice` | `property_prices` | Existing |
| `App\Models\PropertyPricingOption` | `property_pricing_options` | Baru |
| `App\Models\PropertySpecialPrice` | `property_special_prices` | Baru |
| `App\Models\PropertyAddOn` | `property_add_ons` | Baru |
| `App\Models\PropertyPaymentPlan` | `property_payment_plans` | Baru |
| `App\Models\PropertyPaymentPlanEntry` | `property_payment_plan_entries` | Baru |
| `App\Models\PropertyPromo` | `property_promos` | Baru |
| `App\Models\PropertyOtherCore` | `property_other_core` | Baru |
| `App\Models\PropertyExtraDescription` | `property_extra_descriptions` | Baru |
| `App\Models\PropertyReviewSummary` | `property_review_summaries` | Baru |
| `App\Models\PropertyReviewBreakdown` | `property_review_breakdowns` | Baru |
| `App\Models\PropertySpec` | `property_specs` | Baru |
| `App\Models\PropertyBedFacility` | `property_bed_facilities` | Baru |
| `App\Models\PropertyBuildingFacility` | `property_building_facilities` | Baru |
| `App\Models\PropertyBuildingFacilityAll` | `property_building_facilities_all` | Baru |
| `App\Models\PropertyRoomFurniture` | `property_room_furniture` | Baru |
| `App\Models\PropertyRoomFurnitureGroup` | `property_room_furniture_groups` | Baru |
| `App\Models\PropertyRoomFurnitureItem` | `property_room_furniture_items` | Baru |
| `App\Models\PropertyCheckInNote` | `property_check_in_notes` | Baru |
| `App\Models\PropertyDepositNote` | `property_deposit_notes` | Baru |
| `App\Models\PropertyUnitDetail` | `property_unit_details` | Baru |
| `App\Models\PropertyNearbyPlace` | `property_nearby_places` | Baru |
| `App\Models\PropertyGuestMedia` | `property_guest_media` | Baru |
| `App\Models\PropertyBuildingUnit` | `property_building_units` | Baru |
| `App\Models\PropertyQuestion` | `property_questions` | Existing |
| `App\Models\PropertyRecommendation` | `property_recommendations` | Existing |
| `App\Models\PropertySearchLog` | `property_search_logs` | Existing |

#### Modul Hotel
| Model | Tabel | Jenis |
|-------|-------|-------|
| `App\Models\Hotel` | `hotels` | recreate |
| `App\Models\HotelPolicy` | `hotel_policies` | Baru |
| `App\Models\HotelScoreComponent` | `hotel_score_components` | Baru |
| `App\Models\HotelFacilityGroup` | `hotel_facility_groups` | Baru |
| `App\Models\HotelFacility` | `hotel_facilities` | Baru |
| `App\Models\HotelTransportPoint` | `hotel_transport_points` | Baru |
| `App\Models\HotelFaq` | `hotel_faqs` | Baru |
| `App\Models\HotelReviewQuote` | `hotel_review_quotes` | Baru |
| `App\Models\RoomType` | `room_types` | recreate |
| `App\Models\RoomTypeFacility` | `room_type_facilities` | Baru |
| `App\Models\RoomTypeMedia` | `room_type_media` | Baru |
| `App\Models\RoomInventory` | `room_inventories` | Existing |

#### Master Data
| Model | Tabel | Jenis |
|-------|-------|-------|
| `App\Models\Facility` | `facilities` | Baru |
| `App\Models\User` | `users` | Existing |
| `App\Models\City` | `cities` | Existing |

### 5.2 Relasi Model (Konseptual)

```php
// Property.php
class Property extends Model
{
    public function host() { return $this->belongsTo(User::class); }
    public function city() { return $this->belongsTo(City::class); }
    public function media() { return $this->hasMany(PropertyMedia::class)->orderBy('sort_order'); }
    public function facilities() { return $this->hasMany(PropertyFacility::class); }
    public function prices() { return $this->hasMany(PropertyPrice::class); }
    public function pricingOptions() { return $this->hasMany(PropertyPricingOption::class); }
    public function specialPrices() { return $this->hasMany(PropertySpecialPrice::class); }
    public function addOns() { return $this->hasMany(PropertyAddOn::class); }
    public function paymentPlans() { return $this->hasMany(PropertyPaymentPlan::class); }
    public function promos() { return $this->hasMany(PropertyPromo::class); }
    public function other() { return $this->hasOne(PropertyOtherCore::class); }
    public function extraDescriptions() { return $this->hasMany(PropertyExtraDescription::class)->orderBy('sort_order'); }
    public function reviewSummary() { return $this->hasOne(PropertyReviewSummary::class); }
    public function reviewBreakdowns() { return $this->hasMany(PropertyReviewBreakdown::class); }
    public function specs() { return $this->hasMany(PropertySpec::class)->orderBy('sort_order'); }
    public function bedFacilities() { return $this->hasMany(PropertyBedFacility::class)->orderBy('sort_order'); }
    public function buildingFacilities() { return $this->hasMany(PropertyBuildingFacility::class)->orderBy('sort_order'); }
    public function buildingFacilitiesAll() { return $this->hasMany(PropertyBuildingFacilityAll::class)->orderBy('sort_order'); }
    public function roomFurniture() { return $this->hasMany(PropertyRoomFurniture::class)->orderBy('sort_order'); }
    public function roomFurnitureGroups() { return $this->hasMany(PropertyRoomFurnitureGroup::class)->orderBy('sort_order'); }
    public function checkInNotes() { return $this->hasMany(PropertyCheckInNote::class)->orderBy('sort_order'); }
    public function depositNotes() { return $this->hasMany(PropertyDepositNote::class)->orderBy('sort_order'); }
    public function unitDetails() { return $this->hasMany(PropertyUnitDetail::class)->orderBy('sort_order'); }
    public function nearbyPlaces() { return $this->hasMany(PropertyNearbyPlace::class)->orderBy('sort_order'); }
    public function guestMedia() { return $this->hasMany(PropertyGuestMedia::class)->orderBy('sort_order'); }
    public function buildingUnits() { return $this->hasMany(PropertyBuildingUnit::class)->orderBy('sort_order'); }
    public function questions() { return $this->hasMany(PropertyQuestion::class); }
    public function recommendations() { return $this->hasMany(PropertyRecommendation::class); }
    public function searchLogs() { return $this->hasMany(PropertySearchLog::class); }
    public function hotel() { return $this->hasOne(Hotel::class); }
    public function reviews() { return $this->hasMany(Review::class); }

    // Accessor untuk cover
    public function getCoverAttribute() { return $this->media->first()?->url; }
    public function getPriceFromAttribute() { ... }
}

// Hotel.php
class Hotel extends Model
{
    public function property() { return $this->belongsTo(Property::class); }
    public function policies() { return $this->hasOne(HotelPolicy::class); }
    public function scoreComponents() { return $this->hasMany(HotelScoreComponent::class); }
    public function facilityGroups() { return $this->hasMany(HotelFacilityGroup::class)->orderBy('sort_order'); }
    public function transportPoints() { return $this->hasMany(HotelTransportPoint::class)->orderBy('sort_order'); }
    public function faqs() { return $this->hasMany(HotelFaq::class)->orderBy('sort_order'); }
    public function reviewQuotes() { return $this->hasMany(HotelReviewQuote::class)->orderBy('sort_order'); }
    public function roomTypes() { return $this->hasMany(RoomType::class); }
    public function activeRoomTypes() { return $this->hasMany(RoomType::class)->where('is_active', true); }

    // Accessor untuk menyatukan policies menjadi array (compat dengan response lama)
    public function getPoliciesAttribute() { return $this->policies()->first()?->toArray() ?? []; }
    public function getScoreAttribute() { ... } // aggregate dari scoreComponents
    public function getFacilityGroupsAttribute() { ... } // reconstruct dari tabel relasi
    // dst.
}

// RoomType.php
class RoomType extends Model
{
    public function hotel() { return $this->belongsTo(Hotel::class); }
    public function facilities() { return $this->hasMany(RoomTypeFacility::class); }
    public function media() { return $this->hasMany(RoomTypeMedia::class)->orderBy('sort_order'); }
    public function inventories() { return $this->hasMany(RoomInventory::class); }

    public function getImagesAttribute() { return $this->media->pluck('url')->toArray(); }
    public function getFacilitiesAttribute() { return $this->facilities->pluck('name')->toArray(); }
}
```

### 5.3 Accessor, Mutator, dan Casts

**Penting:** Model harus tetap memproduksi format JSON yang sama seperti sebelumnya untuk menjaga
compatibility Flutter. Accessor akan merekonstruksi array/objek lama dari tabel relasional baru.

#### `Hotel.php` — Reconstructors
```php
protected $appends = ['price_from', 'price_original', 'overall_score', 'score_label', 'review_count'];

// Accessor policies: reconstruct dari hotel_policies
public function getPoliciesAttribute(): array
{
    $p = $this->policies()->first();
    if (!$p) return [];

    return [
        'receptionist_24h' => $p->receptionist_24h,
        'allow_children' => $p->allow_children,
        'extra_bed_available' => $p->extra_bed_available,
        'child_policy' => $p->child_policy,
        'extra_bed_policy' => $p->extra_bed_policy,
        'smoking_policy' => $p->smoking_policy,
        'deposit_amount' => (float) $p->deposit_amount,
        'deposit_currency' => $p->deposit_currency,
        'check_in_time' => $p->check_in_time ?? $this->check_in_time,
        'check_out_time' => $p->check_out_time ?? $this->check_out_time,
    ];
}

// Accessor score: reconstruct dari hotel_score_components
public function getScoreAttribute(): array
{
    $components = $this->scoreComponents()
        ->get()
        ->mapWithKeys(fn ($c) => [$c->component => (float) $c->score])
        ->toArray();

    return array_merge([
        'basic' => 0, 'cleanliness' => 0, 'service' => 0,
        'location' => 0, 'value' => 0, 'room' => 0,
    ], $components);
}

// Accessor facility_groups: reconstruct dari hotel_facility_groups + hotel_facilities
public function getFacilityGroupsAttribute(): array
{
    return $this->facilityGroups->map(fn ($g) => [
        'name' => $g->name,
        'items' => $g->facilities->map(fn ($f) => [
            'name' => $f->name,
            'is_available' => $f->is_available,
            'badge' => $f->badge,
        ])->toArray(),
    ])->toArray();
}

// Accessor transport_points, faqs, review_quotes: similar reconstruct
```

**Catatan:** Accessor ini dipakai untuk backward compatibility dengan response API lama.
Di controller baru, gunakan eager-load untuk menghindari N+1:
```php
$hotel->load('policies', 'scoreComponents', 'facilityGroups.facilities', 'transportPoints', 'faqs', 'reviewQuotes');
```

#### `Property.php` — Reconstructors
```php
// Accessor gallery (compat JSONB lama)
public function getGalleryAttribute(): array
{
    return $this->media->pluck('url')->toArray();
}

// Accessor facilities (compat JSONB lama)
public function getFacilitiesAttribute(): array
{
    return $this->facilities->pluck('name')->toArray();
}
```

---

## 6. Flow Data Baru

### 6.1 Write Flow (Flutter Form → Laravel API → Database)

```
┌─────────────┐     POST/PUT      ┌──────────────────┐     Transaction      ┌─────────────┐
│ Flutter Form │ ───────────────▶ │ Laravel Controller│ ──────────────────▶ │   Database   │
│ (multi-tab)  │                  │ (Validate + Auth)│                      │ (Relational) │
└─────────────┘                  └──────────────────┘                      └─────────────┘
       │                               │                                       │
       │ 1. Collect field per tab      │                                       │
       │    - Tab 1: basic info        │                                       │
       │    - Tab 2: location          │                                       │
       │    - Tab 3: pricing           │                                       │
       │    - Tab 4: facilities/media  │                                       │
       │    - Tab 5: display/other     │                                       │
       │                               │                                       │
       │ 2. Upload media files         │                                       │
       │    → storage/app/public/      │                                       │
       │                               │                                       │
       │ 3. Kirim payload JSON:        │                                       │
       │    {                          │                                       │
       │      property: { ... },       │                                       │
       │      media: [ {url, caption}],│                                       │
       │      facilities: [ ... ],     │                                       │
       │      prices: [ ... ],         │                                       │
       │      hotel: { ... },          │                                       │
       │      room_types: [ ... ]      │                                       │
       │    }                          │                                       │
       │                               │                                       │
       │                               │ 4. DB Transaction:                   │
       │                               │    a. upsert Property                │
       │                               │    b. sync PropertyMedia             │
       │                               │    c. sync PropertyFacilities        │
       │                               │    d. upsert PropertyPrices          │
       │                               │    e. if hotel: upsert Hotel         │
       │                               │    f. sync HotelPolicies, Scores,    │
       │                               │       FacilityGroups, Transport, etc.│
       │                               │    g. sync RoomTypes                 │
       │                               │    h. bulk insert RoomInventories    │
       │                               │       (30/90 hari)                   │
       │                               │    i. sync semua property_other_*    │
       │                               │                                       │
       │                               │ 5. Return JSON response              │
       │                               │    (reconstructed untuk Flutter)     │
       ▼                               ▼                                       ▼
```

**Catatan penting:**
- Flutter **tidak boleh** mengirim path lokal (`/data/user/0/...`). Flow upload harus:
  1. Flutter pilih file → upload multipart ke endpoint khusus (`POST /api/v1/host/upload`).
  2. Server kembalikan URL path yang disimpan.
  3. Flutter kirim URL tersebut di payload JSON.
- Room inventories untuk 30/90 hari ke depan dibuat otomatis oleh sistem setelah room type dibuat/diubah.

### 6.2 Read Flow (Database → Laravel API → Flutter)

```
┌─────────────┐   API Request    ┌──────────────────┐   Eager Load      ┌─────────────┐
│   Flutter   │ ───────────────▶ │ Laravel Controller│ ────────────────▶ │   Database   │
│  (Consumer) │                  │                  │                   │ (Relational) │
└─────────────┘                  └──────────────────┘                   └─────────────┘
       ▲                               │                                       │
       │                               │ 1. Load Property with:                │
       │                               │    - city, host                       │
       │                               │    - media (order by sort_order)      │
       │                               │    - facilities                       │
       │                               │    - prices                           │
       │                               │    - otherCore                        │
       │                               │    - extraDescriptions                │
       │                               │    - reviewSummary + breakdowns       │
       │                               │    - specs, bedFacilities, etc.       │
       │                               │    - questions, recommendations       │
       │                               │                                       │
       │                               │ 2. If hotel: load Hotel with:         │
       │                               │    - policies (1 row)                 │
       │                               │    - scoreComponents (6 rows)         │
       │                               │    - facilityGroups + facilities      │
       │                               │    - transportPoints                  │
       │                               │    - faqs                             │
       │                               │    - reviewQuotes                     │
       │                               │    - roomTypes + facilities + media   │
       │                               │      + inventories (jika ada dates)   │
       │                               │                                       │
       │                               │ 3. API Resource / Transformer:         │
       │                               │    - Reconstruct JSONB shape untuk    │
       │                               │      backward compat                  │
       │                               │    - Hitung derived fields:           │
       │                               │      cover, price_from, rating, etc.  │
       │                               │                                       │
       │                               │ 4. Return JSON                        │
       │                               │    {                                  │
       │                               │      id, name, ...,                   │
       │                               │      gallery: [media->url],           │
       │                               │      facilities: [facility->name],    │
       │                               │      hotel: {                         │
       │                               │        policies: { ... },             │
       │                               │        score: { ... },                │
       │                               │        facility_groups: [ ... ],      │
       │                               │        ...                            │
       │                               │      }                                │
       │                               │    }                                  │
       ▼                               ▼                                       ▼
```

### 6.3 API Contract (Response Shape Compatibility)

Response API **tidak berubah** dari perspektif Flutter. Perubahan terjadi di dalam controller
dan model (accessor), bukan di kontrak JSON.

| Endpoint | Method | Catatan |
|----------|--------|---------|
| `GET /api/v1/properties/{id}` | Public | PropertyResource mengembalikan JSON sama seperti sebelumnya. |
| `GET /api/v1/host/properties/{id}` | Host | HostPropertyResource mengembalikan JSON sama seperti sebelumnya. |
| `GET /api/v1/hotels/{id}` | Public | HotelResource mengembalikan JSON sama seperti sebelumnya. |
| `GET /api/v1/host/hotels/{id}` | Host | HostHotelResource mengembalikan JSON sama seperti sebelumnya. |
| `POST /api/v1/host/properties` | Host | Terima payload JSON baru (relational shape). |
| `PUT /api/v1/host/properties/{id}` | Host | Sama. |
| `POST /api/v1/host/hotels` | Host | Terima payload hotel + room_types. |
| `PUT /api/v1/host/hotels/{id}` | Host | Sama. |
| `POST /api/v1/host/room-types` | Host | Terima payload room_type. |
| `PUT /api/v1/host/room-types/{id}` | Host | Update room type + sync facilities/media. |
| `DELETE /api/v1/host/room-types/{id}` | Host | Hapus room type + cascade inventories. |

---

## 7. Dampak & Risiko

### 7.1 Dampak ke Flutter
- **Nol perubahan** pada model Flutter jika accessor Laravel menghasilkan JSON yang sama.
- Flutter tetap menerima `gallery: [...]`, `facilities: [...]`, `policies: {...}`, dst.
- Perubahan hanya terjadi di dalam `Hotel.php` / `Property.php` (accessor) dan Controller (eager-load).

### 7.2 Dampak ke API Konsumen Lain
- Jika ada konsumen API selain Flutter (web admin, partner), mereka juga tetap menerima JSON yang sama.
- **Risiko:** Jika ada konsumen yang memanggil Eloquent model langsung (bukan via API), mereka akan
  melihat perubahan struktur tabel. Dokumentasikan perubahan schema untuk tim lain.

### 7.3 Risiko Performa
- Property detail bisa memuat 15+ JOIN. **Mitigasi:**
  - Eager-load semua relasi di controller (tidak boleh lazy load).
  - Gunakan API Resource caching untuk response yang jarang berubah.
  - Pertimbangkan materialized view untuk listing pencarian jika butuh filter kompleks.

### 7.4 Risiko Data
- Penghapusan tabel berarti data lama hilang jika tidak dimigrasi.
- **Mitigasi:** Lakukan di staging dulu, backup produksi, buat data migration script sebelum drop tabel.

---

## 8. Checklist Pelaksanaan

### Fase 0: Persiapan
- [ ] Backup database (jika ada data yang harus dipertahankan).
- [ ] Pastikan semua test existing hijau.
- [ ] Komunikasi ke tim: schema akan berganti total, Flutter API contract tetap sama.

### Fase 1: Hapus Migration & Model Lama
- [ ] Hapus 15 migration file yang tercantum di §4.1.
- [ ] Hapus 13 model file yang tercantum di §4.1.

### Fase 2: Buat Migration Baru
- [ ] Buat migration `create_facilities_table`.
- [ ] Buat migration `create_properties_table` (struktur baru).
- [ ] Buat migration `create_property_media_table`.
- [ ] Buat migration `create_property_facilities_table`.
- [ ] Buat migration `create_property_prices_table` + unique index.
- [ ] Buat migration `create_property_pricing_options_table`.
- [ ] Buat migration `create_property_special_prices_table`.
- [ ] Buat migration `create_property_add_ons_table`.
- [ ] Buat migration `create_property_payment_plans_table`.
- [ ] Buat migration `create_property_payment_plan_entries_table`.
- [ ] Buat migration `create_property_promos_table`.
- [ ] Buat migration `create_property_other_core_table`.
- [ ] Buat migration `create_property_extra_descriptions_table`.
- [ ] Buat migration `create_property_review_summaries_table`.
- [ ] Buat migration `create_property_review_breakdowns_table`.
- [ ] Buat migration `create_property_specs_table`.
- [ ] Buat migration `create_property_bed_facilities_table`.
- [ ] Buat migration `create_property_building_facilities_table`.
- [ ] Buat migration `create_property_building_facilities_all_table`.
- [ ] Buat migration `create_property_room_furniture_table`.
- [ ] Buat migration `create_property_room_furniture_groups_table`.
- [ ] Buat migration `create_property_room_furniture_items_table`.
- [ ] Buat migration `create_property_check_in_notes_table`.
- [ ] Buat migration `create_property_deposit_notes_table`.
- [ ] Buat migration `create_property_unit_details_table`.
- [ ] Buat migration `create_property_nearby_places_table`.
- [ ] Buat migration `create_property_guest_media_table`.
- [ ] Buat migration `create_property_building_units_table`.
- [ ] Buat migration `create_property_questions_table`.
- [ ] Buat migration `create_property_recommendations_table`.
- [ ] Buat migration `create_property_search_logs_table`.
- [ ] Buat migration `create_hotels_table` (struktur baru).
- [ ] Buat migration `create_hotel_policies_table`.
- [ ] Buat migration `create_hotel_score_components_table`.
- [ ] Buat migration `create_hotel_facility_groups_table`.
- [ ] Buat migration `create_hotel_facilities_table`.
- [ ] Buat migration `create_hotel_transport_points_table`.
- [ ] Buat migration `create_hotel_faqs_table`.
- [ ] Buat migration `create_hotel_review_quotes_table`.
- [ ] Buat migration `create_room_types_table` (struktur baru).
- [ ] Buat migration `create_room_type_facilities_table`.
- [ ] Buat migration `create_room_type_media_table`.
- [ ] Buat migration `create_room_inventories_table` (struktur baru + index).

### Fase 3: Buat Model Baru
- [ ] `Facility` (master data).
- [ ] `PropertyMedia`, `PropertyFacility`, `PropertyPricingOption`, `PropertySpecialPrice`, dst. (lihat §5.1).
- [ ] `HotelPolicy`, `HotelScoreComponent`, `HotelFacilityGroup`, `HotelFacility`, dst. (lihat §5.1).
- [ ] `RoomTypeFacility`, `RoomTypeMedia`.

### Fase 4: Implementasi Relasi & Accessor
- [ ] Implementasikan relasi sesuai §5.2 di setiap model.
- [ ] Implementasikan accessor reconstructor JSON di `Hotel.php` dan `Property.php`.
- [ ] Pastikan semua controller memakai eager-load (`with()`) untuk menghindari N+1.

### Fase 5: Update Controller & Resource
- [ ] `PropertyController` / `PropertyResource`: load relasi baru, return JSON kompatibel.
- [ ] `HotelApiController` / `HotelResource`: load relasi baru, return JSON kompatibel.
- [ ] `HostHotelController`: handle create/update dengan tabel relasional.
- [ ] `WizardForm.php` (Livewire): sync semua tabel baru.

### Fase 6: Update Flutter
- [ ] `hotel_service.dart`: tambah `updateHotelForProperty`, `deleteRoomType`, `deleteHotel`.
- [ ] `hotel_form_screen.dart`: perbaiki loader edit, kirim `name`, `transport_points`, `status`.
- [ ] `property_form_screen.dart`: pastikan payload include semua field baru.
- [ ] `dummy_api_client.dart`: daftarkan endpoint baru.

### Fase 7: Testing & Verifikasi
- [ ] `php artisan migrate:fresh --seed` berjalan tanpa error.
- [ ] Semua feature test hijau.
- [ ] Flutter mode dummy & mode nyata menghasilkan UI identik.
- [ ] Verifikasi dengan checklist di §6.

---

## Lampiran: Pemetaan Field Lama → Baru

### Hotels
| JSONB Lama | Tabel Baru | Catatan |
|------------|------------|---------|
| `policies` | `hotel_policies` | 1 row per hotel |
| `score` | `hotel_score_components` | 6 rows per hotel |
| `facility_groups` | `hotel_facility_groups` + `hotel_facilities` | Group + items |
| `transport_points` | `hotel_transport_points` | Langsung |
| `faqs` | `hotel_faqs` | Langsung |
| `review_quotes` | `hotel_review_quotes` | Langsung |
| `room_types.facilities` | `room_type_facilities` | Langsung |
| `room_types.images` | `room_type_media` | Langsung |

### Properties
| JSONB Lama | Tabel Baru | Catatan |
|------------|------------|---------|
| `gallery` | `property_media` | + field `is_cover`, `sort_order` |
| `facilities` | `property_facilities` | + FK ke `facilities` |
| `properties_other` (semua) | 15 tabel baru | Lihat §2.2 |
| `duration_options` | `property_pricing_options` | Langsung |
| `special_prices` | `property_special_prices` | Langsung |
| `add_ons` | `property_add_ons` | Langsung |
| `payment_plans` + `entries` | `property_payment_plans` + `property_payment_plan_entries` | 1:N |
| `promo` | `property_promos` | Langsung |

---

*Dokumen ini dibuat sebagai panduan eksekusi untuk tim development. Semua perubahan harus
diverifikasi di staging sebelum di-apply ke produksi.*
