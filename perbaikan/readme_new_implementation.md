# New Implementation: Hotel & Property Relational Restructuring

> **Tanggal Update:** 2026-08-18  
> **Status:** API Layer Selesai (236/236 tests passing) | Livewire & DataTables: Perlu Update  
> **Sumber:** `docs/perbaikan/restruktur_data_properti.md` + `docs/perbaikan/implementasi_generate_2.md`

---

## 1. Ringkasan Arsitektur Baru

### 1.1 Dari JSONB ke Relational

| Modul | Sebelum (JSONB) | Sesudah (Relational) |
|-------|-----------------|----------------------|
| **Media** | `properties.gallery` (jsonb), `room_types.images` (jsonb) | Tabel polimorfik `media` |
| **Fasilitas** | `properties.facilities` (jsonb), `hotels.facility_groups` (jsonb), `room_types.facilities` (jsonb) | Master `facilities` + pivot `model_has_facilities` |
| **Hotel Policies** | `hotels.policies` (jsonb, 12 key) | Tabel `hotel_policies` (1 row per hotel) |
| **Hotel Score** | `hotels.score` (jsonb, 6 component) | Tabel `hotel_score_components` |
| **Hotel Facility Groups** | `hotels.facility_groups` (jsonb) | `hotel_facility_groups` + `hotel_facilities` |
| **Transport Points** | `hotels.transport_points` (jsonb) | `hotel_transport_points` |
| **FAQs** | `hotels.faqs` (jsonb) | `hotel_faqs` |
| **Review Quotes** | `hotels.review_quotes` (jsonb) | `hotel_review_quotes` |
| **Property Detail** | `properties_other` (1 tabel, 34 kolom campuran) | 15+ tabel relasional |
| **Room Inventories** | `room_inventories` (sudah relasional) | Tetap relasional, diperbaiki struktur |

### 1.2 Tabel Baru yang Sudah Dibuat

#### A. Master & Shared
| Tabel | Keterangan |
|-------|------------|
| `facilities` | Master data fasilitas (id, name, icon, category) |
| `media` | Media polimorfik untuk Property, RoomType, dll |
| `model_has_facilities` | Pivot fasilitas untuk Property, RoomType, dll |

#### B. Hotel Module
| Tabel | Sumber JSONB Lama |
|-------|-------------------|
| `hotel_policies` | `hotels.policies` |
| `hotel_score_components` | `hotels.score` |
| `hotel_facility_groups` | `hotels.facility_groups` (group level) |
| `hotel_facilities` | `hotels.facility_groups[].items` |
| `hotel_transport_points` | `hotels.transport_points` |
| `hotel_faqs` | `hotels.faqs` |
| `hotel_review_quotes` | `hotels.review_quotes` |
| `room_type_facilities` | `room_types.facilities` |
| `room_type_media` | `room_types.images` |

#### C. Property Module
| Tabel | Sumber JSONB Lama |
|-------|-------------------|
| `property_media` | `properties.gallery` |
| `property_facilities` | `properties.facilities` |
| `property_other_core` | Scalar fields dari `properties_other` |
| `property_extra_descriptions` | `properties_other.description_extra` |
| `property_review_summaries` | `properties_other.review_summary` |
| `property_review_breakdowns` | Nested `review_summary.breakdown` |
| `property_specs` | `properties_other.specs` |
| `property_bed_facilities` | `properties_other.bed_facilities` |
| `property_building_facilities` | `properties_other.building_facilities` |
| `property_building_facilities_all` | `properties_other.building_facilities_all` |
| `property_room_furniture` | `properties_other.room_furniture` |
| `property_room_furniture_groups` | `properties_other.room_furniture_groups` |
| `property_room_furniture_items` | Nested `room_furniture_groups[].items` |
| `property_check_in_notes` | `properties_other.check_in_notes` |
| `property_deposit_notes` | `properties_other.deposit_notes` |
| `property_unit_details` | `properties_other.unit_detail` |
| `property_nearby_places` | `properties_other.nearby` |
| `property_guest_media` | `properties_other.guest_media` |
| `property_building_units` | `properties_other.building_units` |

---

## 2. Status Implementasi Saat Ini

### 2.1 Layer yang SUDAH SELESAI

| Layer | File | Status |
|-------|------|--------|
| **Migrations** | 29 migration files (`2026_08_18_004` - `032`) | ✅ Done |
| **Models** | 34 model files di `app/Models/` | ✅ Done |
| **API Controllers** | `PropertyController`, `HotelApiController`, `HostHotelController` | ✅ Done |
| **API Resources** | `PropertyResource`, `HotelResource` | ✅ Done |
| **Tests** | Full suite: 236/236 passing | ✅ Done |

### 2.2 Layer yang BELUM DIUPDATE

| Layer | File | Keterangan |
|-------|------|------------|
| **Livewire - Hotels/Form.php** | `app/Livewire/Hotels/Form.php` | Masih pakai JSONB strings (`facility_groups_json`, `transport_points_json`, dll) |
| **Livewire - Hotels/WizardForm.php** | `app/Livewire/Hotels/WizardForm.php` | Masih simpan `facility_groups`, `transport_points`, `faqs` sebagai JSONB di `hotels` table |
| **Livewire - Properties/Form.php** | `app/Livewire/Properties/Form.php` | Belum integrate dengan `property_media`, `property_facilities` |
| **Livewire - Properties/WizardForm.php** | `app/Livewire/Properties/WizardForm.php` | Belum integrate dengan tabel relational baru |
| **Livewire - Views** | `resources/views/livewire/hotels/form.blade.php` | Masih textarea JSON |
| **Livewire - Views** | `resources/views/livewire/properties/form.blade.php` | Belom ada input facilities, media |
| **DataTables** | `app/DataTables/PropertyDataTable.php` | Column definitions lama, belum tampilkan data relational |
| **Admin Views** | `resources/views/admin/properties/*.blade.php` | Belom updated untuk relational data |

### 2.3 Livewire Lainnya (Tidak Berhubungan Langsung dengan Restructuring)

| Component | File | Keterangan |
|-----------|------|------------|
| **PropertyPrices** | `app/Livewire/PropertyPrices/Form.php` | ✅ Sudah pakai `PropertyPrice` model (relational) |
| **PropertyRecommendations** | `app/Livewire/PropertyRecommendations/Form.php` | ✅ Sudah pakai `PropertyRecommendation` model (relational) |
| **PropertySearchLogs** | `app/Livewire/PropertySearchLogs/Form.php` | ✅ Sudah pakai `PropertySearchLog` model (relational) |
| **RoomInventories** | `app/Livewire/RoomInventories/Form.php` | ✅ Sudah pakai `RoomInventory` model (relational) |
| **RoomTypes** | `app/Livewire/RoomTypes/Form.php` | ✅ Sudah pakai `RoomType` model (relational) |
| **Availabilities** | `app/Livewire/Availabilities/Form.php` | ⚠️ Pakai `Availability` model (sudah deprecated, diganti `RoomInventory`) |

---

## 3. Alur Akses Form (Menu → Livewire)

### 3.1 Sidebar Menu Structure

File: `resources/views/layout/partials/sidebar-layout/sidebar/_menu.blade.php`

```
Properti (accordion)
├── Daftar Properti          → admin.properties.index (DataTable)
├── Kota                     → admin.cities.index
├── Rekomendasi              → admin.property-recommendations.index
├── Harga Properti           → admin.property-prices.index
├── Ketersediaan             → admin.availabilities.index
└── Log Pencarian            → admin.property-search-logs.index

[Hotel Wizard Button]        → Livewire Hotels/WizardForm (modal)
[Property Wizard Button]     → Livewire Properties/WizardForm (modal)
```

### 3.2 Flow Akses Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ADMIN SIDEBAR MENU                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Properti (accordion)                                               │   │
│  │  ├── Daftar Properti  ──▶ PropertyDataTable (index.blade.php)      │   │
│  │  │                         └──▶ [Add] button                         │   │
│  │  │                              └──▶ Livewire: properties.property-modal │
│  │  │                                   └──▶ properties.form (modal)   │   │
│  │  │                                        └──▶ properties.wizard-form │   │
│  │  │                                             └──▶ Wizard modal     │   │
│  │  ├── Kota ──▶ CityDataTable                                          │   │
│  │  ├── Rekomendasi ──▶ PropertyRecommendationDataTable                 │   │
│  │  │                    └──▶ [Add] └──▶ Livewire: property_recommendations.form │
│  │  ├── Harga Properti ──▶ PropertyPriceDataTable                        │   │
│  │  │                      └──▶ [Add] └──▶ Livewire: property_prices.form │
│  │  ├── Ketersediaan ──▶ AvailabilityDataTable                           │   │
│  │  │                    └──▶ [Add] └──▶ Livewire: availabilities.form  │   │
│  │  └── Log Pencarian ──▶ PropertySearchLogDataTable                     │   │
│  │                         └──▶ [Add] └──▶ Livewire: property_search_logs.form │
│  │                                                                        │   │
│  │  [Hotel Wizard Button] ──▶ Livewire: hotels.hotel-wizard-modal       │   │
│  │                               └──▶ hotels.wizard-form (full wizard)  │   │
│  │  [Property Wizard Button] ──▶ Livewire: properties.wizard-form       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Entry Points untuk Add/Edit

#### A. Property Add/Edit

| Action | Entry Point | Livewire Component | Modal/Page |
|--------|-------------|-------------------|------------|
| **Quick Add Property** | `admin.properties.index` → [Add] button | `Properties/PropertyModal` → `Form` | Modal `#kt_modal_add_property` |
| **Quick Edit Property** | `admin.properties.index` → row action [settings] | `Properties/PropertyModal` → `Form` | Modal `#kt_modal_add_property` |
| **Property Wizard** | `admin.properties.index` → [Property Wizard] button | `Properties/WizardForm` | Modal `#kt_modal_property_wizard` |
| **Hotel Wizard** | `admin.properties.index` → [Hotel Wizard] button | `Hotels/HotelWizardModal` → `WizardForm` | Modal `#kt_modal_hotel_wizard` |

**Flow Detail - Property Wizard:**
```
1. Admin klik "Property Wizard" di index page
2. Modal #kt_modal_property_wizard terbuka
3. Livewire <livewire:properties.wizard-form> di-mount
4. Jika ada propertyId → edit() load data dari tabel relasional
5. Admin isi form (Tab 1-4)
6. Submit → save() → sync ke tabel relasional
7. Modal tertutup, DataTable refresh
```

**Flow Detail - Hotel Wizard:**
```
1. Admin klik "Hotel Wizard" di index page
2. Modal #kt_modal_hotel_wizard terbuka
3. Livewire <livewire:hotels.hotel-wizard-modal> di-mount
4. Jika ada hotelId → edit() load data dari tabel relasional
5. Admin isi form (Tab 1-4)
6. Submit → save() → sync ke tabel relasional
7. Modal tertutup, DataTable refresh
```

#### B. Hotel Add/Edit (Quick Edit)

| Action | Entry Point | Livewire Component | Modal/Page |
|--------|-------------|-------------------|------------|
| **Quick Add Hotel** | `admin.properties.index` → row action [hotel icon] | `Hotels/HotelModal` → `Form` | Modal `#kt_modal_add_hotel` |
| **Quick Edit Hotel** | `admin.properties.index` → row action [hotel icon] | `Hotels/HotelModal` → `Form` | Modal `#kt_modal_add_hotel` |

**Flow Detail:**
```
1. Admin klik icon hotel di row action
2. Modal #kt_modal_add_hotel terbuka
3. Livewire <livewire:hotels.hotel-modal> di-mount
4. edit($hotelId) load data dari tabel relasional
5. Admin isi form (8 tab dalam satu modal)
6. Submit → save() → sync ke tabel relasional
7. Modal tertutup
```

#### C. Supporting Data Entry

| Data | Entry Point | Livewire Component |
|------|-------------|-------------------|
| **Property Price** | `admin.property-prices.index` | `PropertyPrices/PropertyPriceModal` → `Form` |
| **Property Recommendation** | `admin.property-recommendations.index` | `PropertyRecommendations/PropertyRecommendationModal` → `Form` |
| **Room Inventory** | `admin.availabilities.index` atau via Hotel Wizard | `RoomInventories/RoomInventoryModal` → `Form` |
| **Room Type** | Via Hotel Wizard Tab 2 | `RoomTypes/RoomTypeModal` → `Form` |
| **Availability** | `admin.availabilities.index` | `Availabilities/AvailabilityModal` → `Form` |

---

## 4. Detail Restrukturisasi Parameter Livewire

### 4.1 Properties/Form.php (Quick Edit Property)

**Current State:**
- `public $gallery = []` — array file uploads
- `public $saved_gallery = []` — array path strings dari `$property->gallery` (JSONB)
- `save()` → `$validated['gallery'] = array_merge($this->saved_gallery, $uploadedGallery)`
- `save()` → `Property::update($validated)` — menyimpan JSONB array ke `properties.gallery`

**Required Changes:**

```php
// 1. Tambah properties untuk facilities
public array $selected_facilities = [];

// 2. Edit method - load dari tabel relasional
public function edit($id)
{
    $property = Property::with(['media', 'facilities'])->find($id);
    
    // Gallery dari property_media
    $this->saved_gallery = $property->media->map(fn ($m) => $m->url)->toArray();
    
    // Facilities dari model_has_facilities pivot
    $this->selected_facilities = $property->facilities->pluck('name')->toArray();
}

// 3. Save method - simpan ke tabel relasional
public function save()
{
    $validated = $this->validate();
    
    // Gallery upload ke storage
    $uploadedGallery = [];
    foreach ($this->gallery as $photo) {
        $uploadedGallery[] = $photo->store('properties/gallery', 'public');
    }
    $finalGallery = array_values(array_merge($this->saved_gallery, $uploadedGallery));
    
    DB::transaction(function () use ($validated, $finalGallery) {
        // 1. Upsert Property (tanpa gallery dan facilities)
        $propertyData = [
            'host_id' => $validated['host_id'],
            'city_id' => $validated['city_id'],
            'property_type' => $validated['property_type'],
            'name' => $validated['name'],
            // ... field lainnya
        ];
        
        if ($this->propertyId) {
            $property = Property::findOrFail($this->propertyId);
            $property->update($propertyData);
        } else {
            $property = Property::create($propertyData);
            $this->propertyId = $property->id;
        }
        
        // 2. Sync media (property_media table)
        $property->media()->delete(); // hapus yang lama
        foreach ($finalGallery as $index => $url) {
            $property->media()->create([
                'url' => $url,
                'sort_order' => $index,
                'is_cover' => $index === 0,
            ]);
        }
        
        // 3. Sync facilities (model_has_facilities pivot)
        $facilityIds = Facility::whereIn('name', $this->selected_facilities)->pluck('id');
        $property->facilities()->sync($facilityIds);
    });
}
```

### 4.2 Properties/WizardForm.php (Property Wizard)

**Current State:**
- `public array $facilities = []` — array of slugs
- `save()` → `'facilities' => $this->facilities` → disimpan ke `properties.facilities` (JSONB)
- `save()` → `'gallery' => $finalGallery` → disimpan ke `properties.gallery` (JSONB)
- `edit()` → `$this->facilities = is_array($property->facilities) ? $property->facilities : [];`
- `edit()` → `$this->saved_gallery = is_array($property->gallery) ? $property->gallery : [];`

**Required Changes:**

```php
// 1. Edit method - load dari tabel relasional
public function edit($id)
{
    $property = Property::with(['media', 'facilities', 'prices', 'city'])->findOrFail($id);
    
    // Facilities dari pivot
    $this->facilities = $property->facilities->pluck('slug')->toArray();
    
    // Gallery dari property_media
    $this->saved_gallery = $property->media->pluck('url')->toArray();
}

// 2. Save method - simpan ke tabel relasional
public function save()
{
    $this->validate();
    
    // Gallery upload
    $uploadedGallery = [];
    foreach ($this->gallery as $photo) {
        $uploadedGallery[] = $photo->store('properties/gallery', 'public');
    }
    $finalGallery = array_values(array_merge($this->saved_gallery, $uploadedGallery));
    
    DB::transaction(function () use ($finalGallery) {
        // 1. Upsert Property (tanpa facilities dan gallery)
        $propertyData = [
            'host_id' => $this->propertyId ? $this->host_id : Auth::id(),
            'city_id' => $this->city_id,
            'property_type' => $this->property_type,
            'booking_mode' => 'unit',
            'name' => $this->name,
            // ... field lainnya
        ];
        
        if ($this->propertyId) {
            $property = Property::findOrFail($this->propertyId);
            $property->update($propertyData);
        } else {
            $property = Property::create($propertyData);
            $this->propertyId = $property->id;
        }
        
        // 2. Sync property_media
        $property->media()->delete();
        foreach ($finalGallery as $index => $url) {
            $property->media()->create([
                'url' => $url,
                'sort_order' => $index,
                'is_cover' => $index === 0,
            ]);
        }
        
        // 3. Sync model_has_facilities
        $facilityIds = Facility::whereIn('slug', $this->facilities)->pluck('id');
        $property->facilities()->sync($facilityIds);
        
        // 4. Update/create PropertyPrice (sudah benar)
        PropertyPrice::updateOrCreate(...);
        
        // 5. Update/create PropertyRecommendation (sudah benar)
        ...
    });
}
```

### 4.3 Hotels/Form.php (Quick Edit Hotel)

**Current State:**
- `public $facility_groups_json = ''` — JSON string
- `public $transport_points_json = ''` — JSON string
- `public $faqs_json = ''` — JSON string
- `public $review_quotes_json = ''` — JSON string
- `edit()` → `$this->facility_groups_json = json_encode($hotel->facility_groups)`
- `save()` → `'facility_groups' => json_decode($this->facility_groups_json, true)`

**Required Changes:**

```php
// 1. Ganti JSONB properties jadi arrays
public array $selected_facilities = [];
public array $transport_points = [];
public array $faqs = [];
public array $review_quotes = [];

// 2. Edit method - load dari tabel relasional
public function edit($id)
{
    $hotel = Hotel::with(['policy', 'facilities', 'transportPoints', 'faqs', 'reviewQuotes'])->find($id);
    
    // Policies
    $policies = $hotel->policy?->toArray() ?? [];
    $this->receptionist_24h = $policies['receptionist_24h'] ?? true;
    $this->allow_children = $policies['allow_children'] ?? true;
    $this->extra_bed_available = $policies['extra_bed_available'] ?? true;
    
    // Facilities (dari pivot model_has_facilities)
    $this->selected_facilities = $hotel->facilities->pluck('name')->toArray();
    
    // Transport points
    $this->transport_points = $hotel->transportPoints->map(fn ($tp) => [
        'name' => $tp->name,
        'type' => $tp->type,
        'distance' => $tp->distance,
        'duration' => $tp->duration,
        'icon' => $tp->icon,
    ])->toArray();
    
    // FAQs
    $this->faqs = $hotel->faqs->map(fn ($faq) => [
        'question' => $faq->question,
        'answer' => $faq->answer,
        'author_name' => $faq->author_name,
        'author_role' => $faq->author_role,
    ])->toArray();
    
    // Review quotes
    $this->review_quotes = $hotel->reviewQuotes->map(fn ($rq) => [
        'quote' => $rq->quote,
        'author_name' => $rq->author_name,
        'author_role' => $rq->author_role,
        'rating' => $rq->rating,
    ])->toArray();
}

// 3. Save method - simpan ke tabel relasional
public function save()
{
    $validated = $this->validate();
    
    DB::transaction(function () use ($validated) {
        // 1. Upsert Hotel (tanpa JSONB fields)
        $hotelData = [
            'property_id' => $validated['property_id'],
            'star_rating' => $validated['star_rating'],
            'open_year' => $validated['open_year'],
            'check_in_time' => $validated['check_in_time'],
            'check_out_time' => $validated['check_out_time'],
            'deposit_amount' => $validated['deposit_amount'],
        ];
        
        if ($this->hotelId) {
            $hotel = Hotel::findOrFail($this->hotelId);
            $hotel->update($hotelData);
        } else {
            $hotel = Hotel::create($hotelData);
            $this->hotelId = $hotel->id;
            Property::where('id', $hotel->property_id)->update(['booking_mode' => 'room']);
        }
        
        // 2. Upsert HotelPolicy
        HotelPolicy::updateOrCreate(
            ['hotel_id' => $hotel->id],
            [
                'receptionist_24h' => (bool) $this->receptionist_24h,
                'allow_children' => (bool) $this->allow_children,
                'extra_bed_available' => (bool) $this->extra_bed_available,
                // ... field lainnya
            ]
        );
        
        // 3. Sync facilities (model_has_facilities)
        $facilityIds = Facility::whereIn('name', $this->selected_facilities)->pluck('id');
        $hotel->facilities()->sync($facilityIds);
        
        // 4. Sync transport points
        $hotel->transportPoints()->delete();
        foreach ($this->transport_points as $tp) {
            $hotel->transportPoints()->create($tp);
        }
        
        // 5. Sync FAQs
        $hotel->faqs()->delete();
        foreach ($this->faqs as $faq) {
            $hotel->faqs()->create($faq);
        }
        
        // 6. Sync review quotes
        $hotel->reviewQuotes()->delete();
        foreach ($this->review_quotes as $rq) {
            $hotel->reviewQuotes()->create($rq);
        }
    });
    
    session()->flash('success', $this->hotelId ? 'Hotel berhasil diperbarui.' : 'Hotel berhasil didaftarkan.');
    $this->dispatch('success');
}
```

### 4.4 Hotels/WizardForm.php (Hotel Wizard - All-in-One)

**Current State:**
- Tab 3: `selected_facilities[]` → disimpan ke `hotels.facility_groups` (JSONB)
- Tab 3: Policies → disimpan ke `hotels.policies` (JSONB)
- Tab 4: `transport_points[]` → disimpan ke `hotels.transport_points` (JSONB)
- Tab 4: `faqs[]` → disimpan ke `hotels.faqs` (JSONB)
- Room Types: `facilities` per room → disimpan ke `room_types.facilities` (JSONB)
- Room Types: `images` per room → disimpan ke `room_types.images` (JSONB)
- Gallery: `saved_gallery` → disimpan ke `properties.gallery` (JSONB)

**Required Changes:**

```php
// 1. Edit method - load dari tabel relasional
public function edit($id)
{
    $hotel = Hotel::with(['property', 'roomTypes', 'policy', 'facilities', 'transportPoints', 'faqs', 'reviewQuotes'])->find($id);
    
    $p = $hotel->property;
    if ($p) {
        // Gallery dari property_media
        $this->saved_gallery = $p->media->pluck('url')->toArray();
    }
    
    // Policies
    $policies = $hotel->policy?->toArray() ?? [];
    $this->receptionist_24h = $policies['receptionist_24h'] ?? true;
    $this->allow_children = $policies['allow_children'] ?? true;
    $this->extra_bed_available = $policies['extra_bed_available'] ?? true;
    
    // Facilities
    $this->selected_facilities = $hotel->facilities->pluck('name')->toArray();
    
    // Transport points
    $this->transport_points = $hotel->transportPoints->map(fn ($tp) => [
        'name' => $tp->name, 'type' => $tp->type, 'distance' => $tp->distance,
        'duration' => $tp->duration, 'icon' => $tp->icon,
    ])->toArray();
    
    // FAQs
    $this->faqs = $hotel->faqs->map(fn ($faq) => [
        'question' => $faq->question, 'answer' => $faq->answer,
        'author_name' => $faq->author_name, 'author_role' => $faq->author_role,
    ])->toArray();
    
    // Room types (load facilities dan images dari tabel relasional)
    $this->room_types = $hotel->roomTypes->map(function ($rt) {
        return [
            'id' => $rt->id,
            'name' => $rt->name,
            'description' => $rt->description ?? '',
            'facilities' => $rt->facilities->pluck('name')->toArray(), // dari model_has_facilities
            'images' => $rt->media->pluck('url')->toArray(), // dari media table
            // ... field lainnya
        ];
    })->toArray();
}

// 2. Save method - simpan ke tabel relasional
public function save()
{
    $this->validate();
    
    // Gallery upload
    $uploadedGallery = [];
    foreach ($this->gallery as $photo) {
        $uploadedGallery[] = $photo->store('hotels/gallery', 'public');
    }
    $finalGallery = array_values(array_merge($this->saved_gallery, $uploadedGallery));
    
    DB::transaction(function () use ($finalGallery) {
        // 1. Upsert Property
        $propertyData = [
            'host_id' => $this->host_id,
            'city_id' => $this->city_id,
            'property_type' => $this->property_type,
            'booking_mode' => 'room',
            'name' => $this->name,
            'building_name' => $this->building_name,
            'description' => $this->description,
            'address' => $this->address,
            'latitude' => $this->latitude ?: null,
            'longitude' => $this->longitude ?: null,
            'guest_capacity' => 10,
            'bedrooms' => count($this->room_types) > 0 ? count($this->room_types) : 1,
            'facilities' => $this->selected_facilities, // backward compat JSONB
            'gallery' => $finalGallery, // backward compat JSONB
            'status' => 'active',
        ];
        
        if ($this->propertyId) {
            $property = Property::findOrFail($this->propertyId);
            $property->update($propertyData);
        } else {
            $property = Property::create($propertyData);
            $this->propertyId = $property->id;
        }
        
        // 2. Sync property_media (gallery)
        $property->media()->delete();
        foreach ($finalGallery as $index => $url) {
            $property->media()->create([
                'url' => $url,
                'sort_order' => $index,
                'is_cover' => $index === 0,
            ]);
        }
        
        // 3. Sync property facilities (model_has_facilities)
        $facilityIds = Facility::whereIn('name', $this->selected_facilities)->pluck('id');
        $property->facilities()->sync($facilityIds);
        
        // 4. Upsert Hotel
        $hotelData = [
            'property_id' => $property->id,
            'star_rating' => $this->star_rating,
            'open_year' => $this->open_year,
            'check_in_time' => $this->check_in_time,
            'check_out_time' => $this->check_out_time,
            'deposit_amount' => (float) ($this->deposit_amount ?? 0),
        ];
        
        if ($this->hotelId) {
            $hotel = Hotel::findOrFail($this->hotelId);
            $hotel->update($hotelData);
        } else {
            $hotel = Hotel::create($hotelData);
            $this->hotelId = $hotel->id;
        }
        
        // 5. Upsert HotelPolicy
        HotelPolicy::updateOrCreate(
            ['hotel_id' => $hotel->id],
            [
                'receptionist_24h' => (bool) $this->receptionist_24h,
                'allow_children' => (bool) $this->allow_children,
                'extra_bed_available' => (bool) $this->extra_bed_available,
                // ... field lainnya
            ]
        );
        
        // 6. Sync hotel facilities (model_has_facilities)
        $hotelFacilityIds = Facility::whereIn('name', $this->selected_facilities)->pluck('id');
        $hotel->facilities()->sync($hotelFacilityIds);
        
        // 7. Sync transport points
        $hotel->transportPoints()->delete();
        foreach ($this->transport_points as $tp) {
            $hotel->transportPoints()->create($tp);
        }
        
        // 8. Sync FAQs
        $hotel->faqs()->delete();
        foreach ($this->faqs as $faq) {
            $hotel->faqs()->create($faq);
        }
        
        // 9. Sync Review Quotes
        $hotel->reviewQuotes()->delete();
        foreach ($this->review_quotes as $rq) {
            $hotel->reviewQuotes()->create($rq);
        }
        
        // 10. Sync Room Types
        $keptIds = collect($this->room_types)->pluck('id')->filter()->all();
        if ($this->hotelId) {
            $hotel->roomTypes()->whereNotIn('id', $keptIds ?: [0])->delete();
        }
        
        foreach ($this->room_types as $rtData) {
            // ... create/update room type
            
            // 10a. Sync room type facilities (model_has_facilities)
            $rtFacilityIds = Facility::whereIn('name', $rtData['facilities'] ?? [])->pluck('id');
            $roomType->facilities()->sync($rtFacilityIds);
            
            // 10b. Sync room type media
            $roomType->media()->delete();
            foreach ($rtData['images'] ?? [] as $index => $imageUrl) {
                $roomType->media()->create([
                    'url' => $imageUrl,
                    'sort_order' => $index,
                ]);
            }
        }
    });
}
```

### 4.5 PropertyPrices/Form.php

**Current State:** ✅ Sudah benar — menggunakan `PropertyPrice` model (relational).

**Tidak perlu diubah.**

### 4.6 PropertyRecommendations/Form.php

**Current State:** ✅ Sudah benar — menggunakan `PropertyRecommendation` model (relational).

**Tidak perlu diubah.**

### 4.7 PropertySearchLogs/Form.php

**Current State:** ✅ Sudah benar — menggunakan `PropertySearchLog` model (relational).

**Tidak perlu diubah.**

### 4.8 RoomInventories/Form.php

**Current State:** ✅ Sudah benar — menggunakan `RoomInventory` model (relational).

**Catatan:** `Availability` model sudah deprecated, seharusnya menggunakan `RoomInventory`.

### 4.9 RoomTypes/Form.php

**Current State:**
- Tidak ada handling untuk `facilities` dan `images` (JSONB)
- `save()` → `RoomType::create($validated)` — menyimpan ke `room_types` table

**Required Changes:**
```php
// 1. Tambah properties untuk facilities
public array $selected_facilities = [];

// 2. Edit method
public function edit($id)
{
    $roomType = RoomType::with(['facilities', 'media'])->find($id);
    
    $this->selected_facilities = $roomType->facilities->pluck('name')->toArray();
}

// 3. Save method
public function save()
{
    $validated = $this->validate();
    
    DB::transaction(function () use ($validated) {
        if ($this->roomtypeId) {
            $roomType = RoomType::findOrFail($this->roomtypeId);
            $roomType->update($validated);
        } else {
            $roomType = RoomType::create($validated);
            $roomType->ensureInventory(30);
        }
        
        // Sync facilities (model_has_facilities)
        $facilityIds = Facility::whereIn('name', $this->selected_facilities)->pluck('id');
        $roomType->facilities()->sync($facilityIds);
    });
}
```

### 4.10 Availabilities/Form.php

**Current State:** Menggunakan `Availability` model yang sudah deprecated.

**Required Changes:**
- Ganti `Availability` model dengan `RoomInventory`
- Ubah field `property_id` → `room_type_id`
- Ubah field `is_available` → `is_closed` (inverse logic)
- Tambah field `allotment`, `booked_count`

```php
// Sebelum:
public $property_id = null;
public $is_available = false;

// Sesudah:
public $room_type_id = null;
public $date = '';
public $allotment = 5;
public $booked_count = 0;
public $is_closed = false;

// Validasi:
'room_type_id' => 'required|exists:room_types,id',
'date' => 'required|date',
'allotment' => 'required|integer|min:0',
'booked_count' => 'required|integer|min:0',
'is_closed' => 'boolean',
```

---

## 5. Detail Perubahan per Livewire Component

### 5.1 Properties/Form.php (Quick Edit)

| Aspek | Current | Target |
|-------|---------|--------|
| **Gallery** | `saved_gallery` dari `$property->gallery` (JSONB) | `saved_gallery` dari `$property->media->pluck('url')` |
| **Gallery Save** | `Property::update(['gallery' => $array])` | `$property->media()->create([...])` |
| **Facilities** | Tidak ada | Tambah `selected_facilities[]` + sync ke `model_has_facilities` |
| **Validation** | `gallery.*` => image | Tetap sama |
| **Blade** | Gallery upload + preview | Gallery upload + facilities tag input |

### 5.2 Properties/WizardForm.php

| Aspek | Current | Target |
|-------|---------|--------|
| **Tab 2 (Fasilitas)** | `$this->facilities` → disimpan ke `properties.facilities` JSONB | `$this->facilities` → sync ke `model_has_facilities` |
| **Tab 4 (Galeri)** | `$this->saved_gallery` → disimpan ke `properties.gallery` JSONB | `$this->saved_gallery` → disimpan ke `property_media` table |
| **Edit** | `$property->facilities` (JSONB decode) | `$property->facilities` (relation) |
| **Save** | `Property::create(['facilities' => ..., 'gallery' => ...])` | Separate sync untuk `property_media` dan `model_has_facilities` |

### 5.3 Hotels/Form.php (Quick Edit)

| Aspek | Current | Target |
|-------|---------|--------|
| **Policies** | `$hotel->policies` (JSONB accessor) → textarea | `$hotel->policy` (relation) → checkbox/input |
| **Facilities** | `facility_groups_json` textarea | `selected_facilities[]` tag input |
| **Transport Points** | `transport_points_json` textarea | Dynamic rows input |
| **FAQs** | `faqs_json` textarea | Dynamic rows input |
| **Review Quotes** | `review_quotes_json` textarea | Dynamic rows input |
| **Save** | `Hotel::update(['policies' => ..., 'facility_groups' => ...])` | Separate upsert ke `hotel_policies`, `model_has_facilities`, `hotel_transport_points`, `hotel_faqs`, `hotel_review_quotes` |

### 5.4 Hotels/WizardForm.php

| Aspek | Current | Target |
|-------|---------|--------|
| **Tab 3 (Fasilitas)** | `selected_facilities` → `hotels.facility_groups` JSONB | `selected_facilities` → `model_has_facilities` + `hotel_facility_groups` |
| **Tab 3 (Policies)** | `policies` → `hotels.policies` JSONB | `HotelPolicy::updateOrCreate()` |
| **Tab 4 (Transport)** | `transport_points[]` → `hotels.transport_points` JSONB | `$hotel->transportPoints()->create([...])` |
| **Tab 4 (FAQs)** | `faqs[]` → `hotels.faqs` JSONB | `$hotel->faqs()->create([...])` |
| **Tab 2 (Room Types)** | `facilities` → `room_types.facilities` JSONB | `$roomType->facilities()->sync([...])` |
| **Tab 2 (Room Types)** | `images` → `room_types.images` JSONB | `$roomType->media()->create([...])` |
| **Gallery** | `saved_gallery` → `properties.gallery` JSONB | `$property->media()->create([...])` |

### 5.5 RoomTypes/Form.php

| Aspek | Current | Target |
|-------|---------|--------|
| **Facilities** | Tidak ada | Tambah `selected_facilities[]` + sync ke `model_has_facilities` |
| **Images** | Tidak ada | Tambah `images[]` upload + sync ke `media` table |
| **Save** | `RoomType::create($validated)` | Separate sync untuk facilities dan media |

---

## 6. DataTables Update

### 6.1 PropertyDataTable.php

**Current Query:**
```php
public function query(Property $model): Builder
{
    return $model->newQuery(); // No eager loading
}
```

**Required Query:**
```php
public function query(Property $model): Builder
{
    return $model->newQuery()
        ->with(['city', 'host', 'media', 'facilities', 'prices', 'hotel.roomTypes'])
        ->select('properties.*');
}
```

**Current Columns:**
```php
Column::make('id'),
Column::computed('host_name')->title('Host'),
Column::make('property_type')->title('Tipe Properti'),
Column::make('name')->title('Nama'),
Column::make('building_name')->title('Gedung'),
Column::computed('action')
```

**Recommended Columns:**
```php
Column::make('id')->title('ID'),
Column::computed('host_name')->title('Host'),
Column::computed('city_name')->title('Kota'),
Column::make('property_type')->title('Tipe'),
Column::make('booking_mode')->title('Booking Mode'),
Column::make('name')->title('Nama Properti'),
Column::computed('gallery_count')->title('Gallery')->searchable(false),
Column::computed('facilities_count')->title('Fasilitas')->searchable(false),
Column::computed('price_from')->title('Harga Mulai'),
Column::make('status')->title('Status'),
Column::computed('action')
    ->exportable(false)
    ->printable(false)
    ->width(120)
    ->addClass('text-center'),
```

**Computed Columns Implementation:**
```php
->addColumn('city_name', fn(Property $p) => $p->city->name ?? '-')
->addColumn('gallery_count', fn(Property $p) => $p->media->count())
->addColumn('facilities_count', fn(Property $p) => $p->facilities->count())
->addColumn('price_from', fn(Property $p) => 
    $p->prices->min('amount') ?? ($p->hotel?->roomTypes->min('base_price') ?? '-')
)
```

---

## 7. Controllers & Resources yang Sudah Update

### 7.1 PropertyController.php

- ✅ `index()` — eager load `prices`, `city`, `other`, `hotel.roomTypes`, `facilities`, `media`
- ✅ `show()` — eager load + `reviews.user`, `reviews.booking`, `questions.asker`
- ✅ `hostIndex()` — eager load relasional
- ✅ `pricing()` — gunakan `property_prices`
- ✅ `store()` / `update()` — simpan ke tabel relasional

### 7.2 HotelApiController.php

- ✅ `index()` — filter by `hotel.roomTypes`, eager load relasional
- ✅ `show()` — load `policies`, `scoreComponents`, `facilityGroups.facilities`, `transportPoints`, `faqs`, `reviewQuotes`, `roomTypes.inventories`
- ✅ `availableRoomTypes()` — filter by inventory

### 7.3 PropertyResource.php

- ✅ Gallery dari `$property->media` relation (fallback ke JSONB untuk backward compat)
- ✅ Facilities dari `$property->facilities` relation (fallback ke JSONB)
- ✅ Pricing dari `$property->prices` relation
- ✅ Reviews dari `$property->reviews` relation
- ✅ `other` data dari `$property->other` relation

### 7.4 HotelResource.php

- ✅ `facility_groups` dari `$hotel->facilities` relation (group by badge)
- ✅ `transport_points` dari `$hotel->transportPoints` relation
- ✅ `faqs` dari `$hotel->faqs` relation
- ✅ `review_quotes` dari `$hotel->reviewQuotes` relation
- ✅ `policies` dari `$hotel->policy` relation + `HotelNormalizer`
- ✅ `active_room_types` dari `$hotel->activeRoomTypes` + `roomInventories`

---

## 8. Model Accessors & Casts

### 8.1 Property.php

```php
protected $casts = [
    'latitude' => 'decimal:7',
    'longitude' => 'decimal:7',
    'gallery' => 'array',      // backward compat untuk data lama
    'facilities' => 'array',   // backward compat untuk data lama
];

// Relations
public function media(): MorphMany
public function facilities(): MorphToMany
public function hotel(): HasOne
public function reviews(): HasMany
public function bookings(): HasMany

// Accessors (backward compat)
public function galleryUrls(): array
public function coverUrl(): ?string
```

### 8.2 Hotel.php

```php
protected $casts = [
    'star_rating' => 'integer',
    'open_year' => 'integer',
    'deposit_amount' => 'decimal:2',
    'score' => 'array',
    'facility_groups' => 'array',
    'transport_points' => 'array',
    'faqs' => 'array',
    'review_quotes' => 'array',
    'policies' => 'array',
];

// Relations
public function property(): BelongsTo
public function policy(): HasOne
public function scoreComponents(): HasMany
public function facilityGroups(): HasMany
public function facilities(): MorphToMany
public function transportPoints(): HasMany
public function faqs(): HasMany
public function reviewQuotes(): HasMany
public function roomTypes(): HasMany
public function activeRoomTypes(): HasMany

// Accessors (reconstruct dari relasi)
public function getPriceFromAttribute(): ?float
public function getPriceOriginalAttribute(): ?float
public function getOverallScoreAttribute(): ?float
public function getScoreLabelAttribute(): string
public function getReviewCountAttribute(): int
```

### 8.3 RoomType.php

```php
protected $casts = [
    'capacity_adults' => 'integer',
    'capacity_children' => 'integer',
    'max_guests' => 'integer',
    'base_price' => 'decimal:2',
    'price_original' => 'decimal:2',
    'breakfast_included' => 'boolean',
    'total_inventory' => 'integer',
    'has_window' => 'boolean',
    'no_smoking' => 'boolean',
    'free_wifi' => 'boolean',
    'is_active' => 'boolean',
    'facilities' => 'array',    // backward compat
    'images' => 'array',        // backward compat
];

// Relations
public function hotel(): BelongsTo
public function facilities(): MorphToMany
public function media(): MorphMany
public function inventories(): HasMany

// Accessors (handle relasi + JSONB fallback)
public function getImagesAttribute(): array
public function getFacilitiesAttribute(): array

// Scopes
public function scopeAvailableForDates(Builder $query, ...): Builder
public function scopeCapacity(Builder $query, ...): Builder
```

---

## 9. Test Coverage

### 9.1 Test yang Sudah Passing

| Test File | Tests | Status |
|-----------|-------|--------|
| `HotelApiTest` | 27 | ✅ All pass |
| `PropertyControllerTest` | 15 | ✅ All pass |
| `HostHotelTest` | 12 | ✅ All pass |
| `HotelBookingContractTest` | 20 | ✅ All pass |
| `HotelBookingInventoryTest` | 13 | ✅ All pass |
| `HotelSearchSortTest` | 15 | ✅ All pass |
| `HotelWizardFormTest` | 28 | ✅ All pass |
| **Full Suite** | **236** | ✅ **All pass** |

### 9.2 Test yang Perlu Ditambahkan

Setelah Livewire diupdate, tambah test untuk:
- `Livewire/Hotels/FormTest` — create/update hotel dengan relasional data
- `Livewire/Properties/FormTest` — create/update property dengan media & facilities
- `PropertyDataTableTest` — verify columns tampil correct

---

## 10. Backward Compatibility Strategy

### 10.1 JSONB Columns Dipertahankan (Sementara)

Meskipun struktur baru relational, kolom JSONB berikut **dipertahankan** untuk backward compatibility:

| Tabel | Kolom JSONB | Alasan |
|-------|-------------|--------|
| `properties` | `gallery` | Livewire lama masih baca/tulis |
| `properties` | `facilities` | Livewire lama masih baca/tulis |
| `hotels` | `policies` | HotelResource fallback |
| `hotels` | `facility_groups` | HotelResource fallback |
| `hotels` | `transport_points` | HotelResource fallback |
| `hotels` | `faqs` | HotelResource fallback |
| `hotels` | `review_quotes` | HotelResource fallback |
| `hotels` | `score` | HotelResource fallback |
| `room_types` | `facilities` | RoomType accessor fallback |
| `room_types` | `images` | RoomType accessor fallback |

**Setelah semua Livewire diupdate:** Kolom JSONB ini bisa di-drop.

### 10.2 Accessor Fallback Pattern

```php
// PropertyResource.php
$gallery = $this->resource->relationLoaded('media') && $this->resource->media !== null && $this->resource->media->isNotEmpty()
    ? $this->resource->media->pluck('url')->toArray()
    : $this->decodeJson($this->resource->gallery ?? null);

$facilities = $this->resource->relationLoaded('facilities') && $facilitiesRelation !== null && $facilitiesRelation->isNotEmpty()
    ? $facilitiesRelation->pluck('name')->toArray()
    : $this->decodeJson($this->resource->facilities);
```

Pattern ini memastikan:
1. Jika relasi di-load → pakai data relasional
2. Jika tidak → fallback ke JSONB (untuk compatibility)

---

## 11. Checklist Implementasi Lanjutan

### 11.1 Livewire Hotels

- [ ] Update `Hotels/Form.php`:
  - [ ] Ganti 4 JSONB properties jadi `selected_facilities[]`, `transport_points[]`, `faqs[]`, `review_quotes[]`
  - [ ] Update `edit()` load dari tabel relasional
  - [ ] Update `save()` simpan ke tabel relasional
- [ ] Update `Hotels/WizardForm.php`:
  - [ ] Tab 3: sync facilities via `model_has_facilities`
  - [ ] Tab 3: save policies ke `hotel_policies`
  - [ ] Tab 4: save transport points ke `hotel_transport_points`
  - [ ] Tab 4: save faqs ke `hotel_faqs`
  - [ ] Room types: save facilities ke `room_type_facilities` / `model_has_facilities`
  - [ ] Room types: save images ke `media` table
- [ ] Update `Hotels/Form.blade.php`:
  - [ ] Ganti textarea JSON jadi dynamic inputs
- [ ] Update `Hotels/WizardForm.blade.php`:
  - [ ] Update Tab 3 & 4 UI

### 11.2 Livewire Properties

- [ ] Update `Properties/Form.php`:
  - [ ] Gallery upload → `property_media` table
  - [ ] Add facilities input → `model_has_facilities`
- [ ] Update `Properties/WizardForm.php`:
  - [ ] Facilities → `model_has_facilities`
  - [ ] Gallery → `property_media`
- [ ] Update `Properties/Form.blade.php`:
  - [ ] Add facilities UI
  - [ ] Update gallery handling
- [ ] Update `Properties/WizardForm.blade.php`:
  - [ ] Update facilities & gallery tabs

### 11.3 DataTables

- [ ] Update `PropertyDataTable.php`:
  - [ ] Add `city_name` column
  - [ ] Add `booking_mode` column
  - [ ] Add `price_from` computed column
  - [ ] Add `review_count` computed column
  - [ ] Eager load relasi di `query()`
- [ ] Buat `HotelDataTable.php` (jika perlu admin hotel list terpisah)

### 11.4 Admin Views

- [ ] Update `admin/properties/index.blade.php`:
  - [ ] Show new columns dari DataTables
- [ ] Update `admin/properties/edit.blade.php`:
  - [ ] Use relational data
- [ ] Update `admin/properties/create.blade.php`:
  - [ ] Use relational data

### 11.5 Testing

- [ ] Add `Livewire/Hotels/FormTest`
- [ ] Add `Livewire/Properties/FormTest`
- [ ] Add `PropertyDataTableTest`
- [ ] Verify full suite tetap green setelah semua perubahan

---

## 12. Migration Path (JSONB → Relasional)

### 12.1 Backfill Strategy

```php
// Migration script contoh: backfill hotel_policies dari hotels.policies
$hotels = DB::table('hotels')->whereNotNull('policies')->get();
foreach ($hotels as $hotel) {
    $policies = json_decode($hotel->policies, true);
    if ($policies) {
        DB::table('hotel_policies')->insert([
            'hotel_id' => $hotel->id,
            'receptionist_24h' => $policies['receptionist_24h'] ?? true,
            'allow_children' => $policies['allow_children'] ?? true,
            'extra_bed_available' => $policies['extra_bed_available'] ?? true,
            // ... field lainnya
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
```

### 12.2 Drop JSONB Columns (Setelah Livewire Updated)

```sql
-- HAPUS setelah semua Livewire sudah diupdate dan di-test
ALTER TABLE properties DROP COLUMN gallery;
ALTER TABLE properties DROP COLUMN facilities;
ALTER TABLE hotels DROP COLUMN policies;
ALTER TABLE hotels DROP COLUMN score;
ALTER TABLE hotels DROP COLUMN facility_groups;
ALTER TABLE hotels DROP COLUMN transport_points;
ALTER TABLE hotels DROP COLUMN faqs;
ALTER TABLE hotels DROP COLUMN review_quotes;
ALTER TABLE room_types DROP COLUMN facilities;
ALTER TABLE room_types DROP COLUMN images;
DROP TABLE properties_other;
```

---

## 13. Environment & Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Laravel 10+ (PHP 8.1+) |
| **Database** | PostgreSQL (production) / SQLite (testing) |
| **Admin UI** | Livewire + Blade + Metronic theme |
| **API** | RESTful JSON (Flutter consumer) |
| **Testing** | PHPUnit + Laravel TestCase |
| **DataTables** | Yajra DataTables (server-side) |
| **File Storage** | Laravel Storage (public disk) |

---

## 14. Dokumentasi Terkait

- `docs/perbaikan/restruktur_data_properti.md` — Audit lengkap schema
- `docs/perbaikan/implementasi_generate_2.md` — Plan tahapan eksekusi
- `docs/perbaikan/readme_hotels_host.md` — Flutter hotel flow
- `docs/perbaikan/readme_properties_host.md` — Flutter property flow
- `docs/perbaikan/data_ramping.md` — Data migration strategy

---

## 15. Catatan Penting

1. **API Response Shape TIDAK BERUBAH** — Flutter tetap menerima JSON yang sama
2. **Livewire masih pakai JSONB** — Perlu diupdate ke relasional
3. **DataTables belum modified** — Column definitions perlu ditambah
4. **JSONB columns dipertahankan sementara** — Untuk backward compat dengan Livewire lama
5. **Tests already green** — 236/236 passing, jangan break API layer
