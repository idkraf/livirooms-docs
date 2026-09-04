# Sinkronisasi Form Wizard Properti & Hotel — Flutter ↔ Laravel Livewire

Dokumen ini mendokumentasikan implementasi terpadu dari sistem pendaftaran dan pengelolaan akomodasi Mitra (Host) di Livirooms, mencakup frontend Flutter (7 tab wizard) dan backend Laravel (Livewire WizardForm & API `host/accommodations`).

---

## 1. Arsitektur Single Source of Truth (SSoT)

Sistem akomodasi Livirooms membedakan dua mode pemesanan (`booking_mode`):
1. **`unit` (Unit Stay)**: Penyewaan seluruh unit (Apartemen, Rumah Tapak, Villa, Kost Eksklusif). Disewakan secara harian, mingguan, bulanan, atau tahunan.
2. **`room` (Room Stay / Hotel OTA)**: Penyewaan per kamar dengan inventaris multi-room (Hotel, Guest House, Hostel, Hotel Residence). Disewakan per malam per tipe kamar.

### Hubungan Entitas Database:
- **`accommodations`**: Root entity yang menyimpan data identitas, lokasi, kota, koordinat, rating bintang, status, dan field tambahan dalam kolom JSON `other`.
- **`unit_types`**: SSoT untuk spesifikasi fisik unit/kamar (kapasitas tamu, kamar tidur, kamar mandi, luas meter persegi, bed configuration, base pricing, flag sarapan/wifi/window).
  - Pada mode `unit`: Terdapat tepat 1 record `unit_types` default yang merepresentasikan spesifikasi fisik unit tersebut.
  - Pada mode `room`: Terdapat 1 atau lebih record `unit_types` untuk masing-masing tipe kamar (e.g. Deluxe Room, Superior Room, Suite).
- **`unit_type_prices`**: SSoT untuk skema harga durasi rental pada mode `unit` (`daily`, `weekly`, `monthly`, `yearly`), mencakup biaya kebersihan (`cleaning_fee`), deposit, dan biaya layanan (`service_fee`).

---

## 2. Struktur 7 Tab Wizard (Flutter ↔ Livewire Parity)

Kedua layar formulir di Flutter (`PropertyFormScreen` untuk unit dan `HotelFormScreen` untuk room) telah disinkronkan 100% dengan struktur form wizard Laravel Livewire:

| Tab | Form Properti (`unit`) | Form Hotel (`room`) |
|---|---|---|
| **Tab 1: Identitas & Lokasi** | Jenis properti (`apartment`, `house`, `villa`, `exclusive_kost`), Nama, Gedung, Kota, Status, Alamat, Koordinat Lat/Long, Tahun Buka, Rating Bintang (1-5), Jam Check-in/Check-out. | Jenis properti (`hotel`, `guest_house`, `hostel`, `hotel_residence`), Nama Hotel, Gedung, Kota, Status, Alamat, Koordinat Lat/Long, Tahun Buka, Rating Bintang (1-5), Jam Check-in/Check-out. |
| **Tab 2: Inventaris & Ruang** | Kapasitas tamu, Kamar tidur, Kamar mandi, Luas m², Konfigurasi tempat tidur (`bed_facilities[]`), Furniture kamar (`room_furniture[]`), Grup furnitur (`room_furniture_groups[]`). | Daftar tipe kamar (`room_types[]`): Nama kamar, Bed config, Harga dasar, Harga coret, Total kuota/inventaris, Kapasitas dewasa/anak, Luas m², Flag: Breakfast, Window, Non-smoking, Free WiFi. |
| **Tab 3: Harga & Pajak** | Daftar skema sewa (`prices[]`: daily/weekly/monthly/yearly), Biaya kebersihan, Deposit, Service fee, Harga coret, Caption harga listing, Persentase pajak, Kalkulasi pajak (`inclusive`/`exclusive`). | Caption harga listing, Persentase pajak, Kalkulasi pajak (`inclusive`/`exclusive`), Nominal deposit jaminan, Switch Rekomendasi & Flash Sale. |
| **Tab 4: Fasilitas** | Fasilitas gedung/properti (`facilities[]`), Spesifikasi unit (`specs[]`), Tag fasilitas. | Grup fasilitas bertingkat (`facility_groups[]`): Kategori (Populer, Kamar, Kamar Mandi, F&B), Icon, Item fasilitas dengan badge status. |
| **Tab 5: Media & Galeri** | Galeri foto utama, Deskripsi pengantar (`intro`), Deskripsi lengkap, Judul tambahan, Paragraf tambahan. | Galeri foto hotel, Deskripsi pengantar (`intro`), Deskripsi lengkap, Judul tambahan, Paragraf tambahan, Foto spesifik tiap tipe kamar. |
| **Tab 6: Aturan & Kebijakan** | Jam check-in/out, Resepsionis 24 jam, Kebijakan anak & extra bed, Kebijakan merokok, Catatan check-in/check-out dengan tone & icon, Kebijakan pembatalan (`cancellation_policies[]`) dengan tombol preset cepat. | Jam operasional resepsionis + preset, Resepsionis 24 jam, Usia minimum, Kebijakan anak, Extra bed, Merokok, Sarapan, Kebijakan spesifik kamar (`room_policies[]`), Catatan check-in/out + preset. |
| **Tab 7: Sekitar & FAQ** | Titik penting sekitar (`nearby_points[]`: nama, tipe, jarak, durasi, icon), Rincian spesifik unit (`unit_detail[]`), Tanya jawab (`questions[]`). | Transportasi & akses publik (`transport_points[]`: stasiun, bandara, terminal, jarak, durasi), Tanya jawab hotel (`faqs[]`) dengan profil author. |

---

## 3. Presets & Nilai Cepat (Quick Chips)

Formulir menyediakan preset teks standar yang identik dengan `WizardForm.php` backend:
- **Child Policy**: Gratis 0-5 thn, Semua usia, Tidak terima anak, Dewasa 12+.
- **Extra Bed Policy**: Berbayar 250rb, Bervariasi per kamar, Tidak tersedia, Diskon 50% anak.
- **Smoking Policy**: Non-Smoking seluruh area, Dilarang merokok, Balkon only, Smoking room +Rp 100rb.
- **Breakfast Policy**: Terdaftar pada voucher, Tambahan bayar di resto hotel.
- **Cancellation Policy**: Fleksibel (24 jam), Sedang (7 hari), Ketat (Non-refundable), Gratis kapan saja.
- **Reception Hours**: 24 Jam setiap hari, 07:00 - 22:00, 08:00 - 20:00, Keyless entry 24 jam.
- **Check-in / Check-out Notes**: Format terstruktur `{label, icon, tone, text}` dengan preset Mandiri, Wajib ID resmi, Resepsionis lobi, Standar 12:00, Late check-out, Express drop-box.

---

## 4. Spesifikasi Mobile API (`host/accommodations`)

Semua endpoint pendaftaran dan pengelolaan listing Mitra menggunakan rute RESTful terpadu di bawah middleware `auth:sanctum`:

### Daftar Endpoint:
| Metode | Endpoint | Handler | Deskripsi |
|---|---|---|---|
| `GET` | `host/accommodations` | `PropertyController@hostIndex` | Mengambil daftar akomodasi host dengan filter status & paginasi |
| `POST` | `host/accommodations` | `PropertyController@store` | Menyimpan akomodasi baru (otomatis membuat SSoT `unit_types` dan `prices`) |
| `GET` | `host/accommodations/{id}` | `PropertyController@hostShow` | Mengambil detail akomodasi milik host untuk populasi formulir edit |
| `PUT` | `host/accommodations/{id}` | `PropertyController@update` | Memperbarui akomodasi, tipe kamar, durasi harga, fasilitas, dan relasi |
| `DELETE` | `host/accommodations/{id}` | `PropertyController@destroy` | Menghapus listing akomodasi host |
| `POST` | `host/accommodations/gallery/upload` | `PropertyController@uploadGallery` | Unggah file foto galeri via multipart |
| `DELETE` | `host/accommodations/{id}/gallery` | `PropertyController@deleteGallery` | Menghapus foto dari galeri akomodasi tersimpan |
| `DELETE` | `host/accommodations/gallery` | `PropertyController@deleteGalleryTemp` | Menghapus file foto sementara yang belum disimpan |

> **Catatan Kompatibilitas:** Endpoint lama `host/properties` dan `host/hotels` tetap dialihkan ke handler yang sama untuk menjamin backward-compatibility.

---

## 5. Sinkronisasi Flutter Routing

- **Route Constant**: `Routes.mitraAccommodationForm = '/mitra/accommodations/form'`.
- **Dispatcher**: `router.dart` membaca argumen rute:
  - Jika `booking_mode == 'room'` → Merender `HotelFormScreen(hotelId, accommodationId, initialData)`.
  - Jika `booking_mode == 'unit'` → Merender `PropertyFormScreen(property, accommodationId, initialData)`.
  - Jika mode belum ditentukan (`null`) → Merender `AccommodationFormScreen()` sebagai mode selector dialog.
- **Mitra Property Management**: Tombol Floating Action Button (`+ Tambah`) memanggil `_showAddOptionSheet` yang memungkinkan Mitra memilih antara unit apartemen/villa atau hotel OTA.
