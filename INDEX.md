# Indeks Dokumentasi

Peta rute: **topik → file docs → path kode**. Mulai dari sini, lalu buka hanya file yang relevan.

Ukuran dicantumkan supaya bisa memperkirakan biaya baca sebelum membuka.

## Mulai dari mana

| Kalau kamu ingin… | Baca ini |
|---|---|
| Gambaran umum sistem & 25 modul | [README.md](README.md) · 14 KB |
| Menyiapkan environment dev | `/CLAUDE.md` (root) → bagian "Cara mulai" |
| Konvensi backend | `/laravel/CLAUDE.md` |
| Konvensi mobile | `/flutter/CLAUDE.md` |
| Membuat modul admin baru | [configuration/admin-panel.md](configuration/admin-panel.md) + [configuration/ui-patterns.md](configuration/ui-patterns.md) |
| Mengerjakan pembayaran | [payments/trial_fix_payment.md](payments/trial_fix_payment.md) lalu [payments/flow.md](payments/flow.md) lalu [payments/remediation.md](payments/remediation.md) |
| Menambah layar Flutter | [flutter/screens.md](flutter/screens.md) |
| Memahami modul hotel OTA | [hotel/01-database-migration.md](hotel/01-database-migration.md) → urutan 01–07 |

## Per domain

### Admin Panel & UI

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [configuration/admin-panel.md](configuration/admin-panel.md) | 43 KB | Pola modul admin (Pattern A/B/C/D), inventaris controller & DataTable, alur CRUD | `laravel/app/Http/Controllers/Admin/` (32 controller), `laravel/app/Livewire/` (26), `laravel/app/DataTables/` (27) |
| [configuration/ui-patterns.md](configuration/ui-patterns.md) | 15 KB | Markup Blade standar: layout wrapper, card DataTable, action column, form modal, halaman detail | `laravel/resources/views/admin/`, `laravel/resources/views/livewire/` |
| [configuration/missing-files.md](configuration/missing-files.md) | 7 KB | ⚠️ Log pekerjaan selesai, **bukan** audit hidup. Nilai historis saja | — |

### Pembayaran (Midtrans)

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [payments/flow.md](payments/flow.md) | 42 KB | Alur end-to-end: booking → host confirm → order → payment → webhook → deep link | `laravel/app/Http/Controllers/Api/PaymentController.php`, `BookingController.php` |
| [payments/integration.md](payments/integration.md) | 47 KB | Detail integrasi Snap, parameter, channel, signature, host confirmation flow | `laravel/app/Support/MidtransSnap.php`, `MidtransGateway.php` |
| [payments/setup.md](payments/setup.md) | 16 KB | Konfigurasi kredensial, sandbox vs production, alur booking + bayar | `laravel/app/Models/PaymentSetting.php`, `laravel/app/Livewire/PaymentSettings/` |
| [payments/kebijakan_pengembalian_pembayaran.md](payments/kebijakan_pengembalian_pembayaran.md) | 8 KB | 🆕 Kebijakan & mekanisme refund 100% untuk pembayaran sukses tapi kamar tidak tersedia | `BookingController.php` (reject), `PaymentController.php` (refund), `ProcessMidtransRefundJob.php` |
| [payments/remediation.md](payments/remediation.md) | 14 KB | ✅ **Task tracker aktif** — item terbuka: T-5 (test manual), T-14 (migrasi), T-16 (test manual flow) | lihat file |
| [payments/trial_fix_payment.md](payments/trial_fix_payment.md) | 10 KB | Trial fix: booking flow, host confirmation, availability guard, auto-cancel | `BookingController.php`, `CancelExpiredPayments.php`, `booking_detail_screen.dart` |
| [payments/MOBILE_API_INSTALL.md](payments/MOBILE_API_INSTALL.md) | 5 KB | ⚠️ Salah tempat (ini soal API mobile menyeluruh, bukan payment) & duplikat dari `rental-properti-modules-laravel/` | `laravel/routes/api_mobile.php` |

### Properti & Hotel

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [properties/system.md](properties/system.md) | 47 KB | Model properti unit (kos/apartemen), tipe, harga per periode, ketersediaan (`availabilities`), pencarian & filter | `laravel/app/Models/Property.php`, `PropertyPrice.php`, `Availability.php` |
| [properties/recommendations.md](properties/recommendations.md) | 17 KB | Mesin rekomendasi, skoring, POI & jarak geo | `laravel/app/Services/RecommendationService.php`, `app/Models/Poi.php` |
| [hotel/01-database-migration.md](hotel/01-database-migration.md) | 20 KB | ✅ **Selesai** — Migrasi DB hotel harian OTA: `hotels`, `room_types`, `rooms`, `room_inventories`, `booking_rooms`, `facilities`, `insurance_*` | `laravel/database/migrations/2026_08_13_*` |
| [hotel/02-models-relationships.md](hotel/02-models-relationships.md) | 16 KB | ✅ **Selesai** — Eloquent models & relasi: `Hotel`, `RoomType`, `RoomInventory`, `BookingRoom`, `InsurancePlan`, `BookingInsurance` | `laravel/app/Models/` |
| [hotel/03-query-filters.md](hotel/03-query-filters.md) | 17 KB | ✅ **Selesai** — Query Builder dual-mode (unit & room), filter OTA, `BookingController::store()` hotel + kalkulasi asuransi | `laravel/app/Http/Controllers/Api/PropertyController.php`, `BookingController.php` |
| [hotel/04-flutter-implementation.md](hotel/04-flutter-implementation.md) | 17 KB | ✅ **Selesai** — Flutter: `HotelSearchQuery`, `HotelSearchProvider`, deep link `sewain://search`, `InsuranceSelectionWidget` | `flutter/lib/` |
| [hotel/05-insurance-integration.md](hotel/05-insurance-integration.md) | 9 KB | ✅ **Selesai** — Asuransi menginap (*Stay Protection*), Queue Job (`IssueInsurancePolicyJob`), Manual Re-issue Admin | `laravel/app/Jobs/` |
| [hotel/06-hotel-management-flow.md](hotel/06-hotel-management-flow.md) | 11 KB | ✅ **Selesai** — Alur manajemen produk hotel (Web Admin & Flutter Mitra) + Cronjob scheduler | `laravel/routes/console.php`, `app/Jobs/` |
| [hotel/07-compatibility-map.md](hotel/07-compatibility-map.md) | — | 🆕 Peta kompatibilitas hotel ↔ payments ↔ properties (integrasi, backward compat, dual-mode) | lihat file |

### Fitur

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [features/referral.md](features/referral.md) | 28 KB | Sistem referral: kode, klaim, reward | `laravel/app/Models/Referral.php`, `Api/ReferralController.php`, `flutter/lib/services/referral_service.dart` |

### Mobile

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [flutter/screens.md](flutter/screens.md) | 13 KB | Pemetaan 40 layar → route (termasuk 3 layar baru: payment_result, payment_webview, notification) | `flutter/lib/screens/`, `flutter/lib/router.dart` |

## Cari cepat di kode (bukan di docs)

Untuk hal-hal yang cepat basi kalau ditulis di docs, baca langsung dari kode:

| Pertanyaan | Perintah |
|---|---|
| Endpoint API apa saja yang ada? | baca `laravel/routes/api_mobile.php` |
| Route admin apa saja? | baca `laravel/routes/admin_generated.php` |
| Ada model/tabel apa saja? | `ls laravel/app/Models/` · `ls laravel/database/migrations/` |
| Route Flutter apa saja? | baca `flutter/lib/router.dart` |
| Package apa yang benar-benar terpasang? | `laravel/composer.json` · `flutter/pubspec.yaml` |
| Test apa yang ada? | `ls -R laravel/tests/` · `ls -R flutter/test/` |
| Hotel model apa yang sudah ada? | `Hotel`, `RoomType`, `RoomInventory`, `Room`, `BookingRoom`, `Facility`, `InsuranceProvider`, `InsurancePlan`, `BookingInsurance` |

## Drift yang diketahui

Per **2026-08-13** — item yang sudah dikonfirmasi:

| Lokasi | Klaim Lama | Realita Aktual |
|---|---|---|
| `README.md` stack Flutter | Dio, FCM, Google Maps, Share Plus, Riverpod | `http`, `provider`, `webview_flutter`, `app_links`, `cached_network_image`, `intl` |
| `README.md` stack Laravel | Livewire 3, Laravel Excel | Livewire **4.3**; no Laravel Excel; `barryvdh/laravel-dompdf` ada |
| `README.md` Laravel version | `Laravel 10+` (di payments doc) | **Laravel 12** |
| `README.md` skala DB | ±70–100 tabel | ~50 base migrations; +9 hotel migrations (Selesai & teruji) |
| `admin-panel.md` inventaris | 25 controller, 24 DataTable, 22 Livewire | **32** Admin controller / **27** DataTable / **26** Livewire |
| `MOBILE_API_INSTALL.md` | 12 Api controller | **17** Api controller |
| `flutter/screens.md` total | 37 layar | **40 layar** (+ `payment_result_screen`, `payment_webview_screen`, `notification_screen`) |
| `flutter/screens.md` route | `/settings/profile`, `/settings/favorites` | Tidak ada di router aktual (layar di-embed di shell/tabs) |
| `flutter/screens.md` missing | — | `payment_result_screen.dart`, `payment_webview_screen.dart`, `notification_screen.dart` belum terdaftar |
| `INDEX.md` deep link T-12 | Masih open | ✅ Selesai (`DeepLinkHandler` sudah ada di kode) |
| Branding | Sewain | `flutter/lib/config/app_config.dart` masih `LIVI.COM` |
| Hotel models & migrations | — | ✅ Selesai diimplementasikan di Laravel & Flutter |

Aturan agar tidak berulang: **jangan tulis daftar file di docs.** Daftar controller/model/endpoint dibaca dari kode (lihat tabel "Cari cepat" di atas).

## Catatan

- `sfds.md` adalah catatan lepas berisi usulan struktur docs yang **tidak dipakai** dan bertentangan dengan struktur nyata. Abaikan atau hapus.
- Bahasa docs: Indonesia. Bahasa kode & komentar: Inggris.
- `docs/hotel/` adalah dokumentasi arsitektur dari modul Hotel OTA & Stay Protection Insurance yang telah aktif diimplementasikan dan teruji 100%.

