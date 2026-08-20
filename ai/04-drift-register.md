# Drift Register — Docs & Klaim vs Kode

> **Fungsi file ini.** Daftar selisih **terverifikasi** antara apa yang ditulis
> docs/`CLAUDE.md` dan apa yang benar-benar ada di kode, plus cacat integrasi
> yang ditemukan saat menyusun paket ini.
>
> **Baca ini sebelum mempercayai file docs lain di luar `docs/ai/` dan
> `docs/domain/hotel-vs-property.md`.**
>
> **Diverifikasi dari kode pada 2026-08-20.** Setiap baris punya bukti path:baris.

Kategori:
**🔴 Bug** — kode salah, akan gagal saat dijalankan.
**🟠 Docs salah** — kode benar, dokumentasi menyesatkan.
**🟡 Bau kode** — jalan, tapi melanggar konvensi repo sendiri.

---

## Ringkasan

| # | Temuan | Kategori |
|---|---|---|
| 1 | `docs/INDEX.md` mereferensikan 17 file yang tidak ada | 🟠 |
| 2 | `DELETE host/room-types/{id}` dipanggil app, route tidak ada | 🔴 |
| 3 | `DELETE host/hotels/{id}` dipanggil app, route tidak ada | 🔴 |
| 4 | Klien memanggil webhook server-to-server | 🔴 |
| 5 | `PUT host/room-types/{id}` tidak ada di tabel dummy | 🔴 |
| 6 | `HotelSearchProvider` tidak pernah diregistrasi | 🔴 |
| 7 | Tiga string brand berbeda | ✅ Resolved |
| 8 | Dua migration bertimestamp identik | 🟡 |
| 9 | `laravel/CLAUDE.md` — 4 angka inventaris basi | 🟠 |
| 10 | `docs/INDEX.md` — tabel drift-nya sendiri sudah drift | 🟠 |
| 11 | `flutter/CLAUDE.md` — gotcha `AppConfig.dummy` sudah tidak berlaku | 🟠 |
| 12 | `flutter/CLAUDE.md` — 39 layar, aktual 45 | 🟠 |
| 13 | `laravel/CLAUDE.md` menunjuk `docs/payments/remediation.md` yang tidak ada | 🟠 |
| 14 | `RincianUnitScreen` di-push inline `MaterialPageRoute` | 🟡 |
| 15 | `print()` di `router.dart` | 🟡 |
| 16 | `hotelDetail` fallback ke hotelId `101` | 🟡 |
| 17 | `App\Models\Room` & `App\Models\PropertyOther` orphan | 🟡 |
| 18 | FCM: endpoint ada, paket Firebase tidak | 🟠 |
| 19 | `googleMapsApiKey` ada, paket maps tidak | 🟠 |
| 20 | Default `baseUrl` = IP LAN developer | 🟡 |

---

## ✅ Resolved

### 7. Tiga string brand berbeda

**Perbaikan:** Semua referensi `Sewain` diganti `Livirooms` di Flutter, Laravel, dan docs aktif pada 2026-08-20.

- Package: `sewain` → `livirooms`
- Deep link scheme: `sewain://` → `livirooms://`
- App name: `LIVI.COM` → `Livirooms`
- Semua UI strings, platform configs, docs, dan fixture diperbarui.

---

## 🔴 Bug — perlu keputusan/perbaikan

### 2. `DELETE host/room-types/{id}` — route tidak ada

**Bukti.** Dipanggil `flutter/lib/services/hotel_service.dart:58`.
Tidak ada di `laravel/routes/api_mobile.php`.
`HostHotelController` tidak punya method `destroyRoomType`.

**Akibat.** Hapus tipe kamar dari app mitra selalu 404.

**Kenapa tidak boleh asal ditambah.** Menghapus `RoomType` menyentuh
`room_inventories` (counter stok) dan `booking_rooms` (booking yang sudah ada).
Hapus keras bisa merusak booking aktif. **Baca invarian di
`docs/domain/hotel-vs-property.md` dulu**, lalu putuskan: soft delete, tolak
kalau ada booking aktif, atau `is_active = false`.

### 3. `DELETE host/hotels/{id}` — route tidak ada

**Bukti.** Dipanggil `flutter/lib/services/hotel_service.dart:63`.
Tidak ada route; tidak ada method `destroy` di `HostHotelController`.

**Akibat.** Hapus hotel dari app mitra selalu 404.

**Kenapa tidak boleh asal ditambah.** `hotels.property_id` UNIQUE + cascade.
Menghapus baris `hotels` **tidak** mengembalikan `properties.booking_mode` ke
`'unit'` — properti akan tertinggal dalam mode `room` tanpa hotel, dan hilang
dari kedua jalur pencarian. Lihat `docs/domain/hotel-vs-property.md`.

### 4. Klien memanggil webhook server-to-server

**Bukti.** `flutter/lib/services/booking_service.dart:224`
`await _api.post('payments/webhook', body: payload);`

**Kenapa salah.** `POST api/v1/payments/webhook` adalah endpoint Midtrans S2S.
Signature-nya SHA-512 atas `order_id + status_code + gross_amount + serverKey`
(`PaymentController.php:269`) — klien tidak punya `serverKey`, jadi hasilnya 403.
Kalau suatu saat verifikasi dilonggarkan, jalur ini menjadi cara memutasi status
pembayaran dari perangkat yang tidak dipercaya.

**Perbaikan.** Hapus method itu dari `booking_service.dart`. Konfirmasi status
yang benar sudah tersedia: `GET payments/{id}` + `POST payments/{id}/reconcile`.

### 5. `PUT host/room-types/{id}` tidak ada di tabel dummy

**Bukti.** Dipanggil `hotel_service.dart:48`. Tidak ada di
`DummyApiClient.routes` (`dummy_api_client.dart:70-193`).

**Akibat.** Di `--dart-define=DUMMY_API=true`, edit tipe kamar hotel gagal 404
— padahal jalan di mode nyata. Sesuai komentar di `dummy_api_client.dart:50-55`,
route yang tidak ada di tabel memang **sengaja** dibuat 404, jadi ini murni
entri yang lupa ditambah.

**Perbaikan.** Tambah `'PUT host/room-types/{id}': 'PUT_host_room_types_id'` +
fixture di `assets/json/`.

### 6. `HotelSearchProvider` tidak pernah diregistrasi

**Bukti.** `flutter/lib/providers/hotel_search_provider.dart` ada.
`main.dart:50-58` `MultiProvider` hanya memuat
`ChangeNotifierProvider<AuthProvider>`.

**Akibat.** `context.read<HotelSearchProvider>()` akan throw
`ProviderNotFoundException`. Saat ini pencarian hotel memakai state lokal layar,
jadi tidak ada yang meledak — tapi siapa pun yang mengikuti nama file itu akan
menulis kode yang crash.

**Perbaikan.** Registrasi di `MultiProvider`, atau hapus file-nya. Catatan:
`docs/hotel/04-flutter-implementation.md` (yang **tidak ada**, lihat #1) diklaim
INDEX.md sebagai dokumentasi `HotelSearchProvider` "✅ Selesai".

---

## 🟠 Docs salah — kode benar

### 1. `docs/INDEX.md` mereferensikan 17 file yang tidak ada

**File docs yang benar-benar ada — hanya 8:**

```
docs/INDEX.md
docs/README.md
docs/sfds.md
docs/configuration/admin-panel.md
docs/configuration/missing-files.md
docs/configuration/ui-patterns.md
docs/domain/hotel-vs-property.md
docs/features/referral.md
```

**Direferensikan INDEX.md tapi tidak ada** — seluruh direktori ini kosong/tidak
ada: `docs/payments/`, `docs/properties/`, `docs/hotel/`, `docs/flutter/`.

| Referensi hantu | Disebut INDEX.md di |
|---|---|
| `payments/flow.md` | :17, :35 |
| `payments/integration.md` | :36 |
| `payments/setup.md` | :37 |
| `payments/kebijakan_pengembalian_pembayaran.md` | :38 |
| `payments/remediation.md` | :17, :39 |
| `payments/trial_fix_payment.md` | :17, :40 |
| `payments/MOBILE_API_INSTALL.md` | :41 |
| `properties/system.md` | :48 |
| `properties/recommendations.md` | :49 |
| `hotel/01-database-migration.md` | :19, :50 |
| `hotel/02-models-relationships.md` | :51 |
| `hotel/03-query-filters.md` | :52 |
| `hotel/04-flutter-implementation.md` | :53 |
| `hotel/05-insurance-integration.md` | :54 |
| `hotel/06-hotel-management-flow.md` | :55 |
| `hotel/07-compatibility-map.md` | :56 |
| `flutter/screens.md` | :18, :68 |

**Dampak paling berbahaya:** INDEX.md :17 mengarahkan pekerjaan pembayaran ke
tiga file yang tidak ada, dan :19 mengarahkan pekerjaan hotel ke urutan
`hotel/01`–`07` yang tidak ada. Sesi AI yang menurutinya akan gagal membaca dan
berisiko mengarang. Gantinya sekarang: `docs/ai/01-backend-map.md` §8
(pembayaran) dan `docs/domain/hotel-vs-property.md` (hotel).

INDEX.md juga mencantumkan ukuran KB untuk file-file yang tidak ada — angka itu
karangan atau sisa dari file yang sudah dihapus.

### 7. Tiga string brand berbeda — ✅ RESOLVED

**Status:** Fixed in branding rename to Livirooms.

| Lokasi | Nilai |
|---|---|
| `flutter/pubspec.yaml` `name:` | `livirooms` |
| `flutter/lib/config/app_config.dart:24` | `'Livirooms'` |
| `flutter/lib/main.dart:61` `MaterialApp title:` | `'Livirooms'` |
| root `CLAUDE.md` | **Livirooms** |

Deep link scheme konsisten `livirooms` (`PaymentDeepLink.php:20`).
Semua referensi `Sewain` di Flutter, Laravel, dan docs aktif sudah diganti.

### 9. `laravel/CLAUDE.md` — angka inventaris basi

| Klaim `laravel/CLAUDE.md` | Aktual |
|---|---|
| `Models/` "33 model" | **74** |
| `Api/` "17 controller" | **20** |
| `Admin/` "32 controller" | **33** |
| `Livewire/` "26 folder" | **30** |

`DataTables/ 27` ✅ benar.

### 10. `docs/INDEX.md` — tabel drift-nya sendiri sudah drift

INDEX.md :94-96 mencatat "realita aktual" per 2026-08-13 yang kini sudah lewat:

| Klaim INDEX.md sebagai "aktual" | Aktual 2026-08-20 |
|---|---|
| 32 Admin controller | **33** |
| 26 Livewire | **30** |
| 17 Api controller | **20** |
| 40 layar Flutter | **45** |
| "~50 base migration + 9 hotel" | **97 total** |

Ironi yang perlu dicatat: INDEX.md :103 menutup dengan aturan
**"jangan tulis daftar file di docs"** justru karena daftar cepat basi — lalu
tabel drift-nya sendiri membuktikan aturan itu. Paket `docs/ai/` sengaja
melanggar aturan itu (karena diminta sebagai konteks AI), dengan dua mitigasi:
setiap file bertanggal, dan `00-orientation.md` §5 memuat perintah baca-saja
untuk menghitung ulang semua angka.

### 11. `flutter/CLAUDE.md` — gotcha `AppConfig.dummy` sudah tidak berlaku

**Klaim.** "logikanya membingungkan:
`String.fromEnvironment('DUMMY_API', defaultValue: 'true') == 'false'`".

**Aktual** (`app_config.dart:18-22`):
```dart
static const bool dummy =
    String.fromEnvironment('DUMMY_API', defaultValue: 'false') == 'true';
```
Sudah lurus dan jelas. Gotcha itu **stale** — hapus dari `flutter/CLAUDE.md`.

### 12. `flutter/CLAUDE.md` — "39 file" layar

Aktual: **45** `*_screen.dart` + 2 shell. Pohon struktur di
`flutter/CLAUDE.md` juga memakai nama file lama yang tidak cocok:

| Disebut `flutter/CLAUDE.md` | Aktual |
|---|---|
| `promo_code` | `promo_screen.dart` |
| `account_menu` | `account_screen.dart` |
| `help_support` | `help_screen.dart` |
| `notification` (di `settings/`) | `notification_settings_screen.dart` |
| `availability_calendar` | `mitra_calendar_screen.dart` |
| — | `hotel_search`, `hotel_results`, `hotel_detail`, `hotel_booking`, `booking_detail_hotel`, `mitra_hotel_form`, `rincian_unit`, `payment_webview` **tidak disebut** |

Selain itu `flutter/CLAUDE.md` menempatkan `search_results` di `property/` —
aktualnya di `home/`.

### 13. `laravel/CLAUDE.md` menunjuk file yang tidak ada

"Sisa pekerjaan terbuka ada di `docs/payments/remediation.md` (T-5, T-12, dan
**T-14 `php artisan migrate` belum dijalankan di PostgreSQL**)."

File itu tidak ada (#1). Status T-14 karena itu **tidak dapat diverifikasi dari
docs** — dan di repo ini migration memang tidak boleh dijalankan, jadi jangan
mencoba mengonfirmasinya dengan menjalankan `migrate`.

`laravel/CLAUDE.md` juga menyebut `tests/Feature/Admin/ProbeTest.php` sebagai
"file diagnostik sementara yang seharusnya sudah dihapus" — merujuk
`remediation.md` yang sama.

### 18. FCM: endpoint ada, paket tidak

Backend: `POST devices/fcm-token` → `NotificationController::storeFcmToken`,
model `DeviceToken`, fixture dummy `POST_devices_fcm_token`, service
`notification_service.dart:31`. **Tapi `pubspec.yaml` tidak memuat
`firebase_core`/`firebase_messaging`** — tidak ada token nyata yang bisa
dihasilkan. Jalur ini lengkap di kedua ujung kecuali sumber tokennya.

### 19. `googleMapsApiKey` ada, paket maps tidak

`app_config.dart:27` menyediakan key; `pubspec.yaml` tidak memuat
`google_maps_flutter`. Peta belum diimplementasikan.

---

## 🟡 Bau kode — jalan, tapi melanggar konvensi repo

### 8. Dua migration bertimestamp identik

```
2026_08_16_000001_add_children_ages_to_bookings.php
2026_08_16_000001_create_properties_other_table.php
```

Urutan eksekusi jatuh ke alfabet nama file (`add_...` sebelum `create_...`).
Kebetulan aman karena keduanya menyentuh tabel berbeda, tapi jangan dijadikan
preseden. `create_properties_other_table` membuat tabel untuk model
`PropertyOther` yang orphan (#17).

### 14. `RincianUnitScreen` di-push inline

`flutter/lib/screens/property/property_detail_screen.dart:355-356`
```dart
MaterialPageRoute(
  builder: (_) => RincianUnitScreen(
```

Melanggar konvensi eksplisit `flutter/CLAUDE.md`: "Jangan `MaterialPageRoute`
inline di widget." Satu-satunya layar yang tidak lewat `Routes.*`. Jangan
dijadikan contoh saat menambah layar baru.

### 15. `print()` di `router.dart`

Debug statement tertinggal di jalur navigasi produksi. Ganti dengan
`debugPrint` atau hapus.

### 16. `hotelDetail` fallback ke hotelId `101`

`router.dart`, case `Routes.hotelDetail` menerima
`HotelDetailArgs` \| `Hotel` \| `int`, dan bila ketiganya gagal memakai
**hotelId `101`** (data seeder). Artinya pemanggil yang salah kirim argumen
tetap menampilkan halaman yang tampak benar — bug jadi tidak terlihat sampai
produksi, di mana id 101 mungkin milik hotel lain atau tidak ada.

### 17. Model orphan

`App\Models\Room` dan `App\Models\PropertyOther` — tidak dipakai controller,
Livewire, atau resource mana pun. Sudah tercatat di
`docs/domain/hotel-vs-property.md`; dicatat ulang di sini karena `Room` mudah
dikira bagian dari mekanika stok hotel. **Stok hotel ada di `RoomInventory`,
bukan `Room`.**

### 20. Default `baseUrl` = IP LAN developer

`app_config.dart:11-15`: `defaultValue: 'http://192.168.1.20:8000/api/v1'`,
dengan URL produksi `https://ipanzipang.pro/api/v1` dikomentari di atasnya.
Build tanpa `--dart-define=API_BASE_URL=...` akan menunjuk jaringan lokal
seseorang. Sudah didokumentasikan di `flutter/CLAUDE.md`, dicatat di sini karena
ini penyebab nomor satu "app tidak bisa connect".

---

## Cara memakai daftar ini

- **Sebelum mempercayai file docs**: cek apakah namanya muncul di #1. Kalau ya,
  file itu tidak ada — jangan mencoba membacanya, pakai `docs/ai/` sebagai ganti.
- **Sebelum mempercayai angka inventaris** di `CLAUDE.md` mana pun: pakai
  `docs/ai/00-orientation.md` §5 untuk menghitung ulang.
- **Sebelum melaporkan "endpoint rusak"**: cek `03-api-contract.md` §4-5 —
  mungkin sudah tercatat di sini.
- **Setelah memperbaiki salah satu item**: hapus barisnya dari file ini dan
  perbarui pack terkait. Register yang tidak dirawat berubah jadi kebisingan.
