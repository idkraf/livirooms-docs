# Frontend Map — Flutter (Livirooms)

> **Fungsi file ini.** Peta lengkap `flutter/` untuk AI: struktur, 47 route,
> 110 layar/widget, 20 service, 46 model, lapisan API, deep link, dan fixture mapping.
>
> **Catatan arsitektur:** `Property.php` dan `Hotel.php` telah dihapus. Semua relasi terkonsolidasi di `Accommodation.php` dengan diskriminator `booking_mode`.
>
> **Master JSON Contracts:** [`GET_hotels_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id_new.json) & [`GET_properties_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_properties_id_new.json).
>
> **Backend model contract:** `App\Models\Accommodation` adalah single source of truth. `Property.php` dan `Hotel.php` telah dihapus. Semua relasi terkonsolidasi di `Accommodation.php` dengan diskriminator `booking_mode` (`room` = Hotel, `unit` = Property).

---

## 1. Bentuk Aplikasi

**Satu aplikasi Flutter, dua peran** yang dibedakan oleh shell:

| Peran | Shell | Entry Route |
|---|---|---|
| Konsumen | `lib/screens/main_shell.dart` | `Routes.home` |
| Mitra / Host | `lib/screens/mitra_shell.dart` | `Routes.mitraHome` |

### Stack Terpasang
- State management: **`provider ^6.1.2`**
- HTTP Client: **`http ^1.2.1`**
- WebView Snap: **`webview_flutter ^4.13.0`**
- Deep Link: **`app_links ^6.3.2`** (`livirooms://payment-result`)
- Formatting: **`intl ^0.20.3`** (`id_ID`)

---

## 2. Struktur `lib/`

```
lib/
├── main.dart              MaterialApp, MultiProvider, DeepLinkHandler, navigatorObservers [routeObserver]
├── router.dart            Routes (47 route) + AppRouter.onGenerateRoute + global routeObserver
├── config/                AppConfig (baseUrl, dummy toggle), theme
├── screens/               110 *_screen.dart + 2 shell (MainShell, MitraShell)
│   ├── mitra/             PropertyManagementScreen, AccommodationFormScreen (Unified Wizard), etc.
│   │   └── sheets/        11 modal bottom sheets (room_spec, bed_facility, price_scheme, operational_rule, checkin_checkout_note, policy_item, etc.)
│   ├── home/              MainShell, FilterScreen, SearchResultsScreen
│   ├── property/          PropertyDetailScreen, RincianUnitScreen, Hotel screens
│   ├── booking/           BookingDetailScreen, BookingListScreen, etc.
│   ├── payment/           PaymentMethodScreen, PaymentResultScreen, etc.
│   ├── account/           AccountMenuScreen, EditProfileScreen, etc.
│   ├── auth/              LoginScreen, RegisterScreen, SplashScreen, etc.
│   ├── chat/              ChatListScreen, ChatRoomScreen
│   └── settings/          HelpSupportScreen, NotificationSettingsScreen, etc.
├── services/              20 service (Http, Auth, Property, Hotel, Payment, SearchLog, dll)
├── models/                46 model (Accommodation, UnitType, Booking, dll)
├── providers/             AuthProvider (registered), HotelSearchProvider
└── utils/                 Formatters, icons, promo helpers
```

---

## 3. Integrasi API & Dummy Mode

Aplikasi mendukung mode live API dan fallback fixture JSON terstandar di `assets/json/`:
- **Hotel Detail Screen (`/hotel/detail`):** Mengonsumsi `GET /api/v1/hotels/{id}` atau fixture `GET_hotels_id_new.json`.
- **Property Detail Screen (`/property/detail`):** Mengonsumsi `GET /api/v1/properties/{id}` atau fixture `GET_properties_id_new.json`.
- **Unified API:** Backend Laravel merespons kedua payload tersebut melalui `App\Http\Resources\AccommodationResource` yang 100% kompatibel tanpa perlu adaptasi di Flutter.

---

## 4. Accommodation Creation Flow (Flutter → Laravel)

### Alur Lengkap

```
Flutter AccommodationFormScreen
  ├── Mode Selection (room / unit)
  ├── Accommodation Wizard (7 tabs)
  │   ├── Tab 1: Info Dasar → name, property_type, address, city, building_list, status
  │   ├── Tab 2: Kapasitas & Kamar (unit) / Tipe Kamar (room) → capacity, bedrooms, bathrooms, room_types[]
  │   ├── Tab 3: Harga → base_price, price_original, prices[]
  │   ├── Tab 4: Fasilitas → facility_groups[], facility_tags[], bed_facilities[]
  │   ├── Tab 5: Konten → gallery[], intro, description_extra
  │   ├── Tab 6: Kebijakan → cancellation_policy, check_in/out_time, deposit_amount, policies[]
  │   ├── Tab 7: Lokasi & FAQ → latitude, longitude, map_preview, faqs[], nearby_points[]
  └── Submit → HostService.createProperty() / HotelService.createHotelForProperty()
      ├── POST host/properties (propertyPayload) — untuk unit mode
      └── POST host/hotels (hotelPayload) + POST host/hotels/{id}/room-types — untuk room mode
```

### Service Methods

| Flutter Service | Laravel Endpoint | Method |
|---|---|---|
| `HotelService.createHotelForProperty()` | `POST host/hotels` + `POST host/hotels/{id}/room-types` | Hotel creation |
| `HotelService.updateHotelForProperty()` | `PUT host/hotels/{id}` + `PUT/POST host/room-types/{id}` | Hotel update |
| `HotelService.getHostHotelDetail()` | `GET host/hotels/{id}` | Host-side detail |
| `HostService.createProperty()` | `POST host/properties` | Property creation |
| `HostService.updateProperty()` | `PUT host/properties/{id}` | Property update |
| `HostService.propertyDetail()` | `GET host/properties/{id}` | Property detail |

---

## 5. Model Mapping

| Flutter Model | Laravel Resource | Purpose |
|---|---|---|
| `Hotel` | `AccommodationResource` (hotelShape) | Hotel detail screen |
| `AccommodationHotel` | `AccommodationHotelListResource` | Hotel search/listing card |
| `Property` | `AccommodationResource` (propertyShape) | Property detail screen |
| `HotelRoomItem` | `UnitTypeResource` | Room type card |
| `HotelFacilityGroup` | `FacilityGroupResource` | Facility group |
| `HotelPolicy` | `AccommodationPolicyResource` | Policy block |
| `AccommodationFaqItem` | `AccommodationQuestionResource` | FAQ item |
| `NearbyPlace` | `NearbyPointResource` | Transport/nearby point |
| `Review` | `ReviewResource` | Guest review after completed booking |
| `ReviewPhoto` | `ReviewPhotoResource` | Photo attachment for guest review |
| `AccommodationDetailRoom` (JSON dummy) | `AccommodatonDetailRoomResource` | **Baru** — Detail & Booking mode `room` (`lib/screens/accommodation/accommodation_detail_room_screen.dart`) |
| `AccommodationDetailUnit` (JSON dummy) | `AccommodationDetailUnitResource` | **Baru** — Detail & Booking mode `unit` (`lib/screens/accommodation/accommodation_detail_unit_screen.dart`) |

> **Flutter dummy assets (struktur `policies` per `section`):** `assets/json/accommodation_room_id.json` (mode `room`) & `assets/json/accommodation_unit_id.json` (mode `unit`). Kedua file mereplikasi persis output API Resource, dengan blok `policies` dikelompokkan berdasarkan `section` (`general`, `check_in`, `check_out`, `cancellation`, `smoking_policy`, `extra_bed_policy`, `deposit`, `room_policy`).

> **Seeder aman (chunking):** `AccommodationSeeder` memproses seluruh pekerjaan seed dalam chunk eksplisit (maksimal 100 chunk) dengan jeda `sleep(2)` di akhir setiap chunk untuk mencegah beban puncak CPU/memori saat `migrate:fresh --seed`.
 
---

## 6. Lifecycle & Navigation Auto-Refresh

- **`BookingListScreen` (`/bookings` & Tab 1 MainShell):**
  - Mengimplementasikan `RouteAware` dengan mendaftarkan diri ke `routeObserver` di `didChangeDependencies()`. Ketika user kembali dari halaman detail booking atau pembayaran (`didPopNext()`), data booking otomatis di-fetch ulang (`_load()`).
  - Mendukung `didUpdateWidget(oldWidget)` dengan parameter `isActive` yang di-pass dari `MainShell` (`isActive: _index == 1`). Pergantian tab di dalam `IndexedStack` otomatis memicu reload tanpa perlu me-recreate state.
  - Menggunakan `WidgetsBindingObserver` (`didChangeAppLifecycleState`) untuk mendeteksi status `AppLifecycleState.resumed` saat user kembali ke aplikasi setelah menyelesaikan pembayaran di luar aplikasi (misalnya browser Midtrans Snap / e-wallet).
  - Pada `_BookingTab._openDetail()`, `Navigator.pushNamed(...)` di-`await`, dan pemanggilan `onRefresh()` langsung dieksekusi begitu navigasi ditutup (`pop`).
  - Mengawasi perubahan user pada `AuthProvider` di dalam `didChangeDependencies()` agar data otomatis ter-refresh saat status autentikasi berubah.

---

## 7. Booking Status Display & Action Button Invariants

Penyajian status pemesanan dan tombol aksi mengikuti aturan:
- **`completed` (Pesanan Selesai):** Menampilkan penjelasan eksplisit di layar bahwa masa sewa/inap telah selesai (`Pesanan Selesai`, ikon centang hijau `AppColors.success`). Tombol **Bayar** dan **Batalkan Pemesanan** tidak ditampilkan.
- **`cancelled` & `expired` (Dibatalkan / Kedaluwarsa):** Menampilkan penjelasan status pembatalan atau kedaluwarsa dengan warna `AppColors.danger`. Tombol **Bayar** dan **Batalkan Pemesanan** tidak ditampilkan sama sekali.
- **`waiting_payment` (Menunggu Pembayaran):** Menampilkan countdown timer serta tombol aktif **Bayar** (dan tombol **Batalkan Pemesanan** jika diizinkan kebijakan pembatalan).
- **Layar & Komponen Terkait:**
  - `lib/screens/booking/booking_detail_screen.dart` (Property Booking Detail)
  - `lib/screens/booking/booking_detail_hotel_screen.dart` (Hotel Booking Detail)
  - `lib/screens/booking/widgets/booking_widgets_bottom_bar.dart`
  - `lib/screens/booking/widgets/booking_widgets_segment_status.dart`

---

## 8. Authentication & Role Routing (Mitra vs Consumer)

- **Routing Shell:**
  - `User` dengan status host (`auth.isHost == true`) otomatis diarahkan ke `Routes.mitraHome` (`MitraShell`) baik saat selesai login di `LoginScreen` maupun saat auto-login di `SplashScreen`.
  - `User` dengan status konsumen biasa diarahkan ke `Routes.home` (`MainShell`).
- **Resolusi Status Host (`User.isHost`):**
  - **Flutter (`User.isHost`):** Mengevaluasi `type == 'host'`, array `roles.contains('host')`, serta fallback pola email host (`.host@` / `host@` seperti `budi.host@example.com`).
  - **Laravel (`AuthController` & `ProfileController`):** Memvalidasi `$user->hasRole('host')`, kepemilikan properti/hotel (`Accommodation::where('host_id', $user->id)->exists()`), atau pola email host. Otomatis memperbarui `UserProfile.type = 'host'` dan menyertakan `roles` dalam response JSON payload `auth/login`, `auth/me`, dan `profile`.

