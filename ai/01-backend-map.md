# Backend Map — Laravel 12

> **Fungsi file ini.** Peta lengkap `laravel/` untuk AI: layer, inventaris,
> domain, state machine, pembayaran, admin panel, job, permission. Dibaca
> sebagai ganti menjelajah `app/` secara buta.
>
> **Diverifikasi dari kode pada 2026-08-20.** Angka dihitung langsung.
>
> Untuk domain properti/hotel yang mendalam, dokumen ini **menunjuk** ke
> `docs/domain/hotel-vs-property.md` — itu master-nya, jangan digandakan di sini.

---

## 1. Dua muka, satu aplikasi

| Muka | Entry | Auth | Response |
|---|---|---|---|
| **REST API mobile** | `routes/api_mobile.php`, prefix `api/v1` | `auth:sanctum` (Bearer token) | JSON amplop `ApiResponse` |
| **Admin Panel** | `routes/web.php` → `routes/admin_generated.php`, prefix `admin` | session + `role:admin\|host` | Blade (Metronic) + Livewire 4 + Yajra DataTables |
| Website publik | `routes/web.php` → `Front/FrontController` | — | Blade |
| Callback browser Midtrans | `routes/web.php` → `Payment/{Finish,Unfinish,Error}Controller` | — | redirect ke deep link |

`routes/api.php` **hanya** `require api_mobile.php`. Jangan menambah endpoint di sana.

---

## 2. Stack terpasang

```
laravel/framework      ^12
livewire/livewire      ^4.3      ← Livewire 4, BUKAN 3
laravel/sanctum        ^4.3
spatie/laravel-permission ^6.9
yajra/laravel-datatables-* ^12
midtrans/midtrans-php  ^2.6
barryvdh/laravel-dompdf
```

Build aset: **Vite** (`vite.config.js`). `webpack.mix.js` legacy — jangan dipakai.
DB: **PostgreSQL** (`pgsql`). CHECK constraint dipakai untuk enum status — ini
penting karena PostgreSQL menegakkannya (SQLite tidak).

---

## 3. Inventaris — angka aktual per 2026-08-20

| Direktori | Jumlah | Catatan |
|---|---|---|
| `app/Models/` | **74** | bukan 33 seperti klaim lama di `laravel/CLAUDE.md` |
| `database/migrations/` | **97** | |
| `app/Http/Controllers/Api/` | **20** | |
| `app/Http/Controllers/Admin/` | **33** | thin — mayoritas hanya `index()` render DataTable |
| `app/Http/Controllers/Payment/` | 3 | Finish / Unfinish / Error |
| `app/Http/Controllers/Front/` | 1 | `FrontController` |
| `app/Livewire/` | **30** folder | semua add/edit/delete admin |
| `app/DataTables/` | **27** | Yajra |
| `app/Http/Resources/` | **9** + `Concerns/` | sedang direfaktor — lihat domain doc §8 |
| `app/Services/` | 4 | `Breadcrumbs`, `ConditionEvaluator`, `RecommendationService`, `RemoteConfigService` |
| `app/Support/` | 5 | `ApiResponse`, `HotelNormalizer`, `MidtransGateway`, `MidtransSnap`, `PaymentDeepLink` |
| `app/Jobs/` | 4 | `CancelExpiredBookingsJob`, `ExtendHotelInventoriesJob`, `IssueInsurancePolicyJob`, `SyncInsuranceStatusJob` |
| `app/Observers/` | 3 | `UserObserver`, `BookingObserver`, `RoomTypeObserver` |
| `app/Enums/` | 1 | `PoiCategory` |
| `app/Console/Commands/` | 1 | `CancelExpiredPayments` |
| `app/Policies/` | **0** | tidak ada policy — otorisasi manual di controller/Livewire |
| `database/seeders/` | 65 | `DatabaseSeeder` + 64 |
| endpoint `api/v1` | **84** | 21 publik + 63 `auth:sanctum` |

---

## 4. Layer & aliran kontrol

```
API mobile:
  routes/api_mobile.php
    → app/Http/Controllers/Api/*Controller
      → Eloquent Model (query langsung, tanpa repository)
      → app/Http/Resources/*Resource         (transformasi output)
      → app/Support/ApiResponse::success()   (amplop)

Admin panel:
  routes/admin_generated.php
    → app/Http/Controllers/Admin/*Controller   (thin: index → DataTable)
      → app/DataTables/*DataTable              (listing, server-side)
    → app/Livewire/{Module}/{Form,Modal}       (add / edit / delete)
      → Eloquent Model
```

**Tidak ada** service layer di jalur API — controller memanggil Eloquent langsung.
`app/Services/` hanya untuk 4 hal khusus (rekomendasi, remote config, breadcrumb,
evaluasi kondisi), bukan pola umum.

---

## 5. Amplop API — kontrak wajib

`app/Support/ApiResponse.php`. Satu bentuk untuk **semua** endpoint, sukses
maupun gagal:

```json
{
  "status":  true,        // bool — SATU-SATUNYA cabang klien. BUKAN "success"
  "code":    200,         // mirror HTTP status; ada di body karena dummy client tak punya layer HTTP
  "message": "Berhasil.", // selalu human-readable, selalu Indonesia
  "data":    null,        // payload, tidak pernah dibungkus dua kali
  "meta":    null,        // pagination / counter
  "errors":  null         // { field: [pesan] } pada 422
}
```

Saat gagal ada tambahan `"error_code"`. Nilainya snake_case huruf kecil —
konstanta `ApiResponse::ERR_*` (`ApiResponse.php:40-49`):

`validation_error` · `unauthenticated` · `forbidden` · `not_found` ·
`method_not_allowed` · `conflict` · `unprocessable` · `rate_limited` ·
`server_error` · `gateway_error` · `bad_request` (fallback)

**Aturan:**
- Pagination: `data` tetap array datar, counter pindah ke `meta`
  (`current_page`, `last_page`, `per_page`, `total`, `from`, `to`, `has_more`).
  Klien tidak pernah membongkar `data.data`. → `ApiResponse::paginated()`.
- `ApiResponse::fromException()` di-wire global di `bootstrap/app.php`, jadi
  exception liar tidak bisa lolos sebagai HTML. Peta exception → status:
  `ValidationException`→422, `AuthenticationException`→401,
  `AuthorizationException`→403, `ModelNotFoundException`→404,
  `QueryException`→500.
- Middleware `ForceJsonResponse` memastikan request API selalu dapat JSON.

---

## 6. Domain — properti vs hotel

🔴 **Master: `docs/domain/hotel-vs-property.md`. Baca itu untuk tugas apa pun
yang menyentuh properti, hotel, kamar, stok, atau pencarian.** Yang di bawah ini
hanya cukup untuk mengorientasikan diri.

Satu tabel induk `properties` menampung semua listing. Diskriminatornya
**`properties.booking_mode`**:

| `booking_mode` | Arti | Stok |
|---|---|---|
| `'unit'` (default) | sewa seluruh hunian satu periode | tidak ada booking bentrok + tabel `availabilities` |
| `'room'` | sewa per kamar (hotel/OTA) | counter harian `room_inventories.allotment - booked_count` |

`hotels` adalah **ekstensi 1:1** dari `properties` (`property_id` UNIQUE,
cascade) — bukan entitas paralel. Hotel tidak punya nama/alamat sendiri.

`property_type` (`apartment` · `house` · `villa` · `hotel_residence` ·
`guest_house` · `exclusive_kost` · `hotel`) mendeskripsikan **bangunan**;
`booking_mode` mendeskripsikan **cara stok dijual**. Jangan pernah menyimpulkan
satu dari yang lain.

Cermin transaksinya: `bookings.booking_type` (`'unit'` | `'room'`), wajib
konsisten dengan `booking_mode` properti induk.

---

## 7. State machine — status booking, order, payment

Sumber kebenaran = CHECK constraint PostgreSQL, bukan enum PHP (tidak ada
enum class untuk status).

### `bookings.status` — 9 nilai
`2026_08_12_000001_update_booking_status_enum.php:12`

```
waiting_payment · waiting_confirmation · confirmed · paid ·
waiting_checkin · staying · completed · cancelled · expired
```

### `orders.status` — 6 nilai
`2026_08_12_000002_update_orders_status_enum.php:12`

```
pending · processing · confirmed · completed · cancelled · refunded
```

### `payments.status` — 5 nilai
`2026_07_14_081300_create_payments_table.php:16`

```
pending · paid · failed · expired · refunded
```

`payments.method` awalnya enum, **diubah jadi string** oleh
`2026_08_10_120000_change_payments_method_to_string.php`. Nilai awal:
`virtual_account`, `bank_transfer`, `qris`, `ewallet`, `credit_card`, `paylater`.

### ⚠️ Asimetri kritis: dua checkout, dua status awal berbeda

| | Booking hotel (`booking-hotels`) | Booking unit (`booking-property`) |
|---|---|---|
| status awal | **`waiting_payment`** | **`waiting_confirmation`** |
| `host_confirmed` | **`true`** (auto-confirm) | `false` — host harus konfirmasi dulu |
| bisa langsung bayar? | **ya** | tidak — tunggu `POST bookings/{id}/confirm` |
| kode | `BookingController.php:563,567` | `BookingController.php:783` |

Keduanya membuat `Order` dengan `status = 'pending'`
(`BookingController.php:586` & `:801`).

### Transisi yang ada di kode

| Aksi | Efek | Lokasi |
|---|---|---|
| `POST bookings/{id}/cancel` | booking + order → `cancelled` | `BookingController.php:827-828` |
| `POST bookings/{id}/confirm` (host) | booking + order → `confirmed` | `:842-843` |
| `POST bookings/{id}/reject` (host) | booking + order → `cancelled` | `:894-895` |
| `POST bookings/{id}/checkin` | booking → `waiting_checkin` | `:860` |
| `POST bookings/{id}/confirm-checkin` | booking → `staying` | `:877` |
| webhook `settlement`/`capture`+`accept` | payment→`paid`, order→`processing`, booking→`paid` | `PaymentController.php:354,362,366` |
| webhook `deny`/`cancel`/`expire` | payment→`failed`/`expired`, order→`cancelled`, booking→`cancelled`/`expired` | `:392-399` |
| webhook `capture`+`challenge` | **tetap `pending`** — dana ditahan, bukan ditangkap | `:331,335` |

`completed` dan `refunded` **tidak** di-set oleh jalur API mobile — hanya dari
admin panel atau job refund.

---

## 8. Pembayaran (Midtrans) — aturan keras

### Pembagian tanggung jawab

| Jalur | Boleh ubah status? | Kenapa |
|---|---|---|
| **Webhook S2S** `POST api/v1/payments/webhook` | ✅ **hanya ini** | satu-satunya input yang punya signature terverifikasi |
| Callback browser `/payment/{finish,unfinish,error}` | ❌ **tidak boleh sama sekali** | hanya parse `order_id` → redirect deep link |
| `POST payments/{payment}/reconcile` | ✅ (tarik status dari Midtrans) | dipicu klien saat webhook telat |

### Urutan validasi webhook — `PaymentController::webhook()` (`:258`)

1. **Signature** — `hash_equals` terhadap SHA-512 `order_id+status_code+gross_amount+serverKey` (`:269`). Gagal → 403 `forbidden`.
2. **Nominal** — `gross_amount` vs `payment->amount`. Signature valid hanya membuktikan pengirimnya Midtrans, bukan nominalnya benar (`:280`).
3. **Idempoten** — settlement kedua tidak menimpa `paid_at` (`:349`).
4. **Out-of-order** — kegagalan yang datang setelah settlement diabaikan (`:379`).
5. **Fraud challenge** — `capture` + `challenge` → biarkan `pending` (`:331`).

### Kredensial

**DB (`payment_settings`) adalah sumber kebenaran**, `.env` fallback.
Di-override di `AppServiceProvider::boot()` via
`PaymentSetting::applyMidtransConfig()` (`AppServiceProvider.php:38`), di-cache
— **hapus cache setelah menyimpan setting**, kalau tidak key lama masih dipakai.

### Seam test

Snap dibangun di `app/Support/MidtransSnap.php`. Controller memanggil lewat
`app/Support/MidtransGateway` yang di-inject di constructor
(`PaymentController.php:31`) — **jangan panggil SDK statis Midtrans langsung
dari controller**, itu memutus seam.

### Deep link

`app/Support/PaymentDeepLink.php`. Scheme `livirooms`, host `payment-result`
(`PaymentDeepLink.php:20`). Bentuk: `livirooms://payment-result?paymentId=..&orderId=..`.
**Backend sengaja tidak mengirim status di URL** — klien wajib konfirmasi via
`GET payments/{id}`.

`PaymentDeepLink::paymentIdFrom($orderRef)` membongkar `order_id` Midtrans
(format `{orderCode}-{paymentId}`) untuk menemukan payment-nya (`:30`).

### Sapu bersih

`php artisan payments:cancel-expired` — payment `pending` > 60 menit.
Terjadwal tiap 10 menit (`routes/console.php:17`).

---

## 9. Job & scheduler

Semua jadwal ada di **`routes/console.php`**, bukan `app/Console/Kernel.php`
(Laravel 12 tidak memuat Kernel — method `schedule()` di sana tidak akan
pernah jalan).

| Job / command | Jadwal | Fungsi | Lokasi jadwal |
|---|---|---|---|
| `payments:cancel-expired` | tiap 10 menit | payment pending > 60 menit | `console.php:17` |
| `CancelExpiredBookingsJob` | tiap 5 menit | batalkan booking **hotel** belum bayar (expiry 30 menit), lepas `booked_count` | `console.php:25` |
| `ExtendHotelInventoriesJob` | harian 00:00 | perpanjang jendela `room_inventories` 30 hari berjalan | `console.php:33` |
| `SyncInsuranceStatusJob` | tiap jam | sinkron status polis dengan provider | `console.php:41` |
| `IssueInsurancePolicyJob` | on-demand (dispatch) | terbitkan polis Stay Protection | — |

Semua pakai `->withoutOverlapping()` + `->onFailure(Log::error)`.

### Observer

| Observer | Hook | Guna |
|---|---|---|
| `UserObserver` | created, updated, deleted | — |
| `BookingObserver` | created, updated, deleted | sinkron efek samping booking |
| `RoomTypeObserver` | created | jaminan `room_inventories` langsung ada untuk tipe kamar baru |

Terdaftar di `AppServiceProvider::boot()` (`:46-48`).

---

## 10. Auth & permission

### API mobile
Sanctum Bearer token. `POST auth/login` / `auth/register` → token.
Route publik vs terproteksi dipisah grup di `api_mobile.php:36` (publik) dan
`:67` (`auth:sanctum`).

Peran host di API tidak dijaga middleware — dijaga per-method, mis.
`BookingController::authorizeHost()` (`:904`).

### Admin panel
Spatie Permission. Role dibuat di `RolePermissionSeeder`:

| Role | Cakupan |
|---|---|
| `admin` | semua permission modul |
| `host` | `view *` untuk modul miliknya + daftar read tambahan (`RolePermissionSeeder:82-98`) |
| `consumer` | dibuat, tanpa permission admin |

### ⚠️ Dua jebakan otorisasi

1. **Grup admin di `web.php:41` memakai `role:admin|host`** — jadi **host juga
   masuk** ke seluruh `/admin/*`. Setiap halaman khusus admin **wajib punya gate
   sendiri**; jangan andalkan grup route.

2. **Endpoint `/livewire/update` hanya memutar ulang *persistent middleware*
   Livewire — `role`/`permission` Spatie TIDAK termasuk.** Jadi setiap aksi
   Livewire sensitif wajib `$this->authorize()` **di dalam komponen**, bukan
   cuma middleware di route. Ditambah lagi `admin_generated.php` bisa
   diregenerasi dan menghilangkan middleware-nya.

**Tidak ada `app/Policies/`.** Otorisasi seluruhnya manual di controller/Livewire.

---

## 11. Admin panel

Detail pola: **`docs/configuration/admin-panel.md`** (Pattern A/B/C/D).
Markup Blade standar: **`docs/configuration/ui-patterns.md`**.
Referensi kanonik di kode: `resources/views/admin/user-management/`.

### Modul admin utuh butuh 9 hal — lewat satu, halaman error / tombol mati

1. `database/migrations/*_create_{table}_table.php`
2. `app/Models/{Model}.php`
3. `app/DataTables/{Model}DataTable.php`
4. `app/Http/Controllers/Admin/{Model}Controller.php` (thin: `index()`)
5. `app/Livewire/{Module}/Form.php` + `{Module}Modal.php` ← **Pattern D**
6. `resources/views/admin/{table}/index.blade.php` + `columns/_actions.blade.php`
7. `resources/views/livewire/{table}/form.blade.php`
8. Route di `admin_generated.php` (via scaffold) + entri `routes/breadcrumbs.php`
9. Permission di `RolePermissionSeeder` + item sidebar

Pakai `/new-module <Nama>` supaya lengkap.

### Modul yang ada (dari nama route `admin_generated.php`)

`cities` · `properties` · `property-search-logs` · `bookings` (+`show`,
`invoice`) · `availabilities` · `property-prices` · `vouchers` ·
`property-recommendations` · `conversations` · `faqs` · `notification-logs` ·
`user-profiles` · `orders` · `payments` · `payment-methods` ·
`payment-settings` · `withdrawals` · `reviews` · `wishlists` · `referrals` ·
`banners` · `cms-pages` · `roles` (+`sync-permissions`) · `audit-logs` ·
`reports` (booking/revenue/withdrawal/property-performance/export) ·
`remote-config` · `setting` · `user-management` · `user-validation` ·
`dashboard-admin` · `dashboard-host`

### ⚠️ Hotel bukan modul admin mandiri

**Tidak ada** `Admin/HotelController`, `HotelDataTable`, atau route admin hotel.
CRUD hotel diakses dari **dalam halaman properti** lewat tombol "Hotel Wizard"
(`resources/views/admin/properties/index.blade.php:39`) dan komponen
`<livewire:hotels.hotel-wizard-modal>` (`:67`).

**`app/Livewire/Hotels/Form.php:140` adalah baris yang membalik
`properties.booking_mode` menjadi `'room'`.** Hotel yang dibuat tanpa itu tidak
akan pernah muncul di pencarian.

---

## 12. Fitur lain — di mana kodenya

| Fitur | Controller API | Model utama | Docs |
|---|---|---|---|
| Referral | `ReferralController` | `Referral` | `docs/features/referral.md` |
| Wishlist | `WishlistController` | `Wishlist` | — |
| Review | `ReviewController` | `Review`, `PropertyReviewSummary`, `PropertyReviewBreakdown` | — |
| Voucher / promo | `VoucherController` | `Voucher`, `PropertyPromo` | — |
| Chat | `ChatController` | `Conversation`, `Message` | — |
| Notifikasi | `NotificationController` | `NotificationLog`, `DeviceToken` | ⚠️ FCM: endpoint token ada, paket Firebase **tidak** terpasang di Flutter |
| Dompet host | `HostWalletController` | `Withdrawal` | — |
| Validasi identitas | `UserValidationController` | `UserValidation` | — |
| Remote config | `RemoteConfigApiController` | `RemoteConfigParameter` (+`Condition`, `ParameterCondition`, `PublishLog`) | evaluasi: `Services/ConditionEvaluator`, `Services/RemoteConfigService` |
| Rekomendasi | dipakai `HomeController` | `PropertyRecommendation`, `Poi` | `Services/RecommendationService`, `Enums/PoiCategory` |
| Asuransi menginap | `InsuranceApiController` | `InsuranceProvider`, `InsurancePlan`, `BookingInsurance` | job: `IssueInsurancePolicyJob`, `SyncInsuranceStatusJob` |
| CMS / FAQ | `HomeController::cmsPage`, `::faqs` | `CmsPage`, `Faq` | — |
| Audit | — (admin saja) | `AuditLog` | — |

---

## 13. Titik masuk kode — mulai dari sini, bukan pencarian buta

| Pertanyaan | File:baris |
|---|---|
| Bentuk amplop response | `app/Support/ApiResponse.php:56` |
| Peta exception → status | `app/Support/ApiResponse.php:159` |
| Bagaimana pencarian membedakan dua mode | `app/Http/Controllers/Api/PropertyController.php:104-130` |
| Booking hotel dibuat | `app/Http/Controllers/Api/BookingController.php:410` |
| Booking unit dibuat | `app/Http/Controllers/Api/BookingController.php:653` |
| Stok kamar diambil (anti-oversell) | `app/Http/Controllers/Api/BookingController.php:615` |
| Aturan validasi tiap checkout | `BookingController.php:326` (common), `:358` (room), `:380` (unit) |
| Otorisasi host atas booking | `BookingController.php:904` |
| Snap dibuat | `app/Http/Controllers/Api/PaymentController.php:44` (pay), `:122` (retry) |
| Webhook diverifikasi | `app/Http/Controllers/Api/PaymentController.php:258` |
| Deep link dirakit | `app/Support/PaymentDeepLink.php:44` |
| Kredensial Midtrans di-override | `app/Providers/AppServiceProvider.php:38` |
| Observer didaftarkan | `app/Providers/AppServiceProvider.php:46-48` |
| Jadwal semua job | `routes/console.php` |
| `booking_mode` di-set jadi `room` | `app/Livewire/Hotels/Form.php:140` |
| Hotel detail dirakit | `app/Http/Resources/HotelResource.php` + `app/Support/HotelNormalizer.php` |
| Feed home campur unit+hotel | `app/Http/Resources/PropertyNHotelResource.php` |

---

## 14. Jangan sentuh

- `routes/admin_generated.php` — hasil scaffold, diregenerasi. Ubah sumbernya di
  `rental-properti-modules-laravel/`, atau tambah route di `web.php`.
- `.env` — kredensial DB nyata. Jangan commit, jangan echo nilainya.
- `fix_datatables.php`, `test_auth.php`, `commit_list.txt` di root `laravel/` —
  sisa debugging, bukan kode aktif. Jangan dijadikan referensi.
- **Jangan jalankan test atau migration** di repo ini.
