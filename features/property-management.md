# Fitur Manajemen Properti Mitra (Host Property Management)

Dokumentasi implementasi, arsitektur, dan audit integrasi untuk modul Manajemen Properti Mitra di Flutter dan Laravel.

---

## 1. Arsitektur Layar & Komponen

- **Frontend Screen**: [property_management_screen.dart](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/screens/mitra/property_management_screen.dart) (Screen 30)
- **Dart Service**: [host_service.dart](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/services/host_service.dart) (`properties()`)
- **Backend Controller**: [PropertyController.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/PropertyController.php) (`hostAccommodations()`)
- **Resource Envelope**: [AccommodationResource.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Resources/AccommodationResource.php) (`hotelShape()` & `propertyShape()`)
- **Model Dart**: [property.dart](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/models/property.dart) (`Property.fromJson`)

---

## 2. Kontrak Endpoint API

### `GET /api/v1/host/accommodations`
- **Autentikasi**: Sanctum Token (`auth:sanctum`)
- **Query Parameter**:
  - `page`: Nomor halaman paginasi (default: `1`)
  - `per_page`: Jumlah item per halaman (default: `15`)
  - `status`: Filter status (`active`, `inactive`, `maintenance`)
  - `booking_mode`: Filter mode (`unit`, `room`)
  - `q`: Pencarian kata kunci nama/alamat akomodasi
- **Karakteristik Output**:
  - Mengembalikan daftar akomodasi terpadu (baik unit apartemen/villa maupun hotel) milik host yang sedang login.
  - Tidak memfilter dengan `withValidPricing()`, sehingga listing baru yang belum memiliki unit type / harga tetap dapat dilihat dan dikelola oleh host.
  - `hotelShape` menyertakan `status`, `host_id`, dan `deposit_amount` numerik.

---

## 3. Resolusi Masalah (Audit & Fix)

1. **Type Cast Exception di `Property.fromJson`**:
   - `deposit_amount` pada `hotelShape` sebelumnya diformat sebagai string via `number_format` (`"500000.00"`).
   - `property.dart` telah diperbaiki menggunakan parser defensif `_toDoubleOrNull(json['deposit_amount'])` dan pembacaan numerik yang aman (`_toInt`, `_toDouble`) untuk seluruh atribut numerik.
2. **Missing Fields pada `hotelShape`**:
   - Ditambahkan atribut `'status' => $this->status` dan `'host_id' => $this->host_id` pada `AccommodationResource::hotelShape()`.
   - Mengubah `deposit_amount` pada `hotelShape` menjadi nilai numerik `(float) $this->deposit_amount` yang konsisten.
3. **Penyempurnaan Query Host**:
   - Menghapus filter `->withValidPricing()` pada `hostAccommodations` dan `hostIndex` agar listing draf/baru milik host tidak tersembunyi.
4. **Error Handling & Diagnostics**:
   - Menampilkan `ApiException::message` jika request gagal dan mencatat stack trace via `debugPrint` untuk mempermudah diagnosa.

---

## 4. Pengujian Otomatis

- **Laravel Feature Test**: `HostAccommodationsApiTest::test_host_accommodations_lists_all_host_properties_with_status_and_correct_shapes`
- **Flutter Model Test**: `test/models/property_test.dart`
- **Flutter Widget Test**: `test/screens/mitra/property_management_screen_test.dart`

---

## 5. Form Edit Data Binding & Multi-Step Tab Locking

### A. Edit Data Binding Flow
- **Navigasi dari Manajemen Properti**: Menu "Edit" dan "Kelola Hotel & Kamar" pada [property_management_screen.dart](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/screens/mitra/property_management_screen.dart) mengirimkan argumen `{'id': p.id, 'booking_mode': p.bookingMode, 'property': p}`.
- **Router Resolution ([router.dart](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/router.dart))**:
  - `booking_mode == 'room'` mengarahkan ke [HotelFormScreen](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/screens/mitra/hotel_form_screen.dart).
  - `booking_mode == 'unit'` mengarahkan ke [PropertyFormScreen](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/screens/mitra/property_form_screen.dart).
  - Objek `Property` dan `accommodationId` diinjeksi langsung ke konstruktor layar form.
- **Inisialisasi Sinkron & Background Refresh**:
  - Pada `initState()`, form secara sinkron memetakan seluruh atribut model `Property` ke dalam `TextEditingController`, dropdown, dan list konfigurasi (`_loadFromPropertyModel`).
  - Bila ID tersedia, detail terbaru di-fetch di background (`_loadRemoteDetail`). Method `_loadInitialData` dirancang defensif sehingga field null atau list kosong dari respons API tidak menimpa data yang telah terisi sebelumnya.

### B. Strict Tab Locking untuk Akomodasi Baru
- **Kondisi Kunci**: Pada mode *Create* (`property == null && accommodationId == null`), host wajib melengkapi dan menyimpan identitas dasar (Tab 1) ke database terlebih dahulu.
- **Mekanisme Penguncian**:
  - **Swipe Lock**: `TabBarView.physics` menggunakan `NeverScrollableScrollPhysics()` hingga `_canNavigateTabs == true`.
  - **Tap Lock**: `TabBar.onTap` mencegat klik pada tab indeks > 0, mengembalikan controller ke tab 0, dan memunculkan notifikasi peringatan.
  - **Visual Indicator**: Setiap tab setelah tab 1 menampilkan ikon gembok (`Icons.lock_outline`).
  - **Aksi Simpan Tahap 1**: Tombol dedicated *"Simpan Identitas & Buka Tab Lainnya"* memvalidasi kelengkapan form Tab 1 (nama, alamat, kota), mengeksekusi `createProperty()`, menyimpan `_savedAccommodationId`, dan membuka kunci seluruh tab serta bertransisi ke Tab 2 secara otomatis.

### C. Pengujian Form & Validasi Tab
- **Widget Test Suite**: [form_binding_and_tab_lock_test.dart](file:///d:/Project/Fastwork/rental.apartemen/flutter/test/screens/mitra/form_binding_and_tab_lock_test.dart)
  - Pengujian pre-populasi data form pada mode Edit unit & hotel.
  - Pengujian pencegahan swipe dan tap navigasi tab pada mode Create.
  - Pengujian pembukaan kunci tab setelah penyimpanan Tab 1 berhasil.
  - Pengujian resolusi argumen rute pada `AppRouter`.
