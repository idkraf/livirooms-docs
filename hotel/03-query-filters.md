# 03. Logika Backend & Filter Dinamis (Daily Hotel Booking)

Dokumen ini mendokumentasikan spesifikasi query controller, validasi request, dan optimasi *Query Builder* Laravel untuk menangani pencarian & filter harian hotel berbasis parameter lokasi, rentang tanggal *check-in/check-out*, jumlah kamar & tamu, rating bintang, serta fasilitas cepat. Logika ini diintegrasikan langsung pada [`laravel/app/Http/Controllers/Api/PropertyController.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/PropertyController.php).

---

## 1. Validasi & Parameter Request API Search

Endpoint API utama yang digunakan oleh aplikasi Flutter adalah `GET /api/v1/properties`.

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

```php
public function toArray($request): array
{
    $cheapestRoomPrice = null;
    if ($this->booking_mode === 'room' && $this->relationLoaded('hotel') && $this->hotel) {
        $cheapestRoomPrice = $this->hotel->roomTypes->min('base_price');
    }

    return [
        'id'                 => $this->id,
        'name'               => $this->name,
        'slug'               => $this->slug,
        'property_type'      => $this->property_type,
        'booking_mode'       => $this->booking_mode, // 'unit' | 'room'
        'city'               => $this->city ? $this->city->name : null,
        'address'            => $this->address,
        'star_rating'        => $this->hotel ? $this->hotel->star_rating : null,
        'check_in_time'      => $this->hotel ? $this->hotel->check_in_time : null,
        'check_out_time'     => $this->hotel ? $this->hotel->check_out_time : null,
        'price_from'         => $cheapestRoomPrice ?? $this->prices->min('amount'),
        'rating'             => round($this->reviews_avg_rating ?? 0, 1),
        'reviews_count'      => $this->reviews_count ?? 0,
        'cover_image'        => $this->cover_image_url,
        'facilities'         => $this->facilities ?? [],
        'has_breakfast'      => $this->hotel ? $this->hotel->roomTypes->contains('breakfast_included', true) : false,
    ];
}
```

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
        $roomsCount = $validated['rooms_count'] ?? 1;

        $roomType = RoomType::findOrFail($validated['room_type_id']);

        // Lock stok inventaris kamar harian (Pencegahan Race Condition / Overselling)
        $inventories = RoomInventory::where('room_type_id', $roomType->id)
            ->whereBetween('date', [$checkIn->toDateString(), $checkOut->copy()->subDay()->toDateString()])
            ->lockForUpdate()
            ->get();

        if ($inventories->count() < $nights) {
            return ApiResponse::error('Stok kamar tidak tersedia pada tanggal yang dipilih', 422);
        }

        $roomSubtotal = 0;
        foreach ($inventories as $inv) {
            if ($inv->is_closed || ($inv->allotment - $inv->booked_count) < $roomsCount) {
                return ApiResponse::error("Kamar penuh pada tanggal {$inv->date->format('Y-m-d')}", 422);
            }
            $roomSubtotal += ($inv->price * $roomsCount);
        }

        // Kalkulasi Premi Asuransi
        $insuranceFee = 0;
        $insurancePlan = null;
        if (!empty($validated['include_insurance']) && !empty($validated['insurance_plan_id'])) {
            $insurancePlan = InsurancePlan::findOrFail($validated['insurance_plan_id']);
            $insuranceFee = $insurancePlan->calculatePremium($nights, $validated['adults'] ?? 1, $roomSubtotal);
        }

        $totalPrice = $roomSubtotal + $insuranceFee;

        // Create Booking
        $booking = Booking::create([
            'booking_code'  => 'HTL-' . strtoupper(Str::random(8)),
            'property_id'   => $validated['property_id'],
            'user_id'       => $request->user()->id,
            'check_in'      => $checkIn->toDateString(),
            'check_out'     => $checkOut->toDateString(),
            'duration_type' => 'daily',
            'booking_type'  => 'room',
            'rooms_count'   => $roomsCount,
            'adults'        => $validated['adults'] ?? 1,
            'children'      => $validated['children'] ?? 0,
            'status'        => 'waiting_payment',
            'has_insurance' => !empty($insurancePlan),
            'insurance_fee' => $insuranceFee,
            'total_price'   => $totalPrice,
        ]);

        // Detail Kamar
        BookingRoom::create([
            'booking_id'      => $booking->id,
            'room_type_id'    => $roomType->id,
            'quantity'        => $roomsCount,
            'price_per_night' => ($roomSubtotal / ($nights * $roomsCount)),
            'subtotal'        => $roomSubtotal,
        ]);

        // Buat record Polis status PENDING
        if ($insurancePlan) {
            BookingInsurance::create([
                'booking_id'             => $booking->id,
                'insurance_plan_id'     => $insurancePlan->id,
                'holder_name'           => $validated['holder_name'],
                'holder_identity_number'=> $validated['holder_identity'] ?? null,
                'premium_amount'        => $insuranceFee,
                'coverage_amount'       => $insurancePlan->coverage_amount,
                'status'                => 'pending',
            ]);
        }

        // Increment booked_count pada inventaris
        foreach ($inventories as $inv) {
            $inv->increment('booked_count', $roomsCount);
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

