# 03. Logika Backend & Filter Dinamis (Daily Hotel Booking)

Dokumen ini mendokumentasikan spesifikasi query controller, validasi request, dan optimasi *Query Builder* Laravel untuk menangani pencarian & filter harian hotel berbasis parameter lokasi, rentang tanggal *check-in/check-out*, jumlah kamar & tamu, rating bintang, serta fasilitas cepat.

> 🔴 **Endpoint pencarian hotel bukan `GET properties`.** Dokumen ini semula menempelkan seluruh logika hotel pada [`PropertyController.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/PropertyController.php); yang berjalan sekarang adalah [`HotelApiController::index()`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/HotelApiController.php) di `GET /api/v1/hotels`. Keduanya **tidak** menerima kumpulan parameter yang sama — mengirim `sort=score_desc` atau `flex_days` ke `GET properties` menghasilkan **422**. Itulah isi item [F-1](screen/readme_screen.md#152-flutter): `HotelSearchProvider` dulu memanggil `PropertyService.searchHotels()` → `GET properties`, dan sudah dialihkan 16 Agt 2026. **Baca [§1.1](#11-kamus-nilai-sort--ui--server-terverifikasi) lebih dulu** — blok skema di §1 adalah spesifikasi historis untuk jalur unit, bukan kontrak hotel yang berlaku.

---

## 1. Validasi & Parameter Request API Search

Endpoint pencarian **unit** (kos/apartemen/villa) adalah `GET /api/v1/properties`. Pencarian **hotel** memakai `GET /api/v1/hotels` — skemanya ada di [§1.1](#11-kamus-nilai-sort--ui--server-terverifikasi).

### Skema Validasi Input Request (`FormRequest` / Validator)

```php
$validated = $request->validate([
    'q'                   => 'nullable|string|max:100',
    'city_id'             => 'nullable|integer|exists:cities,id',
    'property_type'       => 'nullable|string|in:apartment,house,villa,hotel_residence,guest_house,exclusive_kost,hotel',
    'booking_mode'        => 'nullable|string|in:unit,room',
    
    // Rentang Tanggal Harian Hotel (OTA Flow)
    'check_in'            => 'nullable|date_format:Y-m-d|after_or_equal:today',
    'check_out'           => 'nullable|date_format:Y-m-d|after:check_in',
    
    // Kamar & Kapasitas Tamu
    'rooms_count'         => 'nullable|integer|min:1|max:10',
    'adults'              => 'nullable|integer|min:1|max:30',
    'children'            => 'nullable|integer|min:0|max:20',
    
    // Quick Filter Chips (Referensi UI)
    'star_rating'         => 'nullable|array',
    'star_rating.*'       => 'integer|min:1|max:5',
    'facilities'          => 'nullable|array',
    'facilities.*'        => 'string',
    'breakfast_included'  => 'nullable|boolean',
    
    // Harga & Rating
    'min_price'           => 'nullable|numeric|min:0',
    'max_price'           => 'nullable|numeric|min:0',
    'min_rating'          => 'nullable|numeric|min:1|max:5',
    
    // Sorting & Paginasi
    'sort'                => 'nullable|string|in:newest,price_asc,price_desc,rating,popularity',
    'per_page'            => 'nullable|integer|min:1|max:50',
    'page'                => 'nullable|integer|min:1',
]);
```

> ⚠️ **`popularity` di atas adalah spesifikasi, BUKAN kondisi kode — dan tidak diterima controller mana pun.** `PropertyController::index()` memakai
> `'sort' => ['nullable', 'in:newest,price_asc,price_desc,rating']` ([PropertyController.php:42](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/PropertyController.php)); `HotelApiController::index()` memakai daftar 7 nilai di [§1.1](#11-kamus-nilai-sort--ui--server-terverifikasi). `sort=popularity` **ditolak 422** di keduanya, bukan diabaikan. Nilai ini tidak pernah diimplementasikan — jangan dikirim.

### 1.1 Kamus Nilai `sort` — UI ↔ Server (terverifikasi)

Skema yang berlaku untuk pencarian hotel, dari `HotelApiController::index()` baris 27–47:

```php
'sort'  => ['nullable', 'in:newest,price_asc,price_desc,rating,distance,star_desc,score_desc'],
// Titik acuan untuk `sort=distance`. Keduanya wajib ada, atau tidak dipakai sama sekali.
'lat'   => ['nullable', 'numeric', 'between:-90,90',  'required_with:lng'],
'lng'   => ['nullable', 'numeric', 'between:-180,180', 'required_with:lat'],
'q'         => ['nullable', 'string', 'max:100'],
'flex_days' => ['nullable', 'integer', 'min:1', 'max:3'],
```

`lat`/`lng` bersifat **berpasangan**: mengirim salah satunya saja → 422 pada field yang hilang (`required_with`). Di luar rentang → 422. Dijaga oleh T-L11.

Bottom sheet **Urutkan** ([mockup](screen/_build/html/result_pencarian_bottom_modal_filter_urutkan.html), layar #9) punya **4 opsi**. Pemetaannya ke `HotelApiController::index()` baris 106–120:

| Label UI | Nilai `sort` | Implementasi server | Status |
|---|---|---|---|
| Rekomendasi *(default terpilih)* | kosongkan, atau `score_desc` | `orderByDesc('score')` | ✅ ada — peringkat relevansi, bukan `latest()` |
| Harga terendah | `price_asc` | `withMin('activeRoomTypes as min_price', 'base_price')->orderBy('min_price')` | ✅ ada |
| Rating tertinggi | `rating` | `orderByDesc('score')` | ✅ ada |
| Jarak terdekat | `distance` + `lat` + `lng` | `orderByDistance()` — delta kuadrat lat/lng, sumbu bujur diskalakan `cos²(lat)` | ✅ **ada sejak 16 Agt 2026** ([L-6](screen/readme_screen.md#151-laravel)) |

**Catatan tambahan:** `newest` juga memetakan ke `orderByDesc('score')`, bukan `latest()` — jadi `newest`, `rating`, `score_desc`, dan default menghasilkan urutan **identik** pada endpoint hotel. `star_desc` adalah satu-satunya nilai yang mengurutkan menurut bintang.

**"Jarak terdekat" dulu adalah tombol yang tidak berefek.** Sebelum L-6, `'distance'` jatuh ke arm `orderByDesc('star_rating')` — chip itu mengembalikan **peringkat bintang** yang berpenampilan seperti jawaban benar. Yang berlaku sekarang:

- `distance` **dengan** `lat`+`lng` → diurutkan dari titik acuan; hotel tanpa koordinat dipaksa ke urutan **terakhir** lewat `orderByRaw('case when … is null then 1 else 0 end asc')`, karena posisi `NULL` berbeda antar-engine.
- `distance` **tanpa** origin → turun ke **relevansi** (`orderByDesc('score')`), bukan bintang. Degradasi ini disengaja dan diuji: T-L10 membandingkan tiga panggilan API hidup dan menuntut hasilnya **sama dengan** `score_desc` serta **berbeda dari** `star_desc`.
- Rumusnya planar, bukan haversine (tanpa `radians()`/`acos()`): monoton terhadap jarak sebenarnya pada skala kota — cukup untuk `ORDER BY` — dan berperilaku sama di PostgreSQL maupun SQLite tempat suite berjalan.

Test terkait: T-L9…T-L11 di [`HotelSearchSortTest.php`](../../laravel/tests/Feature/Api/HotelSearchSortTest.php). Fixture-nya sengaja menaruh hotel terdekat pada bintang **terendah**, sehingga peringkat bintang tidak bisa lolos menyamar sebagai jarak. Sisi Flutter: `HotelSearchQuery` mengirim `sort=distance` beserta `lat`/`lng` hanya bila origin lengkap ([F-2](screen/readme_screen.md#152-flutter), grup test `sort: distance`).

Lihat juga [A-D9](screen/readme_screen.md#113-drift-kontrak-flutter--laravel) — temuan aslinya, kini tertutup.

### 1.2 Filter "Kebutuhan" (`needs[]`) & `children_ages[]`

Chip **Kebutuhan** pada layar hasil pencarian memakai nilai-nilai berikut (dari mockup; sisi server **belum** memvalidasi daftar ini):

| Nilai | Label UI |
|---|---|
| `family_room` | Kamar Keluarga |
| `kids_activities` | Aktivitas untuk anak |
| `breakfast_included` | Termasuk sarapan |
| `family_friendly` | Disukai keluarga |
| `strategic_location` | Lokasi strategis |

> ✅ **`children_ages[]` sudah didukung sejak 16 Agt 2026** ([L-5](screen/readme_screen.md#151-laravel)). Sebelumnya UI pemilih umur anak (layar #14–#16) mengumpulkan umur per anak tetapi `BookingController::store()` tidak memvalidasi maupun menyimpannya — data **hilang** saat submit, padahal aturan "Anak Menginap Gratis" bergantung padanya ([A-D2](screen/readme_screen.md#113-drift-kontrak-flutter--laravel)). Yang berlaku sekarang:
>
> ```php
> 'children_ages'   => ['nullable', 'array', 'max:10'],
> 'children_ages.*' => ['integer', 'min:0', 'max:17'],
> ```
>
> Disimpan ke kolom jsonb `bookings.children_ages` (cast `array`). **List kosong menjadi `null`**, bukan `[]` — `array_values($data['children_ages'])` hanya dipanggil bila `!empty()`, karena `[]` akan terbaca sebagai "0 anak dengan umur tak diketahui" sedangkan `null` berarti "tidak dikirim". Umur > 17 → 422 pada `children_ages.0`. Dijaga T-L25; sisi Flutter memastikan list kosong **tidak** dikirim (`hotel_service_test.dart`).

> 🟠 **`needs[]` masih belum divalidasi server.** Daftar nilai di atas berasal dari mockup; `HotelApiController::index()` tidak menerima parameter `needs`. Chip ini belum punya efek apa pun di backend.

---

## 2. Arsitektur Query Builder (`PropertyController::index`)

Berikut adalah implementasi refactored dari `PropertyController::index()` yang mendukung *dual-mode* (sewa unit kos/apartemen & sewa kamar hotel harian).

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PropertyResource;
use App\Models\Property;
use App\Models\PropertyPrice;
use App\Models\RoomInventory;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PropertyController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $data = $request->validate([
            'q'                  => 'nullable|string',
            'city_id'            => 'nullable|integer',
            'property_type'      => 'nullable|string',
            'booking_mode'       => 'nullable|string|in:unit,room',
            'check_in'           => 'nullable|date_format:Y-m-d',
            'check_out'          => 'nullable|date_format:Y-m-d',
            'rooms_count'        => 'nullable|integer|min:1',
            'adults'             => 'nullable|integer|min:1',
            'children'           => 'nullable|integer|min:0',
            'star_rating'        => 'nullable|array',
            'facilities'         => 'nullable|array',
            'breakfast_included' => 'nullable|boolean',
            'min_price'          => 'nullable|numeric',
            'max_price'          => 'nullable|numeric',
            'min_rating'         => 'nullable|numeric',
            'sort'               => 'nullable|string',
            'per_page'           => 'nullable|integer',
        ]);

        $query = Property::query()
            ->where('status', 'active')
            ->with(['city', 'hotel', 'prices', 'masterFacilities']);

        // 1. Filter Kata Kunci & Lokasi
        if (!empty($data['q'])) {
            $q = $data['q'];
            $query->where(function (Builder $b) use ($q) {
                $b->where('name', 'ilike', "%{$q}%")
                  ->orWhere('address', 'ilike', "%{$q}%")
                  ->orWhereHas('city', function (Builder $cb) use ($q) {
                      $cb->where('name', 'ilike', "%{$q}%");
                  });
            });
        }

        if (!empty($data['city_id'])) {
            $query->where('city_id', $data['city_id']);
        }

        // 2. Filter Tipe Properti & Booking Mode
        if (!empty($data['property_type'])) {
            $query->where('property_type', $data['property_type']);
        }

        if (!empty($data['booking_mode'])) {
            $query->where('booking_mode', $data['booking_mode']);
        }

        // 3. Filter Rating Bintang Hotel (1-5 Bintang)
        if (!empty($data['star_rating'])) {
            $stars = array_map('intval', (array) $data['star_rating']);
            $query->whereHas('hotel', function (Builder $hq) use ($stars) {
                $hq->whereIn('star_rating', $stars);
            });
        }

        // 4. Filter Ketersediaan Tanggal & Stok Kamar OTA
        if (!empty($data['check_in']) && !empty($data['check_out'])) {
            $checkIn = Carbon::parse($data['check_in']);
            $checkOut = Carbon::parse($data['check_out']);
            $roomsCount = (int) ($data['rooms_count'] ?? 1);
            $adults = (int) ($data['adults'] ?? 1);
            $children = (int) ($data['children'] ?? 0);

            // Rentang tanggal eksklusif check-out: [check_in, check_out)
            $period = CarbonPeriod::create($checkIn, $checkOut->copy()->subDay());
            $dates = [];
            foreach ($period as $dt) {
                $dates[] = $dt->format('Y-m-d');
            }
            $nightsCount = count($dates);

            $query->where(function (Builder $bq) use ($dates, $nightsCount, $roomsCount, $adults, $children) {
                // Cabang A: Mode Hotel (Cek Ketersediaan RoomType & RoomInventory)
                $bq->where(function (Builder $hq) use ($dates, $nightsCount, $roomsCount, $adults, $children) {
                    $hq->where('booking_mode', 'room')
                      ->whereHas('hotel.roomTypes', function (Builder $rtq) use ($dates, $nightsCount, $roomsCount, $adults, $children) {
                          $rtq->where('is_active', true)
                              ->where('capacity_adults', '>=', $adults)
                              ->where('max_guests', '>=', ($adults + $children))
                              ->whereHas('inventories', function (Builder $iq) use ($dates, $roomsCount) {
                                  $iq->whereIn('date', $dates)
                                     ->where('is_closed', false)
                                     ->whereRaw('(allotment - booked_count) >= ?', [$roomsCount]);
                              }, '=', $nightsCount); // Wajib tersedia penuh untuk setiap malam
                      });
                })
                // Cabang B: Mode Unit Kos/Apartemen Bulanan (Eksisting)
                ->orWhere(function (Builder $uq) use ($dates) {
                    $uq->where('booking_mode', 'unit')
                       ->whereDoesntHave('bookings', function (Builder $bkq) use ($dates) {
                           $bkq->whereNotIn('status', ['cancelled', 'expired'])
                               ->where(function (Builder $ovq) use ($dates) {
                                   $ovq->whereIn('check_in', $dates)
                                       ->orWhereIn('check_out', $dates);
                               });
                       });
                });
            });
        }

        // 5. Filter Sarapan Gratis (Termasuk Sarapan)
        if (!empty($data['breakfast_included'])) {
            $query->whereHas('hotel.roomTypes', function (Builder $rtq) {
                $rtq->where('breakfast_included', true);
            });
        }

        // 6. Filter Fasilitas Cepat (Kolam Renang, Wi-Fi, AC, Parking, Gym)
        if (!empty($data['facilities'])) {
            $facilities = (array) $data['facilities'];
            foreach ($facilities as $fac) {
                $slug = strtolower(trim($fac));
                $query->where(function (Builder $fq) use ($slug) {
                    // Cek di masterFacilities relasional ATAU di mirror JSON properties.facilities
                    $fq->whereHas('masterFacilities', function (Builder $mfq) use ($slug) {
                        $mfq->where('slug', $slug);
                    })->orWhereJsonContains('facilities', $slug);
                });
            }
        }

        // 7. Filter Rating Minimum Pengguna
        if (!empty($data['min_rating'])) {
            $query->withAvg('reviews', 'rating')
                  ->havingRaw('COALESCE(reviews_avg_rating, 0) >= ?', [(float) $data['min_rating']]);
        }

        // 8. Sorting Berdasarkan Harga / Rating
        $sort = $data['sort'] ?? 'newest';
        if ($sort === 'rating') {
            $query->withAvg('reviews', 'rating')->orderByDesc('reviews_avg_rating');
        } elseif ($sort === 'price_asc' || $sort === 'price_desc') {
            // Correlated Subquery untuk mengambil tarif terendah (Unit vs Room)
            $cheapestPriceSubquery = PropertyPrice::selectRaw('min(amount)')
                ->whereColumn('property_prices.property_id', 'properties.id');

            $direction = $sort === 'price_asc' ? 'asc' : 'desc';
            $query->orderBy($cheapestPriceSubquery, $direction);
        } else {
            $query->latest();
        }

        // Execution Paginasi
        $perPage = (int) ($data['per_page'] ?? 15);
        $paginator = $query->paginate($perPage);

        return ApiResponse::paginated(
            PropertyResource::collection($paginator),
            'Berhasil mengambil daftar properti dan hotel'
        );
    }
}
```

---

## 3. Ekstensi `PropertyResource` untuk Format JSON Standard

File [`laravel/app/Http/Resources/PropertyResource.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Resources/PropertyResource.php) diperbarui agar memberikan metadata spesifik hotel untuk UI Flutter:

> ⚠️ **Cuplikan di bawah adalah kode nyata per 16 Agt 2026, bukan rancangan.** Versi lama dokumen ini menuliskan `$this->hotel->roomTypes->min('base_price')` **tanpa** filter `is_active` — itu memang kode yang dulu berjalan, dan justru itulah [A-D13](screen/readme_screen.md#113-drift-kontrak-flutter--laravel): `GET properties` dan `GET hotels` menjawab harga berbeda untuk hotel yang sama. Sejak [L-9](screen/readme_screen.md#151-laravel) resource ini **mendelegasikan** ke accessor `Hotel::price_from`/`price_original`, jadi tidak ada lagi dua implementasi harga hotel. Bila Anda mengubah salah satunya, ubah accessor-nya — bukan resource ini.

```php
public function toArray(Request $request): array
{
    $cheapestPrice = null;
    $priceOriginal = null;

    // `booking_mode === 'room'` adalah diskriminator kanonik (bukan keberadaan baris
    // `hotels`), dan `relationLoaded('roomTypes')` wajib diperiksa — tanpa itu
    // accessor akan memicu lazy-load 1 query per properti.
    $hotelLoaded = $this->booking_mode === 'room'
        && $this->relationLoaded('hotel')
        && $this->hotel
        && $this->hotel->relationLoaded('roomTypes');

    if ($hotelLoaded) {
        $cheapestPrice = $this->hotel->price_from;      // float | null — tipe kamar AKTIF termurah
        $priceOriginal = $this->hotel->price_original;  // harga coret tipe kamar YANG SAMA
    }

    // `property_prices` adalah tabel tarif mode unit, jadi tidak boleh menyelamatkan
    // hotel yang tak punya tipe kamar aktif — `null` adalah kontrak "tak ada tarif".
    if ($cheapestPrice === null && $this->booking_mode !== 'room' && $this->relationLoaded('prices')) {
        $cheapestPrice = optional($this->prices->sortBy('amount')->first())->amount;
    }

    return [
        'id'             => $this->id,
        'name'           => $this->name,
        'property_type'  => $this->property_type,
        'booking_mode'   => $this->booking_mode ?? 'unit', // 'unit' | 'room'
        'city_name'      => $this->relationLoaded('city') ? $this->city?->name : null,
        'address'        => $this->address,
        'star_rating'    => $this->relationLoaded('hotel') && $this->hotel ? $this->hotel->star_rating : null,
        'check_in_time'  => $this->relationLoaded('hotel') && $this->hotel ? $this->hotel->check_in_time : null,
        'check_out_time' => $this->relationLoaded('hotel') && $this->hotel ? $this->hotel->check_out_time : null,
        'price_from'     => $cheapestPrice,
        'price_original' => $priceOriginal,
        'rating'         => $this->when(isset($this->reviews_avg_rating), fn () => round((float) $this->reviews_avg_rating, 1)),
        'review_count'   => $this->when(isset($this->reviews_count), fn () => (int) $this->reviews_count),
        'cover_image'    => $gallery[0] ?? null,
        'facilities'     => $facilities ?? [],
        'has_breakfast'  => $hotelLoaded ? $this->hotel->roomTypes->where('is_active', true)->contains('breakfast_included', true) : false,
        // ...selebihnya lihat file aslinya
    ];
}
```

**Beda dari versi dokumen sebelumnya** (semua sudah dikoreksi di atas):

| Klaim lama | Kenyataan |
|---|---|
| `min('base_price')` lintas semua tipe kamar | accessor `Hotel::price_from`, hanya tipe kamar `is_active = true` |
| `price_from` bertipe **string** (`"450000.00"`, hasil cast `decimal:2` mentah) | **float**, karena accessor meng-`(float)`-kan |
| tak ada `price_original` | ada, dari tipe kamar yang sama dengan `price_from` |
| fallback inline `?? $this->prices->min('amount')` | `if` terpisah, dijaga `relationLoaded('prices')` **dan** `booking_mode !== 'room'` |
| key `slug`, `city`, `reviews_count`, `cover_image_url` | tidak ada; yang ada `city_name`, `review_count`, `cover_image`/`cover` dari `$gallery[0]` |
| `rating` selalu ada (`?? 0`) | dibungkus `$this->when(isset(...))` → **key hilang** bila agregat `withAvg` tidak di-select |
| `has_breakfast` menghitung semua tipe kamar | hanya tipe kamar aktif |

> `total_price` **sengaja tidak** dipancarkan di sini, berbeda dari `GET hotels`. Endpoint ini melayani hasil campuran unit+room, dan "total" mode unit ikut menghitung `cleaning_fee`/`deposit`/`service_fee` — angka dengan arti berbeda di bawah nama yang sama lebih berbahaya daripada key yang absen. Detail: [readme_screen.md §11.2](screen/readme_screen.md#112-kontrak-field-harga).


---

## 4. Benchmark & Garansi Performa Query

1. **Penerapan Aggregate `HAVING count(*) = :nightsCount`**:
   - Memastikan database hanya mengembalikan hotel yang memiliki stok di *setiap* hari dalam rentang tanggal pesanan.
2. **Penggunaan Correlated Subquery**:
   - Mencegah perkalian jumlah baris (row duplication) pada sorting harga dibanding menggunakan `JOIN`.
3. **Penyatuan Cache/Count**:
   - Paginator Laravel menangani count secara efisien tanpa eksekusi `(clone $query)->count()` ganda.

---

## 5. Alur Pemesanan Hotel & Kalkulasi Asuransi (`BookingController::store`)

Saat pengguna melakukan submit booking kamar hotel dengan opsi memilih asuransi menginap (*Stay Protection*):

```php
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([
        'property_id'        => 'required|exists:properties,id',
        'room_type_id'       => 'required_if:booking_type,room|exists:room_types,id',
        'booking_type'       => 'required|in:unit,room',
        'check_in'           => 'required|date_format:Y-m-d|after_or_equal:today',
        'check_out'          => 'required|date_format:Y-m-d|after:check_in',
        'rooms_count'        => 'integer|min:1',
        'adults'             => 'integer|min:1',
        'children'           => 'integer|min:0',
        'include_insurance'  => 'boolean',
        'insurance_plan_id'  => 'required_if:include_insurance,true|exists:insurance_plans,id',
        'holder_name'        => 'required_if:include_insurance,true|string|max:150',
        'holder_identity'    => 'nullable|string|max:50',
    ]);

    return DB::transaction(function () use ($request, $validated) {
        $checkIn = Carbon::parse($validated['check_in']);
        $checkOut = Carbon::parse($validated['check_out']);
        $nights = $checkIn->diffInDays($checkOut);
        $roomsCount = $validated['rooms_count'] ?? count($validated['guests'] ?? [1]);

        $hotelId = $validated['hotel_id'] ?? $validated['property_id'];
        $hotel = Hotel::with('roomTypes')->findOrFail($hotelId);

        $roomSubtotal = 0;
        $bookingRoomsData = [];

        // Support single roomType atau multiple guest room assignment
        if (!empty($validated['guests']) && is_array($validated['guests'])) {
            foreach ($validated['guests'] as $idx => $guest) {
                $roomTypeName = $guest['room_name'] ?? 'Superior Room';
                $roomType = $hotel->roomTypes->firstWhere('name', $roomTypeName) ?? $hotel->roomTypes->first();
                $pricePerNight = $roomType ? $roomType->base_price : 446637;
                $subtotal = $pricePerNight * $nights;
                $roomSubtotal += $subtotal;

                $bookingRoomsData[] = [
                    'room_type_id'     => $roomType ? $roomType->id : 1,
                    'room_number'      => $guest['room_number'] ?? ($idx + 1),
                    'room_name'        => $roomTypeName,
                    'guest_first_name' => $guest['first_name'] ?? '',
                    'guest_last_name'  => $guest['last_name'] ?? '',
                    'quantity'         => 1,
                    'price_per_night'  => $pricePerNight,
                    'subtotal'         => $subtotal,
                ];
            }
        } else {
            $roomType = RoomType::findOrFail($validated['room_type_id']);
            $roomSubtotal = $roomType->base_price * $nights * $roomsCount;
            $bookingRoomsData[] = [
                'room_type_id'     => $roomType->id,
                'room_number'      => 1,
                'room_name'        => $roomType->name,
                'guest_first_name' => $validated['holder_name'] ?? 'Tamu Utama',
                'guest_last_name'  => '',
                'quantity'         => $roomsCount,
                'price_per_night'  => $roomType->base_price,
                'subtotal'         => $roomSubtotal,
            ];
        }

        // Kalkulasi Premi Asuransi (Stay Protection)
        $insuranceFee = 0;
        $insurancePlan = null;
        if (!empty($validated['has_insurance']) && !empty($validated['insurance_plan_id'])) {
            $insurancePlan = InsurancePlan::findOrFail($validated['insurance_plan_id']);
            $insuranceFee = $insurancePlan->calculatePremium($nights, $validated['adults'] ?? 1, $roomSubtotal);
        }

        $totalPrice = $roomSubtotal + $insuranceFee;
        $coinsEarned = (int) round($totalPrice * 0.005); // 0.5% Trip Coins

        // Create Booking
        $booking = Booking::create([
            'booking_code'       => 'HTL-' . date('Ymd') . '-' . strtoupper(Str::random(4)),
            'property_id'        => $hotel->property_id ?? $hotel->id,
            'user_id'            => $request->user()->id,
            'check_in'           => $checkIn->toDateString(),
            'check_out'          => $checkOut->toDateString(),
            'duration_type'      => 'daily',
            'booking_type'       => 'room',
            'rooms_count'        => $roomsCount,
            'adults'             => $validated['adults'] ?? 1,
            'children'           => $validated['children'] ?? 0,
            'contact_email'      => $validated['contact_email'] ?? $request->user()->email,
            'contact_phone'      => $validated['contact_phone'] ?? $request->user()->phone,
            'special_requests'   => $validated['special_requests'] ?? null,
            'trip_coins_earned'  => $coinsEarned,
            'receive_promos'     => $validated['receive_promos'] ?? true,
            'status'             => 'waiting_payment',
            'has_insurance'      => !empty($insurancePlan),
            'insurance_fee'      => $insuranceFee,
            'total_price'        => $totalPrice,
        ]);

        // Simpan Detail Kamar & Data Tamu per Kamar
        foreach ($bookingRoomsData as $bRoom) {
            $booking->bookingRooms()->create($bRoom);
        }

        // Buat record Polis status PENDING jika memilih proteksi
        if ($insurancePlan) {
            BookingInsurance::create([
                'booking_id'             => $booking->id,
                'insurance_plan_id'      => $insurancePlan->id,
                'holder_name'            => $validated['holder_name'] ?? ($bookingRoomsData[0]['guest_first_name'] . ' ' . $bookingRoomsData[0]['guest_last_name']),
                'holder_identity_number' => $validated['holder_identity'] ?? null,
                'premium_amount'         => $insuranceFee,
                'coverage_amount'        => $insurancePlan->coverage_amount,
                'status'                 => 'pending',
            ]);
        }

        // Generate Midtrans Payment Order (Eksisting)
        $order = $booking->order()->create([
            'order_code'   => 'ORD-' . $booking->booking_code,
            'gross_amount' => $totalPrice,
            'status'       => 'pending',
        ]);

        return ApiResponse::success([
            'booking' => $booking->load(['bookingRooms.roomType', 'insurance.insurancePlan']),
            'order'   => $order,
        ], 'Booking hotel berhasil dibuat');
    });
}
```

