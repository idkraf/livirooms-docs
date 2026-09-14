# USER MANUAL WEB ADMINISTRATOR
## Manual Sistem & Dokumentasi Arsitektur Panel Administrasi Livirooms
**Document Version:** 2.4.0  
**Stack Architecture:** Laravel 12 (Metronic 8 Admin Kit, Livewire 4, Yajra DataTables, Spatie Permission, Midtrans SDK) & Flutter Mobile Client  
**Database Engine:** PostgreSQL 16 (21 Normalized 3NF Tables)  
**Target Audience:** System Administrators, Property Hosts/Managers, Technical Support, Operations & Finance Teams  

---

## DAFTAR ISI

1. [Pendahuluan & Konsep Arsitektur](#1-pendahuluan--konsep-arsitektur)
   - 1.1 Sekilas Platform Liviroom
   - 1.2 Hirarki Hak Akses (Role-Based Access Control)
   - 1.3 Struktur Antarmuka Sidebar Metronic
2. [Modul 1: Dashboard Utama (Executive Overview)](#2-modul-1-dashboard-utama-executive-overview)
   - 2.1 Purpose & Functionality
   - 2.2 Screen Components & UI Elements
   - 2.3 Step-by-Step Admin Workflow
   - 2.4 Expected Backend & Database Interaction
3. [Modul 2: Manajemen Properti & Gedung](#3-modul-2-manajemen-properti--gedung)
   - 3.1 Purpose & Functionality
   - 3.2 Screen Components & Multi-Step Wizard UI
   - 3.3 Step-by-Step Admin Workflow
   - 3.4 Expected Backend & Database Interaction
4. [Modul 3: Manajemen Kamar & Inventory](#4-modul-3-manajemen-kamar--inventory)
   - 4.1 Purpose & Functionality
   - 4.2 Screen Components & Availability Matrix
   - 4.3 Step-by-Step Admin Workflow
   - 4.4 Expected Backend & Database Interaction
5. [Modul 4: Manajemen Tamu & Pengguna (User Management & RBAC)](#5-modul-4-manajemen-tamu--pengguna-user-management--rbac)
   - 5.1 Purpose & Functionality
   - 5.2 Screen Components & UI Elements
   - 5.3 Step-by-Step Admin Workflow (KYC Validation & Role Assignment)
   - 5.4 Expected Backend & Database Interaction
6. [Modul 5: Manajemen Reservasi & Booking](#6-modul-5-manajemen-reservasi--booking)
   - 6.1 Purpose & Functionality
   - 6.2 Screen Components & Booking Lifecycle State Machine
   - 6.3 Step-by-Step Admin Workflow (Check-in, Check-out, Manual Override)
   - 6.4 Expected Backend & Database Interaction
7. [Modul 6: Keuangan & Pembayaran](#7-modul-6-keuangan--pembayaran)
   - 7.1 Purpose & Functionality
   - 7.2 Screen Components & Payment Settings UI
   - 7.3 Step-by-Step Admin Workflow (Midtrans Setup, Withdrawal Approval, Financial Reports)
   - 7.4 Expected Backend & Database Interaction
8. [Modul 7: Pengaturan Sistem & Integrasi](#8-modul-7-pengaturan-sistem--integrasi)
   - 8.1 Purpose & Functionality
   - 8.2 Screen Components & Configuration UI
   - 8.3 Step-by-Step Admin Workflow (Firebase FCM, SMTP, Remote Config)
   - 8.4 Expected Backend & Database Interaction
9. [Lampiran: Matriks Referensi Teknis Rute, Controller, dan Model](#9-lampiran-matriks-referensi-teknis-rute-controller-dan-model)

---

# 1. PENDAHULUAN & KONSEP ARSITEKTUR

### 1.1 Sekilas Platform Liviroom
**Liviroom** adalah platform manajemen reservasi properti dan sewa apartemen hybrid terpadu. Sistem mengadopsi konsep **Dual Booking Mode**:
1. **Property Rental (`booking_mode = 'unit'`)**: Penyewaan unit utuh (apartemen, villa, kost eksklusif) dengan dukungan durasi harian, mingguan, bulanan, hingga tahunan.
2. **Hotel OTA (`booking_mode = 'room'`)**: Penjualan berbasis tipe kamar kamar hotel (Deluxe, Suite, Standard) dengan kuota allotment inventaris harian.

Backend beroperasi di atas **Laravel 12** menggunakan PostgreSQL 3NF ternormalisasi tanpa redundansi JSON blob. Frontend admin dibangun menggunakan tema **Metronic 8**, diperkuat oleh **Livewire 4** untuk reaktivitas modal/wizard tanpa reload halaman, serta **Yajra DataTables** untuk pemrosesan dataset besar secara server-side.

### 1.2 Hirarki Hak Akses (Role-Based Access Control)
Sistem membagi operasional ke dalam beberapa peran (*roles*) menggunakan `spatie/laravel-permission`:
- **Super Administrator (`admin`)**: Memiliki akses penuh terhadap konfigurasi sistem, audit log, integrasi API gateway, keuangan platform, dan manajemen staf.
- **Host / Property Owner (`host`)**: Memiliki hak mengelola gedung, properti, unit/kamar, melihat kalender reservasi miliknya, dan mengajukan pencairan dana (*withdrawal*).
- **Customer Service / Front Desk (`cs_operator`)**: Memiliki hak operasional reservasi harian, verifikasi check-in/out, monitoring chat, dan penanganan ulasan tamu.
- **Consumer / Guest (`consumer`)**: Pengguna akhir aplikasi seluler Flutter (hanya dapat mengakses REST API).

### 1.3 Struktur Antarmuka Sidebar Metronic (`_menu.blade.php`)
Antarmuka admin dipetakan dalam 7 seksi navigasi utama:
```
├── DASHBOARD
│   └── Dashboard Utama (Overview & Analytics)
├── PROPERTI
│   ├── Daftar Properti (Unit & Hotel Management)
│   ├── Kota (Wilayah Operasional)
│   ├── Gedung (Apartemen / Kompleks Properti)
│   ├── Rekomendasi (Featured Curation)
│   ├── Log Pencarian (User Search Trends)
│   └── Banner (Promotional Banners)
├── TRANSAKSI
│   ├── Booking (Manajemen Reservasi & Tamu)
│   ├── Order (Billing & Invoice Order Satelit)
│   ├── Pembayaran (Daftar, Metode, & Setting Gateway)
│   ├── Withdrawal (Pencairan Dana Host)
│   ├── Voucher (Diskon & Promo Engine)
│   └── Referral (Program Afiliasi Pengguna)
├── KONTEN
│   ├── Ulasan (Review & Rating Tamu)
│   ├── FAQ (Pusat Bantuan & Tanya Jawab)
│   ├── CMS Halaman (Terms, Privacy, About)
│   ├── Percakapan (Customer Service Chat Monitor)
│   └── Wishlist (Monitoring Minat Pengguna)
├── LAPORAN
│   ├── Ringkasan (Executive Summary)
│   ├── Laporan Booking (Filter Periode & Status)
│   ├── Laporan Pendapatan (Gross & Net Revenue)
│   ├── Laporan Withdrawal (Payout Host)
│   └── Performa Properti (Occupancy & Rating)
├── LOGS
│   ├── Log Notifikasi (FCM Push Delivery Records)
│   └── Audit Log (Sistem Aktivitas & Perubahan Data)
├── USER MANAGEMENT
│   ├── Users (Daftar Pengguna Platform)
│   ├── Roles (Manajemen Peran Spatie)
│   ├── Permissions (Hak Akses Spesifik)
│   └── User Validation (KYC Dokumen KTP & Verifikasi Host)
└── SETTING
    ├── Remote Config (Dynamic Flutter App Flags)
    └── Apps Config (Branding, SMTP, Pajak, Firebase JSON)
```

---

# 2. MODUL 1: DASHBOARD UTAMA (EXECUTIVE OVERVIEW)

### 2.1 Purpose & Functionality
Dashboard Utama bertindak sebagai pusat komando operasional dan pemantauan performa bisnis Liviroom secara *real-time*. Menyediakan metrik performa kunci (KPI), grafik tren pendapatan, tingkat okupansi kamar, rasio konversi pemesanan, serta rekap penarikan saldo host yang memerlukan tindakan segera (*actionable insights*).

### 2.2 Screen Components & UI Elements
1. **Stat Cards / KPI Widget (Top Row):**
   - **Total Users:** Jumlah seluruh pengguna terdaftar dengan diferensiasi badge *Host* vs *Consumer*.
   - **Active Hosts:** Jumlah mitra pemilik properti yang memiliki listing berstatus aktif.
   - **Registered Accommodations:** Total unit apartemen dan hotel yang terdaftar di platform.
   - **Platform Revenue:** Akumulasi pendapatan kotor transaksi reservasi yang berstatus `completed`.
   - **Pending Withdrawals Alert:** Indikator badge merah yang menampilkan jumlah pengajuan pencairan dana mitra yang belum diproses.
   - **Active Vouchers:** Jumlah voucher promosi yang sedang berlaku.
2. **Chart Visualizations (Middle Section):**
   - **Revenue & Booking Trend (ApexCharts / Chart.js):** Grafik garis interaktif dengan filter harian, mingguan, bulanan, dan tahunan.
   - **Occupancy Rate Meter:** Diagram radial gauge yang menunjukkan persentase kamar terisi dibandingkan total unit aktif di kota-kota kunci.
3. **Operational Tables (Bottom Section):**
   - **Recent Transactions Widget:** Tabel 5 transaksi booking terakhir lengkap dengan status badge (`waiting_payment`, `paid`, `staying`).
   - **Host Payout Queue:** Shortcut pengajuan penarikan dana tercepat untuk ditinjau bagian *Finance*.

### 2.3 Step-by-Step Admin Workflow
1. **Pemeriksaan Metrik Harian:**
   - Masuk ke dashboard melalui rute `/admin/dashboard-admin`.
   - Pantau badge **Pending Withdrawals** dan **Waiting Confirmation Bookings**.
2. **Analisis Tren Keuangan & Okupansi:**
   - Ubah selector rentang tanggal (Hari Ini, 7 Hari Terakhir, Bulan Ini).
   - Arahkan kursor (*hover*) pada grafik pendapatan untuk memeriksa fluktuasi *gross booking value*.
3. **Navigasi Cepat Tindakan:**
   - Klik kartu **Pending Withdrawals** untuk langsung menuju ke halaman verifikasi transfer penarikan dana host.
   - Klik pada baris reservasi di widget **Recent Transactions** untuk melihat detail invoice atau override status booking.

### 2.4 Expected Backend & Database Interaction
- **Route:** `GET /admin/dashboard-admin` (Named: `admin.dashboard-admin`)
- **Controller:** `App\Http\Controllers\Admin\DashboardAdminController::index`
- **Models Terlibat:**
  - `App\Models\User` (`User::count()`)
  - `App\Models\Accommodation` (`Accommodation::distinct('host_id')->count('host_id')`)
  - `App\Models\Booking` (`Booking::where('status', 'completed')->sum('total_price')`)
  - `App\Models\Withdrawal` (`Withdrawal::where('status', 'pending')->count()`)
  - `App\Models\Voucher` (`Voucher::where('is_active', true)->count()`)
- **Blade Template:** `resources/views/admin/dashboard-admin/index.blade.php`

---

# 3. MODUL 2: MANAJEMEN PROPERTI & GEDUNG

### 3.1 Purpose & Functionality
Modul ini bertanggung jawab atas siklus hidup seluruh properti sewa dan hotel. Mendukung arsitektur **Single Root Accommodations** dengan discriminator `booking_mode` (`unit` vs `room`), relasi lokasi kota, kompleks gedung (*building list*), kurasi rekomendasi beranda aplikasi, serta banner promosi.

### 3.2 Screen Components & Multi-Step Wizard UI
1. **Property Master Index (`PropertyDataTable`):**
   - Data grid server-side: Gambar Cover, Nama Properti, Kategori (`Apartemen`, `Hotel`, `Kost`), Host/Pemilik, Kota & Gedung, Harga Mulai (`price_from`), Status (`active`/`inactive`), Kolom Aksi.
   - Fitur pencarian cepat (*instant search debounce 300ms*), filter status, dan ekspor data.
2. **Unified Livewire Form Wizard (`Accommodations\WizardForm`):**
   - **Tab 1: Info Dasar & Lokasi:** Input nama akomodasi, slug otomatis, host pemegang unit, pemilihan kota (`cities`), pemilihan gedung (`building_lists`), koordinat latitude/longitude, alamat lengkap, dan deskripsi intro.
   - **Tab 2: Kapasitas & Kamar (Unit Types):** Penentuan tipe kamar atau spesifikasi unit (luas kamar $m^2$, kapasitas tamu dewasa & anak, jumlah kamar tidur & kamar mandi, fasilitas kasur/ranjang).
   - **Tab 3: Harga & Biaya Tambahan:** Konfigurasi tarif multi-durasi (`unit_type_prices`: harian, bulanan, tahunan), biaya kebersihan (*cleaning fee*), uang jaminan (*deposit*), dan biaya layanan platform.
   - **Tab 4: Fasilitas, Kebijakan, & Galeri:** Checklist multi-kategori fasilitas (`facility_items` dengan konteks *facility*, *furniture*, atau *spec*), aturan check-in/out, kebijakan pembatalan, upload galeri foto multi-file dengan penandaan cover.
3. **Sub-Modul Gedung & Kota:**
   - `admin.cities.index`: Pengaturan nama kota, provinsi, gambar thumbnail kota, koordinat pusat, dan status ketersediaan.
   - `admin.building-lists.index`: Pengaturan gedung apartemen/kondominium (nama gedung, alamat, jumlah lantai, fasilitas gedung umum seperti kolam renang dan gym).

### 3.3 Step-by-Step Admin Workflow
1. **Menambahkan Properti Baru:**
   - Navigasikan sidebar ke **Properti > Daftar Properti**, lalu klik tombol **Tambah Properti**.
   - Sistem membuka modal wizard Livewire (`#kt_modal_add_property`).
   - Isi informasi dasar pada **Tab 1**, tentukan `booking_mode` (`unit` untuk apartemen tunggal, `room` untuk unit hotel).
   - Pada **Tab 2**, isi detail tipe kamar. Untuk apartemen, tentukan kapasitas maksimal tamu dan jumlah kamar tidur.
   - Pada **Tab 3**, tentukan nominal tarif harian dan bulanan. Masukkan nominal deposit jaminan kerusakan.
   - Pada **Tab 4**, unggah foto resolusi tinggi, centang fasilitas utama (WiFi, AC, Water Heater, Dapur), lalu tentukan jam check-in (standar 14:00) dan check-out (standar 12:00).
   - Klik **Simpan Properti**. Komponen mengeksekusi penyimpanan terpadu dalam satu transaksi atomik database (`DB::transaction`).
2. **Menonaktifkan / Mengedit Properti:**
   - Cari properti pada DataTable melalui kolom pencarian.
   - Klik menu **Aksi > Edit** untuk memuat ulang data ke dalam wizard form.
   - Lakukan penyesuaian data dan klik **Update**.

### 3.4 Expected Backend & Database Interaction
- **Routes:**
  - `GET /admin/properties` (`admin.properties.index`)
  - `GET /admin/properties/create` (`admin.properties.create`)
  - `GET /admin/properties/{property}/edit` (`admin.properties.edit`)
  - `DELETE /admin/properties/{property}` (`admin.properties.destroy`)
  - `GET /admin/cities` (`admin.cities.index`)
  - `GET /admin/building-lists` (`admin.building-lists.index`)
- **Controllers & Components:**
  - `App\Http\Controllers\Admin\PropertyController`
  - `App\DataTables\PropertyDataTable`
  - `App\Livewire\Accommodations\WizardForm`
- **Models Terlibat:**
  - `App\Models\Accommodation` (Tabel utama `accommodations`)
  - `App\Models\City` (`cities`)
  - `App\Models\BuildingList` (`building_lists`)
  - `App\Models\UnitType` (`unit_types` sebagai SSoT spesifikasi fisik dan relasi `cheapestUnitType()`)
  - `App\Models\UnitTypePrice` (`unit_type_prices`)
  - `App\Models\FacilityItem` (`facility_items`)
  - `App\Models\Gallery` (`galleries`)
  - `App\Models\AccommodationPolicy` (`accommodation_policies`)

---

# 4. MODUL 3: MANAJEMEN KAMAR & INVENTORY

### 4.1 Purpose & Functionality
Modul ini mengelola ketersediaan unit dan inventaris kamar secara presisi untuk menghindari *double-booking* (reservasi ganda). Mengadopsi prinsip **Dual Availability Engine**:
- **Unit Property:** Ketersediaan bersifat biner (tersedia atau diblokir) per rentang tanggal pemesanan.
- **Hotel OTA:** Ketersediaan berbasis alokasi kuota kamar (*allotment*) yang dihitung dari formula `remaining = total_inventory - active_bookings`.

### 4.2 Screen Components & Availability Matrix
1. **Kalender Matriks Ketersediaan (Interactive FullCalendar / Date Grid):**
   - Tampilan visual per bulan/minggu dengan kode warna status:
     - 🟢 **Hijau (Available):** Unit siap dipesan, kuota kamar penuh.
     - 🔴 **Merah (Booked):** Unit terkunci oleh tamu dengan reservasi berstatus aktif.
     - 🟡 **Kuning (Maintenance / Out of Order):** Unit diblokir oleh admin/host untuk keperluan perawatan, renovasi, atau perbaikan interior.
     - ⚪ **Abu-abu (Blocked Dates):** Tanggal masa lalu atau tanggal di luar kontrak sewa.
2. **Form Konfigurasi Kuota & Blackout Date:**
   - Pemilihan akomodasi dan tipe unit (`unit_types`).
   - Pemilih rentang tanggal (*Date Range Picker*).
   - Override harga khusus (*Seasonal / Weekend Pricing Surcharge*).
   - Toggle sakelar status pemblokiran inventaris (*Block Room / Out of Service*).

### 4.3 Step-by-Step Admin Workflow
1. **Memblokir Kamar untuk Maintenance / Perbaikan:**
   - Navigasi ke **Properti > Ketersediaan** (atau kelola inventaris di detail unit).
   - Pilih properti target dan pilih unit kamar (mis. "Unit 12B - Tower Sakura").
   - Pilih tanggal mulai dan tanggal selesai masa renovasi.
   - Set status ketersediaan ke **Maintenance / Blocked**.
   - Simpan perubahan. Sistem langsung memperbarui kuota ketersediaan sehingga tanggal tersebut tidak dapat dipilih di aplikasi Flutter konsumen.
2. **Menyesuaikan Kuota Kamar Hotel Harian:**
   - Buka pengaturan `UnitType` kamar target.
   - Atur `total_inventory` (mis. 10 kamar tipe Deluxe).
   - Job otomatis `App\Jobs\ExtendHotelInventoriesJob` memastikan stok tersedia untuk horizon reservasi hingga 365 hari ke depan.

### 4.4 Expected Backend & Database Interaction
- **Routes:**
  - `GET /admin/availabilities` (`admin.availabilities.index`)
  - `GET /admin/availabilities/create` (`admin.availabilities.create`)
  - `GET /admin/availabilities/{availability}/edit` (`admin.availabilities.edit`)
  - `DELETE /admin/availabilities/{availability}` (`admin.availabilities.destroy`)
- **Controllers & Components:**
  - `App\Http\Controllers\Admin\AvailabilityController`
  - `App\DataTables\AvailabilityDataTable`
  - `App\Livewire\Availabilities\Form`
- **Models & Relasi:**
  - `App\Models\UnitType` (Kolom `total_inventory`, accessor `remaining`)
  - `App\Models\Availability` (Tabel pengecualian tanggal `availabilities`)
  - `App\Models\Booking` (Pengecekan overlap tanggal `check_in` dan `check_out` pada booking berstatus `confirmed`, `paid`, `waiting_checkin`, `staying`)

---

# 5. MODUL 4: MANAJEMEN TAMU & PENGGUNA (USER MANAGEMENT & RBAC)

### 5.1 Purpose & Functionality
Modul ini mengelola seluruh pengguna ekosistem Liviroom, memisahkan hak istimewa operasional internal dari akun publik, memverifikasi identitas mitra pemilik properti (*Know Your Customer / KYC*), serta memantau rekam jejak (*booking history*) dan audit aktivitas pengguna.

### 5.2 Screen Components & UI Elements
1. **Users DataTable (`UsersDataTable`):**
   - Kolom: Info Profil (Avatar, Nama, Email Terverifikasi), Peran (*Role Badge*), Tipe Akun (`consumer`, `host`, `corporate`), No. Telepon, Tanggal Registrasi, Tombol Aksi.
   - Tombol **Add User** memicu modal Livewire `AddUserModal`.
2. **User Validation (KYC Host Verification Desk):**
   - Grid kartu permohonan verifikasi host baru yang mengunggah berkas identitas resmi.
   - Modal AJAX Preview Berkas: Menampilkan foto KTP definisi tinggi, foto selfie bersama KTP, Nomor NIK, Nama Lengkap sesuai KTP.
   - Tombol Tindakan Cepat: **Approve KYC** (Otomatis mempromosikan akun menjadi Host) dan **Reject KYC** (dengan kolom input alasan penolakan).
3. **Role & Permission Management UI:**
   - **Role Cards Grid (`RoleList`):** Kartu visual per peran (Admin, Host, CS Operator) yang menampilkan total personil aktif dalam peran tersebut.
   - **Permission Matrix Table:** Matriks checkbox perizinan granular Spatie (`view properties`, `create bookings`, `view payments`, `edit payment_settings`).

### 5.3 Step-by-Step Admin Workflow (KYC Validation & Role Assignment)
1. **Memverifikasi Pengajuan Host Baru (KYC Approval):**
   - Buka menu **User > User Validation** (`admin.user-management.user-validation.index`).
   - Pilih pengguna dengan status *Pending Validation*.
   - Klik tombol **Review Dokumen**. Sistem memuat modal AJAX dengan foto KTP dan foto selfie.
   - Verifikasi keaslian dokumen dan kesesuaian nama.
   - Klik tombol **Approve Validation**.
   - *Backend Action:* Sistem mengeksekusi `UserValidationController::update`, mencatat status `is_validate = true`, menghapus peran `consumer` dari pengguna, dan memberikan peran `host` (`$user->assignRole('host')`). Notifikasi otomatis dikirimkan ke aplikasi mobile mitra.
2. **Membuat dan Menetapkan Role Staf Baru:**
   - Buka menu **User > User Management > Roles**.
   - Klik **Add Role**, beri nama peran (misal: `FrontDesk`).
   - Centang izin yang relevan: `view bookings`, `edit bookings`, `view user_profiles`.
   - Simpan peran. Tetapkan pengguna staf yang ditunjuk ke dalam peran ini.

### 5.4 Expected Backend & Database Interaction
- **Routes:**
  - `GET /admin/user-management/users` (`admin.user-management.users.index`)
  - `GET /admin/user-management/roles` (`admin.user-management.roles.index`)
  - `GET /admin/user-management/permissions` (`admin.user-management.permissions.index`)
  - `GET /admin/user-management/user-validation` (`admin.user-management.user-validation.index`)
  - `GET /admin/user-management/user-validation/{id}` (`admin.user-management.user-validation.show`)
  - `PUT /admin/user-management/user-validation/{id}` (`admin.user-management.user-validation.update`)
- **Controllers & Livewire:**
  - `App\Http\Controllers\Admin\UserManagementController`
  - `App\Http\Controllers\Admin\UserValidationController`
  - `App\Livewire\User\AddUserModal`
  - `App\Livewire\Permission\RoleList`
  - `App\Livewire\Permission\RoleModal`
- **Models:**
  - `App\Models\User`
  - `App\Models\UserProfile` (Relasi profil: `company_name`, `npwp`, `phone`, `address`)
  - `App\Models\UserValidation` (Data KYC: `upload_ktp`, `upload_selfie`, `is_validate`)
  - `Spatie\Permission\Models\Role` & `Permission`

---

# 6. MODUL 5: MANAJEMEN RESERVASI & BOOKING

### 6.1 Purpose & Functionality
Modul Reservasi adalah jantung transaksional platform. Mengelola siklus hidup penuh pemesanan (*booking lifecycle state machine*), memonitor kedatangan dan kepulangan tamu, menangani *manual override* untuk kasus darurat atau perpanjangan durasi (*stay extension*), serta menerbitkan dokumen tagihan resmi (*Invoice PDF*).

### 6.2 Screen Components & Booking Lifecycle State Machine
1. **Status Lifecycle State Machine:**
   Platform Liviroom menegakkan **9 Nilai Status Reservasi Resmi**:
   - `waiting_payment`: Reservasi dibuat di aplikasi, menunggu pembayaran via Midtrans Snap.
   - `waiting_confirmation`: Pembayaran diterima, menunggu verifikasi ketersediaan final dari Host.
   - `confirmed`: Reservasi telah dikonfirmasi dan unit terkunci aman.
   - `paid`: Pembayaran lunas terverifikasi penuh.
   - `waiting_checkin`: Menjelang hari-H kedatangan tamu (H-1 / Hari-H sebelum jam check-in).
   - `staying`: Tamu telah berhasil melakukan proses check-in fisik di unit/apartemen.
   - `completed`: Tamu telah check-out, deposit jaminan diselesaikan, transaksi selesai.
   - `cancelled`: Dibatalkan oleh tamu atau ditolak oleh host sebelum check-in.
   - `expired`: Waktu pembayaran Midtrans melampaui batas waktu (otomatis dibatalkan oleh `CancelExpiredBookingsJob`).
2. **Booking Management DataTable:**
   - Kolom: Kode Booking (`booking_code`), Nama Properti, Nama Tamu & Kontak, Rentang Tanggal (`check_in` - `check_out`), Durasi & Tipe (`daily`, `monthly`, `yearly`), Total Nilai Pembayaran, Badge Status, Kolom Aksi.
3. **Layar Detail Booking & Invoice (`admin.bookings.show`):**
   - Rincian lengkap tamu, rincian biaya sewa, breakdown diskon voucher, biaya layanan, nomor unit kamar, dan tombol unduh **Invoice PDF**.

### 6.3 Step-by-Step Admin Workflow (Check-in, Check-out, Manual Override)
1. **Proses Check-in Tamu:**
   - Tamu tiba di lokasi dan menunjukkan bukti pemesanan / QR Code dari aplikasi Flutter.
   - Petugas mencari reservasi pada DataTable menggunakan `booking_code` (contoh: `BK-LIV-202609-0012`).
   - Klik **Edit / Kelola Status**.
   - Ubah status dari `waiting_checkin` menjadi `staying`.
   - Serahkan kunci unit / kartu akses fisik kepada tamu.
2. **Proses Check-out & Penyelesaian Deposit:**
   - Tamu mengembalikan kunci di akhir masa sewa.
   - Petugas melakukan inspeksi fisik kelayakan unit kamar.
   - Jika tidak ada kerusakan inventaris, ubah status reservasi menjadi `completed`.
   - Deposit jaminan dikembalikan ke saldo dompet tamu atau rekening transfer.
3. **Manual Override (Perubahan Tanggal atau Pembatalan Khusus):**
   - Dalam skenario tamu meminta perpanjangan menginap mendesak secara offline:
   - Admin membuka form edit booking via `Bookings\Form`.
   - Perbarui field `check_out` ke tanggal yang baru, sesuaikan `total_price` sesuai tarif sewa tambahan.
   - Klik **Simpan**. Sistem memvalidasi bahwa tanggal perpanjangan tersebut tidak bentrok dengan reservasi tamu lain.

### 6.4 Expected Backend & Database Interaction
- **Routes:**
  - `GET /admin/bookings` (`admin.bookings.index`)
  - `GET /admin/bookings/create` (`admin.bookings.create`)
  - `GET /admin/bookings/{booking}` (`admin.bookings.show`)
  - `GET /admin/bookings/{booking}/invoice` (`admin.bookings.invoice`)
  - `GET /admin/bookings/{booking}/edit` (`admin.bookings.edit`)
  - `DELETE /admin/bookings/{booking}` (`admin.bookings.destroy`)
- **Controllers & Components:**
  - `App\Http\Controllers\Admin\BookingController`
  - `App\DataTables\BookingDataTable`
  - `App\Livewire\Bookings\Form`
  - `App\Jobs\CancelExpiredBookingsJob`
- **Models:**
  - `App\Models\Booking` (Tabel `bookings`)
  - `App\Models\BookingRoom` (Tabel kamar hotel terikat `booking_rooms`)
  - `App\Models\Order` (Tabel order penagihan satelit `orders`)
  - `App\Models\Payment` (Tabel catatan transaksi `payments`)

---

# 7. MODUL 6: KEUANGAN & PEMBAYARAN

### 7.1 Purpose & Functionality
Modul Keuangan mengontrol seluruh lalu lintas moneter platform Liviroom: konfigurasi integrasi payment gateway **Midtrans** (Snap & Core API), pengelolaan metode pembayaran aktif, persetujuan dan eksekusi pencairan saldo host (*withdrawals*), serta penerbitan laporan keuangan berkala yang dapat diekspor ke Excel dan PDF.

### 7.2 Screen Components & Payment Settings UI
1. **Pengaturan Gateway Pembayaran (`PaymentSettings\Settings`):**
   - **Kredensial Midtrans:** Input Server Key, Client Key, dan toggle mode Sandbox vs Produksi (*Production Mode*).
   - **Profil Merchant:** Nama Merchant, Email Dukungan Billing, Nomor Telepon Merchant.
   - **Katalog Metode Pembayaran:** Sakelar toggle per kanal pembayaran (BCA Virtual Account, Mandiri Bill, BNI VA, BRI VA, Permata VA, Gopay, QRIS, Kartu Kredit).
2. **Daftar Transaksi Pembayaran (`PaymentDataTable`):**
   - Kolom: Transaksi ID, Kode Order, Metode Pembayaran, Jumlah Tagihan, Status Settlement, Tanggal Bayar, Bukti / Midtrans Reference.
3. **Manajemen Withdrawal Host (`WithdrawalDataTable`):**
   - Kolom: Host Pengaju, Nama Bank & Nomor Rekening, Jumlah Penarikan, Saldo Tersedia, Status (`pending`, `approved`, `rejected`), Tanggal Pengajuan, Aksi.
4. **Laporan & Ekspor Finansial (`ReportController`):**
   - Laporan Pendapatan (*Revenue Report*), Laporan Booking, Laporan Withdrawal, dan Laporan Performa Properti.
   - Tombol Export: **Export to Excel (.xlsx)** via `Maatwebsite\Excel` dan **Export to PDF** via `barryvdh/laravel-dompdf`.

### 7.3 Step-by-Step Admin Workflow (Midtrans Setup, Withdrawal Approval, Financial Reports)
1. **Konfigurasi Kredensial Midtrans:**
   - Buka menu **Transaksi > Pembayaran > Pengaturan Pembayaran** (`admin.payment-settings.index`).
   - Masukkan *Midtrans Server Key* dan *Client Key* yang didapatkan dari Midtrans Dashboard.
   - Tentukan status lingkungan (Matikan switch produksi untuk pengujian Sandbox, hidupkan untuk Live Production).
   - Klik **Simpan Pengaturan Midtrans**. Sistem menyimpan kredensial ke database tabel `payment_settings` dan otomatis mengaplikasikan konfigurasi aktif (`PaymentSetting::applyMidtransConfig()`).
   - Aktifkan metode pembayaran yang diinginkan (mis. QRIS, BCA VA, ShopeePay) dengan mengklik switch di tabel metode pembayaran.
2. **Memproses Pencairan Dana Host (Withdrawal Approval):**
   - Buka menu **Transaksi > Withdrawal** (`admin.withdrawals.index`).
   - Periksa daftar pengajuan yang berstatus *Pending*.
   - Periksa validitas nomor rekening dan ketersediaan saldo host dari riwayat reservasi yang telah `completed`.
   - Lakukan transfer bank ke rekening host terkait.
   - Klik **Edit / Setujui**, unggah bukti transfer perbankan, dan ubah status menjadi `approved`.
   - Host otomatis menerima notifikasi konfirmasi pencairan di aplikasi mobile.
3. **Mengekspor Laporan Keuangan:**
   - Buka menu **Laporan > Pendapatan** (`admin.reports.revenue`).
   - Tentukan filter rentang tanggal (mis. `from = 2026-09-01` sampai `to = 2026-09-30`).
   - Klik tombol **Export Excel**. File `.xlsx` tergenerate secara otomatis dengan format laporan resmi siap audit.

### 7.4 Expected Backend & Database Interaction
- **Aturan Integritas Pembayaran:**
  > **KRITIKAL:** Sesuai standar industri perbankan, Callback Controller (`Payment/{Finish,Unfinish,Error}Controller`) **TIDAK PERNAH** memutasi status pembayaran. Mutasi status pembayaran HANYA diizinkan melalui **Midtrans S2S (Server-to-Server) Webhook** setelah lolos verifikasi tanda tangan SHA512 dan nominal `gross_amount`.
- **Routes:**
  - `GET /admin/payments` (`admin.payments.index`)
  - `GET /admin/payment-methods` (`admin.payment-methods.index`)
  - `GET /admin/payment-settings` (`admin.payment-settings.index`)
  - `GET /admin/withdrawals` (`admin.withdrawals.index`)
  - `GET /admin/reports/revenue` (`admin.reports.revenue`)
  - `GET /admin/reports/export/{type}` (`admin.reports.export`)
- **Controllers & Livewire:**
  - `App\Http\Controllers\Admin\PaymentController`
  - `App\Http\Controllers\Admin\PaymentMethodController`
  - `App\Http\Controllers\Admin\WithdrawalController`
  - `App\Http\Controllers\Admin\ReportController`
  - `App\Livewire\PaymentSettings\Settings`
- **Models:**
  - `App\Models\Payment` (Status: `pending`, `settlement`, `paid`, `failed`, `expired`, `refunded`)
  - `App\Models\PaymentMethod` (`code`, `name`, `fee`, `is_enabled`, `sort_order`)
  - `App\Models\PaymentSetting` (Konfigurasi tersimpan: server key, client key)
  - `App\Models\Withdrawal` (`amount`, `bank_name`, `bank_account`, `status`)

---

# 8. MODUL 7: PENGATURAN SISTEM & INTEGRASI

### 8.1 Purpose & Functionality
Modul Pengaturan mengontrol konfigurasi global platform Liviroom, parameter bisnis, identitas visual aplikasi, integrasi perpesanan SMTP Email dan SMS/WhatsApp Gateway, manajemen kredensial Firebase Cloud Messaging (FCM) untuk notifikasi mobile push, serta konfigurasi jarak jauh (*Remote Config*) aplikasi Flutter.

### 8.2 Screen Components & Configuration UI
1. **Aplikasi & Konfigurasi Bisnis (`layout/_setting.blade.php`):**
   - **Tab General:**
     - Upload Logo Platform (Mendukung PNG, SVG, resolusi tinggi).
     - Upload Favicon Browser.
     - Nama Proyek (`PROJECT_NAME`) & Moto Aplikasi (`APP_MOTO`).
     - Email Layanan Pelanggan (`APP_EMAIL_SUPPORT`) & Telepon Hotline (`APP_PHONE`).
     - Pengaturan Mata Uang Default (`APP_CURRENCY = IDR`).
   - **Tab Notifikasi & Biaya:**
     - Toggle Master Notifikasi Push FCM (`APP_NOTIF = true/false`).
     - Switch Tampilkan Pajak di Harga Listing (`APP_INCLUDE_TAX`).
     - Switch Tampilkan Biaya Lainnya di Harga Listing (`APP_INCLUDE_BIAYA`).
     - Input ID Proyek Firebase (`FIREBASE_PROJECT_ID`).
     - Editor Berkas Kredensial Firebase Service Account JSON (disimpan di `storage/app/firebase/firebase_credentials.json`).
2. **Remote Config Desk (`admin.remote-config.index`):**
   - Konfigurasi parameter dinamis aplikasi Flutter mobile tanpa perlu rilis ulang ke Google Play Store / Apple App Store (mis. URL Term of Service, maintenance flag, nomor customer support WhatsApp, minimum version force-update).
3. **Log Notifikasi & Audit Log:**
   - **Notification Logs (`admin.notification-logs.index`):** Rekap riwayat pesan push notification yang terkirim ke gawai tamu dan host, mencakup recipient user ID, FCM token, judul, payload pesan, dan status pengiriman.
   - **Audit Logs (`admin.audit-logs.index`):** Catatan forensik seluruh aktivitas staf dan admin di panel (siapa yang mengubah harga, waktu eksekusi perubahan peran, IP address, dan user agent).

### 8.3 Step-by-Step Admin Workflow (Firebase FCM, SMTP, Remote Config)
1. **Konfigurasi Kredensial Firebase Push Notification:**
   - Unduh file `service-account.json` resmi dari Google Firebase Console proyek Liviroom.
   - Masuk ke Admin Dashboard Liviroom pada menu **Setting > Apps Config**.
   - Buka tab **Notifikasi**.
   - Masukkan ID Proyek pada kolom **FIREBASE PROJECT ID** (misal: `livirooms-mobile-app`).
   - Buka file JSON kredensial dengan text editor, salin seluruh kodenya, dan tempelkan ke textarea **Firebase Service Account JSON**.
   - Klik tombol **Save Firebase JSON**.
   - Sistem memvalidasi sintaks JSON melalui `json_decode`, memverifikasi struktur, dan menyimpannya secara aman di direktori storage terproteksi.
   - Aktifkan sakelar **Aktivasi Notifikasi FCM** ke posisi **ON**, lalu klik **Save**.
2. **Pembaruan Kontak Dukungan & WhatsApp Support:**
   - Pada tab **General**, perbarui kolom **Phone Support** dengan nomor WhatsApp resmi layanan pelanggan (format internasional, mis. `+6281234567890`).
   - Klik **Save**. Sistem secara otomatis membersihkan cache konfigurasi Laravel (`config:clear` & `cache:clear`).
   - Aplikasi mobile Flutter akan langsung membaca nomor WhatsApp terbaru saat pengguna mengklik menu *Hubungi Bantuan*.

### 8.4 Expected Backend & Database Interaction
- **Routes:**
  - `GET /admin/setting` (`admin.setting.index`)
  - `POST /admin/setting/env_key_update` (`admin.env_key_update.update`)
  - `POST /admin/setting/upload-logo` (`admin.setting.upload-logo`)
  - `POST /admin/setting/upload-favicon` (`admin.setting.upload-favicon`)
  - `POST /admin/setting/savejson-firebase` (`admin.setting.savejson-firebase`)
  - `GET /admin/remote-config` (`admin.remote-config.index`)
  - `GET /admin/notification-logs` (`admin.notification-logs.index`)
  - `GET /admin/audit-logs` (`admin.audit-logs.index`)
- **Controllers & Logika:**
  - `App\Http\Controllers\Admin\BusinessSettingsController`
  - `App\Http\Controllers\Admin\RemoteConfigController`
  - `App\Http\Controllers\Admin\NotificationLogController`
  - `App\Http\Controllers\Admin\AuditLogController`
- **File Konfigurasi & Berkas Keamanan:**
  - `.env` (Diperbarui secara terproteksi menggunakan regex stream safe writer)
  - `storage/app/firebase/firebase_credentials.json` (Kredensial otentikasi Google API v1)
  - Direktori publik aset: `storage/logos/`

---

# 9. LAMPIRAN: MATRIKS REFERENSI TEKNIS RUTE, CONTROLLER, DAN MODEL

Tabel referensi berikut merangkum pemetaan teknis lengkap 24 modul panel administrasi Livirooms:

| No | Modul / Halaman | HTTP Route | Controller Admin | Livewire / DataTable | Model Eloquent Terkait |
|---|---|---|---|---|---|
| **1** | Dashboard Utama | `/admin/dashboard-admin` | `DashboardAdminController` | — | `User`, `Accommodation`, `Booking`, `Withdrawal` |
| **2** | Daftar Properti | `/admin/properties` | `PropertyController` | `PropertyDataTable`, `Accommodations\WizardForm` | `Accommodation`, `UnitType`, `FacilityItem`, `Gallery` |
| **3** | Kota Operasional | `/admin/cities` | `CityController` | `CityDataTable`, `Cities\Form` | `City` |
| **4** | Daftar Gedung | `/admin/building-lists` | `BuildingListController` | `BuildingListDataTable`, `BuildingLists\Form` | `BuildingList` |
| **5** | Rekomendasi Beranda | `/admin/accommodation-recommendations` | `AccommodationRecommendationController` | `AccommodationRecommendationDataTable` | `AccommodationRecommendation` |
| **6** | Log Pencarian | `/admin/accommodation-search-logs` | `AccommodationSearchLogController` | `AccommodationSearchLogDataTable` | `AccommodationSearchLog` |
| **7** | Banner Promosi | `/admin/banners` | `BannerController` | `BannerDataTable`, `Banners\Form` | `Banner` |
| **8** | Manajemen Booking | `/admin/bookings` | `BookingController` | `BookingDataTable`, `Bookings\Form` | `Booking`, `BookingRoom`, `Accommodation`, `User` |
| **9** | Order Penagihan | `/admin/orders` | `OrderController` | `OrderDataTable`, `Orders\Form` | `Order`, `Payment`, `Booking` |
| **10** | Riwayat Pembayaran | `/admin/payments` | `PaymentController` | `PaymentDataTable`, `Payments\Form` | `Payment`, `Order` |
| **11** | Metode Pembayaran | `/admin/payment-methods` | `PaymentMethodController` | `PaymentMethodDataTable`, `PaymentMethods\Form` | `PaymentMethod` |
| **12** | Pengaturan Midtrans | `/admin/payment-settings` | *View Closure* | `PaymentSettings\Settings` | `PaymentSetting`, `PaymentMethod` |
| **13** | Penarikan Host | `/admin/withdrawals` | `WithdrawalController` | `WithdrawalDataTable`, `Withdrawals\Form` | `Withdrawal`, `User` (Host) |
| **14** | Manajemen Voucher | `/admin/vouchers` | `VoucherController` | `VoucherDataTable`, `Vouchers\Form` | `Voucher` |
| **15** | Program Referral | `/admin/referrals` | `ReferralController` | `ReferralDataTable`, `Referrals\Form` | `Referral`, `User` |
| **16** | Ulasan Tamu | `/admin/reviews` | `ReviewController` | `ReviewDataTable`, `Reviews\Form` | `Review`, `ReviewPhoto` |
| **17** | FAQ Bantuan | `/admin/faqs` | `FaqController` | `FaqDataTable`, `Faqs\Form` | `Faq` |
| **18** | CMS Halaman | `/admin/cms-pages` | `CmsPageController` | `CmsPageDataTable`, `CmsPages\Form` | `CmsPage` |
| **19** | Percakapan Chat | `/admin/conversations` | `ConversationController` | `ConversationDataTable`, `Conversations\Form` | `Conversation`, `Message` |
| **20** | Wishlist Tamu | `/admin/wishlists` | `WishlistController` | `WishlistDataTable`, `Wishlists\Form` | `Wishlist` |
| **21** | Laporan Platform | `/admin/reports/*` | `ReportController` | Maatwebsite Excel & DomPDF Exporter | `Booking`, `Payment`, `Withdrawal`, `Accommodation` |
| **22** | Log Notifikasi | `/admin/notification-logs` | `NotificationLogController` | `NotificationLogDataTable` | `NotificationLog` |
| **23** | Audit Log Sistem | `/admin/audit-logs` | `AuditLogController` | `AuditLogDataTable` | `AuditLog`, `User` |
| **24** | Pengguna Platform | `/admin/user-management/users` | `UserManagementController` | `UsersDataTable`, `User\AddUserModal` | `User`, `UserProfile` |
| **25** | Peran (Roles) | `/admin/user-management/roles` | `RoleManagementController` | `Permission\RoleList`, `RoleModal` | Spatie `Role` |
| **26** | Izin (Permissions) | `/admin/user-management/permissions` | `PermissionManagementController` | `PermissionsDataTable`, `PermissionModal` | Spatie `Permission` |
| **27** | Verifikasi KYC Host | `/admin/user-management/user-validation` | `UserValidationController` | `UserValidationDataTable` | `UserValidation`, `User` |
| **28** | Remote Config | `/admin/remote-config` | `RemoteConfigController` | `RemoteConfig\Form` | Dynamic App Settings |
| **29** | Apps Config & FCM | `/admin/setting` | `BusinessSettingsController` | Blade Layout Builder (`_setting.blade.php`) | `.env`, `firebase_credentials.json` |

---

### Verifikasi & Standar Integritas Produksi
1. **Zero N+1 Query:** Seluruh pemanggilan relasi di dalam Yajra DataTables wajib mengimplementasikan eager loading (`with(['accommodation', 'user', 'roles'])`).
2. **Idempotensi Pembayaran:** Sinkronisasi status pembayaran wajib mengacu secara eksklusif ke webhook resmi Midtrans dengan validasi `hash('sha512', $order_id . $status_code . $gross_amount . $server_key)`.
3. **Penyimpanan Dokumen Sensitif:** Berkas identitas KTP dan dokumen KYC pengguna disimpan di direktori terproteksi `storage/app/public/user_validations/` dengan batasan akses otorisasi admin.

---
*Dokumen ini merupakan standar operasional prosedur (SOP) dan dokumentasi arsitektur resmi platform Livirooms. Seluruh pembaruan modul wajib disinkronkan secara konsisten dengan dokumen ini.*
