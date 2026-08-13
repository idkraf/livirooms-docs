# Flutter Screen Reference

Dokumen ini berisi daftar seluruh referensi layar aplikasi Flutter Sewain, hasil ekstraksi per-layar dalam format `.png`, sebagai referensi visual untuk pengembangan aplikasi Flutter (mobile — Konsumen & Mitra/Vendor).

## Kebijakan Guest Browsing

Aplikasi mengizinkan pengguna melakukan *browsing* properti tanpa login/daftar:
- **Publik:** Homepage, pencarian, detail properti, dan filter dapat diakses tanpa token.
- **Login Required:** Booking/pembayaran, wishlist, chat, riwayat transaksi, dan profil memerlukan `auth:sanctum`.
- **Flow startup:** `SplashScreen` mengarahkan guest langsung ke `Routes.home`, bukan onboarding.

Seluruh file gambar berada di `flutter/screens_flutter/`, dengan format penamaan:
```
<no_urut>_<nama_layar>.png
```

Total: **37 layar** — 28 layar sisi Konsumen, 8 layar sisi Mitra/Vendor, 1 layar Register Host.

## Daftar Isi

- [A. Sisi Konsumen (Consumer App)](#a-sisi-konsumen-consumer-app)
  - [1. Onboarding & Autentikasi](#1-onboarding--autentikasi)
  - [2. Registrasi, Profil & Pencarian Properti](#2-registrasi-profil--pencarian-properti)
  - [3. Detail Properti, Booking & Pesan](#3-detail-properti-booking--pesan)
  - [4. Chat, Menu Profil & Wishlist](#4-chat-menu-profil--wishlist)
  - [5. Pembayaran & Ringkasan Pemesanan](#5-pembayaran--ringkasan-pemesanan)
  - [6. Profil & Pengaturan](#6-profil--pengaturan)
- [B. Sisi Mitra / Vendor (Partner App)](#b-sisi-mitra--vendor-partner-app)
  - [7. Rental Management](#7-rental-management)
  - [8. Order Management](#8-order-management)
- [Struktur Folder yang Disarankan (Flutter)](#struktur-folder-yang-disarankan-flutter)
- [Catatan](#catatan)

## A. Sisi Konsumen (Consumer App)

### 1. Onboarding & Autentikasi

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `01_splash_screen.png` | Splash Screen | `/splash` | Layar pembuka aplikasi yang menampilkan logo dan nama brand "Sewain" saat aplikasi pertama kali dibuka. |
| `02_onboarding_slide_intro.png` | Onboarding — Slide Intro | `/onboarding` | Slide perkenalan aplikasi dengan tagline "Find Your Perfect Stay, Anytime, Anywhere" beserta deskripsi singkat jangkauan pilihan properti. |
| `03_welcome_screen.png` | Welcome Screen | `/welcome` | Layar sambutan yang mengarahkan pengguna untuk masuk (Sign In) atau mendaftar (Sign Up), dengan opsi login cepat via Apple, Google, Facebook. |
| `04_login_sign_in.png` | Login (Sign In) | `/login` | Form masuk untuk pengguna terdaftar: Email, Password, tautan "Forgot Password", serta tautan menuju halaman pendaftaran. |

### 2. Registrasi, Profil & Pencarian Properti

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `05_create_account.png` | Create Account | `/register` | Form pendaftaran akun baru: Nama Lengkap, Email, Password, persetujuan Syarat & Ketentuan, opsi daftar cepat via Apple/Google/Facebook. |
| `06_create_your_profile.png` | Create Your Profile | `/register/profile` | Lanjutan registrasi untuk melengkapi data diri: foto profil, nama, tanggal lahir, email, telepon, jenis kelamin. |
| `07_home_beranda.png` | Home / Beranda | `/home` | Halaman utama: sapaan pengguna, kolom pencarian, notifikasi, daftar properti "Most Popular" dan "Recommended For You". |
| `08_filter_by.png` | Filter By | `/search/filter` | Layar filter pencarian lanjutan: rentang harga, rating, fasilitas (Wi-Fi, AC, Pool, Parking, Breakfast, GYM), lokasi. |

### 3. Detail Properti, Booking & Pesan

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `09_hotel_details.png` | Hotel Details | `/property/detail` | Detail properti: galeri foto, nama, lokasi, fasilitas umum, deskripsi, peta lokasi, harga/malam, tombol "Book Now". |
| `10_daftar_hasil_pencarian.png` | Daftar Hasil Pencarian | `/search/results` | Daftar kartu properti hasil pencarian/kategori: foto kamar, rating, lokasi, tanggal, jumlah tamu. |
| `11_booking_detail.png` | Booking Detail | `/booking/detail` | Ringkasan pemesanan terkonfirmasi: nama & lokasi properti, peta, tanggal menginap, jumlah tamu, tipe kamar, kode booking (barcode). |
| `12_daftar_pesan_chat_list.png` | Daftar Pesan (Chat List) | `/chat` | Kotak masuk percakapan: daftar kontak (Host/pengguna lain), pesan terakhir, waktu, jumlah pesan belum dibaca. |

### 4. Chat, Menu Profil & Wishlist

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `13_chat_percakapan.png` | Chat / Percakapan | `/chat/room` | Ruang obrolan Konsumen–Host mengenai ketersediaan kamar, dengan kartu ringkas properti, status online, opsi telepon/video call. |
| `14_menu_profil_account_menu.png` | Menu Profil (Account Menu) | `/account` | Menu akun: navigasi ke My Favorite, Security, Notification, Language, Help & Support, Logout. |
| `15_edit_profile_flow.png` | Edit Profile | `/account/edit-profile` | Form pembaruan data pribadi: foto profil, nama, tanggal lahir, email, telepon, jenis kelamin. |
| `16_my_favorite_wishlist.png` | My Favorite (Wishlist) | `/wishlist` | Daftar properti favorit: kolom pencarian, filter kategori (All, Hotel, Villas, Apartment), kartu properti tersimpan. |

### 5. Pembayaran & Ringkasan Pemesanan

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `17_select_payment_method.png` | Select Payment Method | `/payment/method` | Pemilihan metode pembayaran: Master Card, Visa, UPI, PayTM/Wallets, Net Banking, tombol "Confirm And Pay". |
| `18_add_new_card.png` | Add New Card UI | `/payment/add-card` | Form tambah kartu pembayaran baru: kartu visual, Nama Pemegang, Nomor Kartu, Tanggal Kedaluwarsa, CVV. |
| `19_promo_code.png` | Promo Code UI | `/payment/promo` | Layar penerapan kode promo/voucher: input kode, daftar promo tersedia beserta masa berlaku. |
| `20_booking_success.png` | Booking Success | `/booking/success` | Konfirmasi pembayaran & pemesanan berhasil, ilustrasi "Payment Successful", tombol lihat detail booking. |
| `21_my_bookings.png` | My Bookings | `/booking/list` | Daftar riwayat pemesanan pengguna: kartu properti yang dipesan, tanggal menginap, jumlah tamu. |
| `22_booking_details.png` | Booking Details | `/booking/detail` | Rincian lengkap satu pemesanan: properti, peta lokasi, tanggal, tamu, tipe kamar, telepon, kode booking (barcode). |

### 6. Profil & Pengaturan

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `23_edit_profile_settings.png` | Edit Profile | `/settings/profile` | Form pengaturan data pribadi (nama, tanggal lahir, email, telepon, gender) dengan tombol "Save Changes". |
| `24_favorite_hotels.png` | Favorite Hotels | `/settings/favorites` | Koleksi properti favorit dengan filter kategori dan fitur pencarian hotel. |
| `25_security_settings.png` | Security Settings | `/settings/security` | Pengaturan keamanan akun: sakelar Face ID, Remember Password, Touch ID. |
| `26_notification_preferences.png` | Notification Preferences | `/settings/notifications` | Preferensi notifikasi per kategori: New Event, Delivery, Message, Payment. |
| `27_help_support.png` | Help & Support | `/settings/help` | Pusat bantuan: kolom pencarian, daftar FAQ yang dapat di-expand/collapse. |
| `28_language.png` | Language | `/settings/language` | Pengaturan bahasa aplikasi multi-bahasa: English, Indian, Arabic, Chinese, German, Spanish, French. |

---

## B. Sisi Mitra / Vendor (Partner App)

### 7. Rental Management

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `29_mitra_dashboard.png` | Dashboard Mitra | `/mitra/dashboard` | Ringkasan performa Mitra: total properti, pesanan hari ini, pendapatan bulan berjalan, rating rata-rata, grafik pendapatan 6 bulan, pesanan terbaru. |
| `30_mitra_manajemen_properti.png` | Manajemen Properti | `/mitra/properties` | Daftar unit properti milik Mitra dengan status (Aktif/Nonaktif/Maintenance), pencarian, filter status, tombol tambah properti. |
| `31_mitra_tambah_edit_properti.png` | Tambah / Edit Properti | `/mitra/properties/form` | Form kelola properti: upload foto, nama, tipe, alamat, harga/malam, kapasitas, pemilihan fasilitas. |
| `32_mitra_kalender_ketersediaan.png` | Kalender Ketersediaan | `/mitra/calendar` | Kalender bulanan status tanggal (Tersedia/Terisi/Diblokir/Harga Khusus), aksi blokir tanggal & atur harga. |

### 8. Order Management

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `33_mitra_manajemen_order.png` | Manajemen Order | `/mitra/orders` | Daftar pesanan masuk per status (Baru/Dikonfirmasi/Selesai) dengan aksi cepat Terima/Tolak. |
| `34_mitra_detail_order.png` | Detail Order | `/mitra/orders/detail` | Timeline status pesanan (Menunggu → Dikonfirmasi → Check-in → Selesai), data tamu, rincian pembayaran, konfirmasi pesanan. |
| `35_mitra_saldo_penarikan.png` | Saldo & Penarikan | `/mitra/wallet` | Saldo tersedia & tertahan, pendapatan bulan berjalan, total ditarik, tombol Tarik Dana, riwayat penarikan. |
| `36_mitra_profil_mitra.png` | Profil Mitra | `/mitra/profile` | Profil kemitraan: identitas, status verifikasi, rating, statistik (properti/order/response rate), menu rekening bank, dokumen legalitas, bantuan. |

### 9. Registrasi Host

| File | Nama Layar | Suggested Route | Deskripsi |
|------|------------|-----------------|-----------|
| `37_register_host.png` | Daftar Menjadi Host | `/register/host` | Form pendaftaran untuk mitra/host: upload dokumen legalitas, identitas, data rekening bank, verifikasi awal. |

---

## Struktur Folder yang Disarankan (Flutter)

```
lib/
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart            // 01
│   │   ├── onboarding_screen.dart        // 02
│   │   ├── welcome_screen.dart           // 03
│   │   ├── login_screen.dart             // 04
│   │   ├── register_screen.dart          // 05, 06
│   │   └── register_host_screen.dart     // 37
│   ├── home/
│   │   ├── home_screen.dart              // 07
│   │   └── filter_screen.dart            // 08
│   ├── property/
│   │   ├── property_detail_screen.dart   // 09
│   │   └── search_results_screen.dart    // 10
│   ├── booking/
│   │   ├── booking_detail_screen.dart    // 11, 22
│   │   ├── booking_list_screen.dart      // 21
│   │   └── booking_success_screen.dart   // 20
│   ├── chat/
│   │   ├── chat_list_screen.dart         // 12
│   │   └── chat_room_screen.dart         // 13
│   ├── account/
│   │   ├── account_menu_screen.dart      // 14
│   │   ├── edit_profile_screen.dart      // 15, 23
│   │   └── wishlist_screen.dart          // 16, 24
│   ├── payment/
│   │   ├── payment_method_screen.dart    // 17
│   │   ├── add_card_screen.dart          // 18
│   │   └── promo_code_screen.dart        // 19
│   ├── settings/
│   │   ├── security_settings_screen.dart       // 25
│   │   ├── notification_settings_screen.dart   // 26
│   │   ├── help_support_screen.dart             // 27
│   │   └── language_settings_screen.dart        // 28
│   └── mitra/
│       ├── mitra_dashboard_screen.dart          // 29
│       ├── property_management_screen.dart      // 30
│       ├── property_form_screen.dart            // 31
│       ├── availability_calendar_screen.dart    // 32
│       ├── order_management_screen.dart         // 33
│       ├── order_detail_screen.dart              // 34
│       ├── wallet_screen.dart                    // 35
│       └── mitra_profile_screen.dart             // 36
```

---

## Catatan

- Seluruh nama, foto, dan data pada tangkapan layar bersifat contoh (dummy) untuk keperluan demonstrasi desain antarmuka, dan tidak merepresentasikan data pengguna sebenarnya.
- Layar 29–36 (sisi Mitra/Vendor) merupakan rancangan antarmuka baru yang dibangun mengikuti gaya visual dan palet warna yang sama dengan aplikasi Konsumen (Navy `#0E2340` dan Gold `#F4A93B`) agar identitas merek Sewain tetap konsisten di kedua sisi aplikasi.
- Rasio/dimensi asli gambar bervariasi tergantung sumber ekstraksi — sesuaikan ulang ke ukuran target device saat diimplementasikan di Flutter.
