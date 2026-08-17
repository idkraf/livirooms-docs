# Refactor Arsitektur Database: Hotels & Properties
## Pendekatan Normalized & Polymorphic (Streamlined)

> **Dokumen:** Rencana refaktor arsitektur database yang lebih ramping.
> **Sumber:** `docs/perbaikan/restruktur_data_properti.md`
> **Tanggal:** 2026-08-18
> **Prinsip:** 1 tabel universal untuk media, 1 pivot polimorfik untuk fasilitas, core entities terpisah, display tables relasional tanpa JSONB.

---

## 1. Ringkasan Refactor

### 1.1 Perubahan Utama

| Aspek | Sebelum (34 tabel baru) | Sesudah (Streamlined) |
|-------|------------------------|----------------------|
| **Media** | `property_media`, `room_type_media`, `hotel_media` (3 tabel) | **1 tabel `media`** (polymorphic) |
| **Fasilitas** | `property_facilities`, `hotel_facility_groups`, `hotel_facilities`, `room_type_facilities` (4 tabel) | **1 master `facilities` + 1 pivot `model_has_facilities`** |
| **Display Properties** | 15+ tabel pecahan | Tetap relational, tapi lebih sedikit duplikasi |
| **JSONB** | Dihapus semuanya | Dihapus semuanya |
| **Total tabel baru** | 34 | **~24** (hemat 10 tabel) |

### 1.2 Tabel yang Dihapus/Diganti

| Tabel Lama | Diganti Dengan | Alasan |
|------------|----------------|--------|
| `property_media` | `media` (polymorphic) | Konsolidasi universal |
| `room_type_media` | `media` (polymorphic) | Konsolidasi universal |
| `hotel_facility_groups` | **Dihapus** | Tidak perlu lagi, gunakan `sort_order` di pivot |
| `hotel_facilities` | `model_has_facilities` | Polymorphic pivot |
| `property_facilities` | `model_has_facilities` | Polymorphic pivot |
| `room_type_facilities` | `model_has_facilities` | Polymorphic pivot |

---

## 2. Arsitektur Database Baru

### 2.1 Diagram Konseptual (Text ERD)

```
users (1) ────< (N) properties (1) ────< (N) media (polymorphic)
                  │                      (N) model_has_facilities (polymorphic)
                  │                      (N) property_prices
                  │                      (N) property_pricing_options
                  │                      (N) property_special_prices
                  │                      (N) property_add_ons
                  │                      (N) property_payment_plans ────< (N) property_payment_plan_entries
                  │                      (N) property_promos
                  │                      (1) property_other_core
                  │                      (N) property_extra_descriptions
                  │                      (1) property_review_summary ────< (N) property_review_breakdowns
                  │                      (N) property_specs
                  │                      (N) property_bed_facilities
                  │                      (N) property_building_facilities
                  │                      (N) property_building_facilities_all
                  │                      (N) property_room_furniture
                  │                      (N) property_room_furniture_groups ────< (N) property_room_furniture_items
                  │                      (N) property_check_in_notes
                  │                      (N) property_deposit_notes
                  │                      (N) property_unit_details
                  │                      (N) property_nearby_places
                  │                      (N) property_guest_media → diganti media
                  │                      (N) property_building_units
                  │                      (N) property_questions
                  │                      (N) property_recommendations
                  │                      (N) property_search_logs
                  │
                  │ (1) ────< (N) hotels
                  │                      (1) hotel_policy
                  │                      (N) hotel_score_components
                  │                      (N) hotel_transport_points
                  │                      (N) hotel_faqs
                  │                      (N) hotel_review_quotes
                  │                      (N) room_types
                  │                             (N) media (polymorphic)
                  │                             (N) model_has_facilities (polymorphic)
                  │                             (N) room_inventories
                  │
cities (1) ────< (N) properties
facilities (1) ────< (N) model_has_facilities
```

### 2.2 Tabel Inti

#### `properties` (Core Property)
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `host_id` | bigint | FK → users |
| `city_id` | bigint | FK → cities |
| `property_type` | enum | apartment, house, villa, hotel_residence, guest_house, exclusive_kost |
| `booking_mode` | enum | unit, room |
| `name` | varchar | |
| `building_name` | varchar | nullable |
| `description` | text | nullable |
| `address` | text | |
| `latitude` | decimal(10,7) | nullable |
| `longitude` | decimal(10,7) | nullable |
| `guest_capacity` | unsigned integer | default 1 |
| `bedrooms` | unsigned integer | default 1 |
| `bathrooms` | unsigned integer | nullable |
| `status` | enum | draft, active, inactive, maintenance, fully_booked |
| `cancellation_policy` | text | nullable |
| `created_at` / `updated_at` | timestamp | |

**Dihapus dari schema lama:** `gallery` (jsonb), `facilities` (jsonb)

#### `hotels` (Core Hotel)
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK unique → properties |
| `star_rating` | unsigned tinyint | 1-5 |
| `check_in_time` | time | default 14:00 |
| `check_out_time` | time | default 12:00 |
| `open_year` | unsigned smallint | nullable |
| `deposit_amount` | decimal(12,2) | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Dihapus dari schema lama:** `policies` (jsonb), `score` (jsonb), `facility_groups` (jsonb), `transport_points` (jsonb), `faqs` (jsonb), `review_quotes` (jsonb)

#### `room_types`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → hotels |
| `name` | varchar | |
| `slug` | varchar | |
| `description` | text | nullable |
| `capacity_adults` | unsigned integer | default 2 |
| `capacity_children` | unsigned integer | default 1 |
| `max_guests` | unsigned integer | default 3 |
| `room_size_sqm` | unsigned integer | nullable |
| `bed_configuration` | varchar | nullable |
| `base_price` | decimal(12,2) | |
| `price_original` | decimal(12,2) | nullable |
| `breakfast_included` | boolean | default false |
| `total_inventory` | unsigned integer | default 1 |
| `has_window` | boolean | default false |
| `no_smoking` | boolean | default false |
| `free_wifi` | boolean | default true |
| `is_active` | boolean | default true |
| `created_at` / `updated_at` | timestamp | |

**Dihapus dari schema lama:** `facilities` (jsonb), `images` (jsonb)

#### `room_inventories`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `room_type_id` | bigint | FK → room_types |
| `date` | date | |
| `allotment` | unsigned integer | default 1 |
| `booked_count` | unsigned integer | default 0 |
| `price` | decimal(12,2) | |
| `is_closed` | boolean | default false |
| `min_stay` | unsigned integer | default 1 |
| `max_stay` | unsigned integer | nullable |
| `created_at` / `updated_at` | timestamp | |

**Unique:** `(room_type_id, date)`
**Check constraint (PostgreSQL):** `booked_count <= allotment`

### 2.3 Tabel Polymorphic

#### `media` (Universal Media)
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `model_type` | varchar | Misal: `App\Models\Property`, `App\Models\RoomType` |
| `model_id` | bigint | |
| `url` | varchar | Path/URL media |
| `caption` | varchar | nullable |
| `is_cover` | boolean | default false |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(model_type, model_id, sort_order)`

**Catatan:**
- Menggantikan `property_media`, `room_type_media`, dan media lain.
- `is_cover` menentukan gambar utama. Untuk property: `gallery[0]` adalah cover.
- `model_type` disimpan sebagai string class name (standar Laravel polymorphic).

#### `facilities` (Master Data)
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `name` | varchar | Nama fasilitas |
| `icon` | varchar | nullable |
| `category` | enum | property, room, building |
| `is_active` | boolean | default true |
| `created_at` / `updated_at` | timestamp | |

#### `model_has_facilities` (Polymorphic Pivot)
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `facility_id` | bigint | FK → facilities |
| `model_type` | varchar | App\Models\Property, App\Models\Hotel, App\Models\RoomType |
| `model_id` | bigint | |
| `is_available` | boolean | default true |
| `badge` | varchar | nullable, misal: "Baru", "Premium" |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Unique:** `(facility_id, model_type, model_id)`
**Index:** `(model_type, model_id, sort_order)`

**Catatan:**
- Menggantikan `property_facilities`, `hotel_facilities`, `room_type_facilities`, dan `hotel_facility_groups`.
- `badge` nullable untuk compatibility dengan property/hotel yang punya badge.
- `sort_order` menggantikan kebutuhan `hotel_facility_groups` untuk urutan tampil.

### 2.4 Tabel Hotel Module (Relasional)

#### `hotel_policies`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK unique → hotels |
| `receptionist_24h` | boolean | default false |
| `allow_children` | boolean | default false |
| `extra_bed_available` | boolean | default false |
| `child_policy` | text | nullable |
| `extra_bed_policy` | text | nullable |
| `smoking_policy` | text | nullable |
| `deposit_amount` | decimal(12,2) | nullable |
| `deposit_currency` | varchar(3) | nullable, ISO 4217 |
| `created_at` / `updated_at` | timestamp | |

#### `hotel_score_components`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → hotels |
| `component` | enum | basic, reward, inventory, content, review, rate_competitiveness |
| `score` | decimal(3,2) | 0-5 |
| `created_at` / `updated_at` | timestamp | |

**Unique:** `(hotel_id, component)`

#### `hotel_transport_points`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → hotels |
| `name` | varchar | |
| `type` | varchar | train, metro, bus, airport, mall, attraction |
| `distance` | varchar | Misal: "2.1 km" |
| `duration` | varchar | Misal: "8 mnt berkendara" |
| `icon` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(hotel_id, sort_order)`

#### `hotel_faqs`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → hotels |
| `question` | text | |
| `answer` | text | nullable |
| `author_name` | varchar | nullable |
| `author_role` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(hotel_id, sort_order)`

#### `hotel_review_quotes`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `hotel_id` | bigint | FK → hotels |
| `quote` | text | |
| `author_name` | varchar | nullable |
| `author_role` | varchar | nullable |
| `rating` | unsigned integer | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(hotel_id, sort_order)`

### 2.5 Tabel Property Module (Relasional)

#### `property_prices` (Existing - dipertahankan)
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `price_type` | enum | daily, weekly, monthly, yearly |
| `amount` | decimal(15,2) | |
| `cleaning_fee` | decimal(15,2) | nullable |
| `deposit` | decimal(15,2) | nullable |
| `service_fee` | decimal(15,2) | nullable |
| `extra_guest_fee` | decimal(15,2) | nullable |
| `created_at` / `updated_at` | timestamp | |

**Unique:** `(property_id, price_type)`

#### `property_pricing_options`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `nights` | unsigned integer | Jumlah malam |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Unique:** `(property_id, nights)`

#### `property_special_prices`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `min_nights` | unsigned integer | |
| `discount_percent` | unsigned integer | 0-100 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, min_nights)`

#### `property_add_ons`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `name` | varchar | |
| `duration_note` | varchar | nullable |
| `price` | decimal(15,2) | |
| `info` | text | nullable |
| `is_selected` | boolean | default false |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_payment_plans`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `name` | varchar | |
| `cadence` | varchar | nullable, misal: monthly, weekly |
| `installments` | unsigned integer | |
| `total` | decimal(15,2) | |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_payment_plan_entries`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_payment_plan_id` | bigint | FK → property_payment_plans |
| `date` | date | |
| `amount` | decimal(15,2) | |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_payment_plan_id, date)`

#### `property_promos`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `code` | varchar | nullable |
| `discount_type` | varchar | nullable, percent/fixed |
| `discount_value` | decimal(15,2) | nullable |
| `valid_from` | date | nullable |
| `valid_until` | date | nullable |
| `is_active` | boolean | default true |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, is_active)`

#### `property_other_core`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK unique → properties |
| `province` | varchar | nullable |
| `price_from` | decimal(15,2) | nullable |
| `rating` | decimal(3,2) | nullable |
| `review_count` | unsigned integer | default 0 |
| `star_rating` | unsigned tinyint | nullable |
| `check_in_time` | time | nullable |
| `check_out_time` | time | nullable |
| `has_breakfast` | boolean | default false |
| `type_label` | varchar | nullable |
| `area_label` | varchar | nullable |
| `extra_media_count` | unsigned integer | default 0 |
| `intro` | text | nullable |
| `description_extra_heading` | varchar | nullable |
| `map_preview` | varchar | nullable |
| `price_caption` | varchar | default 'per bulan mulai dari' |
| `is_flash_sale` | boolean | default false |
| `deposit_amount` | decimal(15,2) | nullable |
| `schedule_note` | text | nullable |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id)`

#### `property_extra_descriptions`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `text` | text | |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_review_summaries`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK unique → properties |
| `average` | decimal(3,2) | nullable |
| `total` | unsigned integer | default 0 |
| `label` | varchar | nullable |
| `created_at` / `updated_at` | timestamp | |

#### `property_review_breakdowns`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_review_summary_id` | bigint | FK → property_review_summaries |
| `rating` | unsigned integer | 1-5 |
| `count` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_review_summary_id, rating)`

#### `property_specs`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `label` | varchar | |
| `value` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_bed_facilities`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `label` | varchar | |
| `note` | varchar | nullable |
| `count` | unsigned integer | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_building_facilities`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `label` | varchar | |
| `is_highlighted` | boolean | default false |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_building_facilities_all`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `name` | varchar | |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_room_furniture`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `label` | varchar | |
| `count` | unsigned integer | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_room_furniture_groups`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `name` | varchar | |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_room_furniture_items`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_room_furniture_group_id` | bigint | FK → property_room_furniture_groups |
| `icon` | varchar | nullable |
| `label` | varchar | |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_room_furniture_group_id, sort_order)`

#### `property_check_in_notes`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `title` | varchar | nullable |
| `text` | text | |
| `tone` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_deposit_notes`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `title` | varchar | nullable |
| `text` | text | |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_unit_details`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `icon` | varchar | nullable |
| `label` | varchar | |
| `value` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_nearby_places`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `name` | varchar | |
| `type` | varchar | nullable |
| `distance` | varchar | nullable |
| `icon` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

#### `property_building_units`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigint | PK |
| `property_id` | bigint | FK → properties |
| `type` | varchar | nullable |
| `count` | unsigned integer | nullable |
| `icon` | varchar | nullable |
| `sort_order` | unsigned integer | default 0 |
| `created_at` / `updated_at` | timestamp | |

**Index:** `(property_id, sort_order)`

### 2.6 Tabel Transaksional (Existing - dipertahankan)

| Tabel | Keterangan |
|-------|------------|
| `property_questions` | Q&A properti |
| `property_recommendations` | Rekomendasi properti |
| `property_search_logs` | Log pencarian (filters tetap jsonb) |

---

## 3. Migration & Model Planning

### 3.1 Daftar Migration Baru

#### A. Core & Polymorphic
| No | File Migration | Tabel |
|----|----------------|-------|
| 1 | `2026_08_18_000001_create_facilities_table.php` | `facilities` |
| 2 | `2026_08_18_000002_create_media_table.php` | `media` |
| 3 | `2026_08_18_000003_create_model_has_facilities_table.php` | `model_has_facilities` |

#### B. Property Module
| No | File Migration | Tabel |
|----|----------------|-------|
| 4 | `2026_08_18_000004_create_property_pricing_options_table.php` | `property_pricing_options` |
| 5 | `2026_08_18_000005_create_property_special_prices_table.php` | `property_special_prices` |
| 6 | `2026_08_18_000006_create_property_add_ons_table.php` | `property_add_ons` |
| 7 | `2026_08_18_000007_create_property_payment_plans_table.php` | `property_payment_plans` |
| 8 | `2026_08_18_000008_create_property_payment_plan_entries_table.php` | `property_payment_plan_entries` |
| 9 | `2026_08_18_000009_create_property_promos_table.php` | `property_promos` |
| 10 | `2026_08_18_000010_create_property_other_core_table.php` | `property_other_core` |
| 11 | `2026_08_18_000011_create_property_extra_descriptions_table.php` | `property_extra_descriptions` |
| 12 | `2026_08_18_000012_create_property_review_summaries_table.php` | `property_review_summaries` |
| 13 | `2026_08_18_000012_create_property_review_breakdowns_table.php` | `property_review_breakdowns` |
| 14 | `2026_08_18_000013_create_property_specs_table.php` | `property_specs` |
| 15 | `2026_08_18_000014_create_property_bed_facilities_table.php` | `property_bed_facilities` |
| 16 | `2026_08_18_000015_create_property_building_facilities_table.php` | `property_building_facilities` |
| 17 | `2026_08_18_000016_create_property_building_facilities_all_table.php` | `property_building_facilities_all` |
| 18 | `2026_08_18_000017_create_property_room_furniture_table.php` | `property_room_furniture` |
| 19 | `2026_08_18_000018_create_property_room_furniture_groups_table.php` | `property_room_furniture_groups` |
| 20 | `2026_08_18_000019_create_property_room_furniture_items_table.php` | `property_room_furniture_items` |
| 21 | `2026_08_18_000020_create_property_check_in_notes_table.php` | `property_check_in_notes` |
| 22 | `2026_08_18_000021_create_property_deposit_notes_table.php` | `property_deposit_notes` |
| 23 | `2026_08_18_000022_create_property_unit_details_table.php` | `property_unit_details` |
| 24 | `2026_08_18_000023_create_property_nearby_places_table.php` | `property_nearby_places` |
| 25 | `2026_08_18_000025_create_property_building_units_table.php` | `property_building_units` |

#### C. Hotel Module
| No | File Migration | Tabel |
|----|----------------|-------|
| 26 | `2026_08_18_000026_create_hotel_policies_table.php` | `hotel_policies` |
| 27 | `2026_08_18_000027_create_hotel_score_components_table.php` | `hotel_score_components` |
| 28 | `2026_08_18_000030_create_hotel_transport_points_table.php` | `hotel_transport_points` |
| 29 | `2026_08_18_000031_create_hotel_faqs_table.php` | `hotel_faqs` |
| 30 | `2026_08_18_000032_create_hotel_review_quotes_table.php` | `hotel_review_quotes` |

### 3.2 Model Laravel

#### Property Module Models

```php
// Property.php
class Property extends Model
{
    public function host(): BelongsTo { return $this->belongsTo(User::class); }
    public function city(): BelongsTo { return $this->belongsTo(City::class); }
    public function media(): MorphMany { return $this->morphMany(Media::class, 'model')->orderBy('sort_order'); }
    public function facilities(): MorphToMany { return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')->withPivot('is_available', 'badge', 'sort_order')->orderBy('sort_order'); }
    public function prices(): HasMany { return $this->hasMany(PropertyPrice::class); }
    public function pricingOptions(): HasMany { return $this->hasMany(PropertyPricingOption::class)->orderBy('sort_order'); }
    public function specialPrices(): HasMany { return $this->hasMany(PropertySpecialPrice::class); }
    public function addOns(): HasMany { return $this->hasMany(PropertyAddOn::class)->orderBy('sort_order'); }
    public function paymentPlans(): HasMany { return $this->hasMany(PropertyPaymentPlan::class); }
    public function promos(): HasMany { return $this->hasMany(PropertyPromo::class); }
    public function other(): HasOne { return $this->hasOne(PropertyOtherCore::class); }
    public function extraDescriptions(): HasMany { return $this->hasMany(PropertyExtraDescription::class)->orderBy('sort_order'); }
    public function reviewSummary(): HasOne { return $this->hasOne(PropertyReviewSummary::class); }
    public function specs(): HasMany { return $this->hasMany(PropertySpec::class)->orderBy('sort_order'); }
    public function bedFacilities(): HasMany { return $this->hasMany(PropertyBedFacility::class)->orderBy('sort_order'); }
    public function buildingFacilities(): HasMany { return $this->hasMany(PropertyBuildingFacility::class)->orderBy('sort_order'); }
    public function buildingFacilitiesAll(): HasMany { return $this->hasMany(PropertyBuildingFacilityAll::class)->orderBy('sort_order'); }
    public function roomFurniture(): HasMany { return $this->hasMany(PropertyRoomFurniture::class)->orderBy('sort_order'); }
    public function roomFurnitureGroups(): HasMany { return $this->hasMany(PropertyRoomFurnitureGroup::class)->orderBy('sort_order'); }
    public function checkInNotes(): HasMany { return $this->hasMany(PropertyCheckInNote::class)->orderBy('sort_order'); }
    public function depositNotes(): HasMany { return $this->hasMany(PropertyDepositNote::class)->orderBy('sort_order'); }
    public function unitDetails(): HasMany { return $this->hasMany(PropertyUnitDetail::class)->orderBy('sort_order'); }
    public function nearbyPlaces(): HasMany { return $this->hasMany(PropertyNearbyPlace::class)->orderBy('sort_order'); }
    public function guestMedia(): MorphMany { return $this->morphMany(Media::class, 'model'); }
    public function buildingUnits(): HasMany { return $this->hasMany(PropertyBuildingUnit::class)->orderBy('sort_order'); }
    public function questions(): HasMany { return $this->hasMany(PropertyQuestion::class); }
    public function recommendations(): HasMany { return $this->hasMany(PropertyRecommendation::class); }
    public function searchLogs(): HasMany { return $this->hasMany(PropertySearchLog::class); }
    public function hotel(): HasOne { return $this->hasOne(Hotel::class); }
    public function reviews(): HasMany { return $this->hasMany(Review::class); }
    public function cover(): ?string { return $this->media->first()?->url; }
}

// PropertyOtherCore.php
class PropertyOtherCore extends Model
{
    protected $table = 'property_other_core';
    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
}

// PropertyReviewSummary.php
class PropertyReviewSummary extends Model
{
    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
    public function breakdowns(): HasMany { return $this->hasMany(PropertyReviewBreakdown::class); }
}

// PropertyReviewBreakdown.php
class PropertyReviewBreakdown extends Model
{
    public function reviewSummary(): BelongsTo { return $this->belongsTo(PropertyReviewSummary::class); }
}

// PropertyRoomFurnitureGroup.php
class PropertyRoomFurnitureGroup extends Model
{
    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
    public function items(): HasMany { return $this->hasMany(PropertyRoomFurnitureItem::class); }
}
```

#### Hotel Module Models

```php
// Hotel.php
class Hotel extends Model
{
    protected $table = 'hotels';
    public function property(): BelongsTo { return $this->belongsTo(Property::class); }
    public function policy(): HasOne { return $this->hasOne(HotelPolicy::class); }
    public function scoreComponents(): HasMany { return $this->hasMany(HotelScoreComponent::class); }
    public function transportPoints(): HasMany { return $this->hasMany(HotelTransportPoint::class)->orderBy('sort_order'); }
    public function faqs(): HasMany { return $this->hasMany(HotelFaq::class)->orderBy('sort_order'); }
    public function reviewQuotes(): HasMany { return $this->hasMany(HotelReviewQuote::class)->orderBy('sort_order'); }
    public function roomTypes(): HasMany { return $this->hasMany(RoomType::class); }
    public function activeRoomTypes(): HasMany { return $this->hasMany(RoomType::class)->where('is_active', true); }
    public function media(): MorphMany { return $this->morphMany(Media::class, 'model')->orderBy('sort_order'); }
    public function facilities(): MorphToMany { return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')->withPivot('is_available', 'badge', 'sort_order')->orderBy('sort_order'); }
    
    public function getPriceFromAttribute(): ?float {
        $cheapest = $this->activeRoomTypes()->orderBy('base_price')->first();
        return $cheapest ? (float) $cheapest->base_price : null;
    }
    
    public function getPriceOriginalAttribute(): ?float {
        $cheapest = $this->activeRoomTypes()->first();
        return $cheapest?->price_original ? (float) $cheapest->price_original : null;
    }
    
    public function getOverallScoreAttribute(): ?float {
        if (empty($this->score)) return null;
        return $this->score['basic'] ?? null;
    }
}

// HotelPolicy.php
class HotelPolicy extends Model
{
    protected $table = 'hotel_policies';
    protected $casts = ['receptionist_24h' => 'boolean', 'allow_children' => 'boolean', 'extra_bed_available' => 'boolean'];
    public function hotel(): BelongsTo { return $this->belongsTo(Hotel::class); }
}

// HotelScoreComponent.php
class HotelScoreComponent extends Model
{
    protected $table = 'hotel_score_components';
    public function hotel(): BelongsTo { return $this->belongsTo(Hotel::class); }
}

// HotelTransportPoint.php
class HotelTransportPoint extends Model
{
    protected $table = 'hotel_transport_points';
    public function hotel(): BelongsTo { return $this->belongsTo(Hotel::class); }
}

// HotelFaq.php
class HotelFaq extends Model
{
    protected $table = 'hotel_faqs';
    public function hotel(): BelongsTo { return $this->belongsTo(Hotel::class); }
}

// HotelReviewQuote.php
class HotelReviewQuote extends Model
{
    protected $table = 'hotel_review_quotes';
    public function hotel(): BelongsTo { return $this->belongsTo(Hotel::class); }
}
```

#### RoomType Model

```php
// RoomType.php
class RoomType extends Model
{
    protected $table = 'room_types';
    public function hotel(): BelongsTo { return $this->belongsTo(Hotel::class); }
    public function facilities(): MorphToMany { return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')->withPivot('is_available', 'sort_order')->orderBy('sort_order'); }
    public function media(): MorphMany { return $this->morphMany(Media::class, 'model')->orderBy('sort_order'); }
    public function inventories(): HasMany { return $this->hasMany(RoomInventory::class); }
    
    public function scopeAvailableForDates(Builder $query, string $checkIn, string $checkOut, int $requiredRooms = 1): Builder {
        $dates = generateDateRange($checkIn, $checkOut);
        $nightsCount = count($dates);
        return $query->whereHas('inventories', function (Builder $q) use ($dates, $requiredRooms) {
            $q->whereIn('date', $dates)->where('is_closed', false)->whereRaw('(allotment - booked_count) >= ?', [$requiredRooms]);
        }, '=', $nightsCount);
    }
    
    public function getImagesAttribute(): array {
        return $this->media->pluck('url')->toArray();
    }
    
    public function getFacilitiesAttribute(): array {
        return $this->facilities->pluck('name')->toArray();
    }
}
```

#### Polymorphic Models

```php
// Media.php
class Media extends Model
{
    protected $fillable = ['model_type', 'model_id', 'url', 'caption', 'is_cover', 'sort_order'];
    protected $casts = ['is_cover' => 'boolean'];
    
    public function model(): MorphTo { return $this->morphTo(); }
}

// Facility.php
class Facility extends Model
{
    protected $fillable = ['name', 'icon', 'category', 'is_active'];
    protected $casts = ['is_active' => 'boolean'];
}

// ModelHasFacility.php
class ModelHasFacility extends Model
{
    protected $table = 'model_has_facilities';
    public $timestamps = true;
    protected $fillable = ['facility_id', 'model_type', 'model_id', 'is_available', 'badge', 'sort_order'];
    protected $casts = ['is_available' => 'boolean'];
    
    public function facility(): BelongsTo { return $this->belongsTo(Facility::class); }
    public function model(): MorphTo { return $this->morphTo(); }
}
```

---

## 4. Relasi Eloquent - Detail

### 4.1 Property Relations

```php
// Property.php
public function media(): MorphMany {
    return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
}

public function facilities(): MorphToMany {
    return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
        ->withPivot('is_available', 'badge', 'sort_order')
        ->orderBy('sort_order');
}

public function cover(): ?string {
    return $this->media->first()?->url;
}

public function gallery(): array {
    return $this->media->pluck('url')->toArray();
}
```

### 4.2 Hotel Relations

```php
// Hotel.php
public function media(): MorphMany {
    return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
}

public function facilities(): MorphToMany {
    return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
        ->withPivot('is_available', 'badge', 'sort_order')
        ->orderBy('sort_order');
}

public function policy(): HasOne {
    return $this->hasOne(HotelPolicy::class);
}

public function scoreComponents(): HasMany {
    return $this->hasMany(HotelScoreComponent::class);
}

public function transportPoints(): HasMany {
    return $this->hasMany(HotelTransportPoint::class)->orderBy('sort_order');
}

public function faqs(): HasMany {
    return $this->hasMany(HotelFaq::class)->orderBy('sort_order');
}

public function reviewQuotes(): HasMany {
    return $this->hasMany(HotelReviewQuote::class)->orderBy('sort_order');
}
```

### 4.3 RoomType Relations

```php
// RoomType.php
public function media(): MorphMany {
    return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
}

public function facilities(): MorphToMany {
    return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
        ->withPivot('is_available', 'sort_order')
        ->orderBy('sort_order');
}

public function inventories(): HasMany {
    return $this->hasMany(RoomInventory::class);
}
```

---

## 5. Sample Data - Exact Values from Existing Seeders

### 5.1 Property Media (from PropertySeeder + PropertiesOtherSeeder)

```php
// PropertyMediaSeeder
$mediaMap = [
    'Peaceful Living in Spacious 3BR at Apartment Lucky Tower Residence By Travelio' => [
        'properties/gallery/peaceful-3br-1.jpg',
        'properties/gallery/peaceful-3br-2.jpg',
    ],
    'Big and Cozy 3BR Apartment Lucky Tower Residence By Travelio' => [
        'properties/gallery/big-3br-1.jpg',
        'properties/gallery/big-3br-2.jpg',
    ],
    'Fabulous 2BR Apartment Lucky Tower Residence By Travelio' => [
        'properties/gallery/fabulous-2br-1.jpg',
        'properties/gallery/fabulous-2br-2.jpg',
    ],
    'Modern Look 2BR at Lucky Tower Residence Apartment By Travelio' => [
        'properties/gallery/modern-2br-1.jpg',
        'properties/gallery/modern-2br-2.jpg',
    ],
    'Sunset Beach Apartment' => [
        'https://example.com/gallery1/1.jpg',
    ],
    'Merlynn Park Hotel' => [
        'hotels/gallery/merlynn_1.jpg',
        'hotels/gallery/merlynn_2.jpg',
        'hotels/gallery/merlynn_3.jpg',
        'hotels/gallery/merlynn_4.jpg',
        'hotels/gallery/merlynn_5.jpg',
    ],
    // ... Grand Cemara, YELLO, Artotel, MaxOne
];
```

### 5.2 Facilities (from HotelSeeder + PropertySeeder)

```php
// PropertyFacilitySeeder (via model_has_facilities)
$facilitiesMap = [
    'Peaceful Living in Spacious 3BR...' => [
        'wifi', 'ac', 'kitchen', 'parking', 'swimming_pool', 'tv', 'washing_machine', 'security', 'elevator',
    ],
    'Merlynn Park Hotel' => [
        'Kolam Renang Infinity', 'Kolam Renang Anak', 'Pusat Kebugaran / Gym',
        'Spa & Sauna', 'Restoran Internasional', 'Bar Lobi & Lounge',
        'Wi-Fi Gratis di Semua Area', 'Resepsionis 24 Jam', 'Area Parkir Gratis',
        'Bathtub di Setiap Kamar', 'Layanan Kamar 24 Jam', 'Antar-Jemput Bandara',
    ],
    // ... Grand Cemara, YELLO, Artotel, MaxOne
];
```

### 5.3 Hotel Policies (from HotelSeeder)

```php
// HotelPolicySeeder
$policies = [
    'Merlynn Park Hotel' => [
        'receptionist_24h' => true,
        'allow_children' => true,
        'extra_bed_available' => true,
        'child_policy' => 'Anak usia 0-5 tahun menginap gratis jika menggunakan tempat tidur yang ada.',
        'smoking_policy' => 'Semua kamar adalah bebas rokok (Non-Smoking). Area khusus merokok tersedia.',
        'deposit_amount' => 500000,
        'deposit_currency' => 'IDR',
    ],
    'Grand Cemara Hotel' => [
        'receptionist_24h' => true,
        'allow_children' => true,
        'extra_bed_available' => true,
        'deposit_amount' => 100000,
        'deposit_currency' => 'IDR',
    ],
    // ... YELLO, Artotel, MaxOne
];
```

### 5.4 Hotel Score Components (from HotelSeeder)

```php
// HotelScoreComponentSeeder
$scores = [
    'Merlynn Park Hotel' => [
        ['component' => 'basic', 'score' => 4.8],
        ['component' => 'reward', 'score' => 0.5],
        ['component' => 'inventory', 'score' => 4.7],
        ['component' => 'content', 'score' => 5.0],
        ['component' => 'review', 'score' => 4.8],
        ['component' => 'rate_competitiveness', 'score' => 4.6],
    ],
    // ... Grand Cemara, YELLO, Artotel, MaxOne
];
```

### 5.5 Hotel Transport Points (from HotelSeeder)

```php
// HotelTransportPointSeeder
$points = [
    'Merlynn Park Hotel' => [
        ['name' => 'Stasiun Gambir', 'type' => 'train', 'distance' => '2.1 km', 'duration' => '8 mnt berkendara', 'icon' => 'train'],
        ['name' => 'Stasiun Juanda', 'type' => 'train', 'distance' => '1.8 km', 'duration' => '6 mnt berkendara', 'icon' => 'train'],
        ['name' => 'Halte TransJakarta Petojo', 'type' => 'bus', 'distance' => '350 m', 'duration' => '4 mnt jalan kaki', 'icon' => 'bus'],
        ['name' => 'Monumen Nasional (Monas)', 'type' => 'attraction', 'distance' => '1.9 km', 'duration' => '7 mnt berkendara', 'icon' => 'map-pin'],
        ['name' => 'Bandara Internasional Soekarno-Hatta (CGK)', 'type' => 'airport', 'distance' => '23.4 km', 'duration' => '30 mnt via Tol', 'icon' => 'plane'],
    ],
    // ... Grand Cemara, YELLO, Artotel, MaxOne
];
```

### 5.6 Hotel FAQs (from HotelSeeder)

```php
// HotelFaqSeeder
$faqs = [
    'Merlynn Park Hotel' => [
        ['question' => 'Berapa jarak Merlynn Park Hotel ke Monas?', 'answer' => 'Merlynn Park Hotel berjarak sekitar 1,9 km dari Monas.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
        ['question' => 'Apakah sarapan tersedia di hotel?', 'answer' => 'Ya, sarapan prasmanan disajikan di Grand Central Restaurant.', 'author_name' => 'Manager akomodasi', 'author_role' => 'Staff Hotel'],
        // ...
    ],
    // ... Grand Cemara, YELLO, Artotel, MaxOne
];
```

### 5.7 Hotel Review Quotes (from HotelSeeder)

```php
// HotelReviewQuoteSeeder
$quotes = [
    'Merlynn Park Hotel' => [
        ['quote' => 'Kamarnya sangat luas, bersih, dan bathtub-nya sangat nyaman.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
        ['quote' => 'Pilihan menu sarapan sangat bervariasi dan lezat. Pelayanan staf sangat ramah.', 'author_name' => 'Tamu', 'author_role' => 'Domestic', 'rating' => 5],
        // ...
    ],
    // ... Grand Cemara, YELLO, Artotel, MaxOne
];
```

---

## 6. Strategi Migrasi

### 6.1 Tahap Persiapan
1. **Backup database** produksi/staging.
2. Buat migration baru untuk semua tabel di atas.
3. Buat model baru dengan relasi polymorphic.

### 6.2 Tahap Data Migration
1. **Insert master facilities** dari data existing.
2. **Migrate media** dari `properties.gallery` dan `room_types.images` ke tabel `media`.
3. **Migrate facilities** dari `properties.facilities`, `hotels.facility_groups`, `room_types.facilities` ke `model_has_facilities`.
4. **Migrate hotel metadata** dari JSONB ke tabel relasional.
5. **Migrate properties_other** ke tabel-tabel pecahan.

### 6.3 Tahap Cleanup
1. Drop kolom JSONB lama (`gallery`, `facilities`, `policies`, `score`, `facility_groups`, `transport_points`, `faqs`, `review_quotes`, `images`, `facilities` di room_types).
2. Drop tabel `properties_other`.
3. Update controller & resource untuk menggunakan relasi baru.

---

## 7. Keuntungan Pendekatan Ini

1. **Media universal:** 1 tabel untuk semua model (Property, Hotel, RoomType, dst). Mudah di-maintain.
2. **Fasilitas terpusat:** 1 master table + 1 pivot polimorfik. Konsistensi nama fasilitas terjaga.
3. **Query lebih cepat:** Tidak ada JSONB parsing. Semua data bisa di-filter dengan SQL standar.
4. **Eager-loading jelas:** Relasi Eloquent eksplisit, tidak ada N+1 query.
5. **Backward compatible:** Accessor di model bisa merekonstruksi JSON shape lama untuk Flutter.

---

## 8. Catatan Implementasi

- **Booking & Payment system tidak disentuh** sesuai instruksi.
- Semua `sort_order` ditambahkan agar urutan tampil di Flutter tetap terjaga.
- `model_type` di tabel polymorphic disimpan sebagai full class name (`App\Models\Property`).
- Untuk backward compatibility, model bisa menambahkan accessor yang merekonstruksi JSONB shape lama jika diperlukan oleh API response yang sudah ada.
