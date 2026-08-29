# Mitra Accommodation — API Contract & Migration Guide

> Dokumentasi teknis modul Mitra Accommodation: respons API `room` vs `unit`, skema payload request, dan panduan migrasi.

## 1. Ikhtisar

| `booking_mode` | Tipe | Contoh | Booking Jalur |
|---|---|---|---|
| `room` | Hotel / Guest House / Inventory-based | Hotel, Motel, Penginapan | Per tipe kamar (`unit_types`) |
| `unit` | Apartemen / Vila / Kost / Property-based | Apartment, Villa, Rumah | Per unit utuh |

Flutter: `accommodation_form_screen.dart`
- `bookingMode` null → mode selector.
- `room` → 5 tab.
- `unit` → 4 tab.

---

## 2. API Response — Room Mode (`room`)

Endpoint: `GET host/hotels/{id}` atau `GET accommodations/{id}`

Resource: `HostAccommodationResource::roomShape()` atau `AccommodationResource::hotelShape()`

```json
{
  "status": true,
  "code": 200,
  "message": "Detail hotel berhasil dimuat.",
  "data": {
    "id": 1,
    "booking_mode": "room",
    "star_rating": 5,
    "open_year": 2010,
    "check_in_time": "14:00:00",
    "check_out_time": "12:00:00",
    "deposit_amount": 500000.00,
    "name": "Merlynn Park Hotel",
    "description": "...",
    "address": "Jl. K.H. Hasyim Ashari No. 29-31, Jakarta Pusat",
    "city_name": "Jakarta Pusat",
    "latitude": -6.166667,
    "longitude": 106.816667,
    "cancellation_policy": "Pembatalan gratis hingga 24 jam sebelum check-in.",
    "price_from": 685000,
    "price_original": 950000,
    "gallery": ["https://images.unsplash.com/photo-..."],
    "facilities": [
      {
        "category": "Fasilitas Utama",
        "icon": "star",
        "items": [
          {"name": "Resepsionis & Keamanan 24 Jam", "is_available": true, "badge": null}
        ]
      }
    ],
    "facility_items": [
      {"id": 1, "name": "AC", "icon": "ac", "context": "facility", "is_available": true, "badge": null}
    ],
    "nearby_points": [
      {"name": "Stasiun Gambir", "type": "train", "distance": "1,2 km", "duration": "15 menit", "icon": "train"}
    ],
    "questions": [
      {"id": 1, "question": "Apakah tersedia laundry?", "answer": "Ya, 24 jam.", "author_name": "Manager", "author_role": "Staff"}
    ],
    "policies": {
      "general": [{"section": "general", "icon": "info", "tone": "neutral", "title": "Informasi Umum", "paragraphs": ["Check-in mulai pukul 14:00."], "sort_order": 1}],
      "cancellation": [{"section": "cancellation", "icon": "cancel", "tone": "warning", "title": "Pembatalan", "paragraphs": ["Pembatalan gratis hingga 24 jam."], "sort_order": 1}],
      "smoking_policy": [{"section": "smoking_policy", "icon": "smoke_free", "tone": "info", "title": "Merokok", "paragraphs": ["Semua kamar bebas rokok."], "sort_order": 1}],
      "extra_bed_policy": [{"section": "extra_bed_policy", "icon": "bed", "tone": "info", "title": "Ranjang Tambahan", "paragraphs": ["Tersedia atas permintaan."], "sort_order": 1}],
      "deposit": [{"section": "deposit", "icon": "account_balance_wallet", "tone": "info", "title": "Deposit", "paragraphs": ["Deposit wajib Rp 500.000."], "sort_order": 1}],
      "check_in": [{"section": "check_in", "icon": "login", "tone": "info", "title": "Check-in", "paragraphs": ["Tunjukkan KTP/Passport."], "sort_order": 1}],
      "check_out": [{"section": "check_out", "icon": "logout", "tone": "info", "title": "Check-out", "paragraphs": ["Kunci kamar serahkan ke resepsionis."], "sort_order": 1}],
      "room_policy": [{"section": "room_policy", "icon": "hotel", "tone": "neutral", "title": "Kamar", "paragraphs": ["Dilarang membawa tamu tidak tercatat."], "sort_order": 1}]
    },
    "check_in_info": "Check-in mulai pukul 14:00.",
    "check_out_info": "Check-out sebelum pukul 12:00.",
    "reception_hours": "Resepsionis beroperasi 24 jam setiap hari.",
    "min_age": 18,
    "child_policy": "Anak usia 0-5 tahun menginap gratis.",
    "extra_bed_policy": "Ranjang tambahan tersedia atas permintaan.",
    "smoking_policy": "Semua kamar adalah bebas rokok (Non-Smoking).",
    "deposit_amount": 500000,
    "deposit_currency": "IDR",
    "receptionist_24h": true,
    "allow_children": true,
    "extra_bed_available": true,
    "unit_types": [
      {
        "id": 1,
        "name": "Executive Room",
        "description": "Kamar Executive dengan fasilitas lengkap.",
        "bed_configuration": "1 King Bed atau 2 Single Bed",
        "room_size_sqm": 35.0,
        "base_price": 685000.0,
        "price_original": 950000.0,
        "capacity_adults": 2,
        "capacity_children": 1,
        "max_guests": 3,
        "breakfast_included": true,
        "has_window": true,
        "no_smoking": true,
        "free_wifi": true,
        "total_inventory": 20,
        "is_active": true,
        "facilities": ["Bathtub Marmer", "AC", "TV Kabel Layar Datar"],
        "images": [{"url": "https://images.unsplash.com/photo-...", "caption": "Executive Room - Main View"}],
        "prices": [{"price_type": "daily", "amount": 685000, "cleaning_fee": 0, "deposit": 500000, "service_fee": 68500}]
      }
    ],
    "bed_facilities": [{"icon": "king_bed", "label": "King Bed", "note": "(180x200)", "count": 1}],
    "room_furniture_groups": [
      {
        "id": 1,
        "room": "Living Room",
        "items": [{"id": 1, "name": "Sofa L Shape", "is_bed_config": false}],
        "bed_config": {"bed_type": "King Bed", "count": 1},
        "sort_order": 1
      }
    ],
    "status": "active",
    "created_at": "2026-08-13T04:12:33.000000Z",
    "updated_at": "2026-08-15T09:41:07.000000Z"
  }
}
```

### Field Reference — Room Mode

| Field | Tipe | Keterangan |
|---|---|---|
| `id` | int | ID akomodasi |
| `booking_mode` | string | Selalu `"room"` |
| `star_rating` | int | Bintang hotel (1-5) |
| `open_year` | int | Tahun operasional |
| `check_in_time` | string | Format `HH:MM:SS` |
| `check_out_time` | string | Format `HH:MM:SS` |
| `deposit_amount` | float/null | Deposit tunai wajib |
| `facilities` | array | Grup fasilitas ber-kategori |
| `facility_items` | array | Item fasilitas multi-konteks |
| `policies` | object | Kebijakan terstruktur per section |
| `unit_types` | array | Tipe kamar (harga + inventaris) |
| `nearby_points` | array | Titik transit/lokasi sekitar |
| `questions` | array | FAQ hotel |
| `bed_facilities` | array | Kartu ranjang |
| `room_furniture_groups` | array | Grup perabot ruangan |

---

## 3. API Response — Unit Mode (`unit`)

Endpoint: `GET host/properties/{id}` atau `GET accommodations/{id}`

Resource: `HostAccommodationResource::unitShape()` atau `AccommodationResource::propertyShape()`

```json
{
  "status": true,
  "code": 200,
  "message": "Detail properti berhasil dimuat.",
  "data": {
    "id": 1,
    "host_id": 10,
    "city_id": 1,
    "property_type": "apartment",
    "booking_mode": "unit",
    "name": "Sunset Beach Apartment",
    "building_name": "Sunset Towers",
    "description": "A beautiful apartment with ocean view",
    "address": "Jl. Pantai Indah No. 10, Bali",
    "latitude": -8.65,
    "longitude": 115.2167,
    "guest_capacity": 4,
    "bedrooms": 2,
    "bathrooms": 1,
    "star_rating": null,
    "check_in_time": "14:00:00",
    "check_out_time": "12:00:00",
    "has_breakfast": false,
    "facility_tags": ["WiFi", "Pool", "Gym", "Parking"],
    "gallery": ["https://images.unsplash.com/photo-..."],
    "cover_image": "https://images.unsplash.com/photo-...",
    "status": "active",
    "cancellation_policy": "Pembatalan gratis hingga 24 jam sebelum check-in.",
    "city_name": "Bali",
    "province": "Bali",
    "price_from": 500000,
    "price_original": 950000,
    "rating": 9.6,
    "review_count": 12,
    "prices": [
      {"price_type": "daily", "amount": 500000, "cleaning_fee": 50000, "deposit": 500000, "service_fee": 50000},
      {"price_type": "weekly", "amount": 3000000, "cleaning_fee": 50000, "deposit": 500000, "service_fee": 300000}
    ],
    "host": {"id": 10, "name": "Budi Santoso"},
    "type_label": "Apartment",
    "area_label": "Bali",
    "specs": [{"icon": "furnished", "label": "Full Furnished"}],
    "is_favorite": false,
    "intro": "Cari hunian nyaman? Sewa unit ini...",
    "description_extra": ["Apartemen ini berada di kawasan pantai indah."],
    "description_extra_heading": "Rekomendasi Tempat Rekreasi Terdekat:",
    "map_preview": "https://maps.google.com/?q=-8.65,115.2167",
    "price_caption": "per bulan mulai dari",
    "extra_media_count": 0,
    "is_flash_sale": true,
    "bed_facilities": [{"icon": "king_bed", "label": "King Bed", "note": "(180x200)", "count": 1}],
    "building_facilities": [{"icon": "pool", "label": "Kolam Renang", "note": "24 Jam", "count": null}],
    "building_facilities_all": ["Kolam Renang", "Gym", "Keamanan 24 Jam"],
    "room_furniture": [{"room": "Living Room", "items": [{"name": "Sofa L Shape", "is_bed_config": false}]}],
    "room_furniture_groups": [
      {
        "id": 1,
        "room": "Living Room",
        "items": [{"id": 1, "name": "Sofa L Shape", "is_bed_config": false}],
        "bed_config": {"bed_type": "King Bed", "count": 1},
        "sort_order": 1
      }
    ],
    "check_in_notes": [{"icon": "key", "tone": "info", "title": "Check-in Mandiri", "text": "Check-in dilakukan secara mandiri melalui locker pintar."}],
    "deposit_amount": 11175000,
    "deposit_notes": [{"currency": "IDR", "text": "Deposit dikembalikan dalam 3 hari kerja."}],
    "unit_detail": [{"icon": "floor", "label": "Lantai", "value": "12"}],
    "nearby_points": [{"name": "Pantai Kuta", "type": "beach", "distance": "500 m", "duration": "6 menit", "icon": "beach_access"}],
    "guest_media": [],
    "map_preview": "https://maps.google.com/?q=-8.65,115.2167",
    "building_units": {"id": 1, "name": "Sunset Towers", "image": null, "available_units": null},
    "reviews": [{"id": 1, "booking_id": 1, "property_id": 1, "user_id": 2, "user_name": "Siti Nurhaliza", "rating": 9.5, "comment": "Unit sangat nyaman!", "host_reply": "Terima kasih!", "photos": [], "created_at": "2026-07-20T14:30:00+07:00"}],
    "question_count": 2,
    "questions": [
      {"id": 1, "question": "Apakah tersedia parkir?", "answer": "Ya, 1 slot per unit.", "author_name": "Budi Santoso", "author_role": "Host", "asked_by": "host"}
    ],
    "facility_items": [
      {"id": 1, "name": "WiFi", "icon": "wifi", "context": "facility", "is_available": true, "badge": "Gratis"},
      {"id": 5, "name": "Sofa", "icon": "weekend", "context": "furniture", "is_available": true, "badge": null},
      {"id": 7, "name": "Full Furnished", "icon": "weekend", "context": "spec", "is_available": true, "badge": null}
    ],
    "bed_facilities": [{"icon": "king_bed", "label": "King Bed", "note": "(180x200)", "count": 1}],
    "unit_types": [
      {
        "id": 1,
        "name": "Default Unit",
        "slug": "sunset-beach-apartment-default-unit",
        "bed_configuration": "1 King Bed + 2 Single Bed",
        "base_price": 500000,
        "price_original": 950000,
        "total_inventory": 5,
        "remaining": 3,
        "capacity_adults": 4,
        "capacity_children": 2,
        "max_guests": 6,
        "bedrooms": 2,
        "bathrooms": 1,
        "room_size_sqm": 85.0,
        "has_breakfast": false,
        "has_window": true,
        "no_smoking": true,
        "free_wifi": true,
        "is_active": true,
        "prices": [{"price_type": "daily", "amount": 500000, "cleaning_fee": 50000, "deposit": 500000, "service_fee": 50000}],
        "images": [{"url": "https://images.unsplash.com/photo-...", "caption": "Main View"}],
        "facility_items": [{"id": 1, "name": "WiFi", "icon": "wifi", "context": "facility", "is_available": true}]
      }
    ],
    "policies": {
      "general": [{"section": "general", "icon": "info", "tone": "neutral", "title": "Informasi Umum", "paragraphs": ["Check-in mulai pukul 14:00."], "sort_order": 1}],
      "check_in": [{"section": "check_in", "icon": "login", "tone": "info", "title": "Prosedur Check-in", "paragraphs": ["Tunjukkan KTP/Passport asli."], "sort_order": 1}],
      "check_out": [{"section": "check_out", "icon": "logout", "tone": "info", "title": "Prosedur Check-out", "paragraphs": ["Serahkan kunci akses kartu di resepsionis."], "sort_order": 1}],
      "cancellation": [{"section": "cancellation", "icon": "cancel", "tone": "warning", "title": "Pembatalan", "paragraphs": ["Pembatalan gratis hingga 24 jam."], "sort_order": 1}],
      "smoking_policy": [{"section": "smoking_policy", "icon": "smoke_free", "tone": "info", "title": "Merokok", "paragraphs": ["Area dalam unit bebas rokok."], "sort_order": 1}],
      "extra_bed_policy": [{"section": "extra_bed_policy", "icon": "bed", "tone": "info", "title": "Ranjang Tambahan", "paragraphs": ["Tidak tersedia."], "sort_order": 1}],
      "deposit": [{"section": "deposit", "icon": "account_balance_wallet", "tone": "info", "title": "Deposit", "paragraphs": ["Deposit sesuai durasi sewa."], "sort_order": 1}],
      "room_policy": [{"section": "room_policy", "icon": "hotel", "tone": "neutral", "title": "Hunian", "paragraphs": ["Dilarang mengadakan acara tanpa seizin host."], "sort_order": 1}]
    },
    "check_in_info": "Check-in mulai pukul 14:00.",
    "check_out_info": "Check-out sebelum pukul 12:00.",
    "reception_hours": "Resepsionis beroperasi 24 jam.",
    "min_age": 18,
    "child_policy": "Anak usia 0-5 tahun menginap gratis.",
    "extra_bed_policy": "Ranjang tambahan tidak tersedia.",
    "smoking_policy": "Area dalam unit adalah area bebas rokok.",
    "receptionist_24h": true,
    "allow_children": true,
    "extra_bed_available": true,
    "unit_detail": [{"icon": "floor", "label": "Lantai", "value": "12"}],
    "description_paragraphs": ["Apartemen ini berada di kawasan pantai indah.", "Gedung ini dilengkapi keamanan 24 jam."],
    "details": [{"icon": "floor", "label": "Lantai", "value": "12"}],
    "created_at": "2026-08-13T04:12:33.000000Z",
    "updated_at": "2026-08-15T09:41:07.000000Z"
  }
}
```

### Field Reference — Unit Mode

| Field | Tipe | Keterangan |
|---|---|---|
| `id` | int | ID akomodasi |
| `booking_mode` | string | Selalu `"unit"` |
| `property_type` | string | `apartment`, `house`, `villa`, dll |
| `building_name` | string | Nama gedung/tower |
| `guest_capacity` | int | Kapasitas tamu maksimal |
| `bedrooms` | int | Jumlah kamar tidur |
| `bathrooms` | int | Jumlah kamar mandi |
| `has_breakfast` | bool | Tersedia sarapan |
| `facility_tags` | array | Tag fasilitas ringkas |
| `prices` | array | Harga multi-durasi |
| `host` | object | Ringkasan host |
| `type_label` | string | Label tipe properti |
| `area_label` | string | Label kota/area |
| `specs` | array | Spesifikasi singkat |
| `intro` | string | Headline marketing |
| `description_extra` | array | Paragraf deskripsi tambahan |
| `bed_facilities` | array | Kartu ranjang |
| `building_facilities` | array | Fasilitas gedung |
| `room_furniture` | array | Perabot ruangan |
| `room_furniture_groups` | array | Grup perabot terstruktur |
| `check_in_notes` | array | Catatan check-in |
| `deposit_notes` | array | Catatan deposit |
| `unit_detail` | array | Detail unit (lantai, luas, view) |
| `nearby_points` | array | Lokasi sekitar |
| `guest_media` | array | Media tambahan dari tamu |
| `building_units` | object/null | Mirror gedung/tower |
| `questions` | array | FAQ properti |
| `facility_items` | array | Item fasilitas multi-konteks (`facility`, `furniture`, `spec`) |

---

## 4. Request Payload — Submit Form

### 4.1 Room Mode — `POST host/hotels`

```json
{
  "city_id": 1,
  "name": "Merlynn Park Hotel",
  "address": "Jl. K.H. Hasyim Ashari No. 29-31, Jakarta Pusat",
  "description": "Hotel bintang 5 bergaya megah...",
  "latitude": -6.166667,
  "longitude": 106.816667,
  "open_year": 2010,
  "check_in_time": "14:00:00",
  "check_out_time": "12:00:00",
  "deposit_amount": 500000,
  "check_in_info": "Check-in mulai pukul 14:00...",
  "check_out_info": "Check-out sebelum pukul 12:00.",
  "reception_hours": "Resepsionis beroperasi 24 jam setiap hari.",
  "min_age": 18,
  "child_policy": "Anak usia 0-5 tahun menginap gratis...",
  "extra_bed_policy": "Ranjang tambahan tersedia...",
  "smoking_policy": "Semua kamar adalah bebas rokok...",
  "receptionist_24h": true,
  "allow_children": true,
  "extra_bed_available": true,
  "cancellation_policy": "Pembatalan gratis hingga 24 jam...",
  "facility_groups": [
    {
      "category": "Fasilitas Utama",
      "icon": "star",
      "items": [
        {"name": "Resepsionis & Keamanan 24 Jam", "is_available": true, "badge": null}
      ]
    }
  ],
  "policies": [
    {"section": "general", "icon": "info", "tone": "neutral", "title": "Informasi Umum", "paragraphs": ["Check-in mulai pukul 14:00."]},
    {"section": "cancellation", "icon": "cancel", "tone": "warning", "title": "Pembatalan", "paragraphs": ["Pembatalan gratis hingga 24 jam."]}
  ],
  "faqs": [
    {"question": "Apakah tersedia laundry?", "answer": "Ya, 24 jam.", "author_name": "Manager", "author_role": "Staff"}
  ],
  "transport_points": [
    {"name": "Stasiun Gambir", "type": "train", "distance": "1,2 km", "duration": "15 menit", "icon": "train"}
  ],
  "gallery": ["https://images.unsplash.com/photo-..."],
  "status": "active"
}
```

#### Room Types — `POST host/hotels/{hotelId}/room-types`

```json
{
  "name": "Executive Room",
  "description": "Kamar Executive dengan fasilitas lengkap.",
  "capacity_adults": 2,
  "capacity_children": 1,
  "max_guests": 3,
  "room_size_sqm": 35.0,
  "bed_configuration": "1 King Bed atau 2 Single Bed",
  "base_price": 685000,
  "price_original": 950000,
  "breakfast_included": true,
  "has_window": true,
  "no_smoking": true,
  "free_wifi": true,
  "total_inventory": 20,
  "is_active": true,
  "facilities": ["Bathtub Marmer", "AC", "TV Kabel Layar Datar"],
  "images": [{"url": "https://images.unsplash.com/photo-...", "caption": "Executive Room - Main View"}]
}
```

### 4.2 Unit Mode — `POST host/properties`

```json
{
  "property_type": "apartment",
  "booking_mode": "unit",
  "name": "Sunset Beach Apartment",
  "building_name": "Sunset Towers",
  "description": "A beautiful apartment with ocean view",
  "address": "Jl. Pantai Indah No. 10, Bali",
  "latitude": -8.65,
  "longitude": 115.2167,
  "open_year": 2020,
  "check_in_time": "14:00:00",
  "check_out_time": "12:00:00",
  "has_breakfast": false,
  "guest_capacity": 4,
  "bedrooms": 2,
  "bathrooms": 1,
  "facilities": ["wifi", "ac", "kitchen", "parking", "swimming_pool"],
  "facility_tags": ["WiFi", "Pool", "Gym", "Parking"],
  "gallery": ["https://images.unsplash.com/photo-..."],
  "status": "active",
  "cancellation_policy": "Pembatalan gratis hingga 24 jam sebelum check-in.",
  "map_preview": "https://maps.google.com/?q=-8.65,115.2167",
  "is_recommended": true,
  "recommendation_score": 9.5,
  "recommendation_reason": "Pilihan terbaik di Bali",
  "prices": [
    {"price_type": "daily", "amount": 500000, "cleaning_fee": 50000, "deposit": 500000, "service_fee": 50000},
    {"price_type": "weekly", "amount": 3000000, "cleaning_fee": 50000, "deposit": 500000, "service_fee": 300000}
  ],
  "other": {
    "province": "Bali",
    "cover": "https://images.unsplash.com/photo-...",
    "cover_image": "https://images.unsplash.com/photo-...",
    "type_label": "Apartment",
    "area_label": "Bali",
    "extra_media_count": 0,
    "specs": [{"icon": "furnished", "label": "Full Furnished"}],
    "is_favorite": false,
    "intro": "Cari hunian nyaman? Sewa unit ini...",
    "description_extra": ["Apartemen ini berada di kawasan pantai indah."],
    "description_extra_heading": "Rekomendasi Tempat Rekreasi Terdekat:",
    "price_caption": "per bulan mulai dari",
    "is_flash_sale": true,
    "bed_facilities": [{"icon": "king_bed", "label": "King Bed", "note": "(180x200)", "count": 1}],
    "building_facilities": [{"icon": "pool", "label": "Kolam Renang", "note": "24 Jam", "count": null}],
    "building_facilities_all": ["Kolam Renang", "Gym", "Keamanan 24 Jam"],
    "room_furniture": [{"room": "Living Room", "items": [{"name": "Sofa L Shape", "is_bed_config": false}]}],
    "room_furniture_groups": [{"id": 1, "room": "Living Room", "items": [{"id": 1, "name": "Sofa L Shape", "is_bed_config": false}], "bed_config": {"bed_type": "King Bed", "count": 1}, "sort_order": 1}],
    "check_in_notes": [{"icon": "key", "tone": "info", "title": "Check-in Mandiri", "text": "Check-in dilakukan secara mandiri melalui locker pintar."}],
    "deposit_amount": 11175000,
    "deposit_notes": [{"currency": "IDR", "text": "Deposit dikembalikan dalam 3 hari kerja."}],
    "unit_detail": [{"icon": "floor", "label": "Lantai", "value": "12"}],
    "nearby_points": [{"name": "Pantai Kuta", "type": "beach", "distance": "500 m", "duration": "6 menit", "icon": "beach_access"}],
    "guest_media": [],
    "building_units": {"id": 1, "name": "Sunset Towers", "image": null, "available_units": null},
    "map_preview": "https://maps.google.com/?q=-8.65,115.2167",
    "facility_tags": ["WiFi", "Pool", "Gym", "Parking"],
    "has_breakfast": false
  }
}
```

### 4.3 Endpoint Summary

| Mode | Method | Endpoint | Keterangan |
|---|---|---|---|
| `room` | POST | `/api/v1/host/hotels` | Buat hotel baru |
| `room` | PUT | `/api/v1/host/hotels/{id}` | Update metadata hotel |
| `room` | POST | `/api/v1/host/hotels/{id}/room-types` | Tambah tipe kamar |
| `room` | PUT | `/api/v1/host/room-types/{id}` | Edit tipe kamar |
| `unit` | POST | `/api/v1/host/properties` | Buat properti baru |
| `unit` | PUT | `/api/v1/host/properties/{id}` | Update properti |

---

## 5. JSON Dummy / Fixture Files

| File | Mode | Kegunaan |
|---|---|---|
| `flutter/assets/json/accommodation_room_dummy.json` | `room` | Load data hotel ke form |
| `flutter/assets/json/accommodation_unit_dummy.json` | `unit` | Load data properti ke form |

### 5.1 Room Dummy Structure

```json
{
  "id": 1,
  "booking_mode": "room",
  "name": "Merlynn Park Hotel",
  "star_rating": 5,
  "open_year": 2010,
  "check_in_time": "14:00:00",
  "check_out_time": "12:00:00",
  "deposit_amount": "500000.00",
  "description": "...",
  "address": "...",
  "city_name": "Jakarta Pusat",
  "latitude": -6.166667,
  "longitude": 106.816667,
  "cancellation_policy": "Pembatalan gratis hingga 24 jam sebelum check-in.",
  "facilities": [...],
  "facility_items": [...],
  "policies": {"general": [...], "cancellation": [...], "smoking_policy": [...], "extra_bed_policy": [...], "deposit": [...], "check_in": [...], "check_out": [...], "room_policy": [...]},
  "unit_types": [...],
  "gallery": [...],
  "questions": [...],
  "nearby_points": [...],
  "check_in_info": "...",
  "check_out_info": "...",
  "reception_hours": "...",
  "min_age": 18,
  "child_policy": "...",
  "extra_bed_policy": "...",
  "smoking_policy": "...",
  "receptionist_24h": true,
  "allow_children": true,
  "extra_bed_available": true,
  "status": "active"
}
```

### 5.2 Unit Dummy Structure

```json
{
  "id": 1,
  "booking_mode": "unit",
  "property_type": "apartment",
  "name": "Sunset Beach Apartment",
  "building_name": "Sunset Towers",
  "description": "...",
  "address": "...",
  "city_id": 1,
  "city_name": "Bali",
  "province": "Bali",
  "latitude": -8.65,
  "longitude": 115.2167,
  "guest_capacity": 4,
  "bedrooms": 2,
  "bathrooms": 1,
  "facility_tags": ["WiFi", "Pool", "Gym", "Parking"],
  "facility_items": [...],
  "gallery": [...],
  "cover_image": "...",
  "cancellation_policy": "...",
  "prices": [...],
  "host": {"id": 10, "name": "Budi Santoso"},
  "type_label": "Apartment",
  "area_label": "Bali",
  "specs": [...],
  "intro": "...",
  "description_extra": [...],
  "description_extra_heading": "...",
  "map_preview": "...",
  "price_caption": "per bulan mulai dari",
  "is_flash_sale": true,
  "bed_facilities": [...],
  "building_facilities": [...],
  "building_facilities_all": [...],
  "room_furniture": [...],
  "room_furniture_groups": [...],
  "check_in_notes": [...],
  "deposit_amount": 11175000,
  "deposit_notes": [...],
  "unit_detail": [...],
  "nearby_points": [...],
  "guest_media": [],
  "building_units": {...},
  "questions": [...],
  "policies": {"general": [...], "cancellation": [...], "check_in": [...], "check_out": [...], "smoking_policy": [...], "extra_bed_policy": [...], "deposit": [...], "room_policy": [...]},
  "unit_types": [...],
  "status": "active"
}
```

---

## 6. Laravel Resource Mapping

### 6.1 Resource Baru

File: `laravel/app/Http/Resources/HostAccommodationResource.php`

Resource ini mengekspos:
- **Room mode (`roomShape`)**: `facilities`, `facility_items`, `policies`, `unit_types`, `nearby_points`, `questions`, `galleries`, `bed_facilities`, `room_furniture_groups`.
- **Unit mode (`unitShape`)**: `facility_tags`, `gallery`, `prices`, `host`, `specs`, `intro`, `description_extra`, `bed_facilities`, `building_facilities`, `room_furniture`, `room_furniture_groups`, `check_in_notes`, `deposit_notes`, `unit_detail`, `nearby_points`, `guest_media`, `building_units`, `reviews`, `questions`, `unit_types`.

### 6.2 Eager Loading Contract

**Room mode:**
```php
Accommodation::hotels()->with([
    'city', 'buildingList', 'galleries',
    'policies', 'questions', 'nearbyPoints',
    'facilityGroups.items', 'facilityItems', 'facilityTags',
    'unitTypes.images', 'unitTypes.facilityItems',
    'bedFacilities', 'roomFurnitureGroups', 'details'
])->findOrFail($id);
```

**Unit mode:**
```php
Accommodation::properties()->with([
    'city', 'buildingList', 'galleries',
    'policies', 'questions', 'nearbyPoints',
    'facilityItems', 'facilityTags', 'bedFacilities',
    'roomFurnitureGroups', 'details', 'cheapestUnitType'
])->findOrFail($id);
```

### 6.3 Resource yang Digunakan

| Resource | Kegunaan |
|---|---|
| `AccommodationResource` | Public detail (auto-branching `hotelShape`/`propertyShape`) |
| `HostAccommodationResource` | Host-side form detail (menambahkan `policies` sebagai object, `facility_items`, dsb) |
| `AccommodationPolicyResource` | Single policy block + `toNoteArray()` untuk check-in/deposit notes |
| `AccommodationQuestionResource` | FAQ hotel (`toArray`) dan properti (`toPropertyArray`) |
| `NearbyPointResource` | Transport/nearby point (`toArray` untuk hotel, `toPropertyArray` untuk properti) |
| `FacilityGroupResource` | Grup fasilitas hotel |
| `FacilityItemResource` | Item fasilitas multi-konteks (`toSpecArray`, `toBuildingFacilityArray`, `toRoomFurnitureArray`) |
| `UnitTypeResource` | Tipe kamar/unit |
| `UnitTypePriceResource` | Harga periodik properti |
| `BedFacilityResource` | Kartu ranjang |
| `RoomFurnitureGroupResource` | Grup perabot ruangan |
| `GalleryResource` | URL galeri |
| `BuildingListResource` | Gedung/tower (`toArray` untuk hotel, `toPropertyArray` untuk properti) |

---

## 7. Panduan Migrasi — Developer Mobile

### 7.1 File Legacy yang Dihapus

| File Legacy | Pengganti | Catatan |
|---|---|---|
| `flutter/lib/screens/mitra/hotel_form_screen.dart` | `accommodation_form_screen.dart` | Semua logic hotel kini di dalam form terpadu |
| `flutter/lib/screens/mitra/property_form_payload.dart` | Inline `buildPropertyPayload()` di `accommodation_form_screen.dart` | Payload builder tidak lagi sebagai file terpisah |

### 7.2 Perubahan Routing

Route lama:
- `/mitra/properties/form` → `PropertyFormScreen`
- `/mitra/hotels/form` → `HotelFormScreen`

Route baru:
- `/mitra/accommodations/form` → `AccommodationFormScreen`

Mode ditentukan via argumen `bookingMode`:
```dart
// Room mode (Hotel)
Navigator.pushNamed(
  context,
  Routes.mitraAccommodationForm,
  arguments: {'booking_mode': 'room', 'hotel_id': 1, 'property_id': 1},
);

// Unit mode (Property)
Navigator.pushNamed(
  context,
  Routes.mitraAccommodationForm,
  arguments: {'booking_mode': 'unit', 'property_id': 1},
);

// Mode selector (tampilkan pilihan room/unit terlebih dahulu)
Navigator.pushNamed(
  context,
  Routes.mitraAccommodationForm,
);
```

### 7.3 Perubahan Model & Parsing

**Lama (Hotel):**
```dart
// hotel_form_screen.dart
final hotel = await _service.getHostHotelDetail(hotelId);
// parsing manual ke _roomTypes, _facilityGroups, _faqs, dsb
```

**Baru (AccommodationFormScreen):**
```dart
// accommodation_form_screen.dart
if (_isHotel) {
  await _loadHotelData(); // memanggil hotelService.getHostHotelDetail
} else {
  await _loadPropertyData(id); // memanggil hostService.propertyDetail
}
```

### 7.4 Perubahan Submit

**Lama:**
- Hotel: `HotelFormScreen._submit()` → `hotelService.createHotelForProperty()` atau `updateHotelForProperty()`
- Property: `PropertyFormScreen._submit()` → `hostService.createProperty()` atau `updateProperty()`

**Baru:**
- Hotel: `AccommodationFormScreen._submitHotel()` → `hotelService.createHotelForProperty()` atau `updateHotelForProperty()`
- Property: `AccommodationFormScreen._submitUnit()` → `hostService.createProperty()` atau `updateProperty()`

Payload builder untuk unit kini inline di file yang sama:
```dart
final body = buildPropertyPayload(form: {...}, status: status);
```

### 7.5 JSON Dummy Baru

Gunakan file dummy baru yang terpisah:

| Mode | File Dummy | Catatan |
|---|---|---|
| `room` | `flutter/assets/json/accommodation_room_dummy.json` | Struktur lengkap hotel dengan `policies` sebagai object multi-section |
| `unit` | `flutter/assets/json/accommodation_unit_dummy.json` | Struktur lengkap properti dengan `facility_items` multi-konteks |

### 7.6 Draft Autosave

Draft kini menggunakan key yang sama untuk kedua mode:
```dart
const _kDraftKey = 'accommodation_form_draft';
```

Field yang disimpan: `name`, `address`, `building_name`, `description`, `property_type`, `city_id`, `guest_capacity`, `bedrooms`, `facilities`, `gallery`.

---

## 8. Panduan Migrasi — Developer Backend

### 8.1 Resource Baru

Buat file `laravel/app/Http/Resources/HostAccommodationResource.php` jika belum ada. Resource ini:
- Meng-extend `JsonResource`
- Memiliki dua method: `roomShape()` dan `unitShape()`
- Menggunakan `whenLoaded()` untuk semua relasi opsional
- Menghasilkan JSON yang konsisten dengan dummy Flutter

### 8.2 Controller Update

Di `HostHotelController`, gunakan `HostAccommodationResource` untuk response host-side:

```php
use App\Http\Resources\HostAccommodationResource;

public function show(Request $request, $id)
{
    $hotel = Accommodation::hotels()
        ->where('host_id', $request->user()->id)
        ->with([
            'city', 'buildingList', 'galleries',
            'policies', 'questions', 'nearbyPoints',
            'facilityGroups.items', 'facilityItems', 'facilityTags',
            'unitTypes.images', 'unitTypes.facilityItems',
            'bedFacilities', 'roomFurnitureGroups', 'details'
        ])->findOrFail($id);

    return ApiResponse::success(
        (new HostAccommodationResource($hotel))->resolve(),
        'Detail hotel berhasil dimuat.'
    );
}
```

Di `PropertyController`, gunakan `HostAccommodationResource` untuk response host-side:

```php
public function hostShow(Request $request, $id)
{
    $property = Accommodation::properties()
        ->where('host_id', $request->user()->id)
        ->with([
            'city', 'buildingList', 'galleries',
            'policies', 'questions', 'nearbyPoints',
            'facilityItems', 'facilityTags', 'bedFacilities',
            'roomFurnitureGroups', 'details', 'cheapestUnitType'
        ])->findOrFail($id);

    return ApiResponse::success(
        (new HostAccommodationResource($property))->resolve(),
        'Detail properti berhasil dimuat.'
    );
}
```

### 8.3 Migration Steps Summary

1. **Flutter**: Ganti semua import `hotel_form_screen.dart` dan `property_form_payload.dart` menjadi `accommodation_form_screen.dart`.
2. **Flutter**: Update semua `Navigator.pushNamed` yang menuju `Routes.mitraHotelForm` atau `Routes.mitraPropertyForm` menjadi `Routes.mitraAccommodationForm` dengan argumen `booking_mode`.
3. **Flutter**: Hapus file `hotel_form_screen.dart` dan `property_form_payload.dart` setelah memastikan tidak ada dependency.
4. **Laravel**: Buat `HostAccommodationResource.php` jika belum ada.
5. **Laravel**: Update `HostHotelController::show()` dan `PropertyController::hostShow()` untuk menggunakan `HostAccommodationResource`.
6. **Laravel**: Pastikan eager loading contract terpenuhi di semua controller yang memuat data akomodasi untuk form.

### 8.4 Backward Compatibility

- Endpoint lama (`GET host/hotels/{id}`, `GET host/properties/{id}`) tetap berfungsi.
- Response lama (`AccommodationResource`) tetap dipertahankan untuk public consumer.
- `HostAccommodationResource` hanya digunakan untuk host-side form detail.
- Flutter `AccommodationFormScreen` dapat menerima data dari `AccommodationResource` atau `HostAccommodationResource` karena struktur JSON-nya seragam.

### 8.5 Testing Checklist

- [ ] Flutter `flutter analyze` tidak ada error.
- [ ] Mode selector menampilkan 2 pilihan (Hotel/Inn dan Properti/Unit).
- [ ] Tab 1-5 untuk room mode dapat di-navigate.
- [ ] Tab 1-4 untuk unit mode dapat di-navigate.
- [ ] Load data dari `accommodation_room_dummy.json` berhasil mengisi form hotel.
- [ ] Load data dari `accommodation_unit_dummy.json` berhasil mengisi form properti.
- [ ] Submit form hotel mengirim payload yang sesuai dengan `POST host/hotels`.
- [ ] Submit form properti mengirim payload yang sesuai dengan `POST host/properties`.
- [ ] Draft autosave bekerja untuk kedua mode.
- [ ] Validasi form menangkap field kosong sebelum submit.

---

## 9. Daftar File Terkait

| File | Kegunaan |
|---|---|
| `flutter/lib/screens/mitra/accommodation_form_screen.dart` | Layar form terpadu (room + unit) |
| `flutter/assets/json/accommodation_room_dummy.json` | Dummy data hotel untuk form |
| `flutter/assets/json/accommodation_unit_dummy.json` | Dummy data properti untuk form |
| `laravel/app/Http/Resources/HostAccommodationResource.php` | Resource host-side form detail |
| `laravel/app/Http/Resources/AccommodationResource.php` | Resource public detail (auto-branching) |
| `laravel/app/Http/Controllers/Api/HostHotelController.php` | Controller host hotel CRUD |
| `laravel/app/Http/Controllers/Api/PropertyController.php` | Controller host property CRUD |
| `docs/domain/accommodations.md` | Master arsitektur akomodasi (21 tabel, 3NF) |
| `docs/ai/02-frontend-map.md` | Peta Flutter (47 route, 45 screen) |
| `docs/ai/03-api-contract.md` | Kontrak API 84 endpoint |
