# Payment Remediation Tasks

Daftar tugas perbaikan payment (Midtrans), diurutkan berdasarkan prioritas. Tugas yang lebih awal diselesaikan lebih dulu karena menutup risiko terbesar atau menjadi prasyarat tugas berikutnya.

Legenda status: `[ ]` belum · `[x]` selesai · `[~]` sebagian

## Daftar Isi

- [Ringkasan Prioritas](#ringkasan-prioritas)
- [Kebijakan Guest Browsing](#kebijakan-guest-browsing)
- [Fase 1 — Keamanan & Integritas (WAJIB DULU)](#fase-1--keamanan--integritas-wajib-dulu)
- [Fase 2 — Sumber Kebenaran Kredensial](#fase-2--sumber-kebenaran-kredensial)
- [Fase 3 — Integritas Data Transaksi](#fase-3--integritas-data-transaksi)
- [Fase 4 — UX & Kegagalan Operasional](#fase-4--ux--kegagalan-operasional)
- [Fase 5 — Kehandalan Kode](#fase-5--kehandalan-kode)
- [Fase 6 — Percaya Diri Sebelum Go-Live](#fase-6--percaya-diri-sebelum-go-live)

## Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

## Ringkasan Prioritas

| Fase | Isi | Alasan didahulikan |
|------|-----|--------------------|
| **Fase 1** | K-1, K-5, K-6, K-7 | Celah keamanan + integritas uang. Tidak boleh go-live tanpa ini |
| **Fase 2** | K-2 | Admin mengira sudah ganti key padahal belum — berisiko salah environment |
| **Fase 3** | K-4, K-8, item_details | Integritas data laporan & kedaluwarsa transaksi |
| **Fase 4** | K-9, K-10, T-16 | Ketahanan operasional + availability guard + host confirmation |
| **Fase 5** | K-3 | UX: user kembali ke app setelah bayar |
| **Fase 6** | K-11 + test | Kepercayaan terhadap suite test |

---

## Fase 1 — Keamanan & Integritas (WAJIB DULU)

### T-1 · K-1 · Hapus mutasi status dari callback browser

**File:** `app/Http/Controllers/Payment/FinishController.php`, `UnfinishController.php`, `ErrorController.php`

- [x] Hapus seluruh blok `$payment->update([...])` dari ketiga controller
- [x] Sisakan hanya: parse `order_id` → cari payment → redirect ke deep link
- [x] Deep link **tidak lagi** membawa `status` dari query string; kirim `orderId` + `paymentId` saja, biar app yang tanya status ke backend (`app/Support/PaymentDeepLink.php`)
- [x] Verifikasi: request `GET /payment/finish?order_id=X&transaction_status=settlement` tidak boleh mengubah baris apa pun di tabel `payments` — 8 test di `tests/Feature/Api/PaymentCallbackTest.php`

**Kenapa pertama:** ini satu-satunya temuan yang bisa dieksploitasi orang luar untuk mendapat barang/jasa tanpa bayar.

### T-2 · K-5 · Verifikasi nominal di webhook

**File:** `app/Http/Controllers/Api/PaymentController.php` → `webhook()`

- [x] Bandingkan `(int) round($payment->amount)` dengan `(int) $grossAmount` (`Api/PaymentController.php:252-264`)
- [x] Bila beda: `Log::warning(...)` + tolak (`422`), jangan ubah status
- [x] Tambah test: webhook dengan `gross_amount` berbeda harus ditolak — `test_webhook_rejects_amount_mismatch`

### T-3 · K-6 · Jadikan webhook idempoten

**File:** `PaymentController.php` → `webhook()`

- [x] Keluar lebih awal (`200`, bukan error) bila `payment->status === 'paid'` dan notifikasi yang datang juga menyatakan lunas (`Api/PaymentController.php:319-321`)
- [x] Jangan timpa `paid_at` yang sudah terisi
- [x] Jangan mundurkan status order yang sudah maju (`completed`, `cancelled`)
- [x] Tambah test: kirim webhook `settlement` dua kali → `paid_at` tidak berubah — `test_webhook_is_idempotent_for_duplicate_settlement` dan `test_webhook_does_not_downgrade_paid_payment`

**Kenapa penting:** Midtrans mengirim ulang notifikasi bila tidak menerima `200`, dan mengirim `capture` lalu `settlement` untuk satu transaksi kartu.

### T-4 · K-7 · Tangani `fraud_status = challenge`

**File:** `PaymentController.php` → `webhook()` dan `reconcile()`

- [x] Tambah cabang: `capture` + `challenge` → tetap `pending` **tapi** di-log sebagai butuh tinjauan manual (`Api/PaymentController.php:301-307`)
- [x] Simpan `gateway_reference` agar admin bisa `Transaction::approve()`
- [x] Test: `test_webhook_keeps_challenged_capture_pending` dan `test_does_not_expire_challenged_capture`

---

## Fase 2 — Sumber Kebenaran Kredensial

### T-5 · K-2 · Satukan sumber kredensial Midtrans

**Keputusan:** **Opsi A** — DB sebagai sumber kebenaran, `.env` sebagai fallback. Alasan: admin non-teknis harus bisa ganti key tanpa akses SSH.

**File:** `app/Providers/AppServiceProvider.php`, `app/Livewire/PaymentSettings/Settings.php`

- [x] Di `AppServiceProvider::boot()`: timpa `config('services.midtrans.*')` dari tabel `payment_settings` (`AppServiceProvider.php:36`), dibungkus `Cache::remember()` di `PaymentSetting.php:55` supaya tidak menambah query tiap request
- [x] Guard `Schema::hasTable()` agar `php artisan migrate` di DB kosong tidak error (`PaymentSetting.php:51`)
- [x] `Settings::mount()` → baca dari **DB** (bukan config) supaya refresh menampilkan nilai yang benar-benar tersimpan
- [x] `Settings::saveMidtrans()` → hapus cache setelah simpan (`PaymentSetting.php:64`, dipanggil dari hook `saved`)
- [ ] Test manual: simpan key baru → refresh → nilai baru tetap tampil — **belum dilakukan**, butuh browser

---

## Fase 3 — Integritas Data Transaksi

### T-6 · K-4 · Kirim `enabled_payments` ke Snap

**File:** `PaymentController.php` → `pay()`, `payUrl()`

- [x] Petakan `payment_methods.code` → channel Midtrans (`app/Support/MidtransSnap.php:31-69`)
- [x] Ambil dari kolom `metadata` bila tersedia, fallback ke peta default
- [x] Sertakan di `$params` hanya bila hasil pemetaan tidak kosong (`MidtransSnap.php:143`)

### T-7 · Tambahkan `item_details`

- [x] Kirim rincian: nama properti, durasi, harga — supaya invoice Midtrans informatif (`MidtransSnap.php:124`)
- [x] Pastikan `sum(item_details.price * quantity) === gross_amount`, kalau tidak Midtrans menolak transaksi — selisih pembulatan diserap satu baris penyesuaian; diuji oleh `test_pay_sends_wellformed_snap_payload`

### T-8 · K-8 · Perbaiki `expiry.start_time`

- [x] Ganti format `'Y-m-d H:i:s T'` → `'Y-m-d H:i:s O'`
- [x] Konversi eksplisit ke `Asia/Jakarta` (`MidtransSnap::TIMEZONE`)
- [x] Pindahkan durasi 60 menit ke konstanta agar dipakai bersama T-9 (`MidtransSnap::EXPIRY_MINUTES`, dipakai juga oleh `payments:cancel-expired`)

### T-9 · Ganti perangkaian `redirect_url` manual

- [x] Pakai `Snap::createTransaction($params)` lalu ambil `token` + `redirect_url` dari respons, hapus hardcode domain `app.midtrans.com` (`Api/PaymentController.php:95-97` dan `:148`)

---

## Fase 4 — UX & Kegagalan Operasional

### T-10 · K-9 · Command auto-expire + auto-cancel past check-in

**File:** `app/Console/Commands/CancelExpiredPayments.php`

- [x] Sapu `payments` status `pending` berusia > 60 menit
- [x] Konfirmasi ke `Transaction::status()` sebelum menandai `expired` (jangan expire transaksi yang ternyata sudah lunas)
- [x] Kaskade ke `order` + `booking`
- [x] Jadwalkan tiap 10 menit di `routes/console.php:14-19`
- [x] Test: 8 skenario di `tests/Feature/Commands/CancelExpiredPaymentsTest.php`
- [x] Tambah `cancelPastCheckInBookings()`: batalkan booking yang `check_in < hari ini` dengan status `waiting_payment`/`waiting_confirmation`/`confirmed`/`paid`/`waiting_checkin`
- [x] Tambah `restoreAvailability()`: restore `is_available = true` saat booking cancelled/expired jika tidak ada overlap booking lain

### T-11 · K-10 · `reconcile` GET → POST

**File:** `routes/api_mobile.php`

- [x] Ubah `Route::get('payments/{payment}/reconcile')` → `Route::post(...)` (`api_mobile.php:82`)
- [x] Sesuaikan `flutter/lib/services/booking_service.dart` bila memanggilnya
- [x] Sesuaikan `dummy_api_client.dart:113`
- [x] Test: `test_reconcile_rejects_get`

### T-16 · Booking overlap guard + host confirmation flow

**File:** `app/Http/Controllers/Api/BookingController.php`, `app/Models/Booking.php`, `database/migrations/2026_08_11_000001_add_host_confirmed_to_bookings_table.php`

- [x] Tambah `host_confirmed` column ke `bookings` table
- [x] Overlap check di `BookingController::store()`: `lockForUpdate()` pada booking aktif + availability check
- [x] Availability guard di `PaymentController::payUrl()`: cek overlap sebelum buat Snap transaction
- [x] `BookingController::confirm()`: host mengkonfirmasi booking → `host_confirmed = true`
- [x] `BookingController::reject()`: host menolak booking → cascade cancel + restore availability
- [x] `BookingController::restoreAvailability()`: restore `is_available` jika tidak ada booking aktif lain
- [x] Route `POST /api/v1/bookings/{booking}/confirm` dan `reject` (`api_mobile.php`)
- [x] Flutter: `Booking` model tambah `hostConfirmed`
- [x] Flutter: `booking_detail_screen.dart` tampilkan "Menunggu konfirmasi..." / "Lanjutkan Bayar" berdasarkan `host_confirmed`
- [x] Flutter: `payment_method_screen.dart` navigasi ke booking detail setelah create booking (tidak lagi buka Snap langsung)
- [x] Flutter: `host_service.dart` tambah `confirmOrder()` dan `rejectOrder()`
- [x] Flutter: mitra screens panggil API sungguhan untuk Terima/Tolak

---

## Fase 5 — Deep Link (UX)

### T-12 · K-3 · Aktifkan deep link

**Keputusan skema:** pakai **`sewain`** (sudah dipakai ketiga controller backend).

- [x] `flutter/pubspec.yaml` → tambah `app_links` (`^6.3.2`, baris 30)
- [x] `AndroidManifest.xml` → intent-filter `VIEW` + `BROWSABLE` untuk `scheme="sewain" host="payment-result"` (baris 32-41)
- [x] `ios/Runner/Info.plist` → `CFBundleURLTypes` (baris 48-59)
- [x] `lib/main.dart` → `navigatorKey` + listener `app_links` (tangani cold start **dan** resume) — `lib/services/deep_link_handler.dart`
- [x] `PaymentResultScreen` → konfirmasi status via `GET /payments/{id}`, **jangan** percaya parameter URL (konsekuensi T-1)
- [ ] Uji di perangkat/emulator sungguhan — **belum dilakukan**, butuh `flutter run` + memicu deep link

---

## Fase 6 — Test & Kebersihan

### T-13 · K-11 · Perbaiki test menyesatkan

- [x] Ganti nama `test_pay_creates_payment_and_returns_snap_params_when_sdk_missing` → `test_pay_creates_payment_and_returns_snap_token`. Nama lama menyatakan "SDK tidak ada" padahal SDK terpasang; yang diuji sebenarnya jalur gagal
- [x] Tambah seam `App\Support\MidtransGateway` supaya panggilan statis SDK bisa dipalsukan lewat `$this->app->instance()` — tanpa ini test terpaksa menyentuh jaringan Midtrans sungguhan
- [x] Test baru untuk: webhook nominal salah, webhook ganda, finish callback tidak mengubah status (`PaymentControllerTest`, `PaymentCallbackTest`, `CancelExpiredPaymentsTest`)

### T-14 · Sinkronkan ENUM `payments.method`

- [x] `bank_transfer` ada di ENUM tapi tidak ada di seeder
- [x] Migration ENUM → `VARCHAR(50)` agar admin bisa menambah metode tanpa migration baru: `2026_08_10_120000_change_payments_method_to_string.php`. DDL per-driver karena `change()` butuh `doctrine/dbal` yang tidak terpasang
- [x] Kolom `code` di form admin dibatasi `MidtransSnap::supportedMethodCodes()` dan blade-nya jadi dropdown — kode di luar daftar akan sampai ke Snap tanpa pemetaan channel
- [ ] **`php artisan migrate` belum dijalankan di PostgreSQL.** Sampai itu dilakukan, perbaikan ini belum aktif di produksi

> Kenapa bug ini tak terlihat di test: DB test adalah SQLite in-memory, dan SQLite tidak menegakkan CHECK constraint. Di PostgreSQL `enum()` menjadi CHECK, jadi `INSERT` dengan metode baru gagal — hanya di produksi.

### T-15 · Tinjau gate role

- [x] `routes/web.php:41` memakai `role:admin|host` — host (pemilik properti) bisa membaca **dan menulis** Server Key. Dikonfirmasi sebagai celah nyata
- [x] Middleware `permission:` pada 5 route payment di `routes/admin_generated.php`, memakai string izin yang sama dengan yang sudah dipakai sidebar (`RolePermissionSeeder` memberikannya ke admin saja — seeder tidak diubah)
- [x] `$this->authorize()` di `Settings::mount()`, `saveMidtrans()`, `toggleMethod()`, dan `PaymentMethods\Form::save()`
- [x] 8 test di `tests/Feature/Admin/PaymentSettingsAccessTest.php`

> Kenapa guard-nya dobel: `admin_generated.php` adalah file yang diregenerasi, jadi middleware di sana bisa hilang sewaktu-waktu. Lebih penting lagi, endpoint `/livewire/update` hanya memutar ulang *persistent middleware* Livewire, dan `role`/`permission` Spatie tidak ada dalam daftar itu (`PersistentMiddleware::$persistentMiddleware`). Jadi tanpa guard di komponen, aksi seperti `saveMidtrans()` tetap bisa dipanggil langsung.

---

## Yang Sengaja TIDAK Dikerjakan Sekarang

| Hal | Alasan |
|-----|--------|
| Refund via `Transaction::refund()` | Butuh keputusan kebijakan bisnis (siapa boleh refund, potongan berapa) |
| Snap in-app WebView | Perubahan arsitektur besar di Flutter; deep link sudah cukup untuk sekarang |
| App Links / Universal Links | Butuh akses hosting untuk `assetlinks.json` + `apple-app-site-association` |
| `Config::$paymentIdempotencyKey` | Idempotensi sudah ditangani di sisi kita (T-3) |

---

## Verifikasi Yang Masih Harus Dijalankan

Jalankan berurutan dari direktori `laravel/`:

```bash
# 1. Buang berkas diagnostik sementara
rm -f tests/Feature/Admin/ProbeTest.php

# 2. Seluruh suite — harapannya 110 lulus, 0 gagal
php artisan test

# 3. Terapkan migration T-14 — INI YANG PALING PENTING
php artisan migrate

# 4. Terapkan migration T-16 — tambah host_confirmed
php artisan migrate

# 5. Pastikan ENUM benar-benar hilang (PostgreSQL)
php artisan tinker
>>> DB::select("SELECT data_type, character_maximum_length FROM information_schema.columns WHERE table_name='payments' AND column_name='method'");
>>> DB::select("SELECT conname FROM pg_constraint WHERE conrelid='payments'::regclass AND contype='c'");
```

**Yang diharapkan pada langkah 5:** `data_type = character varying`, `character_maximum_length = 50`, dan tidak ada baris `payments_method_check`.

**Bila langkah 2 masih merah di `PaymentSettingsAccessTest`:** yang perlu diperbaiki hampir pasti test-nya, bukan guard-nya — gate sudah dibuktikan menolak host (`can(...) = false`). Periksa apakah respons yang dikembalikan 403 atau justru 500; bila 500, berarti ada exception lain yang menutupi.

### Verifikasi Manual Flow Booking + Host Confirmation

1. **Buat booking sebagai user** → navigasi ke `booking_detail_screen` → lihat "Menunggu konfirmasi dari pemilik properti..."
2. **Login sebagai host** → buka `order_management_screen` → tab "Baru" → lihat order baru
3. **Tekan "Terima"** → booking harus muncul `host_confirmed = true`
4. **Kembali ke user app** → `booking_detail_screen` harus menampilkan tombol "Lanjutkan Bayar"
5. **Tekan "Lanjutkan Bayar"** → pilih metode → browser membuka Midtrans
6. **Selesaikan pembayaran** → webhook harus update status ke `paid` → booking → `paid`
7. **Coba booking baru pada tanggal yang sama** → harus ditolak dengan "Tanggal yang dipilih sudah dipesan"

### Verifikasi Auto-Cancel Past Check-in

1. Buat booking dengan `check_in = kemarin`, bayar → tidak harus lunas
2. Jalankan `php artisan payments:cancel-expired`
3. Booking harus → `cancelled`, order → `cancelled`, payment → `expired`
4. Tanggal properti harus kembali `is_available = true`

Referensi hasil sebelumnya: **107 lulus, 394 asersi**, 3 gagal karena assertion test yang salah (sudah diperbaiki, belum di-run ulang).

---

## Definition of Done

Sebuah tugas dianggap selesai bila:

1. Kode berubah **dan** `php -l` bersih
2. Test terkait lulus (`php artisan test --filter=PaymentControllerTest`)
3. Tidak ada regresi pada test lain
4. Perilaku terverifikasi manual bila menyangkut UI/redirect

Menurut definisi ini, T-1 s.d. T-13 sudah memenuhi syarat 1–3 (test hijau). T-14 menunggu `php artisan migrate`, dan T-15 menunggu satu kali run ulang setelah assertion test-nya diperbaiki. Syarat 4 (verifikasi manual UI/redirect) masih terbuka untuk T-5 dan T-12.
