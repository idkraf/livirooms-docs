# Payment Flow Documentation

Dokumen ini menjelaskan arsitektur dan alur pembayaran Midtrans pada sistem Sewain, mencakupi bagian yang sudah diimplementasikan, yang belum, dan solusi yang disarankan untuk setiap masalah yang diidentifikasi.

## Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

## Daftar Isi

- [Arsitektur](#arsitektur)
- [Yang Sudah Diterapkan](#yang-sudah-diterapkan)
- [Yang Belum Diterapkan](#yang-belum-diterapkan)
- [Poin-Poin Penting & Solusi](#poin-poin-penting--solusi)
- [Status Implementasi Keseluruhan](#status-implementasi-keseluruhan)
- [Rekomendasi Teknis](#rekomendasi-teknis)
- [Referensi File](#referensi-file)

## Arsitektur

```
Flutter (FE)                     Laravel (BE)                    Midtrans
    |                                 |                              |
    |--- POST /bookings ------------->|                              |
    |    (create booking + order)     |                              |
    |<--- {booking, order} -----------|                              |
    |                                 |                              |
    |--- GET /bookings/{id} --------->|                              |
    |<--- booking detail -------------|                              |
    |                                 |                              |
    |--- POST /bookings/{id}/confirm ->|   [host only]               |
    |--- POST /bookings/{id}/reject --->|   [host only]               |
    |                                 |                              |
    |--- POST /orders/{id}/pay ------->|                              |
    |    body: {method: "qris"}       |                              |
    |                                 |--- Snap::getSnapToken() ---->|
    |                                 |<-- {snap_token, redirect} --|
    |<--- {payment, snap_token,      |                              |
    |     redirect_url} --------------|                              |
    |                                 |                              |
    |--- open external browser -------|----------------------------->|
    |    (redirect_url)               |     [user pays on Midtrans]  |
    |                                 |<------ webhook notification -|
    |                                 |   (transaction_status, etc)  |
    |                                 |                              |
    |--- GET /payments/{id} ---------->|                              |
    |<--- payment detail --------------|                              |
```

**Tumpukan teknologi:**
- **Gateway**: Midtrans Snap (VTWeb + Snap Token)
- **Backend**: Laravel 10+, Livewire, Yajra DataTables
- **Frontend**: Flutter, `url_launcher` untuk redirect ke browser eksternal, `app_links` untuk deep link
- **Webhook**: Server-to-server notification dari Midtrans untuk update status otomatis

## Yang Sudah Diterapkan

### Backend (Laravel)

#### Booking & Host Confirmation

File: `app/Http/Controllers/Api/BookingController.php`, `app/Models/Booking.php`, `database/migrations/2026_08_11_000001_add_host_confirmed_to_bookings_table.php`

- User membuat booking → `bookings.status = waiting_confirmation`, `bookings.host_confirmed = false`
- Overlap check saat booking creation: `lockForUpdate()` pada query booking aktif + `availabilities` check
- Host dapat mengkonfirmasi booking via `POST /api/v1/bookings/{booking}/confirm` → `host_confirmed = true`, `bookings.status = confirmed`, `orders.status = confirmed`
- Host dapat menolak booking via `POST /api/v1/bookings/{booking}/reject` → booking/order/payment → `cancelled`, restore availability
- `restoreAvailability()`: saat booking cancelled/expired, cek overlap booking lain; jika tidak ada, restore `is_available = true`

#### Auto-Cancel Booking Check-in Terlewat

File: `app/Console/Commands/CancelExpiredPayments.php`

- Command `payments:cancel-expired` sekarang juga menjalankan `cancelPastCheckInBookings()`
- Membatalkan booking dengan `check_in < hari ini` dan status `waiting_payment`/`waiting_confirmation`/`confirmed`/`paid`/`waiting_checkin`
- Cascade: booking → `cancelled`, order → `cancelled`, payment → `expired`, restore availability

#### Konfigurasi Midtrans

- Server Key, Client Key, Production Mode disimpan di tabel `payment_settings`
- Data merchant (nama, email, telepon) juga disimpan
- Admin dapat mengubah semua nilai melalui Livewire panel
- Konfigurasi terbaca dari `config/services.php` dan `payment_settings` table

#### Manajemen Metode Pembayaran

File: `database/seeders/PaymentMethodSeeder.php`, `app/Models/PaymentMethod.php`, `app/Livewire/PaymentMethods/Form.php`, `app/Http/Controllers/Admin/PaymentMethodController.php`, `app/DataTables/PaymentMethodDataTable.php`

Metode yang terdaftar:

| Kode           | Nama            | Group             | Min Amount | Max Amount   | Enabled | Metadata                              |
|----------------|-----------------|-------------------|------------|--------------|---------|---------------------------------------|
| `virtual_account` | Virtual Account | `virtual_account` | Rp10.000   | Rp50.000.000 | ✅      | banks: [bca, bni, mandiri]            |
| `qris`         | QRIS            | `qris`            | Rp10.000   | Rp20.000.000 | ✅      | -                                     |
| `ewallet`      | E-Wallet        | `ewallet`         | Rp10.000   | Rp10.000.000 | ✅      | channels: [gopay, shopee_pay, dana]   |
| `credit_card`  | Kartu Kredit    | `credit_card`     | Rp50.000   | Rp100.000.000| ✅      | -                                     |
| `paylater`     | PayLater        | `paylater`        | Rp100.000  | Rp50.000.000 | ❌      | -                                     |

- Setiap metode memiliki `min_amount`, `max_amount`, dan `metadata` (JSON)
- Admin dapat menambah, mengedit, menonaktifkan metode via Livewire
- Validasi range amount diterapkan sebelum transaksi dibuat

#### Model Pembayaran

File: `app/Models/Payment.php`, `database/seeders/PaymentSeeder.php`

Tabel `payments` menyimpan:

| Field              | Tipe     | Keterangan                              |
|--------------------|----------|-----------------------------------------|
| `id`               | bigint   | Primary key                             |
| `order_id`         | bigint   | Foreign key ke `orders`                 |
| `method`           | string   | Kode metode (virtual_account, qris, etc)|
| `amount`           | decimal  | Jumlah yang dibayar                     |
| `status`           | enum     | pending / paid / failed / expired / refunded |
| `paid_at`          | datetime | Timestamp pembayaran sukses             |
| `gateway_reference`| string   | Transaction ID dari Midtrans            |

Hubungan: `Payment belongsTo Order`, `Order hasOne Payment`

#### API Pembayaran

File: `app/Http/Controllers/Api/PaymentController.php`

Endpoint yang tersedia:

| Method | Endpoint                  | Fungsi                                          |
|--------|---------------------------|-------------------------------------------------|
| `GET`  | `/api/payments/methods`   | Mengambil daftar metode pembayaran yang aktif    |
| `POST` | `/api/orders/{id}/pay`    | Membuat transaksi Midtrans Snap                 |
| `POST` | `/api/orders/{id}/pay/retry` | Membuat ulang link pembayaran (continue/retry) |
| `GET`  | `/api/payments/{id}`      | Detail pembayaran                                |
| `POST` | `/api/payments/{payment}/reconcile` | Sinkron status dengan Midtrans |
| `POST` | `/api/payments/webhook`   | Webhook notification dari Midtrans               |

**Logika `POST /api/orders/{id}/pay`:**
1. Validasi kepemilikan order (hanya user pemilik)
2. Validasi order masih `pending` (belum diproses)
3. Validasi metode pembayaran aktif
4. Validasi range amount (min/max)
5. Buat/update record `Payment` dengan status `pending`
6. Build parameter Snap transaction (`transaction_details`, `customer_details`, `callbacks`)
7. Panggil `Midtrans\Snap::getSnapToken()`
8. Return `payment`, `snap_token`, dan `redirect_url`

**Logika `POST /api/orders/{id}/pay/retry` (`payUrl`):**
1. Validasi kepemilikan order
2. Validasi payment ada dan statusnya `pending`/`failed`/`expired`
3. **Availability guard**: cek apakah ada booking aktif lain yang overlap tanggal booking ini
   - Jika overlap → mark booking/order/payment sebagai `cancelled`, return 422
   - Perbedaan: `cancelled` = sistem batalkan karena availability; `failed` = Midtrans menolak transaksi
4. Buat Snap transaction baru, return `redirect_url`

**Logika Webhook:**
- Verifikasi `signature_key` menggunakan SHA-512 hash dari `order_id + status_code + gross_amount + server_key`
- Parse `order_id` untuk mendapatkan `payment_id` (format: `{order_code}-{payment_id}`)
- Jika `transaction_status` = capture/settlement dan `fraud_status` = accept:
  - Update payment → `paid`, set `paid_at`, `gateway_reference`
  - Update order → `processing`
  - Update booking → `paid`
- Jika `transaction_status` = deny/cancel/expire:
  - Update payment → `failed` atau `expired`
  - Update order → `cancelled`
  - Update booking → `cancelled` atau `expired`

#### Admin Panel

File: `app/Http/Controllers/Admin/PaymentController.php`, `app/Http/Controllers/Admin/PaymentMethodController.php`, `app/DataTables/PaymentDataTable.php`, `app/DataTables/PaymentMethodDataTable.php`, `app/Livewire/Payments/Form.php`, `app/Livewire/Payments/PaymentModal.php`

- Admin dapat melihat daftar pembayaran dan metode pembayaran
- DataTables dengan export CSV/print
- Livewire form untuk create/edit payment dan payment method

### Frontend (Flutter)

#### Model

File: `flutter/lib/models/payment.dart`, `flutter/lib/models/payment_method.dart`, `flutter/lib/models/booking.dart`

```dart
class Booking {
  final int id;
  final String bookingCode;
  final int propertyId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String durationType;
  final String status;
  final double totalPrice;
  final bool hostConfirmed;
  final Property? property;
  final Order? order;
  // ...
}

class Order {
  final int id;
  final String orderCode;
  final int bookingId;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final Payment? payment;
  // ...
}

class Payment {
  final int id;
  final int orderId;
  final String method;
  final double amount;
  final String status;
  final String? snapToken;
  final String? redirectUrl;
  // ... factory fromJson
}

class PaymentMethod {
  final String code;
  final String name;
  final String group;
  final String? icon;
  final bool isEnabled;
  final double? minAmount;
  final double? maxAmount;
  final Map<String, dynamic>? metadata;
  // ... factory fromJson
}
```

#### Service

File: `flutter/lib/services/booking_service.dart`, `flutter/lib/services/host_service.dart`

```dart
// BookingService
Future<List<PaymentMethod>> paymentMethods()   // GET /payments/methods
Future<Payment> paymentDetail(int id)          // GET /payments/{id}
Future<Payment> pay(int orderId, String method) // POST /orders/{orderId}/pay
Future<Payment> retryPayment(int orderId)      // POST /orders/{orderId}/pay/retry
Future<bool> checkAvailability(int propertyId, DateTime checkIn, DateTime checkOut, [int? excludeBookingId])
Future<Booking> bookingDetail(int bookingId)   // GET /bookings/{booking}

// HostService
Future<Paginated<Order>> orders({int page = 1, String? status}) // GET /host/orders
Future<Order> orderDetail(int id)                                  // GET /host/orders/{id}
Future<void> confirmOrder(int bookingId)       // POST /bookings/{booking}/confirm
Future<void> rejectOrder(int bookingId)        // POST /bookings/{booking}/reject
```

#### Screen: Payment Method Selection

File: `flutter/lib/screens/payment/payment_method_screen.dart`

- Menampilkan ringkasan order (properti, tanggal, durasi, harga)
- Menampilkan breakdown harga (subtotal, cleaning fee, service fee, deposit, diskon promo, total)
- Memuat daftar metode pembayaran dari API
- Button "Buat Pesanan" yang:
  1. Membuat booking + order via `BookingService.create()`
  2. Navigasi ke `BookingDetailScreen` (bukan langsung ke pembayaran)
- **Pembayaran tidak dilakukan di screen ini** — dilakukan dari booking detail setelah host mengkonfirmasi

#### Screen: Booking Detail

File: `flutter/lib/screens/booking/booking_detail_screen.dart`

- Menampilkan info properti, tanggal, tamu, durasi, total
- Barcode simulasi dari booking code
- **Menunggu konfirmasi host**: jika `host_confirmed = false`, tampilkan pesan "Menunggu konfirmasi dari pemilik properti..."
- **Setelah host konfirmasi** (`host_confirmed = true`): tampilkan tombol **Lanjutkan Bayar**
- Tombol **Lanjutkan Bayar**: pilih metode pembayaran → panggil `POST /orders/{id}/pay` → buka browser Midtrans
- Tombol **Lanjutkan Pembayaran**: jika payment sudah `pending`, panggil `POST /orders/{id}/pay/retry`
- Tombol **Coba Bayar Lagi** / **Buat Pesanan Baru**: untuk payment `failed`/`expired`
- Button "Hubungi Pemilik"
- Button "Batalkan Pesanan" (hanya untuk status `waiting*`)
- Polling setiap 5 detik untuk update status payment

#### Screen: Mitra Order Management

File: `flutter/lib/screens/mitra/order_management_screen.dart`, `order_detail_screen.dart`

- Data order dimuat dari `GET /host/orders` (berdasarkan `property.host_id`, bukan `user_id`)
- Tab **Baru**: menampilkan order dengan status `waiting_confirmation`/`confirmed`
  - Menampilkan rentang menginap, waktu dibuat, dan badge "Waktu konfirmasi telah terlewat" jika `check_out` sudah terlewat
  - Tombol **Terima**/**Tolak** disembunyikan jika order sudah expired
- Tombol **Terima** → panggil `POST /bookings/{booking}/confirm` → `host_confirmed = true`
- Tombol **Tolak** → panggil `POST /bookings/{booking}/reject` → booking/order → `cancelled`, restore availability
- Order detail menampilkan timeline status, rincian waktu, dan tombol konfirmasi/tolak (disembunyikan jika expired)

---

## Yang Belum Diterapkan

### Backend (Laravel)

| # | Fitur yang Belum | Keterangan |
|---|------------------|------------|
| 1 | **Midtrans Snap WebView di backend** | Backend hanya mengembalikan `snap_token` dan `redirect_url`. Tidak ada endpoint untuk render Snap WebView secara native. |
| 2 | **Payment history endpoint** | Tidak ada endpoint untuk daftar riwayat pembayaran user. Hanya `paymentDetail(id)` dan admin DataTables. |
| 3 | **Payment notification untuk user** | Tidak ada sistem notifikasi (email/push) saat pembayaran berhasil/gagal. |
| 4 | **Refund endpoint** | Webhook menangani `refunded` status tapi tidak ada API untuk memicu refund dari admin/backend. |
| 5 | **Payment detail di API response order** | Response order tidak menyertakan data payment secara eager-loaded. |
| 6 | **`enabled_payments` ke Snap** | Metode yang dipilih user belum diteruskan ke Midtrans Snap. |

### Frontend (Flutter)

| # | Fitur yang Belum | Keterangan |
|---|------------------|------------|
| 1 | **Payment Status Screen** | Tidak ada screen khusus untuk menampilkan detail pembayaran (metode, nominal, status, reference, waktu). |
| 2 | **WebView Snap Integration** | Saat ini menggunakan `url_launcher` (browser eksternal). Tidak ada WebView untuk Snap agar user tetap di dalam app. |
| 3 | **Payment Polling / Real-time Status** | Setelah redirect ke browser eksternal, FE melakukan polling setiap 5 detik untuk update status. |
| 4 | **Credit Card Integration** | `credit_card` dan `paylater` tercantum di metode pembayaran, tetapi tidak ada form input khusus untuk kartu kredit. Midtrans Snap akan menanganinya, tetapi tidak ada flow testing untuk metode ini di Flutter. |
| 5 | **Payment History Screen** | Tidak ada screen untuk melihat riwayat semua pembayaran user. |
| 6 | **Notification Pembayaran** | Tidak ada in-app notification atau push notification untuk update status pembayaran. |
| 7 | **Timer/Countdown Kedaluwarsa di UI** | Tidak ada indikator waktu tersisa sebelum booking expired di booking detail atau payment method screen. |

---

## Poin-Poin Penting & Solusi

### Informasi Pembayaran di Detail Order

**Masalah:** `booking_detail_screen.dart` saat ini hanya menampilkan info properti, check-in/out, jumlah tamu, tipe/durasi, total harga, barcode booking code, dan button "Hubungi Pemilik" / "Batalkan Pesanan". **Tidak menampilkan:** metode pembayaran, status pembayaran, nominal yang dibayar, waktu pembayaran, reference transaksi dari Midtrans, atau aksi lanjutkan pembayaran jika masih pending.

**Solusi yang Disarankan:**

**Backend — Langkah 1:** Update eager-load di API Booking. Method `show(Booking $booking, Request $request)` di `BookingController`:

```php
return ApiResponse::success(
    $booking->load('order.payment'),
    'Detail booking berhasil dimuat.'
);
```

**Backend — Langkah 2:** Pastikan response JSON menyertakan payment. Flutter akan menerima struktur:

```json
{
  "booking": { ... },
  "order": {
    "id": 1,
    "order_code": "ORD-001",
    "payment": {
      "id": 1,
      "method": "qris",
      "amount": 500000,
      "status": "pending",
      "paid_at": null,
      "gateway_reference": null
    }
  }
}
```

**Frontend — Langkah 1:** Update `Booking` model agar memiliki `order` field, dan `Order` model agar memiliki `payment` field.

**Frontend — Langkah 2:** Tambahkan widget `_PaymentInfoCard` di `booking_detail_screen.dart` setelah baris barcode block, untuk menampilkan:
- Metode pembayaran
- Nominal
- Waktu pembayaran (jika `paidAt` ada)
- Reference transaksi (jika ada)
- Status pembayaran dengan badge warna

**Frontend — Langkah 3:** Update `Payment` model agar memiliki `paidAt` dan `gatewayReference`.

**Frontend — Langkah 4:** Tambahkan helper di `formatters.dart`:
- `paymentMethodLabel(String method)` — map kode ke label tampilan
- `paymentStatusLabel(String status)` — map status ke label Bahasa Indonesia
- `dateTime(String iso)` — format ISO datetime ke format lokal

### Tombol Lanjut Pembayaran dan Mekanismenya

**Masalah:** Setelah user memilih metode pembayaran dan menekan "Confirm And Pay":
1. Booking + order dibuat
2. Payment record dibuat dengan status `pending`
3. `redirect_url` Midtrans dibuka di browser eksternal
4. **Langsung navigasi ke `BookingSuccessScreen`** meskipun pembayaran belum selesai

Jika user menutup browser tanpa menyelesaikan pembayaran:
- Tidak ada tombol untuk melanjutkan pembayaran
- Tidak ada cara untuk kembali ke halaman pembayaran Midtrans
- User harus membuat booking baru

**Solusi yang Disarankan:**

**Backend — Langkah 1:** Tambahkan method `payUrl` di `PaymentController` untuk membuat link pembayaran baru:

```php
public function payUrl(Order $order, Request $request)
{
    abort_unless($order->user_id === $request->user()->id, 403);

    $payment = $order->payment;
    if (!$payment) {
        return ApiResponse::error('Pembayaran belum dibuat.', 404);
    }

    if (in_array($payment->status, ['paid', 'refunded'])) {
        return ApiResponse::error('Pembayaran sudah selesai.', 422);
    }

    if (!in_array($payment->status, ['pending', 'failed', 'expired'])) {
        return ApiResponse::error(
            'Pembayaran ini tidak dapat dilanjutkan. Status: ' . $payment->status,
            422
        );
    }

    $redirectUrl = null;
    $snapToken = null;

    if (class_exists(\Midtrans\Snap::class)) {
        \Midtrans\Config::$serverKey = config('services.midtrans.server_key');
        \Midtrans\Config::$isProduction = (bool) config('services.midtrans.is_production');
        \Midtrans\Config::$isSanitized = true;
        \Midtrans\Config::$is3ds = true;

        $params = [
            'transaction_details' => [
                'order_id' => $order->order_code . '-' . $payment->id,
                'gross_amount' => (int) round($order->total),
            ],
            'customer_details' => [
                'first_name' => $request->user()->name,
                'email' => $request->user()->email,
            ],
            'callbacks' => [
                'finish' => config('app.url') . '/payment/finish',
                'unfinish' => config('app.url') . '/payment/unfinish',
                'error' => config('app.url') . '/payment/error',
            ],
        ];

        try {
            $snapToken = \Midtrans\Snap::getSnapToken($params);
            $payment->update(['status' => 'pending']);

            $redirectUrl = \Midtrans\Config::$isProduction
                ? 'https://app.midtrans.com/snap/v2/vtweb/' . $snapToken
                : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/' . $snapToken;
        } catch (\Throwable $e) {
            Log::error('Midtrans snap error', ['e' => $e->getMessage()]);

            return ApiResponse::error(
                'Gagal membuat link pembayaran. Silakan coba lagi.',
                502,
                null,
                ApiResponse::ERR_GATEWAY
            );
        }
    }

    return ApiResponse::success([
        'payment' => $payment,
        'snap_token' => $snapToken,
        'redirect_url' => $redirectUrl,
    ], 'Link pembayaran berhasil dibuat.');
}
```

**Backend — Langkah 2:** Tambahkan route API:

```php
// routes/api_mobile.php — sebelum closing bracket group auth:sanctum
Route::middleware('auth:sanctum')->post('/orders/{order}/pay/retry', [App\Http\Controllers\Api\PaymentController::class, 'payUrl']);
```

**Backend — Langkah 3:** Tambahkan route web callback untuk Midtrans:

```php
// routes/web.php
use App\Http\Controllers\Payment\FinishController;
use App\Http\Controllers\Payment\UnfinishController;
use App\Http\Controllers\Payment\ErrorController;

Route::get('/payment/finish', [FinishController::class, 'finish'])->name('payment.finish');
Route::get('/payment/unfinish', [UnfinishController::class, 'unfinish'])->name('payment.unfinish');
Route::get('/payment/error', [ErrorController::class, 'error'])->name('payment.error');
```

**Backend — Langkah 4:** Buat `FinishController`, `UnfinishController`, `ErrorController`:

Path: `app/Http/Controllers/Payment/FinishController.php`

```php
<?php

namespace App\Http\Controllers\Payment;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\Request;

class FinishController extends Controller
{
    public function finish(Request $request)
    {
        $orderId = $request->query('order_id');
        $transactionStatus = $request->query('transaction_status');

        $separatorPos = strrpos((string) $orderId, '-');
        $paymentId = $separatorPos === false
            ? 0
            : (int) substr((string) $orderId, $separatorPos + 1);

        $payment = Payment::find($paymentId);

        if ($payment && $payment->status === 'pending') {
            if (in_array($transactionStatus, ['capture', 'settlement'])) {
                $payment->update([
                    'status' => 'paid',
                    'paid_at' => now(),
                    'gateway_reference' => $request->query('transaction_id'),
                ]);
                $payment->order?->update(['status' => 'processing']);
                $payment->order?->booking?->update(['status' => 'paid']);
            } elseif (in_array($transactionStatus, ['cancel', 'deny'])) {
                $payment->update(['status' => 'failed']);
                $payment->order?->update(['status' => 'cancelled']);
                $payment->order?->booking?->update(['status' => 'cancelled']);
            } elseif ($transactionStatus === 'expire') {
                $payment->update(['status' => 'expired']);
                $payment->order?->update(['status' => 'cancelled']);
                $payment->order?->booking?->update(['status' => 'expired']);
            }
        }

        $frontendDeepLink = 'sewain://payment-result?status='
            . ($payment?->status ?? 'unknown')
            . '&orderId=' . ($payment?->order_id ?? 0);

        return redirect()->away($frontendDeepLink);
    }
}
```

Path: `app/Http/Controllers/Payment/UnfinishController.php`

```php
<?php

namespace App\Http\Controllers\Payment;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\Request;

class UnfinishController extends Controller
{
    public function unfinish(Request $request)
    {
        $orderId = $request->query('order_id');

        $separatorPos = strrpos((string) $orderId, '-');
        $paymentId = $separatorPos === false
            ? 0
            : (int) substr((string) $orderId, $separatorPos + 1);

        $payment = Payment::find($paymentId);

        if ($payment && $payment->status === 'pending') {
            $payment->update(['status' => 'failed']);
        }

        $frontendDeepLink = 'sewain://payment-result?status='
            . ($payment?->status ?? 'unknown')
            . '&orderId=' . ($payment?->order_id ?? 0);

        return redirect()->away($frontendDeepLink);
    }
}
```

Path: `app/Http/Controllers/Payment/ErrorController.php`

```php
<?php

namespace App\Http\Controllers\Payment;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\Request;

class ErrorController extends Controller
{
    public function error(Request $request)
    {
        $orderId = $request->query('order_id');

        $separatorPos = strrpos((string) $orderId, '-');
        $paymentId = $separatorPos === false
            ? 0
            : (int) substr((string) $orderId, $separatorPos + 1);

        $payment = Payment::find($paymentId);

        if ($payment && $payment->status === 'pending') {
            $payment->update(['status' => 'failed']);
        }

        $frontendDeepLink = 'sewain://payment-result?status='
            . ($payment?->status ?? 'unknown')
            . '&orderId=' . ($payment?->order_id ?? 0);

        return redirect()->away($frontendDeepLink);
    }
}
```

> **Catatan penting untuk Deep Link:** Laravel mengembalikan redirect ke skema custom `sewain://payment-result?status=...&orderId=...`. Flutter harus menangkap scheme `sewain://` dan parse query parameter untuk navigasi ke screen yang sesuai.

**Frontend — Langkah 1:** Update `booking_service.dart` — tambahkan method `retryPayment`:

```dart
Future<Payment> retryPayment(int orderId) async {
  final res = await _api.post('orders/$orderId/pay/retry');
  final data = res.dataMap;
  final raw = data['payment'];

  if (raw is! Map<String, dynamic>) {
    throw ApiException(
      500,
      'Gagal memperbarui pembayaran.',
      null,
      ApiErrorCode.malformed,
    );
  }

  final payment = Payment.fromJson(raw);
  return Payment(
    id: payment.id,
    orderId: payment.orderId,
    method: payment.method,
    amount: payment.amount,
    status: payment.status,
    snapToken: data['snap_token'] as String? ?? payment.snapToken,
    redirectUrl: data['redirect_url'] as String? ?? payment.redirectUrl,
    paidAt: payment.paidAt,
    gatewayReference: payment.gatewayReference,
  );
}
```

**Frontend — Langkah 2:** Update `payment_method_screen.dart` — ubah method `_confirmAndPay` menjadi:

```dart
Future<void> _confirmAndPay() async {
  setState(() => _processing = true);
  try {
    final (booking, order) = await _bookingService.create(
      propertyId: widget.args.property.id,
      checkIn: widget.args.checkIn,
      checkOut: widget.args.checkOut,
      durationType: widget.args.durationType,
      voucherCode: _appliedCode,
    );
    final payment = await _bookingService.pay(order.id, _selectedMethod);
    if (!mounted) return;

    final redirectUrl = payment.redirectUrl;
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final uri = Uri.tryParse(redirectUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.payments_outlined,
              color: AppColors.gold, size: 48),
          title: const Text('Pembayaran Menunggu'),
          content: Text(
            'Pesanan ${order.orderCode} berhasil dibuat. '
            'Silakan selesaikan pembayaran di halaman Midtrans. '
            'Anda dapat melanjutkan pembayaran kapan saja dari halaman detail booking.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.bookingDetail,
                  (r) => r.settings.name == Routes.home,
                  arguments: booking,
                );
              },
              child: const Text('Lihat Detail Booking'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.bookingSuccess,
      (r) => r.settings.name == Routes.home,
      arguments: BookingSuccessArgs(booking: booking, order: order),
    );
  } on ApiException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal memproses pembayaran.')),
    );
  } finally {
    if (mounted) setState(() => _processing = false);
  }
}
```

**Catatan:** Hapus baris yang sebelumnya melakukan navigasi langsung ke `BookingSuccessScreen`.

**Frontend — Langkah 3:** Update `booking_detail_screen.dart` — tambahkan import `Payment` model, method `_continuePayment()` dan `_retryPayment()`, dan conditional buttons di `build()` setelah `_PaymentInfoCard`:

```dart
Future<void> _continuePayment() async {
  if (booking.order == null) return;
  setState(() => _cancelling = true);
  try {
    final payment = await _bookingService.retryPayment(booking.order!.id);
    if (!mounted) return;

    final redirectUrl = payment.redirectUrl;
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final uri = Uri.tryParse(redirectUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan selesaikan pembayaran di tab baru.')),
      );
    }
  } on ApiException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal melanjutkan pembayaran.')),
    );
  } finally {
    if (mounted) setState(() => _cancelling = false);
  }
}

Future<void> _retryPayment() async {
  if (booking.order == null) return;
  setState(() => _cancelling = true);
  try {
    final payment = await _bookingService.retryPayment(booking.order!.id);
    if (!mounted) return;

    final redirectUrl = payment.redirectUrl;
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final uri = Uri.tryParse(redirectUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan selesaikan pembayaran di tab baru.')),
      );
    }
  } on ApiException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal memproses pembayaran.')),
    );
  } finally {
    if (mounted) setState(() => _cancelling = false);
  }
}
```

Tambahkan button callbacks di `build()` setelah barcode block:

```dart
if (booking.payment != null) ...[
  const SizedBox(height: 16),
  _PaymentInfoCard(payment: booking.payment!),
  if (booking.payment!.status == 'pending') ...[
    const SizedBox(height: 12),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _cancelling ? null : _continuePayment,
        icon: const Icon(Icons.payment_outlined),
        label: const Text('Lanjutkan Pembayaran'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
        ),
      ),
    ),
  ],
  if (booking.payment!.status == 'failed' ||
      booking.payment!.status == 'expired') ...[
    const SizedBox(height: 12),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _cancelling ? null : _retryPayment,
        icon: Icon(booking.payment!.status == 'expired'
            ? Icons.refresh
            : Icons.replay),
        label: Text(booking.payment!.status == 'expired'
            ? 'Buat Pesanan Baru'
            : 'Coba Bayar Lagi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
        ),
      ),
    ),
  ],
],
```

**Catatan:** Reuse state variable `_cancelling` sebagai loading indicator untuk tombol pembayaran.

---

### Jika Ada Pembayaran Gagal: Bagaimana Handlenya di Laravel dan Flutter

**Backend (Laravel) — Status Flow di Webhook:**

File: `app/Http/Controllers/Api/PaymentController.php` method `webhook`

```
pending
  |
  |-- capture/settlement + accept --> paid --> (order: processing, booking: paid)
  |
  |-- deny/cancel --> failed --> (order: cancelled, booking: cancelled)
  |
  |-- expire --> expired --> (order: cancelled, booking: expired)
  |
  |-- refund --> refunded (manual trigger needed)
```

**Yang Sudah Diterapkan:**
- Webhook verifies signature key dengan benar
- Status `paid`: payment → `paid`, order → `processing`, booking → `paid`
- Status `failed/expired`: payment → `failed`/`expired`, order → `cancelled`, booking → `cancelled`/`expired`
- Callback `finish`, `unfinish`, `error` URL sudah dikonfigurasi di method `pay()`

**Yang Kurang / Perbaikan yang Disarankan:**

**1. Finish/Unfinish/Error callback controller** — sudah dijelaskan di atas (Langkah 3-6).

**2. Payment Status Reconciliation Endpoint:**

```php
// app/Http/Controllers/Api/PaymentController.php
use Midtrans\Transaction;

public function reconcile(Payment $payment, Request $request)
{
    abort_unless($payment->order->user_id === $request->user()->id, 403);

    if (!in_array($payment->status, ['pending', 'failed', 'expired'])) {
        return ApiResponse::error(
            'Pembayaran ini tidak dapat disinkronkan. Status: ' . $payment->status,
            422
        );
    }

    $orderId = $payment->order->order_code . '-' . $payment->id;

    if (!class_exists(\Midtrans\Transaction::class)) {
        return ApiResponse::error('Midtrans SDK tidak terinstal.', 500);
    }

    \Midtrans\Config::$serverKey = config('services.midtrans.server_key');
    \Midtrans\Config::$isProduction = (bool) config('services.midtrans.is_production');

    try {
        $status = \Midtrans\Transaction::status($orderId);
        $transactionStatus = $status->transaction_status ?? '';
        $fraudStatus = $status->fraud_status ?? 'accept';

        if (in_array($transactionStatus, ['capture', 'settlement']) && $fraudStatus === 'accept') {
            $payment->update([
                'status' => 'paid',
                'paid_at' => now(),
                'gateway_reference' => $status->transaction_id ?? $payment->gateway_reference,
            ]);
            $payment->order->update(['status' => 'processing']);
            $payment->order->booking->update(['status' => 'paid']);
        } elseif (in_array($transactionStatus, ['deny', 'cancel'])) {
            $payment->update(['status' => 'failed']);
            $payment->order->update(['status' => 'cancelled']);
            $payment->order->booking?->update(['status' => 'cancelled']);
        } elseif ($transactionStatus === 'expire') {
            $payment->update(['status' => 'expired']);
            $payment->order->update(['status' => 'cancelled']);
            $payment->order->booking?->update(['status' => 'expired']);
        }

        return ApiResponse::success(
            $payment->fresh()->load('order'),
            'Status berhasil disinkronkan.'
        );
    } catch (\Throwable $e) {
        return ApiResponse::error('Gagal mengecek status: ' . $e->getMessage(), 502);
    }
}
```

**Tambahkan route:**

```php
// routes/api_mobile.php
Route::middleware('auth:sanctum')->get('/payments/{payment}/reconcile', [App\Http\Controllers\Api\PaymentController::class, 'reconcile']);
```

**3. Payment Retry dengan Validasi** — sudah dijelaskan di bagian Tombol Lanjut Pembayaran.

**4. Logging** — Tambahkan `Log::info()` di setiap perubahan status di `payUrl`, `reconcile`, dan controller callback:

```php
Log::info('Payment status updated', [
    'payment_id' => $payment->id,
    'old_status' => $oldStatus,
    'new_status' => $payment->status,
]);
```

**Catatan keamanan:**
- Endpoint `reconcile` memanggil Midtrans API menggunakan server key — pastikan endpoint hanya bisa diakses oleh pemilik payment
- Parameter `gross_amount` selalu dihitung dari `$order->total` (server-side), tidak pernah dari request body

#### Frontend (Flutter) — Status Handling

| Status        | UI di Booking Detail                              | Aksi yang Tersedia                     |
|---------------|---------------------------------------------------|----------------------------------------|
| `pending`     | Badge "Menunggu Pembayaran" (gold)               | Tombol "Lanjutkan Pembayaran"         |
| `paid`        | Badge "Berhasil" (green), tampilkan detail bayar | -                                      |
| `failed`      | Badge "Gagal" (red), tampilkan pesan error       | Tombol "Coba Bayar Lagi"              |
| `expired`     | Badge "Kedaluwarsa" (red), tampilkan pesan       | Tombol "Buat Pesanan Baru" atau retry |
| `refunded`    | Badge "Dikembalikan" (blue)                      | -                                      |

**Implementasi tombol lanjut/coba bayar** — tambahkan 3 blok kode di `booking_detail_screen.dart`:
1. Import `Payment` model
2. Method `_continuePayment()` dan `_retryPayment()`
3. Conditional buttons di `build()` setelah `_PaymentInfoCard`

**Handling Deep Link dari Midtrans Callback:**

File: `flutter/lib/router.dart`

**Tambahkan route constant:**

```dart
static const paymentResult = '/payment/result';
```

**Tambahkan case di `onGenerateRoute`:**

```dart
case Routes.paymentResult:
  {
    final uri = Uri.parse(settings.name ?? '');
    final status = uri.queryParameters['status'] ?? 'unknown';
    final orderId = int.tryParse(uri.queryParameters['orderId'] ?? '0') ?? 0;
    page = PaymentResultScreen(status: status, orderId: orderId);
  }
  break;
```

Buat screen `flutter/lib/screens/payment/payment_result_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../router.dart';
import '../../services/booking_service.dart';
import '../../utils/formatters.dart';
import '../../config/theme.dart';

class PaymentResultArgs {
  final String status;
  final int orderId;
  const PaymentResultArgs({required this.status, required this.orderId});
}
```

> **Penting:** `PaymentResultScreen` tidak boleh mempercayai parameter URL `status`. Setelah terbuka, panggil `GET /payments/{id}` untuk mendapatkan status yang terverifikasi dari backend. Lihat [K-1](#k-1--kritis-forgery-status-pembayaran-lewat-finish-callback).

---

## Status Implementasi Ringkasan

### Yang Sudah

| Komponen | File | Deskripsi |
|----------|------|-----------|
| Model Payment | `app/Models/Payment.php` | Eloquent model dengan relasi ke Order |
| Model PaymentMethod | `app/Models/PaymentMethod.php` | Model metode pembayaran |
| Model PaymentSetting | `app/Models/PaymentSetting.php` | Model pengaturan Midtrans |
| PaymentController | `app/Http/Controllers/Api/PaymentController.php` | Inti integrasi Snap + webhook |
| FinishController | `app/Http/Controllers/Payment/FinishController.php` | Callback browser → deep link |
| UnfinishController | `app/Http/Controllers/Payment/UnfinishController.php` | Callback unfinish |
| ErrorController | `app/Http/Controllers/Payment/ErrorController.php` | Callback error |
| Admin PaymentController | `app/Http/Controllers/Admin/PaymentController.php` | CRUD admin payments |
| Admin PaymentMethodController | `app/Http/Controllers/Admin/PaymentMethodController.php` | CRUD admin payment methods |
| PaymentSettings Livewire | `app/Livewire/PaymentSettings/Settings.php` | Form konfigurasi Midtrans |
| MidtransSnap helper | `app/Support/MidtransSnap.php` | Helper pembuatan Snap params |
| PaymentDeepLink helper | `app/Support/PaymentDeepLink.php` | Helper parsing deep link |
| Flutter Model Payment | `flutter/lib/models/payment.dart` | Model Dart |
| Flutter Service | `flutter/lib/services/booking_service.dart` | pay(), paymentMethods(), retryPayment() |
| Flutter Screen | `flutter/lib/screens/payment/payment_method_screen.dart` | Pilih metode, buka Snap |
| Flutter Screen | `flutter/lib/screens/payment/payment_result_screen.dart` | Hasil pembayaran (belum dipanggil) |

### Yang Belum

| # | Fitur yang Belum | Keterangan |
|---|------------------|------------|
| 1 | **Koneksi admin settings ke kode** | `payment_settings` ditulis tapi tidak pernah dibaca |
| 2 | **`enabled_payments` ke Snap** | Metode pilihan user tidak diteruskan ke Midtrans |
| 3 | **`item_details`** | Rincian item tidak dikirim |
| 4 | **Verifikasi nominal di webhook** | `gross_amount` tidak dibandingkan dengan `order->total` |
| 5 | **Idempotensi webhook** | Webhook yang sama diproses berulang |
| 6 | **Penanganan `fraud_status = challenge`** | Tidak ada logging atau aksi |
| 7 | **Auto-expire pembayaran** | Tidak ada scheduled job |
| 8 | **Refund** | Tidak ada API untuk refund |
| 9 | **Deep link terdaftar** | Tidak ada intent-filter Android / CFBundleURLTypes iOS |
| 10 | **Listener deep link Flutter** | Tidak ada package `app_links`/`uni_links` |
| 11 | **Navigasi ke PaymentResultScreen** | Tidak ada pemanggil |
| 12 | **Logging transaksi** | Hanya error yang di-log |

---

## Analisa Kekurangan & Celah Kritis

### Masalah pada Finish/Return URL Midtrans

`FinishController` mempercayai `transaction_status` dari query string dan langsung menandai pembayaran `paid`. Route ini publik tanpa autentikasi. Siapa pun bisa menandai pesanannya lunas tanpa membayar.

### Inkonsistensi State saat Webhook Gagal / Tertunda

`fraud_status = challenge` tidak ditangani. Kombinasi `capture` + `challenge` jatuh ke celah: tidak `paid`, tidak `failed`, tanpa log.

### Keamanan Validasi Order & Payment Amount

Webhook tidak memverifikasi `gross_amount` dengan `order->total`. Signature memang sudah mengikat nominal, tapi pengecekan eksplisit tetap perlu sebagai pertahanan berlapis.

### Penanganan Multi-Device / Sesi Pembayaran Ganda

Tidak ada mekanisme khusus. Karena `payment_id` adalah auto-increment dan `order_code` diketahui user, celah K-1 tetap bisa dieksploitasi.

---

## Rekomendasi Teknis

### Prioritas Tinggi

1. **K-1** — Hapus mutasi status dari `FinishController` / `UnfinishController` / `ErrorController`. Lihat [T-1](#t-1--k-1--hapus-mutasi-status-dari-callback-browser) di `remediation.md`.
2. **K-5** — Verifikasi `gross_amount` di webhook. Lihat [T-2](#t-2--k-5--verifikasi-nominal-di-webhook).
3. **K-6** — Jadikan webhook idempoten. Lihat [T-3](#t-3--k-6--jadikan-webhook-idempoten).
4. **K-7** — Tangani `fraud_status = challenge`. Lihat [T-4](#t-4--k-7--tangani-fraud_status--challenge).

### Prioritas Menengah

5. **K-2** — Satukan sumber kredensial. Lihat [T-5](#t-5--k-2--satukan-sumber-kredensial-midtrans).
6. **K-4** — Kirim `enabled_payments`. Lihat [T-6](#t-6--k-4--kirim-enabled_payments-ke-snap).
7. **K-8** — Perbaiki format `expiry.start_time`. Lihat [T-8](#t-8--k-8--perbaiki-expirystart_time).

### Prioritas Rendah

8. **K-9** — Job auto-expire. Lihat [T-10](#t-10--k-9--command-auto-expire).
9. **K-10** — `reconcile` menjadi `POST`. Lihat [T-11](#t-11--k-10--reconcile-get--post).
10. **K-3** — Deep link. Lihat [T-12](#t-12--k-3--aktifkan-deep-link).
11. **K-11** — Perbaiki test. Lihat [T-13](#t-13--k-11--perbaiki-test-menyesatkan).
