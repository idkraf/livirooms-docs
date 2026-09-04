# Manajemen Order Mitra (Host Order Management)

Dokumentasi arsitektur, state mapping, dan alur kerja untuk manajemen order mitra di Flutter dan Laravel.

---

## 1. Ikhtisar Layar & Routing

| Layar | File | Route | Argumen | Deskripsi |
|---|---|---|---|---|
| **OrderManagementScreen** | `lib/screens/mitra/order_management_screen.dart` | `Routes.mitraOrders` (`/mitra/orders`) | None | Tab bar interaktif 3 kolom (Baru, Dikonfirmasi, Selesai) dengan pagination tak terbatas dan aksi konfirmasi/penolakan instan. |
| **OrderDetailScreen** | `lib/screens/mitra/order_detail_screen.dart` | `Routes.mitraOrderDetail` (`/mitra/orders/detail`) | `Order` (atau map/ID fallback) | Detail order vertikal lengkap: header kode order, status timeline, informasi properti, data tamu, rincian waktu, rincian pembayaran, dan aksi host kontekstual. |

---

## 2. Pemetaan Tab & Status Booking

Order pada layar manajemen diklasifikasikan ke dalam 3 tab berdasarkan `effectiveBookingStatus` (`order.bookingStatus ?? order.status`):

| Tab | Status yang Dicakup | Aksi yang Tersedia |
|---|---|---|
| **Baru** | `waiting_confirmation`, `waiting_payment`, `pending` | **Terima** (`confirmOrder`), **Tolak** (`rejectOrder`) dengan dialog konfirmasi jika belum expired. |
| **Dikonfirmasi** | `confirmed`, `paid`, `waiting_checkin`, `staying`, `checked_in` | Tap kartu membuka detail untuk menandai **Tamu Tiba** (`paid`) atau **Konfirmasi Check-in** (`waiting_checkin`, `checked_in`). |
| **Selesai** | `completed`, `cancelled`, `expired`, `rejected` | Review riwayat menginap & histori pembayaran selesai. |

---

## 3. Alur Aksi & Kontrak Endpoint API

```mermaid
graph TD
    A[Order Masuk / waiting_confirmation] -->|Host Terima| B[POST /api/v1/bookings/{id}/confirm]
    A -->|Host Tolak| C[POST /api/v1/bookings/{id}/reject]
    B -->|Status: confirmed| D[Menunggu Pembayaran / Check-in]
    D -->|Tamu Tiba| E[POST /api/v1/bookings/{id}/checkin]
    E -->|Status: checked_in| F[POST /api/v1/bookings/{id}/confirm-checkin]
    F -->|Check-in Dikonfirmasi| G[Status: staying / Menginap]
```

### Rincian Endpoint:
1. `GET host/orders` (`OrderController::forHost`): Mengambil daftar order yang terkait dengan akomodasi milik mitra (mendukung filter `page`, `status`, `booking_status`).
2. `GET host/orders/{order}` (`OrderController::showForHost`): Mengambil detail order mitra beserta properti, kamar, asuransi, dan pembayaran.
3. `POST bookings/{booking}/confirm` (`BookingController::confirm`): Host menerima pesanan, status booking berubah menjadi `confirmed`.
4. `POST bookings/{booking}/reject` (`BookingController::reject`): Host menolak pesanan, status booking berubah menjadi `rejected` dan order `cancelled`, serta inventaris dikembalikan.
5. `POST bookings/{booking}/checkin` (`BookingController::checkin`): Host mencatat tamu telah tiba, status berubah menjadi `checked_in`.
6. `POST bookings/{booking}/confirm-checkin` (`BookingController::confirmCheckin`): Host mengonfirmasi check-in tamu (`host_confirmed_checkin = true`).

---

## 4. Model DTO (`Order`)

Model `lib/models/order.dart` diperkaya dengan metadata akomodasi dan tamu yang diekstrak dari payload relasi:
- `propertyName`: Nama akomodasi (`booking.property.name` / `json.property_name`).
- `propertyAddress` & `propertyCity`: Alamat dan kota properti.
- `propertyImage`: URL foto sampul properti.
- `bookingCode`: Kode pemesanan (`booking.booking_code`).
- `guestName` & `guestPhone`: Nama dan kontak pemesan (`booking.contact_phone` / `user.name` / `user.phone`).
- `effectiveBookingStatus`: Helper getter `bookingStatus ?? status`.
- `isConfirmationExpired`: Memastikan indikator kedaluwarsa hanya aktif jika status pemesanan secara eksplisit `expired` dari backend.

---

## 5. Pengujian Otomatis

Modul diuji secara otomatis dengan 100% stabilitas:
- `test/screens/mitra/order_management_screen_test.dart`:
  - Pengujian transisi tab (Baru, Dikonfirmasi, Selesai) dan rendering nama properti.
  - Pengujian alur dialog konfirmasi "Terima" beserta pemanggilan service dan SnackBar.
  - Pengujian alur dialog konfirmasi "Tolak" dan verifikasi pembatalan dialog.
- `test/screens/mitra/order_detail_screen_test.dart`:
  - Pengujian rendering detail lengkap (timeline, data tamu, informasi properti).
  - Pengujian tombol aksi kontekstual ("Terima", "Tolak", "Tamu Tiba", "Konfirmasi Check-in").
  - Pengujian pencegahan false expired warning pada order yang telah selesai.
