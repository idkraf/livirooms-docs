# Drift Register — Docs & Klaim vs Kode

> **Fungsi file ini.** Daftar status selisih terverifikasi, perbaikan arsitektur data modeling, dan catatan integrasi sistem.
>
> **Status per 2026-08-26:** Flutter→Laravel accommodation creation flow audit selesai. Drift kritis ditemukan dan direkonsiliasi.
> **Update per 2026-08-27:** Relasi `Accommodation::bookings()` ditambahkan untuk menghilangkan `BadMethodCallException` di `ReportController::propertyPerformanceReport()`.
> **Update per 2026-08-27:** `Property.php` dan `Hotel.php` dihapus. Semua relasi terkonsolidasi di `Accommodation.php`. `HotelFaq` diubah menjadi `AccommodationFaq` (tabel `accommodation_faqs`). `HotelScoreComponent` diubah menjadi `AccommodationScoreComponent` (tabel `accommodation_score_components`). `AccommodationReviewQuote` dihapus; review quotes tidak lagi disimpan secara terpisah.
> **Update per 2026-08-27:** Resource audit selesai. `PresentsProperty` trait dibersihkan dari referensi `PropertyOther` yang sudah dihapus. `AccommodationQuestionResource::toPropertyArray()` diselaraskan dengan Flutter `HotelFaqItem`. `NearbyPointResource::toPropertyArray()` diselaraskan dengan Flutter `TransportPoint`.
> **Update per 2026-08-27:** `Accommodation::updateScoreComponents()` ditambahkan untuk men-sinkronkan rata-rata rating review ke tabel `accommodation_score_components` (component `basic`). Event `created`, `updated` (hanya jika `rating` berubah), dan `deleted` pada model `Review` memicu penyaluran otomatis. `ReviewController::store()` juga memanggilnya secara eksplisit sebagai safety net.
> **Update per 2026-08-27:** Audit `Accommodations\WizardForm` + blade selesai. Accessor rekursif `getCheckInTimeAttribute()`/`getCheckOutTimeAttribute()` dihapus. Validasi `prices` kini kondisional via `required_if:booking_mode,unit`. `has_breakfast` dipindah ke `unit_types`, tidak lagi disimpan ke tabel `accommodations`. Default transit icon diubah ke `map-pin`. Semua 23 test Livewire wizard lolos.
> **Update per 2026-08-30:** `AndroidManifest.xml` diperbaiki: referensi `@mipmap/launcher_icon` diganti `@mipmap/ic_launcher` dan meta-data Firebase `com.google.firebase.messaging.default_notification_icon` (menunjuk ke `@drawable/logo_launcher` yang tidak ada) dihapus karena Firebase tidak digunakan. Build debug Android kini berhasil link resource.
> **Update per 2026-08-29:** WizardForm icon inputs diganti dari free-text menjadi `<select>` dropdown dengan opsi Flutter-mapped yang valid. `HotelNormalizer` diintegrasikan ke pipeline `save()` untuk sanitasi `facility_groups`, `transport_points`, `faqs`, `questions`, dan `room_images`. Autocomplete suggestions disinkronkan dari master data `AccommodationSeeder` dan model `FacilityItem`/`NearbyPoint`. Dropdown `booking_mode` ditambahkan di Tab 1.
> **Update per 2026-09-03:** `HotelApiController::getFilterMetadata` diubah dari `->pluck('star_rating')` menjadi `->get()->pluck('star_rating')` karena `star_rating` bukan kolom fisik di tabel `accommodations`, melainkan accessor komputasi yang dihasilkan dari `selectRaw`. PostgreSQL gagal menguraikan alias `star_rating` pada query builder `pluck` tanpa `get()` terlebih dahulu.
> **Update per 2026-09-04:** Sinkronisasi endpoint rincian harga sewa (`GET accommodations/{id}/pricing` dan `properties/{id}/pricing`). `PropertyController::pricing` diperbarui dengan `UnitTypeResource` & `UnitTypePriceResource` untuk memastikan seluruh nilai nominal bertipe integer murni (menghindari type cast exception pada Dart). Model Dart `UnitPricing` & child models dilengkapi parser angka defensif `_toNum`/`_toInt`. Resolver rental period pada `RincianUnitScreen` diselaraskan agar memilih periode valid yang tersedia di database.
> **Update per 2026-09-04:** Perbaikan order management mitra. Tiga fixture dummy (`GET_host_orders.json`, `GET_orders.json`, `GET_host_orders_id.json`) merepresentasikan objek `Booking` yang di-flatten ke level atas, bukan objek `Order` dengan nested `booking`. Akibatnya: `Order.fromJson` menghasilkan `bookingStatus = null`, sehingga order tidak muncul di tab manapun ("Baru"/"Dikonfirmasi"/"Selesai"). Fixture juga tidak memiliki field Order (`order_code`, `booking_id`, `subtotal`, `discount`, `total`) dan `meta` pakai `page` instead of `current_page`. Ketiga fixture sudah diperbaiki untuk mencerminkan format API nyata (Order dengan nested `booking`). `Order.fromJson` juga dibuat defensif — pakai `Formatters.asInt` untuk `id`/`bookingId` dan `Formatters.asString` untuk `status`/`bookingStatus`, menghindari `TypeError` bila backend mengembalikan nilai integer sebagai string.
> **Update per 2026-09-14:** Perbaikan view `admin.user-management.users.show`. Delapan modal akun pengguna (`_update-details`, `_add-schedule`, `_add-one-time-password`, `_update-email`, `_update-password`, `_update-role`, `_add-auth-app`, `_add-task`) keliru diprefiks menggunakan `config('settings.THEME_LAYOUT_DIR')` sehingga mencari view `layout.admin.user-management.users.modals.*` yang tidak ada. Path `@include` telah diselaraskan langsung ke `admin.user-management.users.modals.*`. View kini ter-render sempurna tanpa exception.
> **Update per 2026-09-14:** Revamp total tampilan Detail Pengguna Admin (`admin.user-management.users.show`). Kode lama peninggalan template ("warga", "Surat Masuk", dan `$user->ktp`) dibersihkan. Model `App\Models\User` diperkaya dengan relasi lengkap ke entitas sistem: `accommodations`, `bookings`, `orders`, `withdrawals`, `contactInfos`, `invoiceProfiles`, `wishlists`, `buildingLists`, `referralsGiven`, `referralsReceived`, `deviceTokens`, `auditLogs`, dan `searchLogs`. Migrasi pending tabel `contact_infos` dijalankan. Tampilan detail admin kini menyajikan data komprehensif: biodata profil, verifikasi KYC, tab Bookings, Properties, Finance, Contacts & Invoicing, Activity, serta Security.
> **Update per 2026-09-14:** Implementasi Soft Deletes pada tabel dan model inti (`users`, `bookings`, `orders`, `payments`). Migrasi `2026_09_14_000001_add_soft_deletes_to_users_bookings_orders_and_payments_tables.php` menambahkan kolom `deleted_at` ke keempat tabel. Model `User`, `Booking`, `Order`, dan `Payment` diperbarui dengan trait `Illuminate\Database\Eloquent\SoftDeletes`.
> **Update per 2026-09-14:** Penyesuaian `admin.user-management.users.show` menjadi tampilan read-only. Seluruh kolom aksi (`Actions`), tombol mutasi (`Edit`, `Manage`, `Add Property`), dan tombol `Edit Profile` ditiadakan untuk menjaga fungsi halaman sebagai penampil informasi detail pengguna murni.
> **Update per 2026-09-14:** Perbaikan tombol "Add Validasi Host" dan font 404 pada `admin.user-management.user-validation.index`. Tombol sebelumnya menarget `#kt_modal_add_user-validation` yang elemen modalnya belum ada, menyebabkan error JavaScript `Uncaught TypeError: Cannot read properties of undefined (reading 'backdrop')`. Telah ditambahkan markup modal `#kt_modal_add_user-validation`, route POST `admin.user-management.user-validation.store`, controller handler `UserValidationController::store` untuk upload KTP & selfie serta sinkronisasi role host, dan font `assets/plugins/global/fonts/line-awesome/la.woff2` (dari duplikasi `la-solid-900.woff2`) guna mengeliminasi error 404.
> **Update per 2026-09-14:** Pembuatan panduan operasional teknis `docs/manual/user_guide_worker.md`. Menjelaskan secara komprehensif arsitektur background processing Laravel 12 (Queue Driver `database`, Scheduler `routes/console.php`, Jobs, Dispatching, Event Listener `BookingPaid`), inventaris seluruh background task (`payments:cancel-expired`, `CancelExpiredBookingsJob`, `ExtendHotelInventoriesJob`, `IssueInsurancePolicyJob`, `SyncInsuranceStatusJob`), serta panduan konfigurasi produksi lengkap untuk VPS Linux (Crontab + Supervisord daemon multi-process) dan cPanel Shared Hosting (Cron `--stop-when-empty`).
> **Update per 2026-09-15:** Audit, test, dan perbaikan menyeluruh pada alur simpan & perbarui `PropertyFormScreen`, `HotelFormScreen`, dan `AvailabilityPriceEditScreen`:
> 1. **Laravel `PropertyController` (store & update):** Validasi & persistensi 7 atribut kebijakan (`open_year`, `deposit_amount`, `reception_hours`, `min_age`, `receptionist_24h`, `allow_children`, `extra_bed_available`), generasi otomatis `slug`, penanganan relasi foto tipe kamar `unit_type_images` serta atribut kamar (`has_window`, `no_smoking`, `free_wifi`), soft delete tipe kamar yang dihapus dari form saat update, dan transisi pembaruan harga unit (`unit_type_prices`) menggunakan `updateOrCreate`/restore stabil (bukan `forceDelete`).
> 2. **Laravel `UnitTypePriceController` & `UnitTypeResource`:** Sinkronisasi status `unit_types.is_active` saat status harga diperbarui; penambahan field `price_id` pada resource tipe kamar agar Flutter dapat mengidentifikasi skema harga secara unik.
> 3. **Flutter `property_form_payload.dart`:** Mengekspos field kebijakan & deposit pada root payload agar langsung tervalidasi dan tersimpan di database.
> 4. **Flutter `property_form_screen.dart` & `hotel_form_screen.dart`:** Penambahan pass pengunggahan gambar lokal via `uploadGallery()` sebelum submit agar database menerima URL server yang valid; migrasi seluruh parsing angka ke `Formatters.parseInt`/`parseDouble` untuk mencegah `TypeError`; pembersihan seluruh linting dan deprecation.
> 5. **Flutter `availability_price_edit_screen.dart`:** Parser angka defensif terhadap Postgres numeric strings dan injeksi `HostService` untuk pengujian widget terisolasi (`availability_price_edit_screen_test.dart`). Seluruh 44 test Flutter mitra dan 18 test Laravel lolos 100%.
> **Update per 2026-09-16:** Penambahan method alias `Formatters.formatIdr(num? amount)` pada `Formatters` (`lib/utils/formatters.dart`) yang mendelegasikan ke `Formatters.rupiah(amount)`. Menyelaraskan seluruh pemanggilan format mata uang pada `hotel_form_screen.dart`, `property_form_screen.dart`, dan `availability_price_edit_screen.dart` agar konsisten dan bebas error `undefined_method`.
> **Update per 2026-09-17:** Penguatan keamanan IDOR, konkurensi, rekonsiliasi parameter galeri, dan integritas data pada 3 layar form mitra (`availability_price_edit_screen.dart`, `hotel_form_screen.dart`, `property_form_screen.dart`) beserta API Laravel terkait:
> 1. **Laravel `UnitTypePriceController` (IDOR & Race Condition Fix):** Memperketat otorisasi pada method `show()` dan `update()` (`if (! $user || ! $accommodation || $accommodation->host_id !== $user->id)` kecuali admin), menutup celah IDOR di mana record dengan `host_id = null` sebelumnya dapat disunting pihak non-admin. Method `update()` kini dibungkus transaksi database dengan pessimistic row lock (`UnitTypePrice::lockForUpdate()`), menjamin atomisitas saat update konkuren.
> 2. **Laravel `PropertyController` & `HostHotelController` (Gallery Delete Parameter Drift):** Endpoint `deleteGallery` dan `deleteGalleryTemp` diperbarui untuk menerima query parameter `image` (yang dikirim oleh Flutter `HostService`) maupun `path`, serta dilengkapi sanitasi `basename()` guna mencegah path traversal.
> 3. **Flutter `availability_price_edit_screen.dart`:** Menghilangkan fallback berbahaya yang sebelumnya meneruskan `unit_type_id` sebagai `price_id` saat `price_id` absen pada data room type. Menambahkan validasi dan SnackBar peringatan, serta mempertahankan seluruh skema harga lain dalam `prices` saat mengupdate tarif harian.
> 4. **Flutter `hotel_form_screen.dart` & `property_form_screen.dart`:**
>    - Sanitasi parsing `deposit_amount` dengan menghilangkan tanda titik pemisah ribuan standar Indonesia (`500.000` -> `500000.0`) sebelum `double.tryParse` agar tidak terpotong menjadi pecahan (`500.0`).
>    - Pembersihan path lokal yang gagal/belum terunggah (`removeWhere`) dari galeri foto properti dan foto tipe kamar sebelum submit ke backend.
>    - Rehidrasi state form hotel (`_loadRemoteDetail`) setelah `_saveInitialStep` agar tipe kamar memperoleh ID dan `price_id` server yang valid sebelum tab berikutnya diakses.

---

## 1. Status Resolusi Arsitektur (Selesai Direkonsiliasi)

| Topik | Isu Lama | Status & Solusi Baru |
|---|---|---|
| **Data Modeling Hotel vs Property** | Tabel paralel tidak konsisten & JSON blob `display_meta` tak terstruktur | ✅ **Terselesaikan:** 21 tabel ternormalisasi 3NF dengan single root `accommodations` & `booking_mode`. |
| **Harga & Kapasitas** | Duplikasi harga di properti dan room type | ✅ **Terselesaikan:** Single source of truth pada `unit_types` + `unit_type_prices`. Relasi `cheapestUnitType()` (`HasOne::ofMany`). |
| **Transformasi Output API** | Resource monolitik campur aduk | ✅ **Terselesaikan:** `AccommodationResource` auto-branching `hotelShape()` & `propertyShape()`, 100% cocok dengan master fixture JSON. |
| **Admin Form Wizards** | Form Livewire belum mendukung relasi ternormalisasi | ✅ **Terselesaikan:** `Properties\WizardForm` & `Hotels\WizardForm` mendukung 4-step wizard transaksional (`DB::transaction`). |
| **Flutter→Laravel Creation Drift** | Flutter `AccommodationFormScreen` mengirim 15+ field (facility_groups, policies, faqs, transport_points, gallery, star_rating) tapi Laravel `HostHotelController::store()` hanya menerima 11 field dasar | ✅ **Terselesaikan:** Controller `store()` kini menerima dan memproses semua field yang dikirim Flutter form. |
| **Order Management Fixture Drift** | `GET_host_orders.json` / `GET_orders.json` / `GET_host_orders_id.json` berisi objek `Booking` yang di-flatten, bukan `Order` dengan nested `booking`; `GET_orders.json` berisi data Property. Akibat: order tidak muncul di tab manapun | ✅ **Terselaiperbaiki:** Ketiga fixture diselaraskan ke format API nyata (Order + nested `booking`). `Order.fromJson` dibuat defensif dengan `Formatters.asInt`/`asString`. Debug `print` di `api_client.dart` `_uri()` dihapus. |

---

## 2. Flutter→Laravel Accommodation Creation Flow

### Alur Lengkap (Flutter Form → Laravel API)

```
Flutter AccommodationFormScreen
  ├── _submitHotel()
  │   ├── hotelPayload → POST host/hotels
  │   │   ├── name, star_rating, open_year, check_in_time, check_out_time
  │   │   ├── description, address, latitude, longitude
  │   │   ├── facility_groups[] → facility_groups table
  │   │   ├── policies{} → accommodation_policies table
  │   │   ├── deposit_amount, cancellation_policy
  │   │   ├── faqs[], transport_points[]
  │   │   └── gallery[] → galleries table
  │   └── roomTypesPayload[] → POST host/hotels/{id}/room-types
  │       ├── name, description, capacity_adults, capacity_children
  │       ├── max_guests, room_size_sqm, bed_configuration
  │       ├── base_price, price_original, breakfast_included
  │       ├── has_window, no_smoking, free_wifi, total_inventory
  │       └── facilities[], images[]
  └── _submitUnit()
      └── buildPropertyPayload() → POST host/properties
```

### Field Mapping: Flutter → Laravel → DB

| Flutter Field | Laravel Controller | DB Table | Status |
|---|---|---|---|
| name, address, description | `store()` validated | `accommodations` | ✅ |
| star_rating | `store()` validated | computed from reviews | ✅ |
| open_year, check_in_time, check_out_time | `store()` validated | `accommodations` | ✅ |
| cancellation_policy | `store()` validated | `accommodation_policies` | ✅ |
| deposit_amount | `store()` validated | `accommodations` | ✅ |
| facility_groups | `store()` processed | `facility_groups` + `facility_items` | ✅ |
| policies (child, extra_bed, smoking) | `store()` processed | `accommodation_policies` | ✅ |
| faqs | `store()` processed | `accommodation_questions` | ✅ |
| transport_points | `store()` processed | `nearby_points` | ✅ |
| gallery | `store()` processed | `galleries` | ✅ |
| room_types[] | `storeRoomType()` | `unit_types` | ✅ |
| room_type.prices | via unit type | `unit_type_prices` | ✅ |

### Perbandingan dengan Seeder

| Entitas | Seeder | Flutter Form | Catatan |
|---|---|---|---|
| Accommodation | ✅ Full fields | ✅ Full fields | Konsisten |
| UnitType (room) | ✅ 2 types (Merlynn) | ✅ Dynamic | Flutter dinamis |
| UnitTypePrice | ✅ daily price | Via room type | Konsisten |
| Gallery | ✅ 5 photos | ✅ Dynamic upload | Konsisten |
| Policy | ✅ cancellation + check_in | ✅ cancellation + general | Konsisten |
| FacilityGroup | ✅ 1 group + 6 items | ✅ Dynamic | Konsisten |
| FacilityTag | ✅ 4 tags | Via facility_tags | Konsisten |
| NearbyPoint | ✅ 3 points | ✅ Dynamic | Konsisten |
| Question (FAQ) | ✅ 2 FAQs | ✅ Dynamic | Konsisten |
| Review | ✅ 1 review + photo | ❌ Not in form | Reviews come from guests |

---

## 3. Catatan Integrasi Aktif

### 1. Model `Room` (Fisik)
Stok kamar hotel sepenuhnya menggunakan counter `unit_types.remaining` (real-time) dan bukan penomoran kamar fisik. Tabel `room_inventories` (daily calendar) sudah dihapus di refactoring terakhir.

### 2. Push Notification & Maps
- Parameter `AppConfig.googleMapsApiKey` dan endpoint token `POST devices/fcm-token` tersedia di backend untuk ekspansi masa depan tanpa memblokir runtime Flutter.

### 3. Known Resource Issues (Fixed)
- `AccommodationResource`: N+1 risk pada `question_count` → fixed dengan `whenLoaded()`
- `AccommodationHotelListResource`: null-cast pada `rating_label` → fixed
- `AccommodationListResource`: N+1 risk pada `city`, `rating` accessors → fixed
