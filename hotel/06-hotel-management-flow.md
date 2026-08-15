# 06. Alur Manajemen Produk Hotel & Otomasi Job/Cronjob

Dokumen ini mendokumentasikan alur lengkap penambahan manual produk hotel oleh Mitra Properti atau Admin melalui **Website Portal Admin Laravel** dan **Aplikasi Mobile Flutter Mitra**, serta arsitektur **Otomasi Backend via Laravel Queue Job & Cronjob Scheduler**.

---

## 1. Alur Manual Tambah Produk Hotel di Website Web Admin & Portal Mitra

Penambahan produk hotel pada portal web dikembangkan menggunakan komponen Laravel Livewire / Admin Form Wizard yang terbagi ke dalam 5 tahapan berurutan:

```
[Step 1: Info Hotel & Jam In/Out] ---> [Step 2: Pendaftaran Tipe Kamar] ---> [Step 3: Unit Kamar Fisik]
                                                                                      |
                                                                                      v
[Step 5: Konfigurasi Asuransi]    <--- [Step 4: Matriks Stok & Harga Harian] <--------+
```

### Rincian Tahapan Form Wizard Web Admin:

#### Step 1: Informasi Utama Hotel & Mode Properti (8 Tab Metadata)
- **Mode Properti (`booking_mode`)**: Pilih `room` (Sewa Kamar Hotel Harian).
- **Tipe Properti (`property_type`)**: Pilih `hotel` atau `hotel_residence`.
- **Nama & Lokasi**: Nama Hotel, Kota (`city_id`), Alamat Lengkap, Koordinat Latitude/Longitude.
- **Bintang Hotel (`star_rating`)**: Pilih 1 sampai 5 Bintang & Tahun Pembukaan (`open_year`).
- **Jam Operasional & Kebijakan**: Jam Check-in (Default `14:00:00`), Jam Check-out (Default `12:00:00`), Resepsionis 24 jam, Kebijakan Anak & Ranjang Tambahan.
- **Fasilitas Terkelompok (`facility_groups`)**:
  - *Makanan & Minuman*: Minimarket/kios, Restoran, Bar Lobi.
  - *Kolam Renang*: Indoor, Outdoor.
  - *Transportasi*: Rental Mobil, Area Parkir Gratis, Layanan Mobil Concierge.
  - *Kesehatan & Kebugaran*: Spa, Pusat Kebugaran / Gym.
- **Poin Transit Transportasi (`transport_points`)**: Stasiun Kereta (e.g. Gondangdia, Gambir), Stasiun Metro (Bundaran HI, Dukuh Atas), Bandara, Terminal Bus beserta estimasi jarak.
- **Tanya Jawab Manager (`faqs`)**: FAQ seputar sarapan berbayar/gratis, antar-jemput bandara, deposit tunai, dll.
- **Galeri Foto**: Upload Foto Utama / Cover, Foto Fasilitas, dan Foto Kamar.

#### Step 2: Manajemen Tipe Kamar & Kombo Rekomendasi (`room_types`)
Mitra/Admin dapat menambahkan satu atau lebih tipe kamar:
- **Nama Tipe Kamar**: e.g., *Family Suite*, *Kamar Superior*, *Deluxe King*.
- **Kapasitas Tamu**: Kapasitas Dewasa (Default 2-4), Anak (Default 1-2), Maksimal Tamu.
- **Tarif Dasar (`base_price`) & Harga Coret (`price_original`)**: Tarif standar per malam & diskon promo.
- **Inklusi Sarapan (`breakfast_included`)**: Toggle *Termasuk Sarapan Gratis*.
- **Luas Kamar & Konfigurasi Bed**: Luas m² (*30 m²*, *21 m²*), Tipe Ranjang (*2 Queen Bed* / *1 Queen Bed atau 2 Single Bed*).
- **Fasilitas Kamar Cepat**: Memiliki Jendela (`has_window`), Bebas Rokok (`no_smoking`), Wi-Fi Gratis (`free_wifi`).
- **Total Stok Kamar (`total_inventory`) & Sisa Kamar (`remaining_count`)**: Pengaturan ketersediaan kuota.

#### Step 3: Pendaftaran Unit Kamar Fisik (`rooms`)
- Penentuan Nomor Kamar (e.g. Room 101, 102, 201, 202) dan Lantai.
- Status Awal: `available`, `occupied`, `maintenance`.

#### Step 4: Matriks Stok & Tarif Harian (`room_inventories`)
- Pembuatan otomatis matriks stok harian 30 hari ke depan via `RoomTypeObserver`.
- Interface kalender untuk mengubah tarif khusus *Weekend / High-Season* atau *Stop-Sell* (`is_closed = true`).

#### Step 5: Pengaturan Asuransi Menginap (*Stay Protection*)
- Pilih Paket Asuransi Default yang ditawarkan kepada tamu (Basic / Deluxe Protection).
- Penentuan status asuransi: **Opsional (Tamu memilih)** atau **Mandatori (Sudah termasuk di tarif kamar)**.

---

## 2. Alur Tambah/Edit Produk Hotel di Aplikasi Mobile Flutter Mitra

Pada aplikasi Flutter Mitra (`flutter/lib/screens/mitra/`), alur manajemen produk hotel dirancang dengan layar antarmuka responsive:

```
[MitraDashboardScreen] ---> [AddHotelScreen (Step Form)] ---> [ManageRoomTypesScreen] ---> [InventoryCalendarModal]
```

### Rincian Layar Flutter Mitra:

1. **`AddHotelScreen`**: Form input data dasar hotel, lokasi picker, upload gambar via kamera/galeri, dan pemilihan jam check-in/check-out.
2. **`ManageRoomTypesScreen`**: Layar list & CRUD tipe kamar (menambah kamar baru, menetapkan kapasitas dewasa/anak, dan toggle *Termasuk Sarapan*).
3. **`InventoryCalendarModal`**: Component modal BottomSheet untuk Mitra menyesuaikan *allotment* stok kamar dan harga harian secara cepat langsung dari smartphone.

---

## 3. Arsitektur Otomasi Cronjob & Queue Job Laravel

Untuk menjaga performa database dan otomatisasi tugas operasional hotel, sistem menggunakan **Laravel Console Scheduler** (`routes/console.php`) yang mengeksekusi 3 Job utama:

```php
// laravel/routes/console.php

use App\Jobs\CancelExpiredBookingsJob;
use App\Jobs\ExtendHotelInventoriesJob;
use App\Jobs\SyncInsuranceStatusJob;
use Illuminate\Support\Facades\Schedule;

// 1. Cron Otomatis Perpanjang Stok Kamar Harian (Setiap Jam 00:00 Malam)
Schedule::job(new ExtendHotelInventoriesJob())->dailyAt('00:00');

// 2. Cron Otomatis Membatalkan Booking Expired (Setiap 5 Menit)
Schedule::job(new CancelExpiredBookingsJob())->everyFiveMinutes();

// 3. Cron Sinkronisasi Status Polis/Klaim Asuransi (Setiap 1 Jam)
Schedule::job(new SyncInsuranceStatusJob())->hourly();
```

---

### A. Job Perpanjang Inventaris Harian (`ExtendHotelInventoriesJob`)

Job ini memastikan setiap tipe kamar hotel yang aktif selalu memiliki ketersediaan inventaris kalender 30 hari ke depan (*rolling inventory window*).

```php
<?php

namespace App\Jobs;

use App\Models\RoomInventory;
use App\Models\RoomType;
use Carbon\Carbon;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ExtendHotelInventoriesJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $targetDate = Carbon::today()->addDays(30)->toDateString();
        $roomTypes = RoomType::where('is_active', true)->get();

        $createdCount = 0;
        foreach ($roomTypes as $roomType) {
            $exists = RoomInventory::where('room_type_id', $roomType->id)
                ->where('date', $targetDate)
                ->exists();

            if (!$exists) {
                RoomInventory::create([
                    'room_type_id' => $roomType->id,
                    'date'         => $targetDate,
                    'allotment'    => $roomType->total_inventory,
                    'booked_count' => 0,
                    'price'        => $roomType->base_price,
                    'is_closed'    => false,
                ]);
                $createdCount++;
            }
        }

        Log::info("ExtendHotelInventoriesJob: Berhasil menambahkan {$createdCount} baris inventaris kamar untuk tanggal {$targetDate}.");
    }
}
```

---

### B. Job Pembatalan Booking Expired & Release Stok (`CancelExpiredBookingsJob`)

Membatalkan booking hotel yang melewati batas pembayaran dan mengembalikan *allotment* stok kamar harian secara otomatis.

```php
<?php

namespace App\Jobs;

use App\Models\Booking;
use App\Models\RoomInventory;
use Carbon\Carbon;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CancelExpiredBookingsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        // Booking hotel belum dibayar > 30 menit
        $expiredThreshold = Carbon::now()->subMinutes(30);

        $expiredBookings = Booking::where('status', 'waiting_payment')
            ->where('created_at', '<=', $expiredThreshold)
            ->with('bookingRooms')
            ->get();

        foreach ($expiredBookings as $booking) {
            DB::transaction(function () use ($booking) {
                $booking->update(['status' => 'expired']);

                if ($booking->order) {
                    $booking->order->update(['status' => 'cancelled']);
                }

                // Restore stok kamar yang terkunci
                if ($booking->booking_type === 'room') {
                    $checkIn = $booking->check_in;
                    $checkOut = $booking->check_out->copy()->subDay();

                    foreach ($booking->bookingRooms as $br) {
                        RoomInventory::where('room_type_id', $br->room_type_id)
                            ->whereBetween('date', [$checkIn->toDateString(), $checkOut->toDateString()])
                            ->decrement('booked_count', $br->quantity);
                    }
                }
            });

            Log::info("CancelExpiredBookingsJob: Booking {$booking->booking_code} otomatis dibatalkan dan stok dikembalikan.");
        }
    }
}
```

---

### C. Job Sinkronisasi Status Asuransi (`SyncInsuranceStatusJob`)

Melakukan polling berkala ke API Provider Insurtech untuk memperbarui status polis yang terbit atau klaim yang diajukan pengguna.

```php
<?php

namespace App\Jobs;

use App\Models\BookingInsurance;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SyncInsuranceStatusJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $issuedInsurances = BookingInsurance::where('status', 'issued')
            ->whereNotNull('policy_number')
            ->with('insurancePlan.provider')
            ->get();

        foreach ($issuedInsurances as $insurance) {
            $provider = $insurance->insurancePlan->provider;
            
            try {
                $apiKey = config("services.insurance.{$provider->code}_key");
                $response = Http::withHeaders([
                    'Authorization' => "Bearer {$apiKey}",
                ])->get("{$provider->api_endpoint}/v1/policies/status/{$insurance->policy_number}");

                if ($response->successful()) {
                    $remoteStatus = $response->json('status'); // e.g. 'claimed', 'cancelled'
                    if (in_array($remoteStatus, ['claimed', 'cancelled']) && $remoteStatus !== $insurance->status) {
                        $insurance->update(['status' => $remoteStatus]);
                        Log::info("SyncInsuranceStatusJob: Status polis {$insurance->policy_number} di-update ke {$remoteStatus}.");
                    }
                }
            } catch (\Throwable $e) {
                Log::warning("SyncInsuranceStatusJob Gagal memuat status polis {$insurance->policy_number}: {$e->getMessage()}");
            }
        }
    }
}
```

---

## 4. Matriks Ringkasan Otomasi Operasional

| Nama Job / Task | Frekuensi Cron | Pemicu / Trigger | Tujuan Operasional |
|---|---|---|---|
| `IssueInsurancePolicyJob` | Asynchronous Queue | Event `BookingPaid` (Webhook Midtrans) | Otomatis mendaftarkan polis ke API Insurtech & menyimpan link PDF E-Certificate |
| `ExtendHotelInventoriesJob` | Daily `00:00` | Cron Scheduler Laravel | Menjamin ketersediaan kalender harian 30 hari ke depan (*rolling inventory window*) |
| `CancelExpiredBookingsJob` | Every 5 Minutes | Cron Scheduler Laravel | Membatalkan booking kadaluarsa & mengembalikan *allotment* kamar ke pasar |
| `SyncInsuranceStatusJob` | Hourly | Cron Scheduler Laravel | Sinkronisasi status polis & santunan klaim dari API Provider Insurtech |
