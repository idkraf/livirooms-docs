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
- **`unit_type_prices`**: SSoT untuk skema harga durasi rental pada mode `unit` (`daily`, `weekly`, `monthly`, `yearly`), mencakup biaya kebersihan (`cleaning_fee`), deposit, biaya layanan (`service_fee`), serta status ketersediaan & operasional (`status`: `active`, `inactive`, `sold_out`, `maintenance`).

---

## 2. Struktur 7 Tab Wizard (Flutter ↔ Livewire Parity)

Kedua layar formulir di Flutter (`PropertyFormScreen` untuk unit dan `HotelFormScreen` untuk room) telah disinkronkan 100% dengan struktur form wizard Laravel Livewire:

| Tab | Form Properti (`unit`) | Form Hotel (`room`) |
|---|---|---|
| **Tab 1: Identitas & Lokasi** | Jenis properti (`apartment`, `house`, `villa`, `exclusive_kost`), Nama, Gedung, Kota, Status, Alamat, Koordinat Lat/Long, Tahun Buka, Rating Bintang (1-5), Jam Check-in/Check-out. | Jenis properti (`hotel`, `guest_house`, `hostel`, `hotel_residence`), Nama Hotel, Gedung, Kota, Status, Alamat, Koordinat Lat/Long, Tahun Buka, Rating Bintang (1-5), Jam Check-in/Check-out. |
| **Tab 2: Inventaris & Ruang** | Kapasitas tamu, Kamar tidur, Kamar mandi, Luas m², Konfigurasi tempat tidur (`bed_facilities[]`), Furniture kamar (`room_furniture[]`), Grup furnitur (`room_furniture_groups[]` dikelola via modal bottom sheet interaktif). | Daftar tipe kamar (`room_types[]`): Nama kamar, Bed config, Harga dasar, Harga coret, Total kuota/inventaris, Kapasitas dewasa/anak, Luas m², Flag: Breakfast, Window, Non-smoking, Free WiFi. |
| **Tab 3: Harga & Pajak** | Daftar skema sewa (`prices[]`: daily/weekly/monthly/yearly), Biaya kebersihan, Deposit, Service fee, Harga coret, Caption harga listing, Persentase pajak, Kalkulasi pajak (`inclusive`/`exclusive`). | Matrix tarif kamar interaktif (`room_types[]` diedit via `showPriceSchemeSheet()`): Tarif dasar, Harga + Pajak, Stok, Status badge, Fees subtitle, Sarapan. Caption harga listing, Persentase pajak, Kalkulasi pajak (`inclusive`/`exclusive`). |
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

---

## 6. Arsitektur Modal Bottom Sheets Formulir (`lib/screens/mitra/sheets/`)

Untuk menyederhanakan ukuran file formulir yang kompleks (`property_form_screen.dart` dan `hotel_form_screen.dart`), seluruh formulir sub-dialog dan builder entitas modular telah dipisahkan ke direktori `lib/screens/mitra/sheets/` dengan barrel export `sheets.dart`:

| Sheet File | Fungsi / Modal Builder | Target Form | Deskripsi & Payload Model |
|---|---|---|---|
| `room_spec_sheet.dart` | `showRoomSpecSheet()` | Unit (`PropertyFormScreen`) | Kapasitas tamu, kamar tidur, kamar mandi, luas m² via steppers interaktif dengan validasi minimum. Mengembalikan `Map<String, num>`. |
| `bed_facility_sheet.dart` | `showBedFacilitySheet()` | Unit (`PropertyFormScreen`) | Form tambah/edit konfigurasi tempat tidur (`label`, `note`, `count`, `icon_name`). Mengembalikan `Map<String, dynamic>`. |
| `room_furniture_group_sheet.dart` | `showRoomFurnitureGroupSheet()` | Unit (`PropertyFormScreen`) | Modal builder nama ruangan, daftar item furnitur per ruangan, dan konfigurasi bed per grup. |
| `price_scheme_sheet.dart` | `showPriceSchemeSheet()` | Unit (`PropertyFormScreen`) & Hotel (`HotelFormScreen` Tab 3) | Form tambah/edit skema sewa (`daily`, `weekly`, `monthly`, `yearly`), nominal harga (`amount` / `base_price`), cleaning fee, deposit, service fee, dan status operasional (`active`, `inactive`, `sold_out`, `maintenance`). Jika dibuka dari `booking_type = 'room'` / `booking_mode = 'room'`, dropdown "Tipe Sewa" otomatis disembunyikan dan dikunci ke `daily`. Sinkron penuh dengan penyimpanan room types & `unit_type_prices` di Laravel `PropertyController@update`. |
| `building_facility_sheet.dart` | `showBuildingFacilitySheet()` | Unit (`PropertyFormScreen`) | Form tambah/edit fasilitas gedung dengan 11 icon picker interaktif (`facility_name`, `icon`). Mengembalikan `Map<String, dynamic>`. |
| `property_spec_sheet.dart` | `showPropertySpecSheet()` | Unit (`PropertyFormScreen`) | Form tambah/edit spesifikasi properti dengan 5 kategori icon (`spec_name`, `icon`). Mengembalikan `Map<String, dynamic>`. |
| `hotel_room_type_sheet.dart` | `showHotelRoomTypeSheet()` | Hotel (`HotelFormScreen`) | Full builder tipe kamar hotel: Nama kamar, bed configuration, base price, original price, allotment kuota inventaris, kapasitas dewasa/anak, luas m², deskripsi, dan flags (breakfast, window, non-smoking, free WiFi). Mengembalikan `Map<String, dynamic>`. |
| `hotel_facility_group_sheet.dart` | `showHotelFacilityGroupSheet()` | Hotel (`HotelFormScreen`) | Form tambah/edit grup fasilitas bertingkat: Kategori/group selector (dengan quick chips grup yang sudah ada), icon picker, item name, badge selector (Gratis/Tersedia/Populer/etc), dan toggle ketersediaan. Mengembalikan `Map<String, dynamic>`. |
| `operational_rule_sheet.dart` | `showOperationalRuleSheet()` | Unit & Hotel | Modal konfigurasi aturan operasional: jam check-in, jam check-out, nominal deposit, usia minimum tamu, jam operasional resepsionis (+ presets), dan toggle switch 24 jam resepsionis, tamu anak, serta extra bed. Mengembalikan `Map<String, dynamic>`. |
| `checkin_checkout_note_sheet.dart` | `showCheckInOutNoteSheet()` | Unit & Hotel | Form tambah/edit catatan operasional check-in dan check-out dengan preset cepat, pemilih tone notifikasi (`info`, `warning`, `success`, `danger`), dan icon picker (`clock`, `info`, `building`, `key`, `door`, dll). Mengembalikan `Map<String, dynamic>`. |
| `policy_item_sheet.dart` | `showPolicyItemSheet()` / `PolicyArraySection` | Unit & Hotel | Modal tambah/edit butir kebijakan custom & komponen visual `PolicyArraySection` untuk kebijakan anak, extra bed, merokok, sarapan, pembatalan, dan kamar hotel dengan preset dinamis serta aksi edit/hapus. Mengembalikan `String`. |
| `nearby_point_sheet.dart` | `showNearbyPointSheet()` | Unit & Hotel | Form modal tambah/edit titik lokasi penting sekitar (POI) dan titik transit transportasi hotel dengan saran kategori (`Stasiun`, `Bandara`, `Terminal`, dll), jarak, estimasi durasi, dan pemilih ikon (`train`, `airport`, `bus`, `mall`, dll). Mengembalikan `Map<String, dynamic>`. |
| `faq_item_sheet.dart` | `showFaqItemSheet()` | Unit & Hotel | Form modal tambah/edit tanya jawab (FAQ) akomodasi: pertanyaan tamu, jawaban pengelola/staff, nama penjawab, dan peran/jabatan penjawab. Mengembalikan `Map<String, dynamic>`. |
| `unit_detail_sheet.dart` | `showUnitDetailSheet()` | Unit (`PropertyFormScreen`) | Form modal tambah/edit rincian spesifik unit (Detail Properti Tambahan) dengan preset nilai cepat (`Parkir`, `Daya Listrik`, `Lantai`, `Pemandangan`, dll) dan pemilih ikon. Mengembalikan `Map<String, dynamic>`. |
| `building_form_sheet.dart` | `showBuildingFormSheet()` | Unit & Hotel | Form modal tambah gedung/tower apartemen baru langsung dengan upload foto gedung, pilihan kota, dan nama gedung. Mengembalikan `BuildingList`. |
| `pricing_tax_sheet.dart` | `showPricingTaxSheet()` | Unit (`PropertyFormScreen`) & Hotel (`HotelFormScreen` Tab 3) | Form modal pengaturan harga coret/normal (`price_original`), caption harga listing (`price_caption`), persentase pajak (`tax_percentage`), dan kalkulasi pajak (`exclusive`/`inclusive`). Mengembalikan `Map<String, dynamic>`. |
| `sheets.dart` | *Barrel Export* | Unit & Hotel | Meng-export seluruh enam belas (16) sheet di atas untuk kemudahan import satu pintu (`import 'sheets/sheets.dart';`). |

---

## 7. Mekanisme Sinkronisasi Tarif Kamar & Skema Harga (`unit_types` & `unit_type_prices`)

Pada mode hotel (`room`), setiap tipe kamar memiliki konfigurasi tarif dasar dan biaya-biaya pendukung:

1. **Struktur Penyimpanan Backend**:
   - `unit_types`: Menyimpan metadata kamar fisik (`name`, `bed_configuration`, `base_price`, `price_original`, `total_inventory`, `room_size_sqm`, `has_breakfast`, `description`, `is_active`).
   - `unit_type_prices`: Menyimpan rincian harga per durasi (`price_type` default `daily`), `amount` (nominal tarif kamar), `cleaning_fee`, `deposit`, `service_fee`, dan ketersediaan `status` (`active`, `inactive`, `sold_out`, `maintenance`).
2. **Serialisasi API Resource**:
   - `UnitTypeResource`: Membuka field flat pada objek root (`price`, `amount`, `price_type`, `cleaning_fee`, `deposit`, `service_fee`, `status`) dari skema harga harian (`dailyPrice`), selain menyertakan relasi nested `prices`.
   - `AccommodationResource`: Menyediakan detail hotel dengan eager loading `unitTypes.prices` sehingga tarif kamar dan biaya pendukung selalu tersedia saat form dibuka kembali.
3. **Penyimpanan Controller**:
   - `PropertyController@update` & `HostHotelController@update`: Membaca array `room_types` dari payload, memperbarui tabel `unit_types`, dan melakukan upsert (`updateOrCreate`) ke `unit_type_prices` baik dari field flat maupun array nested `prices`.
4. **Alur Frontend Flutter**:
   - `HotelRoomItem`: Menyimpan dan mem-parse `priceType`, `cleaningFee`, `deposit`, `serviceFee`, `status`, `isActive`, dan `prices`.
   - `hotel_room_type_sheet.dart`: Menggunakan spread operator `{ if (init != null) ...init, ... }` saat submit sehingga field tarif dan biaya tidak terhapus ketika user mengedit spesifikasi fisik kamar di Tab 2.
   - `hotel_form_screen.dart` (Tab 3): Memanggil `showPriceSchemeSheet(bookingType: 'room')`, memperbarui `_roomTypes[idx]` dengan field flat sekaligus nested `'prices'` array, dan langsung merefleksikan perubahan pada kartu ringkasan matrix harga (tarif dasar, harga + pajak, stok, status badge, dan rincian biaya kebersihan/deposit/service fee).

---

## 8. Pembaruan Kilat Ketersediaan & Tarif (Quick Availability & Price Edit)

Untuk mempercepat perubahan ketersediaan dan harga tanpa harus membuka wizard edit penuh 7 tab, telah diimplementasikan alur end-to-end terpadu:

### 1. Backend: Strictly Update-Only API (`UnitTypePriceController`)
- **Rute**:
  - `GET api/v1/host/unit-type-prices/{id}`
  - `PUT api/v1/host/unit-type-prices/{id}` (dan nested `PUT api/v1/unit-types/{unitType}/prices/{price}`)
- **Prinsip Keamanan Strictly Update-Only (No Create)**:
  - Menggunakan `UnitTypePrice::findOrFail($id)` tanpa method `create` atau `insert`.
  - Jika ID tidak ditemukan, mengembalikan `404 Not Found`.
  - Upaya `POST` diblokir oleh rute (`405 Method Not Allowed`).
  - Verifikasi kepemilikan host (`accommodation->host_id === $request->user()->id`), mengembalikan `403 Forbidden` jika bukan pemilik.
  - Validasi payload ketat: `amount` (min: 0), `cleaning_fee` (min: 0), `deposit` (min: 0), `service_fee` (min: 0), `price_type` (in: `daily,weekly,monthly,yearly`), `status` (in: `active,inactive,sold_out,maintenance`).
  - Mencegah duplikasi `price_type` pada `unit_type` yang sama (`422 Unprocessable Entity`).
  - Mengembalikan respon `200 OK` dengan `UnitTypePriceResource` serta menyinkronkan `unit_types.base_price` jika durasi harian diubah.

### 2. Frontend: Modal Bottom Sheet Navigasi (`property_management_screen.dart`)
- Pada saat kartu properti ditekan (`onTap` di baris 319), sistem menampilkan Modal Bottom Sheet dengan 2 opsi jelas:
  1. **Opsi 1 (Full Edit)**: Membuka wizard edit penuh 7 tab via `_openForm(p)` (`Routes.mitraAccommodationForm`).
  2. **Opsi 2 (Available & Price Edit)**: Membuka layar pembaruan kilat via `_openAvailabilityPriceEdit(p)` (`Routes.mitraAvailabilityPriceEdit`).
- Opsi juga dapat diakses langsung melalui menu titik tiga (`PopupMenuButton`) pada setiap kartu.

### 3. Frontend: Layar Pembaruan Cepat (`availability_price_edit_screen.dart`)
- **Kondisi Unit (Apartemen/Villa/Kost)**:
  - Mengadopsi arsitektur dari baris 1876 `property_form_screen.dart`.
  - Menampilkan daftar skema tarif rental (`daily`, `weekly`, `monthly`, `yearly`).
  - Tombol edit memanggil `showPriceSchemeSheet(bookingType: 'unit')`.
  - Nilai yang diperbarui langsung dikirim via `HostService.updateUnitTypePrice(priceId, payload)`.
- **Kondisi Room (Hotel OTA)**:
  - Mengadopsi arsitektur dari baris 1940–2070 `hotel_form_screen.dart`.
  - Menampilkan matrix tipe kamar (nama kamar, kapasitas, harga dasar, simulasi harga + pajak, stok kamar, badge status ketersediaan, rincian biaya).
  - Tombol edit memanggil `showPriceSchemeSheet(bookingType: 'room')`.
  - Nilai yang diperbarui langsung dikirim via `HostService.updateUnitTypePrice(priceId, payload)`.
- **Feedback & State**:
  - Validasi feedback interaktif (SnackBar sukses/gagal, indikator loading per item, dan refresh otomatis daftar saat navigasi kembali).
