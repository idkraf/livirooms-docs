# Frontend Map — Flutter

> **Fungsi file ini.** Peta lengkap `flutter/` untuk AI: struktur, 45 route,
> 45 layar, 19 service, 44 model, lapisan API, deep link, jebakan. Dibaca
> sebagai ganti menjelajah `lib/` secara buta.
>
> **Diverifikasi dari kode pada 2026-08-20.** 188 file `.dart` di `lib/`.

---

## 1. Bentuk aplikasi

**Satu aplikasi Flutter, dua peran** — dibedakan oleh shell, bukan oleh build:

| Peran | Shell | Masuk lewat |
|---|---|---|
| Konsumen | `lib/screens/main_shell.dart` | `Routes.home` setelah login |
| Mitra / Host | `lib/screens/mitra_shell.dart` | `Routes.mitraHome` |

`pubspec.yaml`: name `livirooms`, version **1.0.3+103**, Dart SDK `>=3.3.0 <4.0.0`.

### Stack aktual — jangan menebak dari nama paket populer

```yaml
provider           ^6.1.2    # state management — BUKAN Riverpod, BUKAN Bloc
http               ^1.2.1    # HTTP — BUKAN Dio
shared_preferences ^2.5.2    # token & preferensi
webview_flutter    ^4.13.0   # halaman Midtrans Snap
app_links          ^6.3.2    # deep link livirooms://
cached_network_image ^3.3.1
intl               ^0.20.3   # locale id_ID
image_picker       ^1.2.0
url_launcher       ^6.3.1
cupertino_icons
```

**Tidak ada** `firebase_*` / `firebase_messaging` — meski backend menyediakan
`POST devices/fcm-token`. Notifikasi push belum benar-benar tersambung.
**Tidak ada** `google_maps_flutter` — meski `AppConfig.googleMapsApiKey` ada.
**Tidak ada** `share_plus`.

Aset terdaftar: `assets/json/`, `assets/images/`, `assets/logo/`.

---

## 2. Struktur `lib/` — 188 file

```
lib/
├── main.dart              MaterialApp, MultiProvider, DeepLinkHandler
├── router.dart            SEMUA route: class Routes + AppRouter.onGenerateRoute
├── config/
│   ├── app_config.dart    baseUrl, dummy, appName, googleMapsApiKey
│   └── theme.dart
├── screens/   45 *_screen.dart + 2 shell  (per area, lihat §4)
├── services/  19 file                     (1 per domain + lapisan transport)
├── models/    44 file                      (17 di antaranya booking_* sub-model)
├── providers/  2 file                      (auth_provider, hotel_search_provider)
├── widgets/    7 file
└── utils/      4 file                      (detail_icons, fmt, formatters, promo_labels)
```

---

## 3. Bootstrap — `main.dart`

| Baris | Isi |
|---|---|
| `:13` | `initializeDateFormatting('id_ID', null)` — locale Indonesia |
| `:31` | `_navigatorKey` — dibutuhkan deep link untuk navigasi tanpa context |
| `:37` | `DeepLinkHandler(_navigatorKey)` di-start di `initState` |
| `:50-58` | `MultiProvider` — **hanya** `ChangeNotifierProvider<AuthProvider>`, memanggil `provider.bootstrap()` |
| `:61` | `MaterialApp(title: 'Livirooms')` ⚠️ |
| `home:` | `const SplashScreen()` |

⚠️ **`HotelSearchProvider` didefinisikan tapi tidak pernah diregistrasi** di
`MultiProvider`. Orphan — `context.read<HotelSearchProvider>()` akan throw.
Pencarian hotel saat ini memakai state lokal layar, bukan provider itu.

⚠️ **Tiga string brand berbeda**: `pubspec.yaml` name `livirooms` ·
`AppConfig.appName = 'Livirooms'` · `MaterialApp title: 'Livirooms'`.
Lihat `04-drift-register.md`.

---

## 4. Router — 45 route, semuanya di satu file

`lib/router.dart`. Dua bagian yang **wajib sinkron**:
`class Routes { static const ... }` (45 konstanta) dan
`AppRouter.onGenerateRoute` (45 `case`).

**Konvensi: setiap navigasi lewat named route.** Menambah layar = tambah
konstanta + tambah `case`. Jangan `MaterialPageRoute` inline.

### Tabel route

| Konstanta | Path | Layar | Argumen |
|---|---|---|---|
| `splash` | `/splash` | `SplashScreen` | — |
| `onboarding` | `/onboarding` | `OnboardingScreen` | — |
| `welcome` | `/welcome` | `WelcomeScreen` | — |
| `login` | `/login` | `LoginScreen` | — |
| `register` | `/register` | `RegisterScreen` | — |
| `registerProfile` | `/register/profile` | `RegisterProfileScreen` | data registrasi |
| `home` | `/home` | **`MainShell`** (tab konsumen) | — |
| `filter` | `/filter` | `FilterScreen` | filter aktif |
| `searchResults` | `/search-results` | `SearchResultsScreen` | query pencarian |
| `propertyDetail` | `/property-detail` | `PropertyDetailScreen` | `int` propertyId |
| `hotelSearch` | `/hotel-search` | `HotelSearchScreen` | — |
| `hotelResults` | `/hotel-results` | `HotelResultsScreen` | `HotelSearchQuery` |
| `hotelDetail` | `/hotel-detail` | `HotelDetailScreen` | `HotelDetailArgs` \| `Hotel` \| `int` — fallback `101` |
| `hotelBooking` | `/hotel-booking` | `HotelBookingScreen` | `HotelBookingArgs` \| `Hotel` |
| `bookingDetail` | `/booking-detail` | `BookingDetailScreen` | `int` bookingId |
| `bookingDetailHotel` | `/booking-detail-hotel` | `BookingDetailHotelScreen` | `BookingDetailArgs` \| `int` \| `HotelBookingDetail` |
| `bookingList` | `/booking-list` | `BookingListScreen` | — |
| `bookingSuccess` | `/booking-success` | `BookingSuccessScreen` | hasil booking |
| `chatList` | `/chat-list` | `ChatListScreen` | — |
| `chatRoom` | `/chat-room` | `ChatRoomScreen` | conversation |
| `account` | `/account` | `AccountScreen` | — |
| `editProfile` | `/edit-profile` | `EditProfileScreen` | — |
| `validation` | `/validation` | `ValidationScreen` | — |
| `wishlist` | `/wishlist` | `WishlistScreen` | — |
| `referral` | `/referral` | `ReferralScreen` | — |
| `paymentMethod` | `/payment-method` | `PaymentMethodScreen` | order/booking |
| `addCard` | `/add-card` | `AddCardScreen` | — |
| `promo` | `/promo` | `PromoScreen` | — |
| `paymentResult` | `/payment-result` | `PaymentResultScreen` | paymentId (dari deep link) |
| `paymentWebview` | `/payment-webview` | `PaymentWebviewScreen` | `redirect_url` Snap |
| `security` | `/security` | `SecurityScreen` | — |
| `notifications` | `/notifications` | `NotificationScreen` | — |
| `notificationSettings` | `/notification-settings` | `NotificationSettingsScreen` | — |
| `help` | `/help` | `HelpScreen` | — |
| `language` | `/language` | `LanguageScreen` | — |
| `mitraHome` | `/mitra` | **`MitraShell`** (tab mitra) | — |
| `mitraDashboard` | `/mitra/dashboard` | `MitraDashboardScreen` | — |
| `mitraProperties` | `/mitra/properties` | `MitraPropertiesScreen` | — |
| `mitraPropertyForm` | `/mitra/property-form` | `MitraPropertyFormScreen` | property (edit) / null (baru) |
| `mitraHotelForm` | `/mitra/hotel-form` | `MitraHotelFormScreen` | hotel (edit) / null |
| `mitraCalendar` | `/mitra/calendar` | `MitraCalendarScreen` | — |
| `mitraOrders` | `/mitra/orders` | `MitraOrdersScreen` | — |
| `mitraOrderDetail` | `/mitra/order-detail` | `MitraOrderDetailScreen` | `int` bookingId |
| `mitraWallet` | `/mitra/wallet` | `MitraWalletScreen` | — |
| `mitraProfile` | `/mitra/profile` | `MitraProfileScreen` | — |

### Toleransi bentuk argumen — sengaja, jangan "dirapikan"

Tiga route menerima beberapa tipe argumen karena dipanggil dari jalur berbeda
(deep link, list, detail):

- `hotelDetail` → `HotelDetailArgs` \| `Hotel` \| `int`; kalau semua gagal
  **fallback ke hotelId `101`** (data seeder). Ini menyembunyikan bug pemanggil.
- `hotelBooking` → `HotelBookingArgs` \| `Hotel` polos.
- `bookingDetailHotel` → `BookingDetailArgs` \| `int` \| `HotelBookingDetail`.

⚠️ `router.dart` masih memuat `print()` debug di jalur produksi.

### Layar yang TIDAK punya route

- `HomeScreen` — di-embed sebagai tab `MainShell` (`main_shell.dart:41`),
  bukan route. Mencari `Routes.home` mengarah ke `MainShell`, bukan `HomeScreen`.
- `RincianUnitScreen` — dipush **inline** `MaterialPageRoute` di
  `property_detail_screen.dart:356`. Melanggar konvensi router terpusat.

---

## 5. Layar per area — 45 `*_screen.dart` + 2 shell

| Area | Layar |
|---|---|
| `auth/` | splash, onboarding, welcome, login, register, register_profile |
| `home/` | home, filter, search_results |
| `property/` | property_detail, rincian_unit, hotel_search, hotel_results, hotel_detail |
| `booking/` | hotel_booking, booking_detail, booking_detail_hotel, booking_list, booking_success |
| `chat/` | chat_list, chat_room |
| `account/` | account, edit_profile, validation, wishlist, referral |
| `payment/` | payment_method, add_card, promo, payment_result, payment_webview |
| `settings/` | security, notification_settings, help, language |
| `notification/` | notification |
| `mitra/` | mitra_home, mitra_dashboard, mitra_properties, mitra_property_form, mitra_hotel_form, mitra_calendar, mitra_orders, mitra_order_detail, mitra_wallet, mitra_profile |
| shell | `main_shell.dart`, `mitra_shell.dart` |

---

## 6. Lapisan API — `ApiTransport`

Ini bagian paling penting untuk dipahami sebelum menyentuh service apa pun.

```
Screen
  → services/{domain}_service.dart      ← satu file per domain, hanya di sini
    → services/api_client.dart          ← abstraksi ApiTransport
      ├── _RealApiClient      → http package → Laravel
      └── DummyApiClient      → assets/json/*.json  (offline)
        → models/api_response.dart      ← membongkar amplop
```

### Pemilihan transport

`AppConfig.dummy` (`app_config.dart:18`):
```dart
static const bool dummy =
    String.fromEnvironment('DUMMY_API', defaultValue: 'false') == 'true';
```
Default **false** → real API. Aktifkan dummy dengan
`flutter run --dart-define=DUMMY_API=true`.

> Catatan: gotcha lama di `flutter/CLAUDE.md` soal "logika `AppConfig.dummy`
> membingungkan / default true" sudah **tidak berlaku** — kodenya sekarang
> jelas `defaultValue: 'false'`.

### Base URL

`app_config.dart:11`:
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  // defaultValue: 'https://ipanzipang.pro/api/v1',   ← prod, dikomentari
  defaultValue: 'http://192.168.1.20:8000/api/v1',    ← IP LAN developer
);
```
⚠️ Default adalah IP LAN spesifik. Untuk emulator Android **wajib** override:
`--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1`.

### Membongkar amplop

`models/api_response.dart:55` mendeteksi amplop Laravel dengan
`json.containsKey('status')` — **bukan** `'success'`. Kalau backend pernah
mengganti nama kunci itu, seluruh app berhenti mem-parsing. Lihat
`01-backend-map.md` §5.

### Token

`services/auth_storage.dart` — baca/tulis token Sanctum di `shared_preferences`.
`AuthProvider.bootstrap()` (dipanggil di `main.dart:50-58`) memulihkan sesi
saat app dibuka.

---

## 7. Service — 19 file, satu per domain

Aturan: **panggilan HTTP hanya boleh ada di `lib/services/`.** Layar tidak
pernah memanggil `ApiClient` langsung.

| Service | Domain |
|---|---|
| `auth_service.dart` | register, login, me, logout |
| `profile_service.dart` | profil, become-host, validasi identitas |
| `home_service.dart` | feed home |
| `city_service.dart` | kota & detail kota |
| `property_service.dart` | pencarian, detail, harga, review, ketersediaan, host, plan asuransi |
| `hotel_service.dart` | hotel, tipe kamar, checkout hotel, CRUD hotel mitra |
| `booking_service.dart` | booking, order, payment, review |
| `voucher_service.dart` | daftar & apply voucher |
| `wishlist_service.dart` | wishlist |
| `referral_service.dart` | kode, daftar, apply, status |
| `chat_service.dart` | conversation & message |
| `notification_service.dart` | notifikasi, read, read-all, token FCM |
| `content_service.dart` | FAQ, CMS, remote config |
| `remote_config_service.dart` | pembungkus remote config |
| `host_service.dart` | dashboard/properti/order/wallet/withdrawal mitra |
| `api_client.dart` | `ApiTransport` + `_RealApiClient` |
| `dummy_api_client.dart` | transport offline dari assets |
| `auth_storage.dart` | penyimpanan token |
 | `deep_link_handler.dart` | penanganan `livirooms://` |

Peta lengkap **endpoint ↔ method service ↔ layar**: `03-api-contract.md`.

### Contoh bentuk service — `property_service.dart`

| Method | Endpoint | Catatan |
|---|---|---|
| `search()` | `GET properties` | param: q, city_id, property_type, guests, bedrooms, min_price, max_price, sort, page |
| `detail(id)` | `GET properties/{id}` | |
| `pricing(id, {priceType})` | `GET properties/{id}/pricing` | |
| `reviews(id, {page})` | `GET properties/{id}/reviews` | |
| `availability(id, {from, to})` | `GET properties/{id}/availability` | memfilter `is_available == false` → daftar tanggal terblokir |
| `host(id)` | `GET properties/{id}/host` | |
| `getInsurancePlans()` | `GET insurance/plans` | |

---

## 8. Model — 44 file

Model biasa: `property.dart`, `hotel.dart`, `room_type.dart`, `booking.dart`,
`order.dart`, `payment.dart`, `city.dart`, `user.dart`, `review.dart`,
`voucher.dart`, `conversation.dart`, `message.dart`, `referral.dart`,
`insurance_plan.dart`, `api_response.dart`, `hotel_search_query.dart`, dst.

**17 file `booking_*`** adalah sub-model pecahan untuk layar detail booking
hotel (`booking_detail_hotel_screen.dart`) — satu bagian kartu = satu model.
Kalau menambah field di response detail booking hotel, cek dulu sub-model mana
yang memilikinya sebelum membuat model baru.

Provider (`lib/providers/`): **2 file** —
- `auth_provider.dart` ✅ terpakai (registered di `main.dart`)
- `hotel_search_provider.dart` ⚠️ orphan (tidak pernah diregistrasi)

Widget (`lib/widgets/`): `app_network_image`, `booking_status_card`, `city_list`,
`insurance_selection_widget`, `property_card`, `state_views`.

Util (`lib/utils/`): `detail_icons`, `fmt`, `formatters`, `promo_labels`.

---

## 9. Deep link — `livirooms://`

`services/deep_link_handler.dart`, paket `app_links`, butuh `navigatorKey`
dari `main.dart:31`.

| URI | Aksi |
|---|---|
 | `livirooms://payment-result?paymentId=..&orderId=..` | push `Routes.paymentResult` |
 | `livirooms://search?...` | push pencarian |

**Aturan penting:** backend **tidak** mengirim status pembayaran di URL
(`01-backend-map.md` §8). Jadi `PaymentResultScreen` **wajib** memanggil
`GET payments/{id}` untuk tahu hasil sebenarnya. Jangan pernah menyimpulkan
"berhasil" dari fakta deep link datang.

### Alur bayar di sisi app

```
PaymentMethodScreen
  → POST orders/{id}/pay          → { snap_token, redirect_url }
  → PaymentWebviewScreen(redirect_url)      (webview_flutter)
  → Midtrans redirect → /payment/finish (Laravel)
   → redirect livirooms://payment-result?paymentId=..
  → DeepLinkHandler → PaymentResultScreen
  → GET payments/{id}                        ← sumber kebenaran status
  → kalau masih pending: POST payments/{id}/reconcile
```

---

## 10. Titik masuk kode — mulai dari sini

| Pertanyaan | File:baris |
|---|---|
| Semua route & argumennya | `lib/router.dart` |
| Base URL / mode dummy / nama app | `lib/config/app_config.dart:11,18,24` |
| Provider yang aktif | `lib/main.dart:50-58` |
| Deep link di-start | `lib/main.dart:37` |
| Amplop API dibongkar | `lib/models/api_response.dart:55` |
| Transport dipilih (real vs dummy) | `lib/services/api_client.dart` |
| Token disimpan | `lib/services/auth_storage.dart` |
| Checkout unit dipanggil | `lib/services/booking_service.dart` (`booking-property`) |
| Checkout hotel dipanggil | `lib/services/hotel_service.dart` (`booking-hotels`) |
| Tanggal terblokir dihitung | `lib/services/property_service.dart` → `availability()` |
| Tab konsumen | `lib/screens/main_shell.dart:41` |
| Tab mitra | `lib/screens/mitra_shell.dart` |
| Layar inline yang melanggar router | `lib/screens/property/property_detail_screen.dart:356` |

---

## 11. Konvensi & jebakan

**Konvensi**
1. Navigasi **selalu** lewat `Routes.*` + `case` di `AppRouter`.
2. HTTP **hanya** di `lib/services/`.
3. Amplop dideteksi lewat kunci `status`, bukan `success`.
4. Locale `id_ID` — format tanggal/uang lewat `lib/utils/fmt.dart`.
5. Mockup visual: `screens_flutter/*.png` (referensi desain, bukan kode).

**Jebakan**
- `HotelSearchProvider` orphan → jangan `context.read` untuknya.
- `hotelDetail` fallback ke id `101` → bug pemanggil jadi tak terlihat.
- Default `baseUrl` IP LAN → selalu override saat menjalankan.
- `print()` di `router.dart` → jangan tambah lagi.
- `RincianUnitScreen` di-push inline → jangan dijadikan contoh.
- `HomeScreen` tidak punya route → jangan cari `Routes.homeScreen`.
- FCM: endpoint token ada di backend, paket Firebase **tidak** terpasang.
- **Dua endpoint DELETE dipanggil app tapi tidak ada di backend** — lihat
  `04-drift-register.md` §2-3. Pasti 404.
