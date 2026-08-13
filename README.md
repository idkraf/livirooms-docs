# Rental Apartemen — Dokumentasi Proyek

Platform penyewaan properti multi-tipe berbasis subscription yang mendukung penyewaan harian, mingguan, bulanan, dan tahunan. Sistem ini melayani empat aktor utama: **Konsumen**, **Host**, **Admin**, dan **Corporate**.

> 📍 **Mencari file tertentu?** Buka **[INDEX.md](INDEX.md)** — peta topik → dokumen → path kode, lengkap dengan daftar drift yang diketahui. Dokumen ini (README) berisi gambaran umum; INDEX untuk navigasi.

---

## Daftar Isi

- [Ringkasan Proyek](#ringkasan-proyek)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Stack Teknologi](#stack-teknologi)
- [Daftar Modul](#daftar-modul)
- [Hak Akses Pengguna](#hak-akses-pengguna)
- [Roadmap Pengembangan](#roadmap-pengembangan)
- [Struktur Dokumentasi](#struktur-dokumentasi)
- [Panduan Kontribusi](#panduan-kontribusi)

---

## Ringkasan Proyek

| Aspek | Detail |
|-------|--------|
| **Nama proyek** | Rental Apartemen (Sewain / LiviRooms) |
| **Tipe properti** | Apartemen, Rumah, Villa, Hotel Residence, Guest House, Kost Eksklusif, **Hotel (OTA Mode)** |
| **Periode sewa** | Harian · Mingguan · Bulanan · Tahunan |
| **Platform** | Mobile App (Flutter) + Admin Panel (Web/Livewire) + Corporate Web |
| **Estimasi tabel DB** | ±50–60 tabel (base) + 9 tabel hotel/asuransi (**live & teruji**) |
| **Payment Gateway** | Midtrans Snap (VA, QRIS, E-Wallet, Kartu Kredit, PayLater) |
| **Autentikasi** | Laravel Sanctum (API) + Session (Admin) |

---

## Arsitektur Sistem

```
┌──────────────────────────────────────────────────────────────────────┐
│                          API Gateway (Laravel)                       │
│  Route: /api/v1/* (Sanctum) + /admin/* (Session)                   │
│  Layer: Controller → Service → Model → Database                     │
└────────────────────────┬─────────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Mobile App  │ │ Admin Panel  │ │ Corporate Web│
│   (Flutter)  │ │(Livewire/    │ │              │
│              │ │ Blade/       │ │              │
└──────────────┘ └──────────────┘ └──────────────┘
```

### Alur Data

1. **Mobile → API**: Flutter mengirim request ke Laravel REST API dengan Sanctum token
2. **Admin → Backend**: Admin panel menggunakan Livewire + Blade, komunikasi langsung ke backend
3. **Backend → Database**: Laravel Eloquent ORM ke PostgreSQL
4. **Backend → Midtrans**: Snap API untuk pembayaran, webhook untuk callback
5. **Backend → Queue**: Laravel Queue untuk job async (asuransi, notifikasi, cancel expired)

---

## Stack Teknologi

### Backend (Laravel 12)

| Package | Versi | Fungsi |
|---------|-------|--------|
| **Laravel** | `^12.0` | Framework utama |
| **Laravel Sanctum** | `^4.3` | Autentikasi API token |
| **Livewire** | `^4.3` | Komponen UI dinamis untuk admin panel |
| **Yajra DataTables** | `^12.x` | Tabel server-side dengan search, sort, export |
| **Spatie Permission** | `^6.9` | Manajemen role & permission |
| **Laravel Queue** | built-in | Proses async (asuransi, email, Midtrans callback) |
| **Laravel Scheduler** | built-in | Cron jobs (expire booking, inventory hotel, report) |
| **Laravel Notification** | built-in | Notifikasi multi-channel (database, mail) |
| **Midtrans PHP SDK** | `^2.6` | Payment gateway Midtrans Snap |
| **barryvdh/laravel-dompdf** | `*` | Generasi PDF (laporan, sertifikat asuransi) |
| **PostgreSQL** | — | Basis data produksi |

### Mobile (Flutter)

| Package | Versi | Fungsi |
|---------|-------|--------|
| **Flutter** | `>=3.19.0` | Framework mobile |
| **provider** | `^6.1.2` | State management |
| **http** | `^1.2.1` | HTTP client |
| **webview_flutter** | `^4.13.0` | WebView untuk Midtrans Snap in-app |
| **app_links** | `^6.3.2` | Deep link handler (`sewain://`) |
| **url_launcher** | `^6.3.1` | Buka browser eksternal |
| **image_picker** | `^1.2.0` | Upload foto galeri/kamera |
| **cached_network_image** | `^3.3.1` | Cache gambar dari URL |
| **shared_preferences** | `^2.5.2` | Penyimpanan lokal (token, preferensi) |
| **intl** | `^0.20.3` | Format tanggal & angka (Internasionalisasi) |
| **cupertino_icons** | `^1.0.6` | Ikon iOS |

### Admin Panel

| Package | Fungsi |
|---------|--------|
| **Laravel Blade** | Template engine |
| **Livewire 4.3** | Komponen interaktif tanpa JS |
| **Yajra DataTables** | Tabel dengan export CSV/print |
| **Bootstrap 5** | CSS framework |

---

## Daftar Modul

Sistem terdiri dari 25 modul utama (24 base + 1 modul hotel OTA — Phase 4).

| No | Modul | Tabel | Model | Deskripsi | Dokumentasi |
|----|-------|-------|-------|-----------|-------------|
| 1 | **Property Management** | `properties` | `Property` | Manajemen properti multi-tipe dengan galeri, fasilitas, harga, dan mode sewa (`unit`/`room`) | [properties/system.md](properties/system.md) |
| 2 | **Pencarian Properti** | `property_search_logs` | `PropertySearchLog` | Log pencarian + filter realtime, mendukung filter dual-mode (unit & hotel) | [properties/system.md](properties/system.md) |
| 3 | **Management Booking** | `bookings`, `booking_rooms` | `Booking`, `BookingRoom` | Booking unit (kos/apartemen) & kamar hotel harian, asuransi menginap, kalender, pembatalan | [properties/system.md](properties/system.md) |
| 4 | **Kalender Ketersediaan** | `availabilities` | `Availability` | Host atur tanggal tersedia/tidak untuk mode unit; hotel menggunakan `room_inventories` | [properties/system.md](properties/system.md) |
| 5 | **Management Harga** | `property_prices`, `room_inventories` | `PropertyPrice`, `RoomInventory` | Harga harian/mingguan/bulanan/tahunan (unit), tarif kamar harian & allotment (hotel) | [properties/system.md](properties/system.md) |
| 6 | **Promo & Voucher** | `vouchers` | `Voucher` | Weekly deals, flash sale, kode promo | — |
| 7 | **Rekomendasi Properti** | `property_recommendations` | `PropertyRecommendation` | Terlaris, terbaru, premium, berbasis POI | [properties/recommendations.md](properties/recommendations.md) |
| 8 | **Management Chat** | `conversations`, `messages` | `Conversation`, `Message` | Chat realtime konsumen–host, admin moderation | — |
| 9 | **FAQ & Help Center** | `faqs` | `Faq` | Panduan booking/pembayaran/refund | — |
| 10 | **Management Notifikasi** | `notification_logs` | `NotificationLog` | Booking, pembayaran, promo (in-app + push) | — |
| 11 | **Management User** | `user_profiles` | `UserProfile` | Konsumen, Host, Corporate, dengan role & permission | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 12 | **Management Order** | `orders` | `Order` | Checkout, invoice, perpanjangan, pembatalan | — |
| 13 | **Flexible Payment** | `payments` | `Payment` | VA, Transfer, QRIS, E-Wallet, Kartu Kredit, PayLater via Midtrans Snap | [payments/flow.md](payments/flow.md) |
| 14 | **Management Withdrawal** | `withdrawals` | `Withdrawal` | Host withdrawal, admin approval | — |
| 15 | **Review & Rating** | `reviews` | `Review` | Rating properti & host | — |
| 16 | **Wishlist** | `wishlists` | `Wishlist` | Properti favorit | — |
| 17 | **Referral** | `referrals` | `Referral` | Kode referral, reward otomatis | [features/referral.md](features/referral.md) |
| 18 | **Banner & Iklan** | `banners` | `Banner` | Banner utama, promo, musiman | — |
| 19 | **CMS** | `cms_pages` | `CmsPage` | Artikel, FAQ, syarat & ketentuan | — |
| 20 | **Dashboard Host** | — | — | Statistik properti, booking, pendapatan (aggregate) | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 21 | **Dashboard Admin** | — | — | Statistik operasional (aggregate) | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 22 | **Role & Permission** | — | — | Multi role dengan Spatie Permission | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 23 | **Log Aktivitas** | `audit_logs` | `AuditLog` | Login, booking, pembayaran, withdrawal | — |
| 24 | **Laporan** | — | — | Booking, pendapatan, properti, withdrawal, refund | — |
| 25 🆕 | **Hotel OTA Booking** | `hotels`, `room_types`, `rooms`, `room_inventories`, `booking_rooms`, `facilities`, `insurance_providers`, `insurance_plans`, `booking_insurances` | `Hotel`, `RoomType`, `RoomInventory`, `BookingRoom`, `Facility`, `InsurancePlan`, `BookingInsurance` | Booking kamar hotel harian (mode OTA), manajemen stok/tarif harian, asuransi menginap | [hotel/](hotel/) |

> **Catatan:** Modul 20, 21, 22, dan 24 tidak memiliki tabel/model sendiri karena merupakan layanan agregasi (aggregate) di atas modul lain. Modul 25 (Hotel OTA) telah **diimplementasikan & teruji** — migrasi, model, controller, Flutter, dan test suite tersedia penuh (115 Laravel tests ✅, 133 Flutter tests ✅).

---

## Hak Akses Pengguna

| Role | Akses Utama |
|------|-------------|
| **Super Admin** | Kontrol penuh seluruh sistem |
| **Admin** | Operasional harian & moderasi konten |
| **Finance** | Verifikasi pembayaran, withdrawal, laporan keuangan |
| **Customer Service** | Chat, bantuan, penanganan keluhan |
| **Marketing** | Promo, voucher, banner, kampanye |
| **Property Manager** | Verifikasi & pengelolaan properti |
| **Host / Mitra** | Kelola properti, kalender/inventaris, booking, pendapatan, withdrawal |
| **Corporate** | Booking untuk karyawan, approval, invoice perusahaan |
| **Konsumen** | Pencarian, booking, pembayaran, review, wishlist, referral |

### Guest Browsing

Pengguna dapat menjelajahi properti tanpa login/daftar:
- **Publik:** Homepage, pencarian, detail properti, dan filter.
- **Login Required:** Booking, pembayaran, wishlist, chat, riwayat transaksi, profil.
- Tindakan transaksional mengarahkan ke `LoginScreen` jika token tidak ada.

---

## Roadmap Pengembangan

### Phase 1 — MVP ✅
- Login & Registrasi (email + social login)
- Property Management (CRUD properti multi-tipe)
- Pencarian Properti (filter, sorting, pagination)
- Booking (instan, request, kalender)
- Pembayaran (Midtrans Snap — VA, QRIS, E-Wallet)
- Chat (Konsumen–Host)
- Notifikasi (in-app)
- Dashboard Admin & Host

### Phase 2 ✅
- Promo & Voucher
- Referral System
- Wishlist
- Review & Rating
- Withdrawal Management
- Banner Management
- Guest Browsing (properti publik tanpa login)

### Phase 3 ✅
- CMS (Artikel, FAQ, Syarat & Ketentuan)
- Laporan (booking, pendapatan, properti)
- Audit Log
- Multi Role & Permission (Spatie)
- Dashboard Statistik
- Remote Config
- Deep Link (`sewain://payment-result`)
- Asuransi (dasar)
- Cities & POI System
- User Validation (KYC)

### Phase 4 — Hotel OTA Booking ✅ *(Selesai & Teruji)*
- Mode Booking Kamar Hotel Harian (`booking_mode = 'room'`) — `PropertyController`, `BookingController`
- Manajemen Tipe Kamar & Stok Harian (Allotment/Inventory Calendar) — `RoomInventory`, `RoomTypeObserver`
- Filter OTA: tanggal check-in/check-out, jumlah kamar, kapasitas tamu, bintang, fasilitas — dual-mode query builder
- Asuransi Menginap Hotel (Stay Protection) — `InsurancePlan`, `BookingInsurance`, `IssueInsurancePolicyJob`
- Deep Link Hotel Search (`sewain://search?...`) — `DeepLinkHandler`, `HotelSearchQuery`, `HotelSearchProvider`
- Queue Job & Cronjob otomasi: `ExtendHotelInventoriesJob`, `CancelExpiredBookingsJob`, `SyncInsuranceStatusJob`, `IssueInsurancePolicyJob`
- Flutter: `InsuranceSelectionWidget`, fixture JSON diperbarui, unit tests hotel & asuransi
- **Test coverage**: 115 Laravel tests ✅ · 133 Flutter tests ✅

---

## Struktur Dokumentasi

```
docs/
├── README.md                                    # Ringkasan proyek & panduan dokumentasi
├── INDEX.md                                     # Peta topik → dokumen → path kode
├── payments/
│   ├── setup.md                                 # Panduan setup Midtrans
│   ├── integration.md                           # Audit integrasi Midtrans
│   ├── flow.md                                  # Alur pembayaran end-to-end
│   ├── remediation.md                           # Task tracker perbaikan
│   ├── trial_fix_payment.md                     # Trial fix: booking flow, host confirm
│   └── MOBILE_API_INSTALL.md                    # Panduan integrasi mobile API
├── properties/
│   ├── system.md                                # Dokumentasi sistem property (unit mode)
│   └── recommendations.md                       # Algoritma rekomendasi properti
├── features/
│   └── referral.md                              # Sistem referral
├── configuration/
│   ├── admin-panel.md                           # Arsitektur panel admin (Pattern A/B/C/D)
│   ├── ui-patterns.md                           # Pola UI standar Blade
│   └── missing-files.md                         # ⚠️ Log historis, bukan audit hidup
├── flutter/
│   └── screens.md                               # Referensi 40 layar Flutter
└── hotel/                                       # ✅ Hotel OTA Booking & Stay Protection Insurance (Selesai & Teruji)
    ├── 01-database-migration.md                 # Skema migrasi DB hotel & asuransi
    ├── 02-models-relationships.md               # Eloquent models & relasi
    ├── 03-query-filters.md                      # Query Builder & alur BookingController
    ├── 04-flutter-implementation.md             # Frontend Flutter (Provider, deep link, widget)
    ├── 05-insurance-integration.md              # Asuransi menginap & Queue Job
    ├── 06-hotel-management-flow.md              # Alur manajemen produk hotel & Cronjob
    └── 07-compatibility-map.md                  # Peta kompatibilitas hotel ↔ payments ↔ properties
```

---

## Panduan Kontribusi

### Menambahkan Modul Baru

1. Baca [configuration/admin-panel.md](configuration/admin-panel.md) untuk memahami 3 pattern modul admin
2. Baca [configuration/ui-patterns.md](configuration/ui-patterns.md) untuk pola UI standar
3. Ikuti struktur folder yang sudah ditetapkan
4. Tambahkan dokumentasi di `docs/` jika modul baru memerlukan penjelasan khusus

### Standar Dokumentasi

- Gunakan Bahasa Indonesia untuk konten utama
- Gunakan Bahasa Inggris untuk kode, nama file, dan istilah teknis
- Setiap file harus memiliki judul yang konsisten: `# Nama Dokumen` (Title Case)
- Gunakan tabel untuk data terstruktur
- Gunakan blok kode dengan syntax highlighting
- Sertakan path file relatif terhadap root project

### Testing

```bash
# Laravel — Unit & Feature Tests
php artisan test

# Laravel — Test spesifik
php artisan test --filter=PaymentCallbackTest
php artisan test --filter=BookingHotelTest

# Flutter — Unit Tests
flutter test

# Flutter — Test file spesifik
flutter test test/models/referral_test.dart
flutter test test/services/booking_service_test.dart

# Laravel — Jalankan Queue Worker (lokal)
php artisan queue:work

# Laravel — Jalankan Scheduler (lokal)
php artisan schedule:run
```

---

## Kontak & Dukungan

Untuk pertanyaan teknis atau diskusi arsitektur, buat issue di repository project atau hubungi tim development.
