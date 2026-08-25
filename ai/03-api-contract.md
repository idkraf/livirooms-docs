# API Contract — Jembatan Laravel ↔ Flutter

> **Fungsi file ini.** Satu tabel untuk seluruh endpoint `api/v1`:
> method · path · `Controller::method` · service Dart pemanggil · fixture dummy.
>
> **Status:** Tersinkronisasi dengan 21 model ternormalisasi dan `AccommodationResource`.

---

## 1. Aturan Dasar

- Prefix penuh: `{host}/api/v1/...`. Sisi Dart mengirim path **tanpa** `api/v1` dan tanpa leading slash.
- Amplop response: `ApiResponse` standar (`status`, `code`, `message`, `data`, `meta`, `errors`).
- Kontrak Output: `AccommodationResource` secara otomatis memetakan `hotelShape()` atau `propertyShape()` sesuai discriminator `booking_mode`.

---

## 2. Publik — 22 Endpoint (Tanpa Sanctum)

| # | Method + Path | Controller::method | Dart Service | Dummy Fixture | Keterangan |
|---|---|---|---|---|---|
| 1 | `POST auth/register` | `AuthController::register` | `auth_service.dart:22` | ✅ | Registrasi user |
| 2 | `POST auth/login` | `AuthController::login` | `auth_service.dart:36` | ✅ | Login user & return token |
| 3 | `GET remote-config` | `RemoteConfigApiController::fetch` | `remote_config_service.dart:35` | ✅ | Parameter remote config |
| 4 | `GET remote-config/{key}` | `RemoteConfigApiController::fetchOne` | `remote_config_service.dart:55` | ✅ | Nilai tunggal key |
| 5 | `GET home` | `HomeController::index` | `home_service.dart:35` | ✅ | Banners + recommended listings |
| 6 | `GET cities` | `CityController::index` | `city_service.dart:18` | ✅ | Daftar kota |
| 7 | `GET cities/{city}` | `CityController::show` | `city_service.dart:23` | ✅ | Detail kota |
| 8 | `GET properties` | `PropertyController::index` | `property_service.dart:24` | ✅ | Pencarian & filter properti |
| 9 | `GET properties/{property}` | `PropertyController::show` | `property_service.dart:39` | ✅ | Detail properti (`propertyShape`) |
| 10 | `GET properties/{property}/pricing` | `PropertyController::pricing` | `property_service.dart:46` | ✅ | Kalkulator harga sewa |
| 11 | `GET properties/{property}/reviews` | `ReviewController::index` | `property_service.dart:55` | ✅ | Ulasan properti |
| 12 | `GET properties/{property}/availability` | `PropertyController::availability` | `booking_service.dart:49` | ✅ | Kalender ketersediaan unit |
| 13 | `GET properties/{property}/host` | `PropertyController::host` | `property_service.dart:79` | ✅ | Profil host/mitra |
| 14 | `GET insurance/plans` | `InsuranceApiController::plans` | `hotel_service.dart:92` | ✅ | Pilihan asuransi |
| 15 | `GET vouchers` | `VoucherController::index` | `voucher_service.dart:41` | ✅ | Kupon promo aktif |
| 16 | `GET hotels` | `HotelApiController::index` | `hotel_service.dart:20` | ✅ | Pencarian & filter hotel OTA |
| 17 | `GET hotels/{hotel}` | `HotelApiController::show` | `hotel_service.dart:26` | ✅ | Detail hotel 8-tab (`hotelShape`) |
| 18 | `GET hotels/{hotel}/room-types` | `HotelApiController::roomTypes` | — | ⬜ | Allotment tipe kamar |
| 19 | **`GET accommodations/{id}`** | **`AccommodationController::show`** | — | ✅ | **Unified endpoint (Auto-branching Hotel & Property)** |
| 20 | `GET cms/{slug}` | `HomeController::cmsPage` | `content_service.dart:100` | ✅ | Privacy Policy, T&C, About |
| 21 | `GET faqs` | `HomeController::faqs` | `content_service.dart:85` | ✅ | FAQ Publik |
| 22 | `POST payments/webhook` | `PaymentController::webhook` | — | 🔒 | **Midtrans Server-to-Server Webhook** |

---

## 3. Terautentikasi — 63 Endpoint (`auth:sanctum`)

### Auth & Profil
- `POST auth/logout` (`AuthController::logout`)
- `GET auth/me` (`AuthController::me`)
- `GET profile` (`ProfileController::show`)
- `PUT profile` (`ProfileController::update`)
- `POST profile/become-host` (`ProfileController::becomeHost`)
- `GET user/validation` (`UserValidationController::index`)
- `POST user/validation` (`UserValidationController::store`)

### Booking & Checkout
- `GET bookings` (`BookingController::index`)
- `POST booking-property` (`BookingController::storeProperty`) — Checkout sewa unit utuh
- `POST booking-hotels` (`BookingController::storeHotel`) — Checkout sewa per kamar hotel
- `POST bookings` (Legacy) (`BookingController::store`) — Dispatched by `booking_type`
- `GET bookings/{booking}` (`BookingController::show`)
- `POST bookings/{booking}/cancel` (`BookingController::cancel`)
- `POST bookings/{booking}/confirm` (`BookingController::confirm`)
- `POST bookings/{booking}/reject` (`BookingController::reject`)
- `POST bookings/{booking}/checkin` (`BookingController::checkin`)
- `POST bookings/{booking}/confirm-checkin` (`BookingController::confirmCheckin`)

### Orders & Payment Snap
- `GET orders` (`OrderController::index`)
- `GET orders/{order}` (`OrderController::show`)
- `POST payments/pay` (`PaymentController::pay`) — Create Midtrans Snap token & redirect URL
- `POST payments/retry` (`PaymentController::retry`) — Retry payment
- `GET payments/check/{order}` (`PaymentController::check`) — Poll payment status

### Host Management (Mitra)
- `GET host/properties` (`PropertyController::hostIndex`)
- `POST host/properties` (`PropertyController::store`)
- `GET host/properties/{property}` (`PropertyController::hostShow`)
- `PUT host/properties/{property}` (`PropertyController::update`)
- `DELETE host/properties/{property}` (`PropertyController::destroy`)
- `GET host/hotels` (`HostHotelController::index`)
- `POST host/hotels` (`HostHotelController::store`)
- `GET host/hotels/{hotel}` (`HostHotelController::show`)
- `PUT host/hotels/{hotel}` (`HostHotelController::update`)
- `DELETE host/hotels/{hotel}` (`HostHotelController::destroy`)
- `GET host/hotels/{hotel}/room-types` (`HostHotelController::roomTypes`)
- `POST host/hotels/{hotel}/room-types` (`HostHotelController::storeRoomType`)
- `PUT host/room-types/{roomType}` (`HostHotelController::updateRoomType`)
- `DELETE host/room-types/{roomType}` (`HostHotelController::destroyRoomType`)
- `GET host/wallet` (`HostWalletController::index`)
- `POST host/wallet/withdraw` (`HostWalletController::withdraw`)
