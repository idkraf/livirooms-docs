# Flutter Screen Reference

Dokumen ini berisi daftar seluruh layar aplikasi Flutter Sewain berdasarkan **kondisi kode aktual** di `flutter/lib/` per 2026-08-16. Kolom **Status** menunjukkan apakah file `.dart` sudah ada atau belum.

> **Modul Hotel:** untuk detail per-layar, aset mockup, payload API, dan design system, lihat **[hotel/screen/readme_screen.md](../hotel/screen/readme_screen.md)** — dokumen itu adalah Master Reference modul Hotel.

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
- [C. Hotel OTA (Screens Selesai Dibuat)](#c-hotel-ota-screens-selesai-dibuat)
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

Modul pencarian hotel, hasil filter, detail 8 tab, dan form booking checkout sudah dibuat dan **semuanya sudah terdaftar di `router.dart`**. Lihat [hotel/04-flutter-implementation.md](../hotel/04-flutter-implementation.md) dan **[hotel/screen/readme_screen.md](../hotel/screen/readme_screen.md)** (Master Reference: 40 layar/komponen, aset, payload, design system).

| Status | File Kode | Route | Nama Layar | Layar di Master Ref | Deskripsi & Infrastruktur |
|--------|-----------|-------|------------|---------------------|---------------------------|
| ✅ | `property/hotel/hotel_search_screen.dart` | `/hotel/search` | Hotel Search & Filter | #1–#6 | Destinasi populer, tanggal check-in/out, counter kamar/tamu, modal filter harga/bintang |
| ✅ | `property/hotel/hotel_results_screen.dart` | `/hotel/results` | Hotel Results | #7–#16 | List hotel card, filter chips, banner diskon, trust modal sheet |
| ✅ | `property/hotel/hotel_detail_screen.dart` | `/hotel/detail` | Hotel Detail (8 Tab) | #17–#25 | Hero gallery, Kamar, Ulasan, Lokasi, Fasilitas, Kebijakan, Keterangan, Trip Moments, Akomodasi Terdekat |
| ✅ | `property/hotel/hotel_booking_screen.dart` | `/hotel/booking` | Hotel Booking Checkout | #26–#32 | Ringkasan kamar, form data tamu per kamar, info kontak, Trip Coins, jaminan harga |
| ✅ | `mitra/hotel_form_screen.dart` | `/mitra/hotels/form` | Form Wizard Registrasi Hotel | — (sisi mitra) | 5-Step pendaftaran hotel & kamar mitra (Info, Fasilitas, Kamar, Inventaris, Galeri) |

**Komponen yang belum ada** (detail di [readme_screen.md §14.2](../hotel/screen/readme_screen.md#142-yang-belum-ada-di-hotel_booking_screendart)):

| Kekurangan | Layar Master Ref |
|---|---|
| Bottom sheet kode promo | #36 |
| Bottom sheet permintaan khusus | #37 |
| Bottom sheet informasi tambahan | #33 |
| Bottom sheet detail kamar (Family Suite / Kamar Superior) | #34, #35 |
| Ringkasan kamar masih hardcode via `_roomSummary(...)` | #27 |
| Seksi Trip Coins expandable | #29, #31, #32 |
| Top modal tanggal & tamu (paket `top_modal_sheet` **tidak ada** di `pubspec.yaml`) | #12–#16 |

---

## Struktur Lengkap Flutter (`flutter/lib/`)

```
flutter/lib/
├── main.dart
├── router.dart                                   (44 named route terdaftar)
│
├── config/
│   └── app_config.dart
│
├── models/                                        (24 model)
│   ├── api_response.dart
│   ├── app_banner.dart
│   ├── app_notification.dart
│   ├── booking.dart                               + BookingRoom, RoomType, BookingInsuranceSummary
│   ├── chat.dart
│   ├── city.dart
│   ├── host_dashboard.dart
│   ├── host_info.dart
│   ├── hotel.dart                                 Hotel OTA model
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
│                                                  ⚠️ memakai PropertyService.searchHotels()
│
├── services/                                      (19 service)
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
│   ├── hotel_service.dart                         Hotel OTA service
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
└── screens/                                       (45 file — 44 punya named route;
                                                     home_screen.dart = tab di MainShell)
    ├── auth/          (6 file)  ✅ splash, onboarding, welcome, login, register, register_profile
    ├── home/          (3 file)  ✅ main_shell, home_screen, filter_screen
    ├── property/      (2 file)  ✅ property_detail, search_results
    │   └── hotel/     (4 file)  ✅ hotel_search, hotel_results, hotel_detail, hotel_booking
    ├── booking/       (3 file)  ✅ booking_detail, booking_list, booking_success
    ├── chat/          (2 file)  ✅ chat_list, chat_room
    ├── account/       (5 file)  ✅ account_menu, edit_profile, wishlist, referral, validation
    ├── payment/       (5 file)  ✅ payment_method, payment_webview, payment_result, add_card, promo
    ├── settings/      (4 file)  ✅ security, notification_settings, help_support, language
    ├── notification/  (1 file)  ✅ notification_screen
    └── mitra/         (10 file) ✅ shell, dashboard, property_mgmt, property_form, calendar,
                                    order_mgmt, order_detail, wallet, mitra_profile, hotel_form
```

---

## Ringkasan Status

| Kategori | Selesai | Belum |
|----------|---------|-------|
| **Screens** | **45** file | 1 Register Host |
| **Named route di `router.dart`** | **44** | 0 — semua layar Hotel OTA **sudah** terdaftar |
| **Models** | 24 | 0 |
| **Services** | 19 | 0 |
| **Providers** | 2 | 0 |
| **Widgets** | 5 | 0 |
| **Test (`flutter/test/`)** | **17 file** | lihat catatan cakupan di bawah |

> `router.dart` punya 44 konstanta route dan 44 `case Routes.*` yang berpasangan tepat. Selisih 45 vs 44 adalah `home_screen.dart`, yang dirender sebagai tab di dalam `MainShell` dan memang tidak punya named route.

### Cakupan Test Flutter

`flutter/test/` berisi **17 file**, **6 di antaranya sudah menyentuh Hotel/asuransi**:

| File test | Cakupan |
|---|---|
| `models/hotel_test.dart` | 6 test — parsing `Hotel` minimal & lengkap (metadata 8 tab), `HotelRoomItem`, `HotelPolicy` default, `HotelGuestInput.toJson()`, `HotelFacilityGroup` kosong |
| `services/hotel_service_test.dart` | 9 test — `searchHotels`, `getHotelDetail`, `getRoomTypes` (**delegasi ke `getHotelDetail`**), `getInsurancePlans`, `createHotelBooking` (payload lengkap & tanpa field opsional), `createHotelForProperty` |
| `providers/hotel_search_provider_test.dart` | 2 test — initial state, search memperbarui query & memuat hotel |
| `models/hotel_search_query_test.dart` | 2 test — query params default, parsing deep link `sewain://search` |
| `widgets/hotel_screens_test.dart` | 8 `testWidgets` — render `HotelSearchScreen`, `HotelResultsScreen`, `HotelDetailScreen`, `HotelBookingScreen`, `HotelFormScreen` (mode tambah/edit, default 3 bintang, 5 label tab) |
| `models/insurance_plan_test.dart` | 4 test — premi fixed per malam (1 & banyak tamu, samakan dengan Laravel), premi persentase, parsing JSON |

Sisanya (11 file) di luar modul Hotel: `widget_test.dart`, `api_envelope_test.dart`, `utils/formatters_test.dart`, `models/{property,property_recommendation,booking,payment,referral}_test.dart`, `services/{booking,property,referral}_service_test.dart`.

> ⚠️ **Celah yang sudah dipastikan:** `models/hotel_search_query_test.dart` selalu mengirim `city_id` pada URI-nya, sedangkan `HotelSearchQuery.fromUri()` memakai `q['city_id']!` tanpa fallback — deep link tanpa `city_id` masih *crash* dan belum tertutup test. Lihat A-D7 di [readme_screen.md §11.3](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel).

---

## Catatan

- `register_host_screen.dart` belum dibuat -- mockup ada di `screens_flutter/37_register_host.png`.
- **Hotel OTA:** 4 layar konsumen (`property/hotel/`) + 1 layar mitra (`mitra/hotel_form_screen.dart`) **sudah dibuat dan sudah terdaftar** di `router.dart`. Yang belum lengkap adalah bottom sheet di dalam layar checkout — lihat tabel "Komponen yang belum ada" di [bagian C](#c-hotel-ota-screens-selesai-dibuat).
- `InsuranceSelectionWidget` sudah dipakai di alur checkout hotel (Stay Protection).
- ⚠️ `hotel_search_provider.dart` memanggil `PropertyService.searchHotels()` (`GET properties`), bukan `HotelService` (`GET hotels`) — field khusus hotel (skor, jumlah ulasan, jarak, tag) hilang. Detail & rencana perbaikan: [readme_screen.md §11.3 A-D6](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel).
- ⚠️ `HotelService.getHotelFilters()` dan `HotelService.createHotelBooking()` memanggil endpoint yang **tidak ada** di `routes/api_mobile.php` (`GET hotel/filters`, `POST hotel/bookings`) → 404 di mode API nyata. Lihat A-D4 & A-D5 pada dokumen yang sama.
- ⚠️ Paket `top_modal_sheet` **tidak terpasang** di `flutter/pubspec.yaml` — top modal harus dibuat manual (`showGeneralDialog` + `SlideTransition`).
- Bahasa kode: **Inggris**. Bahasa docs: **Indonesia**.
