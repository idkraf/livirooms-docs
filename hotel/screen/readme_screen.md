# 📱 Hotel Screen Documentation

Dokumentasi lengkap semua screen pada fitur Hotel — dianalisis dari mockup gambar nyata (Trip.com style).

---

## 🗂️ Screen Registry & Urutan Build

| ID | Nama Screen | File Gambar | Folder |
|----|------------|-------------|--------|
| `filter_location` | Filter Lokasi / Cari Destinasi | `filter_hotel (folder)/sheet_modal_bottom_full_screen/filter_by_location_screen.jpeg` | `screen/filter_hotel (folder)/sheet_modal_bottom_full_screen/` |
| `filter_screen` | Filter Utama (Home Search) | `filter_hotel (folder)/filter_screen.jpeg` | `screen/filter_hotel (folder)/` |
| `filter_kamar_tamu` | Filter Kamar & Tamu | `filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/filter_kamar_dan_tamu_screen.jpeg` | `screen/filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/` |
| `filter_kamar_tamu_bottom_modal_select_anak` | Filter Kamar & Tamu — Bottom Modal Pilih Anak | `filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/show_modal_bottom/select_umur_anak.jpeg` | `screen/filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/show_modal_bottom/` |
| `filter_kalendar_screen` | Filter Kalender (2-Tab: Kalender + Tanggal Fleksibel) | Tab 1: `filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_kalendar_screen.jpeg` · Tab 2: `filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_tanggal_flexibel_screen.jpeg` | `screen/filter_hotel (folder)/filter_kalendar_screen (new screen)/` |
| `result_pencarian` | Hasil Pencarian Hotel | `result_filter_hotel (folder)/result_pencarian_hotel_screen.jpeg` | `screen/result_filter_hotel (folder)/` |
| `result_pencarian_bottom_modal_filter` | Hasil Pencarian Hotel — Bottom Modal Filter | `result_filter_hotel (folder)/sheet_modal_bottom/filter_widget.jpeg` | `screen/result_filter_hotel (folder)/sheet_modal_bottom/` |
| `result_pencarian_bottom_modal_filter_kebutuhan` | Hasil Pencarian Hotel — Bottom Modal Filter Kebutuhan | `result_filter_hotel (folder)/sheet_modal_bottom/filter_kebutuhan_widget.jpeg` | `screen/result_filter_hotel (folder)/sheet_modal_bottom/` |
| `result_pencarian_bottom_modal_filter_urutkan` | Hasil Pencarian Hotel — Bottom Modal Filter Urutkan | `result_filter_hotel (folder)/sheet_modal_bottom/filter_urutkan_widget.jpeg` | `screen/result_filter_hotel (folder)/sheet_modal_bottom/` |
| `result_pencarian_bottom_modal_filter_lokasi` | Hasil Pencarian Hotel — Bottom Modal Filter Lokasi | `result_filter_hotel (folder)/sheet_modal_bottom_full_screen/result_pencarian_hotel_screen_bottom_modal_filter_lokasi.jpeg` | `screen/result_filter_hotel (folder)/sheet_modal_bottom_full_screen/` |
| `result_pencarian_top_modal_filter_date_and_tamu` | Hasil Pencarian Hotel — Top Modal Filter Date & Tamu (`top_modal_sheet` dependency) | `result_filter_hotel (folder)/sheet_modal_top/sheet_modal_top_widget.jpeg` | `screen/result_filter_hotel (folder)/sheet_modal_top/` |
| `result_pencarian_top_modal_filter_date_and_tamu_kalendar` | Hasil Pencarian Hotel — Screen Filter Kalender (2-Tab) | `result_filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_kalendar_screen.jpeg` | `screen/result_filter_hotel (folder)/filter_kalendar_screen (new screen)/` |
| `result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel` | Hasil Pencarian Hotel — Screen Filter Tanggal Fleksibel (2-Tab) | `result_filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_tanggal_flexibel_screen.jpeg` | `screen/result_filter_hotel (folder)/filter_kalendar_screen (new screen)/` |
| `result_pencarian_top_modal_filter_date_and_tamu_2nd` | Hasil Pencarian Hotel — Top Modal Filter Date & Tamu (2nd) | `result_filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/filter_kamar_dan_tamu_screen.jpeg` | `screen/result_filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/` |
| `result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak` | Hasil Pencarian Hotel — Top Modal ke Bottom Modal Select Anak | `result_filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/show_modal_bottom/select_umur_anak.jpeg` | `screen/result_filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/show_modal_bottom/` |
| `detail_hotel` | Detail Hotel (Scroll awal) | `detail_hotel (folder)/detail_hotel_screen.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_kamar` | Tab Kamar | `detail_hotel (folder)/detail_hotel_screen_tab_kamar.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_ulasan` | Tab Ulasan / Pertanyaan Umum | `detail_hotel (folder)/detail_hotel_screen_tab_ulasan.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_lokasi` | Tab Lokasi | `detail_hotel (folder)/detail_hotel_screen_tab_lokasi.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_fasilitas` | Tab Fasilitas | `detail_hotel (folder)/detail_hotel_screen_tab_fasilitas.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_kebijakan` | Tab Kebijakan | `detail_hotel (folder)/detail_hotel_screen_tab_kebijakan.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_keterangan` | Tab Keterangan | `detail_hotel (folder)/detail_hotel_screen_tab_keterangan.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_trip_moments` | Tab Trip Moments | `detail_hotel (folder)/detail_hotel_screen_tab_trip_moments.jpeg` | `screen/detail_hotel (folder)/` |
| `detail_tab_akomodasi_terdekat` | Tab Akomodasi Terdekat | `detail_hotel (folder)/detail_hotel_screen_tab_akomodasi_terdekat.jpeg` | `screen/detail_hotel (folder)/` |
| `pesan_kamar_section` | Pilih Kamar (scroll ke bawah di detail) | `detail_hotel (folder)/sheet_modal_button_pesan_kamar/detail_hotel_screen_saat_mau_pilih_button_pesan_kamar.jpeg` | `screen/detail_hotel (folder)/sheet_modal_button_pesan_kamar/` |
| `sheet_pesan_kamar` | Ringkasan Pemesanan | `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/` |
| `form_pengisian_kamar` | Form Data Tamu | `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_form_pengisian_kamar.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/` |
| `form_pengisian_kamar_scroll` | Form Data Tamu — scroll bawah | `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_form_pengisian_kamar_scroll.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/` |
| `form_pesan_kamar_step1` | Form Data Tamu — Multi-room (Kamar 1 & 2) | `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_1.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/` |
| `form_pesan_kamar_step2` | Diskon & Benefit (Kode Promo, Trip Coins, Permintaan Khusus) | `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_2.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/` |
| `form_pesan_kamar_step3` | Informasi Tambahan & T&C | `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_3.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/` |
| `bottom_sheet_informasi_tambahan` | Informasi Tambahan (Kebijakan Deposit) | `detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom/bottom_sheet_informasi_tambahan.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom/` |
| `room_detail_family_suite` | Detail Kamar Family Suite | `detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/tab_family_suite/` (1-4) | `screen/detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/tab_family_suite/` |
| `room_detail_kamar_superior` | Detail Kamar Superior | `detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/tab_kamar_superior/` (1-4) | `screen/detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/tab_kamar_superior/` |
| `bottom_sheet_kode_promo` | Kode Promo | `detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_sheet_kode_promo/bottom_sheet_kode_promo.jpeg` | `screen/detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_sheet_kode_promo/` |
| `bottom_sheet_permintaan` | Permintaan Khusus | `detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_sheet_permintaan/` (1-2) | `screen/detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_sheet_permintaan/` |
| `booking_list_screen` | Daftar Pemesanan Saya | `booking/semua_pemesanan_screen.jpeg` | `screen/booking/` |
| `booking_pembayaran_screen` | Pembayaran | `booking/pembayaran_screen.jpeg` | `screen/booking/` |
| `booking_hotel_detail_screen` | Detail Pemesanan Hotel (scroll 1-5) | `booking/booking_hotel_detail_screen/01_menunggu_pembayaran_scroll.jpeg` · `02_lokasi_fasilitas_kebijakan_scroll.jpeg` · `03_detail_kamar_tamu_scroll.jpeg` · `04_reward_benefit_scroll.jpeg` · `05_konfirmasi_pemesanan_scroll.jpeg` | `screen/booking/booking_hotel_detail_screen/` |

---

## 📋 Analisis Detail Per Screen

---

### 1. `filter_location` — Filter Lokasi / Cari Destinasi

**File:** `filter_hotel (folder)/sheet_modal_bottom_full_screen/filter_by_location_screen.jpeg`

**Layout:**
- Topbar: `[X]` + Search bar aktif _"Destinasi atau akomodasi"_ (outlined biru)
- Row `📍 Lokasi Saat Ini` (teks biru)
- Divider
- Section **Pencarian Terakhir** (kanan: link "Hapus" biru)
  - Row: `🕐 Kelapa Dua` + subtitle `15 Agt–16 Agt | 2 dewasa` + chevron kanan
- Divider
- Section **Destinasi Populer**
  - Grid 2 kolom (3 baris) berisi gambar destinasi + label nama kota:
    - Bali · Jakarta Pusat · Jakarta Selatan · Kuala Lumpur · Yogyakarta · Kecamatan Depok

---

### 2. `filter_screen` — Halaman Pencarian Hotel (Home Search)

**File:** `filter_hotel (folder)/filter_screen.jpeg`

**Layout:**
- Hero image latar sunset/villa (full-width)
- Topbar overlay: `[←]` · avatar "T" · `[⋯]`
- Judul besar putih: **"Hotel & Rumah Liburan"**
- Card putih search panel (floating, rounded):
  - Row 1: `🔍 Jakarta Pusat, Indonesia` (+ tombol ×)
  - Divider
  - Row 2: `📅 Sab, 15 Agt – Min, 16 Agt` · `1 malam`
  - Divider
  - Row 3: `👤 2 kamar · 5 dewasa · 2 anak`
  - Divider
  - Filter chips scrollable: `Filter` · `Termasuk Sarapan` · `4 Bintang` · `Kolam re...`
  - Button biru full-width: **"Cari"**
- Section shortcut (4 ikon lingkaran): Disimpan · Pemesanan · Promo saya · Dilihat
- Card rekomendasi: **"Pesan Akomodasi Ini"** [X] dengan hotel image + nama + tipe kamar + tanggal + harga

---

### 3. `filter_kamar_tamu` — Filter Kamar & Tamu

**File:** `filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/filter_kamar_dan_tamu_screen.jpeg`

**Layout:**
- Topbar: `[←]` · Judul **"Kamar dan Tamu"**
- Divider
- Stepper rows (label kiri, counter kanan):
  - `Kamar` · `[-] 1 [+]` (minus abu/disabled, plus biru)
  - `Dewasa` · `[−] 2 [+]`
  - `Anak` · `[−] 2 [+]`
- Section abu-abu: _"Usia anak pada saat check-in"_
  - `Anak 1` · `<1 tahun ›`
  - `Anak 2` · `4 tahun ›`
- Info box abu-abu muda (bullet):
  - Harap konfirmasi jumlah anak dan usianya…
  - Jika ada lebih banyak tamu, pertimbangkan menambah kamar
- Button biru full-width bottom: **"Selesai"**

---

### 4. `filter_kamar_tamu_bottom_modal_select_anak` — Bottom Modal Pilih Anak

**File:** `filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/show_modal_bottom/select_umur_anak.jpeg`

**Layout:**
- Bottom modal sheet untuk memilih usia anak
- Header: `[←]  Kamar dan Tamu`
- List anak dengan dropdown usia:
  - `Anak 1` · `<1 tahun ›`
  - `Anak 2` · `4 tahun ›`
- Info box abu-abu muda tentang konfirmasi jumlah anak
- Button biru: **"Selesai"**

---

### 5. `filter_kalendar_screen` — Filter Kalender (2-Tab: Kalender + Tanggal Fleksibel)

**Folder:** `filter_hotel (folder)/filter_kalendar_screen (new screen)/`

---

#### Tab 1: Kalender

**File:** `filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_kalendar_screen.jpeg`

**Layout:**
- Topbar: `[←]` · Judul **"Pilih Tanggal"**
- Divider
- Calendar grid dengan hari Sen-Min
- Tanggal terpilih: **15 Agt – 16 Agt** (highlight biru bulat)
- Button biru full-width bottom: **"Selesai"**

---

#### Tab 2: Tanggal Fleksibel

**File:** `filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_tanggal_flexibel_screen.jpeg`

**Layout:**
- Top tab bar: `Kalender` · `Tanggal Fleksibel` (aktif, biru underline)
- Section **Durasi menginap**: grid 4 kolom chip (`1 malam` terpilih, `2 malam` – `7 malam`)
- Checkboxes: `Termasuk hari Jumat` · `Termasuk hari Sabtu`
- Section **Bulan**: 4 kartu bulan (`Agt`, `Sep`, `Okt` terpilih dengan border biru + icon check; `Nov` tidak terpilih dengan icon kalender)
- Summary: `1 malam antara Agt dan Okt`
- Button biru full-width: **"Konfirmasi (1 malam)"**

---

### 6. `result_pencarian` — Hasil Pencarian Hotel

**File:** `result_filter_hotel (folder)/result_pencarian_hotel_screen.jpeg`

**Layout:**
- Topbar search bar:
  - `[←]` · Badge tanggal `15 Agt / 16 Agt [∨]` · teks kota `Jakarta Pusat, Indonesia` · icon IDR (kanan)
- Filter chips horizontal: `↑↓ Urutkan` · `⇌ Filter` · `📍 Lokasi` · `👤 Kebutuhan...`
- Promo banner: `[%] Diskon hingga Rp393.750 — Promo Homestay Unggulan [›]`
- Label: **"975 akomodasi ditemukan"**
- List card hotel (vertical scroll):

  **Card 1 — Grand Cemara Hotel ⭐⭐⭐**
  - Gambar hotel (kiri, ~130px lebar) + tombol `♡` overlay
  - `8,1/10` badge biru · _Luar Biasa_ · 371 ulasan
  - 800m dari pusat kota
  - Tags hijau: _Kamar Keluarga_ · _Aktivitas untuk anak_
  - "1.549 orang menambahkan ke favorit"
  - Harga: ~~Rp541.790~~ **Rp446.637**
  - Total: **Rp1.089.796** (2 kamar × 1 malam termasuk pajak)
  - Badge pink: _Diskon Spesial_

  **Card 2 — Amaris Hotel Pasar Baru ⭐⭐**
  - `7,4/10` badge biru · 26 ulasan
  - 2,4km dari pusat kota
  - Tags hijau: _Termasuk sarapan_ · _Disukai keluarga_ · _Lokasi strategis_
  - "188 orang menambahkan ke favorit"
  - Harga: **Rp337.795**

- Floating bottom bar: `📍 Peta | ♡ Disimpan`

---

### 7. `result_pencarian_bottom_modal_filter` — Bottom Modal Filter

**File:** `result_filter_hotel (folder)/sheet_modal_bottom/filter_widget.jpeg`

**Layout:**
- Panel `Filter` sebagai bottom modal sheet:
  - Handle bar di atas
  - Header: `Filter` · `[X]`
  - Section **Harga (untuk 1 malam)** dengan range slider
  - Section **Bintang** checkbox list: ⭐⭐⭐⭐⭐ · ⭐⭐⭐⭐ · ⭐⭐⭐ · ⭐⭐
  - Button: **"Lihat Hasil (900+)"**

---

### 8. `result_pencarian_bottom_modal_filter_kebutuhan` — Bottom Modal Filter Kebutuhan

**File:** `result_filter_hotel (folder)/sheet_modal_bottom/filter_kebutuhan_widget.jpeg`

**Layout:**
- Panel `Kebutuhan` sebagai bottom modal sheet:
  - Handle bar + header `Kebutuhan` · `[X]`
  - Grid 2 kolom chip: `Termasuk sarapan` (checked), `Kolam renang` (checked), `Parkir gratis`, `Wi-Fi gratis`, `Spa`, `Pusat kebugaran`, `Restoran`, `Bar lobi`

---

### 9. `result_pencarian_bottom_modal_filter_urutkan` — Bottom Modal Urutkan

**File:** `result_filter_hotel (folder)/sheet_modal_bottom/filter_urutkan_widget.jpeg`

**Layout:**
- Panel `Urutkan` sebagai bottom modal sheet:
  - Handle bar + header `Urutkan` · `[X]`
  - Radio options: `Rekomendasi` (aktif), `Harga terendah`, `Rating tertinggi`, `Jarak terdekat`

---

### 10. `result_pencarian_bottom_modal_filter_lokasi` — Bottom Modal Filter Lokasi

**File:** `result_filter_hotel (folder)/sheet_modal_bottom_full_screen/result_pencarian_hotel_screen_bottom_modal_filter_lokasi.jpeg`

**Layout:**
- Panel `Filter Lokasi` sebagai bottom modal sheet:
  - Handle bar + header `Filter Lokasi` · `[X]`
  - Search field: `Cari lokasi`
  - Section `Populer`: `Jakarta Pusat`, `Jakarta Selatan`, `Bali`, `Kuala Lumpur`, `Yogyakarta`

---

### 11. `result_pencarian_top_modal_filter_date_and_tamu` — Top Modal Filter Date & Tamu (2-Columns, menggunakan `top_modal_sheet`)

**File:** `result_filter_hotel (folder)/sheet_modal_top/sheet_modal_top_widget.jpeg`

**Flutter Dependency:**
- `top_modal_sheet: ^2.1.0` — digunakan untuk menampilkan top modal sheet yang slide dari bagian atas layar.

**Top-level have 2 columns:**
- **Column 1: Kalender / Tanggal** → `result_pencarian_top_modal_filter_date_and_tamu_kalendar` (full screen, 2-tab: Kalender + Tanggal Fleksibel)
  - Tap pada field tanggal di top modal akan membuka full-screen Kalender/Tanggal Fleksibel
- **Column 2: Kamar & Tamu** → `result_pencarian_top_modal_filter_date_and_tamu_2nd` (full screen stepper)
  - Tap pada field kamar/tamu di top modal akan membuka full-screen Kamar & Tamu
  - Tap pada dropdown usia anak akan membuka bottom modal `result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak`

**Action:**
- Button biru **"Cari"** di bagian bawah top modal akan mengirim request ke **Laravel API** untuk menjalankan filter berdasarkan kriteria yang dipilih (tanggal, kamar, tamu).

---

#### Columns 1 → `result_pencarian_top_modal_filter_date_and_tamu_kalendar` — Full Screen Kalender (2-Tab)

**File:** `result_filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_kalendar_screen.jpeg`


---

##### Column 1 → `result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel` — Full Screen Tanggal Fleksibel (2-Tab)

**File:** `result_filter_hotel (folder)/filter_kalendar_screen (new screen)/filter_by_tab_tanggal_flexibel_screen.jpeg`
---

#### Columns 2 → `result_pencarian_top_modal_filter_date_and_tamu_2nd` — Full Screen Kamar & Tamu

**File:** `result_filter_hotel (folder)/filter_kamar_dan_tamu_screen (new screen)/filter_kamar_dan_tamu_screen.jpeg`

**Layout:**
- Stepper rows (label kiri, counter kanan):
  - `Dewasa` · `[−] 2 [+]`
  - `Anak` · `[−] 2 [+]`
- Section abu-abu: _"Usia anak pada saat check-in"_
  - `Anak 1` · `<1 tahun ›`
  - `Anak 2` · `4 tahun ›`
- Info box abu-abu muda tentang konfirmasi jumlah anak
- Button biru full-width bottom: **"Selesai"**

---

### 16. `detail_hotel` — Detail Hotel (Scroll Awal)

**File:** `detail_hotel (folder)/detail_hotel_screen.jpeg`

**Layout:**
- **Hero Image** full-width (~220px): foto gedung Grand Cemara Hotel
  - Overlay kiri-atas: `[←]` putih bulat
  - Overlay kanan-atas: `♡ [share]` putih bulat
  - Badge kanan-bawah: `📷 1/43`
- **Content scroll:**
  - **"Grand Cemara Hotel"** (H1 bold 22px)
  - `⭐⭐⭐` · _Dibuka tahun 1994_
  - Alamat lengkap + Link biru **"Lihat di Peta"**
  - Divider
  - `8,1/10` badge biru · **_Luar Biasa_** · `371 ulasan`
  - Kutipan: _"Berlokasi di pusat kota" "Harga sesuai kualitas"_
  - Divider
  - **Fasilitas untuk Keluarga 🧡** (2 kolom):
    - 🏠 Kamar Keluarga · 😊 Aktivitas untuk anak
    - 🏠 Suite · 📍 Lokasi strategis
  - **Lokasi Strategis** (list dengan jarak):
    - 🏢 Area komersial: Thamrin — 2,2km
    - 🚉 Stasiun kereta api: Gondangdia — 480m
    - 🏔️ Atraksi wisata: Masjid Cut Meutia — 420m
- **Bottom Bar Sticky:**
  - Kiri: **Rp446.637** (bold biru) · ~~Rp541.790~~ (coret merah)
  - Kanan: Button biru **"Pilih kamar"**

---

### 17. `detail_tab_kamar` — Tab Kamar

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_kamar.jpeg`

**Layout:**
- Topbar: `[←] Grand Cemara Hotel` · `♡ share`
  - Subtitle biru: `15 Agt–16 Agt [∨]`
- **Tab bar scrollable** (aktif: **Kamar** biru underline):
  - Kamar · Ulasan · Pertanyaan Umum · Lokasi · Fasilitas...
- **Konten:**
  - Card kamar expanded — **Family Suite**:
    - 🛏️ 2 queen bed · 📐 30 m² · 🪟 Memiliki jendela
    - 🚭 Bebas rokok · 📶 Wi-Fi gratis
    - Tombol `Sembunyikan ∧` (teks biru, tengah)
  - Section: **"Tambahkan kamar untuk mengakomodasi grup Anda"** + deskripsi
  - Card **Kamar Superior**:
    - Galeri 2 thumbnail foto horizontal (+ badge `📷 5`)
    - **Kamar Superior ›** (bold + chevron)
    - 🛏️ 1 queen bed atau 2 single bed · 📐 21 m²
    - 🪟 Memiliki jendela · 🚭 Bebas rokok · 📶 Wi-Fi gratis
    - ~~Rp415.089~~ **Rp350.495** (biru besar)
    - Link: `Lihat harga lainnya (2) ∨`
- **Bottom Bar Sticky**

---

### 18. `detail_tab_ulasan` — Tab Ulasan / Pertanyaan Umum

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_ulasan.jpeg`

**Layout:**
- Tab aktif: **Ulasan**
- **Konten:**
  - Section **"Mungkin Anda ingin tahu"**
    - Horizontal scroll card FAQ:
      - **"Berapa biaya sarapan?"** — Info sarapan + avatar Manager akomodasi
    - Link: `Lihat Semua Pertanyaan` (underline)
  - Section **"Masih ada pertanyaan?"**
    - Teks info + Button outlined: `💬 Ajukan pertanyaan`
  - Section: **"Lokasi"** (terpotong di bawah)
- **Bottom Bar Sticky**

---

### 19. `detail_tab_lokasi` — Tab Lokasi

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_lokasi.jpeg`

**Layout:**
- Tab aktif: **Lokasi**
- **Konten:**
  - Judul: **"Lokasi"**
  - Score: **8,9** /10 · _Lokasi Strategis_
  - **Peta Google Maps** (snapshot ~180px): area Gondangdia-Menteng + pin biru
  - Alamat lengkap + ikon copy
  - Filter chips: `[Transportasi]` (aktif biru) · `Atraksi wisata` · `Belanja`
  - List Transportasi (ikon + nama + tipe + jarak):
    - 🚉 Gondangdia · Stasiun Kereta · 480m
    - 🚉 Stasiun Gambir · Stasiun Kereta · 1,5km
    - 🚇 Bundaran HI Bank Jakarta · Stasiun Metro · 1,3km
    - 🚇 Dukuh Atas BNI · Stasiun Metro · 3,3km
    - 🚌 Monas · Stasiun bus jarak jauh · 1,5km
    - ✈️ Bandara Halim Perdanakusuma · 14,7km
  - Link: `Tampilkan semua area sekitar` (underline)
- **Bottom Bar Sticky**

---

### 20. `detail_tab_fasilitas` — Tab Fasilitas

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_fasilitas.jpeg`

**Layout:**
- Tab aktif: **Fasilitas**
- **Konten:**
  - Judul: **"Layanan & fasilitas"**
  - Grid 2 kolom foto fasilitas (dengan label overlay):
    - `Kolam Renang Out... (2)` · `Ruang pertemuan (11)`
  - Kategori fasilitas (ikon + judul bold + sub-list):
    - 🍽️ **Makanan & minuman**: Minimarket/kios · ~~Restoran~~ · Bar lobi
    - 🏊 **Kolam Renang**: Kolam Renang Indoor · Kolam Renang Outdoor
    - 🚗 **Transportasi**: Rental mobil · Area Parkir `[Gratis]` · Layanan mobil concierge
    - 💪 **Kesehatan & kebugaran**: Spa · _Biaya tambahan_
  - Link: `Tampilkan semua fasilitas` (underline)
- **Bottom Bar Sticky**

---

### 21. `detail_tab_kebijakan` — Tab Kebijakan

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_kebijakan.jpeg`

**Layout:**
- Tab aktif: **Kebijakan**
- **Konten:**
  - Judul: **"Kebijakan akomodasi"**
  - 🕐 **Check-in/Check-out**:
    - Info box abu: Check-in Setelah 14:00 · Check-out Sebelum 12:00
    - Jam kerja resepsionis: 24 jam
    - Tamu utama minimal 18 tahun.
  - 👧 **Kebijakan tamu anak**:
    - Anak dari segala usia dapat menginap.
    - Paragraf rekomendasi kamar anak.
    - Info box: Jumlah tamu: 5 dewasa, 2 anak · Anak: 0 tahun & 4 tahun · `[Ubah]`
  - 🛏️ **Ranjang bayi dan tempat tidur tambahan** (terpotong)
- **Bottom Bar Sticky**

---

### 22. `detail_tab_keterangan` — Tab Keterangan

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_keterangan.jpeg`

**Layout:**
- Tab aktif: **Keterangan**
- **Konten:**
  - Judul: **"Deskripsi akomodasi"**
  - Buka: 1994
  - Paragraf deskripsi hotel (~4 baris + expand)
  - Link: `Tampilkan deskripsi lengkap ∨`
  - Section **"Ide Untuk Tempat Menginap Anda"**
    - Card UGC blog: grid 3 foto + judul + deskripsi + username (terpotong)
- **Bottom Bar Sticky**

---

### 23. `detail_tab_trip_moments` — Tab Trip Moments

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_trip_moments.jpeg`

**Layout:**
- Tab aktif: **Trip Moments**
- **Konten:**
  - Section **"Ide Untuk Tempat Menginap Anda"**
    - Card UGC lengkap: grid foto + judul + deskripsi + avatar `itslxyx` + 👍 45
  - Section **"Anda mungkin juga menyukai"** (horizontal scroll):
    - Hotel Alia Cikini ⭐⭐ · 8,4/10 · Rp795.164
    - Keraton at The Plaza ⭐⭐⭐⭐⭐ · 9,6/10 · Rp4.405.000
- **Bottom Bar Sticky**

---

### 24. `detail_tab_akomodasi_terdekat` — Tab Akomodasi Terdekat

**File:** `detail_hotel (folder)/detail_hotel_screen_tab_akomodasi_terdekat.jpeg`

**Layout:**
- Tab aktif: **Akomodasi Terdekat**
- **Konten:**
  - Section **"Anda mungkin juga menyukai"** (horizontal scroll card)
    - Hotel Alia Cikini ⭐⭐ · 8,4/10 · 930m · Rp795.164
    - Keraton at The Plaza ⭐⭐⭐⭐⭐ · 9,6/10 · 1km · Rp4.405.000
  - Section **"Mengapa Pesan di Trip.com?"**
    - 💜 **Kami Samakan Harga** + deskripsi
    - 🎟️ **Dapatkan reward saat bepergian** + deskripsi (terpotong)
- **Bottom Bar Sticky**

---

### 25. `pesan_kamar_section` — Section Pilih Kamar (Scroll ke Bawah)

**File:** `detail_hotel (folder)/form_pesan_kamar_screen/detail_hotel_screen_saat_mau_pilih_button_pesan_kamar.jpeg`

**Layout:**
- Konten lanjutan detail hotel (scroll ke bawah):
  - List fasilitas: 🧘 Spa · 🎱 Ruang biliar · 💆 Ruang pijat · 🧳 Penyimpanan bagasi
- Section **"Pilih Kamar Anda"**:
  - Sub: `💜 Kami Samakan Harga`
  - Card pilihan tanggal & tamu:
    - **15 Agt–16 Agt** · 1 malam | **2** kamar · **5** dewasa · **2** anak
    - Chips filter: `Termasuk Sarapan` · `Kamar Keluarga` · `2 Bed [∨]`
- Section **"Disarankan memesan kombo 2 kamar"**:
  - Card: `1 × Family Suite` + `1 × Kamar Superior` + Link `Lihat Detail`
  - Harga per kamar: ~~Rp541.790~~ **Rp446.637** + Total Rp1.089.796
  - Badge pink: _Diskon Spesial_
  - Button biru: **"Pesan 2 Kamar"**
  - 2 foto thumbnail kamar di bawah
- **Bottom Bar Sticky**

---

### 26. `sheet_pesan_kamar` — Ringkasan Pemesanan

**Folder:** `detail_hotel (folder)/form_pesan_kamar_screen/`

**Main screen:** `form_pesan_kamar.jpeg`

**Scroll states** (halaman yang sama, scroll ke bawah):
- `form_pesan_kamar_1.jpeg` — scroll posisi 1
- `form_pesan_kamar_2.jpeg` — scroll posisi 2
- `form_pesan_kamar_3.jpeg` — scroll posisi 3

**Layout:**
- Topbar: `[←]  Grand Cemara Hotel` (center bold)
- **Card Ringkasan Booking** (outlined rounded):
  - Check-in: **Sab, 15 Agt** — 1 malam — **Min, 16 Agt**
  - Setelah pukul 14:00 · Sebelum pukul 12:00
  - Divider
  - **Family Suite | 1 Kamar**
    - 👤 Harga untuk 4 Dewasa · 🛏️ 2 queen bed · 🚭 Bebas rokok
    - 🍳 Sarapan berbayar Rp108.900 (opsional) · ⓘ Tidak dapat di-refund
  - Divider
  - **Kamar Superior | 1 Kamar**
    - 👤 Harga untuk 2 dewasa + 1 anak · 🛏️ 1 queen bed atau 2 single bed
    - 🚭 Bebas rokok · 💜 _Anak Menginap Gratis_ (teal)
    - 🍳 Sarapan berbayar Rp108.900 (opsional) · ⓘ Tidak dapat di-refund
- Section **"Info tamu"** ⓘ:
  - `🏨 Kamar 1` · `👤+ Pilih tamu yang tersimpan`
- Banner: `💜 Kami Samakan Harga`
- **Bottom Bar:**
  - _Prabayar Online (total harga)_ · **Rp1.089.796** ⓘ · Button **"Pesan"**

---

### 27. `form_pengisian_kamar` — Form Data Tamu

**File:** `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_form_pengisian_kamar.jpeg`

**Layout:**
- Topbar: `[←]  Grand Cemara Hotel` (center)
- **Kamar 1:**
  - `🏨 Kamar 1` · `👤+ Pilih tamu yang tersimpan` (abu)
  - Sub: _Family Suite_
  - Field outlined: `Nama depan*` (placeholder abu)
  - Field outlined: `Nama belakang*`
- **Kamar 2:**
  - `🏨 Kamar 2` · `👤+ Pilih tamu yang tersimpan` (abu)
  - Sub: _Kamar Superior_
  - Field: `Nama depan*`
  - Field: `Nama belakang*`
- **Info Kontak:**
  - Field email floating label: `Email*` · nilai: `mohbaswandegorie@gmail.com` · ✓ hijau
  - Field: `+62 › Nomor Telepon*`
- Banner: `💜 Kami Samakan Harga`
- **Bottom Bar:** _Prabayar Online_ · **Rp1.089.796** · Button **"Pesan"**

---

### 28. `form_pengisian_kamar_scroll` — Form Data Tamu (Scroll Bawah)

**File:** `detail_hotel (folder)/form_pesan_kamar_screen/form_pesan_kamar_form_pengisian_kamar_scroll.jpeg`

**Layout:**
- Topbar: `[←]  Grand Cemara Hotel` (center)
- Konten lanjutan form:
  - 🎟️ **Trip Coins**: _Dapatkan 31 Trip Coins (≈Rp5.526) setelah Anda menginap._ `[∨]`
  - Divider
  - **Permintaan Khusus**: Info teks + Link `Pelajari Selengkapnya`
  - Divider
  - **Informasi Tambahan (1)**: _Deposit tunai Rp100.000 diperlukan saat check-in_ + link
  - Divider
  - Teks persetujuan T&C + Pernyataan Privasi
  - ☑ Checkbox: _Kirimi saya promo spesial Trip.com via email, notifikasi push, WhatsApp_
- Banner: `💜 Kami Samakan Harga`
- **Bottom Bar:** _Prabayar Online_ · **Rp1.089.796** · Button **"Pesan"**

---

### 29. `booking_list_screen` — Daftar Pemesanan Saya

**File:** `booking/semua_pemesanan_screen.jpeg`

**Layout:**
- **Topbar:** `[←] Semua Pemesanan` · icon search kanan
- **Tab bar:** `Semua Pemesanan` (aktif) · `Mendatang` · `Selesai` · `Refund`
- **Filter chips horizontal:** `Filter` · `Pesawat` · `Hotel` · `Kereta`
- **Card pesanan hotel:**
  - Icon hotel + label `Hotel` · badge oranye `Menunggu Pembayaran`
  - **Grand Cemara Hotel**
  - `Family Suite`
  - `17 Agt - 18 Agt, 2 kamar 1 malam`
  - `Anda akan mendapatkan: 43 Trip Coins (Rp7.665)`
  - `Prabayar online Rp1.498.990`
  - Button biru: **"Bayar"**
- **Empty state:** _Tidak Ada Pemesanan Lainnya_ + link _Cari berdasarkan email atau PIN_

---

### 30. `booking_pembayaran_screen` — Pembayaran

**File:** `booking/pembayaran_screen.jpeg`

**Layout:**
- **Topbar:** `[←]` · badge centang `Anda telah menghemat Rp277.224 pada pemesanan ini`
- **Transaksi Aman:** _Selesaikan pembayaran dalam 00:29:43_
- **Total:** `Rp1.498.990`
- **Info booking:** `Sen, 17 Agt–Sel, 18 Agt | 1 malam` · `Grand Cemara Hotel` · `Info Tamu: Tea Wan`
- **Metode pembayaran:**
  - `Virtual Account` (aktif/checklist) — icon bank BCA, BRI, BNI, Mandiri, CIMB, Permata, Danamon
  - `Tambah Kartu Kredit/Debit` — icon Mastercard, VISA, JCB, AMEX
  - `OVO` — _Tautkan akun Anda ke Trip.com agar lebih praktis_
  - `Google Pay`
- **Bottom:** Button biru full-width **"Bayar Sekarang"**
- Footer: _Berbagai metode pembayaran_ · _Cakupan global_

---

### 31. `booking_hotel_detail_screen` — Detail Pemesanan Hotel (Scroll 1-5)

**Folder:** `booking/booking_hotel_detail_screen/`

Screen ini merupakan **1 kesatuan scroll** yang menampilkan detail lengkap pemesanan hotel. Urutan scroll:

| No | File | Konten Utama |
|----|------|--------------|
| 1 | `01_menunggu_pembayaran_scroll.jpeg` | Header `Menunggu Pembayaran` dengan countdown 28:00, info `Pemesanan ini tidak memiliki opsi refund`, detail hotel Grand Cemara Hotel, tanggal `Sen, 17 Agt - Sel, 18 Agt 2026 \| 1 Malam`, check-in setelah 14:00, check-out sebelum 12:00, buttons `Bayar` dan `Batalkan Pemesanan` |
| 2 | `02_lokasi_fasilitas_kebijakan_scroll.jpeg` | Section **Lokasi** — alamat lengkap Jl. Cemara No.1 5, Gondangdia, Menteng, Jakarta Pusat + link `Lihat peta`. Section **Tidak tersedia layanan antar jemput** — link `Pesan di Trip.com`. Section **Fasilitas** — `Resepsionis 24 jam` · `Penyimpanan bagasi`. Section **Kebijakan** — `Kebijakan Deposit` deposit tunai Total Rp100.000 diperlukan. |
| 3 | `03_detail_kamar_tamu_scroll.jpeg` | **Family Suite** — 2 Kamar 1 Malam, 5 dewasa 2 anak (3 tahun, 4 tahun), 2 queen bed, Sarapan untuk 2 tamu per kamar per malam. **Info Tamu** — Tea Wan, nomor telepon dan email. **Reward & Benefit** — Trip Coins. |
| 4 | `04_reward_benefit_scroll.jpeg` | **Reward & Benefit** — `Dapatkan 43 Trip Coins (≈Rp7.665)`. **Layanan Pelanggan** — `Bantuan global 30 detik` dengan FAQ: `Di mana saya bisa melihat informasi pemesanan?`, `Bagaimana cara melihat fasilitas kamar yang disediakan?`, `Bisakah saya mengisi data untuk orang lain ketika saya melakukan reservasi?`. Section **Seberapa mungkin Anda merekomendasikan Trip.com** — rating 0-10. |
| 5 | `05_konfirmasi_pemesanan_scroll.jpeg` | No. Pemesanan `1367843010567330` + PIN, tombol `[←]` · `[🎧]` · `[↗]`. Section `Bisakah saya mengisi data untuk orang lain ketika saya melakukan reservasi?`. Badge `💜 Kami Samakan Harga` · `🛡️ Jaminan Menginap di Hotel`. Footer buttons `Bayar` (oranye) dan `Batalkan Pemesanan` (biru). |

---

## 🎨 Design System

### Palette Warna
| Token | Nilai | Digunakan pada |
|-------|-------|----------------|
| `primary` | `#2962FF` | Button CTA, badge skor, link, tab aktif underline |
| `primary_dark` | `#0039CB` | Pressed state |
| `teal_accent` | `#14B8A6` | _Anak Menginap Gratis_, _Kami Samakan Harga_ |
| `text_primary` | `#1A1A2E` | Judul, body |
| `text_secondary` | `#757575` | Subtitle, keterangan |
| `text_disabled` | `#BDBDBD` | Item tidak tersedia |
| `bg_primary` | `#FFFFFF` | Background layar |
| `bg_surface` | `#F5F5F5` | Info box abu, section background |
| `star_color` | `#FFA726` | Bintang rating |
| `price_original` | `#E53935` + strikethrough | Harga asli (dicoret) |
| `price_discount` | `#2962FF` | Harga diskon |
| `score_badge_bg` | `#2962FF` | Background badge skor (misal 8,1/10) |
| `score_badge_text` | `#FFFFFF` | Teks badge skor |
| `chip_discount_bg` | `#FCE4EC` | Background badge _Diskon Spesial_ |
| `chip_discount_text` | `#E91E63` | Teks badge _Diskon Spesial_ |

### Tipografi
| Style | Size | Weight | Digunakan |
|-------|------|--------|-----------|
| H1 (Nama Hotel) | 22px | 800 | detail_hotel |
| H2 (Section) | 18px | 700 | Semua section |
| H3 (Sub-section) | 16px | 700 | Subseksi detail |
| Body | 14px | 400 | Deskripsi, info |
| Caption | 12px | 400 | Keterangan kecil |
| Price Large | 20–24px | 800 | Harga diskon |
| Score Badge | 13–14px | 700 | Badge skor |

---

## 🏗️ Komponen Reusable

| Komponen | Digunakan di |
|----------|-------------|
| `HotelCard` (gambar kiri + info kanan) | `result_pencarian` |
| `TabBar` (scrollable horizontal, underline aktif) | Semua `detail_tab_*` |
| `BottomBarPesan` (harga + CTA button) | Semua `detail_*` |
| `ScoreBadge` (angka/10 + label) | `result_pencarian`, `detail_hotel`, `detail_tab_lokasi` |
| `StepperRow` (+/− counter) | `filter_kamar_tamu`, `result_pencarian_top_modal_filter_date_and_tamu_2nd` |
| `FacilityCategory` | `detail_tab_fasilitas` |
| `PolicySection` | `detail_tab_kebijakan` |
| `MapSnapshot` | `detail_tab_lokasi` |
| `GuestFormField` | `form_pengisian_kamar` |
| `RoomComboCard` | `pesan_kamar_section`, `sheet_pesan_kamar` |
| `BookingSummaryCard` | `sheet_pesan_kamar` |
| `PromoCodeSheet` | `form_pesan_kamar_screen/show_modal_bottom_full/bottom_sheet_kode_promo/` |
| `SpecialRequestSheet` | `form_pesan_kamar_screen/show_modal_bottom_full/bottom_sheet_permintaan/` |
| `AdditionalInfoBottomSheet` | `form_pesan_kamar_screen/show_modal_bottom/` |
| `RoomDetailBottomScreen` | `form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/` |
| `LocationFilterChips` | `detail_tab_lokasi` |
| `UGCBlogCard` | `detail_tab_keterangan`, `detail_tab_trip_moments` |
| `NearbyHotelCard` | `detail_tab_akomodasi_terdekat`, `detail_tab_trip_moments` |
| `BottomModalSheet` | `result_pencarian_*_bottom_modal_*` |
| `TopModalFilter` (2-Columns, menggunakan `top_modal_sheet`) | `result_pencarian_top_modal_filter_date_and_tamu` |
| `BottomModalSelectAnak` | `filter_kamar_tamu_bottom_modal_select_anak`, `result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak` |
| `BookingCard` | `booking_list_screen` |
| `BookingDetailScroll` | `booking_hotel_detail_screen` |
| `PaymentMethodSelector` | `booking_pembayaran_screen` |

---

## 🗺️ User Flow

```
filter_screen (home search)
  ├── [tap search field] → filter_location
  │     └── [pilih destinasi] → filter_screen (terisi)
  ├── [tap kamar & tamu] → filter_kamar_tamu
  │     └── [tap pilih anak] → filter_kamar_tamu_bottom_modal_select_anak
  ├── [tap kalender] → filter_kalendar_screen (2-tab)
  │     ├── [tab Kalender] → tampilkan kalender tanggal
  │     └── [tab Tanggal Fleksibel] → tampilkan durasi + bulan
  └── [tap Cari] → result_pencarian
        ├── [tap top header] → result_pencarian_top_modal_filter_date_and_tamu
        ├── [tap Urutkan] → result_pencarian_bottom_modal_filter_urutkan
        ├── [tap Filter] → result_pencarian_bottom_modal_filter
        ├── [tap Lokasi] → result_pencarian_bottom_modal_filter_lokasi
        ├── [tap Kebutuhan] → result_pencarian_bottom_modal_filter_kebutuhan
        └── [tap hotel card] → detail_hotel
              ├── [tab Kamar] → detail_tab_kamar
              ├── [tab Ulasan] → detail_tab_ulasan
              ├── [tab Lokasi] → detail_tab_lokasi
              ├── [tab Fasilitas] → detail_tab_fasilitas
              ├── [tab Kebijakan] → detail_tab_kebijakan
              ├── [tab Keterangan] → detail_tab_keterangan
              ├── [tab Trip Moments] → detail_tab_trip_moments
              ├── [tab Akomodasi Terdekat] → detail_tab_akomodasi_terdekat
               └── [scroll ke bawah / Pilih Kamar] → pesan_kamar_section
                     └── [Pesan 2 Kamar] → sheet_pesan_kamar
                           ├── [scroll] → sheet_pesan_kamar scroll state (1, 2, 3)
                           └── [Pesan] → form_pengisian_kamar
                                 └── [scroll] → form_pengisian_kamar_scroll
                                        └── [Pesan] → API Laravel menyimpan pesanan
                                              └── Tampil di `booking_list_screen.dart` (Flutter)
                                                    └── [tap detail pesanan] → booking_hotel_detail.dart
                                                          └── Scroll 1-5: `01_menunggu_pembayaran_scroll.jpeg` → `02_lokasi_fasilitas_kebijakan_scroll.jpeg` → `03_detail_kamar_tamu_scroll.jpeg` → `04_reward_benefit_scroll.jpeg` → `05_konfirmasi_pemesanan_scroll.jpeg`
                                                                └── [Bayar] → `booking_pembayaran_screen.jpeg` → API Laravel proses pembayaran
```

**Catatan struktur tab pada `filter_kalendar_screen`:**
- `filter_kalendar_screen` adalah SATU screen dengan 2 tab:
  - **Tab Kalender** → `filter_by_tab_kalendar_screen.jpeg`
  - **Tab Tanggal Fleksibel** → `filter_by_tab_tanggal_flexibel_screen.jpeg`

**Catatan struktur `result_pencarian_top_modal_filter_date_and_tamu` (Top Modal):**
- Menggunakan dependency `top_modal_sheet: ^2.1.0` di Flutter untuk menampilkan top modal yang slide dari bagian atas layar.
- Top modal memiliki **2 kolom**:
  - **Kolom 1: Kalender** → Full screen 2-tab (`Kalender` + `Tanggal Fleksibel`) — lihat `result_pencarian_top_modal_filter_date_and_tamu_kalendar` dan `result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel`
  - **Kolom 2: Kamar & Tamu** → Full screen stepper — lihat `result_pencarian_top_modal_filter_date_and_tamu_2nd`
    - └── [tap pilih anak] → bottom modal — lihat `result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak`

---

## 🚀 Implementasi ke Flutter (`flutter/lib/`)

Sesuai pemetaan arsitektur pada [`docs/flutter/screens.md`](file:///D:/Project/Fastwork/rental.apartemen/docs/flutter/screens.md) Bagian C (Hotel OTA), seluruh screen di atas telah dikonversi dan diintegrasikan ke dalam arsitektur Flutter:

### 1. Struktur File Flutter

| Komponen | File Kode | Route | Keterangan |
|----------|-----------|-------|------------|
| **Search & Filter** | [`flutter/lib/screens/property/hotel/hotel_search_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/property/hotel/hotel_search_screen.dart) | `/hotel/search` | Mencakup `filter_screen`, modal `filter_location`, modal `filter_kamar_tamu`, modal `filter_kamar_tamu_bottom_modal_select_anak`, `filter_kalendar_screen` (2-tab: Kalender + Tanggal Fleksibel). |
| **Search Results** | [`flutter/lib/screens/property/hotel/hotel_results_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/property/hotel/hotel_results_screen.dart) | `/hotel/results` | Menampilkan `result_pencarian`, bottom modal sheets (`urutkan`, `filter`, `lokasi`, `kebutuhan`), top modal `date_and_tamu` (3-tab: Kalender→2-tab, Kamar & Tamu, Tanggal Fleksibel). |
| **Detail & 8 Tabs** | [`flutter/lib/screens/property/hotel/hotel_detail_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/property/hotel/hotel_detail_screen.dart) | `/hotel/detail` | `detail_hotel` + Tab: Kamar, Ulasan, Pertanyaan Umum, Lokasi, Fasilitas, Kebijakan, Keterangan, Trip Moments, Akomodasi Terdekat. |
| **Booking & Checkout** | [`flutter/lib/screens/property/hotel/hotel_booking_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/property/hotel/hotel_booking_screen.dart) | `/hotel/booking` | `pesan_kamar_section`, `sheet_pesan_kamar` (dengan scroll state 1/2/3), `form_pengisian_kamar`, `form_pengisian_kamar_scroll`, dan modal `form_pesan_kamar_screen` (kode promo, permintaan khusus, informasi tambahan, detail kamar). |
| **Booking List** | [`flutter/lib/screens/booking/booking_list_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/booking/booking_list_screen.dart) | `/booking` | Menampilkan daftar semua pesanan properti (hotel, pesawat, kereta, dll) dengan status `Menunggu Pembayaran`, `Mendatang`, `Selesai`, `Refund`. Tap detail pesanan hotel menuju `booking_hotel_detail.dart`. |
| **Booking Detail** | [`flutter/lib/screens/booking/booking_detail_screen.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/screens/booking/booking_detail_screen.dart) | `/booking/:id` | Detail pemesanan hotel dengan scroll 1-5: `01_menunggu_pembayaran_scroll` → `02_lokasi_fasilitas_kebijakan_scroll` → `03_detail_kamar_tamu_scroll` → `04_reward_benefit_scroll` → `05_konfirmasi_pemesanan_scroll`. Button `Bayar` mengarah ke `booking_pembayaran_screen`. |

### 2. Service & Transport Layer

- **Service Hotel:** [`flutter/lib/services/hotel_service.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/services/hotel_service.dart)
  - `getHotelFilters()` — opsi filter hotel
  - `searchHotels(HotelSearchQuery query)`
  - `getHotelDetail(int hotelId)`
  - `getRoomTypes(int hotelId)`
  - `getFacilities(int hotelId)`
  - `getTransport(int hotelId)`
  - `getPolicies(int hotelId)`
  - `createHotelBooking(...)`
- **Dummy API Client Routing:** [`flutter/lib/services/dummy_api_client.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/services/dummy_api_client.dart)
  - `'GET hotels' -> 'GET_hotels'`
  - `'GET hotels/{id}' -> 'GET_hotels_id'`
  - `'GET hotel/filters' -> 'GET_hotel_filters'`
  - `'POST hotel/bookings' -> 'POST_hotel_bookings'`

### 3. Model Data Terintegrasi

- **Hotel Model:** [`flutter/lib/models/hotel.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/models/hotel.dart) (`Hotel`, `HotelFacilityGroup`, `HotelFacilityItem`, `HotelTransportPoint`, `HotelPolicy`, `HotelRoomItem`, `HotelFaqItem`, `HotelGuestInput`)
- **Query Model:** [`flutter/lib/models/hotel_search_query.dart`](file:///D:/Project/Fastwork/rental.apartemen/flutter/lib/models/hotel_search_query.dart)

### 4. Sample Mock JSON Fixtures (`flutter/assets/json/`)

- [`GET_hotels.json`](file:///D:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels.json) — Data list hotel hasil pencarian (Grand Cemara, Amaris, Alia, Keraton).
- [`GET_hotels_id.json`](file:///D:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotels_id.json) — Data lengkap detail hotel Grand Cemara (8 tab).
- [`GET_hotel_filters.json`](file:///D:/Project/Fastwork/rental.apartemen/flutter/assets/json/GET_hotel_filters.json) — Opsi filter hotel (lokasi, bintang, harga, fasilitas, tipe kamar, tamu, tanggal fleksibel).
- [`POST_hotel_bookings.json`](file:///D:/Project/Fastwork/rental.apartemen/flutter/assets/json/POST_hotel_bookings.json) — Response mock reservasi kamar hotel.
