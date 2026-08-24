# Payment System Documentation

> **Diverifikasi dari kode pada 2026-08-21.** Setiap baris punya bukti path:baris.

## 1. Ringkasan

Sistem pembayaran menggunakan **Midtrans Snap** sebagai payment gateway. Terdapat 6 endpoint di `PaymentController`:

| # | Endpoint | Method | Fungsi |
|---|---|---|
| 1 | `GET payments/methods` | Client | List metode pembayaran yang enabled |
| 2 | `POST orders/{order}/pay` | Client | Buat transaksi Midtrans, return `snap_token` + `redirect_url` |
| 3 | `POST orders/{order}/pay/retry` | Client | Retry/continue pembayaran yang sudah ada |
| 4 | `GET payments/{payment}` | Client | Detail pembayaran |
| 5 | `POST payments/{payment}/reconcile` | Client | Sync status pembayaran dengan Midtrans |
| 6 | `POST payments/webhook` | Midtrans S2S | Notifikasi status pembayaran dari Midtrans |

Sistem booking memiliki 2 alur yang terpisah:
- **Property booking** (`booking_type: unit`) — lewat `POST booking-property`
- **Hotel booking** (`booking_type: room`) — lewat `POST booking-hotels`

Keduanya menghasilkan `Booking` + `Order`, lalu pembayaran dilakukan lewat `POST orders/{order}/pay`.

## 2. Alur Pembayaran Hotel (Booking Mode `room`)

```
┌─────────────┐     POST booking-hotels      ┌─────────────┐
│  Flutter    │ ─────────────────────────────▶ │   Laravel   │
│             │ ◀───────────────────────────── │             │
│             │   booking + order (tanpa      │             │
│             │   payment)                    │             │
└──────┬──────┘                               └──────┬──────┘
       │                                             │
       │  POST orders/{orderId}/pay                  │
       │  body: { method: 'credit_card' }            │
       │ ───────────────────────────────────────────▶│
       │ ◀───────────────────────────────────────────│
       │   payment + snap_token + redirect_url       │
       │                                             │
       │  Buka PaymentWebviewScreen(redirect_url)    │
       │                                             │
       │  User bayar di webview                      │
       │                                             │
       │  Midtrans redirect                          │
       │  livirooms://payment-result?paymentId=X&    │
       │    orderId=Y                                │
       │                                             │
       │  DeepLinkHandler                            │
       │  → PaymentResultScreen                      │
       │  → GET payments/{paymentId}                 │
       │  → konfirmasi status                        │
       └─────────────────────────────────────────────┘
```

## 3. Alur Pembayaran Property (Booking Mode `unit`)

```
┌─────────────┐     POST booking-property     ┌─────────────┐
│  Flutter    │ ─────────────────────────────▶ │   Laravel   │
│             │ ◀───────────────────────────── │             │
│             │   booking + order (tanpa      │             │
│             │   payment, status=waiting_    │             │
│             │   confirmation)               │             │
└──────┬──────┘                               └──────┬──────┘
       │                                             │
       │  User tunggu konfirmasi host               │
       │  Host klik "Konfirmasi"                     │
       │  POST bookings/{id}/confirm                 │
       │  → booking.status = confirmed               │
       │  → order.status = confirmed                 │
       │                                             │
       │  POST orders/{orderId}/pay                  │
       │  body: { method: 'credit_card' }            │
       │ ───────────────────────────────────────────▶│
       │ ◀───────────────────────────────────────────│
       │   payment + snap_token + redirect_url       │
       │                                             │
       │  Buka PaymentWebviewScreen(redirect_url)    │
       │                                             │
       │  User bayar di webview                      │
       │                                             │
       │  Midtrans redirect                          │
       │  livirooms://payment-result?paymentId=X&    │
       │    orderId=Y                                │
       │                                             │
       │  DeepLinkHandler                            │
       │  → PaymentResultScreen                      │
       │  → GET payments/{paymentId}                 │
       │  → konfirmasi status                        │
       └─────────────────────────────────────────────┘
```

## 4. Endpoint Detail

### 4.0 Booking Action Endpoints

Semua endpoint aksi dibawah memerlukan auth host (kecuali `cancel` yang dibutuhkan user).

| # | Endpoint | Method | Keterangan |
|---|---|---|
| 1 | `POST bookings/{id}/cancel` | User | Batalkan booking (property & hotel) |
| 2 | `POST bookings/{id}/confirm` | Host | Konfirmasi booking property |
| 3 | `POST bookings/{id}/reject` | Host | Tolak booking property |
| 4 | `POST bookings/{id}/checkin` | Host | Catat check-in tamu (property & hotel) |
| 5 | `POST bookings/{id}/confirm-checkin` | Host | Konfirmasi check-in tamu (property & hotel) |
| 6 | `POST bookings/{id}/review` | User | Beri ulasan setelah booking selesai |

#### 4.0.1 `POST bookings/{id}/cancel`

Membatalkan booking. Hanya bisa dibatalkan jika status masih `waiting_payment`, `waiting_confirmation`, `confirmed`, `paid`, `waiting_checkin`, `staying`, atau `checked_in`. Tidak bisa dibatalkan jika sudah `completed`, `cancelled`, `staying`, `checked_in`, atau `rejected`.

**Response:**
```json
{
  "status": true,
  "code": 200,
  "message": "Booking berhasil dibatalkan.",
  "data": {
    "id": 1,
    "status": "cancelled",
    "property": { ... }
  }
}
```

#### 4.0.2 `POST bookings/{id}/confirm`

Host mengkonfirmasi booking property. Mengubah `host_confirmed` menjadi `true` dan `status` menjadi `confirmed`.

**Response:**
```json
{
  "status": true,
  "code": 200,
  "message": "Pesanan berhasil dikonfirmasi.",
  "data": {
    "id": 1,
    "status": "confirmed",
    "host_confirmed": true
  }
}
```

#### 4.0.3 `POST bookings/{id}/reject`

Host menolak booking property. Mengubah `status` menjadi `rejected` dan `host_confirmed` menjadi `false`.

**Response:**
```json
{
  "status": true,
  "code": 200,
  "message": "Pesanan berhasil ditolak.",
  "data": {
    "id": 1,
    "status": "rejected",
    "host_confirmed": false
  }
}
```

#### 4.0.4 `POST bookings/{id}/checkin`

Host mencatat check-in tamu. Hanya bisa jika status booking adalah `paid`. Mengubah `status` menjadi `checked_in` dan mengisi `checked_in_at`.

**Response:**
```json
{
  "status": true,
  "code": 200,
  "message": "Check-in berhasil dicatat.",
  "data": {
    "id": 1,
    "status": "checked_in",
    "checked_in_at": "2026-08-15T14:00:00.000000Z"
  }
}
```

#### 4.0.5 `POST bookings/{id}/confirm-checkin`

Host mengkonfirmasi check-in tamu. Hanya bisa jika status booking adalah `checked_in`. Mengubah `host_confirmed_checkin` menjadi `true`.

**Response:**
```json
{
  "status": true,
  "code": 200,
  "message": "Check-in berhasil dikonfirmasi.",
  "data": {
    "id": 1,
    "status": "checked_in",
    "host_confirmed_checkin": true
  }
}
```

#### 4.0.6 `POST bookings/{id}/review`

User memberikan ulasan setelah booking selesai (`status = completed`). Hanya bisa sekali per booking.

**Response:**
```json
{
  "status": true,
  "code": 201,
  "message": "Terima kasih, ulasan Anda berhasil dikirim.",
  "data": {
    "id": 1,
    "booking_id": 1,
    "property_id": 1,
    "user_id": 2,
    "rating": 5,
    "comment": "Properti sangat bagus dan bersih!",
    "host_reply": "Terima kasih atas review positifnya!",
    "photos": ["https://example.com/reviews/1/1.jpg"],
    "created_at": "2026-07-20T14:30:00+07:00",
    "user": {
      "id": 2,
      "name": "Siti Nurhaliza"
    }
  }
}
```

### 4.1 `GET payments/methods`

List semua metode pembayaran yang enabled.

**Response:**
```json
[
  {
    "code": "credit_card",
    "name": "Kartu Kredit",
    "group": "card",
    "icon": "https://...",
    "min_amount": 10000,
    "max_amount": null,
    "metadata": {}
  }
]
```

### 4.2 `POST orders/{order}/pay`

Buat transaksi Midtrans Snap. Hanya bisa dipanggil sekali per order (kecuali status `failed`/`expired`).

**Request:**
```json
{
  "method": "credit_card"
}
```

**Response:**
```json
{
  "payment": {
    "id": 1,
    "order_id": 1,
    "method": "credit_card",
    "amount": 500000,
    "status": "pending",
    "snap_token": "abc123...",
    "redirect_url": "https://app.sandbox.midtrans.com/...",
    "paid_at": null,
    "gateway_reference": null,
    "created_at": "2026-08-20T..."
  },
  "snap_token": "abc123...",
  "redirect_url": "https://app.sandbox.midtrans.com/..."
}
```

**Error:**
- `403` — Order bukan milik user
- `422` — Order sudah diproses sebelumnya, atau metode tidak tersedia, atau amount di bawah minimum

### 4.3 `POST orders/{order}/pay/retry`

Retry pembayaran yang sudah ada. Tidak butuh `method` karena method sudah tersimpan di payment row.

**Response:** Sama seperti `POST orders/{order}/pay`.

### 4.4 `GET payments/{payment}`

Detail pembayaran. Include `order.booking`.

**Response:**
```json
{
  "id": 1,
  "order_id": 1,
  "method": "credit_card",
  "amount": 500000,
  "status": "pending",
  "snap_token": "abc123...",
  "redirect_url": "https://app.sandbox.midtrans.com/...",
  "paid_at": null,
  "gateway_reference": null,
  "created_at": "2026-08-20T..."
}
```

### 4.5 `POST payments/{payment}/reconcile`

Sync status pembayaran dengan Midtrans. Panggil ini jika `GET payments/{payment}` masih `pending` setelah webview ditutup.

**Response:**
```json
{
  "payment_id": 1,
  "status": "paid"
}
```

### 4.6 `POST payments/webhook` — Midtrans S2S Only

**INI ADALAH ENDPOINT UNTUK MIDTRANS SAJA. KLIENT FLUTTER TIDAK BOLEH MEMANGGIL ENDPOINT INI.**

Midtrans mengirim notifikasi S2S setelah transaksi selesai. Endpoint ini:
1. Verifikasi signature SHA-512
2. Cek `gross_amount` vs `payment->amount`
3. Update status payment/order/booking via `applyTransactionStatus()`

**Payload dari Midtrans:**
```json
{
  "order_id": "HTL-20260820-A1B2C3D4-1",
  "status_code": "200",
  "gross_amount": "500000.00",
  "signature_key": "sha512_hash...",
  "transaction_status": "settlement",
  "transaction_id": "...",
  "fraud_status": "accept"
}
```

**Catatan keamanan:**
- Signature dihitung: `hash('sha512', order_id + status_code + gross_amount + serverKey)`
- Klien Flutter tidak punya `serverKey`, sehingga tidak dapat membuat signature yang valid
- Mengabaikan verifikasi signature memungkinkan status pembayaran dimanipulasi dari perangkat klien

## 5. Flutter Implementation

### 5.1 Service Methods

`lib/services/booking_service.dart`:

| Method | Endpoint | Return |
|---|---|---|
| `paymentMethods()` | `GET payments/methods` | `List<PaymentMethod>` |
| `pay(orderId, method)` | `POST orders/{orderId}/pay` | `Payment` |
| `retryPayment(orderId)` | `POST orders/{orderId}/pay/retry` | `Payment` |
| `paymentDetail(id)` | `GET payments/{id}` | `Payment` |
| `reconcilePayment(id)` | `POST payments/{id}/reconcile` | `Payment` |
| `paymentWebhook(payload)` | `POST payments/webhook` | `void` |

`lib/services/host_booking_service.dart` (host-side):

| Method | Endpoint | Return |
|---|---|---|
| `confirmBooking(bookingId)` | `POST bookings/{id}/confirm` | `Map<String, dynamic>` |
| `rejectBooking(bookingId)` | `POST bookings/{id}/reject` | `Map<String, dynamic>` |
| `checkinBooking(bookingId)` | `POST bookings/{id}/checkin` | `Map<String, dynamic>` |
| `confirmCheckin(bookingId)` | `POST bookings/{id}/confirm-checkin` | `Map<String, dynamic>` |

### 5.2 Payment Initiation by Screen

| Screen | Kapan | Method yang Dipanggil |
|---|---|---|
| `hotel_booking_screen.dart` | Setelah booking hotel dibuat | `BookingService.pay(orderId, 'credit_card')` → buka webview |
| `rincian_unit_screen.dart` | Setelah booking unit dibuat | `BookingService.pay(orderId, 'credit_card')` → buka webview |
| `booking_detail_screen.dart` | User klik "Bayar" | `BookingService.retryPayment(orderId)` → buka webview |
| `booking_detail_hotel_screen.dart` | User klik "Bayar" | `BookingService.pay(orderId, firstMethod)` → buka webview |

### 5.3 Host Action Endpoints

Host melakukan aksi pada booking melalui `HostBookingService`:

| Screen | Aksi | Method yang Dipanggil |
|---|---|---|
| `booking_detail_screen.dart` (host) | Konfirmasi booking | `HostBookingService.confirmBooking(id)` |
| `booking_detail_screen.dart` (host) | Tolak booking | `HostBookingService.rejectBooking(id)` |
| `booking_detail_hotel_screen.dart` (host) | Check-in tamu | `HostBookingService.checkinBooking(id)` |
| `booking_detail_hotel_screen.dart` (host) | Konfirmasi check-in | `HostBookingService.confirmCheckin(id)` |

### 5.4 Webview Flow

1. Dapatkan `redirect_url` dari response `pay()` atau `retryPayment()`
2. Buka `PaymentWebviewScreen` dengan `PaymentWebviewArgs(url: redirectUrl, ...)`
3. User selesaikan pembayaran di webview
4. Midtrans redirect ke `livirooms://payment-result?paymentId=X&orderId=Y`
5. `DeepLinkHandler` menangkap deep link
6. `PaymentResultScreen` dibuka
7. Panggil `GET payments/{paymentId}` untuk konfirmasi status
8. Jika masih `pending`, panggil `POST payments/{paymentId}/reconcile`

## 6. Payment Status Machine

### 6.1 Payment Status

```
pending → paid (via webhook/reconcile)
pending → failed (via webhook/reconcile)
pending → expired (via CancelExpiredPayments job)
paid → refunded (admin action)
```

**Sumber kebenaran status:** Webhook S2S Midtrans (`POST payments/webhook`). Status dari webview callback atau parameter URL tidak dipercaya.

### 6.2 Booking Status

Booking memiliki status yang lebih detail untuk mengelola alur:

| Status | Keterangan |
|---|---|
| `waiting_payment` | Booking dibuat, menunggu pembayaran (hotel) |
| `waiting_confirmation` | Booking dibuat, menunggu konfirmasi host (property) |
| `confirmed` | Host mengkonfirmasi booking property |
| `paid` | Pembayaran lunas |
| `waiting_checkin` | Tamu tiba, menunggu konfirmasi check-in |
| `checked_in` | Tamu sudah check-in |
| `staying` | Check-in dikonfirmasi host |
| `completed` | Booking selesai |
| `cancelled` | Booking dibatalkan (user/host) |
| `rejected` | Booking ditolak host |
| `expired` | Booking kedaluwarsa (batas waktu pembayaran) |

## 7. Deep Link

Setelah pembayaran selesai, Midtrans redirect ke:
```
livirooms://payment-result?paymentId={id}&orderId={order_id}
```

**Catatan:** Backend sengaja tidak menyertakan status pembayaran di deep link URL. Flutter app wajib memanggil `GET payments/{paymentId}` untuk mendapatkan status sebenarnya.

## 8. Dummy Mode

Mode dummy mensimulasikan endpoint pembayaran:

| Route | Fixture File |
|---|---|
| `GET payments/methods` | `GET_payments_methods.json` |
| `POST orders/{id}/pay` | `POST_orders_id_pay.json` |
| `POST orders/{id}/pay/retry` | `POST_orders_id_pay_retry.json` |
| `GET payments/{id}` | `GET_payments_id.json` |
| `POST payments/{id}/reconcile` | `POST_payments_id_reconcile.json` |
| `POST payments/webhook` | `POST_payments_webhook.json` |

## 9. Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/POST /api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

## 10. Ringkasan URL

| Field di Dashboard Midtrans | Isi |
|---|---|
| **Payment Notification URL** | `https://livirooms.com/api/v1/payments/webhook` |
| **Finish Redirect URL** | `https://livirooms.com/payment/finish` |
| **Unfinish Redirect URL** | `https://livirooms.com/payment/unfinish` |
| **Error Redirect URL** | `https://livirooms.com/payment/error` |

## 11. Notification URL vs Finish Redirect URL

### Notification URL — jalur yang dipercaya

```
Server Midtrans  ──HTTP POST──►  Server Laravel Anda
```

- Dipanggil **server-ke-server**. Browser pengguna tidak terlibat.
- Membawa `signature_key` = `sha512(order_id + status_code + gross_amount + server_key)`.
- Karena `server_key` hanya diketahui Midtrans dan server Anda, tanda tangan ini **membuktikan** pesannya asli.
- **Inilah satu-satunya jalur yang boleh mengubah status pembayaran.**
- Midtrans mengulang kirim sampai dapat HTTP `200`. Handler-nya wajib idempoten — dan di kode ini sudah: `applyTransactionStatus()` keluar lebih awal bila `status === 'paid'` (`Api/PaymentController.php:319`).

### Finish Redirect URL — jalur yang TIDAK dipercaya

```
Browser pengguna  ──redirect──►  Server Laravel Anda
```

- Yang mengunjungi adalah **browser pengguna** setelah ia menekan tombol selesai di halaman Snap.
- Semua query string-nya dikendalikan pengguna. Siapa pun bisa mengetik `?order_id=ORD-123-45&transaction_status=settlement` di address bar.
- **Tidak boleh menyentuh status pembayaran.** Lihat komentar di `app/Http/Controllers/Payment/FinishController.php:10-20`.
- Tugasnya hanya satu: memantulkan pengguna kembali ke aplikasi Flutter.

> Analogi: Notification URL itu petugas bank yang menelepon lewat nomor resmi. Finish Redirect URL itu orang yang mengetuk pintu Anda dan mengaku dari bank. Yang pertama boleh mengubah saldo, yang kedua hanya boleh dipersilakan masuk.

Kalau Anda hanya mengisi Finish Redirect URL dan mengabaikan Notification URL, **tidak ada satu pun pembayaran yang akan tercatat lunas.** Booking pengguna akan kedaluwarsa oleh `payments:cancel-expired` meskipun uangnya sudah masuk.

## 12. Notification URL — Detail

### Route-nya

`laravel/routes/api_mobile.php:52-53`

```php
Route::post('payments/webhook', [PaymentController::class, 'webhook']);
```

Route ini berada di dalam `Route::prefix('v1')`, dan file `routes/api.php` memuatnya di bawah prefix `/api` bawaan Laravel. Jadi path lengkapnya:

```
/api  +  /v1  +  /payments/webhook   →   /api/v1/payments/webhook
```

Perhatikan letaknya: **di luar** grup `auth:sanctum`. Memang harus begitu — Midtrans tidak punya token Sanctum. Pengaman jalur ini adalah tanda tangan SHA512, bukan sesi login.

### Yang diisi di dashboard

| Lingkungan | Isi |
|---|---|
| Sandbox, domain publik | `https://staging.livirooms.com/api/v1/payments/webhook` |
| Produksi | `https://livirooms.com/api/v1/payments/webhook` |
| Lokal (via tunnel) | `https://a1b2c3d4.ngrok-free.app/api/v1/payments/webhook` |

### Syarat yang wajib dipenuhi

1. **HTTPS.** Midtrans menolak `http://` di produksi.
2. **Dapat diakses publik.** `localhost` dan IP privat tidak akan pernah dihubungi Midtrans.
3. **Tanpa auth.** Jangan letakkan di balik Basic Auth, Cloudflare Access, atau halaman "maintenance".
4. **Balas `200` secepatnya.** Kalau server balas `500` atau timeout, Midtrans mengulang beberapa kali lalu menyerah — dan pembayaran akan menggantung.
5. **Bebas dari CSRF.** Sudah aman: route API tidak memakai middleware `web`.

## 13. Finish Redirect URL — Detail

### Route-nya

`laravel/routes/web.php:35-38`

```php
Route::get('/payment/finish',   [FinishController::class, 'finish'])->name('payment.finish');
Route::get('/payment/unfinish', [UnfinishController::class, 'unfinish'])->name('payment.unfinish');
Route::get('/payment/error',    [ErrorController::class, 'error'])->name('payment.error');
```

Ketiganya di `routes/web.php` **tanpa** prefix `admin` dan **tanpa** middleware `auth` — memang harus begitu, karena yang membukanya browser eksternal yang mungkin belum login.

Jadi path-nya persis: `/payment/finish` — tanpa `/api`, tanpa `/v1`.

### Yang diisi di dashboard

| Lingkungan | Finish | Unfinish | Error |
|---|---|---|---|
| Produksi | `https://livirooms.com/payment/finish` | `.../payment/unfinish` | `.../payment/error` |
| Sandbox | `https://staging.livirooms.com/payment/finish` | `.../payment/unfinish` | `.../payment/error` |
| Lokal | `https://a1b2c3d4.ngrok-free.app/payment/finish` | `.../payment/unfinish` | `.../payment/error` |

### Kapan masing-masing dipanggil

| URL | Dipanggil saat |
|---|---|
| **Finish** | Pengguna menyelesaikan alur pembayaran. **Belum tentu lunas** — bisa saja ia baru dapat nomor VA dan belum mentransfer. |
| **Unfinish** | Pengguna menutup/meninggalkan halaman Snap sebelum selesai. |
| **Error** | Terjadi kegagalan di sisi Midtrans. |

Poin di baris "Finish" sering disalahpahami. `finish` **bukan** sinonim "berhasil". Untuk pembayaran VA, pengguna sampai di `finish` begitu nomor VA terbit — pembayaran sesungguhnya baru terjadi berjam-jam kemudian, dan hanya webhook yang tahu.

### Satu catatan penting soal dashboard

Nilai di dashboard sebenarnya adalah **fallback**. Kode ini sudah mengirim `callbacks` di setiap permintaan Snap (`app/Support/MidtransSnap.php:129-133`):

```php
'callbacks' => [
    'finish'   => url('/payment/finish'),
    'unfinish' => url('/payment/unfinish'),
    'error'    => url('/payment/error'),
],
```

`url()` menurunkan host dari `APP_URL`. Artinya:

> **`APP_URL` di `.env` wajib benar.** Kalau masih `http://localhost`, Midtrans akan memantulkan pengguna produksi ke `localhost` — dan alur pembayaran putus di situ, tanpa pesan galat yang jelas.

```env
APP_URL=https://livirooms.com
```

Tetap isi juga kolom di dashboard sebagai jaring pengaman.

## 14. Langkah Setup

### Langkah 1 — Ambil kunci dari dashboard sandbox

1. Masuk ke `https://dashboard.sandbox.midtrans.com`
2. `Settings` → `Access Keys`
3. Salin **Merchant ID**, **Client Key**, dan **Server Key**

Server Key sandbox berawalan `SB-Mid-server-`, Client Key `SB-Mid-client-`. Kunci produksi tanpa awalan `SB-`.

> **Server Key adalah kredensial paling sensitif di sistem ini.** Ia memverifikasi webhook dan mengotorisasi refund. Jangan pernah menaruhnya di kode Flutter, repo publik, atau tiket. Client Key boleh berada di sisi klien; Server Key tidak.

### Langkah 2 — Masukkan kunci ke aplikasi

Ada dua cara, dan **cara pertama yang dianjurkan**:

**Cara A — lewat panel admin (dianjurkan)**

```
Login sebagai admin → menu Pembayaran → Pengaturan Pembayaran
```

Isi Server Key, Client Key, dan sakelar Production Mode, lalu simpan. Nilainya disimpan ke tabel `payment_settings` dan langsung dipakai — `AppServiceProvider` mendorongnya ke `config('services.midtrans.*')` saat boot.

Kelebihannya: rotasi kunci tidak butuh akses SSH dan tidak perlu deploy ulang.

> Halaman ini hanya untuk peran **admin**. Peran `host` (pemilik properti) sengaja tidak diberi akses, karena halaman ini memuat Server Key.

**Cara B — lewat `.env` (hanya untuk instalasi baru)**

```env
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxxxxxxxxxxxxxxxxxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxxxxxxxxxxxxxxxxxxx
MIDTRANS_IS_PRODUCTION=false
```

`.env` hanya berfungsi sebagai nilai awal. Begitu ada baris di `payment_settings`, baris itulah yang menang (`app/Models/PaymentSetting.php:67-78`).

### Langkah 3 — Pastikan `APP_URL` benar

```env
APP_URL=https://livirooms.com
```

Lalu bersihkan cache konfigurasi:

```bash
php artisan config:clear
```

### Langkah 4 — Isi URL di dashboard

`Settings` → `Configuration`:

| Kolom | Isi |
|---|---|
| Payment Notification URL | `https://livirooms.com/api/v1/payments/webhook` |
| Finish Redirect URL | `https://livirooms.com/payment/finish` |
| Unfinish Redirect URL | `https://livirooms.com/payment/unfinish` |
| Error Redirect URL | `https://livirooms.com/payment/error` |

Tekan **Update**.

### Langkah 5 — Aktifkan metode pembayaran

```
Panel admin → Pembayaran → Metode Pembayaran
```

Kolom `code` berupa dropdown, isinya terbatas pada kode yang bisa dipetakan `MidtransSnap` ke channel Snap:

`virtual_account`, `bank_transfer`, `qris`, `ewallet`, `credit_card`, `paylater`

Pembatasan ini disengaja. Kode di luar daftar akan sampai ke Snap tanpa pemetaan channel, sehingga pengguna melihat **semua** pilihan pembayaran padahal `payments.method` mencatat satu metode tertentu — laporan jadi tidak cocok dengan data Midtrans.

Untuk mempersempit channel lebih jauh, isi kolom Metadata:

```json
{"banks": ["bca", "bni"]}
```

atau

```json
{"channels": ["gopay", "shopeepay"]}
```

Pemetaannya ada di `app/Support/MidtransSnap.php:35-69`.

### Langkah 6 — Pastikan scheduler berjalan

```cron
* * * * * cd /var/www/livirooms && php artisan schedule:run >> /dev/null 2>&1
```

Tanpa ini, `payments:cancel-expired` tidak pernah jalan dan pembayaran yang telantar akan menahan ketersediaan properti selamanya. Jadwalnya terdaftar di `routes/console.php:14-19` (tiap 10 menit).

## 15. Menguji Secara Lokal (tanpa domain publik)

Midtrans tidak bisa menghubungi `localhost`. Buka terowongan:

```bash
ngrok http 8000
```

Ambil URL HTTPS yang muncul, misalnya `https://a1b2c3d4.ngrok-free.app`, lalu:

1. Perbarui `.env`:
   ```env
   APP_URL=https://a1b2c3d4.ngrok-free.app
   ```
2. `php artisan config:clear`
3. Perbarui keempat URL di dashboard dengan host tersebut.

URL ngrok gratis berubah setiap kali dijalankan ulang, jadi langkah 1–3 harus diulang tiap sesi.

### Menguji webhook tanpa membayar

`Settings` → `Configuration` → tombol **Send test notification**.

Atau kirim manual — perhatikan tanda tangannya harus dihitung dengan Server Key yang sama persis:

```bash
ORDER_ID="ORD-A1B2C3D4-45"
STATUS_CODE="200"
GROSS_AMOUNT="575000.00"
SERVER_KEY="SB-Mid-server-xxxxxxxxxxxxxxxxxxxxx"

SIGNATURE=$(printf '%s%s%s%s' "$ORDER_ID" "$STATUS_CODE" "$GROSS_AMOUNT" "$SERVER_KEY" | sha512sum | cut -d' ' -f1)

curl -X POST https://a1b2c3d4.ngrok-free.app/api/v1/payments/webhook \
  -H "Content-Type: application/json" \
  -d "{
    \"order_id\": \"$ORDER_ID\",
    \"status_code\": \"$STATUS_CODE\",
    \"gross_amount\": \"$GROSS_AMOUNT\",
    \"signature_key\": \"$SIGNATURE\",
    \"transaction_status\": \"settlement\",
    \"fraud_status\": \"accept\",
    \"transaction_id\": \"test-trx-001\"
  }"
```

Dua hal yang mudah keliru:

- `gross_amount` harus **sama persis** dengan yang dikirim Midtrans, termasuk dua angka desimal (`575000.00`, bukan `575000`). Tanda tangan dihitung dari string mentahnya.
- `order_id` harus berakhiran `-{payment_id}` yang benar-benar ada di basis data, karena `PaymentDeepLink::paymentIdFrom()` memotong di tanda hubung terakhir.

### Kartu uji sandbox

| Skenario | Nomor kartu | CVV | Exp | OTP |
|---|---|---|---|---|
| Berhasil | `4811 1111 1111 1114` | `123` | `01/25` | `112233` |
| Ditolak | `4911 1111 1111 1113` | `123` | `01/25` | `112233` |

Daftar lengkap: <https://docs.midtrans.com/docs/testing-payment-on-sandbox>

## 16. Naik ke Produksi

1. **Ganti dashboard** ke `https://dashboard.midtrans.com` (tanpa `sandbox`).
2. **Ambil kunci produksi** — berbeda dari sandbox, tanpa awalan `SB-`.
3. **Perbarui via panel admin**, termasuk menyalakan sakelar **Production Mode**. Sakelar ini yang menentukan `Config::$isProduction` (`app/Support/MidtransSnap.php:77-83`); salah setel berarti transaksi dikirim ke lingkungan yang keliru dan seluruhnya gagal.
4. **Isi ulang keempat URL** di dashboard produksi dengan domain produksi.
5. **Perbarui `APP_URL`** lalu `php artisan config:clear`.
6. **Pastikan sertifikat TLS sah.** Sertifikat kedaluwarsa atau self-signed membuat Midtrans gagal mengirim webhook, dan pembayaran akan menggantung tanpa gejala di sisi pengguna.
7. **Uji satu transaksi kecil sungguhan** sebelum diumumkan.

## 17. Bila Bermasalah

| Gejala | Kemungkinan penyebab | Cara memastikan |
|---|---|---|
| Pembayaran lunas tapi status tetap `pending` | Notification URL salah / tidak terjangkau | `Settings` → `Configuration` → tab riwayat notifikasi; cek `storage/logs/laravel.log` |
| Log berisi `signature mismatch` | Server Key di aplikasi ≠ Server Key dashboard, atau sandbox tercampur produksi | Bandingkan Server Key di panel admin dengan `Access Keys` |
| Log berisi `amount mismatch` | `orders.total` berubah setelah transaksi dibuat | Bandingkan `payments.amount` dengan `gross_amount` di payload |
| Setelah bayar, browser mendarat di `localhost` | `APP_URL` masih nilai lokal | `php artisan tinker` → `config('app.url')` |
| Aplikasi Flutter tidak terbuka setelah bayar | Deep link belum terpasang | Lihat T-12 di `remediation.md` |
| Booking kedaluwarsa padahal sudah dibayar | Scheduler mati **atau** webhook tak pernah sampai | Cek cron; cari `left paid` di log |
| Snap menampilkan semua metode padahal pengguna memilih QRIS | Metadata/kode metode tidak terpetakan | Cek baris di `payment_methods`, cocokkan dengan `MidtransSnap::DEFAULT_CHANNELS` |
| Tombol "Lanjutkan Bayar" tidak muncul di booking detail | `host_confirmed = false` — host belum mengkonfirmasi | Login sebagai host → Manajemen Order → Terima |
| Tombol pembayaran hilang meski status pending | Booking sudah expired (`check_out` terlewat) — tombol disembunyikan otomatis | Cek tanggal `check_out` booking; jika lewat, buat booking baru |
| Booking baru ditolak dengan "Tanggal sudah dipesan" | Ada booking aktif lain yang overlap tanggal yang sama | Cek `bookings` table untuk property_id tersebut |
| Payment expired tapi booking masih waiting_confirmation | `payments:cancel-expired` belum dijalankan | Jalankan `php artisan payments:cancel-expired` |

### Tempat melihat log

```bash
tail -f storage/logs/laravel.log | grep -i midtrans
```

Yang penting dicari:

- `Midtrans webhook rejected: signature mismatch` → kunci tidak cocok
- `Midtrans webhook rejected: amount mismatch` → nominal berubah
- `Midtrans transaction flagged for manual review` → `fraud_status = challenge`, perlu approve/deny manual di dashboard
- `Midtrans reported failure for an already-paid payment` → notifikasi datang tidak berurutan; sudah ditangani, tapi layak diperiksa

## 18. Rujukan

- Dashboard sandbox — <https://dashboard.sandbox.midtrans.com>
- Dokumentasi Snap — <https://docs.midtrans.com/docs/snap-snap-integration-guide>
- HTTP Notification — <https://docs.midtrans.com/docs/https-notification-webhooks>
- SDK PHP — <https://github.com/Midtrans/midtrans-php>
