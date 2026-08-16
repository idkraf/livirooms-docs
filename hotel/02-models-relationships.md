# 02. Definisi Model Eloquent & Relasi (Daily Hotel Booking)

Dokumen ini mendeskripsikan struktur entitas model Eloquent, relasi antar entitas, *Accessors/Mutators*, dan *Query Scopes* untuk modul **Daily Hotel Booking** di aplikasi **Sewain**. Model eksisting ([`laravel/app/Models/Booking.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/Booking.php) dan [`laravel/app/Models/Property.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Models/Property.php)) di-*extend* tanpa mengubah atau menghapus fungsi yang ada.

---

## 1. Modifikasi Model Eksisting

### A. Extension Model `App\Models\Booking` (`laravel/app/Models/Booking.php`)

Relasi eksisting `property()`, `user()`, `order()`, `review()` dipertahankan secara utuh. Ditambahkan atribut `$fillable`, relasi ke kamar hotel, accessor, dan query scopes.

```php
<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Booking extends Model
{
    use HasFactory;

    protected $table = 'bookings';

    protected $fillable = [
        'booking_code',
        'property_id',
        'user_id',
        'check_in',
        'check_out',
        'check_in_time',
        'check_out_time',
        'duration_type',
        'booking_type',     // 'unit' | 'room'
        'rooms_count',      // Tambahan modul hotel
        'adults',           // Tambahan modul hotel
        'children',         // Tambahan modul hotel
        'status',
        'total_price',
        'has_insurance',    // Fitur Asuransi Hotel
        'insurance_fee',   // Fitur Asuransi Hotel
        'host_confirmed',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'host_confirmed' => 'boolean',
        'has_insurance' => 'boolean',
        'insurance_fee' => 'decimal:2',
        'rooms_count' => 'integer',
        'adults' => 'integer',
        'children' => 'integer',
        'total_price' => 'decimal:2',
    ];

    /* --- Relasi Eksisting (Preserved) --- */
    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function order(): HasOne
    {
        return $this->hasOne(Order::class);
    }

    public function review(): HasOne
    {
        return $this->hasOne(Review::class);
    }

    /* --- Relasi Modul Hotel Baru --- */
    public function bookingRooms(): HasMany
    {
        return $this->hasMany(BookingRoom::class);
    }

    public function roomTypes(): BelongsToMany
    {
        return $this->belongsToMany(RoomType::class, 'booking_rooms')
                    ->withPivot(['quantity', 'price_per_night', 'subtotal'])
                    ->withTimestamps();
    }

    public function insurance(): HasOne
    {
        return $this->hasOne(BookingInsurance::class);
    }

    /* --- Accessors & Mutators --- */
    public function getIsHotelAttribute(): bool
    {
        return $this->booking_type === 'room';
    }

    public function getNightsCountAttribute(): int
    {
        if (!$this->check_in || !$this->check_out) {
            return 0;
        }
        return (int) $this->check_in->diffInDays($this->check_out);
    }

    /* --- Scopes --- */
    public function scopeHotel(Builder $query): Builder
    {
        return $query->where('booking_type', 'room');
    }

    public function scopeUnit(Builder $query): Builder
    {
        return $query->where('booking_type', 'unit');
    }

    public function scopeActiveBookings(Builder $query): Builder
    {
        return $query->whereNotIn('status', ['cancelled', 'expired']);
    }
}
```

---

### B. Extension Model `App\Models\Property` (`laravel/app/Models/Property.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Property extends Model
{
    // ... properti & atribut eksisting tetap utuh ...

    /* --- Relasi Modul Hotel Baru --- */
    public function hotel(): HasOne
    {
        return $this->hasOne(Hotel::class);
    }

    public function roomTypes(): HasManyThrough
    {
        return $this->hasManyThrough(RoomType::class, Hotel::class);
    }

    public function masterFacilities(): BelongsToMany
    {
        return $this->belongsToMany(Facility::class, 'facility_property');
    }

    /* --- Scopes Modul Hotel --- */
    public function scopeHotelMode(Builder $query): Builder
    {
        return $query->where('booking_mode', 'room');
    }

    public function scopeStarRating(Builder $query, array|int $stars): Builder
    {
        $starList = is_array($stars) ? $stars : [$stars];
        return $query->whereHas('hotel', function (Builder $q) use ($starList) {
            $q->whereIn('star_rating', $starList);
        });
    }

    public function scopeWithFacilities(Builder $query, array $slugs): Builder
    {
        return $query->whereHas('masterFacilities', function (Builder $q) use ($slugs) {
            $q->whereIn('slug', $slugs);
        }, '=', count($slugs));
    }
}
```

---

## 1.5 Jalur Relasi Khusus Hotel (bukan berlaku untuk properti biasa)

> Rujukan kanonik: [screen/readme_screen.md §10](screen/readme_screen.md#10-pemisahan-domain-booking-hotel-vs-booking-properti).

Kolom `bookings.booking_type` adalah **diskriminator tunggal** antara dua bentuk pemesanan. Ia menentukan relasi mana yang terisi:

| | `booking_type = 'unit'` (properti biasa) | `booking_type = 'room'` (hotel) |
|---|---|---|
| Yang disewa | seluruh unit properti | kamar per-tipe di dalam hotel |
| `booking_rooms` | **tidak ada baris** | **1 baris per kamar** |
| Rantai relasi | `Booking → Property` | `Booking → bookingRooms → roomType → hotel → property` |
| `room_type_id` | `null` | terisi |
| Prefix `booking_code` | `BK-` + 8 karakter | `HTL-` + `Ymd` + 4 karakter |
| `duration_type` | `daily`/`weekly`/`monthly`/`yearly` | selalu `daily` |
| `host_confirmed` | mengikuti alur konfirmasi host | selalu `true` (instant booking) |
| Sumber jam check-in | properti | `hotels.check_in_time`, fallback `14:00` |

**Konsekuensi praktis saat query:**

```php
// ❌ SALAH — mengasumsikan setiap booking punya booking_rooms
$booking->bookingRooms->first()->roomType->name;

// ✅ BENAR — cabangkan berdasarkan diskriminator
if ($booking->booking_type === 'room') {
    $booking->loadMissing('bookingRooms.roomType.hotel');
} else {
    $booking->loadMissing('property');
}
```

Jangan pakai `hotel_id` atau keberadaan `guests[]` sebagai penentu di sisi baca — keduanya hanya dipakai saat **inferensi** di `BookingController::store()`; setelah tersimpan, `booking_type` adalah satu-satunya sumber kebenaran.

---

## 2. Model Entitas Baru

### A. Model `App\Models\Hotel` (`laravel/app/Models/Hotel.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Hotel extends Model
{
    use HasFactory;

    protected $table = 'hotels';

    protected $fillable = [
        'property_id',
        'star_rating',
        'open_year',
        'check_in_time',
        'check_out_time',
        'score',
        'score_label',
        'review_count',
        'review_quotes',
        'facility_groups',
        'transport_points',
        'policies',
        'faqs',
        'deposit_amount',
    ];

    protected $casts = [
        'star_rating' => 'integer',
        'open_year' => 'integer',
        'score' => 'decimal:1',
        'review_count' => 'integer',
        'review_quotes' => 'array',
        'facility_groups' => 'array',
        'transport_points' => 'array',
        'policies' => 'array',
        'faqs' => 'array',
        'deposit_amount' => 'decimal:2',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function roomTypes(): HasMany
    {
        return $this->hasMany(RoomType::class);
    }
}
```

---

### B. Model `App\Models\RoomType` (`laravel/app/Models/RoomType.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RoomType extends Model
{
    use HasFactory;

    protected $table = 'room_types';

    protected $fillable = [
        'hotel_id',
        'name',
        'slug',
        'description',
        'capacity_adults',
        'capacity_children',
        'max_guests',
        'size_sqm',
        'bed_type',
        'has_window',
        'no_smoking',
        'free_wifi',
        'base_price',
        'price_original',
        'breakfast_included',
        'total_inventory',
        'remaining_count',
        'images',
        'facilities',
        'is_active',
    ];

    protected $casts = [
        'capacity_adults' => 'integer',
        'capacity_children' => 'integer',
        'max_guests' => 'integer',
        'has_window' => 'boolean',
        'no_smoking' => 'boolean',
        'free_wifi' => 'boolean',
        'base_price' => 'decimal:2',
        'price_original' => 'decimal:2',
        'breakfast_included' => 'boolean',
        'total_inventory' => 'integer',
        'remaining_count' => 'integer',
        'images' => 'array',
        'facilities' => 'array',
        'is_active' => 'boolean',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }

    public function rooms(): HasMany
    {
        return $this->hasMany(Room::class);
    }

    public function inventories(): HasMany
    {
        return $this->hasMany(RoomInventory::class);
    }

    public function masterFacilities(): BelongsToMany
    {
        return $this->belongsToMany(Facility::class, 'facility_room_type');
    }

    /* --- Scopes --- */
    public function scopeAvailableForDates(Builder $query, string $checkIn, string $checkOut, int $requiredRooms = 1): Builder
    {
        $dates = generateDateRange($checkIn, $checkOut); // Rentang tanggal [check_in, check_out)
        $nightsCount = count($dates);

        return $query->whereHas('inventories', function (Builder $q) use ($dates, $requiredRooms) {
            $q->whereIn('date', $dates)
              ->where('is_closed', false)
              ->whereRaw('(allotment - booked_count) >= ?', [$requiredRooms]);
        }, '=', $nightsCount);
    }

    public function scopeCapacity(Builder $query, int $adults, int $children = 0): Builder
    {
        return $query->where('capacity_adults', '>=', $adults)
                    ->where('max_guests', '>=', ($adults + $children));
    }
}
```

---

### C. Model `App\Models\RoomInventory` (`laravel/app/Models/RoomInventory.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoomInventory extends Model
{
    use HasFactory;

    protected $table = 'room_inventories';

    protected $fillable = [
        'room_type_id',
        'date',
        'allotment',
        'booked_count',
        'price',
        'is_closed',
        'min_stay',
        'max_stay',
    ];

    protected $casts = [
        'date' => 'date',
        'allotment' => 'integer',
        'booked_count' => 'integer',
        'price' => 'decimal:2',
        'is_closed' => 'boolean',
        'min_stay' => 'integer',
        'max_stay' => 'integer',
    ];

    public function roomType(): BelongsTo
    {
        return $this->belongsTo(RoomType::class);
    }

    public function getAvailableStockAttribute(): int
    {
        return max(0, $this->allotment - $this->booked_count);
    }

    public function scopeDateBetween(Builder $query, string $startDate, string $endDate): Builder
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }
}
```

---

### D. Model `App\Models\BookingRoom` (`laravel/app/Models/BookingRoom.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BookingRoom extends Model
{
    protected $table = 'booking_rooms';

    protected $fillable = [
        'booking_id',
        'room_type_id',
        'room_number',
        'room_name',
        'guest_first_name',
        'guest_last_name',
        'quantity',
        'price_per_night',
        'subtotal',
    ];

    protected $casts = [
        'room_number' => 'integer',
        'quantity' => 'integer',
        'price_per_night' => 'decimal:2',
        'subtotal' => 'decimal:2',
    ];

    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class);
    }

    public function roomType(): BelongsTo
    {
        return $this->belongsTo(RoomType::class);
    }
}
```

---

### E. Model `App\Models\Facility` (`laravel/app/Models/Facility.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Facility extends Model
{
    use HasFactory;

    protected $table = 'facilities';

    protected $fillable = ['name', 'slug', 'icon', 'category'];

    public function properties(): BelongsToMany
    {
        return $this->belongsToMany(Property::class, 'facility_property');
    }

    public function roomTypes(): BelongsToMany
    {
        return $this->belongsToMany(RoomType::class, 'facility_room_type');
    }
}
```

---

### F. Model `App\Models\InsuranceProvider` (`laravel/app/Models/InsuranceProvider.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InsuranceProvider extends Model
{
    use HasFactory;

    protected $table = 'insurance_providers';

    protected $fillable = [
        'name',
        'code',
        'api_endpoint',
        'api_key_ref',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function plans(): HasMany
    {
        return $this->hasMany(InsurancePlan::class, 'provider_id');
    }
}
```

---

### G. Model `App\Models\InsurancePlan` (`laravel/app/Models/InsurancePlan.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InsurancePlan extends Model
{
    use HasFactory;

    protected $table = 'insurance_plans';

    protected $fillable = [
        'provider_id',
        'name',
        'code',
        'premium_type',
        'premium_amount',
        'coverage_amount',
        'coverage_details',
        'is_active',
    ];

    protected $casts = [
        'premium_amount' => 'decimal:2',
        'coverage_amount' => 'decimal:2',
        'coverage_details' => 'array',
        'is_active' => 'boolean',
    ];

    public function provider(): BelongsTo
    {
        return $this->belongsTo(InsuranceProvider::class, 'provider_id');
    }

    public function bookingInsurances(): HasMany
    {
        return $this->hasMany(BookingInsurance::class, 'insurance_plan_id');
    }

    public function calculatePremium(int $nights, int $guests = 1, float $roomSubtotal = 0): float
    {
        if ($this->premium_type === 'percentage') {
            return round(($roomSubtotal * ($this->premium_amount / 100)), 2);
        }
        // Fixed per night per guest
        return round($this->premium_amount * $nights * $guests, 2);
    }
}
```

---

### H. Model `App\Models\BookingInsurance` (`laravel/app/Models/BookingInsurance.php`)

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BookingInsurance extends Model
{
    use HasFactory;

    protected $table = 'booking_insurances';

    protected $fillable = [
        'booking_id',
        'insurance_plan_id',
        'policy_number',
        'holder_name',
        'holder_identity_number',
        'premium_amount',
        'coverage_amount',
        'status',
        'issued_at',
        'certificate_url',
        'api_request_payload',
        'api_response_payload',
        'failure_reason',
    ];

    protected $casts = [
        'premium_amount' => 'decimal:2',
        'coverage_amount' => 'decimal:2',
        'issued_at' => 'datetime',
        'api_request_payload' => 'array',
        'api_response_payload' => 'array',
    ];

    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class);
    }

    public function insurancePlan(): BelongsTo
    {
        return $this->belongsTo(InsurancePlan::class, 'insurance_plan_id');
    }

    public function getIsIssuedAttribute(): bool
    {
        return $this->status === 'issued' && !empty($this->policy_number);
    }
}
```
```

---

## 3. Integrasi Observersi & Garansi Stok Harian

Untuk memastikan setiap tipe kamar baru memiliki baris inventaris tanggal yang valid, ditambahkan Observer pada `RoomType`:

```php
namespace App\Observers;

use App\Models\RoomType;
use App\Models\RoomInventory;
use Carbon\Carbon;

class RoomTypeObserver
{
    public function created(RoomType $roomType): void
    {
        // Otomatis membuat inventaris 30 hari ke depan
        $today = Carbon::today();
        for ($i = 0; $i < 30; $i++) {
            $date = $today->copy()->addDays($i)->toDateString();
            RoomInventory::create([
                'room_type_id' => $roomType->id,
                'date' => $date,
                'allotment' => $roomType->total_inventory,
                'booked_count' => 0,
                'price' => $roomType->base_price,
                'is_closed' => false,
            ]);
        }
    }
}
```
