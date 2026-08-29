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
├── main.dart              MaterialApp, MultiProvider, DeepLinkHandler
├── router.dart            Routes (47 route) + AppRouter.onGenerateRoute
├── config/                AppConfig (baseUrl, dummy toggle), theme
├── screens/               110 *_screen.dart + 2 shell (MainShell, MitraShell)
│   ├── mitra/             PropertyManagementScreen, AccommodationFormScreen (Unified Wizard), etc.
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
