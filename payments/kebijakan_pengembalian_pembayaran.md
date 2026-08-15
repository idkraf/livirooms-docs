# Kebijakan & Mekanisme Pengembalian Pembayaran (Refund Policy)
## Kasus: Pembayaran Berhasil Namun Kamar / Unit Tidak Tersedia

Dokumen ini mengatur kebijakan, alur kerja teknis (system workflow), Standar Operasional Prosedur (SOP), dan mekanisme pengembalian dana (*refund*) dalam ekosistem aplikasi **Sewain**, khusus untuk skenario di mana **pengguna telah menyelesaikan pembayaran (*status: paid/settlement*) tetapi kamar atau unit apartemen/hotel tidak dapat ditempati**.

---

## 1. Latar Belakang & Ruang Lingkup

Dalam operasional penyewaan properti (apartemen, unit harian/bulanan, dan kamar hotel OTA), dapat terjadi situasi di mana pembayaran pengguna telah berhasil terverifikasi oleh *payment gateway* (Midtrans), namun hak tinggal tidak dapat dipenuhi.

### Skenario Utama Kejadian:
1. **Penolakan Host Pasca-Bayar (*Post-Payment Host Rejection*)**: Host menolak atau membatalkan reservasi karena alasan ketersediaan internal atau masalah operasional.
2. **Kondisi Overbooking / Race Condition**: Dua pengguna melakukan pemesanan dan pembayaran secara bersamaan untuk sisa 1 (satu) kamar/unit yang tersisa sebelum inventaris sempat terkunci penuh.
3. **Keterlambatan Sinkronisasi Inventaris (*Sync Delay*)**: Adanya jeda sinkronisasi stok antara Channel Manager / PMS Hotel dengan database aplikasi Sewain.
4. **Unit Tidak Layak Huni Mendadak (*Uninhabitable Property*)**: Terjadi kerusakan mendadak pada unit (kebocoran air, masalah listrik, atau kerusakan fasilitas utama) saat hari check-in.
5. **Keterlambatan Notifikasi Webhook (*Late Webhook Arrival*)**: Pembayaran selesai saat reservasi telah kedaluwarsa oleh sistem dan kamarnya dialokasikan kepada pengguna lain.

---

## 2. Prinsip Dasar Kebijakan Refund

1. **Jaminan 100% Pengembalian Dana (*100% Full Refund Guarantee*)**:
   - Pengguna berhak menerima pengembalian dana utuh **100% dari total tagihan** (`total_price`), yang mencakup:
     - Biaya sewa kamar/unit (*room subtotal*)
     - Biaya layanan (*service fee*)
     - Biaya kebersihan (*cleaning fee*)
     - Biaya asuransi menginap (*insurance fee* / Stay Protection) jika polis belum terbit atau dapat dibatalkan.
   - **TIDAK ADA** potongan biaya administrasi atau potongan gateway apapun kepada pengguna.

2. **Opsi Relokasi Setara / Upgrade (*Relocation First Option*)**:
   - Sebelum refund diproses, sistem/Tim Customer Support wajib menawarkan opsi relokasi ke kamar/unit lain yang setara atau kelas lebih tinggi di lokasi terdekat tanpa biaya tambahan.
   - Jika pengguna menolak relokasi, proses refund 100% langsung dijalankan.

3. **Kompensasi & Permohonan Maaf (*Compensation Voucher*)**:
   - Sebagai bentuk komitmen layanan, pengguna yang terdampak kasus kamar tidak tersedia setelah pembayaran akan secara otomatis mendapatkan **Voucher Kompensasi** (misal: Diskon 10% atau Kredit Rp50.000) untuk pemesanan berikutnya.

4. **Transparansi SLA Pemrosesan**:
   - Setiap tahapan pengembalian dana dilacak secara *real-time* melalui aplikasi Flutter dan email notifikasi.

---

## 3. Alur Kerangka Kerja Teknis (Technical Architecture)

```
 [ Pengguna / Guest ]
          |
   (Bayar Berhasil: Status = Paid)
          |
          v
 [ Deteksi Kamar Tidak Tersedia / Host Reject ]
          |
          v
 [ System Sets Status: cancelled_unavailability / refund_pending ]
          |
          +-----------------------------------+-----------------------------------+
          |                                                                       |
 (Metode Pembayaran Direct API)                                         (Metode Pembayaran Manual / Offline)
 Credit Card, QRIS, GoPay, E-Wallet                                     Virtual Account (VA), Alfamart / Indomaret
          |                                                                       |
          v                                                                       v
 [ Automated Midtrans Refund API ]                                      [ Input Form Rekening Pengguna di Flutter ]
 Endpoint: /v2/{order_id}/refund                                                  |
          |                                                                       v
          |                                                             [ Verification & Payout Finance ]
          |                                                             Via Transfer Bank / Midtrans Iris
          |                                                                       |
          +-----------------------------------+-----------------------------------+
                                              |
                                              v
                                   [ Status: Refunded ]
                                              |
                                  +-----------+-----------+
                                  |                       |
                         (Notifikasi Client)     (Audit Log & Host Penalty)
```

---

## 4. Jalur & Waktu Pemrosesan Refund (Refund Channels & SLA)

| Metode Pembayaran Asal | Jalur Pengembalian Dana (*Refund Channel*) | Estimasi SLA Pengembalian | Keterangan Teknis |
|---|---|---|---|
| **Credit Card / Debit Online** | Midtrans Direct Refund API (`/v2/{order_id}/refund`) | 5 – 14 Hari Kerja | Otomatis dikreditkan kembali ke limit/saldo kartu kredit pengguna. |
| **GoPay / QRIS / ShopeePay / Dana** | Midtrans Direct Refund API (`/v2/{order_id}/refund`) | 1 – 3 Hari Kerja | Otomatis saldo kembali ke akun e-wallet asal pengguna. |
| **Virtual Account (BCA, BNI, Mandiri, BRI, Permata)** | Bank Transfer Manual / Midtrans Iris Payout API | 1 – 2 Hari Kerja | Pengguna mengisi nomor rekening tujuan di aplikasi Flutter. |
| **Convenience Store (Alfamart / Indomaret)** | Bank Transfer Manual / E-Wallet Payout | 1 – 2 Hari Kerja | Pengguna memilih payout via Transfer Bank atau saldo E-Wallet. |

---

## 5. Pemrosesan Asuransi & Inventaris (Protection & Inventory Rollback)

### 5.1 Penanganan Asuransi Menginap (*Stay Protection Insurance*)
- **Jika Polis Belum Diterbitkan (*Status: pending / processing*)**:
  - Panggilan API ke Insurtech Provider dibatalkan (`status` asuransi -> `cancelled`).
  - Biaya asuransi (`insurance_fee`) dikembalikan penuh ke pengguna bersama total refund.
- **Jika Polis Sudah Diterbitkan (*Status: issued*)**:
  - Sistem mengirimkan *void request* ke provider asuransi.
  - Biaya asuransi ditanggung/direfund oleh platform Sewain kepada pengguna.

### 5.2 Restorasi Stok Inventaris (*Room Inventory Safeguard*)
- Sistem secara otomatis mengembalikan kuota ketersediaan:
  - Untuk Properti Unit: `Availability::where('property_id', ...)->update(['is_available' => true])`
  - Untuk Hotel OTA: `RoomInventory::decrement('booked_count', $quantity)` dengan perlindungan `GREATEST(0, booked_count - quantity)`.

---

## 6. Standar Operasional Prosedur (SOP) Tim Support & Finance

1. **Tahap 1: Inisiasi & Konfirmasi (Maksimal 15 Menit)**
   - Peringatan (*alert*) otomatis masuk ke Dashboard Admin/Support saat ada pembatalan karena ketersediaan.
   - Support menghubungi Guest via WhatsApp/Telepon untuk menawarkan relokasi atau mengonfirmasi opsi refund.

2. **Tahap 2: Pengumpulan Data Rekening (Jika Metode Non-Direct)**
   - Jika pembayaran via VA/Retail, aplikasi Flutter menampilkan form input rekening refund di layar Detail Booking.
   - Tim Finance memverifikasi kesesuaian data rekening.

3. **Tahap 3: Disbursmen & Reconsiliation**
   - Finance mengeksekusi transfer atau menyetujui request Payout di dashboard Midtrans Iris.
   - Sistem memperbarui status `payments.status` menjadi `refunded` dan mengirimkan email serta push notification bukti transfer.

---

## 7. Kebijakan Penalti & Rating Host (Host Accountability)

Untuk menjaga kualitas ekosistem dan mencegah kerugian pengguna:
- **Penalti Pembatalan Sepihak**: Host yang menolak/membatalkan pesanan yang sudah dibayar tanpa alasan force majeure akan dikenakan potongan biaya penalti dari komisi pencairan berikutnya.
- **Pengurangan Score Kinerja Host**: Penolakan pasca-bayar akan menurunkan *Host Acceptance Rate* dan menurunkan posisi urutan properti di hasil pencarian (*ranking penalty*).
- **Pembekuan Akun Properti**: Jika Host menolak booking paid lebih dari 3 kali dalam sebulan, unit properti akan di-suspend otomatis selama 7 hari.

---

## 8. Integrasi Kode & Struktur Database

### Backend Laravel:
- **Model**: `App\Models\Booking`, `App\Models\Order`, `App\Models\Payment`, `App\Models\BookingInsurance`
- **Controller**: `App\Http\Controllers\Api\BookingController.php` (`reject`), `PaymentController.php` (`reconcile`, `refund`)
- **Event & Job**: `App\Jobs\ProcessMidtransRefundJob.php`, `App\Events\BookingRefunded.php`

### Mobile Flutter:
- **Screen**: `screens/booking/booking_detail_screen.dart` (menampilkan banner refund & form rekening)
- **Service**: `services/booking_service.dart`, `services/payment_service.dart`

---

*Dokumen ini merupakan standar resmi operasional aplikasi Sewain dan wajib dijadikan acuan dalam pengembangan fitur backend, mobile client, serta SOP tim operasional.*
