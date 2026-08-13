# 07. Matriks Kompatibilitas Modul Hotel ↔ Properties & Payments

Dokumen ini mendokumentasikan pemetaan kompatibilitas teknis antara modul **Daily Hotel Booking** (`docs/hotel/`) dengan sistem eksisting **Property Management** (`docs/properties/`) dan **Payment Gateway Midtrans** (`docs/payments/`).

---

## 1. Prinsip Desain Backward Compatibility

Seluruh spesifikasi modul Hotel dirancang dengan prinsip **Non-Breaking Extension**:
1. **Model & Migration Eksisting Utuh**: Struktur tabel `properties`, `bookings`, `orders`, `payments`, dan `availabilities` tetap berfungsi normal untuk sewa kos/apartemen bulanan/harian (`booking_mode = 'unit'`).
2. **Dual-Mode System**:
   - `booking_mode = 'unit'` (Kos/Apartemen/Villa): Menggunakan `availabilities` & `property_prices`.
   - `booking_mode = 'room'` (Hotel/OTA Mode): Menggunakan `hotels`, `room_types`, `rooms`, dan `room_inventories`.

---

## 2. Integrasi & Kompatibilitas Modul Hotel ↔ Properties (`docs/properties/system.md`)

### A. Skema Database & Model Eloquent

```
+-----------------------------------+
|            properties             |
+-----------------------------------+
| id                                |
| property_type ('hotel', etc)      |
| booking_mode ('unit' | 'room')    | <--- Tambahan Non-Breaking
+-----------------------------------+
          |                 |
   1:1    |                 | 1:N (Mode Unit)
          v                 v
+------------------+  +------------------+
|      hotels      |  |  availabilities  |
+------------------+  +------------------+
          |
     1:N  | (Mode Room)
          v
+------------------+
|    room_types    |
+------------------+
     |         |
  1:N|      1:N|
     v         v
+---------+ +------------------+
|  rooms  | | room_inventories |
+---------+ +------------------+
```

### B. Pemetaan Fitur & Resource JSON

| Fitur / Parameter | Mode Unit (Kos/Apartemen) | Mode Room (Hotel OTA) | Garansi Kompatibilitas |
|---|---|---|---|
| **Property Type** | `apartment`, `house`, `villa`, `exclusive_kost` | `hotel`, `hotel_residence` | Enum `properties.property_type` ditambahkan opsi `'hotel'` via PostgreSQL/SQLite migration. |
| **Harga Terendah (`price_from`)** | `property_prices.amount` (min) | `room_types.base_price` (min) | `PropertyResource` otomatis memilih sumber harga berdasarkan `booking_mode`. |
| **Ketersediaan Tanggal** | Tabel `availabilities` (`is_available = true`) | Tabel `room_inventories` (`allotment - booked_count >= rooms_count`) | Endpoint search `GET /api/v1/properties` menangani query ketersediaan secara kondisional berdasarkan `booking_mode`. |
| **Fasilitas** | JSON `properties.facilities` | JSON `properties.facilities` + `masterFacilities` | Dual fallback pada filter backend: memeriksa `masterFacilities` relasional ATAU JSON `facilities`. |
| **Detail Properti API** | Single unit detail | Metadata hotel + daftar `room_types` aktif | Payload API mengembalikan relasi `hotel` dan `room_types` hanya jika `booking_mode = 'room'`. |

---

## 3. Integrasi & Kompatibilitas Modul Hotel ↔ Payments (`docs/payments/flow.md`)

Alur transaksi pemesanan hotel harian menggunakan infrastruktur **Order & Payment Midtrans Snap** eksisting secara 100% konsisten.

### A. Alur End-to-End Transaksi Hotel + Asuransi

```
Flutter (FE)                      Laravel (BE)                     Midtrans Gateway
    |                                  |                                  |
    |--- POST /api/v1/bookings ------->|                                  |
    |    (room_type_id, check_in/out,   | 1. Lock room_inventories         |
    |     include_insurance: true,    | 2. Calc room subtotal            |
    |     insurance_plan_id, holder)   | 3. Calc insurance premium        |
    |                                  | 4. Create Booking + Order        |
    |<-- {booking, order} -------------| 5. Create BookingInsurance       |
    |                                  |                                  |
    |--- POST /api/v1/orders/{id}/pay->|                                  |
    |    (method: "qris")              |--- Snap::getSnapToken() -------->|
    |                                  |<-- {snap_token, redirect_url} ----|
    |<-- {payment, redirect_url} ------|                                  |
    |                                  |                                  |
    |=== Open Midtrans Snap Browser ===|=================================>|
    |                                  |                                  |
    |                                  |<-- Webhook (settlement) ---------|
    |                                  | 1. Payment status = 'paid'       |
    |                                  | 2. Order status = 'processing'   |
    |                                  | 3. Booking status = 'paid'       |
    |                                  | 4. Trigger Event BookingPaid     |
    |                                  |    └─> IssueInsurancePolicyJob   |
```

### B. Pemetaan Struktur Order & Total Harga (Kalkulasi Asuransi)

Ketika pengguna memilih opsi **Asuransi Menginap (*Stay Protection*)** pada layar booking hotel:

$$\text{Gross Amount} = \text{Subtotal Kamar} + \text{Biaya Premi Asuransi}$$

- **Subtotal Kamar**: $\sum (\text{Harga Inventory} \times \text{Jumlah Kamar})$ per malam.
- **Premi Asuransi**: Dikalkulasi via `InsurancePlan::calculatePremium($nights, $guests, $roomSubtotal)`.
- **Tabel `orders`**:
  - `orders.subtotal`: Subtotal Kamar
  - `orders.total`: Subtotal Kamar + Premi Asuransi
  - `orders.gross_amount`: Meneruskan total bersih ke Midtrans Snap.

### C. Penanganan Webhook Midtrans & Async Queue Job

1. **Webhook Settlement (`PaymentController::webhook`)**:
   - Mengubah `payments.status` $\rightarrow$ `paid`
   - Mengubah `orders.status` $\rightarrow$ `processing`
   - Mengubah `bookings.status` $\rightarrow$ `paid`
   - Memicu Event `App\Events\BookingPaid($booking)`
2. **Listener & Queue Job Asuransi**:
   - `ProcessBookingInsuranceListener` menangkap event `BookingPaid`.
   - Mengecek `booking.has_insurance == true`.
   - Mengubah `booking_insurances.status` dari `pending` $\rightarrow$ `processing`.
   - Mengirim `IssueInsurancePolicyJob` ke **Laravel Queue** (proses asynchronous, tidak mengganggu eksekusi callback Midtrans).
   - `IssueInsurancePolicyJob` menghubungi API Insurtech Partner (Zurich/Chubb/ACA/PasarPolis), menyimpan nomor polis resmi dan link PDF E-Certificate.

### D. Otomasi Expiration & Release Stok Kamar

| Kejadian | Mode Unit Kos/Apartemen | Mode Room Hotel OTA |
|---|---|---|
| **Pemicu Cancellation / Timeout** | `CancelExpiredPayments` Command | `CancelExpiredBookingsJob` (Setiap 5 Menit) |
| **Ambang Batas Expired** | 24 Jam | 30 Menit (Standard OTA) |
| **Aksi Pemulihan Stok** | Reset `availabilities.is_available` $\rightarrow$ `true` | Decrement `room_inventories.booked_count` sesuai `booking_rooms.quantity` |
| **Status Polis Asuransi** | N/A | `booking_insurances.status` $\rightarrow$ `cancelled` |

---

## 4. Tampilan & Opsi Asuransi pada Layar Checkout (`Insurance Display`)

Sesuai kebutuhan audit, integrasi tampilan proteksi menginap dipastikan aktif pada alur pemesanan hotel:

1. **Endpoint Master Plan Asuransi**:
   - Endpoint API: `GET /api/v1/insurance/plans`
   - Mengembalikan daftar paket proteksi aktif (`is_active = true`) beserta rincian santunan (santunan medis, barang hilang, pembatalan).
2. **Kalkulasi Real-time Flutter Widget**:
   - Widget `InsuranceSelectionWidget` di-embed pada layar konfirmasi booking (`HotelBookingCheckoutScreen` / `BookingConfirmScreen`).
   - Menampilkan harga premi transparan berbasis durasi menginap ($N$ malam) dan jumlah tamu ($M$ dewasa).
   - Form input dinamis untuk **Nama Lengkap Tertanggung** (wajib) dan **NIK / No. KTP** (opsional) muncul saat switch toggle diaktifkan.
3. **Payload Request Submit Booking**:
   ```json
   {
     "property_id": 101,
     "booking_type": "room",
     "room_type_id": 5,
     "check_in": "2026-08-28",
     "check_out": "2026-08-30",
     "rooms_count": 1,
     "adults": 2,
     "children": 0,
     "include_insurance": true,
     "insurance_plan_id": 1,
     "holder_name": "Budi Santoso",
     "holder_identity": "3171012345670001"
   }
   ```

---

## 5. Ringkasan Matriks Integrasi 3 Domain

```
+-------------------------------------------------------------------+
|                        PROPERTIES DOMAIN                          |
|  - Property (booking_mode: unit | room)                            |
|  - Hotel & RoomTypes                                              |
|  - RoomInventories (Daily Allotment & Pricing)                    |
+-------------------------------------------------------------------+
                                  │
                                  │ Direct Relationship
                                  v
+-------------------------------------------------------------------+
|                         BOOKING DOMAIN                            |
|  - Booking (booking_type, check_in/out, adults, children)         |
|  - BookingRoom (Room Type & Quantity)                             |
|  - BookingInsurance (Pending state, Holder details)               |
+-------------------------------------------------------------------+
                                  │
                                  │ Triggers Order Creation
                                  v
+-------------------------------------------------------------------+
|                         PAYMENTS DOMAIN                           |
|  - Order (Subtotal + Insurance Fee = Total Gross Amount)          |
|  - Payment (Midtrans Snap Token & Webhook Listener)              |
|  - BookingPaid Event -> IssueInsurancePolicyJob (Queue Async)     |
+-------------------------------------------------------------------+
```

---

## 6. Verifikasi & Garansi Sistem

- ✅ **Tidak Merusak Endpoint Unit Booking Eksisting**: Seluruh API `POST /api/v1/bookings` lama tanpa parameter hotel akan secara otomatis diproses sebagai `booking_type = 'unit'`.
- ✅ **Tidak Merusak Gateway Midtrans**: Parameter `gross_amount` yang dikirim ke Midtrans Snap selalu mencerminkan nilai `orders.total` yang valid.
- ✅ **Garansi Race Condition DB**: Penggunaan `lockForUpdate()` pada `room_inventories` serta PostgreSQL `CHECK constraint` (`booked_count <= allotment`) menjamin 0% risiko *overselling* kamar hotel.
