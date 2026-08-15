# Laravel Hotel OTA — Implementation Guide & Audit

Dokumen ini menganalisis layar dashboard hotel manajemen (Trip.com Partner Dashboard style), melakukan **audit kompatibilitas** dengan spesifikasi di `docs/hotel/01-07`, dan mendokumentasikan workflow implementasi lengkap ke **Laravel** untuk module Hotel OTA di proyek Sewain.

---

## 1. Analisis Layar Dashboard Hotel (Screen Reference)

Referensi layar: `docs/laravel/1x25h12000f74ql9w51B2.png` — Trip.com Hotel Partner Dashboard.

Layar ini adalah **dashboard manajemen hotel untuk mitra properti** dengan elemen-elemen berikut:

### A. Sidebar Navigation (Partner Panel)

| Menu Item | Fungsi Laravel Equivalent |
|---|---|
| **Home** | `GET /api/v1/host/hotels/{hotel}/dashboard` — stats ringkasan |
| **Reservations** | `GET /api/v1/host/orders` — daftar reservasi kamar |
| **Rate & Availability** | `GET/PUT /api/v1/host/room-types/{type}/inventory/bulk` |
| **Promotions** | `GET /api/v1/vouchers` — diskon & promo |
| **Finance** | `GET /api/v1/host/wallet` — pendapatan & penarikan |
| **Guest Relations** | `GET /api/v1/conversations` — pesan tamu |
| **Property Info** | `GET/PUT /api/v1/host/hotels/{hotel}` — 8-tab metadata hotel |

### B. Guest Activity Stats

`
Reservations Made Today  : 11
Checking In Today        : 4
Post-Stay Reviews        : 464
Pre-Stay Questions       : 36
`

Host dashboard endpoint returns: `reservations_today`, `checkins_today`, `review_count`, `pre_stay_questions`.

### C. Guest Activity Table

Kolom: Nama Tamu, Tipe Kamar, Durasi & Tamu, Tanggal, Harga.
→ Mapping: `booking_rooms.guest_first_name` + `booking_rooms.guest_last_name` + `room_types.name`

### D. Property Service Index (PSI)

- **Basic score**: 4.47/5 | **Reward score**: 0.5/1
- **Inventory**: 3.86 | **Content**: 5 | **Review**: 4.43 | **Rate competitiveness**: 3.61
→ Stored in `hotels.score` (jsonb)

---

## 2. Audit Kompatibilitas

### Status Implementasi Saat Ini

| Komponen | Status | Gap |
|---|---|---|
| Migration hotels table | ⚠️ Partial | Missing: open_year, score, facility_groups, transport_points, faqs, deposit_amount |
| Migration room_types table | ⚠️ Partial | Missing: price_original, has_window, no_smoking, free_wifi, images |
| Migration bookings table | ⚠️ Partial | Missing: contact_email, contact_phone, trip_coins_earned, receive_promos |
| Migration booking_rooms table | ⚠️ Partial | Missing: room_number, room_name, guest_first_name, guest_last_name |
| Model Hotel.php | ⚠️ Outdated | fillable missing 8-tab fields |
| Model RoomType.php | ⚠️ Outdated | Missing new fields |
| Model Booking.php | ⚠️ Outdated | Missing OTA contact fields |
| Model BookingRoom.php | ⚠️ Outdated | Missing guest name fields |
| BookingController storeHotelBooking | ⚠️ Single room | No multi-guest array support |
| HotelApiController | ❌ Missing | Public hotel search & detail |
| HostHotelController | ❌ Missing | Mitra hotel management |
| Hotel API routes | ❌ Missing | Not registered in api_mobile.php |

---

## 3. Implementation Workflow

### Step 1 — Migration: 2026_08_15_000001_add_hotel_ota_columns.php

Adds missing columns to 4 tables:
- hotels: open_year, score, facility_groups, transport_points, faqs, review_quotes, deposit_amount
- room_types: price_original, has_window, no_smoking, free_wifi, images
- bookings: contact_email, contact_phone, trip_coins_earned, receive_promos
- booking_rooms: room_number, room_name, guest_first_name, guest_last_name

### Step 2 — Models Update

Hotel.php: Add full 8-tab JSONB fillable + casts
RoomType.php: Add price_original + quick facility boolean flags
Booking.php: Add contact_email, contact_phone, trip_coins_earned, receive_promos
BookingRoom.php: Add room_number, room_name, guest_first_name, guest_last_name

### Step 3 — HotelApiController (Public)

`
GET  /api/v1/hotels                    — Search hotels
GET  /api/v1/hotels/{hotel}            — Hotel detail (8 tabs)
GET  /api/v1/hotels/{hotel}/room-types — Available room types for dates
`

### Step 4 — HostHotelController (Authenticated Mitra)

`
GET  /api/v1/host/hotels                              — List mitra hotels
POST /api/v1/host/hotels                              — Create hotel
GET  /api/v1/host/hotels/{hotel}                      — Hotel detail
PUT  /api/v1/host/hotels/{hotel}                      — Update 8-tab metadata
GET  /api/v1/host/hotels/{hotel}/dashboard            — Stats hari ini
POST /api/v1/host/hotels/{hotel}/room-types           — Add room type
PUT  /api/v1/host/room-types/{roomType}               — Edit room type
POST /api/v1/host/room-types/{roomType}/inventory/bulk — Bulk update inventory
`

### Step 5 — BookingController Update

Support guests[] array for multi-room booking:
- Validate guests.*.room_number, guests.*.room_name, guests.*.first_name, guests.*.last_name
- Create BookingRoom per guest element with guest name
- Fill contact_email, contact_phone, trip_coins_earned (0.5% of total)
- Rename include_insurance -> has_insurance

### Step 6 — Routes Update (api_mobile.php)

Register all hotel public + host routes.

### Step 7 — Queue Jobs

- ExtendHotelInventoriesJob: Daily 00:00 — rolling 30-day inventory
- CancelExpiredBookingsJob: Every 5 minutes — expire unpaid hotel bookings
- SyncInsuranceStatusJob: Hourly — sync policy status from provider

---

## 4. Files Created/Updated

| File | Action |
|---|---|
| database/migrations/2026_08_15_000001_add_hotel_ota_columns.php | [NEW] |
| app/Models/Hotel.php | [UPDATE] |
| app/Models/RoomType.php | [UPDATE] |
| app/Models/Booking.php | [UPDATE] |
| app/Models/BookingRoom.php | [UPDATE] |
| app/Http/Controllers/Api/HotelApiController.php | [NEW] |
| app/Http/Controllers/Api/HostHotelController.php | [NEW] |
| app/Http/Controllers/Api/BookingController.php | [UPDATE] |
| app/Jobs/ExtendHotelInventoriesJob.php | [NEW] |
| app/Jobs/CancelExpiredBookingsJob.php | [NEW] |
| routes/api_mobile.php | [UPDATE] |
| flutter/lib/screens/mitra/hotel_form_screen.dart | [NEW] |

---

## 5. Flutter Mitra Hotel Management

hotel_form_screen.dart: 5-step wizard
- Step 1: Info Dasar Hotel (nama, bintang, tahun buka, jam check-in/out)
- Step 2: Fasilitas & Kebijakan (facility_groups, transport_points, faqs, policies)
- Step 3: Tipe Kamar (name, bed_type, size_sqm, price, breakfast_included)
- Step 4: Inventaris Harian (calendar grid, allotment, price per date)
- Step 5: Galeri & Review (photo upload, publish)

mitra_shell.dart: FAB or dedicated tab shortcut to hotel_form_screen

---

## 6. Compatibility Checklist vs docs/hotel

| Feature | Docs Reference | Status After Implementation |
|---|---|---|
| hotels schema 8-tab | 01-database-migration.md | DONE via new migration |
| Eloquent models full fields | 02-models-relationships.md | DONE via model updates |
| Multi-guest booking payload | 03-query-filters.md | DONE via BookingController update |
| Flutter screens 4 screens | 04-flutter-implementation.md | DONE (previously) |
| Stay Protection has_insurance | 05-insurance-integration.md | DONE field aligned |
| 8-tab mitra form wizard | 06-hotel-management-flow.md | DONE via hotel_form_screen.dart |
| Backward compatibility unit booking | 07-compatibility-map.md | PRESERVED |
