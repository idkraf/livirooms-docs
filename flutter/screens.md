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
| ✅ | `property/hotel/hotel_booking_screen.dart` | `/hotel/booking` | Hotel Booking Checkout | #26–#32 | Ringkasan kamar (data asli `room_types`), form data tamu per kamar, info kontak, Trip Coins, jaminan harga, baris permintaan khusus + baris kode promo |
| ✅ | `property/hotel/special_request_sheet.dart` | — (bottom sheet) | Permintaan Khusus | #37 | C-31 + C-30. Radio bed/lift (bisa toggle off) + checkbox + catatan ber-`maxLength` **dinamis** dari anggaran 500 char/booking. Publik agar terjangkau widget test |
| ✅ | `property/hotel/promo_code_sheet.dart` | — (bottom sheet) | Kode Promo | #36 | C-34 + C-35 + C-33. Katalog `GET vouchers`, verifikasi lewat `POST vouchers/apply` (satu-satunya oracle kelayakan), kartu di-dim `opacity 0.6` + alasan server, **1 voucher per booking** |
| ✅ | `property/hotel/additional_info_sheet.dart` | — (bottom sheet) | Informasi Tambahan | #33 | C-32, read-only. Isi **diturunkan** dari `Hotel` lewat `additionalInfoEntries()` — deposit (`hotels.deposit_amount`), kebijakan anak, ranjang tambahan — sehingga `(N)` di baris pemicu (`AdditionalInfoSection`) tak mungkin berselisih dengan isi sheet. Bagian kosong dibuang |
| ✅ | `property/hotel/room_detail_sheet.dart` | — (bottom sheet) | Detail Kamar | #34 **+** #35 | C-39, read-only, `heightFactor: 0.92`. **Satu** sheet dengan **baris pil pemindah tipe kamar** — #34 dan #35 adalah dua state pil dari komponen yang sama, bukan dua layar. Galeri, spesifikasi, `Opsi 1`/`Opsi 2` (turunan `bed_configuration`), `Fasilitas Kamar` (6 + "Tampilkan semua"), dan 2 seksi chevron kebijakan; seksi tanpa data **hilang**, bukan dirender kosong. Dipicu dari kartu kamar #27 **dan** baris `Detail kamar` #31 lewat `showRoomDetailSheet()`; pil di-dedup oleh fungsi murni `distinctRoomTypes()` |
| ✅ | `mitra/hotel_form_screen.dart` | `/mitra/hotels/form` | Form Wizard Registrasi Hotel | — (sisi mitra) | 5-Step pendaftaran hotel & kamar mitra (Info, Fasilitas, Kamar, Inventaris, Galeri) |

**Komponen yang belum ada** — status per 16 Agt 2026, detail di [readme_screen.md §15.2](../hotel/screen/readme_screen.md#152-flutter):

| Kekurangan | Layar Master Ref | Item |
|---|---|---|
| ~~Bottom sheet kode promo~~ | #36 | ✅ **selesai** — F-5, `promo_code_sheet.dart` |
| ~~Bottom sheet permintaan khusus~~ | #37 | ✅ **selesai** — F-4, `special_request_sheet.dart` |
| ~~Ringkasan kamar masih hardcode via `_roomSummary(...)`~~ | #27 | ✅ **selesai** — F-8, lewat rantai `HotelDetailArgs` → `HotelBookingArgs` |
| ~~Bottom sheet informasi tambahan~~ | #33 | ✅ **selesai** — F-6, `additional_info_sheet.dart` (kolom `deposit_amount` ternyata sudah ada di server tapi tak pernah di-parse Flutter) |
| ~~Bottom sheet detail kamar (Family Suite / Kamar Superior)~~ | #34, #35 | ✅ **selesai** — F-7, `room_detail_sheet.dart`. **Satu** komponen untuk kedua layar (pil pemindah tipe kamar), dan `properties.cancellation_policy` yang tak pernah diratakan `show()` ikut ditambal di Laravel |
| Top modal tanggal & tamu (paket `top_modal_sheet` **tidak ada** di `pubspec.yaml` → harus dibuat manual) | #12–#16 | ⏳ F-9 |
| Seksi Trip Coins expandable | #29, #31, #32 | ⏳ F-10 |
| Kartu daftar booking belum membedakan `booking_type` room vs unit | #38 | ⏳ F-12 |

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
├── models/                                        (26 model)
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
│   ├── promo_voucher.dart                          Hotel #36: PromoCandidate + VoucherCheck
│   ├── property.dart                              + bookingMode, starRating, checkIn/OutTime
│   ├── property_recommendation.dart
│   ├── referral.dart
│   ├── remote_config_model.dart
│   ├── review.dart
│   ├── special_request.dart                        Hotel #37: anggaran 500 char/booking
│   ├── user.dart
│   ├── validation_status.dart
│   ├── voucher.dart                                + startsAt/endsAt (jendela berlaku #36)
│   └── wallet.dart
│
├── providers/                                     (2 provider)
│   ├── auth_provider.dart
│   └── hotel_search_provider.dart                 Hotel OTA: 300ms debounce, race-safe token
│                                                  ✅ lewat HotelService (GET hotels) — A-D6 beres
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
│   ├── voucher_service.dart                       + check() → POST vouchers/apply (oracle #36)
│   └── wishlist_service.dart
│
├── utils/                                         (2 util)
│   ├── formatters.dart                            + dayMonthYearDotTime (jendela voucher #36)
│   └── promo_labels.dart                          label voucher (dipakai #36 & /payment/promo)
│
├── widgets/                                       (5 widget)
│   ├── app_network_image.dart
│   ├── city_list.dart
│   ├── insurance_selection_widget.dart            Stay Protection checkout UI
│   ├── property_card.dart
│   └── state_views.dart
│
└── screens/                                       (49 file — 45 layar, 44 punya named route;
                                                     home_screen.dart = tab di MainShell;
                                                     4 file bottom sheet Hotel tanpa route)
    ├── auth/          (6 file)  ✅ splash, onboarding, welcome, login, register, register_profile
    ├── home/          (3 file)  ✅ main_shell, home_screen, filter_screen
    ├── property/      (2 file)  ✅ property_detail, search_results
    │   └── hotel/     (8 file)  ✅ hotel_search, hotel_results, hotel_detail, hotel_booking,
    │                               special_request_sheet (#37), promo_code_sheet (#36),
    │                               additional_info_sheet (#33), room_detail_sheet (#34+#35)
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
| **File di `screens/`** | **49** file (45 layar + 4 bottom sheet Hotel) | 1 Register Host |
| **Named route di `router.dart`** | **44** | 0 — semua layar Hotel OTA **sudah** terdaftar |
| **Models** | 26 | 0 |
| **Services** | 19 | 0 |
| **Providers** | 2 | 0 |
| **Widgets** | 5 | 0 |
| **Utils** | 2 | 0 |
| **Test (`flutter/test/`)** | **20 file** berisi test — 209 deklarasi, **273 test saat dijalankan** | lihat catatan cakupan di bawah |

> `router.dart` punya 44 konstanta route dan 44 `case Routes.*` yang berpasangan tepat. Selisih 49 vs 44: `home_screen.dart` dirender sebagai tab di dalam `MainShell`, sedangkan `special_request_sheet.dart`, `promo_code_sheet.dart`, `additional_info_sheet.dart`, dan `room_detail_sheet.dart` adalah bottom sheet yang dibuka dari layar checkout (`showSpecialRequestSheet()` / `showPromoCodeSheet()` / `showAdditionalInfoSheet()` / `showRoomDetailSheet()`) — kelimanya memang tidak punya named route.

### Cakupan Test Flutter

`flutter/test/` berisi **20 file berisi test** + 1 helper tanpa test (`support/fake_voucher_api.dart`). Di dalamnya ada **209 deklarasi `test()`/`testWidgets()`**, tetapi jumlah test yang benar-benar dijalankan adalah **273**: satu deklarasi di `api_envelope_test.dart:136` berada di dalam loop `for (final key in requests.keys)` sehingga menghasilkan **65** test — satu per rute di tabel `DummyApiClient`. Jadi 209 − 1 + 65 = 273.

> 🟡 Angka di atas dihitung statis dari kode (grep deklarasi + hitung entri `requests`), **belum** dari output `flutter test` — suite belum dijalankan di lingkungan ini. Lihat baris "Belum dijalankan" di [readme_screen.md §17](../hotel/screen/readme_screen.md#17-catatan-revisi).

**11 file menyentuh Hotel / asuransi / voucher:**

| File test | Deklarasi | Cakupan |
|---|---|---|
| `widgets/hotel_screens_test.dart` | 44 | Render 5 layar Hotel + sheet permintaan khusus #37 + sheet kode promo #36 + sheet informasi tambahan #33 + sheet detail kamar #34/#35 + integrasi end-to-end di layar booking |
| `models/special_request_test.dart` | 20 | Anggaran 500 char/booking, toggle radio, katalog label, serialisasi #37 |
| `models/promo_voucher_test.dart` | 15 | `PromoCandidate`, `VoucherCheck`, label & jendela berlaku voucher (#36) |
| `models/hotel_test.dart` | 15 | Parsing `Hotel` (metadata 8 tab + `deposit_amount` + `cancellation_policy` rata/bersarang), `HotelRoomItem` (harga `decimal:2` berbentuk string, `bedOptions`, `facilities`, `images` objek), `HotelPolicy`, `HotelGuestInput.toJson()` |
| `models/hotel_search_query_test.dart` | 11 | Query params default, deep link `sewain://search`, `city_id` absen (A-D7) |
| `services/hotel_service_test.dart` | 10 | `searchHotels`, `getHotelDetail`, `getRoomTypes`, `getInsurancePlans`, `createHotelBooking`, `createHotelForProperty` |
| `providers/hotel_search_provider_test.dart` | 6 | Initial state, debounce, race-safe token, search memuat hotel via `HotelService` |
| `services/voucher_service_test.dart` | 6 | `check()` → `POST vouchers/apply`: verdict, penolakan sebagai *value*, `errors.code`, rethrow galat jaringan, cashback nol |
| `models/insurance_plan_test.dart` | 4 | Premi fixed per malam & persentase, parsing JSON |
| `utils/formatters_test.dart` | 14 | Termasuk `dayMonthYearDotTime` untuk jendela berlaku voucher (#36) |
| `support/fake_voucher_api.dart` | 0 | Helper: `FakeVoucherTransport` + fixture voucher, dipakai 2 file test |

> Rincian per-test (ID T-F1…T-F71, T-L1…T-L39) dipelihara **hanya** di [readme_screen.md §15.3](../hotel/screen/readme_screen.md#153-daftar-test) agar tidak ada dua salinan angka yang bisa saling menyimpang.

Sisanya di luar modul Hotel: `widget_test.dart`, `api_envelope_test.dart` (87 test: 22 statis + 65 generated), `models/{property,property_recommendation,booking,payment,referral}_test.dart`, `services/{booking,property,referral}_service_test.dart`.

---

## Catatan

- `register_host_screen.dart` belum dibuat -- mockup ada di `screens_flutter/37_register_host.png`.
- **Hotel OTA:** 4 layar konsumen + 4 bottom sheet (`property/hotel/`) + 1 layar mitra (`mitra/hotel_form_screen.dart`) **sudah dibuat**; keempat layar sudah terdaftar di `router.dart`. Yang belum lengkap: top modal tanggal/tamu (F-9), seksi Trip Coins (F-10), dan kartu booking room-vs-unit (F-12) — lihat tabel "Komponen yang belum ada" di [bagian C](#c-hotel-ota-screens-selesai-dibuat).
- `InsuranceSelectionWidget` sudah dipakai di alur checkout hotel (Stay Protection).
- ⚠️ Paket `top_modal_sheet` **tidak terpasang** di `flutter/pubspec.yaml` — top modal harus dibuat manual (`showGeneralDialog` + `SlideTransition`). Ini pekerjaan F-9 yang masih terbuka.
- ✅ **Sudah beres di Fase 2** (jangan pakai lagi sebagai peringatan aktif):
  - A-D4 & A-D5 — `HotelService.getHotelFilters()` / `createHotelBooking()` dulu memanggil endpoint yang tidak ada (`GET hotel/filters`, `POST hotel/bookings`). Ditutup L-2/L-3 + F-1.
  - A-D6 — `hotel_search_provider.dart` dulu memanggil `PropertyService.searchHotels()` (`GET properties`) sehingga field khusus hotel hilang; sekarang lewat `HotelService` (`GET hotels`). Ditutup F-1.
  - A-D7 — `HotelSearchQuery.fromUri()` dulu memakai `q['city_id']!` tanpa fallback sehingga deep link tanpa `city_id` *crash*. Ditutup F-2, dipatok T-F1.
  - A-D3 — promo per tipe kamar di mockup #31 vs satu `voucher_code` per booking di API. Ditutup F-5 dengan membatasi UI ke satu baris promo per booking.
  Riwayat lengkap semua drift: [readme_screen.md §11.3](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel).
- Bahasa kode: **Inggris**. Bahasa docs: **Indonesia**.
