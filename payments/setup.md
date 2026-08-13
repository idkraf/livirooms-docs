# Payment Setup Guide

Panduan lengkap mengisi URL di dashboard Midtrans, memahami perbedaan Notification URL dan Finish Redirect URL, serta langkah testing dan produksi.

## Daftar Isi

- [Kebijakan Guest Browsing](#kebijakan-guest-browsing)
- [Ringkasan URL](#ringkasan-url)
- [Notification URL vs Finish Redirect URL](#notification-url-vs-finish-redirect-url)
- [Alur Lengkap](#alur-lengkap)
- [Langkah Setup](#langkah-setup)
- [Testing Lokal](#testing-lokal)
- [Naik ke Produksi](#naik-ke-produksi)
- [Troubleshooting](#troubleshooting)

## Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/POST /api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

## Ringkasan URL

| Field di Dashboard Midtrans | Isi |
|---|---|
| **Payment Notification URL** | `https://sewain.co.id/api/v1/payments/webhook` |
| **Finish Redirect URL** | `https://sewain.co.id/payment/finish` |
| **Unfinish Redirect URL** | `https://sewain.co.id/payment/unfinish` |
| **Error Redirect URL** | `https://sewain.co.id/payment/error` |

## Perbedaan Notification URL dan Finish Redirect URL

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

## Notification URL — Detail

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
| Sandbox, domain publik | `https://staging.sewain.co.id/api/v1/payments/webhook` |
| Produksi | `https://sewain.co.id/api/v1/payments/webhook` |
| Lokal (via tunnel) | `https://a1b2c3d4.ngrok-free.app/api/v1/payments/webhook` |

### Syarat yang wajib dipenuhi

1. **HTTPS.** Midtrans menolak `http://` di produksi.
2. **Dapat diakses publik.** `localhost` dan IP privat tidak akan pernah dihubungi Midtrans.
3. **Tanpa auth.** Jangan letakkan di balik Basic Auth, Cloudflare Access, atau halaman "maintenance".
4. **Balas `200` secepatnya.** Kalau server balas `500` atau timeout, Midtrans mengulang beberapa kali lalu menyerah — dan pembayaran akan menggantung.
5. **Bebas dari CSRF.** Sudah aman: route API tidak memakai middleware `web`.

### Yang diisi di dashboard

`Settings` → `Configuration` → kolom **Payment Notification URL**.

Ada juga kolom `Finish/Unfinish/Error Redirect URL` di halaman yang sama — lihat bagian berikutnya.

## Finish Redirect URL — Detail

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
| Produksi | `https://sewain.co.id/payment/finish` | `.../payment/unfinish` | `.../payment/error` |
| Sandbox | `https://staging.sewain.co.id/payment/finish` | `.../payment/unfinish` | `.../payment/error` |
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
APP_URL=https://sewain.co.id
```

Tetap isi juga kolom di dashboard sebagai jaring pengaman.

## Alur Lengkap, Ujung ke Ujung

```
User  ──POST /api/v1/bookings────────►  Laravel
  │◄── 201 {booking, order} ──────────│
  │                                   │
  │  navigasi ke BookingDetailScreen  │
  │  "Menunggu konfirmasi host..."    │
  │                                   │
Host  ──POST /api/v1/bookings/{id}/confirm ──►  Laravel
  │◄── 200 {booking.host_confirmed=true} ───────│
  │                                   │
  │  "Lanjutkan Bayar" muncul         │
  │                                   │
  Host  ──GET /api/v1/host/orders ────────────►  Laravel
  │◄── 200 {orders based on property.host_id} ──│
  │                                   │
  Host  ──GET /api/v1/host/orders/{id} ────────►  Laravel
  │◄── 200 {order detail} ─────────────────────│
User  ──POST /api/v1/orders/{order}/pay──►  Laravel  ──Snap::createTransaction()──► Midtrans
  │◄── 201 {payment, snap_token, redirect_url} ────────────────────────────────────┘
  │
  │  buka halaman Snap
  ▼
  ╔═════════════════════ pengguna membayar ═════════════╣
  ║  (A) JALUR TEPERCAYA — mengubah status              ║
  ║      POST /api/v1/payments/webhook                  ║
  ║      + signature_key                                 ║
  ║      → payments.status = 'paid'                      ║
  ║      → orders.status   = 'processing'                ║
   ║      → bookings.status = 'paid'                        ║
  ║                                                     ║
  ║  (B) JALUR TIDAK TEPERCAYA — hanya navigasi         ║
  ║      GET /payment/finish?order_id=...                ║
  ║      → redirect sewain://payment-result?paymentId=N ║
  ╚═════════════════════════════════════════════════════╝
                        │
                        ▼
              Flutter dibuka lewat deep link
```

Perhatikan (A) dan (B) berjalan **paralel dan independen**. Aplikasi tidak pernah mempercayai (B) untuk status; ia selalu bertanya ulang ke server.

Deep link yang dipakai (`app/Support/PaymentDeepLink.php:44-52`):

```
sewain://payment-result?paymentId=45&orderId=12
```

Sengaja tidak membawa status — lihat komentar di `PaymentDeepLink.php:7-16`.

## Langkah Setup

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
APP_URL=https://sewain.co.id
```

Lalu bersihkan cache konfigurasi:

```bash
php artisan config:clear
```

### Langkah 4 — Isi URL di dashboard

`Settings` → `Configuration`:

| Kolom | Isi |
|---|---|
| Payment Notification URL | `https://sewain.co.id/api/v1/payments/webhook` |
| Finish Redirect URL | `https://sewain.co.id/payment/finish` |
| Unfinish Redirect URL | `https://sewain.co.id/payment/unfinish` |
| Error Redirect URL | `https://sewain.co.id/payment/error` |

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
* * * * * cd /var/www/sewain && php artisan schedule:run >> /dev/null 2>&1
```

Tanpa ini, `payments:cancel-expired` tidak pernah jalan dan pembayaran yang telantar akan menahan ketersediaan properti selamanya. Jadwalnya terdaftar di `routes/console.php:14-19` (tiap 10 menit).

## Menguji Secara Lokal (tanpa domain publik)

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

## Naik ke Produksi

1. **Ganti dashboard** ke `https://dashboard.midtrans.com` (tanpa `sandbox`).
2. **Ambil kunci produksi** — berbeda dari sandbox, tanpa awalan `SB-`.
3. **Perbarui via panel admin**, termasuk menyalakan sakelar **Production Mode**. Sakelar ini yang menentukan `Config::$isProduction` (`app/Support/MidtransSnap.php:77-83`); salah setel berarti transaksi dikirim ke lingkungan yang keliru dan seluruhnya gagal.
4. **Isi ulang keempat URL** di dashboard produksi dengan domain produksi.
5. **Perbarui `APP_URL`** lalu `php artisan config:clear`.
6. **Pastikan sertifikat TLS sah.** Sertifikat kedaluwarsa atau self-signed membuat Midtrans gagal mengirim webhook, dan pembayaran akan menggantung tanpa gejala di sisi pengguna.
7. **Uji satu transaksi kecil sungguhan** sebelum diumumkan.

## Bila Bermasalah

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

## Rujukan

- Dashboard sandbox — <https://dashboard.sandbox.midtrans.com>
- Dokumentasi Snap — <https://docs.midtrans.com/docs/snap-snap-integration-guide>
- HTTP Notification — <https://docs.midtrans.com/docs/https-notification-webhooks>
- SDK PHP — <https://github.com/Midtrans/midtrans-php>
