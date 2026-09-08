# Manajemen Order Mitra (Host Order Management)

Dokumentasi arsitektur, state mapping, dan alur kerja untuk manajemen order mitra di Flutter dan Laravel.

---

## 1. Ikhtisar Layar & Routing

| Layar | File | Route | Argumen | Deskripsi |
|---|---|---|---|---|
| **OrderManagementScreen** | `lib/screens/mitra/order_management_screen.dart` | `Routes.mitraOrders` (`/mitra/orders`) | None | Tab bar interaktif 3 kolom (Baru, Dikonfirmasi, Selesai) dengan pagination tak terbatas dan aksi konfirmasi/penolakan instan. |
| **OrderDetailScreen** | `lib/screens/mitra/order_detail_screen.dart` | `Routes.mitraOrderDetail` (`/mitra/orders/detail`) | `Order` (atau map/ID fallback) | Detail order vertikal lengkap: header kode order, status timeline (disembunyikan bila status `cancelled`), informasi properti, data tamu, rincian waktu, rincian pembayaran, serta tombol konfirmasi geser modern (`SlidingConfirmationButton` / swipe-to-confirm) yang ditempatkan pada sticky `bottomNavigationBar` di bagian bawah layar. |

---

## 2. Pemetaan Tab & Status Booking

Order pada layar manajemen diklasifikasikan ke dalam 3 tab berdasarkan `effectiveBookingStatus` (`order.bookingStatus ?? order.status`):

| Tab | Status yang Dicakup | Aksi yang Tersedia |
|---|---|---|
| **Baru** | `waiting_confirmation`, `waiting_payment` | **Terima** (`confirmOrder`), **Tolak** (`rejectOrder`) jika belum expired. |
| **Dikonfirmasi** | `confirmed`, `staying` | Tap kartu membuka detail untuk **Check-in** (`confirmed` -> `staying`) atau **Check-out** (`staying` -> `completed`). |
| **Selesai** | `completed`, `cancelled`, `expired` | Review riwayat menginap & histori pembayaran selesai. |

---

## 3. Alur Aksi & Kontrak Endpoint API

```mermaid
graph TD
    A[Order Masuk / waiting_confirmation] -->|Host Terima| B[POST /api/v1/bookings/{id}/confirm]
    A -->|Host Tolak| C[POST /api/v1/bookings/{id}/reject]
    B -->|Status: confirmed| D[Menunggu Check-in]
    D -->|Host Check-in| E[POST /api/v1/bookings/{id}/checkin]
    E -->|Status: staying| F[Tamu Sedang Menginap]
    F -->|Host Check-out| G[POST /api/v1/bookings/{id}/checkout]
    G -->|Status: completed| H[Booking & Order Selesai]
```

### Rincian Endpoint:
1. `GET host/orders` (`OrderController::forHost`): Mengambil daftar order yang terkait dengan akomodasi milik mitra (mendukung filter `page`, `status`, `booking_status`).
2. `GET host/orders/{order}` (`OrderController::showForHost`): Mengambil detail order mitra beserta properti, kamar, asuransi, dan pembayaran.
3. `POST bookings/{booking}/confirm` (`BookingController::confirm`): Host menerima pesanan, status booking berubah menjadi `confirmed`.
4. `POST bookings/{booking}/reject` (`BookingController::reject`): Host menolak pesanan, status booking berubah menjadi `rejected` dan order `cancelled`, serta inventaris dikembalikan.
5. `POST bookings/{booking}/checkin` (`BookingController::checkin`): Host mencatat tamu check-in, status booking berubah menjadi `staying`.
6. `POST bookings/{booking}/checkout` (`BookingController::checkout`): Host mencatat tamu check-out, status booking berubah menjadi `completed` dan status order menjadi `completed`.
7. `POST bookings/{booking}/confirm-checkin` (`BookingController::confirmCheckin`): Host mengonfirmasi check-in tamu (status booking menjadi `staying`).

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
  - Pengujian tombol aksi geser kontekstual via gesture swipe ("Geser untuk Terima", "Geser untuk Tolak", "Geser jika Tamu Tiba", "Geser Konfirmasi Check-in", "Geser untuk Check-in", "Geser untuk Check-out").
  - Pengujian pencegahan false expired warning pada order yang telah selesai.
  - Pengujian penyembunyian kartu Status Pesanan (timeline) saat status booking bernilai `cancelled`.
- `test/widgets/sliding_confirmation_button_test.dart`:
  - Pengujian rendering label, ikon, dan status loading pada `SlidingConfirmationButton`.
  - Pengujian gesture drag di bawah ambang batas (snaps back tanpa memicu aksi).
  - Pengujian gesture drag melampaui ambang batas (memicu `onConfirmed`).
  - Pengujian status `isLoading: true` yang mematikan drag gesture dan menampilkan indikator loading.
