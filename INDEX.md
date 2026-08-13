# Indeks Dokumentasi

Peta rute: **topik → file docs → path kode**. Mulai dari sini, lalu buka hanya file yang relevan. Total docs ~305 KB — jangan dibaca sekaligus.

Ukuran dicantumkan supaya bisa memperkirakan biaya baca sebelum membuka.

## Mulai dari mana

| Kalau kamu ingin… | Baca ini |
|---|---|
| Gambaran umum sistem & 24 modul | [README.md](README.md) · 13 KB |
| Menyiapkan environment dev | `/CLAUDE.md` (root) → bagian "Cara mulai" |
| Konvensi backend | `/laravel/CLAUDE.md` |
| Konvensi mobile | `/flutter/CLAUDE.md` |
| Membuat modul admin baru | [configuration/admin-panel.md](configuration/admin-panel.md) + [configuration/ui-patterns.md](configuration/ui-patterns.md) |
| Mengerjakan pembayaran | [payments/trial_fix_payment.md](payments/trial_fix_payment.md) lalu [payments/flow.md](payments/flow.md) lalu [payments/remediation.md](payments/remediation.md) |
| Menambah layar Flutter | [flutter/screens.md](flutter/screens.md) |

## Per domain

### Admin Panel & UI

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [configuration/admin-panel.md](configuration/admin-panel.md) | 43 KB | Pola modul admin (Pattern A/B/C/D), inventaris controller & DataTable, alur CRUD | `laravel/app/Http/Controllers/Admin/`, `laravel/app/Livewire/`, `laravel/app/DataTables/` |
| [configuration/ui-patterns.md](configuration/ui-patterns.md) | 15 KB | Markup Blade standar: layout wrapper, card DataTable, action column, form modal, halaman detail | `laravel/resources/views/admin/`, `laravel/resources/views/livewire/` |
| [configuration/missing-files.md](configuration/missing-files.md) | 7 KB | ⚠️ Log pekerjaan selesai, **bukan** audit hidup. Nilai historis saja | — |

### Pembayaran (Midtrans)

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [payments/flow.md](payments/flow.md) | 42 KB | Alur end-to-end: booking → host confirm → order → payment → webhook → deep link | `laravel/app/Http/Controllers/Api/PaymentController.php`, `BookingController.php`, `Payment/` |
| [payments/integration.md](payments/integration.md) | 47 KB | Detail integrasi Snap, parameter, channel, signature, host confirmation flow | `laravel/app/Support/MidtransSnap.php`, `MidtransGateway.php`, `BookingController.php` |
| [payments/setup.md](payments/setup.md) | 16 KB | Konfigurasi kredensial, sandbox vs production, alur booking + bayar | `laravel/app/Models/PaymentSetting.php`, `laravel/app/Livewire/PaymentSettings/` |
| [payments/remediation.md](payments/remediation.md) | 14 KB | ✅ **Task tracker aktif** — item terbuka: T-5 (test manual), T-14 (migrasi), T-16 (test manual flow) | lihat file |
| [payments/trial_fix_payment.md](payments/trial_fix_payment.md) | 10 KB | Trial fix: booking flow, host confirmation, availability guard, auto-cancel | `BookingController.php`, `CancelExpiredPayments.php`, `booking_detail_screen.dart` |
| [payments/MOBILE_API_INSTALL.md](payments/MOBILE_API_INSTALL.md) | 5 KB | ⚠️ Salah tempat (ini soal API mobile menyeluruh, bukan payment) & duplikat dari `rental-properti-modules-laravel/` | `laravel/routes/api_mobile.php` |

### Properti

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [properties/system.md](properties/system.md) | 47 KB | Model properti, tipe, harga per periode, ketersediaan, pencarian & filter | `laravel/app/Models/Property.php`, `PropertyPrice.php`, `Availability.php` |
| [properties/recommendations.md](properties/recommendations.md) | 17 KB | Mesin rekomendasi, skoring, POI & jarak geo | `laravel/app/Services/RecommendationService.php`, `app/Models/Poi.php`, `app/Enums/PoiCategory.php` |
| [hotel/01-database-migration.md](hotel/01-database-migration.md) | 16 KB | Migrasi DB modul hotel harian OTA & Asuransi (hotels, room_types, room_inventories, booking_insurances) | `laravel/database/migrations/` |
| [hotel/02-models-relationships.md](hotel/02-models-relationships.md) | 16 KB | Definisi relasi Eloquent, Accessors, & Scopes modul hotel & asuransi (Booking, Property, Hotel, RoomType, Insurance) | `laravel/app/Models/` |
| [hotel/03-query-filters.md](hotel/03-query-filters.md) | 15 KB | Logika Query Builder & filter dinamis backend + alur transaksi booking & kalkulasi premi asuransi | `laravel/app/Http/Controllers/Api/PropertyController.php`, `BookingController.php` |
| [hotel/04-flutter-implementation.md](hotel/04-flutter-implementation.md) | 15 KB | Frontend Flutter, Provider state management, URL auto-filter, Deep Link `sewain://`, & Insurance Checkout Widget | `flutter/lib/` |
| [hotel/05-insurance-integration.md](hotel/05-insurance-integration.md) | 8 KB | Permodelan Asuransi Menginap Hotel (*Stay Protection*), integrasi API Insurtech, Queue Job & Manual Re-issue Admin | `laravel/app/Jobs/IssueInsurancePolicyJob.php`, `Admin/InsuranceController.php` |
| [hotel/06-hotel-management-flow.md](hotel/06-hotel-management-flow.md) | 9 KB | Alur manual tambah produk hotel (Web Admin & Flutter Mitra) + Otomasi Cronjob & Queue Job Laravel | `laravel/routes/console.php`, `app/Jobs/` |
| [hotel/Cara_Kerja_Modul_Hotel_Sewain.pdf](hotel/Cara_Kerja_Modul_Hotel_Sewain.pdf) | 13 KB | 📄 PDF Panduan Operasional & Cara Kerja Modul Hotel (Frontend Flutter & Backend Web Admin Laravel) | `flutter/lib/`, `laravel/app/` |
| [hotel/Sistem_Operasional_dan_Manajemen_Properti.pdf](hotel/Sistem_Operasional_dan_Manajemen_Properti.pdf) | 5 KB | 📄 PDF Ringkasan Sistem Operasional & Manajemen Properti (Frontend, Backend, & Workflow) | `docs/hotel/` |
| [hotel/Proposal_Pengembangan_Modul_Hotel.pdf](hotel/Proposal_Pengembangan_Modul_Hotel.pdf) | 9 KB | 📄 PDF Proposal Bisnis & Fungsional Integrasi Modul Hotel (Non-Teknis untuk Klien & Stakeholder) | `docs/hotel/` |






### Fitur

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [features/referral.md](features/referral.md) | 28 KB | Sistem referral: kode, klaim, reward | `laravel/app/Models/Referral.php`, `Api/ReferralController.php`, `flutter/lib/services/referral_service.dart` |

### Mobile

| File | Ukuran | Isi | Kode terkait |
|---|---|---|---|
| [flutter/screens.md](flutter/screens.md) | 12 KB | Pemetaan 37 mockup → layar → route | `flutter/lib/screens/`, `flutter/lib/router.dart`, `flutter/screens_flutter/*.png` |

## Cari cepat di kode (bukan di docs)

Untuk hal-hal yang cepat basi kalau ditulis di docs, baca langsung dari kode:

| Pertanyaan | Perintah |
|---|---|
| Endpoint API apa saja yang ada? | baca `laravel/routes/api_mobile.php` |
| Route admin apa saja? | baca `laravel/routes/admin_generated.php` |
| Ada model/tabel apa saja? | `ls laravel/app/Models/` · `ls laravel/database/migrations/` |
| Route Flutter apa saja? | baca `flutter/lib/router.dart` (`AppRoutes`) |
| Package apa yang benar-benar terpasang? | `laravel/composer.json` · `flutter/pubspec.yaml` |
| Test apa yang ada? | `ls -R laravel/tests/` · `ls -R flutter/test/` |

## Drift yang diketahui

Docs ini akurat secara konsep tapi beberapa detail sudah tertinggal dari kode. Yang sudah terkonfirmasi per 2026-08-11:

| Lokasi | Klaim | Realita |
|---|---|---|
| `README.md` tabel stack Flutter | Dio, FCM, Google Maps, Share Plus, Riverpod | Tidak terpasang. Yang dipakai: `http`, `provider`, `app_links` |
| `README.md` tabel stack Laravel | Livewire 3, Laravel Excel | Livewire **4.3**; Laravel Excel tidak ada; `dompdf` ada tapi tak didokumentasikan |
| `README.md` skala DB | ±70–100 tabel | 47 migration → ±40 tabel |
| `admin-panel.md` inventaris | 25 controller, 24 DataTable, 22 Livewire | **32** / **27** / **26** |
| `MOBILE_API_INSTALL.md` | 12 Api controller | **17** |
| `flutter/screens.md` | `register_host_screen.dart`, route `/settings/profile`, `/settings/favorites`, `/register/host` | Tidak ada. Sebaliknya ada layar tak terdokumentasi: `main_shell`, `mitra_shell`, `notification`, `validation`, `referral`, `payment_result` |
| Guest browsing | Belum didokumentasikan | Guest dapat browse properti tanpa login; booking/chat/wishlist tetap butuh auth |
| Branding | Sewain | `flutter/lib/config/app_config.dart` masih `LIVI.COM` |
| `remediation.md` status | Item terbuka T-5, T-12, T-14 | T-12 (deep link) sudah selesai; T-5 dan T-14 masih terbuka |

Aturan agar tidak berulang: **jangan tulis daftar file di docs.** Daftar controller/model/endpoint dibaca dari kode (lihat tabel "Cari cepat" di atas).

## Catatan

- `sfds.md` adalah catatan lepas berisi usulan struktur docs yang **tidak dipakai** dan bertentangan dengan struktur nyata. Abaikan atau hapus.
- Bahasa docs: Indonesia. Bahasa kode & komentar: Inggris.
