# 05. Permodelan & Integrasi Asuransi Hotel (Stay Protection)

Dokumen ini mendokumentasikan spesifikasi **Permodelan Asuransi Menginap Hotel (*Stay Protection*)**, tahapan pendaftaran polis berstandar industri *Insurtech* (seperti Zurich, Chubb, ACA, atau PasarPolis), integrasi API otomatis via **Laravel Queue Job**, serta mekanisme **Manual Request / Re-issue** di Panel Admin Laravel & Portal Mitra.

---

## 1. Tahapan & Siklus Hidup Pendaftaran Polis Asuransi

Pendaftaran asuransi menginap hotel mengikuti 6 tahapan umum industri:

```
[1. Opt-in Checkout] ---> [2. Pending State (DB)] ---> [3. Settlement Payment]
                                                                |
                                                                v
[6. Claim/Cancel]   <--- [5. E-Certificate]     <--- [4. Issue Policy Job]
                                                        (Automated / Manual)
```

### Rincian Status Polis (`booking_insurances.status`):

| Status | Deskripsi | Aksi Otomatis |
|---|---|---|
| `pending` | User mencentang asuransi saat checkout. Booking dibuat tetapi belum dibayar. | Menunggu konfirmasi pembayaran Midtrans |
| `processing` | Pembayaran Midtrans `settlement`. Laravel Job sedang menghubungi API Insurtech Provider. | Dispatch `IssueInsurancePolicyJob` |
| `issued` | Polis sukses terbit dari API Provider. Nomor Polis & Link E-Certificate tersimpan. | Kirim sertifikat PDF ke email user |
| `failed` | Pendaftaran via API gagal (misal: timeout API, NIK invalid). | Notifikasi ke Admin/Mitra untuk **Manual Request** |
| `claimed` | Pengguna mengajukan klaim santunan medis/barang hilang selama masa inap. | Di-update via Cronjob Sinkronisasi Polis |
| `cancelled` | Booking dibatalkan sebelum check-in. Polis dibatalkan di sistem Insurtech. | Job pembatalan polis dipicu |

---

## 2. Pemicu Otomatis Pembayaran & Event Listener (`BookingPaid`)

Saat webhook Midtrans menerima pembayaran sukses (`settlement`), event `App\Events\BookingPaid` dipicu secara otomatis di controller pembayaran eksisting (`laravel/app/Http/Controllers/Api/PaymentController.php`).

### Event Listener & Queue Job Dispatcher

```php
namespace App\Listeners;

use App\Events\BookingPaid;
use App\Jobs\IssueInsurancePolicyJob;

class ProcessBookingInsuranceListener
{
    public function handle(BookingPaid $event): void
    {
        $booking = $event->booking;

        // Cek apakah booking memiliki opsi asuransi aktif dan status polis masih pending
        if ($booking->has_insurance && $booking->insurance) {
            if ($booking->insurance->status === 'pending') {
                $booking->insurance->update(['status' => 'processing']);
                
                // Dispatch Job ke Queue Laravel
                IssueInsurancePolicyJob::dispatch($booking->insurance->id);
            }
        }
    }
}
```

---

## 3. Implementasi Laravel Queue Job (`IssueInsurancePolicyJob`)

Job ini menangani komunikasi asynchronous ke API Provider Insurtech dengan proteksi retry bawaan Laravel (3x percobaan dengan *exponential backoff*).

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

class IssueInsurancePolicyJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 30; // Wait 30 seconds before retry

    public function __construct(public int $bookingInsuranceId) {}

    public function handle(): void
    {
        $insurance = BookingInsurance::with(['booking.property', 'insurancePlan.provider'])->find($this->bookingInsuranceId);

        if (!$insurance || $insurance->status === 'issued') {
            return;
        }

        $provider = $insurance->insurancePlan->provider;
        $booking = $insurance->booking;

        $payload = [
            'partner_booking_code' => $booking->booking_code,
            'plan_code'            => $insurance->insurancePlan->code,
            'holder_name'          => $insurance->holder_name,
            'holder_identity'      => $insurance->holder_identity_number,
            'check_in'             => $booking->check_in->toDateString(),
            'check_out'            => $booking->check_out->toDateString(),
            'guests_count'         => $booking->adults,
            'premium_amount'       => (float) $insurance->premium_amount,
            'hotel_name'           => $booking->property->name,
        ];

        $insurance->update(['api_request_payload' => $payload]);

        try {
            $apiKey = config("services.insurance.{$provider->code}_key");
            $response = Http::withHeaders([
                'Authorization' => "Bearer {$apiKey}",
                'Accept'        => 'application/json',
            ])->timeout(15)->post("{$provider->api_endpoint}/v1/policies/issue", $payload);

            $responseData = $response->json();
            $insurance->update(['api_response_payload' => $responseData]);

            if ($response->successful() && isset($responseData['policy_number'])) {
                $insurance->update([
                    'status'          => 'issued',
                    'policy_number'   => $responseData['policy_number'],
                    'certificate_url' => $responseData['certificate_pdf_url'] ?? null,
                    'issued_at'       => now(),
                    'failure_reason'  => null,
                ]);

                Log::info("Polis Asuransi Berhasil Diterbitkan: {$responseData['policy_number']} untuk Booking {$booking->booking_code}");
            } else {
                $errorMsg = $responseData['message'] ?? 'API Provider mengembalikan status error';
                $insurance->update([
                    'status'         => 'failed',
                    'failure_reason' => $errorMsg,
                ]);
                Log::error("Gagal Penerbitan Polis Asuransi Booking {$booking->booking_code}: {$errorMsg}");
            }
        } catch (\Throwable $e) {
            $insurance->update([
                'status'         => 'failed',
                'failure_reason' => $e->getMessage(),
            ]);
            throw $e; // Triggering retry attempt
        }
    }
}
```

---

## 4. Alur Manual Request & Re-issue di Web Admin Laravel & Portal Mitra

Jika proses pendaftaran polis otomatis mengalami kegagalan (status `failed` karena timeout API atau NIK tidak valid), Admin atau Mitra Properti dapat melakukan **Manual Request / Re-issue** dari panel admin.

### A. Tampilan Admin Controller / Livewire (`Admin/InsuranceManagement`)

Pada daftar transaksi booking di Panel Admin:
1. Filter transaksi dengan `has_insurance = true` dan `insurance.status = 'failed'` atau `'pending'`.
2. Admin dapat mengedit data `holder_name` atau `holder_identity_number` jika terdapat kesalahan input dari pengguna.
3. Tombol **"Manual Request ke Insurance Provider"** mengeksekusi endpoint backend `POST /admin/insurance/{id}/re-issue`.

### B. Controller Backend Re-issue (`laravel/app/Http/Controllers/Admin/InsuranceController.php`)

```php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Jobs\IssueInsurancePolicyJob;
use App\Models\BookingInsurance;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class InsuranceController extends Controller
{
    public function reIssue(Request $request, int $id): RedirectResponse
    {
        $insurance = BookingInsurance::findOrFail($id);

        // Update data tertanggung jika diajukan koreksi
        if ($request->has('holder_name')) {
            $insurance->update([
                'holder_name'            => $request->input('holder_name'),
                'holder_identity_number' => $request->input('holder_identity_number'),
            ]);
        }

        // Reset status ke processing & dispatch ulang job
        $insurance->update([
            'status'         => 'processing',
            'failure_reason' => null,
        ]);

        IssueInsurancePolicyJob::dispatch($insurance->id);

        return back()->with('success', 'Permintaan penerbitan polis asuransi berhasil dikirim ulang ke provider.');
    }
}
```

---

## 5. Ringkasan Fitur Asuransi Hotel

1. **Fleksibilitas Paket**: Mendukung premi tetap per malam/tamu (*fixed per night*) maupun persentase dari harga kamar.
2. **Keandalan Sistem**: Menggunakan Queue Job dengan proteksi retry serta fallback Manual Request di Web Admin.
3. **Auditing Lengkap**: Menyimpan seluruh payload request & response JSON API provider di database (`booking_insurances`).

---

## 5.1 Kontrak Request & Urutan Perhitungan (terverifikasi di kode)

Sumber: `BookingController::storeHotelBooking()` baris 183–194 & 225–232.

### Dua flag yang identik

```php
$hasInsurance = !empty($data['has_insurance']) || !empty($data['include_insurance']);
```

`has_insurance` dan `include_insurance` **ekuivalen** — di-OR, bukan diproses terpisah. Kirim salah satu saja; mengirim keduanya tidak menggandakan premi. Keduanya sama-sama tervalidasi `nullable|boolean`.

**Syarat premi benar-benar terpasang** (keduanya wajib):

| Yang dikirim | Hasil |
|---|---|
| flag `true` **dan** `insurance_plan_id` valid | ✅ premi dihitung, baris `booking_insurances` dibuat |
| flag `true`, `insurance_plan_id` kosong | ❌ premi `0`, **`bookings.has_insurance` tersimpan `false`** |
| flag `true`, `insurance_plan_id` tidak ditemukan | ❌ idem — `InsurancePlan::find()` mengembalikan `null` |
| `insurance_plan_id` valid, flag tidak dikirim | ❌ diabaikan seluruhnya |

Baris 215 menyimpan `'has_insurance' => $hasInsurance && !empty($insurancePlan)` — jadi kolom DB mencerminkan **hasil akhir**, bukan permintaan klien. Jangan pakai flag request sebagai asumsi keadaan tersimpan.

### Urutan rumus uang — premi ditambahkan SETELAH diskon

```php
$insuranceFee = $insurancePlan->calculatePremium($nights, $adults, $roomSubtotal);  // basis: subtotal PENUH
$total        = max(0, $roomSubtotal - $discount) + $insuranceFee;                  // premi di LUAR diskon
$tripCoins    = (int) round($total * 0.005);                                        // 0.5% dari total termasuk premi
```

Tiga konsekuensi yang mudah salah dipahami:

1. **Basis premi adalah `$roomSubtotal` sebelum diskon.** Voucher **tidak** mengecilkan premi — untuk paket berjenis persentase, diskon Rp100.000 tidak mengurangi premi sepeser pun.
2. **Premi tidak ikut didiskon.** `max(0, ...)` hanya membungkus `$roomSubtotal - $discount`; premi ditambahkan di luar tanda kurung, sehingga total **tidak akan pernah** turun di bawah nilai premi meski diskon melebihi subtotal.
3. **Trip Coins dihitung dari total yang sudah termasuk premi**, jadi membeli asuransi menambah koin yang didapat.

Urutan ini wajib dipertahankan di UI Flutter agar angka di layar sama dengan server. Test terkait: **T-L6** (urutan rumus), **T-L9** (`booking_insurances` status `pending` + `premium_amount`). Rujukan: [screen/readme_screen.md §10.4](screen/readme_screen.md#104-rumus-uang-urutan-wajib).

> Premi dihitung dengan `InsurancePlan::calculatePremium($nights, $adults, $roomSubtotal)`. Sisi Flutter sudah punya padanannya dan diuji di `flutter/test/models/insurance_plan_test.dart` (4 test, termasuk *"fixed per night multiple guests (matches Laravel)"*) — jaga kedua implementasi tetap sinkron; bila rumus di Laravel berubah, test Flutter itulah yang harus ikut diperbarui.

---

## 6. Integrasi dengan Form Multi-Kamar (Checkout Flutter)

Pada alur pemesanan kombo multi-kamar di [`flutter/lib/screens/property/hotel/hotel_booking_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/property/hotel/hotel_booking_screen.dart):
1. **Nama Tertanggung**: Menggunakan nama tamu kamar pertama (`Kamar 1: Family Suite` -> `MOH Baswan`) secara otomatis sebagai pemegang polis utama (*Primary Policy Holder*).
2. **Kalkulasi Premi Multi-Tamu**: Premi dihitung otomatis berdasarkan total malam menginap dikali jumlah total tamu dewasa (`adults`).
3. **Klaim & Perlindungan**: Mencakup kompensasi keterlambatan check-in hotel, santunan rawat inap darurat selama menginap, serta kerusakan/kehilangan bagasi di area hotel.

