# Midtrans Integration Audit

> Dokumen ini dibuat dari **pembacaan kode yang ada saat ini** (audit, bukan desain). Tidak ada satu baris pun file Laravel/Flutter yang diubah untuk membuat dokumen ini. Setiap klaim di bawah menyertakan path file + nomor baris agar bisa diverifikasi sendiri.

## Daftar Isi

- [Ringkasan Eksekutif](#ringkasan-eksekutif)
- [Kebijakan Guest Browsing](#kebijakan-guest-browsing)
- [Peta File yang Terlibat](#peta-file-yang-terlibat)
- [Arsitektur & Alur End-to-End](#arsitektur--alur-end-to-end)
- [Status Implementasi (Sudah vs Belum)](#status-implementasi-sudah-vs-belum)
- [Deep Link — Cara Kerja & Solusi](#deep-link--cara-kerja--solusi)
- [Kesesuaian dengan Dokumentasi Resmi Midtrans](#kesesuaian-dengan-dokumentasi-resmi-midtrans)
- [Tutorial Setup dari Nol](#tutorial-setup-dari-nol)
  - [**Langkah 5 — Daftarkan URL di Dashboard Midtrans**](#langkah-5--daftarkan-url-di-dashboard-midtrans) ← keenam field *Setting URL endpoints*
- [Temuan Kritis & Rekomendasi](#temuan-kritis--rekomendasi)
- [Rujukan](#rujukan)

## Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

## Ringkasan Eksekutif

Integrasi Midtrans di proyek ini **sudah 80% terbangun di sisi backend** dan **berfungsi untuk alur "happy path"**: user memilih metode, backend membuat transaksi Snap, user dilempar ke halaman Midtrans, webhook menandai lunas.

Namun ada **tiga penghenti (blocker) yang membuat alur tidak selesai secara utuh**, plus **satu celah keamanan serius**:

| # | Temuan | Dampak |
|---|--------|--------|
| **K-1** | `FinishController` mempercayai `transaction_status` dari **query string** dan langsung menandai pembayaran `paid` | 🔴 **Kritis — keamanan.** Siapa pun bisa menandai pesanannya lunas tanpa membayar |
| **K-2** | Setting Midtrans yang disimpan admin ke tabel `payment_settings` **tidak pernah dibaca** oleh kode pembayaran | 🔴 **Kritis — fungsional.** Tombol "Simpan Konfigurasi" di admin efektif tidak berefek |
| **K-3** | Skema deep link `sewain://` **tidak terdaftar** di Android/iOS, dan tidak ada listener di Flutter | 🔴 **Kritis — fungsional.** User tidak pernah kembali ke app setelah bayar |
| **K-4** | Metode yang dipilih user **tidak dikirim** ke Snap (`enabled_payments` tidak ada) | 🟠 Tinggi. User pilih QRIS, tapi Snap tetap menampilkan semua metode |
| **K-5** | Booking yang sudah dikonfirmasi host **masih bisa di-order user lain** sebelum pembayaran | 🟠 Tinggi. Double-booking possible saat transisi confirmed → paid |

Detail dan solusi tiap poin ada di [bagian 11](#temuan-kritis--rekomendasi).

---

## Peta File yang Terlibat

### Backend — Laravel

| Path | Peran |
|------|-------|
| `app/Http/Controllers/Api/PaymentController.php` | Inti integrasi Snap: `methods`, `pay`, `payUrl`, `show`, `reconcile`, `webhook` |
| `app/Http/Controllers/Api/BookingController.php` | Booking CRUD + host `confirm()`/`reject()` + overlap guard + `restoreAvailability()` |
| `app/Http/Controllers/Payment/FinishController.php` | Callback browser saat pembayaran selesai → deep link |
| `app/Http/Controllers/Payment/UnfinishController.php` | Callback saat user keluar sebelum selesai |
| `app/Http/Controllers/Payment/ErrorController.php` | Callback saat terjadi error di sisi Midtrans |
| `app/Http/Controllers/Admin/PaymentController.php` | CRUD admin untuk data pembayaran |
| `app/Http/Controllers/Admin/PaymentMethodController.php` | CRUD admin untuk metode pembayaran |
| `app/Livewire/PaymentSettings/Settings.php` | Form konfigurasi Midtrans + toggle metode |
| `app/Livewire/PaymentMethods/Form.php` | Form tambah/edit metode pembayaran |
| `app/Console/Commands/CancelExpiredPayments.php` | Auto-expire stale payment + auto-cancel past check-in bookings + restore availability |
| `app/Models/Booking.php` | Model dengan `host_confirmed` flag + casts |
| `app/Models/Payment.php` · `PaymentMethod.php` · `PaymentSetting.php` | Model Eloquent |
| `config/services.php:38-42` | Sumber kredensial Midtrans yang **benar-benar dipakai** |
| `routes/api_mobile.php:53`, `:77-83` | Route API mobile + confirm/reject booking |
| `routes/web.php:36-38` | Route callback browser |
| `routes/admin_generated.php:62-72` | Route admin |
| `tests/Feature/Api/PaymentControllerTest.php` | 12 test feature |

### Frontend — Flutter

| Path | Peran |
|------|-------|
| `flutter/lib/screens/payment/payment_method_screen.dart` | Buat booking + order → navigasi ke booking detail |
| `flutter/lib/screens/booking/booking_detail_screen.dart` | Detail booking dengan payment button setelah host confirm + retry/continue payment |
| `flutter/lib/screens/payment/payment_result_screen.dart` | Layar hasil pembayaran (dipanggil via deep link) |
| `flutter/lib/screens/mitra/order_management_screen.dart` | Manajemen order mitra (`GET /host/orders`) dengan tombol Terima/Tolak, hide jika expired |
| `flutter/lib/screens/mitra/order_detail_screen.dart` | Detail order mitra dengan konfirmasi/tolak |
| `flutter/lib/services/booking_service.dart` | `pay()`, `retryPayment()`, `paymentMethods()`, `checkAvailability()`, `bookingDetail()` |
| `flutter/lib/services/host_service.dart` | `orders()` → `GET /host/orders`, `orderDetail()` → `GET /host/orders/{id}`, `confirmOrder()`, `rejectOrder()` |
| `flutter/lib/models/booking.dart` | Model `Booking` dengan `hostConfirmed` |
| `flutter/lib/models/payment.dart` | Model `Payment` (sudah punya `snapToken`, `redirectUrl`) |
| `flutter/lib/router.dart:84`, `:167` | Route `/payment/result` |
| `flutter/android/app/src/main/AndroidManifest.xml` | **Tidak ada** intent-filter untuk `sewain://` |

### Database

| Migration | Tabel |
|-----------|-------|
| `2026_07_14_081300_create_payments_table.php` | `payments` |
| `2026_07_28_000000_create_payment_methods_table.php` | `payment_methods` |
| `2026_07_28_000001_create_payment_settings_table.php` | `payment_settings` |

Seeder: `PaymentSeeder`, `PaymentMethodSeeder`, `PaymentSettingSeeder`.

---

## Arsitektur & Alur End-to-End

### Alur normal (sesuai desain kode saat ini)

```
Flutter (mobile)                     Laravel (BE)                    Midtrans
     │                                 │                              |
     │── GET /payments/methods ────────►│                              |
     │◄── list PaymentMethod ───────────│                              │
     │                                 │                              │
     │── POST /orders/{order}/pay ─────►│                              │
     │    body: {"method": "qris"}      │                              │
     │                                 │── Snap::getSnapToken(params)─►│
     │                                 │◄── {snap_token, redirect} ──│
     │◄── {snap_token, redirect_url} ──│                              │
     │                                 │                              │
     │── open external browser ────────│─────────────────────────────►│
     │    (redirect_url)                │     [user pays on Midtrans]  │
     │                                 │◄── webhook notification ─────│
     │                                 │   (transaction_status, etc)  │
     │                                 │                              │
     │── GET /payments/{id} ───────────►│                              │
     │◄── payment detail ───────────────│                              │
```

### Dua jalur update status — dan mana yang bisa dipercaya

Sistem ini punya **tiga** jalur yang bisa mengubah status pembayaran:

| Jalur | File | Bisa dipercaya? |
|-------|------|-----------------|
| **Webhook** (server-to-server) | `PaymentController::webhook()` [:291-343](laravel/app/Http/Controllers/Api/PaymentController.php#L291-L343) | ✅ **Ya** — signature SHA512 diverifikasi |
| **Reconcile** (polling dari app) | `PaymentController::reconcile()` [:222-272](laravel/app/Http/Controllers/Api/PaymentController.php#L222-L272) | ✅ **Ya** — tanya langsung ke API Midtrans |
| **Finish callback** (redirect browser) | `FinishController::finish()` [:11-48](laravel/app/Http/Controllers/Payment/FinishController.php#L11-L48) | 🔴 **TIDAK** — lihat [K-1](#k-1--kritis-forgery-status-pembayaran-lewat-finish-callback) |

> **Prinsip Midtrans:** webhook adalah satu-satunya sumber kebenaran. Redirect browser hanya untuk UX (memindahkan user kembali ke app), **tidak boleh** dipakai untuk mengubah status finansial.

---

## Status Implementasi (Sudah vs Belum)

### Sudah Diimplementasikan

#### Backend

- **SDK terpasang.** `midtrans/midtrans-php: ^2.6` di `composer.json:15`, terverifikasi ada di `vendor/midtrans/midtrans-php` (v2.6.2 di `composer.lock`).
- **Config Midtrans.** `config/services.php:38-42` — `server_key`, `client_key`, `is_production`.
- **Endpoint API lengkap** (`routes/api_mobile.php`):

  | Method | Endpoint | Handler |
  |--------|----------|---------|
  | `GET` | `/api/v1/payments/methods` | `methods()` — daftar metode aktif |
  | `GET` | `/api/v1/orders` | `OrderController::index()` — order milik user |
  | `GET` | `/api/v1/orders/{order}` | `OrderController::show()` — detail order milik user |
  | `GET` | `/api/v1/host/orders` | `OrderController::forHost()` — order berdasarkan `property.host_id` |
  | `GET` | `/api/v1/host/orders/{order}` | `OrderController::showForHost()` — detail order untuk host |
  | `POST` | `/api/v1/orders/{order}/pay` | `pay()` — buat transaksi Snap |
  | `POST` | `/api/v1/orders/{order}/pay/retry` | `payUrl()` — lanjut/ulangi pembayaran |
  | `GET` | `/api/v1/payments/{payment}` | `show()` — detail pembayaran |
  | `GET` | `/api/v1/payments/{payment}/reconcile` | `reconcile()` — sinkron status ke Midtrans |
  | `POST` | `/api/v1/payments/webhook` | `webhook()` — notifikasi Midtrans (publik, tanpa Sanctum) |

- **Verifikasi signature webhook.** `PaymentController.php:301-306` — SHA512 dari `order_id + status_code + gross_amount + server_key`, dibandingkan dengan `hash_equals()` (aman dari timing attack). **Ini sudah sesuai spesifikasi resmi Midtrans.**
- **Otorisasi kepemilikan.** `pay()`, `payUrl()`, `show()`, `reconcile()` semuanya memeriksa `user_id` pemilik order (`abort_unless`).
- **Validasi batas nominal.** `min_amount` / `max_amount` per metode dicek di `pay()` [:62-78](laravel/app/Http/Controllers/Api/PaymentController.php#L62-L78).
- **Kaskade status** `payment → order → booking` pada webhook, reconcile, dan finish.
- **Parsing `order_id` aman.** Memakai `strrpos()` (hyphen terakhir), sehingga `ORD-A1B2C3D4-15` tetap terbaca `payment_id = 15` walau `order_code` mengandung hyphen.
- **Envelope API konsisten** lewat `App\Support\ApiResponse`.
- **12 test feature** di `tests/Feature/Api/PaymentControllerTest.php`, termasuk test webhook signature valid & invalid.

#### Admin Panel

- CRUD **Payments** — DataTable + Livewire modal (`admin/payments/`).
- CRUD **Payment Methods** — DataTable + Livewire modal (`admin/payment_methods/`).
- Halaman **Payment Settings** — form Midtrans + tabel toggle metode (`admin/payment_settings/index.blade.php`).
- Permission `view payment_settings`, `view payments`, `view payment_methods` (`RolePermissionSeeder.php:37`), menu sidebar sudah ter-gate.

#### Flutter

- Model `Booking` sekarang punya `hostConfirmed` (`lib/models/booking.dart`).
- Model `Payment` sudah punya field `snapToken` & `redirectUrl` (`lib/models/payment.dart:7-8`).
- `booking_service.pay()` sudah mengambil `snap_token`/`redirect_url` dari **level data** (bukan dari objek `payment`), sesuai bentuk respons backend — `booking_service.dart:102-103`.
- `booking_service.retryPayment()` memanggil `POST /orders/{orderId}/pay/retry` untuk melanjutkan/ulangi pembayaran.
- `booking_service.checkAvailability()` cek `is_available` via `GET /properties/{id}/availability?from=...&to=...`.
- `payment_method_screen.dart` sekarang hanya membuat booking + order, lalu navigasi ke `BookingDetailScreen`.
- `booking_detail_screen.dart` menampilkan:
  - "Menunggu konfirmasi dari pemilik properti..." jika `host_confirmed = false`
  - Tombol **Lanjutkan Bayar** jika `host_confirmed = true` dan belum ada payment
  - Tombol **Lanjutkan Pembayaran** jika payment `pending`
  - Tombol **Coba Bayar Lagi** / **Buat Pesanan Baru** jika payment `failed`/`expired`
- Polling setiap 5 detik untuk update status payment.
- Null-safety guard saat parsing (`raw is! Map<String, dynamic>` → `ApiException`).
- Deep link handler (`lib/services/deep_link_handler.dart`) menangani cold start dan resume.

### Belum Diimplementasikan

#### Backend

| Hal | Status | Keterangan |
|-----|--------|------------|
| **Setting admin terhubung ke kode pembayaran** | ✅ | `AppServiceProvider::boot()` menimpa config dari `payment_settings` tabel |
| **`enabled_payments`** | ✅ | Metode aktif dikirim ke Snap via `MidtransSnap::enabledPaymentsFor()` |
| **`item_details`** | ✅ | Rincian properti + durasi + harga dikirim |
| **Verifikasi nominal di webhook** | ✅ | `gross_amount` dibandingkan dengan `$payment->amount` |
| **Idempotensi webhook** | ✅ | Keluar lebih awal bila sudah `paid`; `paid_at` tidak ditimpa |
| **Penanganan `fraud_status = challenge`** | ✅ | Tetap `pending` + log untuk review manual |
| **Auto-expire pembayaran** | ✅ | `payments:cancel-expired` + auto-cancel past check-in bookings |
| **Availability guard** | ✅ | Overlap check di `BookingController::store()` + `payUrl()` + `restoreAvailability()` |
| **Host confirmation flow** | ✅ | `POST /bookings/{booking}/confirm` & `reject` + `host_confirmed` flag |
| **Refund** | ❌ | `Transaction::refund()` tidak dipakai; status `refunded` ada di enum tapi tidak ada jalur kode |
| **Logging transaksi** | ⚠️ Parsial | Hanya error yang di-log; tidak ada audit trail payload webhook |

#### Flutter

| Hal | Status | Keterangan |
|-----|--------|------------|
| **Registrasi skema `sewain://`** | ✅ | Intent-filter Android + `CFBundleURLTypes` iOS + `app_links` package |
| **Listener deep link** | ✅ | `DeepLinkHandler` di `lib/main.dart` + `lib/services/deep_link_handler.dart` |
| **Navigasi ke `PaymentResultScreen`** | ✅ | Dipanggil dari deep link handler |
| **Payment button setelah host confirm** | ✅ | `booking_detail_screen.dart` menampilkan "Lanjutkan Bayar" setelah `host_confirmed = true` |
| **Continue/retry payment** | ✅ | `_continuePayment()` dan `_retryPayment()` dengan availability guard |
| **Host confirm/reject di mitra** | ✅ | `order_management_screen.dart` dan `order_detail_screen.dart` memanggil API sungguhan |
| **Pemakaian `reconcile`** | ✅ | `PaymentResultScreen` memanggil `reconcilePayment()` jika status masih `pending` |
| **Snap in-app (WebView/SDK)** | ❌ | Memakai browser eksternal, bukan `midtrans_sdk` Flutter |

---

## `frontendDeepLink` — Cara Kerja & Cara Membuatnya Jalan

Ini bagian yang Anda tanyakan secara spesifik. Baris yang dimaksud:

```php
// laravel/app/Http/Controllers/Payment/FinishController.php:43-47
$frontendDeepLink = 'sewain://payment-result?status='
    . ($payment?->status ?? 'unknown')
    . '&orderId=' . ($payment?->order_id ?? 0);

return redirect()->away($frontendDeepLink);
```

Pola yang identik juga ada di `UnfinishController.php:26-30` dan `ErrorController.php:26-30`.

### Cara kerja yang diniatkan

Deep link adalah **URL dengan skema kustom** yang didaftarkan sebuah aplikasi ke sistem operasi. Ketika browser diminta membuka URL berskema itu, OS mengalihkannya ke aplikasi yang mendaftar — bukan ke server web.

Rantai yang diniatkan:

```
1. User selesai bayar di halaman Midtrans (browser eksternal)
2. Midtrans redirect browser ke callbacks.finish
   → https://domain-anda.com/payment/finish?order_id=ORD-XXXX-12&transaction_status=settlement
3. FinishController memproses, lalu membalas HTTP 302 dengan
   Location: sewain://payment-result?status=paid&orderId=12
4. Browser melihat skema "sewain" — bukan http/https
5. Android/iOS mencocokkan skema itu ke aplikasi terdaftar
6. Aplikasi Sewain dibuka ke depan, membawa URI tersebut
7. Listener di Flutter mem-parse URI → Navigator.pushNamed('/payment/result', …)
8. PaymentResultScreen tampil dengan status & orderId
```

### Mengapa saat ini **tidak** berjalan

Rantai putus di **langkah 5**. Tiga hal yang hilang, semuanya di sisi Flutter:

**a) Skema tidak terdaftar di Android.**
`flutter/android/app/src/main/AndroidManifest.xml` hanya punya satu intent-filter:

```xml
<intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
</intent-filter>
```

Tidak ada `<data android:scheme="sewain" />` di mana pun. Akibatnya Chrome menampilkan **`ERR_UNKNOWN_URL_SCHEME`** dan user terjebak di browser.

**b) Skema tidak terdaftar di iOS.**
`ios/Runner/Info.plist` tidak memiliki key `CFBundleURLTypes`.

**c) Tidak ada listener di Flutter.**
`pubspec.yaml:25` hanya memuat `url_launcher` — itu untuk **membuka** URL keluar, bukan **menerima** URL masuk. Tidak ada `app_links` maupun `uni_links`.

**d) Konsekuensi lanjutan.** Karena tidak ada yang pernah menavigasi ke sana, `PaymentResultScreen` menjadi *dead code* — sudah ditulis lengkap (termasuk `PaymentResultArgs{status, orderId}` di `payment_result_screen.dart:9-13`) tapi tidak terjangkau.

> ⚠️ **Catatan penamaan.** Skema di backend adalah `sewain://`, sedangkan aplikasi Flutter memakai `applicationId = "com.liviroom.app"` dan label `liviroom` (`android/app/build.gradle.kts:24`). Ini tidak otomatis salah — skema bebas ditentukan — tapi pastikan tim sepakat memakai `sewain` (harus sama persis dengan yang ada di ketiga controller) atau ubah keduanya menjadi `liviroom`. **Jangan sampai beda.**

### Tutorial: membuat deep link berfungsi

> Langkah-langkah ini **belum diterapkan** ke repo. Ini instruksi untuk Anda jalankan.

#### Langkah 1 — Tambah package listener

`flutter/pubspec.yaml`, di bawah `dependencies:`

```yaml
  app_links: ^6.3.2
```

Lalu:

```bash
cd flutter
flutter pub get
```

#### Langkah 2 — Daftarkan skema di Android

`flutter/android/app/src/main/AndroidManifest.xml`, tambahkan intent-filter **kedua** di dalam `<activity android:name=".MainActivity">` (biarkan intent-filter `MAIN`/`LAUNCHER` yang lama apa adanya):

```xml
<intent-filter android:autoVerify="false">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="sewain" android:host="payment-result" />
</intent-filter>
```

`MainActivity` sudah `android:launchMode="singleTop"` dan `android:exported="true"`, jadi tidak perlu diubah — dua atribut itu memang syarat deep link.

#### Langkah 3 — Daftarkan skema di iOS

`flutter/ios/Runner/Info.plist`, tambahkan sebelum `</dict>` penutup:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.liviroom.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>sewain</string>
        </array>
    </dict>
</array>
```

#### Langkah 4 — Pasang listener di Flutter

Di widget root (misal `lib/main.dart` atau `App`), tangani **dua** kasus: app dibuka dari kondisi mati (*cold start*) dan app sudah berjalan di background (*resume*).

```dart
import 'package:app_links/app_links.dart';

final _appLinks = AppLinks();
StreamSubscription<Uri>? _linkSub;

@override
void initState() {
  super.initState();
  _initDeepLinks();
}

Future<void> _initDeepLinks() async {
  final initial = await _appLinks.getInitialLink();
  if (initial != null) _handleUri(initial);

  _linkSub = _appLinks.uriLinkStream.listen(_handleUri);
}

void _handleUri(Uri uri) {
  if (uri.scheme != 'sewain' || uri.host != 'payment-result') return;

  final status = uri.queryParameters['status'] ?? 'unknown';
  final orderId = int.tryParse(uri.queryParameters['orderId'] ?? '') ?? 0;

  navigatorKey.currentState?.pushNamed(
    Routes.paymentResult,
    arguments: PaymentResultArgs(status: status, orderId: orderId),
  );
}

@override
void dispose() {
  _linkSub?.cancel();
  super.dispose();
}
```

> Ini membutuhkan `navigatorKey` (`GlobalKey<NavigatorState>`) yang terpasang di `MaterialApp`, karena navigasi dipicu dari luar `BuildContext` mana pun.

#### Langkah 5 — Pastikan `APP_URL` benar

`FinishController` hanya terpanggil kalau Midtrans tahu ke mana harus redirect. URL itu dibangun dari `config('app.url')` di `PaymentController.php:99-101`.

Saat ini `.env` masih `APP_URL=http://localhost` — **Midtrans tidak akan bisa menjangkau ini.** Harus domain publik ber-HTTPS:

```env
APP_URL=https://api.domain-anda.com
```

Lalu `php artisan config:clear`.

#### Langkah 6 — Uji tanpa perlu bayar dulu

Deep link bisa diuji langsung dari terminal, tanpa transaksi sungguhan:

```bash
# Android
adb shell am start -a android.intent.action.VIEW \
  -d "sewain://payment-result?status=paid&orderId=12"

# iOS Simulator
xcrun simctl openurl booted "sewain://payment-result?status=paid&orderId=12"
```

Kalau `PaymentResultScreen` muncul, rantai deep link sudah utuh. Uji juga dari browser di HP (ketik URL `sewain://...` di address bar) untuk memastikan skemanya benar-benar dikenali OS.

### Alternatif yang lebih tangguh (rekomendasi)

Deep link berskema kustom punya kelemahan bawaan: kalau app **belum ter-install**, `sewain://` gagal total dan user melihat halaman error. Dua opsi lebih baik:

1. **App Links / Universal Links** (`https://domain-anda.com/payment/finish` langsung membuka app, fallback ke web bila app tidak ada). Perlu file `assetlinks.json` (Android) dan `apple-app-site-association` (iOS) di server.
2. **Snap in-app WebView** — buka Snap di dalam `WebView`, deteksi navigasi ke URL finish, lalu tutup WebView dan pindah layar secara lokal. **Tidak perlu deep link sama sekali.** Ini pendekatan paling sederhana dan paling andal untuk kasus ini.

> Terlepas dari opsi mana pun yang dipilih, **status tetap harus dikonfirmasi ke backend** (lewat `GET /payments/{id}` atau `reconcile`), bukan dipercaya dari parameter URL. Lihat [K-1](#k-1--kritis-forgery-status-pembayaran-lewat-finish-callback).

---

## Kesesuaian dengan Dokumentasi Resmi `midtrans-php`

Dibandingkan dengan <https://github.com/Midtrans/midtrans-php>.

### Yang sudah sesuai

**Konfigurasi global.** Docs resmi:

```php
\Midtrans\Config::$serverKey = '<your server key>';
\Midtrans\Config::$isProduction = false;
\Midtrans\Config::$isSanitized = true;
\Midtrans\Config::$is3ds = true;
```

Kode di `pay()` [:114-117](laravel/app/Http/Controllers/Api/PaymentController.php#L114-L117) dan `payUrl()` [:170-173](laravel/app/Http/Controllers/Api/PaymentController.php#L170-L173) menetapkan keempatnya. ✅

**Pengambilan Snap token.** `Snap::getSnapToken($params)` — persis sesuai contoh docs. ✅

**Cek status transaksi.** `Transaction::status($orderId)` di `reconcile()` [:243](laravel/app/Http/Controllers/Api/PaymentController.php#L243) — sesuai docs. ✅

**Struktur `transaction_details`.** `order_id` + `gross_amount` (integer) — sesuai. ✅

**Verifikasi signature webhook.** SHA512 `order_id + status_code + gross_amount + server_key` — sesuai spesifikasi API Midtrans (perlu dicatat: skema ini ada di dokumentasi API Midtrans, **bukan** di README SDK, yang contohnya justru tidak memverifikasi signature sama sekali). Implementasi di sini **lebih aman daripada contoh README resmi**. ✅

### Yang menyimpang dari docs

**a) `redirect_url` dibangun manual, bukan dari SDK.**

Docs resmi menyediakan:

```php
$paymentUrl = \Midtrans\Snap::createTransaction($params)->redirect_url;
```

Kode saat ini justru merangkai string sendiri (`PaymentController.php:121-123`):

```php
$redirectUrl = \Midtrans\Config::$isProduction
    ? 'https://app.midtrans.com/snap/v2/vtweb/' . $snapToken
    : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/' . $snapToken;
```

Secara praktis URL ini benar dan berfungsi hari ini, tapi ia **mengunci domain Midtrans ke dalam kode aplikasi**. Kalau Midtrans mengubah host atau path Snap, integrasi ini rusak tanpa peringatan. Memakai `createTransaction()->redirect_url` menghilangkan risiko itu sekaligus memangkas satu percabangan `isProduction`.

**b) Format `expiry.start_time` kemungkinan besar ditolak Midtrans.**

`PaymentController.php:104`:

```php
'start_time' => now()->format('Y-m-d H:i:s T'),
```

`config/app.php:68` menetapkan `'timezone' => 'UTC'`, sehingga `T` menghasilkan literal **`UTC`** → `"2026-08-10 09:15:00 UTC"`.

Midtrans mensyaratkan **offset numerik**, contoh `"2026-08-10 09:15:00 +0700"`. Formatter yang benar adalah `O`, bukan `T`:

```php
'start_time' => now()->format('Y-m-d H:i:s O'),
```

Konsekuensi bila dibiarkan: Midtrans dapat menolak seluruh objek `expiry`, sehingga **batas kedaluwarsa 60 menit tidak pernah aktif** dan transaksi memakai default merchant. Perlu diverifikasi terhadap sandbox.

**c) `callbacks.unfinish` dan `callbacks.error` kemungkinan diabaikan.**

`PaymentController.php:98-102` mengirim tiga callback. Snap API secara resmi hanya menghormati **`finish`** di level transaksi; `unfinish` dan `error` diatur lewat **Dashboard → Snap Preferences**. Mengirimnya tidak menyebabkan error, tapi jangan berasumsi ia berpengaruh — set juga di Dashboard.

**d) Class `Midtrans\Notification` tidak dipakai.**

Docs menyarankan `$notif = new \Midtrans\Notification();`. Kode memakai `$request->all()` manual. Ini **bukan kesalahan** — justru memberi kendali penuh untuk verifikasi signature lebih dulu — tapi berarti Anda menanggung sendiri pemetaan field.

**e) `Config::$isSanitized` / `$is3ds` tidak diset di `reconcile()`.**

`reconcile()` [:239-240](laravel/app/Http/Controllers/Api/PaymentController.php#L239-L240) hanya menetapkan `serverKey` dan `isProduction`. Untuk `Transaction::status()` yang read-only ini tidak berdampak, tapi tidak konsisten dengan dua method lain.

**f) `enabled_payments` tidak dikirim.** Lihat [K-4](#k-4--tinggi-metode-pilihan-user-tidak-diteruskan-ke-snap).

**g) Guard `class_exists()` sudah menjadi kode mati.**

`PaymentController.php:113` dan `:169` membungkus logika Snap dalam `if (class_exists(\Midtrans\Snap::class))`. SDK **sudah terpasang**, jadi cabang `false` tidak akan pernah tereksekusi di runtime.

Efek sampingnya ada dua, dan keduanya menyesatkan:
- Field `params` di respons `pay()` [:142](laravel/app/Http/Controllers/Api/PaymentController.php#L142) berkomentar *"exposed only when SDK not yet installed"* — praktis selalu `null`.
- Test `test_pay_creates_payment_and_returns_snap_params_when_sdk_missing` (`PaymentControllerTest.php:130`) **tidak menguji apa yang dinyatakan namanya**: SDK ada, jadi ia sebenarnya memanggil Snap sungguhan atau mengandalkan `assertJsonStructure` yang lolos meski nilainya `null`. Ini menciptakan rasa aman yang palsu terhadap suite test.

---

## Setup Admin — Payment Settings

**URL:** `/admin/payment-settings` · **Permission:** `view payment_settings`
**Blade:** [`resources/views/admin/payment_settings/index.blade.php`](laravel/resources/views/admin/payment_settings/index.blade.php)
**Komponen:** [`app/Livewire/PaymentSettings/Settings.php`](laravel/app/Livewire/PaymentSettings/Settings.php)

Halaman ini terdiri atas dua kartu:

**Kartu 1 — Konfigurasi Midtrans**

| Field | Property | Validasi |
|-------|----------|----------|
| Server Key | `serverKey` | `required\|string\|max:255` |
| Client Key | `clientKey` | `required\|string\|max:255` |
| Production Mode | `isProduction` | `boolean` |
| Merchant Name | `merchantName` | `nullable\|string\|max:255` |
| Merchant Email | `merchantEmail` | `nullable\|email\|max:255` |
| Merchant Phone | `merchantPhone` | `nullable\|string\|max:50` |

**Kartu 2 — Metode Pembayaran**: tabel semua metode dengan tombol Enable/Disable (`toggleMethod()`).

### Peringatan penting soal halaman ini

**Form ini tidak mengubah perilaku pembayaran.** Ada tiga masalah yang saling bertumpuk:

1. **Simpan ≠ dipakai.** `saveMidtrans()` [:57-59](laravel/app/Livewire/PaymentSettings/Settings.php#L57-L59) menulis ke tabel `payment_settings`. Tapi `PaymentController` membaca dari `config('services.midtrans.server_key')` → `.env`. Keduanya tidak pernah bertemu.
2. **Muat ulang mengembalikan nilai lama.** `mount()` [:35-37](laravel/app/Livewire/PaymentSettings/Settings.php#L35-L37) membaca `serverKey`/`clientKey`/`isProduction` dari **config**, bukan dari DB. Jadi setelah Anda simpan lalu refresh, form menampilkan nilai `.env` lagi — seolah penyimpanan gagal. (Sementara `merchant_*` dibaca dari DB lewat `getSetting()`, sehingga **perilaku form tidak konsisten antar-field**.)
3. **`merchant_name/email/phone` tidak dipakai di mana pun.** `customer_details` yang dikirim ke Snap memakai nama & email **user pemesan** (`PaymentController.php:94-97`), bukan data merchant ini.

**Konsekuensi praktis:** untuk saat ini, **satu-satunya cara mengubah kredensial Midtrans adalah lewat `.env`**, lalu `php artisan config:clear`.

**Dua opsi perbaikan** (pilih salah satu, jangan dicampur):

- **Opsi A — jadikan DB sumber kebenaran.** Buat `AppServiceProvider::boot()` menimpa config dari DB saat aplikasi start:
  ```php
  if (Schema::hasTable('payment_settings')) {
      $s = PaymentSetting::pluck('value', 'key');
      config([
          'services.midtrans.server_key'    => $s['midtrans_server_key'] ?? config('services.midtrans.server_key'),
          'services.midtrans.client_key'    => $s['midtrans_client_key'] ?? config('services.midtrans.client_key'),
          'services.midtrans.is_production' => (bool) ($s['midtrans_is_production'] ?? false),
      ]);
  }
  ```
  Jangan lupa cache hasilnya agar tidak menambah query di setiap request.

- **Opsi B — jadikan `.env` sumber kebenaran.** Ubah `saveMidtrans()` agar menulis ke `.env` (pola `updateEnvVariable()` sudah ada di `BusinessSettingsController.php:53-73`), lalu jalankan `config:clear`. Hapus tiga key `midtrans_*` dari `payment_settings` supaya tidak ada dua sumber yang bersaing.

> Opsi A lebih ramah untuk admin non-teknis. Opsi B lebih sederhana dan cocok bila deployment memakai config caching. **Yang berbahaya adalah kondisi sekarang: dua sumber ada, dan yang diedit admin justru bukan yang dipakai.**

---

## Setup Admin — Payment Methods (Aktif / Non-Aktif)

**URL:** `/admin/payment-methods` · **Controller:** [`Admin/PaymentMethodController.php`](laravel/app/Http/Controllers/Admin/PaymentMethodController.php)
**Blade:** `resources/views/admin/payment_methods/` · **Livewire:** `app/Livewire/PaymentMethods/Form.php`

### Kolom tabel `payment_methods`

| Kolom | Tipe | Fungsi |
|-------|------|--------|
| `code` | `string` unique | Kode internal — dipakai Flutter saat `POST /pay` |
| `name` | `string` | Label tampilan |
| `group` | `string` nullable | Pengelompokan (`virtual_account`, `qris`, …) |
| `icon` | `string` nullable | Path ikon |
| `is_enabled` | `boolean` | **Muncul/tidak di aplikasi** |
| `sort_order` | `integer` | Urutan tampil |
| `min_amount` | `decimal(15,2)` | Batas bawah (divalidasi backend) |
| `max_amount` | `decimal(15,2)` | Batas atas (divalidasi backend) |
| `metadata` | `json` | Data tambahan (daftar bank / channel) |

### Data awal (`PaymentMethodSeeder`)

| Code | Nama | Min | Max | Default |
|------|------|-----|-----|---------|
| `virtual_account` | Virtual Account | 10.000 | 50.000.000 | ✅ Aktif |
| `qris` | QRIS | 10.000 | 20.000.000 | ✅ Aktif |
| `ewallet` | E-Wallet | 10.000 | 10.000.000 | ✅ Aktif |
| `credit_card` | Kartu Kredit | 50.000 | 100.000.000 | ✅ Aktif |
| `paylater` | PayLater | 100.000 | 50.000.000 | ❌ Non-aktif |

### Cara mengaktifkan / menonaktifkan metode

Ada **dua** tempat, keduanya bekerja pada kolom yang sama:

1. **`/admin/payment-settings`** — tombol Enable/Disable di kartu "Metode Pembayaran" (paling cepat).
2. **`/admin/payment-methods`** — modal edit, centang **Is Enabled** (bisa sekalian ubah limit & urutan).

### Efek `is_enabled` — dan batasnya

`is_enabled = false` berpengaruh pada **dua** titik:

- `methods()` [:33-35](laravel/app/Http/Controllers/Api/PaymentController.php#L33-L35) — metode tidak lagi muncul di daftar pilihan aplikasi.
- `pay()` [:49-60](laravel/app/Http/Controllers/Api/PaymentController.php#L49-L60) — permintaan dengan metode non-aktif ditolak `422`. Validasi server-side ini penting: user tidak bisa menembusnya dengan memodifikasi request.

> ⚠️ **Yang TIDAK dipengaruhi:** halaman Snap milik Midtrans. Karena `enabled_payments` tidak dikirim ([K-4](#k-4--tinggi-metode-pilihan-user-tidak-diteruskan-ke-snap)), user yang memilih QRIS di aplikasi tetap akan melihat **semua** metode yang aktif di Dashboard Midtrans — termasuk yang sudah Anda matikan di sini. Untuk sementara, matikan metode di **kedua** tempat: panel admin ini *dan* Dashboard Midtrans.

### Perhatian saat menambah metode baru

Kolom `method` di tabel `payments` adalah **ENUM**, bukan string bebas:

```php
// 2026_07_14_081300_create_payments_table.php:15
$table->enum('method', ['virtual_account','bank_transfer','qris','ewallet','credit_card','paylater']);
```

Menambahkan metode dengan `code` di luar keenam nilai itu akan **lolos validasi Livewire tapi gagal saat `Payment::updateOrCreate()`** dengan error database. Kalau perlu metode baru, buat migration untuk mengubah ENUM tersebut lebih dulu (atau ubah kolomnya menjadi `string`).

Catatan: `bank_transfer` ada di ENUM tapi **tidak ada** di seeder — jadi enum dan tabel metode sudah sedikit tidak sinkron sejak awal.

---

## Setup Admin — Payments (Riwayat Transaksi)

**URL:** `/admin/payments` · **Controller:** [`Admin/PaymentController.php`](laravel/app/Http/Controllers/Admin/PaymentController.php)

Menyediakan `index` (DataTable), `create`, `edit` (Livewire modal), dan `destroy`.

Status yang mungkin: `pending`, `paid`, `failed`, `expired`, `refunded`.

> ⚠️ **Halaman ini hanya mengubah database lokal.** Menandai pembayaran `paid` secara manual **tidak** menarik dana, dan menghapus record **tidak** membatalkan transaksi di Midtrans. Perubahan manual juga bisa tertimpa oleh webhook yang datang belakangan. Gunakan untuk koreksi data, bukan sebagai alat operasional pembayaran.
>
> Perlu dicatat pula: route admin di-gate dengan `role:admin|host` ([`routes/web.php:41`](laravel/routes/web.php#L41)), sehingga **user berperan `host` juga dapat mengakses halaman pembayaran dan pengaturan Midtrans** — termasuk melihat Server Key di form Payment Settings. Pertimbangkan mempersempit gate untuk route pembayaran menjadi `role:admin` saja.

---

## Tutorial Setup dari Nol

### Langkah 1 — Dapatkan kredensial Midtrans

1. Daftar di <https://dashboard.midtrans.com> (mulai dari **Sandbox**).
2. **Settings → Access Keys**, salin **Server Key** dan **Client Key**.
3. Key sandbox berawalan `SB-Mid-server-…` / `SB-Mid-client-…`; key produksi tanpa `SB-`.

### Langkah 2 — Isi `.env`

```env
APP_URL=https://api.domain-anda.com

MIDTRANS_SERVER_KEY=SB-Mid-server-xxxxxxxxxxxxxxxxxxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxxxxxxxxxxxxxxxxxx
MIDTRANS_IS_PRODUCTION=false
```

```bash
php artisan config:clear
```

> `APP_URL` **wajib** domain publik ber-HTTPS. Nilai bawaan `http://localhost` membuat semua callback tidak bisa dijangkau Midtrans. Untuk pengembangan lokal, pakai tunnel (ngrok/Cloudflare Tunnel) dan isikan URL tunnel itu.
>
> Ingat juga: mengisi form di `/admin/payment-settings` **tidak** menggantikan langkah ini — lihat [bagian 7](#setup-admin--payment-settings).

### Langkah 3 — Pastikan SDK terpasang

```bash
composer install
composer show midtrans/midtrans-php   # harus tampil v2.6.x
```

### Langkah 4 — Migrasi & seeding

```bash
php artisan migrate
php artisan db:seed --class=PaymentMethodSeeder
php artisan db:seed --class=PaymentSettingSeeder
```

### Langkah 5 — Daftarkan URL di Dashboard Midtrans

Layar yang dimaksud berjudul **Setting URL endpoints**. Ia muncul dua kali:

- saat **onboarding** merchant baru (ada tombol **Back** / **Save & Next** di bawah), dan
- kapan saja setelahnya di **Settings → Configuration**.

Keenam field bertanda `*` sehingga form menolak disimpan bila ada yang kosong. Tapi **hanya empat yang benar-benar dipakai proyek ini** — dua sisanya milik fitur Midtrans yang tidak kita gunakan, dan tetap harus diisi hanya supaya tombol **Save & Next** bisa ditekan.

#### 5.1 Isian siap-tempel

Ganti `https://api.domain-anda.com` dengan domain publik Anda (wajib HTTPS — lihat [Langkah 2](#langkah-2--isi-env)), lalu tempel apa adanya sesuai urutan field di layar:

| # | Field di dashboard | Nilai yang diisi | Dipakai? |
|---|--------------------|------------------|----------|
| 1 | **Payment Notification URL** | `https://api.domain-anda.com/api/v1/payments/webhook` | ✅ **Ya — kritis** |
| 2 | **Recurring Notification URL** | `https://api.domain-anda.com/api/v1/payments/webhook` | ➖ Tidak — pengisi wajib |
| 3 | **Pay Account Notification URL** | `https://api.domain-anda.com/api/v1/payments/webhook` | ➖ Tidak — pengisi wajib |
| 4 | **Finish Redirect URL** | `https://api.domain-anda.com/payment/finish` | ✅ Ya |
| 5 | **Unfinish Redirect URL** | `https://api.domain-anda.com/payment/unfinish` | ✅ Ya |
| 6 | **Error Redirect URL** | `https://api.domain-anda.com/payment/error` | ✅ Ya |

Sebagai daftar polos untuk *find & replace*:

```
https://api.domain-anda.com/api/v1/payments/webhook
https://api.domain-anda.com/api/v1/payments/webhook
https://api.domain-anda.com/api/v1/payments/webhook
https://api.domain-anda.com/payment/finish
https://api.domain-anda.com/payment/unfinish
https://api.domain-anda.com/payment/error
```

#### 5.2 Dari mana keenam path itu berasal

Semua nilai di atas bukan karangan — tiap path punya route yang bisa diverifikasi:

| Path | Method | Route | Handler |
|------|--------|-------|---------|
| `/api/v1/payments/webhook` | `POST` | [`routes/api_mobile.php:53`](../../laravel/routes/api_mobile.php#L53) | `Api\PaymentController::webhook()` |
| `/payment/finish` | `GET` | [`routes/web.php:36`](../../laravel/routes/web.php#L36) | `Payment\FinishController::finish()` |
| `/payment/unfinish` | `GET` | [`routes/web.php:37`](../../laravel/routes/web.php#L37) | `Payment\UnfinishController::unfinish()` |
| `/payment/error` | `GET` | [`routes/web.php:38`](../../laravel/routes/web.php#L38) | `Payment\ErrorController::error()` |

Cek sendiri kalau ragu:

```bash
php artisan route:list --path=payment
```

> 🔴 **Kesalahan paling sering: prefix tertukar.**
> Webhook ada di bawah **`/api/v1/`** (didaftarkan di `routes/api_mobile.php`, dan Laravel menambahkan prefix `api` untuk seluruh file itu). Tiga redirect ada di **root**, tanpa `/api` (didaftarkan di `routes/web.php`).
> Menulis `…/payment/webhook` atau `…/api/v1/payment/finish` menghasilkan **404** — dan untuk webhook artinya **pembayaran tidak akan pernah ditandai lunas** meski uang sudah masuk.

#### 5.3 Field 1 — Payment Notification URL (satu-satunya yang memindahkan uang)

Ini **satu-satunya** jalur yang boleh mengubah status finansial, karena hanya inilah yang datang *server-to-server* dan membawa tanda tangan yang bisa diverifikasi.

Yang terjadi saat Midtrans memanggilnya ([`PaymentController::webhook()`](../../laravel/app/Http/Controllers/Api/PaymentController.php#L228-L278)):

1. Hitung `sha512(order_id + status_code + gross_amount + server_key)`, bandingkan dengan `signature_key` memakai `hash_equals()`. Tidak cocok → **403**.
2. Ambil `payment` dari `order_id` berformat `{order_code}-{payment_id}`. Tidak ada → **404**.
3. Bandingkan `gross_amount` dengan `payments.amount`. Beda → **422**.
4. Baru setelah itu status `payment → order → booking` dipindahkan, secara idempoten.

Konsekuensi praktis untuk setup:

- Endpoint ini **tidak boleh** dilindungi auth, Basic Auth, Cloudflare "Under Attack", atau IP whitelist. Midtrans memanggilnya sebagai pihak luar tanpa kredensial — signature-lah pengamannya.
- Endpoint ini juga **tidak** kena CSRF, karena berada di grup route `api`.
- Midtrans **mengirim ulang** notifikasi bila tidak menerima `200`. Karena itu jangan panik melihat notifikasi ganda di log — `applyTransactionStatus()` sudah idempoten ([`PaymentController.php:290`](../../laravel/app/Http/Controllers/Api/PaymentController.php#L290)).
- Tombol **See history** di bawah field ini adalah alat debug terbaik Anda: ia menampilkan tiap percobaan pengiriman beserta status HTTP yang dikembalikan server Anda. Kalau di sana terlihat `403`, berarti **Server Key di aplikasi ≠ Server Key merchant yang mengirim** (paling sering: sandbox vs produksi tertukar).

#### 5.4 Field 2 & 3 — Recurring & Pay Account Notification URL

Keduanya wajib diisi form, tapi proyek ini tidak memakai fitur yang memicunya:

| Field | Fitur pemicu | Status di proyek ini |
|-------|--------------|----------------------|
| **Recurring Notification URL** | Subscription / Recurring API (tagihan berulang otomatis) | Tidak dipakai — tidak ada satu pun panggilan ke Subscription API di `app/` |
| **Pay Account Notification URL** | GoPay Tokenization (menautkan akun GoPay ke merchant) | Tidak dipakai — Snap memakai GoPay sekali-bayar, bukan akun tertaut |

Karena tidak ada yang memicunya, **mengarahkan keduanya ke URL webhook yang sama aman**: Midtrans tidak akan pernah benar-benar mengirim apa pun ke sana. Ini pilihan paling sederhana dan tidak menambah kode.

Kalau suatu saat notifikasi itu benar-benar datang, tidak ada kerusakan yang terjadi — hanya berisik:

- Notifikasi **Pay Account** tidak punya `order_id` sama sekali → signature tak cocok → **403**, tercatat di log sebagai `signature mismatch`.
- Notifikasi **Recurring** membawa `order_id` milik subscription, bukan berformat `{order_code}-{payment_id}` → **403** atau **404**.

Dalam kedua kasus tidak ada status pembayaran yang berubah. Yang perlu diperhatikan: karena balasannya bukan `200`, **Midtrans akan mencoba ulang berkali-kali** dan log Anda ikut ramai.

> Jadi bila nanti Anda **memang** mengaktifkan Recurring atau GoPay Tokenization, jangan biarkan kedua field ini menunjuk ke webhook pembayaran. Buat endpoint sendiri yang menjawab `200` dan mencatat payload, lalu arahkan field-nya ke sana. Endpoint seperti itu **belum ada di repo** — perlu ditambahkan lebih dulu.

#### 5.5 Field 4, 5, 6 — Tiga Redirect URL

Ketiganya **bukan** callback server-to-server. Ini alamat yang **browser user** dikirimi setelah ia meninggalkan halaman pembayaran:

| Field | Kapan dipakai |
|-------|---------------|
| **Finish Redirect URL** | User menyelesaikan pembayaran |
| **Unfinish Redirect URL** | User menekan *"Back to Order Website"* / keluar sebelum selesai |
| **Error Redirect URL** | Terjadi error di sisi Midtrans |

Karena datang dari browser yang dikendalikan user, **ketiga controller sengaja tidak menulis apa pun** — tidak ke `payments`, tidak ke `orders`, tidak ke `bookings`. Isinya hanya dua baris: cari payment dari `order_id`, lalu lempar ke deep link aplikasi.

```php
// FinishController.php:23-28 — pola identik di Unfinish & Error
$payment = Payment::find(PaymentDeepLink::paymentIdFrom($request->query('order_id')));

return redirect()->away(PaymentDeepLink::for($payment));
```

Hasilnya adalah `302` dengan header:

```
Location: sewain://payment-result?paymentId=15&orderId=12
```

Perhatikan: deep link itu **tidak membawa status pembayaran**. Itu keputusan sadar ([`PaymentDeepLink.php:7-16`](../../laravel/app/Support/PaymentDeepLink.php#L7-L16)) — status hanya sah dari server, jadi aplikasi wajib menanyakannya sendiri lewat `GET /api/v1/payments/{payment}` setelah terbuka.

**Mengapa tidak langsung mengisi `sewain://…` di dashboard?**
Dashboard Midtrans hanya menerima URL berskema `http`/`https` — field-nya bahkan sudah ter-*prefill* `http://`. Skema kustom akan ditolak. Tiga route Laravel ini ada justru sebagai **jembatan**: Midtrans mengarahkan browser ke HTTPS, Laravel membalas `302` ke `sewain://`, OS menangkapnya dan membuka aplikasi.

> ⚠️ **Jangan mengisi ketiganya dengan domain telanjang** (mis. `https://ipanzipang.pro`). Form akan menerimanya, tapi user berakhir di landing page dan **tidak pernah kembali ke aplikasi** — persis gejala yang dilaporkan sebagai "setelah bayar, aplikasi tidak merespons". Path `/payment/finish`, `/payment/unfinish`, `/payment/error` wajib disertakan.

> ℹ️ Deep link `sewain://` hanya bekerja bila skemanya sudah terdaftar di Android/iOS. Itu pekerjaan sisi Flutter — lihat [K-3](#k-3--kritis-deep-link-tidak-terdaftar). Selama belum, browser akan menampilkan `ERR_UNKNOWN_URL_SCHEME` di titik ini. Status pembayaran tetap benar (webhook tidak terpengaruh), hanya perpindahan kembali ke aplikasi yang gagal.

#### 5.6 Tiga tempat yang mengatur redirect — dan mana yang menang

Nilai di **Settings → Configuration** bukan satu-satunya sumber. Urutan prioritas dari yang paling kuat:

1. **Per transaksi** — `callbacks` di dalam payload Snap. Kode ini mengirimkannya di setiap transaksi ([`MidtransSnap.php:129-133`](../../laravel/app/Support/MidtransSnap.php#L129-L133)):
   ```php
   'callbacks' => [
       'finish'   => url('/payment/finish'),
       'unfinish' => url('/payment/unfinish'),
       'error'    => url('/payment/error'),
   ],
   ```
2. **Settings → Snap Preferences** — sebagian versi dashboard punya field redirect tersendiri di sini, khusus Snap.
3. **Settings → Configuration** — nilai yang Anda isi di Langkah 5.1.

Snap secara resmi hanya menghormati **`finish`** di level transaksi; `unfinish` dan `error` diambil dari dashboard. Karena itu: **isi ketiganya di dashboard juga**, jangan mengandalkan payload saja. Bila field redirect muncul di Snap Preferences, isi dengan nilai yang sama supaya tidak ada dua kebenaran.

> 🔴 **Jebakan `url()` yang mudah terlewat.** `url()` membangun alamat dari **host request yang sedang berjalan**, bukan dari `APP_URL` (`APP_URL` hanya dipakai saat tidak ada request HTTP — CLI dan queue).
>
> Artinya: bila aplikasi Flutter memanggil API lewat `http://10.0.2.2:8000/api/v1/...`, maka `callbacks.finish` yang dikirim ke Midtrans menjadi `http://10.0.2.2:8000/payment/finish` — alamat yang **tidak bisa dijangkau siapa pun selain emulator itu**. User akan terjebak di halaman Midtrans setelah membayar.
>
> Karena itu, saat menguji alur bayar sungguhan, **aplikasi harus memanggil API melalui domain/tunnel publik yang sama** dengan yang Anda daftarkan di dashboard:
> ```bash
> flutter run --dart-define=API_BASE_URL=https://api.domain-anda.com/api/v1
> ```
>
> Terkait ini: [`app/Http/Middleware/TrustProxies.php`](../../laravel/app/Http/Middleware/TrustProxies.php) **ada di repo tapi tidak terdaftar** di `bootstrap/app.php`. Bila Laravel berjalan di belakang reverse proxy / load balancer yang mengakhiri TLS, `url()` akan menghasilkan `http://` alih-alih `https://`. Perbaikannya satu baris di `bootstrap/app.php`:
> ```php
> ->withMiddleware(function (Middleware $middleware): void {
>     $middleware->trustProxies(at: '*');
>     // …
> })
> ```

#### 5.7 Verifikasi sebelum menekan Save & Next

Uji keempat URL dari mesin **luar** (bukan dari server itu sendiri, agar sekalian membuktikan ia terjangkau publik):

```bash
BASE="https://api.domain-anda.com"

# 1. Webhook — harus 403 "Invalid signature."
#    403 di sini adalah HASIL YANG BENAR: route ada, dan signature diverifikasi.
curl -i -X POST "$BASE/api/v1/payments/webhook" \
  -H "Content-Type: application/json" -d '{}'

# 2-4. Redirect — harus 302 dengan Location: sewain://payment-result?...
curl -i "$BASE/payment/finish?order_id=ORD-TEST0000-0"
curl -i "$BASE/payment/unfinish?order_id=ORD-TEST0000-0"
curl -i "$BASE/payment/error?order_id=ORD-TEST0000-0"
```

Yang harus Anda lihat:

| Uji | Harapan | Kalau tidak sesuai |
|-----|---------|--------------------|
| Webhook | `403` + JSON `"Invalid signature."` | `404` → prefix `/api/v1/` salah · `405` → dipanggil `GET`, bukan `POST` · `419` → route salah taruh di `web.php` · `500` → cek `storage/logs/laravel.log` |
| Ketiga redirect | `302` + `Location: sewain://payment-result?paymentId=0&orderId=0` | `404` → path salah tulis · `302` ke `/login` → route tanpa sengaja masuk grup `auth` |

`paymentId=0` pada uji di atas memang wajar: `ORD-TEST0000-0` tidak merujuk payment yang ada, dan `PaymentDeepLink::for(null)` sengaja tetap menghasilkan link valid supaya aplikasi bisa menampilkan layar "pembayaran tidak ditemukan" ketimbang meninggalkan user di browser.

Setelah keempatnya lolos, isi form dan tekan **Save & Next**.

#### 5.8 Snap Preferences

Masih di **Settings**, buka **Snap Preferences** dan aktifkan **hanya** metode pembayaran yang Anda izinkan.

Ini tetap perlu meski kode sudah mengirim `enabled_payments` per transaksi ([`MidtransSnap::enabledPaymentsFor()`](../../laravel/app/Support/MidtransSnap.php#L158-L191)). Alasannya: `enabled_payments` hanya **mempersempit** dari apa yang aktif di dashboard, tidak bisa memperluasnya. Metode yang mati di Snap Preferences tetap mati walau dikirim di payload — dan sebaliknya, bila pemetaan channel untuk suatu metode tidak dikenali, fungsi itu mengembalikan `[]` sehingga Snap menampilkan **seluruh** metode yang aktif di dashboard. Dashboard adalah pagar terluarnya.

#### 5.9 Sandbox dan Produksi adalah dua dashboard terpisah

`dashboard.sandbox.midtrans.com` dan `dashboard.midtrans.com` **tidak berbagi konfigurasi apa pun**. Keenam URL di atas harus diisi **dua kali**, sekali di masing-masing dashboard — kelalaian ini adalah penyebab klasik "di sandbox jalan, begitu produksi webhook hilang". Lihat [Langkah 10](#langkah-10--naik-ke-produksi).

#### 5.10 Pengembangan lokal: pakai tunnel

Midtrans harus bisa menjangkau server Anda dari internet, jadi `http://localhost` tidak akan pernah bekerja. Pakai tunnel:

```bash
ngrok http 8000
# → Forwarding  https://a1b2-c3d4.ngrok-free.app -> http://localhost:8000
```

Lalu isi keenam field dengan host tunnel itu (`https://a1b2-c3d4.ngrok-free.app/api/v1/payments/webhook`, dst.).

Tiga hal yang perlu diingat saat memakai tunnel:

- **URL ngrok gratis berubah setiap kali di-restart** — setiap restart berarti mengisi ulang keenam field di dashboard. Cloudflare Tunnel dengan domain tetap menghindari kerepotan ini.
- Set `APP_URL` ke URL tunnel lalu `php artisan config:clear`, dan panggil API dari Flutter **melalui URL tunnel** — lihat jebakan `url()` di [5.6](#56-tiga-tempat-yang-mengatur-redirect--dan-mana-yang-menang).
- ngrok gratis menyisipkan halaman peringatan untuk kunjungan browser pertama. Ini tidak mengganggu webhook (POST JSON), tapi bisa menyela alur redirect di browser HP.

### Langkah 6 — Aktifkan metode di panel admin

Buka `/admin/payment-settings` → kartu **Metode Pembayaran** → Enable/Disable sesuai kebutuhan.

### Langkah 7 — Uji webhook

Dashboard Midtrans menyediakan tombol **Send Test Notification**. Atau manual:

```bash
ORDER_REF="ORD-TEST1234-1"
STATUS_CODE="200"
GROSS="100000"
SERVER_KEY="SB-Mid-server-xxxx"
SIG=$(printf "%s%s%s%s" "$ORDER_REF" "$STATUS_CODE" "$GROSS" "$SERVER_KEY" | sha512sum | cut -d' ' -f1)

curl -X POST https://api.domain-anda.com/api/v1/payments/webhook \
  -H "Content-Type: application/json" \
  -d "{\"order_id\":\"$ORDER_REF\",\"status_code\":\"$STATUS_CODE\",\"gross_amount\":\"$GROSS\",\"transaction_status\":\"settlement\",\"fraud_status\":\"accept\",\"transaction_id\":\"TXN-TEST\",\"signature_key\":\"$SIG\"}"
```

Harapan: `200` + status payment berubah `paid`. Bila `403`, `signature_key` atau Server Key tidak cocok.

### Langkah 8 — Uji alur aplikasi

Kartu kredit uji coba sandbox: `4811 1111 1111 1114`, CVV `123`, exp bebas di masa depan, OTP `112233`.

Alur: pilih properti → booking → pilih metode → **Bayar** → browser terbuka ke Snap → bayar → cek status di `/admin/payments`.

### Langkah 9 — Jalankan test

```bash
php artisan test --filter=PaymentControllerTest
```

### Langkah 10 — Naik ke Produksi

1. Ganti key dengan versi produksi (tanpa awalan `SB-`).
2. `MIDTRANS_IS_PRODUCTION=true`
3. `php artisan config:clear`
4. Perbarui keempat URL di Dashboard **produksi** (dashboard sandbox dan produksi terpisah).
5. **Selesaikan lebih dulu temuan [K-1](#k-1--kritis-forgery-status-pembayaran-lewat-finish-callback).** Jangan go-live tanpa itu.

---

## Temuan Kritis & Rekomendasi

### K-1 — 🔴 KRITIS: Forgery status pembayaran lewat finish callback

**Lokasi:** [`FinishController.php:11-41`](laravel/app/Http/Controllers/Payment/FinishController.php#L11-L41)

```php
$orderId = $request->query('order_id');
$transactionStatus = $request->query('transaction_status');   // ← dari URL, tidak diverifikasi
…
if ($payment && $payment->status === 'pending') {
    if (in_array($transactionStatus, ['capture', 'settlement'])) {
        $payment->update(['status' => 'paid', 'paid_at' => now(), …]);
        $payment->order?->update(['status' => 'processing']);
        $payment->order?->booking?->update(['status' => 'waiting_confirmation']);
    }
```

Route ini **publik tanpa autentikasi** (`routes/web.php:36`, di luar grup `auth`) dan nilai `transaction_status` diambil mentah dari query string **tanpa verifikasi signature apa pun**.

**Eksploitasi** — cukup satu request GET dari browser mana pun:

```
https://api.domain-anda.com/payment/finish?order_id=ORD-A1B2C3D4-15&transaction_status=settlement
```

Hasilnya: `payment.status = paid`, `order.status = processing`, `booking.status = waiting_confirmation`. **Pesanan menjadi lunas tanpa satu rupiah pun dibayarkan.** `payment_id` mudah ditebak karena berupa auto-increment, dan `order_code` diketahui user dari layar bookingnya sendiri.

`UnfinishController` dan `ErrorController` memiliki pola yang sama; keduanya hanya menulis `failed`, jadi dampaknya lebih ringan (sebatas gangguan), tapi akar masalahnya identik.

**Perbaikan:** ketiga controller ini **tidak boleh mengubah status finansial sama sekali**. Tugasnya hanya memindahkan user kembali ke aplikasi. Biarkan `webhook()` — yang sudah memverifikasi signature dengan benar — menjadi satu-satunya penulis status.

Bila diinginkan status yang langsung akurat saat user kembali, panggil `Transaction::status($orderId)` ke Midtrans di dalam controller (seperti `reconcile()`), **bukan** membaca query string. Lebih baik lagi: biarkan `PaymentResultScreen` di Flutter memanggil `GET /payments/{id}` setelah terbuka, sehingga status selalu datang dari sumber yang terverifikasi.

### K-2 — 🔴 KRITIS: Setting admin tidak terhubung ke kode pembayaran

Sudah diuraikan lengkap di [bagian Setup Admin](#setup-admin--payment-settings). Ringkasnya: admin menyimpan ke `payment_settings`, kode membaca dari `.env`. Verifikasi: `grep -rn "PaymentSetting" app/` hanya menemukan `Settings.php` dan modelnya.

**Perbaikan:** pilih Opsi A atau B di bagian 7. Sementara belum diperbaiki, **dokumentasikan ke tim bahwa kredensial hanya bisa diubah lewat `.env`**, agar tidak ada yang mengira sudah berganti key padahal belum.

### K-1 s.d. K-11 — ✅ Telah diperbaiki

Semua temuan kritis yang didokumentasikan di `remediation.md` sudah diperbaiki:

| ID | Temuan | Status |
|----|--------|--------|
| K-1 | FinishController mempercayai query string untuk mutasi status | ✅ T-1 |
| K-2 | Admin settings tidak dibaca oleh kode pembayaran | ✅ T-5 |
| K-3 | Deep link `sewain://` tidak terdaftar di Android/iOS | ✅ T-12 |
| K-4 | `enabled_payments` tidak dikirim ke Snap | ✅ T-6 |
| K-5 | Webhook tidak verifikasi `gross_amount` | ✅ T-2 |
| K-6 | Webhook tidak idempoten | ✅ T-3 |
| K-7 | `fraud_status = challenge` tidak ditangani | ✅ T-4 |
| K-8 | Format `expiry.start_time` invalid | ✅ T-8 |
| K-9 | Tidak ada auto-expire pembayaran | ✅ T-10 |
| K-10 | `reconcile` memakai GET padahal mutatif | ✅ T-11 |
| K-11 | Test menyesatkan | ✅ T-13 |

### K-12 — 🟠 TINGGI: Double-booking saat transisi confirmed → paid

**Lokasi:** `BookingController::store()` + `PaymentController::payUrl()`

Sebelum perbaikan: user membuat booking → bayar → webhook updating status ada jeda waktu. Di jeda itu, user lain bisa booking tanggal yang sama karena `bookings.status` belum berubah.

**Perbaikan yang diterapkan:**
- Overlap check dengan `lockForUpdate()` di `BookingController::store()` — blocking di database level
- Availability guard di `PaymentController::payUrl()` — cek overlap sebelum buat Snap transaction
- `restoreAvailability()` — restore `is_available = true` saat booking cancelled/expired

### K-13 — 🟡 SEDANG: Booking tanpa host confirmation bisa menahan ketersediaan selamanya

**Lokasi:** `BookingController::store()` + `CancelExpiredPayments`

Sebelum perbaikan: booking dibuat, user tidak bayar, tidak ada mekanisme auto-cancel. Properti tetap diblokir.

**Perbaikan yang diterapkan:**
- Auto-cancel past check-in bookings di `payments:cancel-expired`
- Host confirmation flow (`POST /bookings/{booking}/confirm`) — booking baru tidak bisa dibayar sebelum host konfirmasi
- Availability restored otomatis saat booking cancelled/expired

---

## Checklist Go-Live

**Wajib sebelum produksi**

- [ ] **K-1** — hapus mutasi status dari `FinishController` / `UnfinishController` / `ErrorController`
- [ ] **K-2** — satukan sumber kebenaran kredensial (DB **atau** `.env`, bukan keduanya)
- [ ] **K-3** — daftarkan skema deep link di Android + iOS, pasang listener di Flutter
- [ ] **K-5** — verifikasi `gross_amount` di webhook
- [ ] `APP_URL` diarahkan ke domain publik HTTPS
- [ ] Keempat URL terdaftar di Dashboard Midtrans **produksi**
- [ ] Webhook diuji end-to-end di produksi
- [ ] Gate `role:admin|host` pada route pembayaran ditinjau ulang

**Sangat disarankan**

- [ ] **K-4** — kirim `enabled_payments` sesuai metode pilihan
- [ ] **K-6** — jadikan webhook idempoten
- [ ] **K-7** — tangani `fraud_status = challenge`
- [ ] **K-8** — perbaiki format `expiry.start_time`
- [ ] **K-9** — job auto-expire pembayaran menggantung
- [ ] Ganti perangkaian `redirect_url` manual dengan `Snap::createTransaction()->redirect_url`
- [ ] Tambahkan `item_details`
- [ ] Log payload webhook untuk audit

**Peningkatan**

- [ ] **K-10** — `reconcile` menjadi `POST`
- [ ] **K-11** — perbaiki test yang menyesatkan
- [ ] Panggil `reconcile` dari `PaymentResultScreen` sebagai jaring pengaman
- [ ] Pertimbangkan Snap in-app WebView agar tidak bergantung pada deep link
- [ ] Selaraskan penamaan `sewain` vs `liviroom`
- [ ] Sinkronkan ENUM `payments.method` dengan isi tabel `payment_methods`

---

## Lampiran — Referensi Cepat

**Endpoint API**

```
GET    /api/v1/payments/methods                 [auth:sanctum]
POST   /api/v1/orders/{order}/pay               [auth:sanctum]   body: {"method":"qris"}
POST   /api/v1/orders/{order}/pay/retry         [auth:sanctum]
GET    /api/v1/payments/{payment}               [auth:sanctum]
POST   /api/v1/payments/{payment}/reconcile     [auth:sanctum]
POST   /api/v1/bookings/{booking}/confirm       [auth:sanctum]   [host only]
POST   /api/v1/bookings/{booking}/reject        [auth:sanctum]   [host only]
POST   /api/v1/payments/webhook                 [publik — signature SHA512]

GET    /payment/finish                          [publik]
GET    /payment/unfinish                        [publik]
GET    /payment/error                           [publik]
```

**Panel admin**

```
/admin/payments            riwayat transaksi
/admin/payment-methods     CRUD metode
/admin/payment-settings    konfigurasi Midtrans + toggle cepat
```

**Format `order_id` ke Midtrans**

```
{order_code}-{payment_id}      contoh: ORD-A1B2C3D4-15
```

Pembacaan balik memakai `strrpos($orderId, '-')`, sehingga hyphen di dalam `order_code` aman.

**Formula signature webhook**

```
sha512( order_id + status_code + gross_amount + server_key )
```

**Pemetaan status**

| Midtrans | `payment` | `order` | `booking` |
|----------|-----------|---------|-----------|
| `capture` / `settlement` + `accept` | `paid` | `processing` | `paid` |
| `deny` / `cancel` | `failed` | `cancelled` | `cancelled` |
| `expire` | `expired` | `cancelled` | `expired` |
| `pending` | `pending` | `pending` | `waiting_confirmation` |
| `capture` + `challenge` | `pending` (logged) | — | — |

**Catatan:** `booking` status `waiting_confirmation` → `confirmed` oleh host via `POST /bookings/{booking}/confirm`, lalu `paid` setelah webhook `settlement`. Host harus mengonfirmasi check-in via `POST /bookings/{booking}/checkin` dan `POST /bookings/{booking}/confirm-checkin` untuk mengubah status ke `staying`.

---

## Checklist Go-Live

**Wajib sebelum produksi**

- [x] **K-1** — hapus mutasi status dari `FinishController` / `UnfinishController` / `ErrorController`
- [x] **K-2** — satukan sumber kebenaran kredensial (DB **atau** `.env`, bukan keduanya)
- [x] **K-3** — daftarkan skema deep link di Android + iOS, pasang listener di Flutter
- [x] **K-4** — kirim `enabled_payments` ke Snap
- [x] **K-5** — verifikasi `gross_amount` di webhook
- [x] **K-6** — jadikan webhook idempoten
- [x] **K-7** — tangani `fraud_status = challenge`
- [x] **K-8** — perbaiki format `expiry.start_time`
- [x] **K-9** — jalankan `php artisan migrate` untuk T-14 (ENUM → VARCHAR)
- [x] **K-10** — ubah `reconcile` menjadi `POST`
- [x] **K-11** — perbaiki test menyesatkan
- [x] **T-16** — jalankan migration `add_host_confirmed_to_bookings_table.php`
- [x] **T-16** — test manual flow: booking → host confirm → bayar → webhook → status berubah
- [ ] Pastikan scheduler `payments:cancel-expired` berjalan di produksi
- [ ] Isi ulang keenam URL Midtrans di dashboard **produksi** (bukan sandbox)
- [ ] Uji satu transaksi kecil sungguhan sebelum diumumkan
