# API Contract — Jembatan Laravel ↔ Flutter

> **Fungsi file ini.** Satu tabel untuk semua **84 endpoint** `api/v1`:
> method · path · `Controller::method` · service Dart pemanggil · fixture dummy.
> Dibaca sebagai ganti membuka `routes/api_mobile.php` **dan** menyisir
> `lib/services/` untuk mencari siapa memanggil apa.
>
> **Diverifikasi dari kode pada 2026-08-20.**
> Backend: `laravel/routes/api_mobile.php` (84 route).
> Klien: seluruh `flutter/lib/services/*.dart` (call site + nomor baris).
> Dummy: tabel `DummyApiClient.routes` (`dummy_api_client.dart:70-193`, 80 entri).

---

## 1. Aturan dasar

- Prefix penuh: `{host}/api/v1/...`. Sisi Dart mengirim path **tanpa** `api/v1`
  dan **tanpa** leading slash — prefix sudah ada di `AppConfig.baseUrl`.
- Amplop response: lihat `01-backend-map.md` §5. Kunci cabang = **`status`**.
- `auth: false` di sisi Dart = endpoint publik. Default `auth: true`.
- **Menambah endpoint = tiga tempat**: route di `api_mobile.php`, method di
  service Dart, **dan** entri di `DummyApiClient.routes` + fixture di
  `assets/json/`. Lewat yang ketiga → mode dummy 404.

### Legenda kolom

| Simbol | Arti |
|---|---|
| ✅ | ada di backend, dipanggil app, ada fixture dummy |
| ⬜ | ada di backend, **tidak** dipanggil app |
| 🟡 | dipanggil app, backend ada, **fixture dummy tidak ada** → 404 di mode dummy |
| ❌ | dipanggil app, **route backend tidak ada** → 404 selalu |
| ⚠️ | ada tapi salah secara arsitektur |

---

## 2. Publik — 21 endpoint (tanpa Sanctum)

| # | Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|---|
| 1 | `POST auth/register` | `AuthController::register` | `auth_service.dart:22` | ✅ |
| 2 | `POST auth/login` | `AuthController::login` | `auth_service.dart:36` | ✅ |
| 3 | `GET remote-config` | `RemoteConfigApiController::fetch` | `content_service.dart:109`, `remote_config_service.dart:35` | ✅ |
| 4 | `GET remote-config/{key}` | `RemoteConfigApiController::fetchOne` | `content_service.dart:122`, `remote_config_service.dart:55` | ✅ |
| 5 | `GET home` | `HomeController::index` | `home_service.dart:35` | ✅ |
| 6 | `GET cities` | `CityController::index` | `city_service.dart:18` | ✅ |
| 7 | `GET cities/{city}` | `CityController::show` | `city_service.dart:23` | ✅ |
| 8 | `GET properties` | `PropertyController::index` | `property_service.dart:24` | ✅ |
| 9 | `GET properties/{property}` | `PropertyController::show` | `property_service.dart:39` | ✅ |
| 10 | `GET properties/{property}/pricing` | `PropertyController::pricing` | `property_service.dart:46` | ✅ |
| 11 | `GET properties/{property}/reviews` | `ReviewController::index` | `property_service.dart:55` | ✅ |
| 12 | `GET properties/{property}/availability` | `PropertyController::availability` | `property_service.dart:65`, `booking_service.dart:49` | ✅ |
| 13 | `GET properties/{property}/host` | `PropertyController::host` | `property_service.dart:79` | ✅ |
| 14 | `GET insurance/plans` | `InsuranceApiController::plans` | `property_service.dart:84`, `hotel_service.dart:92` | ✅ |
| 15 | `GET vouchers` | `VoucherController::index` | `voucher_service.dart:41` | ✅ |
| 16 | `GET hotels` | `HotelApiController::index` | `hotel_service.dart:20` | ✅ |
| 17 | `GET hotels/{hotel}` | `HotelApiController::show` | `hotel_service.dart:26` | ✅ |
| 18 | `GET hotels/{hotel}/room-types` | `HotelApiController::roomTypes` | — | ⬜ |
| 19 | `GET cms/{slug}` | `HomeController::cmsPage` | `content_service.dart:100` | ✅ |
| 20 | `GET faqs` | `HomeController::faqs` | `content_service.dart:85` | ✅ |
| 21 | `POST payments/webhook` | `PaymentController::webhook` | `booking_service.dart:224` | ⚠️ |

**#18** — endpoint "kamar tersedia" hotel tidak pernah dipanggil app. Layar
detail hotel mengambil tipe kamar dari respons `GET hotels/{hotel}` (8 tab).

**#21** — ⚠️ **Ini endpoint server-to-server Midtrans.** Klien tidak boleh
memanggilnya: signature dihitung dari `serverKey`, jadi request klien akan
ditolak 403 (`PaymentController.php:269`) — atau lebih buruk, kalau berhasil ia
akan memutasi status pembayaran dari perangkat yang tidak dipercaya. Lihat
`04-drift-register.md` §4.

---

## 3. Terautentikasi — 63 endpoint (`auth:sanctum`)

### Auth & profil

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `POST auth/logout` | `AuthController::logout` | `auth_service.dart:53` | ✅ |
| `GET auth/me` | `AuthController::me` | `auth_service.dart:44` | ✅ |
| `GET profile` | `ProfileController::show` | `profile_service.dart:17` | ✅ |
| `PUT profile` | `ProfileController::update` | `profile_service.dart:30` | ✅ |
| `POST profile/become-host` | `ProfileController::becomeHost` | `profile_service.dart:43` | ✅ |
| `GET user/validation` | `UserValidationController::index` | `profile_service.dart:48` | ✅ |
| `POST user/validation` | `UserValidationController::store` | `profile_service.dart:56` (multipart: `upload_ktp`, `upload_selfie`) | ✅ |

### Booking — tiga jalur checkout

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET bookings` | `BookingController::index` | `booking_service.dart:15` | ✅ |
| **`POST booking-property`** | `BookingController::storeProperty` (:243) | `booking_service.dart:131` | ✅ |
| **`POST booking-hotels`** | `BookingController::storeHotel` (:289) | `hotel_service.dart:145` | ✅ |
| `POST bookings` (legacy) | `BookingController::store` (:209) | — | ⬜ |
| `GET bookings/{booking}` | `BookingController::show` | `booking_service.dart:20` | ✅ |
| `POST bookings/{booking}/cancel` | `BookingController::cancel` | `booking_service.dart:209` | ✅ |
| `POST bookings/{booking}/confirm` | `BookingController::confirm` | `host_service.dart:47` | ✅ |
| `POST bookings/{booking}/reject` | `BookingController::reject` | `host_service.dart:51` | ✅ |
| `POST bookings/{booking}/checkin` | `BookingController::checkin` | `host_service.dart:55` | ✅ |
| `POST bookings/{booking}/confirm-checkin` | `BookingController::confirmCheckin` | `host_service.dart:59` | ✅ |
| `POST bookings/{booking}/review` | `ReviewController::store` | `booking_service.dart:65` | ✅ |

🔴 **Tiga jalur, bukan satu.** Aturannya:

| Jalur | Untuk | Validasi | Status awal |
|---|---|---|---|
| `booking-property` | `booking_mode = 'unit'` | `commonBookingRules` + `unitBookingRules` (`:380`) | `waiting_confirmation` |
| `booking-hotels` | `booking_mode = 'room'` | `commonBookingRules` + `roomBookingRules` (`:358`) | `waiting_payment`, `host_confirmed = true` |
| `bookings` (legacy) | keduanya, dispatch pada `booking_type` | keduanya | sesuai jalur |

Masing-masing endpoint **menolak properti dari jalur lain** dan menyebutkan nama
endpoint yang seharusnya dipakai. Jangan menggabungkan ketiganya. Detail
invarian: `docs/domain/hotel-vs-property.md`.

App sudah pindah ke dua endpoint spesifik — `POST bookings` legacy tidak lagi
dipanggil, tapi masih hidup untuk klien versi lama. **Jangan hapus** tanpa cek
versi minimum yang beredar.

### Order

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET orders` | `OrderController::index` | `booking_service.dart:214` | ✅ |
| `GET orders/{order}` | `OrderController::show` | `booking_service.dart:219` | ✅ |
| `GET host/orders` | `OrderController::forHost` | `host_service.dart:37` | ✅ |
| `GET host/orders/{order}` | `OrderController::showForHost` | `host_service.dart:42` | ✅ |

### Pembayaran

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET payments/methods` | `PaymentController::methods` (:35) | `booking_service.dart:35` | ✅ |
| `POST orders/{order}/pay` | `PaymentController::pay` (:44) | `booking_service.dart:151` (body `method`) | ✅ |
| `POST orders/{order}/pay/retry` | `PaymentController::payUrl` (:122) | `booking_service.dart:180` | ✅ |
| `GET payments/{payment}` | `PaymentController::show` (:237) | `booking_service.dart:25` | ✅ |
| `POST payments/{payment}/reconcile` | `PaymentController::reconcile` (:201) | `booking_service.dart:30` | ✅ |

`pay` mengembalikan `snap_token` **dan** `redirect_url`
(`PaymentController.php:117-118`). App memakai `redirect_url` di
`PaymentWebviewScreen`.

Retry hanya boleh untuk payment berstatus `pending`, `failed`, atau `expired`
(guard di `:135` dan `:205`).

### Wishlist, voucher, notifikasi, chat

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET wishlists` | `WishlistController::index` | `wishlist_service.dart:9` | ✅ |
| `POST wishlists/{property}` | `WishlistController::toggle` | `wishlist_service.dart:16` | ✅ |
| `DELETE wishlists/{property}` | `WishlistController::destroy` | `wishlist_service.dart:21` | ✅ |
| `POST vouchers/apply` | `VoucherController::apply` | `voucher_service.dart:49` | ✅ |
| `GET notifications` | `NotificationController::index` | `notification_service.dart:10` | ✅ |
| `POST notifications/{notification}/read` | `NotificationController::markRead` | `notification_service.dart:20` | ✅ |
| `POST notifications/read-all` | `NotificationController::markAllRead` | `notification_service.dart:25` | ✅ |
| `POST devices/fcm-token` | `NotificationController::storeFcmToken` | `notification_service.dart:31` | ✅ ⚠️ |
| `GET conversations` | `ChatController::index` | `chat_service.dart:10` | ✅ |
| `POST conversations` | `ChatController::store` | `chat_service.dart:15` | ✅ |
| `GET conversations/{conversation}/messages` | `ChatController::messages` | `chat_service.dart:23` | ✅ |
| `POST conversations/{conversation}/messages` | `ChatController::sendMessage` | `chat_service.dart:37` | ✅ |

⚠️ `devices/fcm-token` punya route, service, dan fixture — tapi **tidak ada
paket `firebase_messaging` di `pubspec.yaml`**, jadi tidak ada token nyata yang
bisa dikirim. Jalur ini belum aktif ujung ke ujung.

### Host — properti unit

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET host/properties` | `PropertyController::hostIndex` | `host_service.dart:19` | ✅ |
| `POST host/properties` | `PropertyController::store` | `host_service.dart:24` | ✅ |
| `PUT host/properties/{property}` | `PropertyController::update` | `host_service.dart:29` | ✅ |
| `GET host/properties/{property}` | `PropertyController::hostShow` | `host_service.dart:116` | ✅ |
| `DELETE host/properties/{property}` | `PropertyController::destroy` | `host_service.dart:121` | ✅ |
| `POST host/properties/gallery/upload` | `PropertyController::uploadGallery` | `host_service.dart:88` (multipart `image`) | ✅ |
| `DELETE host/properties/{property}/gallery` | `PropertyController::deleteGallery` | `host_service.dart:108` (query `image`) | ✅ |
| `DELETE host/properties/gallery` | `PropertyController::deleteGalleryTemp` | `host_service.dart:112` (query `image`) | ✅ |
| `GET host/dashboard` | `HomeController::hostDashboard` | `host_service.dart:14` | ✅ |

⚠️ Urutan route penting: `host/properties/gallery` (tanpa id) didaftarkan
**setelah** `host/properties/{property}/gallery` di `api_mobile.php:139-140`,
dan `host/properties/{property}` **setelah** rute gallery. Menyusun ulang bisa
membuat `gallery` tertangkap sebagai `{property}`.

### Host — dompet & withdrawal

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET host/wallet` | `HostWalletController::summary` | `host_service.dart:63` | ✅ |
| `GET host/withdrawals` | `HostWalletController::withdrawals` | `host_service.dart:68` | ✅ |
| `POST host/withdrawals` | `HostWalletController::requestWithdrawal` | `host_service.dart:78` | ✅ |

### Referral

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET referrals/my-code` | `ReferralController::myCode` | `referral_service.dart:9` | ✅ |
| `GET referrals/my-list` | `ReferralController::myList` | `referral_service.dart:15` | ✅ |
| `POST referrals/apply` | `ReferralController::apply` | `referral_service.dart:30` | ✅ |
| `GET referrals/status` | `ReferralController::status` | `referral_service.dart:36` | ✅ |

### Host — hotel OTA (`HostHotelController`)

| Method + Path | Controller::method | Dart | Dummy |
|---|---|---|---|
| `GET host/hotels` | `index` | — | ⬜ |
| `POST host/hotels` | `store` | `hotel_service.dart:154` | ✅ |
| `GET host/hotels/{hotel}` | `show` | `hotel_service.dart:33` | ✅ |
| `PUT host/hotels/{hotel}` | `update` | `hotel_service.dart:44` | ✅ |
| `GET host/hotels/{hotel}/dashboard` | `dashboard` | — | ⬜ |
| `POST host/hotels/{hotel}/room-types` | `storeRoomType` | `hotel_service.dart:50`, `:159` | ✅ |
| `PUT host/room-types/{roomType}` | `updateRoomType` | `hotel_service.dart:48` | 🟡 |
| `POST host/room-types/{roomType}/inventory/bulk` | `bulkInventory` | — | ⬜ |

🟡 `PUT host/room-types/{roomType}` **dipanggil app tapi tidak ada di
`DummyApiClient.routes`** → edit tipe kamar hotel selalu gagal 404 di mode
dummy, padahal jalan di mode nyata.

⬜ `POST host/room-types/{roomType}/inventory/bulk` adalah satu-satunya cara
mengatur `allotment`/`price`/`is_closed` per tanggal secara massal — **belum
dipakai app**. `MitraCalendarScreen` belum tersambung ke sini.

---

## 4. ❌ Dipanggil app tapi route backend TIDAK ADA

Dua panggilan ini **pasti 404** di semua environment:

| Dart | Path yang dipanggil | Status backend |
|---|---|---|
| `hotel_service.dart:58` | `DELETE host/room-types/{roomTypeId}` | **tidak ada route** |
| `hotel_service.dart:63` | `DELETE host/hotels/{hotelId}` | **tidak ada route** |

`HostHotelController` hanya punya `index`, `store`, `show`, `update`,
`dashboard`, `storeRoomType`, `updateRoomType`, `bulkInventory` — **tidak ada
method destroy sama sekali**, jadi ini bukan soal route yang lupa didaftarkan,
tapi fitur hapus yang belum diimplementasikan di backend.

Perbaikannya harus memilih arah, bukan asal tambah route: menghapus `RoomType`
menyentuh `room_inventories` dan `booking_rooms`, sedangkan menghapus `Hotel`
menyentuh `properties.booking_mode`. **Baca
`docs/domain/hotel-vs-property.md` (invarian) sebelum menambahkannya.**

---

## 5. Endpoint backend yang tidak dipakai app — 5

| Path | Kenapa penting |
|---|---|
| `GET hotels/{hotel}/room-types` | data diambil dari `GET hotels/{hotel}` |
| `POST bookings` | legacy, sengaja dipertahankan untuk klien lama |
| `GET host/hotels` | daftar hotel mitra — layar mitra belum memakainya |
| `GET host/hotels/{hotel}/dashboard` | statistik hotel mitra — belum ada layar |
| `POST host/room-types/{roomType}/inventory/bulk` | kalender allotment mitra belum tersambung |

Jangan hapus salah satunya sebagai "dead code" tanpa memeriksa dulu: 4 dari 5
adalah fitur yang **sudah siap di backend tapi belum dipakai di app**, bukan
sisa yang mati.

---

## 6. Alur bayar ujung ke ujung

```
[App]  PaymentMethodScreen
         GET payments/methods                     → daftar channel aktif
         POST orders/{order}/pay {method}          → { snap_token, redirect_url }
                                                     payment: pending, order: pending
[App]  PaymentWebviewScreen(redirect_url)         → webview_flutter → Snap

[Midtrans]  user bayar
         ├── S2S  POST api/v1/payments/webhook    → SATU-SATUNYA yang boleh
         │        1. verifikasi signature SHA-512      mengubah status
         │        2. verifikasi gross_amount
         │        3. guard idempoten
         │        → payment: paid · order: processing · booking: paid
         └── browser redirect  GET /payment/finish (web.php)
                  TIDAK mengubah status apa pun
                   → redirect livirooms://payment-result?paymentId=..&orderId=..

[App]  DeepLinkHandler → PaymentResultScreen
         GET payments/{payment}                   → sumber kebenaran status
         kalau masih pending:
         POST payments/{payment}/reconcile        → tarik status dari Midtrans
```

**Tiga aturan yang tidak boleh dilanggar:**

1. **Deep link tidak membawa status.** `PaymentResultScreen` wajib
   `GET payments/{id}`. Jangan pernah menampilkan "berhasil" karena deep link
   datang — user bisa menutup Snap tanpa bayar dan tetap dilempar ke deep link.
2. **Callback browser tidak boleh menulis.** `Payment/*Controller` hanya parse
   `order_id` → redirect. Status hanya dari webhook S2S atau `reconcile`.
3. **Webhook tidak dipanggil klien.** Lihat §2 #21.

Race webhook-vs-user: kalau user kembali ke app sebelum webhook masuk,
`GET payments/{id}` masih `pending` — itulah gunanya `reconcile`, bukan polling
buta.

---

## 7. Ringkasan kesehatan kontrak

| Metrik | Nilai |
|---|---|
| Endpoint backend | **84** (21 publik, 63 sanctum) |
| Dipanggil app & lengkap | **77** ✅ |
| Ada di backend, belum dipakai app | **5** ⬜ |
| Dipanggil app, fixture dummy hilang | **1** 🟡 (`PUT host/room-types/{id}`) |
| Ada tapi salah arsitektur | **1** ⚠️ (klien memanggil webhook S2S) |
| **Dipanggil app, route tidak ada** | **2** ❌ (dua `DELETE` hotel/room-type) |
| Entri tabel dummy | **80** dari 84 |

Detail dan status setiap temuan: `04-drift-register.md`.
