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
- [Paket Scaffold Modul](#paket-scaffold-modul-laravel)
- [Panduan Kontribusi](#panduan-kontribusi)

---

## Ringkasan Proyek

| Aspek | Detail |
|-------|--------|
| **Nama proyek** | Rental Apartemen (Sewain) |
| **Tipe properti** | Apartemen, Rumah, Villa, Hotel Residence, Guest House, Kost Eksklusif |
| **Periode sewa** | Harian · Mingguan · Bulanan · Tahunan |
| **Platform** | Mobile App (Flutter) + Admin Panel (Web/Livewire) + Corporate Web |
| **Estimasi tabel DB** | ±70–100 tabel |
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
│              │ │ Blade/Metronic│ │              │
└──────────────┘ └──────────────┘ └──────────────┘
```

### Alur Data

1. **Mobile → API**: Flutter mengirim request ke Laravel REST API dengan Sanctum token
2. **Admin → Backend**: Admin panel menggunakan Livewire + Blade, komunikasi langsung ke backend
3. **Backend → Database**: Laravel Eloquent ORM ke PostgreSQL
4. **Backend → Midtrans**: Snap API untuk pembayaran, webhook untuk callback
5. **Backend → Firebase**: FCM untuk push notification ke Flutter

---

## Stack Teknologi

### Backend (Laravel 12)

| Package | Fungsi |
|---------|--------|
| **Laravel 12** | Framework utama |
| **Laravel Sanctum** | Autentikasi API token |
| **Laravel Livewire** | Komponen UI dinamis untuk admin panel |
| **Yajra DataTables** | Tabel server-side dengan search, sort, export |
| **Spatie Permission** | Manajemen role & permission |
| **Laravel Queue** | Proses async (email, notification, Midtrans callback) |
| **Laravel Scheduler** | Cron jobs (expire booking, cleanup, report) |
| **Laravel Notification** | Notifikasi multi-channel (database, mail, FCM) |
| **Laravel Excel** | Ekspor laporan (CSV, Excel) |
| **Midtrans Snap** | Payment gateway |
| **PostgreSQL** | Basis data produksi |

### Mobile (Flutter)

| Package | Fungsi |
|---------|--------|
| **Flutter 3.x** | Framework mobile |
| **Provider / Riverpod** | State management |
| **Dio** | HTTP client dengan interceptor |
| **Firebase Cloud Messaging** | Push notification |
| **Google Maps** | Peta lokasi properti |
| **Image Picker** | Upload foto |
| **Share Plus** | Share kode referral |
| **Url Launcher** | Buka browser eksternal untuk Midtrans |

### Admin Panel

| Package | Fungsi |
|---------|--------|
| **Laravel Blade** | Template engine |
| **Livewire 3** | Komponen interaktif tanpa JS |
| **Metronic** | UI kit Bootstrap |
| **Bootstrap 5** | CSS framework |

---

## Daftar Modul

Sistem terdiri dari 24 modul utama. Informasi tabel dan model diambil dari scaffold package [`rental-properti-modules-laravel`](../rental-properti-modules-laravel/README.md).

| No | Modul | Tabel | Model | Deskripsi | Dokumentasi |
|----|-------|-------|-------|-----------|-------------|
| 1 | **Property Management** | `properties` | `Property` | Manajemen properti multi-tipe dengan galeri, fasilitas, harga | [properties/system.md](properties/system.md) |
| 2 | **Pencarian Properti** | `property_search_logs` | `PropertySearchLog` | Log pencarian + filter realtime ke tabel `properties` | [properties/system.md](properties/system.md) |
| 3 | **Management Booking** | `bookings` | `Booking` | Booking instan, request, kalender, pembatalan, refund | [properties/system.md](properties/system.md) |
| 4 | **Kalender Ketersediaan** | `availabilities` | `Availability` | Host atur tanggal tersedia/tidak, harga per tanggal | [properties/system.md](properties/system.md) |
| 5 | **Management Harga** | `property_prices` | `PropertyPrice` | Harga harian/mingguan/bulanan/tahunan, biaya tambahan | [properties/system.md](properties/system.md) |
| 6 | **Promo & Voucher** | `vouchers` | `Voucher` | Weekly deals, flash sale, kode promo | - |
| 7 | **Rekomendasi Properti** | `property_recommendations` | `PropertyRecommendation` | Terlaris, terbaru, premium, berbasis POI | [properties/recommendations.md](properties/recommendations.md) |
| 8 | **Management Chat** | `conversations`, `messages` | `Conversation`, `Message` | Chat realtime konsumen–host, admin moderation | - |
| 9 | **FAQ & Help Center** | `faqs` | `Faq` | Panduan booking/pembayaran/refund | - |
| 10 | **Management Notifikasi** | `notification_logs` | `NotificationLog` | Booking, pembayaran, promo (in-app + push) | - |
| 11 | **Management User** | `user_profiles` | `UserProfile` | Konsumen, Host, Corporate, dengan role & permission | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 12 | **Management Order** | `orders` | `Order` | Checkout, invoice, perpanjangan, pembatalan | - |
| 13 | **Flexible Payment** | `payments` | `Payment` | VA, Transfer, QRIS, E-Wallet, Kartu Kredit, PayLater | [payments/flow.md](payments/flow.md) |
| 14 | **Management Withdrawal** | `withdrawals` | `Withdrawal` | Host withdrawal, admin approval | - |
| 15 | **Review & Rating** | `reviews` | `Review` | Rating properti & host | - |
| 16 | **Wishlist** | `wishlists` | `Wishlist` | Properti favorit | - |
| 17 | **Referral** | `referrals` | `Referral` | Kode referral, reward otomatis | [features/referral.md](features/referral.md) |
| 18 | **Banner & Iklan** | `banners` | `Banner` | Banner utama, promo, musiman | - |
| 19 | **CMS** | `cms_pages` | `CmsPage` | Artikel, FAQ, syarat & ketentuan | - |
| 20 | **Dashboard Host** | — | — | Statistik properti, booking, pendapatan (aggregate) | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 21 | **Dashboard Admin** | — | — | Statistik operasional (aggregate) | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 22 | **Role & Permission** | — | — | Multi role dengan Spatie Permission | [configuration/admin-panel.md](configuration/admin-panel.md) |
| 23 | **Log Aktivitas** | `audit_logs` | `AuditLog` | Login, booking, pembayaran, withdrawal | - |
| 24 | **Laporan** | — | — | Booking, pendapatan, properti, withdrawal, refund | - |

> **Catatan:** Modul 20, 21, 22, dan 24 tidak memiliki tabel/model sendiri karena merupakan layanan agregasi (aggregate) di atas modul lain.

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
| **Host** | Kelola properti, kalender, booking, pendapatan, withdrawal |
| **Corporate** | Booking untuk karyawan, approval, invoice perusahaan |
| **Konsumen** | Pencarian, booking, pembayaran, review, wishlist, referral |

### Guest Browsing

Pengguna dapat menjelajahi properti tanpa login/daftar:
- **Publik:** Homepage, pencarian, detail properti, dan filter.
- **Login Required:** Booking, pembayaran, wishlist, chat, riwayat transaksi, profil.
- Tindakan transaksional mengarahkan ke `LoginScreen` jika token tidak ada.

---

## Roadmap Pengembangan

### Phase 1 — MVP
- Login & Registrasi (email, Google, Apple, Facebook)
- Property Management (CRUD properti multi-tipe)
- Pencarian Properti (filter, sorting, pagination)
- Booking (instan, request, kalender)
- Pembayaran (Midtrans Snap)
- Chat (Konsumen–Host)
- Notifikasi (in-app, push, email)
- Dashboard Admin & Host

### Phase 2
- Promo & Voucher
- Referral System
- Wishlist
- Review & Rating
- Withdrawal Management
- Corporate Account
- Banner Management

### Phase 3
- CMS (Artikel, FAQ, Syarat & Ketentuan)
- Laporan Lengkap (booking, pendapatan, properti)
- Audit Log
- Multi Role & Permission
- Dashboard Statistik
- Monitoring & Maintenance
- Mobile API untuk Host

---

## Struktur Dokumentasi

```
docs/
├── README.md                                    # Ringkasan proyek & panduan dokumentasi
├── payments/
│   ├── setup.md                                 # Panduan setup Midtrans
│   ├── integration.md                           # Audit integrasi Midtrans
│   ├── flow.md                                  # Alur pembayaran end-to-end
│   ├── remediation.md                           # Daftar tugas perbaikan
│   └── MOBILE_API_INSTALL.md                    # Panduan integrasi mobile API
├── properties/
│   ├── system.md                                # Dokumentasi sistem property
│   └── recommendations.md                       # Algoritma rekomendasi properti
├── features/
│   └── referral.md                              # Sistem referral
├── configuration/
│   ├── admin-panel.md                           # Arsitektur panel admin
│   ├── ui-patterns.md                           # Pola UI standar
│   └── missing-files.md                         # Audit file & relasi yang hilang
└── flutter/
    └── screens.md                               # Referensi layar Flutter
```

### Paket Scaffold Modul (Laravel)

Seluruh modul CRUD 1–24 dihasilkan dari scaffold terpisah:

```
rental-properti-modules-laravel/
├── README.md                                    # Dokumentasi scaffold 24 modul
└── MOBILE_API_INSTALL.md                        # Panduan integrasi REST API mobile
```

- **Cara kerja:** Setiap modul CRUD mengeluarkan migration, model, controller, DataTable, Livewire Form, dan Blade view sesuai pattern yang didokumentasikan di [`configuration/admin-panel.md`](configuration/admin-panel.md).
- **Modul non-CRUD (20, 21, 22, 24):** Hanya controller + view agregasi, tidak punya tabel sendiri.
- **Install:** Copy folder `app/`, `database/`, `resources/`, `routes/` ke project Laravel 12 yang sudah terpasang Sanctum, Livewire, dan Spatie Permission. Lihat [`rental-properti-modules-laravel/README.md`](../rental-properti-modules-laravel/README.md) untuk langkah lengkap.

---

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
# Laravel
php artisan test

# Flutter
flutter test

# Specific test files
php artisan test --filter=PaymentCallbackTest
flutter test test/models/referral_test.dart
```

---

## Kontak & Dukungan

Untuk pertanyaan teknis atau diskusi arsitektur, buat issue di repository project atau hubungi tim development.
