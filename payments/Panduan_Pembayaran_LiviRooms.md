# Panduan Sistem Pembayaran LiviRooms

> Dokumentasi lengkap alur booking, pembayaran, dan manajemen order untuk aplikasi LiviRooms - Rental Apartemen.

## Daftar Isi

1. [Pendahuluan](#1-pendahuluan)
2. [Peran Pengguna](#2-peran-pengguna)
3. [Alur Status Booking](#3-alur-status-booking)
4. [Langkah demi Langkah (User)](#4-langkah-demi-langkah-user)
5. [Langkah demi Langkah (Host/Mitra)](#5-langkah-demi-langkah-hostmitra)
6. [API Endpoints](#6-api-endpoints)
7. [Aturan Penting](#7-aturan-penting)
8. [Troubleshooting](#8-troubleshooting)
9. [Referensi File](#9-referensi-file)

---

## 1. Pendahuluan

LiviRooms adalah aplikasi untuk menyewa apartemen secara online. Dokumen ini menjelaskan bagaimana sistem pembayaran bekerja, mulai dari saat user membuat booking, host mengonfirmasi, user melakukan pembayaran, hingga tamu check-in.

Sistem ini menggunakan **Midtrans** sebagai payment gateway. Pembayaran dilakukan melalui browser eksternal (Midtrans Snap), dan status pembayaran dikembalikan ke aplikasi melalui webhook.

### Komponen Utama

- **Flutter (Frontend)** - Aplikasi mobile untuk user dan host
- **Laravel (Backend)** - API server yang menangani booking dan pembayaran
- **Midtrans (Payment Gateway)** - Memproses pembayaran online

---

## 2. Peran Pengguna

Ada 3 peran utama dalam sistem LiviRooms:

### Guest (Pengguna)
- Membuat booking apartemen
- Melihat status booking dan pembayaran
- Melakukan pembayaran
- Membatalkan booking (jika masih dalam masa yang diperbolehkan)

### Host / Mitra (Pemilik Apartemen)
- Menerima atau menolak permintaan booking
- Mengonfirmasi kehadiran tamu (check-in)
- Melihat daftar order dan status pembayaran
- Mengelola properti dan ketersediaan

### Admin
- Mengelola metode pembayaran
- Melihat dan mengekspor data pembayaran
- Mengatur konfigurasi Midtrans

---

## 3. Alur Status Booking

Setiap booking memiliki status yang berubah seiring proses. Berikut adalah alur status dari awal hingga akhir:

### Status Booking

| Status | Artinya |
|--------|---------|
| `waiting_confirmation` | Booking dibuat, menunggu host mengonfirmasi |
| `confirmed` | Host telah mengonfirmasi, user dapat melakukan pembayaran |
| `paid` | Pembayaran berhasil, menunggu tanggal check-in |
| `waiting_checkin` | Tamu telah tiba, menunggu host mengonfirmasi check-in |
| `staying` | Tamu sedang menginap |
| `completed` | Booking selesai |
| `cancelled` | Dibatalkan (user/admin/host) |
| `expired` | Kedaluwarsa (payment timeout atau check-in terlewat) |

### Alur Visual

```
waiting_confirmation  →  confirmed  →  paid  →  waiting_checkin  →  staying  →  completed
      ↓                   ↓            ↓              ↓               ↓
   cancelled          cancelled    cancelled        cancelled        cancelled
   (host tolak)     (user/host)  (payment gagal)  (check-in gagal)  (selesai)
      ↓
   expired  (payment timeout / check-in terlewat)
```

> **Catatan:** Setiap booking selalu dimulai dari `waiting_confirmation`. Host harus mengonfirmasi terlebih dahulu sebelum user dapat melakukan pembayaran.

---

## 4. Langkah demi Langkah (User)

### 4.1 Membuat Booking

1. Buka aplikasi LiviRooms dan pilih apartemen yang ingin disewa.
2. Pilih tanggal check-in dan check-out.
3. Isi data tamu (nama, telepon, dll).
4. Klik **'Pesan Sekarang'**.
5. Sistem membuat booking dengan status `waiting_confirmation`.
6. User melihat pesan: *"Menunggu konfirmasi dari pemilik properti..."*

> **Catatan:** Booking belum dapat dibayar sebelum host mengonfirmasi.

### 4.2 Menunggu Konfirmasi Host

Setelah booking dibuat, user dapat:
- Melihat status booking di halaman 'Daftar Booking'
- Menunggu notifikasi bahwa host telah mengonfirmasi
- Membatalkan booking jika masih dalam status `waiting_confirmation`

### 4.3 Melakukan Pembayaran

Setelah host mengonfirmasi, status berubah menjadi `confirmed` dan tombol **'Lanjutkan Bayar'** muncul.

1. Klik tombol **'Lanjutkan Bayar'**.
2. Pilih metode pembayaran (QRIS, Virtual Account, E-Wallet, Kartu Kredit).
3. Sistem membuat transaksi Midtrans dan membuka halaman pembayaran.
4. User selesaikan pembayaran di Midtrans.
5. Setelah pembayaran berhasil, webhook Midtrans mengupdate status menjadi `paid`.

### 4.4 Setelah Pembayaran

Status booking menjadi `paid`. User dapat:
- Melihat detail pembayaran (metode, waktu, nominal)
- Menunggu tanggal check-in
- Membatalkan booking (kebijakan cancellation berlaku)

> **Catatan:** Pembayaran hanya dianggap berhasil setelah webhook Midtrans mengonfirmasi. Jangan percayai halaman 'finish' dari Midtrans.

### 4.5 Check-in dan Menginap

Pada hari check-in:
- Host akan menandai tamu tiba (status: `waiting_checkin`)
- Host mengonfirmasi check-in (status: `staying`)

Selama menginap, status tetap `staying`. Setelah check-out, status berubah menjadi `completed`.

### 4.6 Membatalkan Booking

User dapat membatalkan booking jika status masih:
- `waiting_confirmation` (belum dikonfirmasi host)
- `confirmed` (sudah dikonfirmasi, belum bayar)

Setelah dibatalkan, tanggal properti kembali tersedia untuk booking lain.

---

## 5. Langkah demi Langkah (Host / Mitra)

### 5.1 Menerima Booking Baru

1. Login sebagai host di aplikasi LiviRooms.
2. Buka menu **'Manajemen Order'**.
3. Lihat tab **'Baru'** untuk booking yang menunggu konfirmasi.
4. Klik detail booking untuk melihat informasi lengkap.
5. Klik **'Terima'** untuk menerima booking.
6. Status booking berubah menjadi `confirmed`, user dapat membayar.

### 5.2 Menolak Booking

1. Di halaman detail booking, klik **'Tolak'**.
2. Booking dibatalkan dan tanggal properti kembali tersedia.
3. User menerima notifikasi bahwa booking ditolak.

### 5.3 Menandai Tamu Tiba

1. Pada hari check-in, buka **'Manajemen Order'** → tab **'Dikonfirmasi'**.
2. Lihat booking dengan status `paid`.
3. Klik **'Tamu Tiba'** untuk menandai kedatangan.
4. Status berubah menjadi `waiting_checkin`.

### 5.4 Mengonfirmasi Check-in

1. Setelah menandai tamu tiba, klik **'Konfirmasi Check-in'**.
2. Status berubah menjadi `staying`.
3. Tamu resmi menginap dan dapat mengakses properti.

### 5.5 Check-out dan Selesai

1. Setelah tamu check-out, sistem otomatis mengubah status menjadi `completed`.
2. Dana pembayaran akan ditransfer ke dompet host sesuai jadwal.
3. Host dapat melihat riwayat completed booking di tab **'Selesai'**.

---

## 6. API Endpoints

### 6.1 Booking

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| GET | `/api/v1/bookings` | Mendapatkan daftar booking milik user |
| POST | `/api/v1/bookings` | Membuat booking baru |
| GET | `/api/v1/bookings/{id}` | Detail booking |
| POST | `/api/v1/bookings/{id}/cancel` | Membatalkan booking |
| POST | `/api/v1/bookings/{id}/confirm` | Host mengonfirmasi booking |
| POST | `/api/v1/bookings/{id}/reject` | Host menolak booking |
| POST | `/api/v1/bookings/{id}/checkin` | Host menandai tamu tiba |
| POST | `/api/v1/bookings/{id}/confirm-checkin` | Host mengonfirmasi check-in |

### 6.2 Payment

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| GET | `/api/v1/payments/methods` | Daftar metode pembayaran aktif |
| POST | `/api/v1/orders/{id}/pay` | Buat transaksi pembayaran |
| POST | `/api/v1/orders/{id}/pay/retry` | Ulangi pembayaran (retry/continue) |
| GET | `/api/v1/payments/{id}` | Detail pembayaran |
| GET | `/api/v1/payments/{id}/reconcile` | Sinkron status dengan Midtrans |
| POST | `/api/v1/payments/webhook` | Webhook dari Midtrans (publik) |

### 6.3 Host Orders

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| GET | `/api/v1/host/orders` | Daftar order untuk host (berdasarkan properti) |
| GET | `/api/v1/host/orders/{id}` | Detail order untuk host |

---

## 7. Aturan Penting

### 7.1 Booking dan Availability
- Saat user membuat booking, sistem mengecek ketersediaan tanggal.
- Jika ada booking aktif lain di tanggal yang sama, booking ditolak.
- Booking aktif meliputi status: `waiting_confirmation`, `confirmed`, `paid`, `waiting_checkin`, `staying`.
- Setiap booking memiliki availability lock selama proses pembayaran.

### 7.2 Host Confirmation
- Booking baru **tidak dapat dibayar** sebelum host mengonfirmasi.
- Host memiliki waktu untuk menerima atau menolak booking.
- Jika host menolak, booking dibatalkan dan tanggal tersedia kembali.

### 7.3 Pembayaran
- Pembayaran hanya diproses oleh webhook Midtrans yang terverifikasi.
- Halaman 'finish' dari Midtrans hanya untuk navigasi, **tidak mengubah status**.
- Jika pembayaran gagal/expired, booking dibatalkan dan tanggal tersedia kembali.
- User dapat retry pembayaran jika masih dalam masa yang diperbolehkan.

### 7.4 Expired dan Cancelled
- Booking otomatis dibatalkan jika check-in terlewat dan masih dalam proses.
- Command `payments:cancel-expired` berjalan secara berkala untuk membersihkan booking lama.
- Booking yang dibatalkan mengembalikan ketersediaan tanggal.

### 7.5 Check-in
- Host harus menandai tamu tiba sebelum dapat mengonfirmasi check-in.
- Check-in hanya dapat dilakukan jika status booking adalah `paid`.
- Setelah check-in dikonfirmasi, status menjadi `staying`.

---

## 8. Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Booking tidak muncul di daftar host | Pastikan booking memiliki status `waiting_confirmation` dan properti dimiliki host. |
| Tombol 'Lanjutkan Bayar' tidak muncul | Pastikan host sudah mengonfirmasi booking (status: `confirmed`). |
| Pembayaran berhasil tapi status tidak berubah | Cek apakah webhook Midtrans bekerja. Jalankan `php artisan payments:cancel-expired` untuk reconcile. |
| Booking expired tapi masih menunggu pembayaran | Jalankan `php artisan payments:cancel-expired` untuk membersihkan booking expired. |
| Double booking terjadi | Sistem overlap check seharusnya mencegah ini. Cek log booking dengan tanggal yang sama. |
| Tamu check-in tapi status tidak berubah | Host harus menekan 'Tamu Tiba' terlebih dahulu, lalu 'Konfirmasi Check-in'. |
| Pembayaran ditolak Midtrans | Cek saldo/limit kartu, atau coba metode pembayaran lain. |

---

## 9. Referensi File

### Backend - Booking
- `app/Http/Controllers/Api/BookingController.php`
- `app/Models/Booking.php`
- `database/migrations/2026_08_12_000001_update_booking_status_enum.php`
- `app/Console/Commands/CancelExpiredPayments.php`

### Backend - Payment
- `app/Http/Controllers/Api/PaymentController.php`
- `app/Http/Controllers/Api/OrderController.php`
- `app/Models/Order.php`
- `app/Models/Payment.php`

### Backend - Routes
- `routes/api_mobile.php`
- `routes/web.php` (payment callbacks)

### Flutter - Screens
- `lib/screens/booking/booking_detail_screen.dart`
- `lib/screens/booking/booking_list_screen.dart`
- `lib/screens/mitra/order_management_screen.dart`
- `lib/screens/mitra/order_detail_screen.dart`

### Flutter - Models & Services
- `lib/models/booking.dart`
- `lib/models/order.dart`
- `lib/models/payment.dart`
- `lib/services/booking_service.dart`
- `lib/services/host_service.dart`

### Documentation
- `docs/payments/flow.md`
- `docs/payments/integration.md`
- `docs/payments/setup.md`
- `docs/payments/remediation.md`
- `docs/payments/trial_fix_payment.md`
- `docs/payments/MOBILE_API_INSTALL.md`
