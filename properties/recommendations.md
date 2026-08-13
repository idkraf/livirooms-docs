# Property Recommendations

Dokumentasi algoritma rekomendasi properti, section-section yang ditampilkan, kategori POI, dan status implementasi.

## Daftar Isi

- [Konsep Umum](#konsep-umum)
- [Section yang Ditampilkan di Flutter](#section-yang-ditampilkan-di-flutter)
- [API Endpoint](#api-endpoint)
- [Algoritma Rekomendasi](#algoritma-rekomendasi)
- [Kategori POI](#kategori-poi)
- [Status Implementasi](#status-implementasi)
- [Testing](#testing)
- [Referensi File](#referensi-file)

## Konsep Umum

Algoritma kurasi pintar untuk menargetkan pengguna secara relevan.

- **Section khusus** — Properti Terlaris, Properti Terbaru, Unit Premium.
- **Rekomendasi berbasis POI (Point of Interest)** — Apartemen dekat Kampus, Rumah Sakit, Mall, Stasiun, Wisata, hingga Kawasan Industri.

## Section yang Ditampilkan di Flutter

### Layout Home — Carousel Horizontal

Setiap section rekomendasi ditampilkan sebagai **horizontal carousel** (scrollable list) dengan:

- **Header section** (`SectionHeader`) — judul section + tombol "Lihat Semua"
- **PropertyCardCompact** — card properti horizontal (cover image, nama, alamat, harga, rating)

### Section List

| Section Key (Backend) | Label di Flutter | Status |
|----------------------|------------------|--------|
| `newest` | Terbaru | ✅ Sudah ditampilkan |
| `best_seller` | Paling Populer | ✅ Sudah ditampilkan |
| `premium` | Pilihan Premium | ✅ Sudah ditampilkan |
| `poi_based` | Dekat Lokasi Populer | ✅ Sudah ditampilkan |

Semua section di atas menampilkan properti tanpa filter kota di homepage. Homepage juga menampilkan daftar kota; jika kota diklik, user diarahkan ke halaman pencarian dengan filter kota tersebut.

### UI Components

```
HomeScreen
├── CityList (horizontal scroll) — daftar kota, klik untuk lihat properti per kota
├── BannerCarousel (horizontal)
├── SectionHeader("Terbaru") + _HorizontalList
├── SectionHeader("Paling Populer") + _HorizontalList
├── SectionHeader("Pilihan Premium") + _HorizontalList
└── SectionHeader("Dekat Lokasi Populer") + _HorizontalList
```

**File terkait:**
- `flutter/lib/screens/home/home_screen.dart` — HomeScreen, `_FeedBody`, `_HorizontalList`, `CityList`
- `flutter/lib/widgets/property_card.dart` — `PropertyCardCompact`, `SectionHeader`
- `flutter/lib/screens/home/filter_screen.dart` — FilterScreen dengan city dropdown (untuk pencarian)
- `flutter/lib/screens/property/search_results_screen.dart` — SearchResultsScreen menerima `city_id` filter

---

## API Endpoint

### Endpoint

```
GET /api/v1/home
```

- **Public** — tidak memerlukan autentikasi
- Menerima query param opsional `city_id` untuk memfilter banner berdasarkan kota
- Tidak ada filter kota untuk section properti — homepage menampilkan semua properti aktif

### Response Structure

```json
{
  "cities": [
    {
      "id": 1,
      "name": "Jakarta",
      "province": "DKI Jakarta",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "is_active": true
    }
  ],
  "banners": [
    {
      "id": 1,
      "title": "Promo Akhir Tahun",
      "image": "https://...",
      "type": "promo",
      "link_url": "/promo/1"
    }
  ],
  "sections": {
    "newest": [
      {
        "id": 1,
        "name": "Apartemen ABC",
        "address": "Jl. Sudirman No. 1",
        "price_from": 2500000,
        "rating": 4.5,
        "cover": "https://..."
      }
    ],
    "best_seller": [...],
    "premium": [...],
    "poi_based": [...]
  }
}
```

**Catatan:**
- `cities` — daftar kota aktif untuk ditampilkan di homepage Flutter. Setiap kota dapat diklik untuk menampilkan properti di kota tersebut.
- Setiap properti di `sections` sudah termasuk data kota (city) melalui `PropertyResource` jika relasi `city` di-load.

### Data Flow

```
Flutter HomeScreen
  └─> HomeService.home(cityId: _city?.id)
       └─> GET /api/v1/home?city_id={id}
            └─> HomeController::index()
                 ├─> resolveCityId() — dari query param city_id atau legacy city name
                 ├─> City::active() → cities (list kota aktif untuk ditampilkan di homepage)
                 ├─> Banner::with('city') → banners (difilter by city_id jika ada)
                 ├─> PropertyRecommendation::groupBy('type') → best_seller, premium, poi_based
                 └─> Property::latest()->limit(10) → newest (merged dengan curated recommendations)
```

**Alur data:**
1. Flutter request `GET /api/v1/home` tanpa parameter kota (default: semua banner)
2. Backend kembalikan `cities` + `banners` (difilter by city_id jika ada) + `sections` (semua properti aktif, tanpa filter kota)
3. Flutter render daftar kota di homepage sebagai `CityList`
4. Saat user klik kota, Flutter set state `_city` dan navigasi ke `SearchResultsScreen` dengan `city_id` filter
5. HomeScreen reload dengan `city_id` untuk memfilter banner yang ditampilkan
6. `SearchResultsScreen` memanggil `PropertyController::index` dengan `city_id` untuk filter properti

### Backend Controller

**File:** `laravel/app/Http/Controllers/Api/HomeController.php`

```php
public function index(Request $request)
{
    $now = now();

    $sections = $this->recommendations->homeSections($request);
    $cityId = $sections['cityId'];

    $banners = Banner::with('city')
        ->where('is_active', true)
        ->where(fn ($q) => $q->whereNull('starts_at')->orWhere('starts_at', '<=', $now))
        ->where(fn ($q) => $q->whereNull('ends_at')->orWhere('ends_at', '>=', $now))
        ->when($cityId, fn ($q, $id) => $q->where(fn ($w) => $w->whereNull('city_id')->orWhere('city_id', $id)))
        ->orderBy('order')
        ->get(['id', 'title', 'image', 'type', 'link_url', 'city_id']);

    return ApiResponse::success([
        'cities' => CityResource::collection($sections['cities']),
        'banners' => BannerResource::collection($banners),
        'sections' => [
            'newest' => PropertyResource::collection($sections['newest']),
            'best_seller' => PropertyResource::collection($sections['best_seller']),
            'premium' => PropertyResource::collection($sections['premium']),
            'poi_based' => PropertyResource::collection($sections['poi_based']),
        ],
    ], 'Beranda berhasil dimuat.');
}
```

**File:** `laravel/app/Services/RecommendationService.php`

```php
class RecommendationService
{
    public function homeSections(Request $request): array
    {
        $cityId = $this->resolveCityId($request);

        $cities = City::active()
            ->withCount(['properties' => fn ($q) => $q->where('status', 'active')])
            ->orderBy('order')
            ->orderBy('name')
            ->get();

        $recommendations = PropertyRecommendation::with([
                'property' => fn ($q) => $q->where('status', 'active')
                    ->with(['prices', 'city'])->withCount('reviews')->withAvg('reviews', 'rating'),
            ])
            ->orderBy('priority')
            ->get()
            ->groupBy('type')
            ->map(fn ($group) => $group->pluck('property')->filter()->values());

        return [
            'cities' => $cities,
            'newest' => $this->newest($recommendations),
            'best_seller' => $this->section($recommendations, 'best_seller'),
            'premium' => $this->section($recommendations, 'premium'),
            'poi_based' => $this->section($recommendations, 'poi_based'),
            'cityId' => $cityId,
        ];
    }

    private function newest($recommendations, int $limit = 10) { /* ... */ }
    private function section($recommendations, string $key) { /* ... */ }
    private function resolveCityId(Request $request): ?int { /* ... */ }
}
```

**File:** `laravel/routes/api_mobile.php`

```php
Route::get('home', [HomeController::class, 'index']);
Route::get('cities', [CityController::class, 'index']);
Route::get('cities/{city}', [CityController::class, 'show']);
```

**Catatan penting:**
- Homepage **menerima** query param `city_id` untuk memfilter banner, tetapi section properti tetap menampilkan semua properti aktif tanpa filter kota.
- `cities` dikembalikan untuk ditampilkan di homepage Flutter sebagai daftar kota yang dapat diklik.
- Saat user klik kota di homepage, Flutter navigasi ke `SearchResultsScreen` dengan `city_id` filter.
- `city_id` digunakan di endpoint pencarian (`PropertyController::index`) untuk filter properti.
- `newest` section menggabungkan curated recommendations (dari `property_recommendations.type = newest`) dengan auto-fetched newest properties.

---

## Algoritma Rekomendasi

### newest

Ambil properti curated dari `property_recommendations` type `newest`, jika kurang dari 10 tambahkan dari database (urut terbaru).

### best_seller

Ambil dari curated, jika kosong hitung booking dengan status `completed` per property, ambil yang paling banyak.

### premium

Ambil dari curated, jika kosong filter property dengan rating >= 4.5 dan review_count >= 5.

### poi_based

Ambil dari curated type `poi_based` (berdasarkan kategori POI dekat properti).

Semua section menggunakan eager-load: `prices`, `city`, `reviews` count & avg.

---

## Kategori POI

`poi_category` adalah **enum `PoiCategory`** dengan 6 nilai:

| Nilai | Label | Deskripsi |
|-------|-------|-----------|
| `near_campus` | Dekat Kampus | Properti di sekitar area kampus/universitas |
| `near_hospital` | Dekat Rumah Sakit | Properti di sekitar rumah sakit |
| `near_mall` | Dekat Mall | Properti di sekitar pusat perbelanjaan |
| `near_station` | Dekat Stasiun | Properti di sekitar stasiun/terminal |
| `near_tourist` | Dekat Wisata | Properti di sekitar objek wisata |
| `near_industrial` | Dekat Kawasan Industri | Properti di sekitar kawasan industri |

---

## Status Implementasi

### Laravel (Backend)

| Fitur | Status | File |
|-------|--------|------|
| Tabel `property_recommendations` | ✅ | `laravel/database/migrations/2026_07_14_080700_create_property_recommendations_table.php` |
| Model `PropertyRecommendation` | ✅ | `laravel/app/Models/PropertyRecommendation.php` |
| API `GET /api/v1/home` | ✅ | `laravel/app/Http/Controllers/Api/HomeController.php` |
| API `GET /api/v1/cities` | ✅ | `laravel/app/Http/Controllers/Api/CityController.php` |
| Admin CRUD Kota | ✅ | `laravel/app/Livewire/Cities/CityModal.php`, `laravel/app/DataTables/CityDataTable.php` |
| Admin CRUD Rekomendasi | ✅ | `laravel/app/Livewire/PropertyRecommendations/Form.php` |
| Admin DataTable Rekomendasi | ✅ | `laravel/app/DataTables/PropertyRecommendationDataTable.php` |
| PropertyResource | ✅ | `laravel/app/Http/Resources/PropertyResource.php` |
| CityResource | ✅ | `laravel/app/Http/Resources/CityResource.php` |
| Seeder Kota | ✅ | `laravel/database/seeders/CitySeeder.php` (9 kota) |
| Seeder Rekomendasi | ✅ | `laravel/database/seeders/PropertyRecommendationSeeder.php` |
| `poi_category` enum | ✅ | `laravel/app/Enums/PoiCategory.php` |
| GeoDistance helper | ✅ | `laravel/app/Helpers/GeoDistance.php` |
| Automated `best_seller` | ✅ | Fallback by booking count via `RecommendationService::bestSeller()` |
| Automated `premium` | ✅ | Fallback by rating + review_count via `RecommendationService::premium()` |
| POI Model | ✅ | `laravel/app/Models/Poi.php`, migration `2026_08_08_000004_create_pois_table.php` |
| Unit tests | ✅ | `laravel/tests/Unit/` + `laravel/tests/Feature/Api/HomeControllerTest.php` |

### Flutter (Frontend)

| Fitur | Status | File |
|-------|--------|------|
| HomeScreen | ✅ | `flutter/lib/screens/home/home_screen.dart` |
| CityList widget | ✅ | `flutter/lib/widgets/city_list.dart` |
| PropertyCardCompact | ✅ | `flutter/lib/widgets/property_card.dart` |
| SectionHeader | ✅ | `flutter/lib/widgets/property_card.dart` |
| HomeService | ✅ | `flutter/lib/services/home_service.dart` |
| HomeFeed model | ✅ | `flutter/lib/services/home_service.dart` |
| Property model | ✅ | `flutter/lib/models/property.dart` |
| City model | ✅ | `flutter/lib/models/city.dart` |
| CityService | ✅ | `flutter/lib/services/city_service.dart` |
| "Properti Terbaru" section | ✅ | `home_screen.dart` → `_sections['Terbaru']` |
| "Paling Populer" section | ✅ | `home_screen.dart` → `_sections['Paling Populer']` |
| "Pilihan Premium" section | ✅ | `home_screen.dart` → `_sections['Pilihan Premium']` |
| "Dekat Lokasi Populer" section | ✅ | `home_screen.dart` → `_sections['Dekat Lokasi Populer']` |
| City click navigation | ✅ | Navigasi ke `SearchResultsScreen` dengan `city_id` + `cityName` |
| SearchResultsScreen cityId | ✅ | Filter properti by `city_id` dengan removable chip |
| PropertyService.search | ✅ | Support `city_id` parameter |
| PropertyRecommendation Dart model | ✅ | `flutter/lib/models/property_recommendation.dart` |
| Dummy JSON | ✅ | `flutter/assets/json/GET_home.json` |

---

## Yang Belum Diimplementasikan

### Laravel (Backend)

| Fitur | Alasan / Catatan |
|-------|-----------------|
| **Automated `newest` scoring** | Sudah ada merge curated + auto `latest()`, tapi belum ada scoring/algorithm |
| **Personalized recommendation** | Tidak ada algoritma collaborative filtering atau content-based filtering |
| **POI category selector UI** | Tidak ada dropdown/chips untuk pilih kategori POI (kampus, mall, dll) |
| **POI-based search/filter** | Tidak ada filter berdasarkan jarak atau kategori POI |
| **Map integration** | Placeholder "Peta segera hadir" di PropertyDetailScreen |
| **"Lihat Semua" dengan filter type** | Navigasi ke SearchResultsScreen tanpa filter rekomendasi type |
| **Distance calculation di Flutter** | Tidak ada perhitungan jarak dari lokasi user ke properti di sisi client |

### Flutter (Frontend)

| Fitur | Alasan / Catatan |
|-------|-----------------|
| **POI category selector UI** | Tidak ada dropdown/chips untuk pilih kategori POI (kampus, mall, dll) |
| **POI-based search/filter** | Tidak ada filter berdasarkan jarak atau kategori POI |
| **Map integration** | Placeholder "Peta segera hadir" di PropertyDetailScreen |
| **"Lihat Semua" dengan filter type** | Navigasi ke SearchResultsScreen tanpa filter rekomendasi type |
| **Personalized recommendation** | Tidak ada rekomendasi berdasarkan riwayat user/search |
| **Distance calculation di Flutter** | Tidak ada perhitungan jarak dari lokasi user ke properti di sisi client |

---

## Catatan Penting

### Backend

- Section `newest` **menggabungkan** curated recommendations (dari `property_recommendations.type = newest`) dengan auto-fetched newest properties dari `Property::latest()`.
- Section `best_seller` memiliki fallback otomatis berdasarkan jumlah booking completed per properti jika tidak ada curated recommendation.
- Section `premium` memiliki fallback otomatis berdasarkan properti dengan rating >= 4.5 dan review_count >= 5 jika tidak ada curated recommendation.
- Section `poi_based` sepenuhnya dikurasi manual oleh admin.
- `poi_category` adalah **enum `PoiCategory`** dengan 6 nilai: `near_campus`, `near_hospital`, `near_mall`, `near_station`, `near_tourist`, `near_industrial`.
- Homepage **menerima** parameter `city_id` untuk memfilter banner, tetapi section properti tetap menampilkan semua properti aktif tanpa filter kota.
- Homepage mengembalikan `cities` (daftar kota aktif) untuk ditampilkan di Flutter.
- `CityResource` menyertakan `property_count` untuk menampilkan jumlah properti per kota.
- `GeoDistance::haversine()` tersedia untuk perhitungan jarak koordinat (lat/lng).

### Flutter

- Flutter membaca key `newest`, `best_seller`, `premium`, `poi_based` dari response API, dengan `popular` dan `featured` sebagai fallback untuk compatibility dengan backend lama.
- `CityList` ditampilkan di homepage sebelum banner, menampilkan daftar kota yang dapat diklik.
- Saat kota diklik, Flutter navigasi ke `SearchResultsScreen` dengan `city_id` dan `cityName`, kemudian reload homepage dengan `city_id` untuk filter banner.
- `SearchResultsScreen` menampilkan removable chip untuk filter kota yang aktif.
- Tidak ada implementasi algoritma rekomendasi personalisasi di sisi client.
- Homepage header menampilkan lokasi aktif (`Semua Kota, Indonesia` atau `{Nama Kota}, {Provinsi}`).

### City

- Tabel `cities` sudah dibuat dengan kolom `name`, `slug`, `province`, `image`, `latitude`, `longitude`, `is_active`, `order`.
- `properties.city_id` sudah berupa foreign key ke `cities` dengan `nullOnDelete`.
- `banners.city_id` sudah berupa foreign key ke `cities` dengan `nullOnDelete`.
- Homepage menampilkan daftar kota dari `cities` array di response `home`.
- Data kota (`city_id`, `city_name`, `province`) ditampilkan di card properti melalui `PropertyResource`.
- Filter kota hanya diterapkan di halaman pencarian/filter (`PropertyController::index`), bukan di homepage section properti.
- Banner di homepage difilter by `city_id` jika ada, banner tanpa `city_id` (nasional) tetap muncul.
