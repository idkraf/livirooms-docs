# 01. Spesifikasi Migrasi Database (Daily Hotel Booking)

Dokumen ini menjelaskan rancangan skema database relasional untuk mendukung ekspansi modul **Daily Hotel Booking** pada aplikasi **Sewain**. Seluruh migrasi dirancang agar **100% kompatibel secara konsisten (backward compatible)** dengan struktur database eksisting di `@D:\Project\Fastwork\rental.apartemen\laravel\database\migrations\`.

---

## 1. Prinsip Desain & Kompatibilitas Sistem Eksisting

1. **Persistensi & Non-Breaking Changes**:
   - Kolom `check_in` dan `check_out` pada tabel `bookings` tetap bertipe `date` (bukan `datetime`), sesuai dengan definisi awal di [`2026_07_14_080300_create_bookings_table.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/database/migrations/2026_07_14_080300_create_bookings_table.php).
   - Pengisian jam check-in/check-out opsional menggunakan kolom waktu terpisah (`check_in_time`, `check_out_time`) yang nullable.
   - Menggunakan nilai default (`booking_type` = `'unit'`, `rooms_count` = `1`, `adults` = `1`, `children` = `0`) agar record booking eksisting (sewa kos/apartemen bulanan) tidak rusak.

2. **Idiom Konstrain PostgreSQL & SQLite**:
   - Berdasarkan temuan di [`2026_08_12_000001_update_booking_status_enum.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/database/migrations/2026_08_12_000001_update_booking_status_enum.php), manipulasi ENUM pada PostgreSQL wajib menggunakan `DB::statement("ALTER TABLE ... DROP CONSTRAINT IF EXISTS ...")` dan `ADD CONSTRAINT ... CHECK (...)`.
   - SQLite untuk testing `in-memory` tidak memvalidasi `CHECK constraint`, namun penulisan sintaks dibuat aman untuk kedua jenis DBMS.

3. **Pemberlakuan Mode Transaksi (`booking_mode`)**:
   - `properties.booking_mode` menentukan tipe penyewaan: `'unit'` (sewa seluruh unit properti seperti kos/apartemen) atau `'room'` (sewa tipe kamar harian ala OTA/hotel).

---

## 2. Struktur Migrasi Baru & Modifikasi Tabel

### A. Update Tabel `properties` & Penambahan Mode (`2026_08_13_000001_update_properties_for_hotels.php`)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('properties', function (Blueprint $table) {
            $table->string('booking_mode')->default('unit')->after('property_type'); // 'unit' | 'room'
            $table->index(['booking_mode', 'status']);
        });

        // PostgreSQL Idiom untuk menambah value 'hotel' pada ENUM property_type
        if (DB::getDriverName() === 'pgsql') {
            DB::statement("ALTER TABLE properties DROP CONSTRAINT IF EXISTS properties_property_type_check");
            DB::statement("ALTER TABLE properties ADD CONSTRAINT properties_property_type_check CHECK (property_type::text IN ('apartment', 'house', 'villa', 'hotel_residence', 'guest_house', 'exclusive_kost', 'hotel'))");
        }
    }

    public function down(): void
    {
        Schema::table('properties', function (Blueprint $table) {
            $table->dropIndex(['booking_mode', 'status']);
            $table->dropColumn('booking_mode');
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement("ALTER TABLE properties DROP CONSTRAINT IF EXISTS properties_property_type_check");
            DB::statement("ALTER TABLE properties ADD CONSTRAINT properties_property_type_check CHECK (property_type::text IN ('apartment', 'house', 'villa', 'hotel_residence', 'guest_house', 'exclusive_kost'))");
        }
    }
};
```

---

### B. Tabel Entitas Hotel (`2026_08_13_000002_create_hotels_table.php`)

Menyimpan metadata spesifik hotel yang terhubung 1-to-1 dengan `properties` saat `booking_mode = 'room'`.

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('hotels', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete()->unique();
            $table->unsignedTinyInteger('star_rating')->default(3)->comment('1 sampai 5 bintang');
            $table->unsignedSmallInteger('open_year')->default(1994)->comment('Tahun operasional buka hotel');
            $table->time('check_in_time')->default('14:00:00');
            $table->time('check_out_time')->default('12:00:00');
            $table->decimal('score', 3, 1)->default(8.1)->comment('Skor agregat ulasan 0.0 - 10.0');
            $table->string('score_label')->default('Luar Biasa');
            $table->unsignedInteger('review_count')->default(0);
            $table->jsonb('review_quotes')->nullable()->comment('Kutipan ulasan unggulan, e.g. ["Berlokasi di pusat kota", "Harga sesuai kualitas"]');
            $table->jsonb('facility_groups')->nullable()->comment('Fasilitas terkelompok: Makanan & Minuman, Kolam Renang, Transportasi, Kebugaran');
            $table->jsonb('transport_points')->nullable()->comment('Poin transit & jarak: Stasiun Kereta, Stasiun Metro, Bandara, Terminal Bus');
            $table->jsonb('policies')->nullable()->comment('Aturan: check_in_info, check_out_info, reception_hours, min_age, child_policy, extra_bed_policy');
            $table->jsonb('faqs')->nullable()->comment('Tanya jawab umum & jawaban manager akomodasi');
            $table->decimal('deposit_amount', 12, 2)->default(100000)->comment('Deposit tunai saat check-in');
            $table->timestamps();

            $table->index('star_rating');
            $table->index('score');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hotels');
    }
};
```

---

### C. Tabel Tipe Kamar / `room_types` (`2026_08_13_000003_create_room_types_table.php`)

Definisi tipe kamar dalam satu hotel (misal: Family Suite, Kamar Superior, Deluxe King).

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('room_types', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')->constrained('hotels')->cascadeOnDelete();
            $table->string('name'); // Family Suite, Kamar Superior
            $table->string('slug');
            $table->text('description')->nullable();
            $table->unsignedInteger('capacity_adults')->default(2);
            $table->unsignedInteger('capacity_children')->default(1);
            $table->unsignedInteger('max_guests')->default(3);
            $table->string('size_sqm')->default('30 m²')->comment('Luas kamar, e.g. 30 m², 21 m²');
            $table->string('bed_type')->default('1 Queen Bed')->comment('e.g. 2 queen bed, 1 queen bed atau 2 single bed');
            $table->boolean('has_window')->default(true);
            $table->boolean('no_smoking')->default(true);
            $table->boolean('free_wifi')->default(true);
            $table->decimal('base_price', 12, 2);
            $table->decimal('price_original', 12, 2)->nullable()->comment('Harga coret sebelum diskon');
            $table->boolean('breakfast_included')->default(false);
            $table->unsignedInteger('total_inventory')->default(5);
            $table->unsignedInteger('remaining_count')->default(3);
            $table->jsonb('images')->nullable()->comment('Daftar URL foto kamar');
            $table->jsonb('facilities')->nullable()->comment('Mirror fasilitas cepat tipe kamar');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['hotel_id', 'is_active']);
            $table->index('breakfast_included');
            $table->index(['capacity_adults', 'capacity_children']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('room_types');
    }
};
```

---

### D. Tabel Unit Fisik Kamar / `rooms` (`2026_08_13_000004_create_rooms_table.php`)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('rooms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_type_id')->constrained('room_types')->cascadeOnDelete();
            $table->string('room_number');
            $table->string('floor')->nullable();
            $table->string('status')->default('available'); // available, occupied, maintenance, out_of_service
            $table->timestamps();

            $table->unique(['room_type_id', 'room_number']);
            $table->index(['room_type_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rooms');
    }
};
```

---

### E. Tabel Inventaris Kalender Harian / `room_inventories` (`2026_08_13_000005_create_room_inventories_table.php`)

Menyimpan stok kamar harian (*allotment*), tarif harian (*price*), serta proteksi *overselling*. Struktur ini merefleksikan arsitektur [`2026_07_14_080400_create_availabilities_table.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/database/migrations/2026_07_14_080400_create_availabilities_table.php).

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('room_inventories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_type_id')->constrained('room_types')->cascadeOnDelete();
            $table->date('date');
            $table->unsignedInteger('allotment')->default(1);
            $table->unsignedInteger('booked_count')->default(0);
            $table->decimal('price', 12, 2);
            $table->boolean('is_closed')->default(false);
            $table->unsignedInteger('min_stay')->default(1);
            $table->unsignedInteger('max_stay')->nullable();
            $table->timestamps();

            $table->unique(['room_type_id', 'date']);
            $table->index(['date', 'is_closed']);
            $table->index(['room_type_id', 'date', 'is_closed']);
        });

        // Dynamic Guard untuk proteksi Race Condition / Overselling di DB
        if (DB::getDriverName() === 'pgsql') {
            DB::statement("ALTER TABLE room_inventories ADD CONSTRAINT check_booked_le_allotment CHECK (booked_count <= allotment)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('room_inventories');
    }
};
```

---

### F. Penyesuaian Tabel `bookings` (`2026_08_13_000006_update_bookings_for_hotels.php`)

Melakukan penambahan kolom *non-breaking* pada tabel `bookings` utama di [`2026_07_14_080300_create_bookings_table.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/database/migrations/2026_07_14_080300_create_bookings_table.php).

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->string('booking_type')->default('unit')->after('duration_type'); // 'unit' | 'room'
            $table->unsignedInteger('rooms_count')->default(1)->after('booking_type');
            $table->unsignedInteger('adults')->default(1)->after('rooms_count');
            $table->unsignedInteger('children')->default(0)->after('adults');
            $table->time('check_in_time')->nullable()->after('check_in');
            $table->time('check_out_time')->nullable()->after('check_out');
            $table->string('contact_email')->nullable()->after('total_price');
            $table->string('contact_phone')->nullable()->after('contact_email');
            $table->text('special_requests')->nullable()->after('contact_phone');
            $table->unsignedInteger('trip_coins_earned')->default(0)->after('special_requests');
            $table->unsignedInteger('trip_coins_used')->default(0)->after('trip_coins_earned');
            $table->boolean('receive_promos')->default(true)->after('trip_coins_used');
            
            // Tambahan Fitur Asuransi Hotel (Stay Protection)
            $table->boolean('has_insurance')->default(false)->after('receive_promos');
            $table->decimal('insurance_fee', 12, 2)->default(0)->after('has_insurance');

            $table->index(['booking_type', 'status']);
            $table->index('has_insurance');
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropIndex(['booking_type', 'status']);
            $table->dropIndex(['has_insurance']);
            $table->dropColumn([
                'booking_type',
                'rooms_count',
                'adults',
                'children',
                'check_in_time',
                'check_out_time',
                'contact_email',
                'contact_phone',
                'special_requests',
                'trip_coins_earned',
                'trip_coins_used',
                'receive_promos',
                'has_insurance',
                'insurance_fee',
            ]);
        });
    }
};
```

---

### G. Tabel Detail Kamar & Data Tamu / `booking_rooms` (`2026_08_13_000007_create_booking_rooms_table.php`)

Menghubungkan `bookings` dengan `room_types` yang dipilih pengguna serta nama tamu masing-masing kamar.

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('booking_rooms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained('bookings')->cascadeOnDelete();
            $table->foreignId('room_type_id')->constrained('room_types')->cascadeOnDelete();
            $table->unsignedInteger('room_number')->default(1)->comment('Nomor urut kamar: 1, 2, dst.');
            $table->string('room_name')->nullable()->comment('e.g. Family Suite, Kamar Superior');
            $table->string('guest_first_name')->nullable()->comment('Nama depan tamu');
            $table->string('guest_last_name')->nullable()->comment('Nama belakang tamu');
            $table->unsignedInteger('quantity')->default(1);
            $table->decimal('price_per_night', 12, 2);
            $table->decimal('subtotal', 12, 2);
            $table->timestamps();

            $table->index(['booking_id', 'room_type_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('booking_rooms');
    }
};
```

---

### H. Tabel Normalisasi Fasilitas (`2026_08_13_000008_create_master_facilities_tables.php`)

Menyediakan tabel master fasilitas untuk query relational berkecepatan tinggi, tanpa menghilangkan mirror JSON `properties.facilities` yang dibaca oleh Flutter.

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('facilities', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique(); // wifi, pool, breakfast, gym, ac, parking
            $table->string('icon')->nullable();
            $table->string('category')->default('hotel'); // hotel, room, general
            $table->timestamps();
        });

        Schema::create('facility_property', function (Blueprint $table) {
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete();
            $table->foreignId('facility_id')->constrained('facilities')->cascadeOnDelete();
            $table->primary(['property_id', 'facility_id']);
        });

        Schema::create('facility_room_type', function (Blueprint $table) {
            $table->foreignId('room_type_id')->constrained('room_types')->cascadeOnDelete();
            $table->foreignId('facility_id')->constrained('facilities')->cascadeOnDelete();
            $table->primary(['room_type_id', 'facility_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('facility_room_type');
        Schema::dropIfExists('facility_property');
        Schema::dropIfExists('facilities');
    }
};
```

---

### I. Tabel Asuransi & Polis Menginap (`2026_08_13_000009_create_insurance_tables.php`)

Menyediakan tabel manajemen penyedia asuransi (*Insurtech Partner*), paket premi asuransi hotel (*Stay Protection*), dan penerbitan polis per transaksi booking.

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // 1. Master Partner Penyedia Asuransi
        Schema::create('insurance_providers', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. Zurich Insurance, Chubb, ACA, PasarPolis
            $table->string('code')->unique(); // zurich_stay, chubb_hotel, pasarpolis_stay
            $table->string('api_endpoint')->nullable();
            $table->string('api_key_ref')->nullable(); // Reference key di config/env
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 2. Paket / Plan Asuransi
        Schema::create('insurance_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('provider_id')->constrained('insurance_providers')->cascadeOnDelete();
            $table->string('name'); // e.g. Protection Basic (Kecelakaan & Barang), Protection Deluxe (Komprehensif)
            $table->string('code')->unique();
            $table->string('premium_type')->default('fixed_per_night'); // 'fixed_per_night' | 'percentage'
            $table->decimal('premium_amount', 12, 2)->default(15000); // Rp 15.000 / malam / tamu
            $table->decimal('coverage_amount', 12, 2)->default(25000000); // Santunan hingga Rp 25.000.000
            $table->jsonb('coverage_details')->nullable(); // { "medical": 10000000, "baggage": 2500000, "cancellation": 5000000 }
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['provider_id', 'is_active']);
        });

        // 3. Polis Asuransi Transaksi Booking
        Schema::create('booking_insurances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained('bookings')->cascadeOnDelete();
            $table->foreignId('insurance_plan_id')->constrained('insurance_plans')->cascadeOnDelete();
            $table->string('policy_number')->nullable()->unique(); // Nomor Polis resmi dari provider (setelah issued)
            $table->string('holder_name'); // Nama Tertanggung (sesuai KTP/Passport)
            $table->string('holder_identity_number')->nullable(); // NIK / No. KTP / Passport
            $table->decimal('premium_amount', 12, 2);
            $table->decimal('coverage_amount', 12, 2);
            $table->string('status')->default('pending'); // pending, processing, issued, failed, claimed, cancelled
            $table->timestamp('issued_at')->nullable();
            $table->string('certificate_url')->nullable(); // File PDF E-Certificate Polis
            $table->jsonb('api_request_payload')->nullable(); // Log payload dikirim ke API
            $table->jsonb('api_response_payload')->nullable(); // Log callback/response API
            $table->text('failure_reason')->nullable(); // Catatan error jika pendaftaran gagal
            $table->timestamps();

            $table->index(['booking_id', 'status']);
            $table->index('policy_number');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('booking_insurances');
        Schema::dropIfExists('insurance_plans');
        Schema::dropIfExists('insurance_providers');
    }
};
```

---

## 3. Matriks Hubungan Relasional Database

```
+------------------+         1:1         +------------------+
|    properties    |-------------------->|      hotels      |
+------------------+                     +------------------+
        |                                         |
        | 1:N                                     | 1:N
        v                                         v
+------------------+                     +------------------+
|   availabilities |                     |    room_types    |
| (Mode Unit Kos/  |                     +------------------+
|    Apartemen)    |                        |       |
+------------------+                     1:N|       |1:N
                                            v       v
                                 +---------------+ +-------------------+
                                 |     rooms     | |  room_inventories |
                                 | (Unit Fisik)  | |(Allotment/Tarif)  |
                                 +---------------+ +-------------------+
                                                            ^
                                                            | Diberlakukan Lock
+------------------+         1:N         +------------------+
|     bookings     |-------------------->|  booking_rooms   |
+------------------+                     +------------------+
        |
        | 1:1 (Optional)
        v
+------------------+         N:1         +------------------+         N:1         +---------------------+
|booking_insurances|-------------------->|  insurance_plans |-------------------->| insurance_providers |
+------------------+                     +------------------+                     +---------------------+
```

---

## 4. Rangkuman Indeks & Optimasi Query

1. `properties(booking_mode, status)`: Mempercepat filtering properti tipe hotel aktif.
2. `hotels(star_rating)`: Mempercepat filter Bintang 1-5.
3. `room_inventories(room_type_id, date, is_closed)`: Indeks komposit utama untuk pencarian ketersediaan tanggal.
4. `room_types(capacity_adults, capacity_children)`: Mempercepat pencarian tipe kamar yang sanggup menampung jumlah tamu.
5. `booking_insurances(booking_id, status)`: Mempercepat pemeriksaan dan penerbitan polis asuransi saat event `BookingPaid`.

