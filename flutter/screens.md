# Flutter Screen Reference

Dokumen ini berisi daftar seluruh layar aplikasi Flutter Sewain berdasarkan **kondisi kode aktual** di `flutter/lib/` per 2026-08-13. Kolom **Status** menunjukkan apakah file `.dart` sudah ada atau belum.

> **Legend**: ✅ Sudah ada dan terdaftar di router · ❌ Belum dibuat

## Kebijakan Guest Browsing

Aplikasi mengizinkan pengguna melakukan *browsing* properti tanpa login/daftar:
- **Publik:** Homepage, pencarian, detail properti, dan filter dapat diakses tanpa token.
- **Login Required:** Booking/pembayaran, wishlist, chat, riwayat transaksi, dan profil memerlukan `auth:sanctum`.
- **Flow startup:** `SplashScreen` -> `Routes.home` (guest) atau `MainShell` (logged-in).

---

## Daftar Isi

- [A. Sisi Konsumen (Consumer App)](#a-sisi-konsumen-consumer-app)
- [B. Sisi Mitra / Vendor (Partner App)](#b-sisi-mitra--vendor-partner-app)
- [C. Hotel OTA (Planned -- Belum Dibuat)](#c-hotel-ota-planned--belum-dibuat)
- [Struktur Lengkap Flutter](#struktur-lengkap-flutter-flutterlib)
- [Ringkasan Status](#ringkasan-status)
- [Catatan](#catatan)

---

## A. Sisi Konsumen (Consumer App)

### 1. Onboarding & Autentikasi

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `auth/splash_screen.dart` | `/splash` | Splash Screen | Logo & brand saat app pertama dibuka |
| ✅ | `auth/onboarding_screen.dart` | `/onboarding` | Onboarding | Slide perkenalan "Find Your Perfect Stay" |
| ✅ | `auth/welcome_screen.dart` | `/welcome` | Welcome Screen | Pilih Sign In atau Sign Up |
| ✅ | `auth/login_screen.dart` | `/login` | Login | Form masuk: Email, Password, Forgot Password |
| ✅ | `auth/register_screen.dart` | `/register` | Create Account | Form daftar: Nama, Email, Password |
| ✅ | `auth/register_profile_screen.dart` | `/register/profile` | Create Profile | Foto, nama, lahir, telepon, gender |

### 2. Home & Pencarian

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `home/main_shell.dart` | `/home` | Main Shell | Bottom navigation shell Konsumen (4 tab) |
| ✅ | `home/home_screen.dart` | `/home` (tab) | Home / Beranda | Pencarian, banner promo, seksi rekomendasi properti |
| ✅ | `home/filter_screen.dart` | `/search/filter` | Filter By | Filter: harga, rating, fasilitas, tipe properti, lokasi |
| ✅ | `property/search_results_screen.dart` | `/search/results` | Hasil Pencarian | Kartu properti dari hasil filter/keyword |
| ✅ | `property/property_detail_screen.dart` | `/property/detail` | Property Detail | Galeri, fasilitas, peta, harga, tombol Book Now |

### 3. Booking

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `booking/booking_detail_screen.dart` | `/booking/detail` | Booking Detail | Tanggal, tamu, status, barcode, bayar. Tampilkan asuransi jika `has_insurance = true` |
| ✅ | `booking/booking_list_screen.dart` | `/booking/list` | My Bookings | Riwayat pesanan dengan filter status |
| ✅ | `booking/booking_success_screen.dart` | `/booking/success` | Booking Success | Konfirmasi berhasil, tombol lihat detail |

### 4. Pembayaran

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `payment/payment_method_screen.dart` | `/payment/method` | Select Payment Method | Pilih metode bayar; panggil `BookingService.create()` |
| ✅ | `payment/payment_webview_screen.dart` | `/payment/webview` | Payment WebView | WebView Midtrans Snap in-app |
| ✅ | `payment/payment_result_screen.dart` | `/payment/result` | Payment Result | Hasil pembayaran via deep link `sewain://payment-result` |
| ✅ | `payment/add_card_screen.dart` | `/payment/add-card` | Add New Card | Form kartu kredit/debit |
| ✅ | `payment/promo_code_screen.dart` | `/payment/promo` | Promo Code | Input & daftar voucher tersedia |

### 5. Chat

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `chat/chat_list_screen.dart` | `/chat` | Daftar Pesan | Inbox: kontak, pesan terakhir, unread count |
| ✅ | `chat/chat_room_screen.dart` | `/chat/room` | Chat / Percakapan | Ruang obrolan Konsumen-Host |

### 6. Akun & Profil

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `account/account_menu_screen.dart` | `/account` | Menu Akun | Favorite, Security, Notification, Language, Help, Logout |
| ✅ | `account/edit_profile_screen.dart` | `/account/edit-profile` | Edit Profile | Foto, nama, lahir, email, telepon, gender |
| ✅ | `account/wishlist_screen.dart` | `/wishlist` | My Favorite (Wishlist) | Properti favorit |
| ✅ | `account/referral_screen.dart` | `/referral` | Referral | Kode referral, riwayat reward, share kode |
| ✅ | `account/validation_screen.dart` | `/account/validation` | Validasi Akun (KYC) | Upload dokumen identitas |

### 7. Notifikasi & Pengaturan

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `notification/notification_screen.dart` | `/notifications` | Notifications | In-app notification: booking, pembayaran, promo |
| ✅ | `settings/security_settings_screen.dart` | `/settings/security` | Security Settings | Face ID, Remember Password, Touch ID |
| ✅ | `settings/notification_settings_screen.dart` | `/settings/notifications` | Notification Preferences | Preferensi per kategori |
| ✅ | `settings/help_support_screen.dart` | `/settings/help` | Help & Support | FAQ expand/collapse |
| ✅ | `settings/language_settings_screen.dart` | `/settings/language` | Language | Pengaturan bahasa |

---

## B. Sisi Mitra / Vendor (Partner App)

| Status | File Kode | Route | Nama Layar | Deskripsi |
|--------|-----------|-------|------------|-----------|
| ✅ | `mitra/mitra_shell.dart` | `/mitra` | Mitra Shell | Bottom navigation shell Mitra (4 tab) |
| ✅ | `mitra/mitra_dashboard_screen.dart` | `/mitra/dashboard` | Dashboard Mitra | Properti, pesanan, pendapatan, rating, grafik |
| ✅ | `mitra/property_management_screen.dart` | `/mitra/properties` | Manajemen Properti | Daftar unit, status, pencarian, tambah |
| ✅ | `mitra/property_form_screen.dart` | `/mitra/properties/form` | Tambah / Edit Properti | Form: foto, nama, tipe, alamat, harga, fasilitas |
| ✅ | `mitra/availability_calendar_screen.dart` | `/mitra/calendar` | Kalender Ketersediaan | Blokir tanggal, harga khusus |
| ✅ | `mitra/order_management_screen.dart` | `/mitra/orders` | Manajemen Order | Tab Baru/Dikonfirmasi/Selesai, Terima/Tolak |
| ✅ | `mitra/order_detail_screen.dart` | `/mitra/orders/detail` | Detail Order | Timeline, data tamu, rincian pembayaran |
| ✅ | `mitra/wallet_screen.dart` | `/mitra/wallet` | Saldo & Penarikan | Saldo, riwayat, Tarik Dana |
| ✅ | `mitra/mitra_profile_screen.dart` | `/mitra/profile` | Profil Mitra | Identitas, verifikasi, statistik, rekening bank |
| ❌ | *(belum dibuat)* | `/register/host` | Daftar Menjadi Host | Mockup `37_register_host.png` ada, file `.dart` belum dibuat |

---

## C. Hotel OTA (Screens Selesai Dibuat)

Modul pencarian hotel, hasil filter, detail 8 tab, dan form booking checkout telah dibuat lengkap dengan service & sample JSON mock. Lihat [hotel/04-flutter-implementation.md](../hotel/04-flutter-implementation.md) dan [hotel/screen/readme_screen.md](../hotel/screen/readme_screen.md).

| Status | File Kode | Route | Nama Layar | Deskripsi & Infrastruktur |
|--------|-----------|-------|------------|---------------------------|
| ✅ | `property/hotel/hotel_search_screen.dart` | `/hotel/search` | Hotel Search & Filter | Destinasi populer, tanggal check-in/out, counter kamar/tamu, modal filter harga/bintang |
| ✅ | `property/hotel/hotel_results_screen.dart` | `/hotel/results` | Hotel Results | List hotel card, filter chips, banner diskon, trust modal sheet |
| ✅ | `property/hotel/hotel_detail_screen.dart` | `/hotel/detail` | Hotel Detail (8 Tab) | Hero gallery, Kamar, Ulasan, Lokasi, Fasilitas, Kebijakan, Keterangan, Trip Moments, Akomodasi Terdekat |
| ✅ | `property/hotel/hotel_booking_screen.dart` | `/hotel/booking` | Hotel Booking Checkout | Ringkasan kamar, form data tamu per kamar, info kontak, Trip Coins, jaminan harga |
| ✅ | `mitra/hotel_form_screen.dart` | `/mitra/hotels/form` | Form Wizard Registrasi Hotel | 5-Step pendaftaran hotel & kamar mitra (Info, Fasilitas, Kamar, Inventaris, Galeri) |


---

## Struktur Lengkap Flutter (`flutter/lib/`)

```
flutter/lib/
├── main.dart
├── router.dart                                   (41 route terdaftar)
│
├── config/
│   └── app_config.dart
│
├── models/                                        (23 model)
│   ├── api_response.dart
│   ├── app_banner.dart
│   ├── app_notification.dart
│   ├── booking.dart                               + BookingRoom, RoomType, BookingInsuranceSummary
│   ├── chat.dart
│   ├── city.dart
│   ├── host_dashboard.dart
│   ├── host_info.dart
│   ├── hotel_search_query.dart                    Hotel OTA value object
│   ├── insurance_plan.dart                        Stay Protection model
│   ├── order.dart
│   ├── paginated.dart
│   ├── payment.dart
│   ├── payment_method.dart
│   ├── property.dart                              + bookingMode, starRating, checkIn/OutTime
│   ├── property_recommendation.dart
│   ├── referral.dart
│   ├── remote_config_model.dart
│   ├── review.dart
│   ├── user.dart
│   ├── validation_status.dart
│   ├── voucher.dart
│   └── wallet.dart
│
├── providers/                                     (2 provider)
│   ├── auth_provider.dart
│   └── hotel_search_provider.dart                 Hotel OTA: 300ms debounce, race-safe token
│
├── services/                                      (18 service)
│   ├── api_client.dart
│   ├── auth_service.dart
│   ├── auth_storage.dart
│   ├── booking_service.dart                       + hotel & insurance params di create()
│   ├── chat_service.dart
│   ├── city_service.dart
│   ├── content_service.dart
│   ├── deep_link_handler.dart                     + sewain://search parsing
│   ├── dummy_api_client.dart                      + GET insurance/plans route
│   ├── home_service.dart
│   ├── host_service.dart
│   ├── notification_service.dart
│   ├── profile_service.dart
│   ├── property_service.dart                      + searchHotels(), getInsurancePlans()
│   ├── referral_service.dart
│   ├── remote_config_service.dart
│   ├── voucher_service.dart
│   └── wishlist_service.dart
│
├── utils/                                         (1 util)
│   └── formatters.dart
│
├── widgets/                                       (5 widget)
│   ├── app_network_image.dart
│   ├── city_list.dart
│   ├── insurance_selection_widget.dart            Stay Protection checkout UI
│   ├── property_card.dart
│   └── state_views.dart
│
└── screens/                                       (41 file, semua terdaftar di router)
    ├── auth/          (6 file)  ✅ splash, onboarding, welcome, login, register, register_profile
    ├── home/          (3 file)  ✅ main_shell, home_screen, filter_screen
    ├── property/      (2 file)  ✅ property_detail, search_results
    ├── booking/       (3 file)  ✅ booking_detail, booking_list, booking_success
    ├── chat/          (2 file)  ✅ chat_list, chat_room
    ├── account/       (5 file)  ✅ account_menu, edit_profile, wishlist, referral, validation
    ├── payment/       (5 file)  ✅ payment_method, payment_webview, payment_result, add_card, promo
    ├── settings/      (4 file)  ✅ security, notification_settings, help_support, language
    ├── notification/  (1 file)  ✅ notification_screen
    ├── mitra/         (9 file)  ✅ shell, dashboard, property_mgmt, property_form, calendar,
    │                               order_mgmt, order_detail, wallet, mitra_profile
    └── hotel/         (0 file)  ❌ 6 screen planned, infrastruktur siap
```

---

## Ringkasan Status

| Kategori | Selesai | Belum |
|----------|---------|-------|
| **Screens (terdaftar di router)** | **41** | 6 Hotel OTA + 1 Register Host |
| **Models** | 23 | 0 |
| **Services** | 18 | 0 |
| **Providers** | 2 | 0 |
| **Widgets** | 5 | 0 |
| **Routes di `router.dart`** | 41 | 6 Hotel OTA belum didaftarkan |

---

## Catatan

- `register_host_screen.dart` belum dibuat -- mockup ada di `screens_flutter/37_register_host.png`.
- **Hotel OTA screens (6)** belum dibuat. Infrastruktur penuh sudah live & teruji 100%.
- `InsuranceSelectionWidget` siap dipakai saat `hotel_booking_screen.dart` dibangun.
- Route Hotel OTA perlu ditambahkan ke `router.dart` saat masing-masing screen dibuat.
- Bahasa kode: **Inggris**. Bahasa docs: **Indonesia**.
