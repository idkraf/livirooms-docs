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
| ✅ | `booking/booking_list_screen.dart` | `/booking/list` | My Bookings | Riwayat pesanan, 3 tab. Baris kartunya `BookingStatusCard` ([C-37](#c-hotel-ota-screens-selesai-dibuat), room vs unit). Filter tab memetakan **9** nilai `bookings_status_check` — Aktif `waiting_payment`/`waiting_confirmation`/`confirmed`/`paid`/`waiting_checkin`/`staying`, Selesai `completed`, Dibatalkan `cancelled`+`expired` — union tepat sekali per status, dipaku T-F91 |
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
| ✅ | `property/hotel/hotel_booking_screen.dart` | `/hotel/booking` | Hotel Booking Checkout | #26–#32 | Ringkasan kamar (data asli `room_types`), form data tamu per kamar, info kontak, Trip Coins ([C-29](#c-hotel-ota-screens-selesai-dibuat) — `trip_coins_section.dart`), jaminan harga, baris permintaan khusus + baris kode promo |
| ✅ | `property/hotel/special_request_sheet.dart` | — (bottom sheet) | Permintaan Khusus | #37 | C-31 + C-30. Radio bed/lift (bisa toggle off) + checkbox + catatan ber-`maxLength` **dinamis** dari anggaran 500 char/booking. Publik agar terjangkau widget test |
| ✅ | `property/hotel/promo_code_sheet.dart` | — (bottom sheet) | Kode Promo | #36 | C-34 + C-35 + C-33. Katalog `GET vouchers`, verifikasi lewat `POST vouchers/apply` (satu-satunya oracle kelayakan), kartu di-dim `opacity 0.6` + alasan server, **1 voucher per booking** |
| ✅ | `property/hotel/additional_info_sheet.dart` | — (bottom sheet) | Informasi Tambahan | #33 | C-32, read-only. Isi **diturunkan** dari `Hotel` lewat `additionalInfoEntries()` — deposit (`hotels.deposit_amount`), kebijakan anak, ranjang tambahan — sehingga `(N)` di baris pemicu (`AdditionalInfoSection`) tak mungkin berselisih dengan isi sheet. Bagian kosong dibuang |
| ✅ | `property/hotel/room_detail_sheet.dart` | — (bottom sheet) | Detail Kamar | #34 **+** #35 | C-39, read-only, `heightFactor: 0.92`. **Satu** sheet dengan **baris pil pemindah tipe kamar** — #34 dan #35 adalah dua state pil dari komponen yang sama, bukan dua layar. Galeri, spesifikasi, `Opsi 1`/`Opsi 2` (turunan `bed_configuration`), `Fasilitas Kamar` (6 + "Tampilkan semua"), dan 2 seksi chevron kebijakan; seksi tanpa data **hilang**, bukan dirender kosong. Dipicu dari kartu kamar #27 **dan** baris `Detail kamar` #31 lewat `showRoomDetailSheet()`; pil di-dedup oleh fungsi murni `distinctRoomTypes()` |
| ✅ | `property/hotel/top_modal_shell.dart` | — (top modal) | *(shell)* | #12–#16 | C-11 + `showAppTopModal()`. Dibuat **manual** di atas `showGeneralDialog` + `SlideTransition(begin: Offset(0,-1))` karena paket `top_modal_sheet` tak pernah ada di `pubspec.yaml` ([A-08](../hotel/screen/readme_screen.md#4-log-anomali-aset--dokumentasi)) dan `showModalBottomSheet` arah animasinya terpaku ke bawah. Geometri verbatim dari HTML (`top:0`, `border-radius:0 0 20px 20px`, `max-height:85%`); satu deviasi sengaja: `SafeArea(bottom: false)` |
| ✅ | `property/hotel/stay_search_top_modal.dart` | — (top modal) | #12 | Panel jatuh-dari-atas di layar hasil, dipicu pil tanggal (`hotel_results_screen.dart:139`). Hub, bukan form: headline membuka #13/#14, baris tamu membuka #15/#16, dan **tak ada** yang diterapkan sebelum `Cari` — scrim/back membuang seluruh suntingan. `stayHeadline()`/`guestSummaryParts()` murni agar teksnya bisa diuji tanpa pump |
| ✅ | `property/hotel/stay_date_picker_sheet.dart` | — (bottom sheet) | #5–#6, #13–#14 | C-16 `DateRangeCalendar` + C-17 `FlexibleDateTab`. Tab fleksibel dibangun **ulang** setelah HTML dibaca: `Durasi menginap` (7 chip single-select) + 2 checkbox hari + grid `Bulan` multi-select — bukan chip `±1/±2/±3 hari` yang tak ada di satu pun aset ([A-D18](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel)). `FlexibleStay.resolve(today)` meringkas pilihan tanpa parameter server jadi `check_in`/`check_out` konkret; objeknya sendiri **tidak** dikirim |
| ✅ | `property/hotel/room_guest_sheet.dart` | — (bottom sheet) | #3–#4, #15–#16 | C-18 `RoomGuestStepperSheet` + C-19 `ChildAgePickerSheet` (18 opsi umur; memilih chip **adalah** konfirmasinya). `resizeChildrenAges()` menjaga jumlah baris umur = jumlah anak, `guestStepperKey()` satu sumber untuk key stepper. `children_ages[]` tetap state layar — tak ada endpoint yang menerimanya ([A-D2](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel)) |
| ✅ | `property/hotel/trip_coins_section.dart` | — (seksi in-page) | Trip Coins | #29, #31, #32 | C-29, expandable. Baris ber-`border-bottom` (**bukan** kartu — aset menggambar Trip Coins dan `Informasi Tambahan` sebagai dua baris bersaudara). Kalimatnya `Perkiraan N Trip Coins…`, bukan `Dapatkan`: angkanya dihitung klien dari promo terpilih sementara yang otoritatif ditulis server saat booking dibuat. Kurung `(≈Rp…)` mockup **dibuang** — tak ada kurs koin→rupiah di sistem ini ([A-23](../hotel/screen/readme_screen.md#4-log-anomali-aset--dokumentasi)), dan isi state terbukanya disusun dari fakta kode, bukan pemasaran, karena tak satu pun aset merekamnya terbuka. Tak ada satu kata pun soal penukaran: `trip_coins_used` belum dibaca siapa pun ([A-D19](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel)) |
| ✅ | `widgets/booking_status_card.dart` | — (widget bersama) | Kartu Pesanan | #38 | C-37. **Satu** kartu untuk kedua domain: cabang `booking_type` `room` → tipe kamar + `N kamar` + `N malam` + `N tamu`, `unit` → label `property_type` + `duration_type` saja. Sengaja publik & bebas `Navigator` (menerima `onTap`) supaya bisa di-pump tanpa tabel route — itulah yang akhirnya membuat T-F16 bisa diuji setelah menganggur sembilan item. Dua elemen mockup **dibuang**: tombol `Bayar` (keputusannya milik #40 yang tahu status pembayaran) dan baris `43 Trip Coins (Rp7.665)` (tak ada `trip_coins_earned` yang di-parse, tak ada kurs — [A-23](../hotel/screen/readme_screen.md#4-log-anomali-aset--dokumentasi)); keduanya dipaku sebagai asersi negatif di T-F89. Diletakkan di `widgets/` — bukan `property/hotel/` — karena #38 satu-satunya layar yang menampilkan hotel **dan** properti biasa berdampingan; pemisahan [§10](../hotel/screen/readme_screen.md#10-pemisahan-booking-hotel-vs-booking-properti-biasa) soal **data**, bukan folder |
| ✅ | `mitra/hotel_form_screen.dart` | `/mitra/hotels/form` | Form Wizard Registrasi Hotel | — (sisi mitra) | 5-Step pendaftaran hotel & kamar mitra (Info, Fasilitas, Kamar, Inventaris, Galeri) |

**Komponen yang belum ada** — **kosong sejak 16 Agt 2026**: seluruh baris di bawah sudah tertutup. Disimpan sebagai jejak audit, bukan daftar kerja; detail per item di [readme_screen.md §15.2](../hotel/screen/readme_screen.md#152-flutter).

| Kekurangan | Layar Master Ref | Item |
|---|---|---|
| ~~Bottom sheet kode promo~~ | #36 | ✅ **selesai** — F-5, `promo_code_sheet.dart` |
| ~~Bottom sheet permintaan khusus~~ | #37 | ✅ **selesai** — F-4, `special_request_sheet.dart` |
| ~~Ringkasan kamar masih hardcode via `_roomSummary(...)`~~ | #27 | ✅ **selesai** — F-8, lewat rantai `HotelDetailArgs` → `HotelBookingArgs` |
| ~~Bottom sheet informasi tambahan~~ | #33 | ✅ **selesai** — F-6, `additional_info_sheet.dart` (kolom `deposit_amount` ternyata sudah ada di server tapi tak pernah di-parse Flutter) |
| ~~Bottom sheet detail kamar (Family Suite / Kamar Superior)~~ | #34, #35 | ✅ **selesai** — F-7, `room_detail_sheet.dart`. **Satu** komponen untuk kedua layar (pil pemindah tipe kamar), dan `properties.cancellation_policy` yang tak pernah diratakan `show()` ikut ditambal di Laravel |
| ~~Top modal tanggal & tamu (paket `top_modal_sheet` **tidak ada** di `pubspec.yaml` → harus dibuat manual)~~ | #12–#16 | ✅ **selesai** — F-9, empat file: `top_modal_shell.dart`, `stay_search_top_modal.dart`, `stay_date_picker_sheet.dart`, `room_guest_sheet.dart`. Dua temuan aset ikut terbawa: #15 hanya punya 2 stepper (**A-22**) dan tab fleksibel salah desain (**A-D18**) |
| ~~Seksi Trip Coins expandable~~ | #29, #31, #32 | ✅ **selesai** — F-10, `trip_coins_section.dart`. Dua temuan ikut tercatat: state terbuka seksi ini **tidak pernah di-capture** dan angka rupiah di dalamnya tak punya kurs (**A-23**), sementara ledger koinnya baru separuh jadi — `trip_coins_used` dibaca/ditulis nol baris kode (**A-D19**) |
| ~~Kartu daftar booking belum membedakan `booking_type` room vs unit~~ | #38 | ✅ **selesai** — F-12, `widgets/booking_status_card.dart` (C-37). Cabangnya membaca `booking_type` — **bukan** `property_type` atau `property.booking_mode`, karena `GET bookings` tak pernah men-select `booking_mode` sehingga nilainya selalu jatuh ke default `'unit'`. Tiga default yang menyamar jadi data ikut ditambal (`cover` yang tak ada kolomnya, `guest_capacity`, `booking_mode` — **A-D21**) plus kosakata filter tab yang bocor (`waiting_payment` hilang, `checkin` hantu — **A-D20**) |

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
├── widgets/                                       (6 widget)
│   ├── app_network_image.dart
│   ├── booking_status_card.dart                   C-37 — satu baris #38, cabang room/unit (F-12)
│   ├── city_list.dart
│   ├── insurance_selection_widget.dart            Stay Protection checkout UI
│   ├── property_card.dart
│   └── state_views.dart
│
└── screens/                                       (54 file — 45 layar, 44 punya named route;
                                                     home_screen.dart = tab di MainShell;
                                                     9 file sheet/top-modal/seksi Hotel tanpa route)
    ├── auth/          (6 file)  ✅ splash, onboarding, welcome, login, register, register_profile
    ├── home/          (3 file)  ✅ main_shell, home_screen, filter_screen
    ├── property/      (2 file)  ✅ property_detail, search_results
    │   └── hotel/    (13 file)  ✅ hotel_search, hotel_results, hotel_detail, hotel_booking,
    │                               special_request_sheet (#37), promo_code_sheet (#36),
    │                               additional_info_sheet (#33), room_detail_sheet (#34+#35),
    │                               top_modal_shell (C-11), stay_search_top_modal (#12),
    │                               stay_date_picker_sheet (#5/#6/#13/#14),
    │                               room_guest_sheet (#3/#4/#15/#16),
    │                               trip_coins_section (C-29, #29/#31/#32)
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
| **File di `screens/`** | **54** file (45 layar + 9 sheet/top-modal/seksi Hotel tanpa route) | 1 Register Host |
| **Named route di `router.dart`** | **44** | 0 — semua layar Hotel OTA **sudah** terdaftar |
| **Models** | 26 | 0 |
| **Services** | 19 | 0 |
| **Providers** | 2 | 0 |
| **Widgets** | 6 | 0 |
| **Utils** | 2 | 0 |
| **Test (`flutter/test/`)** | **20 file** berisi test — 233 deklarasi, **297 test saat dijalankan** | lihat catatan cakupan di bawah |

> `router.dart` punya 44 konstanta route dan 44 `case Routes.*` yang berpasangan tepat. Selisih 54 vs 44: `home_screen.dart` dirender sebagai tab di dalam `MainShell`, sedangkan sembilan file hotel lainnya dipakai lewat fungsi `show*()` atau disusun langsung ke dalam layar, bukan navigator bernama — empat bottom sheet checkout (`special_request_sheet.dart`, `promo_code_sheet.dart`, `additional_info_sheet.dart`, `room_detail_sheet.dart`), empat file top-modal/tanggal-tamu dari F-9 (`top_modal_shell.dart` sebagai shell C-11, `stay_search_top_modal.dart`, `stay_date_picker_sheet.dart`, `room_guest_sheet.dart`), dan satu seksi in-page dari F-10 (`trip_coins_section.dart` — C-29, bukan sheet: ia hidup di dalam `hotel_booking_screen.dart`). Kesembilannya memang tidak punya named route.

> C-37 (`widgets/booking_status_card.dart`, F-12) sengaja **tidak** ikut ke `screens/property/hotel/`: #38 adalah satu-satunya layar yang menampilkan booking hotel **dan** booking properti biasa dalam satu daftar, jadi kartunya milik kedua domain. Pemisahan yang dituntut [readme_screen.md §10](../hotel/screen/readme_screen.md#10-pemisahan-domain-booking-hotel-vs-booking-properti) adalah pemisahan **data** (`booking_type`, tabel anak, kode booking), bukan pemisahan folder — dan cabangnya memang hidup di dalam widget itu.

### Cakupan Test Flutter

`flutter/test/` berisi **20 file berisi test** + 1 helper tanpa test (`support/fake_voucher_api.dart`). Di dalamnya ada **233 deklarasi `test()`/`testWidgets()`**, tetapi jumlah test yang benar-benar dijalankan adalah **297**: satu deklarasi di `api_envelope_test.dart:136` berada di dalam loop `for (final key in requests.keys)` sehingga menghasilkan **65** test — satu per rute di tabel `DummyApiClient`. Jadi 233 − 1 + 65 = 297.

> 🟡 Angka di atas dihitung statis dari kode (grep deklarasi + hitung entri `requests`), **belum** dari output `flutter test` — suite belum dijalankan di lingkungan ini. Lihat baris status eksekusi terakhir di [readme_screen.md §17](../hotel/screen/readme_screen.md#17-catatan-revisi).

**11 file menyentuh Hotel / asuransi / voucher:**

| File test | Deklarasi | Cakupan |
|---|---|---|
| `widgets/hotel_screens_test.dart` | 68 | Render 5 layar Hotel + sheet permintaan khusus #37 + sheet kode promo #36 + sheet informasi tambahan #33 + sheet detail kamar #34/#35 + top modal tanggal/tamu #12–#16 (stepper, umur anak, durasi & bulan fleksibel, kalender, commit vs buang) + seksi Trip Coins C-29 (kolaps/mekar, salinan turunan tanpa angka rupiah) + kartu pesanan C-37 #38 (cabang `booking_type` room vs unit, filter tab vs 9 nilai `bookings_status_check`, label per status termasuk `expired`, delegasi tap) + cakupan label 6 metode bayar vs `MidtransSnap::DEFAULT_CHANNELS` + daftar tipe properti form mitra (subset berlabel, tipe tak terdaftar dibawa bukan diganti — A-D24) + integrasi end-to-end di layar booking |
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

> Rincian per-test (ID T-F1…T-F95, T-L1…T-L39) dipelihara **hanya** di [readme_screen.md §15.3](../hotel/screen/readme_screen.md#153-daftar-test) agar tidak ada dua salinan angka yang bisa saling menyimpang.

Sisanya di luar modul Hotel: `widget_test.dart`, `api_envelope_test.dart` (87 test: 22 statis + 65 generated), `models/{property,property_recommendation,booking,payment,referral}_test.dart`, `services/{booking,property,referral}_service_test.dart`.

---

## Catatan

- `register_host_screen.dart` belum dibuat -- mockup ada di `screens_flutter/37_register_host.png`.
- **Hotel OTA:** 4 layar konsumen + 9 sheet/top-modal/seksi (`property/hotel/`) + 1 layar mitra (`mitra/hotel_form_screen.dart`) + 1 widget bersama (`widgets/booking_status_card.dart`, C-37) **sudah dibuat**; keempat layar sudah terdaftar di `router.dart`. **Seluruh item kode Fase 2 tertutup** (Laravel L-1…L-9, Flutter F-1…F-13); yang tersisa hanya menjalankan suite-nya — lihat baris status eksekusi terakhir di [readme_screen.md §17](../hotel/screen/readme_screen.md#17-riwayat-audit). Layar yang memang belum dibangun dan bukan bagian Fase 2: #39 `pembayaran_screen` & #40 `booking_hotel_detail_screen`.
- `InsuranceSelectionWidget` sudah dipakai di alur checkout hotel (Stay Protection).
- ⚠️ **A-D19 — ledger Trip Coins baru separuh jadi, dan ini pekerjaan server, bukan klien.** `bookings.trip_coins_earned` ditulis **satu kali** saat baris booking dibuat (`round($total * 0.005)`) lalu tak pernah disentuh lagi, sementara `bookings.trip_coins_used` **dibaca dan ditulis oleh nol baris kode**. Jadi tidak ada saldo per pengguna, tidak ada alur penukaran, dan tidak ada kurs koin→rupiah. `trip_coins_section.dart` (C-29) dibangun supaya **tidak menambah janji baru**: copy-nya hanya menjelaskan bagaimana angkanya dihitung, tak pernah menyebut penukaran, dan T-F83 mengasersi kata `tukar` maupun `Rp` **tidak muncul**. Kalau menambah UI koin di layar lain, jangan janjikan penukaran sebelum keempat hal di [readme_screen.md §11.3](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel) ada. Terkait: `Booking.fromJson` belum mem-parse `trip_coins_earned`, jadi layar #40 (`booking_hotel_detail_screen`, belum dibuat) belum punya sumber angkanya.
- ✅ **Sudah beres di Fase 2** (jangan pakai lagi sebagai peringatan aktif):
  - A-08 — paket `top_modal_sheet` **tidak** (dan tidak akan) terpasang di `flutter/pubspec.yaml`; readme lama menyebutnya dependensi padahal ia tak pernah ada. C-11 dibuat manual (`showGeneralDialog` + `SlideTransition(begin: Offset(0,-1))`) di `top_modal_shell.dart`. Ditutup F-9 — **jangan** tambahkan paketnya demi satu animasi geser.
  - A-D4 & A-D5 — `HotelService.getHotelFilters()` / `createHotelBooking()` dulu memanggil endpoint yang tidak ada (`GET hotel/filters`, `POST hotel/bookings`). Ditutup L-2/L-3 + F-1.
  - A-D6 — `hotel_search_provider.dart` dulu memanggil `PropertyService.searchHotels()` (`GET properties`) sehingga field khusus hotel hilang; sekarang lewat `HotelService` (`GET hotels`). Ditutup F-1.
  - A-D7 — `HotelSearchQuery.fromUri()` dulu memakai `q['city_id']!` tanpa fallback sehingga deep link tanpa `city_id` *crash*. Ditutup F-2, dipatok T-F1.
  - A-D3 — promo per tipe kamar di mockup #31 vs satu `voucher_code` per booking di API. Ditutup F-5 dengan membatasi UI ke satu baris promo per booking.
  - A-D18 — tab tanggal fleksibel dulu berisi chip `±1/±2/±3 hari` yang **tidak ada di satu pun aset**; kontrol sebenarnya adalah `Durasi menginap` + checkbox hari + grid `Bulan` multi-select. Ditutup F-9, dipatok T-F74…T-F76.
  - A-23 — state terbuka seksi Trip Coins tak pernah di-capture, dan kurung `(≈Rp5.526)` di mockup butuh kurs koin→rupiah yang tidak ada di sistem ini. Ditutup F-10 dengan dua keputusan: isi state terbuka disusun dari fakta kode (bukan pemasaran), dan kurungnya **dibuang** — T-F83 menjaga agar tak ada yang menyalinnya balik dari PNG. **Jangan** selesaikan ini dengan konstanta kurs di UI.
  - A-D20 — kosakata filter tab #38 dulu bocor dua arah: `waiting_payment` **tidak** terdaftar di tab mana pun padahal itulah status yang ditulis `storeHotelBooking()` saat booking dibuat (`BookingController.php:250`) — jadi setiap booking hotel tak terlihat sejak dibuat sampai dibayar — sementara `checkin` terdaftar padahal bukan salah satu dari 9 nilai `bookings_status_check` (yang ada `waiting_checkin`), dan `expired` tak muncul di tab mana pun meski ditulis dari tiga tempat. Ditutup F-12; T-F91 memaksa union ketiga set == set constraint dan `length == 9` sehingga tab tak bisa lagi menelan status baru tanpa gagal.
  - A-D21 — tiga **default yang menyamar jadi data** di kartu #38, semuanya karena `GET bookings` hanya men-select `id, name, property_type, gallery, address`: thumbnail dibaca dari `Property.cover` (field yang **tak ada endpoint yang mengirim dan tak ada kolom yang menyimpan** — grep `cover` di 47 migration hanya mengembalikan `coverage_amount` milik asuransi) sehingga semua baris merender fallback abu-abu; `guest_capacity` dicetak padahal tak ter-select → selalu `1`; dan `property.booking_mode` dipakai sebagai penentu hotel padahal tak ter-select → selalu `'unit'` → `isHotel` selalu `false`. Ditutup F-12 (gallery→cover, baris tamu dari `adults`/`children` hotel saja, cabang dari `booking_type`); T-F86 memaku ketiganya dengan menuntut label tetap `Hotel` **sambil** `bookingMode == 'unit'` dan `isHotel == false`. Sisa server-side yang **belum** ditambal: `storeUnitBooking()` tak pernah menulis `rooms_count`/`adults`/`children` (`BookingController.php:377-387`), karena itu `bookingGuestLine()` mengembalikan `null` untuk unit alih-alih mencetak default `1 tamu`.
  - A-24 — jalur JPEG untuk layar #38–#40 di readme lama menunjuk berkas yang tidak ada, dan **tidak ada mockup `unit` sama sekali** untuk kartu #38. Ditutup F-12 dengan menurunkan cabang `unit` dari §12.10 + §10.1 (kontrak & skema), bukan dari aset — lalu memaku hasilnya di T-F85/T-F90 agar tak ada yang "memperbaikinya" dari PNG hotel.
  - A-25 — dokumen ini dan readme lama menulis amplop API sebagai `{ success, message, data, meta? }`; bentuk **nyata**-nya `{status, code, message, data, meta, errors}` (+ `error_code` saat gagal) — `status`, bukan `success` (`ApiResponse.php:62-69`, `api_response.dart:55`). Cacatnya tak pernah membuat test merah karena `ApiResponse.fromJson` tetap jalan tanpa `status` (HTTP code yang memutuskan, `data` jatuh ke seluruh body), jadi fixture apa pun yang disalin dari doc lulus **sambil melewati** parsing amplop. Nilai `error_code` juga snake-case huruf kecil (`validation_error`), bukan nama konstanta PHP. Ditutup di readme_screen.md §17 — dan **`CLAUDE.md` root + `flutter/CLAUDE.md` kini ikut dikoreksi** (16 Agt 2026), bersama A-26 (kelas konstanta route bernama `Routes`, bukan `AppRoutes` — identifier itu 0 hasil di `flutter/lib`; generatornya `AppRouter.onGenerateRoute`). **Jangan** menulis fixture berbentuk `{ success: … }`: `ApiResponse.fromJson` menerimanya lewat jalur `hasEnvelope == false` sehingga test-nya hijau tanpa pernah menguji amplopnya — itu mekanisme yang membuat cacat ini bertahan lama.
  - A-D22 — `Formatters.statusLabel` tak punya entri `expired` (penutupnya `?? status`, jadi badge merah di tab Dibatalkan mencetak enum mentah `expired` — warnanya benar karena `StatusBadge.colorFor` **memang** menangani `expired`, hanya kalimatnya tak ada), sekaligus masih menyimpan hantu `'checkin'` yang tak pernah ditulis nol baris kode. Ditutup F-12 bersamaan dengan A-D20 — `'expired': 'Kedaluwarsa'` masuk (terjemahan yang sudah dipakai `paymentStatusLabel` sejak lama), `'checkin'` keluar — dan dipatok T-F93. **Jangan** menambah key ke peta ini tanpa memeriksa constraint DB-nya: peta ber-fallback `?? key` tak bisa gagal, ia hanya bisa jadi jelek.
  - A-D23 — akibat langsung menjalankan pelajaran A-D22 sebagai audit: ketiga peta enum→label modul hotel dibandingkan dengan sumber otoritatifnya. `StatusBadge.colorFor` bersih (9/9 nilai `bookings_status_check`), `Formatters.paymentStatusLabel` bersih (5/5 nilai `payments.status`), tapi **`paymentMethodLabel` hanya 5 dari 6** kunci `MidtransSnap::DEFAULT_CHANNELS` — `bank_transfer` tak punya label, padahal form admin menerimanya lewat `Rule::in(supportedMethodCodes())` dan ENUM asli kolom `payments.method` memuatnya. Tak pernah pecah karena `PaymentMethodSeeder` hanya membuat kelima yang lain; begitu admin menambahkannya, baris `Metode` #40 mencetak string mesin `bank_transfer`. Ditutup dengan `'Transfer Bank'` + dipatok T-F94, dan docblock migrasi `change_payments_method_to_string.php` ikut dikoreksi (klaim "any code, `max:50`" sudah tidak benar sejak `Rule::in` ada). Perbaikan sisi server yang sebenarnya — kirim `payment_methods.name`, yang **sudah** dipancarkan `GET payments/methods` tapi tak ikut di `show()` — dinamai di readme agar tidak diselesaikan dengan menumbuhkan `switch`.
  - A-D24 — instans **keempat** keluarga yang sama, ditemukan dengan menjalankan audit A-D23 satu langkah lebih jauh: bukan hanya peta di `formatters.dart`, tapi setiap enumerasi enum→label yang disentuh modul hotel. Dua bersih (`bookingDurationLabel` 4/4 `duration_type`, `kPropertyTypeLabels` 7/7 `properties_property_type_check`), dan yang keempat justru **salinan kedua** dari peta yang baru dinyatakan bersih — di `screens/mitra/property_form_screen.dart`. Ini satu-satunya dari keempatnya yang **menulis** alih-alih mencetak: `_types` mendaftar 6 tipe (ditulis sebelum `2026_08_13_000001_update_properties_for_hotels.php:19` melebarkan CHECK jadi 7), dan penjaganya menghindari assertion `DropdownButtonFormField` dengan **membuang** tipe tak dikenal → `_type` tertinggal di `'apartment'` → `_submit()` mengirim `property_type` tanpa syarat di PUT badan-penuh → `PropertyController::update():417` menulisnya apa adanya. **Menyunting deskripsi properti bertipe `hotel` mengubahnya jadi apartemen, tanpa pesan.** Laten hari ini karena belum ada produsen nilai `hotel` (kedua form admin masih memvalidasi 6; `HotelSeeder` memakai `hotel_residence`). Ditutup dengan **menghapus** duplikatnya — `_typeLabel` mendelegasi ke `kPropertyTypeLabels`, `kCreatablePropertyTypes` tetap 6 sebagai keputusan (form ini tak mengirim tipe kamar; `booking_mode` akan jatuh ke `'unit'`), dan `propertyTypeOptions()` **membawa** tipe tak terdaftar alih-alih menggantinya — dipatok T-F95. Efek samping yang dicatat: `exclusive_kost` kini `Kost Eksklusif`, bukan `Exclusive Kost`. **Jangan** selesaikan celah tipe ke-7 dengan menambah `hotel` ke `Livewire/Properties/Form.php:37` + `WizardForm.php:57` — itu justru **menciptakan** produsennya, dan itu keputusan produk. Pelajaran yang paling mahal untuk dilupakan: **T-F86 sudah mengasersi 7/7 dan lulus terus** — test cakupan hanya melindungi peta yang ia sebut namanya, jadi obatnya satu peta, bukan penjaga kedua.
  Riwayat lengkap semua drift: [readme_screen.md §11.3](../hotel/screen/readme_screen.md#113-drift-kontrak-flutter--laravel).
- Bahasa kode: **Inggris**. Bahasa docs: **Indonesia**.
