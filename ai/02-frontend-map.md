# Frontend Map — Flutter (Livirooms)

> **Fungsi file ini.** Peta lengkap `flutter/` untuk AI: struktur, 47 route,
> 110 layar/widget, 20 service, 46 model, lapisan API, deep link, dan fixture mapping.
>
> **Master JSON Contracts:** [`GET_hotels_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id_new.json) & [`GET_properties_id_new.json`](file:///d:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_properties_id_new.json).

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
├── models/                46 model (Property, Hotel, UnitType, Booking, dll)
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
  ├── Hotel Wizard (5 tabs)
  │   ├── Tab 1: Info Hotel → name, star_rating, open_year, check_in/out, cancellation_policy
  │   ├── Tab 2: Fasilitas → facility_groups[]
  │   ├── Tab 3: Tipe Kamar → room_types[] (name, price, capacity, inventory)
  │   ├── Tab 4: Inventaris → room_type.remaining
  │   └── Tab 5: Galeri & FAQ → gallery[], faqs[], transport_points[]
  └── Submit → HotelService.createHotelForProperty()
      ├── POST host/hotels (hotelPayload)
      └── POST host/hotels/{id}/room-types (roomTypesPayload)
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
| `HotelFaqItem` | `AccommodationQuestionResource` | FAQ item |
| `NearbyPlace` | `NearbyPointResource` | Transport/nearby point |
