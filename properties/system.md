# Property System Documentation

Dokumentasi sistem property pada Sewain, meliputi database schema, model, controller, API, implementasi Flutter, status, dan testing.

## Daftar Isi

- [Database Schema & Relasi](#database-schema--relasi)
- [Sistem Masa Tunggu, Status Sewa, & Manajemen Ketersediaan](#sistem-masa-tunggu-status-sewa--manajemen-ketersediaan)
- [Model Laravel](#model-laravel)
- [Controller & API (Laravel)](#controller--api-laravel)
- [Implementasi Flutter](#implementasi-flutter)
- [Status Implementasi](#status-implementasi)
- [Testing](#testing)
- [Catatan & Rekomendasi](#catatan--rekomendasi)

## Database Schema & Relasi

### ER Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          users                                  │
└─────────────────────────────────────────────────────────────────┘
         │ host_id                    │ user_id
         ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        properties                                │
├─────────────────────────────────────────────────────────────────┤
│ id | host_id | city_id | property_type | name | address |       │
│ guest_capacity | bedrooms | facilities(JSON) | gallery(JSON) |  │
│ status (draft|active|inactive|maintenance|fully_booked)        │
└─────────────────────────────────────────────────────────────────┘
         │                            │
         │ property_id                │ property_id
         ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      property_prices                             │
├─────────────────────────────────────────────────────────────────┤
│ id | property_id | price_type(daily|weekly|monthly|yearly)     │
│ amount | cleaning_fee | deposit | service_fee | extra_guest_fee │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      availabilities                              │
├─────────────────────────────────────────────────────────────────┤
│ id | property_id | date | is_available | price_override |      │
│ min_stay | max_stay                                            │
│ UNIQUE: [property_id, date]                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   property_recommendations                       │
├─────────────────────────────────────────────────────────────────┤
│ id | property_id | type(best_seller|newest|premium|poi_based)  │
│ poi_category | priority                                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     property_search_logs                         │
├─────────────────────────────────────────────────────────────────┤
│ id | user_id | keyword | filters(JSON) | results_count | ip    │
└─────────────────────────────────────────────────────────────────┘
```

### Tabel `properties`

Path migration: `laravel/database/migrations/2026_07_14_080100_create_properties_table.php`

```php
Schema::create('properties', function (Blueprint $table) {
    $table->id();
    $table->foreignId('host_id')->constrained('users')->cascadeOnDelete();
    $table->enum('property_type', ['apartment','house','villa','hotel_residence','guest_house','exclusive_kost']);
    $table->string('name');
    $table->string('building_name')->nullable();
    $table->text('description')->nullable();
    $table->text('address');
    $table->decimal('latitude', 10, 7)->nullable();
    $table->decimal('longitude', 10, 7)->nullable();
    $table->unsignedInteger('guest_capacity')->default(1);
    $table->unsignedInteger('bedrooms')->default(1);
    $table->json('facilities')->nullable();
    $table->json('gallery')->nullable();
    $table->enum('status', ['draft','active','inactive','maintenance','fully_booked'])->default('draft');
    $table->timestamps();
});
```

### Tabel `property_prices`

Path migration: `laravel/database/migrations/2026_07_14_080500_create_property_prices_table.php`

```php
Schema::create('property_prices', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete();
    $table->enum('price_type', ['daily','weekly','monthly','yearly']);
    $table->decimal('amount', 15, 2);
    $table->decimal('cleaning_fee', 15, 2)->nullable();
    $table->decimal('deposit', 15, 2)->nullable();
    $table->decimal('service_fee', 15, 2)->nullable();
    $table->decimal('extra_guest_fee', 15, 2)->nullable();
    $table->timestamps();
});
```

### Tabel `availabilities`

Path migration: `laravel/database/migrations/2026_07_14_080400_create_availabilities_table.php`

```php
Schema::create('availabilities', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete();
    $table->date('date');
    $table->boolean('is_available')->default(true);
    $table->decimal('price_override', 15, 2)->nullable();
    $table->unsignedInteger('min_stay')->nullable();
    $table->unsignedInteger('max_stay')->nullable();
    $table->timestamps();
    $table->unique(['property_id', 'date']);
});
```

### Tabel `property_recommendations`

Path migration: `laravel/database/migrations/2026_07_14_080700_create_property_recommendations_table.php`

```php
Schema::create('property_recommendations', function (Blueprint $table) {
    $table->id();
    $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete();
    $table->enum('type', ['best_seller','newest','premium','poi_based']);
    $table->string('poi_category')->nullable();
    $table->unsignedInteger('priority')->default(0);
    $table->timestamps();
});
```

### Tabel `property_search_logs`

Path migration: `laravel/database/migrations/2026_07_14_080200_create_property_search_logs_table.php`

```php
Schema::create('property_search_logs', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
    $table->string('keyword')->nullable();
    $table->json('filters')->nullable();
    $table->unsignedInteger('results_count')->default(0);
    $table->string('ip_address')->nullable();
    $table->timestamps();
});
```

---

## Sistem Masa Tunggu, Status Sewa, & Manajemen Ketersediaan

### Status Properti (properties.status)

Status enum eksklusif: `['draft', 'active', 'inactive', 'maintenance', 'fully_booked']` perlu diperluas atau dikelola secara dinamis berdasarkan okupansi kalender:

- **`active`**: Properti siap disewa dan tampil dalam hasil pencarian.
- **`booked_interim` / `occupied`**: Properti sedang dalam masa sewa aktif oleh penyewa.
- **`turnaround_buffer` (Masa Tunggu)**: Jeda waktu krusial (misal: 1–2 hari setelah masa sewa habis) yang dialokasikan khusus untuk proses *check-out inspection*, pembersihan mendalam (*deep cleaning*), dan perbaikan kecil sebelum properti dibuka kembali untuk penyewa berikutnya.
- **`maintenance`**: Perbaikan berat atau renovasi terjadwal.

### Logika Bisnis Masa Tunggu (Buffer Time & Turnaround)

Ketika sebuah Booking dikonfirmasi selesai/lunas (`completed` atau `checked_in`), sistem backend harus secara otomatis memblokir tanggal transisi pada tabel `availabilities`:

```
[ Check-in ] ══════════════► [ Check-out ] ──► [ Masa Tunggu / Cleaning (1-2 Hari) ] ──► [ Tersedia Kembali]
```

**Penerapan pada Laravel:**

Saat tanggal sewa berakhir pada tanggal `2026-09-10`, sistem secara otomatis menginput baris ke tabel `availabilities`:

- `date`: `2026-09-11` hingga `2026-09-12`
- `is_available`: `false`
- `price_override`: `null`
- `is_buffer`: `true` (opsional, untuk penanda internal)

### Rekomendasi Implementasi

Tambahkan kolom `is_buffer` (boolean) pada tabel `availabilities` untuk membedakan antara date yang tidak tersedia karena booked vs karena buffer/cleaning.

```php
Schema::table('availabilities', function (Blueprint $table) {
    $table->boolean('is_buffer')->default(false)->after('is_available');
});
```

Atau gunakan kolom `note` (string, nullable) untuk menyimpan alasan: `'booked'`, `'buffer'`, `'maintenance'`.

---

## Model Laravel

### Property

Path: `laravel/app/Models/Property.php`

```php
class Property extends Model
{
    protected $casts = ['gallery' => 'array'];

    protected $fillable = [
        'host_id','city_id','property_type','name','building_name',
        'description','address','latitude','longitude',
        'guest_capacity','bedrooms','facilities','gallery','status',
    ];

    public function host() { return $this->belongsTo(User::class, 'host_id'); }
    public function city() { return $this->belongsTo(City::class); }
    public function availabilities() { return $this->hasMany(Availability::class); }
    public function prices() { return $this->hasMany(PropertyPrice::class); }
    public function bookings() { return $this->hasMany(Booking::class); }
    public function reviews() { return $this->hasMany(Review::class); }
}
```

### PropertyPrice

Path: `laravel/app/Models/PropertyPrice.php`

```php
class PropertyPrice extends Model
{
    protected $fillable = [
        'property_id','price_type','amount',
        'cleaning_fee','deposit','service_fee','extra_guest_fee',
    ];

    public function property() { return $this->belongsTo(Property::class); }
}
```

### PropertyRecommendation

Path: `laravel/app/Models/PropertyRecommendation.php`

```php
class PropertyRecommendation extends Model
{
    protected $fillable = ['property_id','type','poi_category','priority'];

    protected $casts = [
        'poi_category' => PoiCategory::class,
    ];

    public function property() { return $this->belongsTo(Property::class); }
}
```

### PropertySearchLog

Path: `laravel/app/Models/PropertySearchLog.php`

```php
class PropertySearchLog extends Model
{
    protected $fillable = [
        'user_id','keyword','filters','results_count','ip_address',
    ];

    public function user() { return $this->belongsTo(User::class); }
}
```

### Availability

Path: `laravel/app/Models/Availability.php`

```php
class Availability extends Model
{
    protected $fillable = [
        'property_id','date','is_available',
        'price_override','min_stay','max_stay',
    ];

    protected $casts = [
        'date' => 'date',
        'is_available' => 'boolean',
    ];

    public function property() { return $this->belongsTo(Property::class); }
}
```

### Relasi Antar Model

```
User (host) ──1:N──► Property ──1:N──► PropertyPrice
                      │
                      ├──1:N──► Availability
                      │
                      ├──1:N──► Booking ──1:1──► Order ──1:1──► Payment
                      │
                      └──1:N──► Review

Property ──1:N──► PropertyRecommendation
City ──1:N──► Property
```

---

## Controller & API (Laravel)

### PropertyController

Path: `laravel/app/Http/Controllers/Api/PropertyController.php`

| Method | Endpoint | Fungsi | Auth |
|--------|----------|--------|------|
| GET | `/api/v1/properties` | List properti dengan filter, search, pagination | Public |
| GET | `/api/v1/properties/{id}` | Detail properti dengan prices, city, host, reviews | Public |
| GET | `/api/v1/properties/{id}/availability` | Kalender ketersediaan properti | Public |
| GET | `/api/v1/host/properties` | List properti milik host yang login | Sanctum |
| POST | `/api/v1/host/properties` | Buat properti baru | Sanctum |
| PUT | `/api/v1/host/properties/{id}` | Update properti | Sanctum |
| POST | `/api/v1/host/properties/gallery/upload` | Upload foto gallery | Sanctum |
| DELETE | `/api/v1/host/properties/{id}/gallery` | Hapus foto dari gallery | Sanctum |
| DELETE | `/api/v1/host/properties/gallery/temp` | Hapus foto temporary | Sanctum |

#### Fitur `index()`
- Filter: `q` (search), `city_id`, `property_type`, `guests`, `bedrooms`, `min_price`, `max_price`
- Sort: `newest`, `price_asc`, `price_desc`, `rating`
- Pagination: `per_page` (max 50)
- Eager-load: `prices`, `city`, `reviews` count & avg
- Log pencarian ke `PropertySearchLog`

#### Fitur `show()`
- Load: `prices`, `host`, `city`
- Count & avg: `reviews`
- Return `PropertyResource`

#### Fitur `availability()`
- Filter by date range: `from`, `to`
- Return: `date`, `is_available`, `price_override`, `min_stay`, `max_stay`

### HomeController & RecommendationService

Path: `laravel/app/Http/Controllers/Api/HomeController.php`

Endpoint: `GET /api/v1/home`

Return structure:

```json
{
  "cities": [...],
  "banners": [...],
  "sections": {
    "newest": [...],
    "best_seller": [...],
    "premium": [...],
    "poi_based": [...]
  }
}
```

Path: `laravel/app/Services/RecommendationService.php`

#### Algoritma Rekomendasi

1. **newest**: Ambil properti curated dari `property_recommendations` type `newest`, jika kurang dari 10 tambahkan dari database (urut terbaru).
2. **best_seller**: Ambil dari curated, jika kosong hitung booking dengan status `completed` per property, ambil yang paling banyak.
3. **premium**: Ambil dari curated, jika kosong filter property dengan rating >= 4.5 dan review_count >= 5.
4. **poi_based**: Ambil dari curated type `poi_based` (berdasarkan kategori POI dekat properti).

Semua section menggunakan eager-load: `prices`, `city`, `reviews` count & avg.

---

## Implementasi Flutter

### Model

Path: `flutter/lib/models/property.dart`

```dart
class PropertyPrice {
  final String priceType;
  final double amount;
  final double? cleaningFee;
  final double? deposit;
  final double? serviceFee;

  factory PropertyPrice.fromJson(Map<String, dynamic> json) => PropertyPrice(
        priceType: json['price_type'] as String,
        amount: _toDouble(json['amount']),
        cleaningFee: _toDoubleOrNull(json['cleaning_fee']),
        deposit: _toDoubleOrNull(json['deposit']),
        serviceFee: _toDoubleOrNull(json['service_fee']),
      );
}

class Property {
  final int id;
  final int hostId;
  final int? cityId;
  final String? cityName;
  final String? province;
  final String propertyType;
  final String name;
  final String? buildingName;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final int guestCapacity;
  final int bedrooms;
  final List<String> facilities;
  final List<String> gallery;
  final String? cover;
  final String status;
  final double? priceFrom;
  final double? rating;
  final int? reviewCount;
  final List<PropertyPrice> prices;

  String get locationLabel {
    if (cityName == null || cityName!.isEmpty) return address;
    if (province == null || province!.isEmpty) return cityName!;
    return '$cityName, $province';
  }
}
```

Path: `flutter/lib/models/property_recommendation.dart`

```dart
class PropertyRecommendation {
  final int? id;
  final int propertyId;
  final String type;
  final String? poiCategory;
  final int priority;
}
```

### Service

Path: `flutter/lib/services/property_service.dart`

```dart
class PropertyService {
  Future<Paginated<Property>> search({
    String? q, int? cityId, String? propertyType,
    int? guests, int? bedrooms, double? minPrice, double? maxPrice,
    String? sort, int page = 1,
  });

  Future<Property> detail(int id);
  Future<Paginated<Review>> reviews(int propertyId, {int page = 1});
  Future<List<String>> availability(int propertyId, {String? from, String? to});
}
```

### Screen: Property Detail

Path: `flutter/lib/screens/property/property_detail_screen.dart`

**Fitur yang ada:**
- Gallery image dengan PageView dan indicator
- Info properti: nama, rating, alamat, kapasitas tamu, kamar
- Fasilitas dengan icon mapping
- Deskripsi dengan expand/collapse
- Map placeholder
- Reviews (max 3)
- Chat pemilik
- Tombol "Pesan Sekarang" → navigasi ke `PaymentMethodScreen`
- Wishlist toggle

**Fitur yang belum ada:**
- Tab layout (Overview, Pricing, Availability, Reviews)
- Price breakdown per tipe durasi
- Host info card
- Similar properties
- Share property
- Report property

### Screen: Search Results & Filter

Path: `flutter/lib/screens/property/search_results_screen.dart`

**Fitur:**
- Search dengan query
- Filter by city, property type, price range, rating, guests
- Pagination infinite scroll
- Wishlist toggle
- Navigasi ke PropertyDetailScreen

Path: `flutter/lib/screens/home/filter_screen.dart`

**Fitur:**
- Property type selector
- Price range slider (0 - 10 juta)
- Rating filter
- Facilities multi-select
- Guest count

### Router

Path: `flutter/lib/router.dart`

```dart
static const propertyDetail = '/property/detail';
static const searchResults = '/search/results';
static const filter = '/search/filter';
```

---

## Audit Modul Add Property / Property Form (Flutter)

### Implementasi Aktual

File yang benar-benar digunakan di aplikasi adalah:

Path: `flutter/lib/screens/mitra/property_form_screen.dart`

Kelas: `PropertyFormScreen`

File `flutter/lib/screens/mitra/add_property_screen.dart` tidak ada di codebase. Dokumentasi sebelumnya mengacu pada `AddPropertyScreen` yang merupakan konsep ideal, bukan implementasi aktual.

### Struktur Form Aktual (`PropertyFormScreen`)

Form penambahan properti di Flutter saat ini berupa **single-screen scrollable form** (bukan tabbed form) dengan field-field berikut:

- Nama Properti
- Tipe Properti (dropdown: hotel, villa, apartment, house, kost)
- Alamat
- Harga per Malam
- Kapasitas Tamu (stepper)
- Kamar Tidur (stepper)
- Deskripsi
- Fasilitas (FilterChip multi-select: WiFi, AC, Pool, Parking, Breakfast, GYM, TV, Kitchen)
- Galeri (horizontal list + image picker)

**Yang TIDAK ADA di form aktual:**
- Building Name
- City Selector (`city_id`)
- Latitude / Longitude
- Harga per tipe durasi (hanya harian)
- Cleaning Fee, Deposit, Service Fee, Extra Guest Fee
- Opsi Draft vs Publish
- Tab-based navigation

### Opsi Draft — Tidak Ada

Saat ini `_submitProperty()` selalu mengirim `'status': 'active'`. Laravel `validateProperty()` menerima `draft` sebagai status valid, tetapi:

1. Tidak ada UI untuk memilih `draft` vs `active`
2. Tidak ada validasi berbeda untuk draft vs active
3. Tidak ada filter "Draft Properties" di host property list
4. Tidak ada count atau notifikasi untuk property yang masih draft

### Audit: Kesalahan & Kelemahan

#### Kesalahan 1: Tipe Properti Tidak Konsisten

**Flutter** `PropertyFormScreen` mendefinisikan:
```dart
static const _types = ['hotel', 'villa', 'apartment', 'house', 'kost'];
```

**Laravel** migration menerima:
```php
['apartment','house','villa','hotel_residence','guest_house','exclusive_kost']
```

**Ketidaksesuaian:**
- `hotel` (Flutter) vs `hotel_residence` (Laravel)
- `kost` (Flutter) vs `exclusive_kost` (Laravel)
- `guest_house` tidak ada di Flutter

Dampak: Host tidak bisa membuat/memilih tipe properti yang valid di Laravel karena nilai yang dikirim Flutter tidak cocok.

#### Kesalahan 2: Payload Harga Tidak Lengkap

Flutter mengirim:
```dart
'prices': [{
  'price_type': 'daily', // HARDCODED
  'amount': ...,
}]
```

Masalah:
- `price_type` selalu `daily`, tidak peduli dropdown (yang pada dasarnya juga tidak berfungsi karena `onChanged: (v) {}` kosong)
- Tidak ada `cleaning_fee`, `deposit`, `service_fee`, `extra_guest_fee` walaupun field di form tidak ada
- Hanya 1 tipe harga yang dikirim, padahal backend mendukung daily/weekly/monthly/yearly

#### Kesalahan 3: Missing `city_id`

Form tidak memiliki selector untuk `city_id`. Laravel `validateProperty()` menerima `city_id` sebagai nullable, tetapi PropertyResource mengandalkan relasi `city` untuk `city_name`. Jika `city_id` null, properti tidak akan memiliki data kota.

#### Kesalahan 4: Missing `building_name`

Form tidak memiliki input untuk `building_name`. Field ini nullable di database, tetapi merupakan data penting untuk apartment/hotel.

#### Kesalahan 5: Gallery Path Handling

```dart
// On upload
final path = await _service.uploadGallery(image.path);
setState(() => _gallery.add(path)); // path adalah URL lengkap dari server

// On remove (edit mode)
final relative = _toRelativePath(removed); // ekstrak relatif dari URL
await _service.deleteGallery(widget.property!.id, relative);
```

`_toRelativePath()` mengharapkan URL berisi `/storage/`, tetapi `_gallery` diinisialisasi dari `widget.property!.gallery` yang bisa berisi path relatif atau URL. Ketidaktelitian ini bisa menyebabkan penghapusan gambar gagal.

#### Kesalahan 6: Tidak Ada Validasi Numerik

Field berikut tidak memiliki `validator`:
- `_guestCapacityController` — tidak ada min 1
- `_bedroomsController` — tidak ada min 1
- `_priceCtrl` — tidak ada validasi angka > 0
- Semua fee controllers — tidak ada validasi

#### Kesalahan 7: Property Type Label Mismatch

```dart
String _typeLabel(String t) {
  switch (t) {
    case 'hotel': return 'Hotel';
    case 'villa': return 'Villa';
    case 'apartment': return 'Apartemen';
    case 'house': return 'Rumah';
    case 'kost': return 'Kost';
    default: return t;
  }
}
```

Label `kost` tidak akurat untuk backend value `exclusive_kost`. Host mungkin bingung memilih tipe mana yang benar.

#### Kelemahan 8: Tidak Ada Autosave

Form panjang tanpa autosave. Jika aplikasi crash atau user accidentally navigate away, semua data hilang.

#### Kelemahan 9: Tidak Ada Preview

Host tidak bisa melihat preview bagaimana properti akan tampil di sisi tenant sebelum publish.

#### Kelemahan 10: Single Price Type per Submit

Backend mendukung multiple price types (daily, weekly, monthly, yearly) untuk 1 properti, tetapi Flutter hanya mengirim 1 price record per request.

### Solusi Terbaik

#### Solusi 1: Perbaiki Tipe Properti

Sinkronisasi enum Flutter dengan Laravel:

```dart
static const _types = [
  'apartment',
  'house',
  'villa',
  'hotel_residence',
  'guest_house',
  'exclusive_kost',
];

String _typeLabel(String t) {
  switch (t) {
    case 'apartment': return 'Apartemen';
    case 'house': return 'Rumah';
    case 'villa': return 'Villa';
    case 'hotel_residence': return 'Hotel Residence';
    case 'guest_house': return 'Guest House';
    case 'exclusive_kost': return 'Exclusive Kost';
    default: return t;
  }
}
```

#### Solusi 2: Tambahkan Tab untuk Harga per Tipe Durasi

Implementasi tabbed form. Setiap tab merepresentasikan satu tipe durasi harga, sehingga host bisa menambahkan harga untuk daily, weekly, monthly, dan yearly sekaligus.

Atau minimal: ubah dropdown tipe harga menjadi multi-select yang menghasilkan array `prices` dengan length > 1.

#### Solusi 3: Tambahkan Opsi Draft

Di `AppBar` atau `bottomNavigationBar`, tambahkan dua aksi:

```dart
bottomNavigationBar: Row(
  children: [
    TextButton.icon(
      onPressed: _saveAsDraft,
      icon: const Icon(Icons.save_outlined),
      label: const Text('Simpan Draft'),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: ElevatedButton(
        onPressed: _saving ? null : _publish,
        child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Publikasikan'),
      ),
    ),
  ],
),
```

Dan di payload:

```dart
Future<void> _saveAsDraft() async {
  await _submit(status: 'draft');
}

Future<void> _publish() async {
  await _submit(status: 'active');
}

Future<void> _submit({required String status}) async {
  // ... build payload with status
}
```

#### Solusi 4: Tambahkan `city_id` dan `building_name`

- Tambahkan `city_id` sebagai `DropdownButtonFormField` dengan data dari endpoint `GET /api/v1/cities`
- Tambahkan `_buildingNameController` dan kirim sebagai `building_name`

#### Solusi 5: Perbaiki Gallery Path Handling

Gunakan flag boolean untuk menandai apakah gallery item adalah URL server atau path lokal:

```dart
class _GalleryItem {
  final String url;
  final bool isServerUrl;
  _GalleryItem(this.url, {this.isServerUrl = true});
}
```

Atau minimal, normalisasi semua URL di `_gallery` menjadi relative path sebelum dikirim ke API:

```dart
'gallery': _gallery.map((url) => _toRelativePath(url)).toList(),
```

#### Solusi 6: Tambahkan Validasi Numerik

```dart
TextFormField(
  controller: _priceCtrl,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Harga per Malam', prefixText: 'Rp '),
  validator: (v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Masukkan harga yang valid';
    return null;
  },
),
```

#### Solusi 7: Autosave ke Local Storage

Gunakan `shared_preferences` atau `hive` untuk menyimpan snapshot form setiap 30 detik atau saat berpindah tab.

```dart
Future<void> _autoSave() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('property_draft', jsonEncode({
    'name': _nameController.text,
    // ... semua field
  }));
}
```

#### Solusi 8: Tambahkan Tab untuk Harga & Biaya

Refactor `PropertyFormScreen` menjadi `TabBarView` dengan 4 tab seperti yang didokumentasikan di Section 7 (konsep ideal). Hal ini memungkinkan:
- Input yang terorganisir
- Validasi per-tab
- UX yang lebih baik untuk form yang panjang

#### Solusi 9: Tambahkan Preview Mode

Tambahkan floating action button atau menu item "Preview" yang menavigasi ke `PropertyDetailScreen` dengan data form saat ini (tanpa menyimpan ke server).

#### Solusi 10: Laravel — Validasi Price Type Uniqueness

Tambahkan validasi di `PropertyController::validateProperty()` atau di model level:

```php
// Di Property model
public static function validatePriceTypes(array $prices): void
{
    $types = array_column($prices, 'price_type');
    if (count($types) !== count(array_unique($types))) {
        throw new \InvalidArgumentException('Tipe harga duplikat.');
    }
}
```

Atau gunakan database unique constraint:

```php
Schema::table('property_prices', function (Blueprint $table) {
    $table->unique(['property_id', 'price_type']);
});
```

#### Solusi 11: Laravel — Draft Handling

Pastikan properti dengan `status = 'draft'`:
- Tidak muncul di endpoint publik `/api/v1/properties`
- Tidak muncul di rekomendasi `/api/v1/home`
- Tidak dihitung dalam statistik host (jika diperlukan, tampilkan terpisah)

Di `PropertyController::index()`:
```php
$query->where('status', 'active'); // draft sudah difilter
```

Di `HomeController` / `RecommendationService`:
```php
Property::where('status', 'active')->... // pastikan draft tidak masuk rekomendasi
```

---

## Status Implementasi

### Yang Sudah Diimplementasikan

| Komponen | File | Deskripsi |
|----------|------|-----------|
| Model Property | `app/Models/Property.php` | Eloquent model dengan relasi lengkap |
| Model PropertyPrice | `app/Models/PropertyPrice.php` | Model harga per property |
| Model PropertyRecommendation | `app/Models/PropertyRecommendation.php` | Model rekomendasi dengan enum type |
| Model PropertySearchLog | `app/Models/PropertySearchLog.php` | Model log pencarian |
| Model Availability | `app/Models/Availability.php` | Model ketersediaan harian |
| PropertyController | `app/Http/Controllers/Api/PropertyController.php` | CRUD + search + availability + gallery |
| HomeController | `app/Http/Controllers/Api/HomeController.php` | Home feed dengan sections |
| RecommendationService | `app/Services/RecommendationService.php` | Algoritma rekomendasi (newest, best_seller, premium, poi_based) |
| PropertyResource | `app/Http/Resources/PropertyResource.php` | JSON resource dengan flat city fields, prices, rating |

#### Flutter

| Komponen | File | Deskripsi |
|----------|------|-----------|
| Model Property | `lib/models/property.dart` | Model dengan prices, city, rating, review_count |
| Model PropertyRecommendation | `lib/models/property_recommendation.dart` | Model rekomendasi |
| PropertyService | `lib/services/property_service.dart` | search, detail, reviews, availability |
| PropertyDetailScreen | `lib/screens/property/property_detail_screen.dart` | Gallery, info, facilities, reviews, chat, book now |
| SearchResultsScreen | `lib/screens/property/search_results_screen.dart` | Hasil pencarian dengan filter dan pagination |
| FilterScreen | `lib/screens/home/filter_screen.dart` | Filter property type, price, rating, facilities, guests |
| HomeScreen | `lib/screens/home/home_screen.dart` | Home feed dengan sections |
| Router | `lib/router.dart` | Route untuk property detail, search, filter |

### Yang Belum Diimplementasikan

#### Laravel

| # | Fitur yang Belum | Keterangan |
|---|------------------|------------|
| 1 | Property Verification/Badge | Tidak ada sistem verifikasi properti |
| 2 | Property Comparison | Tidak ada fitur membandingkan beberapa properti |
| 3 | Property View Count | Tidak ada tracking berapa kali properti dilihat |
| 4 | Property Inquiry/Question | Tidak ada sistem Q&A untuk properti |
| 5 | Property Amenities Categories | Fasilitas masih berupa array of strings |
| 6 | Property Rules/House Rules | Tidak ada aturan rumah |
| 7 | Property Cancellation Policy | Tidak ada kebijakan pembatalan |
| 8 | Property Safety/Health | Tidak ada informasi safety |
| 9 | Property Accessibility | Tidak ada informasi aksesibilitas |
| 10 | Bulk Property Management | Admin tidak bisa bulk update/delete properti |

#### Flutter

| # | Fitur yang Belum | Keterangan |
|---|------------------|------------|
| 1 | Tab di Property Detail | Saat ini semua konten dalam satu scroll |
| 2 | Price Breakdown Tab | Tidak ada tampilan breakdown harga per tipe durasi |
| 3 | Availability Calendar Tab | Tidak ada kalender visual ketersediaan |
| 4 | Host Info Card | Tidak ada informasi detail host |
| 5 | Similar Properties | Tidak ada rekomendasi properti serupa |
| 6 | Share Property | Tidak ada fitur share properti |
| 7 | Property Comparison | Tidak ada fitur bandingkan properti |
| 8 | Map Integration | Map masih placeholder |
| 9 | 360°/Video Tour | Tidak ada support untuk virtual tour |
| 10 | Property Tests | Tidak ada test untuk Property model, PropertyService, atau PropertyDetailScreen |

---

## Rekomendasi Enhancement

### Prioritas Tinggi

#### 1. Tab Layout di Property Detail Screen

**Laravel:** Tidak perlu perubahan backend — data sudah ada di `PropertyResource`.

**Flutter:** Ubah `PropertyDetailScreen` menjadi tab-based dengan 5 tab: Overview, Pricing, Availability, Reviews, Host.

#### 2. Price Breakdown Tab

**Flutter:** Tampilkan semua tipe harga dengan perhitungan subtotal, cleaning fee, service fee, deposit.

#### 3. Availability Calendar Tab

**Laravel:** Endpoint availability sudah ada di `PropertyController`.

**Flutter:** Tampilkan kalender visual dengan blocked dates dari API.

### Prioritas Menengah

#### 4. Host Info Card

**Laravel:** Tambahkan endpoint `GET /api/v1/properties/{id}/host` untuk informasi host.

**Flutter:** Tampilkan host info di tab Host dengan avatar, nama, response rate, total properties.

#### 5. Property View Count

**Laravel:** Tambahkan kolom `view_count` di tabel properties dan increment saat properti dilihat.

**Flutter:** Tampilkan view count di property detail.

#### 6. Similar Properties

**Laravel:** Tambahkan method `similar(int $propertyId)` di `RecommendationService`.

**Flutter:** Tampilkan properti serupa di bagian bawah property detail.

### Prioritas Rendah

#### 7. Share Property

Bagikan properti via share dialog dengan teks yang berisi nama, harga, dan link.

#### 8. Property Comparison

Tambahkan model `PropertyComparison` untuk menyimpan perbandingan hingga 4 properti.

#### 9. Map Integration

Ganti placeholder dengan Google Maps atau Mapbox untuk menampilkan lokasi properti.

#### 10. Virtual Tour / Video

Tambahkan field `virtual_tour_url` atau `video_url` di tabel properties.

---

## Evaluasi Kelemahan Sistem & Solusi Arsitektural

Berikut adalah audit mendalam terhadap kelemahan arsitektur saat ini dan solusi perbaikannya:

| No. | Kelemahan Sistem Saat Ini | Dampak Negatif | Solusi Arsitektural / Perbaikan |
|-----|---------------------------|----------------|--------------------------------|
| **1** | **Atribut Fasilitas Bersifat Unstructured Array (`json('facilities')`)** | Menyulitkan proses *filtering* lanjutan di level SQL/Eloquent saat pengguna ingin memfilter properti berdasarkan fasilitas spesifik. | Ubah relasi fasilitas menjadi tabel normalisasi relasional (`facilities` & `property_facility` pivot table) atau pastikan indeks GIN JSON digunakan di PostgreSQL/MySQL 8 untuk performa query JSON pencarian yang cepat. |
| **2** | **Ketiadaan Mekanisme *Locking* Stok / Tanggal saat Transaksi (*Race Condition*)** | Potensi terjadinya *Double Booking* jika dua pengguna memesan tanggal yang sama persis secara bersamaan. | Implementasikan **Database Transaction & Pessimistic Locking (`lockForUpdate()`)** pada tabel `availabilities` ketika proses *checkout* atau pembuatan *booking* berlangsung di sisi Laravel. |
| **3** | **Manajemen Mata Uang & Format Angka yang Kaku** | Menggunakan tipe data `decimal(15,2)` tanpa informasi mata uang (*currency code*), berisiko jika ekspansi bisnis masuk ke ranah multi-negara. | Tambahkan kolom global atau config mata uang (`currency = 'IDR'`), serta pastikan *formatter* di Flutter menggunakan `intl` package secara konsisten. |
| **4** | **Absennya Validasi Kompleksitas Kebijakan Pembatalan & *Refund*** | Terjadi celah sengketa antara *Host* dan *Tenant* apabila terjadi pembatalan sepihak karena kolom kebijakan belum terstandarisasi di database. | Tambahkan kolom `cancellation_policy` (enum: *flexible, moderate, strict*) pada tabel `properties` beserta aturan persentase pengembalian dana (*refund matrix*). |
| **5** | **Absennya Cache Layer pada Home Feed & Recommendation** | Query rekomendasi kompleks yang melibatkan agregasi rating, review count, dan data spasial POI secara *real-time* dapat membebani database utama saat trafik tinggi. | Terapkan **Redis Caching** untuk endpoint `/api/v1/home` dengan *cache invalidation* otomatis setiap kali ada properti baru atau pembaruan status oleh host. |

### Error & Kelemahan Kritis Lainnya

| No. | Kelemahan Sistem Saat Ini | Dampak Negatif | Solusi Arsitektural / Perbaikan |
|-----|---------------------------|----------------|--------------------------------|
| **6** | **Ketidaksesuaian Nilai Enum Tipe Properti (Flutter vs Laravel)** | Flutter mengirim `'hotel'` dan `'kost'`, Laravel migration menerima `'hotel_residence'` dan `'exclusive_kost'`. Proses create/update properti dari mobile akan gagal dengan validation error 422. | Sinkronisasi enum Flutter dengan Laravel migration. Semua nilai di Flutter harus sama persis dengan yang didefinisikan di migration Laravel. |
| **7** | **Payload Harga di Flutter Sangat Terbatas (Single-Price & Hardcoded)** | Flutter mengirim `price_type` hardcoded ke `'daily'` dan mengabaikan biaya-biaya lain. | Tambahkan input untuk multiple price types dan biaya tambahan (cleaning_fee, deposit, service_fee, extra_guest_fee). |
| **8** | **Struktur Data Fasilitas yang Belum Ternormalisasi (Unstructured JSON)** | Kolom `facilities` masih disimpan sebagai JSON array biasa, memperlambat proses filtering lanjutan di level SQL/Eloquent saat skala data tumbuh. | Ubah relasi fasilitas menjadi tabel normalisasi relasional (`facilities` & `property_facility` pivot table) atau pastikan indeks GIN JSON digunakan. |
| **9** | **Kurangnya Validasi Form Sisi Klien & State Preservation** | Form penambahan properti tidak memiliki validasi numerik yang ketat dan tidak memiliki fitur penyimpanan draft lokal. Jika aplikasi crash atau user accidentally navigate away, semua data hilang. | Tambahkan validasi numerik di semua field yang memerlukan angka. Implementasikan autosave ke local storage (shared_preferences atau hive) setiap 30 detik atau saat berpindah tab. Tambahkan draft/publish toggle. |

---

## Testing

### Laravel Tests

Path: `laravel/tests/Feature/Api/PropertyControllerTest.php`

```php
<?php

namespace Tests\Feature\Api;

use App\Models\City;
use App\Models\Property;
use App\Models\PropertyPrice;
use App\Models\PropertyRecommendation;
use App\Models\PropertySearchLog;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PropertyControllerTest extends TestCase
{
    use RefreshDatabase;

    private User $host;
    private User $tenant;
    private City $city;
    private Property $property;

    protected function setUp(): void
    {
        parent::setUp();

        $this->city = City::create([
            'name' => 'Jakarta',
            'slug' => 'jakarta',
            'province' => 'DKI Jakarta',
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'is_active' => true,
            'order' => 0,
        ]);

        $this->host = User::create([
            'name' => 'Test Host',
            'email' => 'host' . uniqid() . '@test.com',
            'password' => bcrypt('password'),
            'email_verified_at' => now(),
        ]);

        $this->tenant = User::create([
            'name' => 'Test Tenant',
            'email' => 'tenant' . uniqid() . '@test.com',
            'password' => bcrypt('password'),
            'email_verified_at' => now(),
        ]);

        $this->property = Property::create([
            'host_id' => $this->host->id,
            'city_id' => $this->city->id,
            'property_type' => 'apartment',
            'name' => 'Test Apartment',
            'building_name' => 'Tower A',
            'description' => 'Nice apartment',
            'address' => 'Jl. Test No. 1',
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'guest_capacity' => 2,
            'bedrooms' => 1,
            'facilities' => json_encode(['wifi', 'ac', 'pool']),
            'gallery' => json_encode(['https://example.com/img1.jpg']),
            'status' => 'active',
        ]);

        PropertyPrice::create([
            'property_id' => $this->property->id,
            'price_type' => 'daily',
            'amount' => 500000,
            'cleaning_fee' => 50000,
            'deposit' => 100000,
            'service_fee' => 25000,
        ]);
    }

    public function test_index_returns_active_properties(): void
    {
        $response = $this->get('/api/v1/properties');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'code',
                'message',
                'data' => [
                    'data' => [
                        '*' => [
                            'id','host_id','city_id','property_type','name','address',
                            'guest_capacity','bedrooms','facilities','gallery','cover',
                            'status','city_name','province','price_from','rating',
                            'review_count','prices' => [
                                '*' => [
                                    'price_type','amount','cleaning_fee',
                                    'deposit','service_fee',
                                ],
                            ],
                        ],
                    ],
                    'meta' => ['current_page','last_page','per_page','total'],
                ],
            ]);
    }

    public function test_index_filters_by_city(): void
    {
        $response = $this->get('/api/v1/properties?city_id=' . $this->city->id);
        $response->assertStatus(200);
        $data = $response->json('data.data');

        foreach ($data as $property) {
            $this->assertSame($this->city->id, $property['city_id']);
        }
    }

    public function test_index_filters_by_property_type(): void
    {
        $response = $this->get('/api/v1/properties?property_type=apartment');
        $response->assertStatus(200);
        $data = $response->json('data.data');

        foreach ($data as $property) {
            $this->assertSame('apartment', $property['property_type']);
        }
    }

    public function test_index_searches_by_keyword(): void
    {
        $response = $this->get('/api/v1/properties?q=Test');
        $response->assertStatus(200);
        $data = $response->json('data.data');

        $this->assertTrue(count($data) > 0);
        $found = false;
        foreach ($data as $property) {
            if (stripos($property['name'], 'Test') !== false ||
                stripos($property['address'], 'Test') !== false) {
                $found = true;
                break;
            }
        }
        $this->assertTrue($found, 'Expected to find property matching keyword "Test"');
    }

    public function test_index_filters_by_price_range(): void
    {
        $response = $this->get('/api/v1/properties?min_price=100000&max_price=1000000');
        $response->assertStatus(200);
        $data = $response->json('data.data');

        foreach ($data as $property) {
            $this->assertNotEmpty($property['prices']);
            $prices = array_column($property['prices'], 'amount');
            $this->assertTrue(min($prices) >= 100000 && max($prices) <= 1000000);
        }
    }

    public function test_show_returns_property_detail(): void
    {
        $response = $this->get('/api/v1/properties/' . $this->property->id);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'id' => $this->property->id,
                    'name' => 'Test Apartment',
                    'city_name' => $this->city->name,
                ],
            ]);
    }

    public function test_show_includes_prices_and_reviews(): void
    {
        Review::create([
            'booking_id' => 1,
            'property_id' => $this->property->id,
            'user_id' => $this->tenant->id,
            'rating' => 5,
            'comment' => 'Great!',
        ]);

        $response = $this->get('/api/v1/properties/' . $this->property->id);
        $data = $response->json('data');

        $this->assertNotEmpty($data['prices']);
        $this->assertEquals(1, $data['review_count']);
        $this->assertEquals(5.0, $data['rating']);
    }

    public function test_availability_returns_correct_dates(): void
    {
        Availability::create([
            'property_id' => $this->property->id,
            'date' => '2026-09-01',
            'is_available' => false,
            'price_override' => 600000,
            'min_stay' => 2,
            'max_stay' => 7,
        ]);

        $response = $this->get('/api/v1/properties/' . $this->property->id . '/availability?from=2026-09-01&to=2026-09-30');
        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertNotEmpty($data);
        $this->assertEquals('2026-09-01', $data[0]['date']);
        $this->assertFalse($data[0]['is_available']);
    }

    public function test_host_index_returns_user_properties(): void
    {
        $this->actingAs($this->host, 'sanctum');

        $response = $this->get('/api/v1/host/properties');
        $response->assertStatus(200);
        $data = $response->json('data.data');

        $this->assertNotEmpty($data);
        $this->assertEquals($this->host->id, $data[0]['host_id']);
    }

    public function test_host_can_create_property(): void
    {
        $this->actingAs($this->host, 'sanctum');

        $response = $this->post('/api/v1/host/properties', [
            'city_id' => $this->city->id,
            'property_type' => 'villa',
            'name' => 'New Villa',
            'address' => 'Jl. Villa No. 1',
            'guest_capacity' => 4,
            'bedrooms' => 2,
            'facilities' => ['wifi', 'pool'],
            'gallery' => ['https://example.com/villa.jpg'],
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => true,
                'message' => 'Properti berhasil dibuat.',
            ]);
    }

    public function test_host_can_update_own_property(): void
    {
        $this->actingAs($this->host, 'sanctum');

        $response = $this->put('/api/v1/host/properties/' . $this->property->id, [
            'name' => 'Updated Apartment',
            'description' => 'Updated description',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'name' => 'Updated Apartment',
                ],
            ]);
    }
}
```
