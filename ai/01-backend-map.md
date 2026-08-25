# Backend Map — Laravel 12 (Livirooms)

> **Fungsi file ini.** Peta lengkap `laravel/` untuk AI: layer, inventaris,
> domain, state machine, pembayaran, admin panel, job, permission. Dibaca
> sebagai ganti menjelajah `app/` secara buta.
>
> Untuk arsitektur data Hotel vs Property, dokumen master adalah:
> 🔴 **`docs/domain/hotel-vs-property.md`**.

---

## 1. Dua Muka, Satu Aplikasi

| Muka | Entry Route | Auth | Response Handler |
|---|---|---|---|
| **REST API Mobile** | `routes/api_mobile.php`, prefix `api/v1` | `auth:sanctum` (Bearer token) | JSON amplop `ApiResponse` |
| **Admin Panel** | `routes/web.php` → `routes/admin_generated.php`, prefix `admin` | session + `role:admin\|host` | Blade (Metronic) + Livewire 4 + Yajra DataTables |
| **Website Publik** | `routes/web.php` → `Front/FrontController` | — | Blade |
| **Callback Midtrans** | `routes/web.php` → `Payment/{Finish,Unfinish,Error}Controller` | — | redirect ke deep link `livirooms://` |

`routes/api.php` **hanya** me-require `api_mobile.php`.

---

## 2. Stack Terpasang

```
laravel/framework          ^12.0
livewire/livewire          ^4.3      (Livewire 4)
laravel/sanctum            ^4.3
spatie/laravel-permission  ^6.9
yajra/laravel-datatables-* ^12.0
midtrans/midtrans-php      ^2.6
barryvdh/laravel-dompdf    *
```

Basis Data: **PostgreSQL** (`pgsql`) dengan 21 tabel ternormalisasi (3NF) untuk entitas akomodasi.

---

## 3. Inventaris Komponen Backend

| Direktori | Deskripsi & Isi |
|---|---|
| `app/Models/` | 21 model ternormalisasi produk (`Accommodation`, `UnitType`, `UnitTypePrice`, `FacilityItem`, `Gallery`, dll) + model auth, billing, cms |
| `app/Http/Resources/` | 17 resource produksi terpadu (`AccommodationResource`, `UnitTypeResource`, `FacilityItemResource`, dll) |
| `app/Http/Controllers/Api/` | 21 controller API mobile (`AccommodationController`, `PropertyController`, `HotelApiController`, `BookingController`, `PaymentController`, dll) |
| `app/Http/Controllers/Admin/` | 33 controller admin (thin, render index DataTable) |
| `app/Livewire/` | 30 folder komponen admin panel, termasuk `Properties/WizardForm` dan `Hotels/WizardForm` |
| `app/DataTables/` | 27 Yajra DataTables |
| `app/Support/` | `ApiResponse`, `MidtransSnap`, `MidtransGateway`, `PaymentDeepLink`, `HotelNormalizer` |
| `app/Jobs/` | `CancelExpiredBookingsJob`, `ExtendHotelInventoriesJob`, `IssueInsurancePolicyJob`, `SyncInsuranceStatusJob` |

---

## 4. Layer & Aliran Kontrol

```
API mobile:
  routes/api_mobile.php
    → app/Http/Controllers/Api/*Controller
      → Eloquent Model (21 Normalized Models)
      → app/Http/Resources/*Resource (e.g. AccommodationResource)
      → app/Support/ApiResponse::success() (JSON envelope)

Admin panel:
  routes/admin_generated.php & web.php
    → app/Http/Controllers/Admin/*Controller (index → DataTable)
    → app/Livewire/Properties/WizardForm & Hotels/WizardForm (Multi-Step Add/Edit)
      → Eloquent Model (DB::transaction)
```

---

## 5. Amplop API Standard (`ApiResponse`)

Setiap endpoint mengembalikan amplop terstandar:

```json
{
  "status": true,
  "code": 200,
  "message": "Detail akomodasi berhasil dimuat.",
  "data": { ... },
  "meta": null,
  "errors": null
}
```

---

## 6. Domain Akomodasi: Single Root `accommodations`

Satu entitas akar `accommodations` dengan diskriminator `booking_mode`:
- **`'unit'` (Property):** Satu unit utuh (apartemen, villa, kost). Menggunakan 1 baris `unit_types` internal untuk kapasitas (`max_guests`, `bedrooms`, `bathrooms`) dan tarif (`unit_type_prices`).
- **`'room'` (Hotel):** Dijual per tipe kamar via multiple `unit_types` dan `unit_type_images`.

Transformasi output ditangani oleh **`AccommodationResource`**:
- Menghasilkan `hotelShape()` untuk hotel (persis `GET_hotels_id_new.json`).
- Menghasilkan `propertyShape()` untuk properti (persis `GET_properties_id_new.json`).

---

## 7. State Machine Booking & Payment

### `bookings.status` (9 Nilai)
`waiting_payment` → `waiting_confirmation` → `confirmed` → `paid` → `waiting_checkin` → `staying` → `completed` (atau `cancelled` / `expired`)

### `orders.status` (6 Nilai)
`pending` → `processing` → `confirmed` → `completed` (atau `cancelled` / `refunded`)

### `payments.status` (5 Nilai)
`pending` → `success` / `settlement` (atau `failed` / `expired` / `refunded`)

---

## 8. Pembayaran Midtrans Snap & Webhook

- **Midtrans S2S Webhook** adalah satu-satunya sumber perubahan status pembayaran ke `success`/`settlement`.
- Callback browser (`Payment/{Finish,Unfinish,Error}Controller`) **TIDAK BOLEH** mengubah status; hanya mengarahkan browser ke deep link `livirooms://payment-result`.
- Signature SHA512 dan verifikasi nominal `gross_amount` wajib diverifikasi sebelum status booking diperbarui.

---

## 9. Livewire Multi-Step Wizards

1. **`App\Livewire\Properties\WizardForm`:**
   - 4 tab: Info Dasar, Kapasitas & Kamar, Harga & Biaya, Galeri & Konten.
   - Mengelola relasi `accommodations` (`booking_mode='unit'`), `unit_types`, `unit_type_prices`, `facility_items` (`context='facility'`), dan `galleries`.
2. **`App\Livewire\Hotels\WizardForm`:**
   - 4 tab: Info Hotel & Bintang, Tipe Kamar (Repeater), Fasilitas & Aturan, Transit & FAQ.
   - Mengelola relasi `accommodations` (`booking_mode='room'`), multiple `unit_types`, `accommodation_policies` (`section='general'`), `nearby_points`, `accommodation_questions`, dan `galleries`.
