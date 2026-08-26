# Frontend Map — Flutter (Livirooms)

> **Fungsi file ini.** Peta lengkap `flutter/` untuk AI: struktur, 45 route,
> 45 layar, 19 service, 44 model, lapisan API, deep link, dan fixture mapping.
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
├── router.dart            Routes (46 route) + AppRouter.onGenerateRoute
├── config/                AppConfig (baseUrl, dummy toggle), theme
├── screens/               46 *_screen.dart + 2 shell (MainShell, MitraShell)
│   └── mitra/             PropertyManagementScreen, AccommodationFormScreen (Unified Wizard), etc.
├── services/              20 service (Http, Auth, Property, Hotel, Payment, SearchLog, dll)
├── models/                44 model (Property, Hotel, UnitType, Booking, dll)
├── providers/             AuthProvider (registered), HotelSearchProvider
└── utils/                 Formatters, icons, promo helpers
```

---

## 3. Integrasi API & Dummy Mode

Aplikasi mendukung mode live API dan fallback fixture JSON terstandar di `assets/json/`:
- **Hotel Detail Screen (`/hotel/detail`):** Mengonsumsi `GET /api/v1/hotels/{id}` atau fixture `GET_hotels_id_new.json`.
- **Property Detail Screen (`/property/detail`):** Mengonsumsi `GET /api/v1/properties/{id}` atau fixture `GET_properties_id_new.json`.
- **Unified API:** Backend Laravel merespons kedua payload tersebut melalui `App\Http\Resources\AccommodationResource` yang 100% kompatibel tanpa perlu adaptasi di Flutter.
