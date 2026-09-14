# USER GUIDE WEB ADMINISTRATOR
## Panduan Operasional & Petunjuk Penggunaan Website Admin Livirooms
**Workspace Sumber:** `laravel/` (Laravel 12 & Metronic Admin Theme)  
**Versi Dokumen:** v2.4.0  
**Target Pengguna:** Administrator, Supervisor Operasional, Front Desk, Tim Keuangan (Finance), Customer Service  

---

## DAFTAR ISI

1. [Bab 1: Login & Autentikasi Sistem](#bab-1-login--autentikasi-sistem)
   - 1.1 Cara Masuk ke Dashboard Admin (Login)
   - 1.2 Cara Memulihkan Kata Sandi (Lupa Password)
   - 1.3 Memahami Hak Akses Pengguna (Role-Based Access Control)
2. [Bab 2: Membaca & Menggunakan Dashboard Utama](#bab-2-membaca--menggunakan-dashboard-utama)
   - 2.1 Membaca Kartu Ringkasan (KPI Metrics Overview)
   - 2.2 Navigasi Pintas Operasional
3. [Bab 3: Manajemen Properti, Kamar & Kompleks Gedung](#bab-3-manajemen-properti-kamar--kompleks-gedung)
   - 3.1 Meninjau Tabel Daftar Properti Aktif
   - 3.2 Memulai Pendaftaran Properti Baru (Modal Form Awal)
   - 3.3 Alur Pendaftaran Properti Mode HOTEL (7 Langkah Wizard)
   - 3.4 Alur Pendaftaran Properti Mode APARTEMEN (7 Langkah Wizard)
   - 3.5 Mengelola Master Data Wilayah Kota Operasional
   - 3.6 Mengelola Master Kompleks Gedung & Tower Apartemen
4. [Bab 4: Kurasi Konten Beranda & Analisis Pencarian](#bab-4-kurasi-konten-beranda--analisis-pencarian)
   - 4.1 Mengatur Rekomendasi Akomodasi Pilihan Beranda
   - 4.2 Memantau Log Pencarian Tamu & Analisis Tren Pasar
   - 4.3 Mengelola Banner Promosi & Slider Kampanye Iklan
5. [Bab 5: Manajemen Reservasi, Pemesanan & Billing Order](#bab-5-manajemen-reservasi-pemesanan--billing-order)
   - 5.1 Memantau Tabel Reservasi Booking Tamu
   - 5.2 Rincian Pemesanan, Status Staying & Cetak Invoice PDF
   - 5.3 Manajemen Order Penagihan Satelit
6. [Bab 6: Transaksi Pembayaran, Saluran & Integrasi Gateway Midtrans](#bab-6-transaksi-pembayaran-saluran--integrasi-gateway-midtrans)
   - 6.1 Memantau Riwayat Transaksi Pembayaran Gateway
   - 6.2 Mengelola Master Saluran Pembayaran (VA, QRIS, E-Wallet, Kartu Kredit)
   - 6.3 Mengatur Kredensial & Saluran Pembayaran Gateway Midtrans
7. [Bab 7: Manajemen Keuangan Mitra & Penarikan Saldo Host](#bab-7-manajemen-keuangan-mitra--penarikan-saldo-host)
   - 7.1 Memantau Antrean Pengajuan Penarikan Saldo (Withdrawal)
   - 7.2 Memproses Transfer Perbankan & Persetujuan Pencairan Dana
8. [Bab 8: Program Marketing, Kupon Diskon & Referral](#bab-8-program-marketing-kupon-diskon--referral)
   - 8.1 Mengelola Kupon Promo & Voucher Diskon Konsumen
   - 8.2 Memantau Program Rujukan Pengguna (Referral System)
9. [Bab 9: Manajemen Reputasi, Bantuan & Konten Legal](#bab-9-manajemen-reputasi-bantuan--konten-legal)
   - 9.1 Memantau & Memberikan Balasan Ulasan Tamu (Review & Rating)
   - 9.2 Mengelola Pusat Bantuan & Tanya Jawab Pengguna (FAQ)
   - 9.3 Mengelola Dokumen Legal Halaman Konten Statis (CMS Page)
10. [Bab 10: Komunikasi Chat & Pemantauan Minat Pelanggan](#bab-10-komunikasi-chat--pemantauan-minat-pelanggan)
    - 10.1 Memantau Pesan Percakapan Chat Tamu dan Host
    - 10.2 Menganalisis Minat Properti Favorit Konsumen (Wishlist)
11. [Pusat Bantuan & Kontak Layanan Operasional](#pusat-bantuan--kontak-layanan-operasional)

---

## BAB 1: LOGIN & AUTENTIKASI SISTEM

### 1.1 Cara Masuk ke Dashboard Admin (Login)
1. **Buka Browser Komputer:** Gunakan Google Chrome, Microsoft Edge, atau Mozilla Firefox versi terbaru untuk performa terbaik.
2. **Akses Alamat Web:** Masukkan alamat URL panel admin: `https://app.livirooms.com/admin` (atau alamat IP server operasional Anda).
3. **Masukkan Identitas Akun:**
   - Masukkan **Alamat Email Resmi** Anda (contoh: `admin@livirooms.com`).
   - Masukkan **Kata Sandi (Password)** Anda. Klik ikon mata untuk melihat karakter yang diketik guna mencegah salah ketik.
4. **Opsi "Ingat Saya":** Beri centang pada opsi *Remember Me* jika menggunakan perangkat kerja pribadi.
5. **Klik Tombol "Masuk":** Tekan tombol biru **"Sign In"**.
6. **Hasil yang Diharapkan:** Sistem memvalidasi akun dan secara otomatis mengarahkan Anda ke tampilan **Dashboard Utama**.

> 💡 **TIPS OPERASIONAL:**
> - Demi menjaga keamanan data reservasi tamu, sesi admin akan otomatis keluar (*auto-logout*) jika tidak ada aktivitas selama 120 menit.
> - Jangan pernah menyimpan kata sandi admin di komputer umum (*shared device*).

### 1.2 Cara Memulihkan Kata Sandi (Lupa Password)
1. Pada halaman login admin, klik tautan **"Lupa Kata Sandi?"**.
2. Masukkan alamat email terdaftar Anda, lalu klik **"Kirim Tautan Pemulihan"**.
3. Buka kotak masuk email Anda, buka pesan dari *Livirooms Security*, lalu klik tombol **"Reset Password"**.
4. Buat kata sandi baru (minimal 8 karakter dengan perpaduan huruf besar, huruf kecil, angka, dan simbol).
5. Simpan kata sandi baru dan masuklah kembali melalui halaman login.

### 1.3 Memahami Hak Akses Pengguna (Role-Based Access Control)
Sistem membagi tugas operasional ke dalam beberapa tingkatan wewenang:
- **Super Administrator (`admin`):** Berwenang mengatur seluruh sistem, integrasi pembayaran Midtrans, komisi, data staf, dan audit log.
- **Host / Mitra Pemilik Properti (`host`):** Hanya dapat melihat properti miliknya, mengatur ketersediaan kamar, dan mengajukan penarikan saldo (*withdrawal*).
- **Front Desk / Customer Service (`cs_operator`):** Berwenang mengelola daftar reservasi harian, memverifikasi check-in/out tamu di lokasi, dan membalas pesan obrolan tamu.

---

## BAB 2: MEMBACA & MENGGUNAKAN DASHBOARD UTAMA

### 2.1 Membaca Kartu Ringkasan (KPI Metrics Overview)

Setelah berhasil masuk ke sistem, halaman pertama yang ditampilkan adalah Dashboard Eksekutif. Bagian ini memberikan ringkasan angka-angka kunci operasional harian platform Livirooms secara langsung (*real-time*).

![Dashboard Utama Web Administrator](website/01-dashboard-executive-overview.png)
*Gambar 2.1: Tampilan Antarmuka Dashboard Utama (Executive Overview) Panel Administrasi Livirooms*

**Penjelasan Elemen & Metrik Utama:**
1. **Total Pengguna (8):** Menampilkan jumlah seluruh akun yang telah terdaftar di dalam platform (termasuk tamu konsumen dan mitra pemilik properti).
2. **Pendapatan Platform (Rp 990.000):** Akumulasi pendapatan bruto dari seluruh transaksi pemesanan unit dan kamar yang telah lunas terbayar melalui payment gateway.
3. **Properti Terdaftar (8):** Total unit apartemen dan kamar hotel yang statusnya aktif dan siap dipesan di aplikasi mobile Livirooms.
4. **Host Aktif (2):** Jumlah mitra pemilik properti terverifikasi yang saat ini memiliki listing unit hunian aktif.
5. **Voucher Aktif (4):** Jumlah kupon promosi yang sedang berlaku dan dapat diklaim oleh pengguna di aplikasi mobile.
6. **Withdrawal Pending:** Kartu peringatan antrean permohonan penarikan dana dari mitra host yang memerlukan verifikasi dan eksekusi transfer dari bagian Finance.

### 2.2 Navigasi Pintas Operasional
- **Sidebar Kiri (Menu Utama):** Dikelompokkan menjadi menu *Dashboard*, *Properti*, *Transaksi*, *Konten*, *Laporan*, *Logs*, *User Management*, dan *Setting*.
- **Profil Staf (Kanan Atas):** Menampilkan avatar dan nama staf yang sedang bertugas, disertai menu dropdown untuk mengubah kata sandi atau keluar sistem (*Sign Out*).

---

## BAB 3: MANAJEMEN PROPERTI, KAMAR & KOMPLEKS GEDUNG

### 3.1 Meninjau Tabel Daftar Properti Aktif

Menu Daftar Properti digunakan untuk memantau, mencari, menyaring, dan memperbarui seluruh listing akomodasi yang dipasarkan di platform.

![Tabel Manajemen Properti](website/02-property-management-table.png)
*Gambar 3.1: Tabel Manajemen Properti Menggunakan DataGrid Interaktif*

**Rincian Kolom & Fungsi Antarmuka:**
1. **Kolom Host:** Nama mitra pemilik listing properti (contoh: *Budi Santoso*, *Siti Rahayu*).
2. **Kolom Kota:** Kota tempat properti berada (*Jakarta Pusat*, *Bali*, *Jakarta Barat*).
3. **Kolom Booking Mode:** Pembeda arsitektur listing:
   - `room`: Mode Hotel / Guest House (pemesanan berbasis tipe kamar dan stok harian).
   - `unit`: Mode Apartemen / Villa / Kost (pemesanan unit hunian utuh).
4. **Kolom Nama Akomodasi:** Nama komersial listing beserta kategorinya (*hotel*, *apartment*, *villa*).
5. **Kolom Gallery:** Thumbnail foto sampul utama yang dilihat tamu di aplikasi.
6. **Kolom Harga Mulai:** Tarif sewa terendah yang berlaku untuk listing tersebut.
7. **Kolom Status:** Status keaktifan properti (`active` atau `inactive`).
8. **Tombol "+ Tambah Akomodasi":** Tombol biru di kanan atas untuk membuka wizard pendaftaran properti baru.

---

### 3.2 Memulai Pendaftaran Properti Baru (Modal Form Awal)

Saat tombol **"+ Tambah Akomodasi"** ditekan, sistem menampilkan jendela formulir pendaftaran awal:

![Formulir Tambah Properti Awal](website/03-wizard-step1-create-property.png)
*Gambar 3.2: Modal Inisiasi Pendaftaran Properti Baru (Langkah 1 Form Input Kosong)*

**Langkah Operasional Staf:**
1. Tentukan **Tipe Mode Pemesanan (`Booking Mode`)**:
   - Pilih **"Hotel / Room"** jika properti berupa Hotel dengan banyak kamar per tipe.
   - Pilih **"Apartemen / Unit"** jika properti berupa unit sewa mandiri utuh.
2. Masukkan **Nama Properti** resmi.
3. Pilih **Kota Operasional** dan **Nama Gedung / Tower** tempat properti berada.
4. Tentukan **Host Pemilik Properti** yang bertanggung jawab atas listing tersebut.
5. Masukkan koordinat peta dan alamat lengkap, lalu klik tombol **"Selanjutnya"** untuk melanjutkan ke wizard konfigurasi terperinci.

---

### 3.3 Alur Pendaftaran Properti Mode HOTEL (7 Langkah Wizard)

Pendaftaran properti mode Hotel mengikuti 7 langkah terpandu:

#### Langkah 1: Identitas & Lokasi Hotel
![Hotel Wizard Langkah 1 Identitas](website/04-hotel-wizard-step1-identity.png)
*Gambar 3.3: Hotel Wizard Langkah 1 - Pengisian Identitas Hotel Bintang 4 & Titik Lokasi Peta Hayam Wuruk*

- Masukkan nama hotel (*MaxOne Platinum Hayam Wuruk*), klasifikasi bintang (*Bintang 4*), alamat lengkap di Hayam Wuruk Jakarta Pusat, nomor telepon front desk, dan tentukan titik koordinat peta untuk akurasi navigasi tamu.

#### Langkah 2: Inventaris & Tipe Kamar Hotel
![Hotel Wizard Langkah 2 Tipe Kamar](website/05-hotel-wizard-step2-room-inventory.png)
*Gambar 3.4: Hotel Wizard Langkah 2 - Konfigurasi Tipe Kamar Happiness Room & Alokasi Stok Unit Fisik*

- Daftarkan tipe-tipe kamar yang tersedia (contoh: *Happiness Room*). Tentukan kapasitas maksimal dewasa dan anak, tipe ranjang (*Double Bed / Twin Bed*), serta jumlah total unit kamar fisik yang dialokasikan ke sistem.

#### Langkah 3: Skema Harga & Pajak Layanan
![Hotel Wizard Langkah 3 Harga dan Pajak](website/06-hotel-wizard-step3-pricing-tax.png)
*Gambar 3.5: Hotel Wizard Langkah 3 - Pengaturan Tarif Kamar Harian & Konfigurasi Persentase Pajak*

- Masukkan tarif sewa kamar per malam (*Daily Rate*), biaya sarapan tambahan (opsional), serta tentukan apakah harga sudah termasuk pajak layanan (*Tax Included*) atau belum.

#### Langkah 4: Fasilitas Hotel & Kamar
![Hotel Wizard Langkah 4 Fasilitas](website/07-hotel-wizard-step4-facilities.png)
*Gambar 3.6: Hotel Wizard Langkah 4 - Pemilihan Fasilitas Umum Hotel & Fasilitas Khusus Kamar*

- Beri centang pada fasilitas hotel yang tersedia: WiFi berkecepatan tinggi, restoran, kolam renang, pusat kebugaran, resepsionis 24 jam, perlengkapan mandi, dan pendingin ruangan (AC).

#### Langkah 5: Galeri Media & Foto
![Hotel Wizard Langkah 5 Galeri Media](website/08-hotel-wizard-step5-media-gallery.png)
*Gambar 3.7: Hotel Wizard Langkah 5 - Galeri Foto Fasad Depan, Lobi & Foto Kamar*

- Unggah foto berkualitas tinggi untuk lobi, tampak depan hotel, interior kamar tidur, kamar mandi, dan fasilitas restoran untuk menarik minat calon tamu.

#### Langkah 6: Kebijakan Operasional & Aturan Menginap
![Hotel Wizard Langkah 6 Kebijakan Checkin](website/09-hotel-wizard-step6-policy-checkin.png)
*Gambar 3.8: Hotel Wizard Langkah 6 (Bagian 1) - Jam Check-in/out & Persyaratan Identitas Tamu*

![Hotel Wizard Langkah 6 Aturan Kamar](website/10-hotel-wizard-step6-policy-rules.png)
*Gambar 3.9: Hotel Wizard Langkah 6 (Bagian 2) - Aturan Dilarang Merokok & Jam Tenang*

![Hotel Wizard Langkah 6 Uang Deposit](website/11-hotel-wizard-step6-policy-deposit.png)
*Gambar 3.10: Hotel Wizard Langkah 6 (Bagian 3) - Kebijakan Uang Jaminan/Deposit & Batasan Usia Anak*

- Atur jam standar check-in (*14:00*) dan check-out (*12:00*), dokumen identitas wajib (KTP/Paspor), aturan bebas rokok (*Non-Smoking*), larangan membawa hewan peliharaan, ketentuan deposit jaminan kerusakan, dan kebijakan batas usia anak tanpa biaya tambahan.

#### Langkah 7: Titik Penting (POI) & Publikasi Hotel
![Hotel Wizard Langkah 7 Titik Penting POI](website/12-hotel-wizard-step7-poi-transit.png)
*Gambar 3.11: Hotel Wizard Langkah 7 (Bagian 1) - Titik Penting POI & Akses Transportasi Terdekat*

![Hotel Wizard Langkah 7 FAQ Publikasi](website/13-hotel-wizard-step7-faq-publish.png)
*Gambar 3.12: Hotel Wizard Langkah 7 (Bagian 2) - Tanya Jawab Khusus Hotel & Tombol Publikasi*

- Masukkan tempat menarik di sekitar hotel (stasiun kereta, halte TransJakarta, pusat belanja), tambahkan pertanyaan umum tamu beserta jawabannya, lalu klik tombol biru **"Publikasikan Hotel"**.

---

### 3.4 Alur Pendaftaran Properti Mode APARTEMEN (7 Langkah Wizard)

Pendaftaran properti mode Apartemen mengikuti alur 7 langkah yang disesuaikan untuk unit sewa utuh:

#### Langkah 1: Identitas & Lokasi Apartemen
![Apartemen Wizard Langkah 1 Identitas](website/14-apt-wizard-step1-identity.png)
*Gambar 3.13: Apartemen Wizard Langkah 1 - Identitas Unit Sunset Beach Apartment & Titik Koordinat Peta*

- Masukkan nama unit (*Sunset Beach Apartment*), pilih tower gedung, kota operasional, lantai unit, dan koordinat peta lokasi apartemen.

#### Langkah 2: Ruangan, Kamar & Perabot
![Apartemen Wizard Langkah 2 Ruangan Furnitur](website/15-apt-wizard-step2-rooms-furniture.png)
*Gambar 3.14: Apartemen Wizard Langkah 2 - Konfigurasi Kamar Tidur, Kamar Mandi & Furnitur Dapur*

- Tentukan jumlah kamar tidur (*2 Bedroom*), jumlah kamar mandi, konfigurasi kasur (*King Bed & Single Bed*), perabot ruang keluarga (sofa, smart TV), dan peralatan dapur lengkap (kompor, kulkas, microwave).

#### Langkah 3: Skema Tarif Multi-Durasi
![Apartemen Wizard Langkah 3 Tarif Sewa](website/16-apt-wizard-step3-multiduration-rates.png)
*Gambar 3.15: Apartemen Wizard Langkah 3 - Skema Tarif Fleksibel Harian, Bulanan & Tahunan*

- Masukkan tarif sewa sesuai skema durasi: harga sewa harian (*Rp 450.000/malam*), harga sewa bulanan (*Rp 6.500.000/bulan*), biaya pembersihan (*Cleaning Fee*), dan besaran deposit jaminan kerusakan unit.

#### Langkah 4: Fasilitas Gedung Apartemen
![Apartemen Wizard Langkah 4 Fasilitas Gedung](website/17-apt-wizard-step4-building-facilities.png)
*Gambar 3.16: Apartemen Wizard Langkah 4 - Fasilitas Bersama Gedung (Kolam Renang, Gym, Akses Lift)*

- Pilih fasilitas gedung yang dapat diakses penghuni: kolam renang infinity, fitness center, kartu akses lift khusus penghuni, pos sekuriti 24 jam, dan lahan parkir kendaraan.

#### Langkah 5: Galeri Foto & Deskripsi Unit
![Apartemen Wizard Langkah 5 Galeri Foto](website/18-apt-wizard-step5-media-description.png)
*Gambar 3.17: Apartemen Wizard Langkah 5 - Galeri Foto Interior Unit & Deskripsi Menarik*

- Unggah foto-foto interior unit apartemen (ruang tamu, balkon dengan pemandangan, kamar tidur utama, kamar mandi bersih, dapur) dan tuliskan kalimat promosi yang memikat calon penyewa.

#### Langkah 6: Kebijakan Check-in Mandiri & Tata Tertib
![Apartemen Wizard Langkah 6 Kebijakan Checkin](website/19-apt-wizard-step6-policy-checkin.png)
*Gambar 3.18: Apartemen Wizard Langkah 6 (Bagian 1) - Jam Check-in, Nilai Deposit & Prosedur Masuk*

![Apartemen Wizard Langkah 6 Aturan Hunian](website/20-apt-wizard-step6-policy-rules.png)
*Gambar 3.19: Apartemen Wizard Langkah 6 (Bagian 2) - Aturan Hunian & Larangan Merokok*

![Apartemen Wizard Langkah 6 Kebijakan Pembatalan](website/21-apt-wizard-step6-cancellation.png)
*Gambar 3.20: Apartemen Wizard Langkah 6 (Bagian 3) - Kebijakan Pembatalan Fleksibel 24 Jam*

- Tentukan mekanisme check-in mandiri (*Self Check-in via Smart Lock / Kotak Kunci Lockbox*), tata tertib gedung hunian, aturan jam tenang malam hari, serta kebijakan pembatalan sewa fleksibel (pengembalian penuh jika dibatalkan 24 jam sebelum kedatangan).

#### Langkah 7: Transportasi, Spesifikasi & Publikasi
![Apartemen Wizard Langkah 7 Transportasi](website/22-apt-wizard-step7-poi-transport.png)
*Gambar 3.21: Apartemen Wizard Langkah 7 (Bagian 1) - Integrasi Peta Google Maps & Akses Jalan Tol*

![Apartemen Wizard Langkah 7 Publikasi](website/23-apt-wizard-step7-specifications-publish.png)
*Gambar 3.22: Apartemen Wizard Langkah 7 (Bagian 2) - Spesifikasi Daya Listrik & Tombol Publikasi*

- Cantumkan petunjuk transportasi menuju apartemen, spesifikasi teknis daya listrik (*2200 Watt*), lalu klik tombol biru **"Publikasikan Akomodasi"** untuk mengaktifkan listing di aplikasi konsumen.

---

### 3.5 Mengelola Master Data Wilayah Kota Operasional

Menu Master Kota mengatur daftar kota tempat Livirooms membuka layanan sewa apartemen dan hotel:

![Tabel Master Data Kota](website/24-master-kota-table.png)
*Gambar 3.23: Tabel Master Data Kota Operasional Livirooms*

- **Tabel Rekap Kota:** Menampilkan daftar kota (*Jakarta, Bandung, Surabaya, Bali, dsb*), provinsi induk, urutan prioritas tampil di beranda, dan status aktif.

![Modal Tambah Kota](website/25-master-kota-add-modal.png)
*Gambar 3.24: Modal Tambah Kota Baru Beserta Titik Koordinat Latitude & Longitude*

- **Menambah Kota Baru:** Klik tombol **"+ Add Kota"**, masukkan Nama Kota (*Jakarta*), Provinsi (*DKI Jakarta*), titik koordinat peta Latitude (*-6.2088*) dan Longitude (*106.8456*) untuk perhitungan radius pencarian tamu, urutan prioritas, unggah foto thumbnail landmark kota, lalu klik **Submit**.

![Modal Edit Kota](website/26-master-kota-edit-modal.png)
*Gambar 3.25: Modal Pengubahan Data Kota & Opsi Reset Gambar*

- **Mengedit Kota:** Klik tombol **Edit** pada baris kota untuk memperbarui koordinat lintang/bujur atau mengganti foto thumbnail kota.

---

### 3.6 Mengelola Master Kompleks Gedung & Tower Apartemen

Menu Master Gedung digunakan untuk mengelompokkan unit-unit apartemen yang berada di dalam kawasan kondominium atau kompleks gedung yang sama:

![Tabel Master Gedung](website/27-master-gedung-table.png)
*Gambar 3.26: Tabel Master Kompleks Gedung & Tower Apartemen*

- Menampilkan daftar tower (*Verlynn Park Tower, Sunset Beach Tower, MaxOne Building*), kota lokasi, dan jumlah unit hunian aktif yang siap disewakan.

![Modal Tambah Gedung](website/28-master-gedung-add-modal.png)
*Gambar 3.27: Modal Pendaftaran Gedung Baru & Penugasan Host Pengelola*

- Klik **"+ Add Gedung"**, masukkan nama gedung (*Tower Cattleya Bassura City*), pilih kota induk, pilih mitra Host penanggung jawab gedung, tentukan kuota unit, unggah foto tampak depan gedung, lalu klik **Submit**.

![Modal Edit Gedung](website/29-master-gedung-edit-modal.png)
*Gambar 3.28: Modal Edit Gedung & Penyesuaian Unit Tersedia*

- Digunakan untuk memperbarui data pengelola gedung atau menambah/mengurangi alokasi unit kamar yang tersedia di gedung tersebut.

---

## BAB 4: KURASI KONTEN BERANDA & ANALISIS PENCARIAN

### 4.1 Mengatur Rekomendasi Akomodasi Pilihan Beranda

Menu Rekomendasi mengontrol properti mana saja yang dipromosikan di halaman utama aplikasi mobile tamu:

![Tabel Rekomendasi Akomodasi](website/30-rekomendasi-akomodasi-table.png)
*Gambar 4.1: Tabel Kurasi Rekomendasi Akomodasi Beranda Mobile*

- Menampilkan daftar akomodasi terpilih, badge kategori (*Best Seller, Terbaru, Premium, Berbasis POI*), dan angka prioritas urutan tampil.

![Modal Tambah Rekomendasi](website/31-rekomendasi-akomodasi-add-modal.png)
*Gambar 4.2: Modal Tambah Properti ke Daftar Rekomendasi Beranda*

- Klik **"+ Add Rekomendasi"**, pilih properti dari daftar dropdown, pilih tipe rekomendasi (*Best Seller / Premium*), tentukan angka prioritas (angka 1 tampil paling awal), lalu klik **Submit**.

![Modal Edit Rekomendasi](website/32-rekomendasi-akomodasi-edit-modal.png)
*Gambar 4.3: Modal Edit Prioritas Rekomendasi Akomodasi*

- Memungkinkan admin menaikkan atau menurunkan prioritas kurasi properti menjelang musim liburan atau kampanye promosi tertentu.

---

### 4.2 Memantau Log Pencarian Tamu & Analisis Tren Pasar

Menu Log Pencarian merekam aktivitas pencarian yang dilakukan pengguna aplikasi mobile secara transparan:

![Tabel Log Pencarian Akomodasi](website/33-log-pencarian-akomodasi-table.png)
*Gambar 4.4: Tabel Log Penelusuran Tamu, Kata Kunci & Filter Harga*

- **Pemanfaatan Data:** Staf pemasaran dapat memantau kata kunci yang paling sering dicari, wilayah kota paling populer (*Jakarta Pusat, Jakarta Barat*), dan rentang harga favorit konsumen untuk merancang promo diskon yang tepat sasaran.

---

### 4.3 Mengelola Banner Promosi & Slider Kampanye Iklan

Menu Banner mengelola gambar promosi geser (*carousel slider*) di bagian atas aplikasi mobile:

![Tabel Banner Iklan](website/34-banner-iklan-table.png)
*Gambar 4.5: Tabel Manajemen Banner Promosi & Iklan Aplikasi*

- Menampilkan judul promosi (*Promo Liburan Akhir Tahun, Event Musim Panas Bali*), tautan target tujuan (*URL*), kota penayangan, dan tanggal mulai tayang banner. Klik **"+ Add Banner & Iklan"** untuk memasang materi promosi baru.

---

## BAB 5: MANAJEMEN RESERVASI, PEMESANAN & BILLING ORDER

### 5.1 Memantau Tabel Reservasi Booking Tamu

Menu Booking adalah pusat kendali operasional pemesanan menginap harian:

![Tabel Manajemen Booking](website/35-manajemen-booking-table.png)
*Gambar 5.1: Tabel Manajemen Reservasi Pemesanan Tamu (Booking Control Desk)*

- **Informasi Kolom:** Kode Booking unik (*HTL-20260904-YE7K, BK-2026-0001*), nama properti, nama penyewa (*Dewi Consumer, Andi Consumer*), tanggal check-in dan check-out, serta tipe durasi sewa (*daily / monthly*).
- Gunakan kolom pencarian di atas tabel untuk mencari pesanan dengan cepat saat tamu tiba di lokasi resepsionis.

---

### 5.2 Rincian Pemesanan, Status Staying & Cetak Invoice PDF

Layar Rincian Pemesanan menyajikan lembar tagihan resmi yang diterbitkan Livirooms:

![Layar Detail Booking dan Invoice](website/36-booking-detail-invoice.png)
*Gambar 5.2: Layar Rincian Pemesanan, Status Menginap Aktif (Staying) & Tombol Unduh Invoice PDF*

**Fitur & Prosedur Operasional:**
1. **Status Badge Hijau (STAYING):** Menunjukkan bahwa tamu telah menyelesaikan proses check-in fisik dan sedang aktif menempati kamar.
2. **Identitas Penyewa:** Email resmi tamu (*mohbaswandegorie@gmail.com*) dan nomor telepon kontak.
3. **Mencetak Tagihan:** Klik tombol biru **"Download Invoice PDF"** untuk mengunduh dokumen penagihan resmi siap cetak untuk diserahkan ke tamu atau arsip keuangan.

---

### 5.3 Manajemen Order Penagihan Satelit

Menu Order mengelola pesanan penagihan transaksi sewa dan biaya tambahan:

![Tabel Manajemen Order](website/37-manajemen-order-table.png)
*Gambar 5.3: Tabel Manajemen Order Penagihan Transaksi*

- Menampilkan relasi antara kode order penagihan (*ORD-YSEFOM19, ORD-2026-0001*) dengan kode booking menginap dan total nominal rupiah yang wajib diselesaikan konsumen.

---

## BAB 6: TRANSAKSI PEMBAYARAN, SALURAN & INTEGRASI GATEWAY MIDTRANS

### 6.1 Memantau Riwayat Transaksi Pembayaran Gateway

Menu Pembayaran mencatat seluruh lalu lintas penerimaan uang dari payment gateway:

![Tabel Riwayat Pembayaran Gateway](website/38-pembayaran-transaksi-table.png)
*Gambar 6.1: Tabel Riwayat Transaksi Pembayaran Gateway*

- Menampilkan kode order, nomor referensi transaksi perbankan (*TRX-VORD8W07KA*), nominal bayar, dan waktu penyelesaian transaksi.

![Modal Tambah Pembayaran Gateway](website/39-pembayaran-transaksi-add-modal.png)
*Gambar 6.2: Modal Pencatatan Pembayaran Gateway Manual*

- Digunakan jika ada transaksi offline tunai yang perlu dicatatkan manual ke dalam sistem pembukuan.

![Modal Edit Pembayaran Gateway](website/40-pembayaran-transaksi-edit-modal.png)
*Gambar 6.3: Modal Koreksi & Rekonsiliasi Transaksi Pembayaran*

- Digunakan untuk koreksi nomor referensi perbankan saat proses rekonsiliasi kas bulanan.

---

### 6.2 Mengelola Master Saluran Pembayaran (VA, QRIS, E-Wallet, Kartu Kredit)

Menu Metode Pembayaran mengelola katalog saluran bayar yang aktif di aplikasi:

![Tabel Master Metode Pembayaran](website/41-metode-pembayaran-table.png)
*Gambar 6.4: Tabel Saluran Pembayaran Resmi Livirooms*

- Mengontrol saluran *Virtual Account, QRIS, PayLater, E-Wallet, dan Kartu Kredit*.

![Modal Tambah Metode Pembayaran](website/42-metode-pembayaran-add-modal.png)
*Gambar 6.5: Modal Pendaftaran Saluran Pembayaran Baru*

- Digunakan untuk mendaftarkan saluran pembayaran perbankan baru beserta biaya administrasi penanganan transaksi (*fee*).

![Modal Edit Metode Pembayaran](website/43-metode-pembayaran-edit-modal.png)
*Gambar 6.6: Modal Pengaturan Saluran Pembayaran Virtual Account*

- Memungkinkan admin memperbarui logo bank atau mengubah besaran biaya penanganan saluran bayar.

---

### 6.3 Mengatur Kredensial & Saluran Pembayaran Gateway Midtrans

Livirooms terintegrasi secara *native* dengan gerbang pembayaran **Midtrans**:

![Pengaturan Kunci API Midtrans](website/44-pengaturan-midtrans-keys.png)
*Gambar 6.7: Layar Konfigurasi Kunci API Midtrans Server Key, Client Key & Mode Produksi*

1. **Pengaturan Kredensial API:**
   - **Server Key:** Kunci rahasia backend dari dashboard Midtrans.
   - **Client Key:** Kunci publik frontend untuk aplikasi mobile Flutter.
   - **Production Mode:** Sakelar switch untuk berpindah antara lingkungan uji coba (*Sandbox*) dan lingkungan transaksi komersial langsung (*Live*).
   - **Identitas Merchant:** Nama Usaha (*Livirooms*), Email Dukungan, dan Nomor Telepon Operasional.

![Pengaturan Kanal Midtrans](website/45-pengaturan-midtrans-channels.png)
*Gambar 6.8: Sakelar Aktivasi Kanal Pembayaran Midtrans & Tombol Simpan Konfigurasi*

2. **Aktivasi Saluran Bayar Midtrans:**
   - Cukup geser sakelar toggle untuk mengaktifkan saluran bayar yang diinginkan (*Virtual Account, QRIS, E-Wallet, Kartu Kredit, PayLater*).
   - Klik tombol biru **"Simpan Konfigurasi"** untuk langsung menerapkan perubahan ke aplikasi mobile secara instan.

---

## BAB 7: MANAJEMEN KEUANGAN MITRA & PENARIKAN SALDO HOST

### 7.1 Memantau Antrean Pengajuan Penarikan Saldo (Withdrawal)

Pemilik properti (*Host*) dapat mengajukan pencairan pendapatan sewa melalui aplikasi mobile mereka. Bagian Finance mengawasi permohonan tersebut pada menu Withdrawal:

![Tabel Manajemen Withdrawal Host](website/46-manajemen-withdrawal-table.png)
*Gambar 7.1: Tabel Antrean Pengajuan Penarikan Saldo Mitra Host*

- Menampilkan nama host, nama bank tujuan (*BCA, Mandiri, BRI*), nomor rekening, nama pemilik rekening, nominal permohonan pencairan dana, dan status verifikasi (*Pending, Approved, Rejected*).

---

### 7.2 Memproses Transfer Perbankan & Persetujuan Pencairan Dana

![Modal Tambah dan Proses Withdrawal](website/47-manajemen-withdrawal-add-modal.png)
*Gambar 7.2: Modal Pemrosesan & Persetujuan Pencairan Dana Host*

**Langkah Operasional Tim Finance:**
1. Periksa pengajuan yang berstatus *Pending*, cocokkan nomor rekening dan pastikan saldo dompet host mencukupi.
2. Lakukan transfer bank ke rekening host melalui internet banking korporat.
3. Buka modal pengajuan, ubah status menjadi **Approved**, catat tanggal transfer berhasil, lalu klik **Submit**.
4. Saldo dompet host otomatis terpotong dan notifikasi berhasil otomatis masuk ke ponsel host.

---

## BAB 8: PROGRAM MARKETING, KUPON DISKON & REFERRAL

### 8.1 Mengelola Kupon Promo & Voucher Diskon Konsumen

Menu Voucher mengelola pembuatan kupon potongan harga untuk mendorong volume transaksi:

![Tabel Manajemen Promo dan Voucher](website/48-manajemen-voucher-promo-table.png)
*Gambar 8.1: Tabel Manajemen Kupon Promo & Voucher Diskon*

- Menampilkan daftar kupon aktif (*STAYCATION50K, HOTWEEK10, FLASH25, AGD30*), jenis potongan (*cashback, percentage %, nominal Rupiah*), nilai diskon, masa berlaku, dan batas penggunaan.

![Modal Tambah Promo Voucher](website/49-manajemen-voucher-promo-add-modal.png)
*Gambar 8.2: Modal Pembuatan Kupon Promo Baru*

- Klik **"+ Add Manajemen Promo & Voucher"**, masukkan kode voucher unik, judul promo, tipe potongan, nilai diskon, kategori promo, tanggal mulai dan berakhir, batas kuota penggunaan, aktifkan sakelar status, lalu klik **Submit**.

![Modal Edit Promo Voucher](website/50-manajemen-voucher-promo-edit-modal.png)
*Gambar 8.3: Modal Edit Kupon Promo Berjalan*

- Memungkinkan admin memperpanjang tanggal kedaluwarsa kupon atau menambah kuota klaim bagi konsumen.

---

### 8.2 Memantau Program Rujukan Pengguna (Referral System)

Menu Referral melacak efektivitas program rujukan kode ajak teman (*member-get-member*):

![Tabel Referral System](website/51-referral-system-table.png)
*Gambar 8.4: Tabel Pelacakan Program Rujukan Referral Pengguna*

- Menampilkan akun pemberi rujukan (*Referrer*), kode referral unik (*REF-BUDI-2*), dan besaran bonus reward yang berhak diterima pengundang.

![Modal Edit Referral System](website/52-referral-system-edit-modal.png)
*Gambar 8.5: Modal Verifikasi & Persetujuan Reward Referral*

- Staf memeriksa apakah teman yang diundang telah berhasil menyelesaikan reservasi pertamanya sebelum mengubah status menjadi *Approved* untuk mencairkan bonus reward.

---

## BAB 9: MANAJEMEN REPUTASI, BANTUAN & KONTEN LEGAL

### 9.1 Memantau & Memberikan Balasan Ulasan Tamu (Review & Rating)

Menu Review mengelola transparansi penilaian dan ulasan pengalaman menginap tamu:

![Tabel Review dan Rating Tamu](website/53-review-rating-table.png)
*Gambar 9.1: Tabel Moderasi Ulasan & Penilaian Tamu*

- Menampilkan nama akomodasi yang dinilai, skor bintang kepuasan, komentar testimoni tamu, dan kolom balasan resmi host (*Host Reply*).

![Modal Tambah Review Tamu](website/54-review-rating-add-modal.png)
*Gambar 9.2: Modal Entri Ulasan Tamu Manual*

- Digunakan untuk mencatatkan formulir survei kepuasan offline ke dalam data sistem.

![Modal Edit Review dan Balasan Host](website/55-review-rating-edit-modal.png)
*Gambar 9.3: Modal Penulisan Tanggapan Resmi Host terhadap Ulasan Tamu*

- Staf atau host menuliskan kalimat apresiasi terima kasih atau klarifikasi atas keluhan tamu pada kolom *Host Reply* agar terlihat profesional di aplikasi mobile.

---

### 9.2 Mengelola Pusat Bantuan & Tanya Jawab Pengguna (FAQ)

Menu FAQ mengelola panduan mandiri yang tampil pada menu Bantuan di aplikasi mobile:

![Tabel FAQ Pusat Bantuan](website/56-faq-help-center-table.png)
*Gambar 9.4: Tabel Manajemen Tanya Jawab FAQ Pusat Bantuan*

- Menampilkan kategori kendala (*Pemesanan, Pembayaran, Pembatalan, Lainnya*), kalimat pertanyaan, urutan tampil, dan status terbit.

![Modal Tambah FAQ](website/57-faq-help-center-add-modal.png)
*Gambar 9.5: Modal Penambahan Butir Tanya Jawab Bantuan Baru*

- Klik **"+ Add FAQ & Help Center"**, pilih kategori, ketik kalimat pertanyaan umum, tuliskan solusi jawaban yang jelas dan ramah, atur nomor urutan, aktifkan sakelar terbit, lalu klik **Submit**.

![Modal Edit FAQ](website/58-faq-help-center-edit-modal.png)
*Gambar 9.6: Modal Pengubahan Jawaban Bantuan FAQ Operasional*

- Memperbarui penjelasan kontak layanan pelanggan atau tata cara penanganan kendala tamu terbaru.

---

### 9.3 Mengelola Dokumen Legal Halaman Konten Statis (CMS Page)

Menu CMS Halaman mengelola dokumen hukum resmi platform tanpa perlu bantuan programmer:

![Tabel CMS Halaman Statis](website/59-cms-halaman-table.png)
*Gambar 9.7: Tabel Manajemen Dokumen Statis CMS (Terms, Privacy, About)*

- Menampilkan slug alamat web (*tentang-kami, syarat-ketentuan, kebijakan-privasi*), judul halaman, dan status publikasi.

![Modal Edit Halaman CMS](website/60-cms-halaman-edit-modal.png)
*Gambar 9.8: Modal Editor Teks Paragraf Dokumen Syarat & Ketentuan*

- Memungkinkan admin memperbarui pasal-pasal perjanjian sewa, ketentuan ganti rugi, atau kebijakan privasi perlindungan data pengguna dengan mudah.

---

## BAB 10: KOMUNIKASI CHAT & PEMANTAUAN MINAT PELANGGAN

### 10.1 Memantau Pesan Percakapan Chat Tamu dan Host

Menu Manajemen Chat memantau percakapan langsung antara calon penyewa dengan pihak pemilik properti:

![Tabel Manajemen Chat](website/61-manajemen-chat-table.png)
*Gambar 10.1: Tabel Pemantauan Percakapan Chat Tamu dan Host*

- Menampilkan nama pengirim, penerima obrolan, akomodasi yang ditanyakan, cuplikan pesan terakhir, dan timestamp waktu kirim.
- Membantu tim Customer Support memonitor kualitas pelayanan host dan mencegah upaya transaksi di luar sistem (*bypass komisi*).

---

### 10.2 Menganalisis Minat Properti Favorit Konsumen (Wishlist)

Menu Wishlist mencatat daftar listing properti yang disimpan ke daftar keinginan oleh pengguna aplikasi mobile:

![Tabel Pemantauan Wishlist](website/62-manajemen-wishlist-table.png)
*Gambar 10.2: Tabel Analisis Minat Properti Favorit Konsumen (Wishlist)*

- Menampilkan akun pengguna yang menandai properti sebagai favorit beserta tanggal penyimpanan.
- Membantu tim bisnis mengevaluasi properti yang diminati banyak calon tamu guna menentukan strategi promo penawaran khusus.

---

## PUSAT BANTUAN & KONTAK LAYANAN OPERASIONAL

- **Kantor Pusat Operasional:** Livirooms Tower, Lantai 12, Jl. Casablanca Kav. 88, Jakarta Selatan 12870.
- **WhatsApp Dukungan Internal Staf:** +62 812-3456-7890
- **Email Administrator Sistem:** admin@livirooms.com
