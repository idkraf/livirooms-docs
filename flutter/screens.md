# Flutter Screen Reference

Dokumen ini berisi daftar seluruh layar aplikasi Flutter Sewain yang **benar-benar ada** di kode (`flutter/lib/screens/`), sebagai referensi visual & navigasi untuk pengembangan aplikasi Flutter (mobile — Konsumen & Mitra/Vendor).

## Kebijakan Guest Browsing

Aplikasi mengizinkan pengguna melakukan *browsing* properti tanpa login/daftar:
- **Publik:** Homepage, pencarian, detail properti, dan filter dapat diakses tanpa token.
- **Login Required:** Booking/pembayaran, wishlist, chat, riwayat transaksi, dan profil memerlukan `auth:sanctum`.
- **Flow startup:** `SplashScreen` → `Routes.home` (guest) atau `MainShell` (logged-in).

Seluruh file gambar berada di `flutter/screens_flutter/`, dengan format penamaan:
```
<no_urut>_<nama_layar>.png
```

Total layar aktual: **40 layar** — 28 layar Konsumen + 9 Mitra + 1 Registrasi Host + 2 layar Payment tambahan + Notification.

> ⚠️ **Catatan drift:** Dokumen sebelumnya mencatat 37 layar. Tiga layar tambahan ditemukan di kode namun belum terdokumentasi: `payment_result_screen.dart`, `payment_webview_screen.dart`, dan `notification_screen.dart`.

## Daftar Isi

- [A. Sisi Konsumen (Consumer App)](#a-sisi-konsumen-consumer-app)
  - [1. Onboarding & Autentikasi](#1-onboarding--autentikasi)
  - [2. Registrasi, Profil & Pencarian Properti](#2-registrasi-profil--pencarian-properti)
  - [3. Detail Properti, Booking & Pesan](#3-detail-properti-booking--pesan)
  - [4. Chat, Menu Profil & Wishlist](#4-chat-menu-profil--wishlist)
  - [5. Pembayaran & Ringkasan Pemesanan](#5-pembayaran--ringkasan-pemesanan)
  - [6. Profil & Pengaturan](#6-profil--pengaturan)
  - [7. Notifikasi & Akun Tambahan](#7-notifikasi--akun-tambahan)
- [B. Sisi Mitra / Vendor (Partner App)](#b-sisi-mitra--vendor-partner-app)
  - [8. Rental Management](#8-rental-management)
  - [9. Order Management](#9-order-management)
- [C. Phase 4 — Hotel OTA (Planned)](#c-phase-4--hotel-ota-planned)
- [Struktur Folder Aktual (Flutter)](#struktur-folder-aktual-flutter)
- [Catatan](#catatan)

## A. Sisi Konsumen (Consumer App)

### 1. Onboarding & Autentikasi

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `auth/splash_screen.dart` | `01_splash_screen.png` | Splash Screen | `/splash` | Layar pembuka — logo & nama brand saat aplikasi pertama dibuka |
| `auth/onboarding_screen.dart` | `02_onboarding_slide_intro.png` | Onboarding | `/onboarding` | Slide perkenalan dengan tagline "Find Your Perfect Stay" |
| `auth/welcome_screen.dart` | `03_welcome_screen.png` | Welcome Screen | `/welcome` | Pilihan masuk (Sign In) atau daftar (Sign Up) |
| `auth/login_screen.dart` | `04_login_sign_in.png` | Login | `/login` | Form masuk: Email, Password, Forgot Password |

### 2. Registrasi, Profil & Pencarian Properti

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `auth/register_screen.dart` | `05_create_account.png` | Create Account | `/register` | Form daftar akun baru: Nama, Email, Password |
| `auth/register_profile_screen.dart` | `06_create_your_profile.png` | Create Your Profile | `/register/profile` | Lengkapi profil: foto, nama, lahir, telepon, gender |
| `home/home_screen.dart` | `07_home_beranda.png` | Home / Beranda | `/home` | Beranda: pencarian, notifikasi, seksi rekomendasi properti |
| `home/filter_screen.dart` | `08_filter_by.png` | Filter By | `/search/filter` | Filter pencarian: harga, rating, fasilitas, lokasi |

### 3. Detail Properti, Booking & Pesan

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `property/property_detail_screen.dart` | `09_hotel_details.png` | Property / Hotel Detail | `/property/detail` | Detail properti: galeri, fasilitas, peta, harga, tombol Book Now |
| `property/search_results_screen.dart` | `10_daftar_hasil_pencarian.png` | Hasil Pencarian | `/search/results` | Kartu properti hasil filter/pencarian |
| `booking/booking_detail_screen.dart` | `11_booking_detail.png` | Booking Detail | `/booking/detail` | Ringkasan booking: properti, tanggal, tamu, kode (barcode), status host confirm, tombol bayar |
| `chat/chat_list_screen.dart` | `12_daftar_pesan_chat_list.png` | Daftar Pesan | `/chat` | Inbox percakapan: kontak, pesan terakhir, unread count |

### 4. Chat, Menu Profil & Wishlist

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `chat/chat_room_screen.dart` | `13_chat_percakapan.png` | Chat / Percakapan | `/chat/room` | Ruang obrolan Konsumen–Host |
| `account/account_menu_screen.dart` | `14_menu_profil_account_menu.png` | Menu Akun | `/account` | Menu: Favorite, Security, Notification, Language, Help, Logout |
| `account/edit_profile_screen.dart` | `15_edit_profile_flow.png` | Edit Profile | `/account/edit-profile` | Pembaruan data pribadi: foto, nama, lahir, email, telepon, gender |
| `account/wishlist_screen.dart` | `16_my_favorite_wishlist.png` | My Favorite (Wishlist) | `/wishlist` | Properti favorit dengan filter kategori |

### 5. Pembayaran & Ringkasan Pemesanan

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `payment/payment_method_screen.dart` | `17_select_payment_method.png` | Select Payment Method | `/payment/method` | Pilih metode bayar; Buat Pesanan → `BookingService.create()` |
| `payment/add_card_screen.dart` | `18_add_new_card.png` | Add New Card | `/payment/add-card` | Form tambah kartu: nama pemegang, nomor, tanggal, CVV |
| `payment/promo_code_screen.dart` | `19_promo_code.png` | Promo Code | `/payment/promo` | Input & daftar kode promo/voucher tersedia |
| `booking/booking_success_screen.dart` | `20_booking_success.png` | Booking Success | `/booking/success` | Konfirmasi booking berhasil, tombol lihat detail |
| `booking/booking_list_screen.dart` | `21_my_bookings.png` | My Bookings | `/booking/list` | Riwayat pemesanan pengguna |
| `booking/booking_detail_screen.dart` | `22_booking_details.png` | Booking Details | `/booking/detail` | Rincian lengkap booking (sama dengan layar 11) |
| `payment/payment_webview_screen.dart` | — | Payment WebView | `/payment/webview` | 🆕 WebView Midtrans Snap in-app (alternatif browser eksternal) |
| `payment/payment_result_screen.dart` | — | Payment Result | `/payment/result` | 🆕 Layar hasil pembayaran — dipanggil via deep link `sewain://payment-result` |

### 6. Profil & Pengaturan

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `account/edit_profile_screen.dart` | `23_edit_profile_settings.png` | Edit Profile (Settings) | `/account/edit-profile` | Form pengaturan data pribadi (sama dengan layar 15) |
| `account/wishlist_screen.dart` | `24_favorite_hotels.png` | Favorite Hotels | `/wishlist` | Koleksi properti favorit (sama dengan layar 16) |
| `settings/security_settings_screen.dart` | `25_security_settings.png` | Security Settings | `/settings/security` | Sakelar Face ID, Remember Password, Touch ID |
| `settings/notification_settings_screen.dart` | `26_notification_preferences.png` | Notification Preferences | `/settings/notifications` | Preferensi notifikasi per kategori |
| `settings/help_support_screen.dart` | `27_help_support.png` | Help & Support | `/settings/help` | FAQ yang dapat di-expand/collapse |
| `settings/language_settings_screen.dart` | `28_language.png` | Language | `/settings/language` | Pengaturan bahasa multi-bahasa |

### 7. Notifikasi & Akun Tambahan

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `notification/notification_screen.dart` | — | Notifications | `/notifications` | 🆕 Daftar in-app notification (booking, pembayaran, promo) |
| `account/referral_screen.dart` | — | Referral | `/account/referral` | 🆕 Kode referral, riwayat reward, share kode |
| `account/validation_screen.dart` | — | Validasi Akun (KYC) | `/account/validation` | 🆕 Upload dokumen identitas untuk verifikasi akun |

---

## B. Sisi Mitra / Vendor (Partner App)

### 8. Rental Management

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `mitra/mitra_shell.dart` | — | Mitra Shell | `/mitra` | Bottom navigation shell untuk layar Mitra |
| `mitra/mitra_dashboard_screen.dart` | `29_mitra_dashboard.png` | Dashboard Mitra | `/mitra/dashboard` | Total properti, pesanan hari ini, pendapatan, rating, grafik |
| `mitra/property_management_screen.dart` | `30_mitra_manajemen_properti.png` | Manajemen Properti | `/mitra/properties` | Daftar unit, status, pencarian, tombol tambah |
| `mitra/property_form_screen.dart` | `31_mitra_tambah_edit_properti.png` | Tambah / Edit Properti | `/mitra/properties/form` | Form properti: foto, nama, tipe, alamat, harga, kapasitas, fasilitas |
| `mitra/availability_calendar_screen.dart` | `32_mitra_kalender_ketersediaan.png` | Kalender Ketersediaan | `/mitra/calendar` | Kalender bulanan: blokir tanggal, atur harga khusus |

### 9. Order Management

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| `mitra/order_management_screen.dart` | `33_mitra_manajemen_order.png` | Manajemen Order | `/mitra/orders` | Tab Baru/Dikonfirmasi/Selesai, aksi Terima/Tolak |
| `mitra/order_detail_screen.dart` | `34_mitra_detail_order.png` | Detail Order | `/mitra/orders/detail` | Timeline status, data tamu, rincian pembayaran, konfirmasi |
| `mitra/wallet_screen.dart` | `35_mitra_saldo_penarikan.png` | Saldo & Penarikan | `/mitra/wallet` | Saldo tersedia/tertahan, riwayat penarikan, tombol Tarik Dana |
| `mitra/mitra_profile_screen.dart` | `36_mitra_profil_mitra.png` | Profil Mitra | `/mitra/profile` | Identitas, verifikasi, statistik, rekening bank, dokumen |

### Registrasi Host

| File Kode | Mockup | Nama Layar | Route | Deskripsi |
|-----------|--------|------------|-------|-----------|
| *(belum ada)* | `37_register_host.png` | Daftar Menjadi Host | `/register/host` | ⚠️ Mockup ada di `screens_flutter/` tapi file `.dart` belum dibuat |

---

## C. Phase 4 — Hotel OTA (Planned)

Layar-layar berikut **belum dibuat** namun dirancang untuk modul Hotel OTA (Phase 4). Lihat [hotel/04-flutter-implementation.md](../hotel/04-flutter-implementation.md) untuk spesifikasi lengkap.

| File Kode (Planned) | Nama Layar | Route | Deskripsi |
|---------------------|------------|-------|-----------|
| `hotel/hotel_search_screen.dart` | Hotel Search | `/hotel/search` | Pencarian hotel dengan filter OTA: tanggal, kamar, tamu, bintang |
| `hotel/hotel_results_screen.dart` | Hotel Results | `/hotel/results` | Hasil pencarian hotel dengan quick filter chips |
| `hotel/hotel_detail_screen.dart` | Hotel Detail | `/hotel/detail` | Detail hotel: info bintang, tipe kamar, fasilitas, jam check-in/out |
| `hotel/room_type_screen.dart` | Room Types | `/hotel/rooms` | Daftar tipe kamar dengan harga, kapasitas, fasilitas |
| `hotel/hotel_booking_screen.dart` | Hotel Booking Checkout | `/hotel/booking` | Form pemesanan kamar + pilih asuransi menginap |
| `mitra/hotel_inventory_screen.dart` | Inventaris Kamar Hotel | `/mitra/hotel/inventory` | Kalender allotment & tarif harian per tipe kamar |

---

## Struktur Folder Aktual (Flutter)

Sesuai `flutter/lib/screens/` per 2026-08-13:

```
lib/
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── register_profile_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── filter_screen.dart
│   │   └── main_shell.dart               ← bottom nav shell (Konsumen)
│   ├── property/
│   │   ├── property_detail_screen.dart
│   │   └── search_results_screen.dart
│   ├── booking/
│   │   ├── booking_detail_screen.dart
│   │   ├── booking_list_screen.dart
│   │   └── booking_success_screen.dart
│   ├── chat/
│   │   ├── chat_list_screen.dart
│   │   └── chat_room_screen.dart
│   ├── account/
│   │   ├── account_menu_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── wishlist_screen.dart
│   │   ├── referral_screen.dart          ← 🆕 belum terdokumentasi sebelumnya
│   │   └── validation_screen.dart        ← 🆕 belum terdokumentasi sebelumnya
│   ├── notification/
│   │   └── notification_screen.dart      ← 🆕 belum terdokumentasi sebelumnya
│   ├── payment/
│   │   ├── payment_method_screen.dart
│   │   ├── add_card_screen.dart
│   │   ├── promo_code_screen.dart
│   │   ├── payment_result_screen.dart    ← 🆕 dipanggil via deep link
│   │   └── payment_webview_screen.dart   ← 🆕 WebView Midtrans in-app
│   ├── settings/
│   │   ├── security_settings_screen.dart
│   │   ├── notification_settings_screen.dart
│   │   ├── help_support_screen.dart
│   │   └── language_settings_screen.dart
│   └── mitra/
│       ├── mitra_shell.dart              ← bottom nav shell (Mitra)
│       ├── mitra_dashboard_screen.dart
│       ├── property_management_screen.dart
│       ├── property_form_screen.dart
│       ├── availability_calendar_screen.dart
│       ├── order_management_screen.dart
│       ├── order_detail_screen.dart
│       ├── wallet_screen.dart
│       └── mitra_profile_screen.dart
```

---

## Catatan

- Seluruh nama, foto, dan data pada tangkapan layar bersifat contoh (dummy) untuk demonstrasi desain.
- Layar 29–36 (Mitra/Vendor) mengikuti gaya visual dan palet warna yang sama dengan aplikasi Konsumen (Navy `#0E2340` dan Gold `#F4A93B`).
- `register_host_screen.dart` (**layar 37**) ada mockup-nya (`screens_flutter/37_register_host.png`) namun file `.dart` belum dibuat.
- Layar `payment_webview_screen.dart` dan `payment_result_screen.dart` adalah bagian dari alur pembayaran Midtrans in-app yang sudah ada di kode namun belum didokumentasikan.
- Layar `notification_screen.dart`, `referral_screen.dart`, dan `validation_screen.dart` sudah ada di kode sebagai fitur Phase 3.
