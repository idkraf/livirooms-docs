# Trial Fix: Payment Flow — Retry/Continue & Availability Guards

Trial fix untuk memastikan alur pembayaran Midtrans tidak ada gap antara Flutter dan Laravel, khususnya saat user melanjutkan atau retry pembayaran.

## Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/POST /api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

---

## 1. Status Enum Reference

### 1.a. Booking (`bookings.status`)

| Status | Keterangan |
|--------|-----------|
| `waiting_confirmation` | Booking dibuat, menunggu host mengonfirmasi |
| `confirmed` | Host telah mengonfirmasi, user dapat melakukan pembayaran |
| `paid` | Pembayaran berhasil, menunggu tanggal check-in |
| `waiting_checkin` | Tamu telah tiba, menunggu host mengonfirmasi check-in |
| `staying` | Tamu sedang menginap |
| `completed` | Booking selesai |
| `cancelled` | Dibatalkan (user/admin/host) |
| `expired` | Kedaluwarsa (payment timeout atau check-in terlewat) |

### 1.b. Availability (`availabilities` table)

Tidak ada enum status. Tabel ini adalah calendar flag:

| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| `is_available` | boolean | `true` = tanggal bisa di-booking |
| `is_buffer` | boolean | `true` = tanggal buffer (tidak bisa di-booking) |

**Pengecekan ketersediaan properti untuk retry pembayaran** menggunakan `bookings` table (bukan `availabilities`), karena availability adalah flag harian, bukan status booking.

### 1.c. Payment (`payments.status`)

| Status | Keterangan |
|--------|-----------|
| `pending` | Menunggu pembayaran dari user |
| `paid` | Pembayaran berhasil (dikonfirmasi webhook/reconcile) |
| `failed` | Pembayaran gagal (Midtrans deny/cancel/error) |
| `expired` | Pembayaran kedaluwarsa (timeout 60 menit) |
| `refunded` | Dana dikembalikan |

---

## 2. Alur Booking dan Pembayaran

### Alur Baru (setelah perbaikan)

1. User membuat booking → `bookings.status = waiting_confirmation`, `order.status = pending`
2. User diarahkan ke `booking_detail_screen` — **belum bisa bayar**, menampilkan "Menunggu konfirmasi dari pemilik properti..."
3. Host melihat order di mitra screen → bisa **Terima** atau **Tolak**
4. Jika host **Terima** → `bookings.host_confirmed = true`, `bookings.status = confirmed`, `order.status = confirmed`
5. `booking_detail_screen` menampilkan tombol **Lanjutkan Bayar**
6. User menekan tombol → pilih metode pembayaran → panggil `POST /orders/{id}/pay`
7. Jika payment berhasil → `payments.status = paid`, `bookings.status = paid`, `order.status = processing`
8. Jika payment gagal/expired dalam 1 jam → booking dibatalkan, tanggal properti kembali aktif

### Skenario A: User menekan "Lanjutkan Pembayaran" (`_startInitialPayment`, booking_detail_screen.dart)

1. Flutter menampilkan dialog pilih metode pembayaran
2. Flutter memanggil `POST /api/v1/orders/{orderId}/pay` → `PaymentController::pay()`
3. Backend membuat `Payment` + Midtrans Snap transaction
4. Flutter buka browser eksternal dengan `redirect_url`

### Skenario B: User menekan "Lanjutkan Pembayaran" untuk payment yang sudah ada (`_continuePayment`, booking_detail_screen.dart)

1. Flutter memanggil `POST /api/v1/orders/{orderId}/pay/retry` → `PaymentController::payUrl()`
2. **Backend cek:**
   - Apakah booking tanggalnya masih bentrok dengan booking lain yang aktif?
   - Jika bentrok → update payment → `cancelled` (batal), bukan `failed` (gagal)
   - Jika tidak bentrok → buat `redirect_url` Midtrans Snap baru
3. Flutter buka browser eksternal dengan `redirect_url`

### Skenario C: User menekan "Coba Bayar Lagi" / "Buat Pesanan Baru" (`_retryPayment`, booking_detail_screen.dart)

Sama persis dengan Skenario B.

---

## 3. Guard: Pengecekan Availability Sebelum Retry

### Backend (`PaymentController::payUrl`)

Sebelum membuat Midtrans transaction, cek apakah ada booking lain yang aktif untuk properti dan tanggal yang sama:

```php
$booking = $payment->order->booking;
if ($booking) {
    $conflict = Booking::where('property_id', $booking->property_id)
        ->where('id', '!=', $booking->id)
        ->whereIn('status', ['waiting_payment', 'waiting_confirmation', 'confirmed', 'paid', 'waiting_checkin', 'staying'])
        ->whereDate('check_in', '<', $booking->check_out)
        ->whereDate('check_out', '>', $booking->check_in)
        ->exists();

    if ($conflict) {
        $payment->update(['status' => 'cancelled']);
        ...
    }
}
```

### Frontend (`booking_detail_screen.dart`)

```dart
Future<void> _continuePayment() async {
  if (booking.order == null) return;
  final isAvailable = await _service.checkAvailability(...);
  if (!isAvailable) {
    ScaffoldMessenger.showSnackBar('Maaf, tanggal ini sudah dipesan...');
    await _refreshBooking();
    return;
  }
  ...
}
```

---

## 4. Blokir Availability 1 Jam

### Saat Booking Dibuat (`BookingController::store`)

Setiap kali user membuat booking, sistem melakukan dua pengecekan:

1. **Cek `availabilities` table** — tanggal yang dipilih harus `is_available = true`
 2. **Cek overlapping booking aktif** — tidak boleh ada booking lain dengan status `waiting_payment`, `waiting_confirmation`, `confirmed`, `paid`, `waiting_checkin`, atau `staying` yang menempel di tanggal yang sama

```php
$overlap = Booking::where('property_id', $property->id)
    ->whereIn('status', ['waiting_payment', 'waiting_confirmation', 'confirmed', 'paid', 'waiting_checkin', 'staying'])
    ->whereDate('check_in', '<', $checkOut->toDateString())
    ->whereDate('check_out', '>', $checkIn->toDateString())
    ->lockForUpdate()
    ->exists();
abort_if($overlap, 422, 'Tanggal yang dipilih sudah dipesan.');
```

### Saat Booking Dibatalkan/Expired (`CancelExpiredPayments` + `BookingController::cancel`)

Saat booking dibatalkan (user cancel, host reject, payment expired, atau check-in terlewat):

1. Update booking → `cancelled` atau `expired`
2. Cek apakah ada booking LAIN yang aktif untuk tanggal yang sama
3. Jika tidak ada → restore `is_available = true` untuk tanggal tersebut

```php
private function restoreAvailability(Booking $booking): void
{
    $hasOtherActive = Booking::where('property_id', $booking->property_id)
        ->where('id', '!=', $booking->id)
        ->whereIn('status', ['waiting_payment', 'waiting_confirmation', 'confirmed', 'paid', 'waiting_checkin', 'staying'])
        ->whereDate('check_in', '<', $booking->check_out)
        ->whereDate('check_out', '>', $booking->check_in)
        ->exists();

    if (! $hasOtherActive) {
        Availability::where('property_id', $booking->property_id)
            ->whereBetween('date', [$booking->check_in, $booking->check_out->copy()->subDay()->toDateString()])
            ->update(['is_available' => true]);
    }
}
```

### Auto-Cancel Check-in Terlewat

Command `payments:cancel-expired` sekarang juga membatalkan booking yang memiliki `check_in < hari ini` dengan status `waiting_payment`, `waiting_confirmation`, `confirmed`, `paid`, atau `waiting_checkin`:

```php
$past = Booking::whereIn('status', ['waiting_payment', 'waiting_confirmation', 'confirmed', 'paid', 'waiting_checkin'])
    ->whereDate('check_in', '<', now()->toDateString())
    ->get();

foreach ($past as $booking) {
    $booking->update(['status' => 'cancelled']);
    $booking->order?->update(['status' => 'cancelled']);
    $this->restoreAvailability($booking);
}
```

---

## 5. Host Confirmation Flow

### Backend Endpoints

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| `POST` | `/api/v1/bookings/{booking}/confirm` | Host mengkonfirmasi booking → `host_confirmed = true`, `bookings.status = confirmed`, `orders.status = confirmed` |
| `POST` | `/api/v1/bookings/{booking}/reject` | Host menolak booking → booking/order → `cancelled`, restore availability |
| `POST` | `/api/v1/bookings/{booking}/checkin` | Host menandai tamu tiba → `bookings.status = waiting_checkin` |
| `POST` | `/api/v1/bookings/{booking}/confirm-checkin` | Host mengonfirmasi check-in → `bookings.status = staying` |

**Guard:** Hanya host pemilik properti yang bisa memanggil endpoint ini.

```php
public function confirm(Booking $booking, Request $request)
{
    $this->authorizeHost($booking, $request);
    $booking->update(['host_confirmed' => true, 'status' => 'confirmed']);
    $booking->order?->update(['status' => 'confirmed']);
    return ApiResponse::success($booking, 'Pesanan dikonfirmasi.');
}

public function reject(Booking $booking, Request $request)
{
    $this->authorizeHost($booking, $request);
    $booking->update(['status' => 'cancelled']);
    $booking->order?->update(['status' => 'cancelled']);
    $this->restoreAvailability($booking);
    return ApiResponse::success($booking, 'Pesanan berhasil ditolak.');
}
```

### Flutter Mitra Screens

- `order_management_screen.dart` — tombol Terima/Tolak sekarang memanggil API sungguhan
- `order_detail_screen.dart` — tombol Konfirmasi Pesanan, Tamu Tiba, dan Konfirmasi Check-in sekarang memanggil API sungguhan

### Booking Detail Screen

Setelah `host_confirmed = true`, `booking_detail_screen.dart` menampilkan tombol **Lanjutkan Bayar**:
- Jika belum ada payment → user pilih metode, lalu panggil `POST /orders/{id}/pay`
- Jika payment sudah ada (pending) → panggil `POST /orders/{id}/pay/retry`
- Jika payment failed/expired → panggil `POST /orders/{id}/pay/retry`
- **Semua tombol pembayaran disembunyikan jika `booking.check_out` sudah terlewat** (`isExpired == true`)

### Mitra Order Management

- `order_management_screen.dart` memuat data dari `GET /host/orders` (berdasarkan `property.host_id`)
- Menampilkan rentang menginap, waktu dibuat, dan badge "Waktu konfirmasi telah terlewat" jika order expired
- Tombol Terima/Tolak disembunyikan jika order sudah expired
- Tombol **Tamu Tiba** muncul untuk booking `paid` → panggil `POST /bookings/{booking}/checkin`
- Tombol **Konfirmasi Check-in** muncul untuk booking `waiting_checkin` → panggil `POST /bookings/{booking}/confirm-checkin`

---

## 6. Penjelasan: `cancelled` vs `failed`

| Status | Artinya | Dipicu oleh |
|--------|---------|-------------|
| `cancelled` | Booking dibatalkan sebelum bayar | User batalkan manual, sistem detect conflict, host reject, atau auto-cancel check-in terlewat |
| `failed` | Pembayaran ditolak Midtrans | Midtrans deny/cancel/error |
| `expired` | Payment timeout | Scheduler `payments:cancel-expired` atau Midtrans expire |

Jika payment di-`cancelled` dari availability conflict:
- Booking → `cancelled`
- Order → `cancelled`
- Payment → `cancelled`
- User harus buat booking baru (karena tanggal sudah terambil orang lain)

---

## 7. Files to Modify

### Laravel
- `database/migrations/2026_08_11_000001_add_host_confirmed_to_bookings_table.php` — tambah kolom `host_confirmed`
- `app/Models/Booking.php` — tambah `host_confirmed` ke fillable dan casts
- `app/Http/Controllers/Api/BookingController.php` — overlap check di `store()`, tambah `confirm()`/`reject()`, tambah `restoreAvailability()`
- `app/Console/Commands/CancelExpiredPayments.php` — tambah `restoreAvailability()` dan `cancelPastCheckInBookings()`
- `routes/api_mobile.php` — tambah route `confirm` dan `reject`

### Flutter
- `lib/models/booking.dart` — tambah `hostConfirmed`
- `lib/screens/payment/payment_method_screen.dart` — navigasi ke booking detail setelah create booking
- `lib/screens/booking/booking_detail_screen.dart` — tambah `_startInitialPayment()`, `_showPaymentMethodDialog()`, update button visibility
- `lib/services/host_service.dart` — tambah `confirmOrder()` dan `rejectOrder()`
- `lib/screens/mitra/order_management_screen.dart` — panggil API sungguhan untuk Terima/Tolak
- `lib/screens/mitra/order_detail_screen.dart` — tombol Konfirmasi Pesanan memanggil API sungguhan

---

## 4. Update Status Saat Pembayaran Berhasil

Ketika Midtrans mengirim webhook `settlement`:

| Entity | Sebelum | Sesudah |
|--------|---------|---------|
| `payments.status` | `pending` | `paid` |
| `payments.paid_at` | `null` | `now()` |
| `payments.gateway_reference` | `null` | Midtrans transaction_id |
| `orders.status` | `pending` | `processing` |
| `bookings.status` | `waiting_confirmation` | `paid` |

Logic ini sudah ada di `PaymentController::webhook()` dan `PaymentController::reconcile()`.

---

## 5. Penjelasan: `cancelled` vs `failed`

| Status | Artinya | Dipicu oleh |
|--------|---------|-------------|
| `cancelled` | Booking dibatalkan sebelum bayar | User batalkan manual, sistem detect conflict, atau admin cancel |
| `failed` | Pembayaran ditolak Midtrans | Midtrans deny/cancel/error |
| `expired` | Payment timeout | Scheduler `payments:cancel-expired` atau Midtrans expire |

Jika payment di-`cancelled` dari availability conflict:
- Booking → `cancelled`
- Order → `cancelled`
- Payment → `cancelled`
- User harus buat booking baru (karena tanggal sudah terambil orang lain)

---

## 6. Files to Modify

### Laravel
- `database/migrations/2026_08_11_000001_add_host_confirmed_to_bookings_table.php` — migrasi baru
- `app/Models/Booking.php` — tambah `host_confirmed` ke fillable dan casts
- `app/Http/Controllers/Api/BookingController.php` — overlap check di `store()`, tambah `confirm()`/`reject()`/`restoreAvailability()`
- `app/Console/Commands/CancelExpiredPayments.php` — tambah `restoreAvailability()` dan `cancelPastCheckInBookings()`
- `routes/api_mobile.php` — tambah route `confirm` dan `reject`

### Flutter
- `lib/models/booking.dart` — tambah `hostConfirmed`
- `lib/screens/payment/payment_method_screen.dart` — navigasi ke booking detail setelah create booking
- `lib/screens/booking/booking_detail_screen.dart` — tombol berdasarkan `host_confirmed` + payment status
- `lib/services/host_service.dart` — tambah `confirmOrder()` dan `rejectOrder()`
- `lib/screens/mitra/order_management_screen.dart` — panggil API sungguhan untuk Terima/Tolak
- `lib/screens/mitra/order_detail_screen.dart` — tombol Konfirmasi Pesanan memanggil API sungguhan

---

## 7. Execution Order

1. ✅ Dokumentasi (`trial_fix_payment.md`) — file ini
2. ✅ Migration `add_host_confirmed_to_bookings_table.php`
3. ✅ Update `Booking.php` model — tambah `host_confirmed` ke fillable dan casts
4. ✅ Update `BookingController::store()` — tambah overlap check untuk blokir booking ganda
5. ✅ Update `BookingController` — tambah `confirm()`, `reject()`, `restoreAvailability()`
6. ✅ Update `CancelExpiredPayments` — tambah `restoreAvailability()` dan `cancelPastCheckInBookings()`
7. ✅ Update `routes/api_mobile.php` — tambah route confirm/reject
8. ✅ Update `payment_method_screen.dart` — navigasi ke booking detail setelah create booking
9. ✅ Update `booking_detail_screen.dart` — tombol berdasarkan `host_confirmed` + payment status
10. ✅ Update `host_service.dart` — tambah `confirmOrder()` dan `rejectOrder()`
11. ✅ Update `order_management_screen.dart` — panggil API sungguhan untuk Terima/Tolak
12. ✅ Update `order_detail_screen.dart` — tombol Konfirmasi Pesanan memanggil API sungguhan
13. ⬜ Jalankan `php artisan migrate`
14. ⬜ Clear cache: `php artisan config:clear && php artisan route:clear && php artisan view:clear`
15. ⬜ Test manual flow complete
