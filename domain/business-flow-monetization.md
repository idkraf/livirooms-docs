# Arsitektur Alur Proses Bisnis, Monetisasi & Arus Kas (Cashflow) Livirooms

> **Diverifikasi dan disinkronkan langsung dari kode aktif pada 2026-10-05.**
> Implementasi tampilan interaktif tersedia pada: [`demo.blade.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/front/demo.blade.php) (Tab 1: `tab-business`).

---

## 1. Ringkasan Eksekutif & Model Bisnis

Livirooms beroperasi sebagai **Two-Sided Hospitality Marketplace** yang mempertemukan:
1. **Tamu / Konsumen (Guests / Renters):** Mencari dan memesan akomodasi harian, mingguan, bulanan, atau tahunan untuk kategori Hotel Room (OTA) maupun Apartemen/Villa (Unit).
2. **Mitra Host (Property Owners / Hoteliers):** Mengunggah inventaris akomodasi, mengatur kuota allotment dan matrix harga, melayani tamu saat check-in, dan menarik saldo pendapatan sewa.
3. **Platform Livirooms (Marketplace Operator):** Menyediakan infrastruktur teknologi, sistem reservasi dual availability, pengamanan transaksi melalui rekening Escrow Midtrans Snap, perlindungan asuransi Stay Protection, serta sistem pembagian hasil (revenue split).

```
┌─────────────────┐       Booking & Payment        ┌─────────────────────────┐
│ Tamu / Konsumen │ ─────────────────────────────▶ │   Rekening Escrow       │
│  (Mobile App)   │                                │   Midtrans Livirooms    │
└─────────────────┘                                └────────────┬────────────┘
                                                                │
                         ┌──────────────────────────────────────┴──────────────────────────────────────┐
                         ▼                                                                             ▼
           ┌───────────────────────────┐                                                 ┌───────────────────────────┐
           │   Hak Sewa Mitra Host     │                                                 │  Monetisasi Livirooms     │
           │  (85% – 90% Net Payout)   │                                                 │  (8% – 15% Take-Rate      │
           │  + Cleaning Fee Penuh     │                                                 │   + Margin InsurTech)     │
           └─────────────┬─────────────┘                                                 └───────────────────────────┘
                         │ Status: completed
                         ▼
           ┌───────────────────────────┐
           │   Transfer Rekening Bank  │
           │   (Host Withdrawal)       │
           └───────────────────────────┘
```

---

## 2. Empat Tahap Siklus Proses Bisnis (End-to-End Lifecycle)

### Tahap 1: Onboarding Mitra Host & Kurasi Inventaris
- **Aktor:** Mitra Host & Admin Kurasi.
- **Aksi Teknis:**
  - Pendaftaran akun dan verifikasi identitas (KTP/KYC).
  - Setup properti melalui form 7-langkah: info gedung, fasilitas, foto galeri, kebijakan, dan matrix harga.
  - Penentuan mode: `unit` (sewa unit utuh multi-durasi: daily, weekly, monthly, yearly) vs `room` (sewa kamar hotel per malam).
  - Penetapan tarif dasar (`base_price`), biaya kebersihan (`cleaning_fee`), deposit jaminan (`deposit`), dan kuota allotment harian.
- **Mutasi Database:** `accommodations.status = 'active'`, `unit_types.total_units = N`, baris skema pada `unit_type_prices`.
- **Pergerakan Arus Kas:** Belum ada perpindahan uang. Host mendaftarkan kuota ketersediaan unit.

### Tahap 2: Reservasi Tamu & Pengamanan Dana Escrow Midtrans
- **Aktor:** Tamu Konsumen, Midtrans Snap, Backend Laravel.
- **Aksi Teknis:**
  - Tamu mencari akomodasi dan memilih tanggal check-in/out.
  - Backend mengeksekusi *pessimistic row locking* (`lockForUpdate()`) untuk mencegah overbooking (anti-overlap).
  - Tamu memilih add-on perlindungan **Stay Protection Insurance** (+Rp 25.000).
  - Sistem membuat token Midtrans Snap (`snap_token`) dan membuka antarmuka pembayaran digital (Virtual Account, QRIS, GoPay, Kartu Kredit).
  - Webhook S2S (Server-to-Server) Midtrans memverifikasi signature kriptografis SHA512 dan mengubah status transaksi menjadi `settlement`.
- **Mutasi Database:** `bookings.status = 'confirmed'`, `orders.status = 'confirmed'`, `payments.status = 'settlement'`.
- **Pergerakan Arus Kas:** 100% dana masuk ke **Rekening Escrow Merchant Midtrans Livirooms**. Saldo dicatat pada status `held_balance` (tertahan dalam proteksi platform, belum masuk dompet host).

### Tahap 3: Check-in, Masa Menginap & Proteksi Otomatis
- **Aktor:** Tamu, Mitra Host, Background Worker Scheduler, InsurTech Partner.
- **Aksi Teknis:**
  - Tamu tiba di akomodasi dan memindai E-Voucher QR untuk check-in mandiri.
  - Host mengonfirmasi kedatangan via endpoint `POST bookings/{id}/checkin` (`bookings.status = 'staying'`).
  - Polis Stay Protection aktif memproteksi risiko kerusakan unit atau pembatalan darurat.
  - Background worker scheduler berjalan setiap menit untuk menyapu pesanan yang kedaluwarsa (*auto-cancel sweeper*) dan merestorasi kuota allotment secara otomatis.
- **Mutasi Database:** `bookings.status = 'staying'`, `booking_insurances.status = 'active'`.
- **Pergerakan Arus Kas:** Dana tetap aman di dalam rekening penampungan Escrow Livirooms. Memberikan stabilitas modal kerja (*positive working capital*) bagi operasional platform.

### Tahap 4: Check-out Selesai, Settlement Dompet & Payout Host
- **Aktor:** Mitra Host, Admin Keuangan, Jaringan Perbankan Nasional.
- **Aksi Teknis:**
  - Tamu menyelesaikan masa tinggal dan melakukan check-out (`POST bookings/{id}/checkout` -> `bookings.status = 'completed'`).
  - Saldo transaksi pada controller [`HostWalletController::summary()`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/HostWalletController.php) otomatis berpindah dari `held_balance` menjadi `available_balance`.
  - Host mengajukan permohonan pencairan melalui endpoint `POST host/wallet/withdraw` (`Withdrawal`).
  - Admin keuangan memverifikasi kesesuaian nomor rekening bank dengan KTP host terdaftar (Anti-Money Laundering / Anti-Fraud).
  - Admin mengeksekusi transfer bank, mengunggah bukti struk transfer, dan mengubah status menjadi `transferred`.
- **Mutasi Database:** `bookings.status = 'completed'`, `withdrawals.status = 'transferred'`.
- **Pergerakan Arus Kas:** Dana didistribusikan: Livirooms membukukan pendapatan margin bersih (*Take-Rate* + *InsurTech Margin*), sedangkan sisa pokok sewa bersih + *cleaning fee* ditransfer utuh ke rekening bank mitra.

---

## 3. Lima Pilar Model Monetisasi Livirooms (Revenue Streams)

| # | Pilar Monetisasi | Besaran / Margin | Mekanisme & Sumber Nilai |
|---|---|---|---|
| **1** | **Platform Take-Rate (Komisi Booking)** | 8% – 15% dari nilai sewa | Dipotong otomatis saat pembayaran berhasil diverifikasi oleh webhook Midtrans. Merupakan kontributor utama pendapatan (65%–70% dari total omset platform). |
| **2** | **InsurTech Stay Protection & Add-ons** | 30% – 45% Net Margin Premi | Pembagian keuntungan (*revenue sharing*) premi perlindungan insiden menginap dan kerusakan properti bersama mitra asuransi. |
| **3** | **Sponsored Listing & Priority Placement** | B2B Ad Spend / Paket Langganan | Slot promosi berbayar bagi mitra host untuk menampilkan unit di Carousel Banner Beranda dan urutan teratas filter pencarian. |
| **4** | **Escrow Holding Float & Capital Yield** | Efisiensi Likuiditas Modal Kerja | Dana reservasi tamu dipegang aman selama periode pemesanan sebelum tanggal check-out (terutama sewa jangka panjang bulanan/tahunan). |
| **5** | **B2B Property Management & Subscriptions** | Recurring B2B Contract | Paket manajemen operasional gedung multi-unit, integrasi API sistem properti, dan koordinasi staf cleaning otomatis. |

---

## 4. Formula Simulasi Finansial & Kalkulasi Arus Kas

Berikut adalah formula perhitungan yang diimplementasikan pada kalkulator interaktif di [`demo.blade.php`](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/front/demo.blade.php):

$$\text{Subtotal Sewa} = \text{Tarif Dasar (Base Price)} \times \text{Durasi Menginap}$$

$$\text{Komisi Platform} = \text{Subtotal Sewa} \times \text{Take-Rate \%}$$

$$\text{Hak Bersih Mitra Host} = (\text{Subtotal Sewa} - \text{Komisi Platform}) + \text{Cleaning Fee}$$

$$\text{Pendapatan Bersih Platform} = \text{Komisi Platform} + \text{Margin Asuransi}$$

$$\text{Total Bayar Tamu (GTV)} = \text{Subtotal Sewa} + \text{Cleaning Fee} + \text{Stay Protection} + \text{PPN 11\% atas Jasa Platform}$$

$$\text{Trip Coins Reward} = \text{GTV} \times 0.5\% \quad (\text{Loyalty Retention Loop})$$

---

## 5. Jaminan Integritas Finansial (Zero-Drift Balance Architecture)

Sistem Livirooms menggaransi keamanan finansial melalui 3 prinsip teknis di backend:
1. **Midtrans Webhook Sebagai Single Source of Truth (SSoT):**
   Status pembayaran hanya dapat berubah lewat notifikasi HTTP POST webhook resmi yang ditandatangani oleh Midtrans dengan algoritma SHA512. Redirect URL di peramban klien tidak diizinkan memutasi saldo.
2. **Derived Dynamic Host Balance (Zero-Drift):**
   Saldo host tidak disimpan dalam kolom angka statis yang rawan dimanipulasi atau mengalami desinkronisasi. Saldo dihitung dinamis (*on-the-fly*):
   $$\text{Available Balance} = \sum(\text{Booking Total Price})_{\text{completed}} - \sum(\text{Withdrawal})_{\text{transferred}} - \sum(\text{Withdrawal})_{\text{locked}}$$
3. **Pessimistic Concurrency Locking:**
   Menggunakan kueri `lockForUpdate()` pada row level basis data saat membuat reservasi dan saat mengajukan penarikan dana untuk mencegah terjadinya *double-booking* atau *double-withdrawal*.
