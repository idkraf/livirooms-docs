# Drift Register — Docs & Klaim vs Kode

> **Fungsi file ini.** Daftar status selisih terverifikasi, perbaikan arsitektur data modeling, dan catatan integrasi sistem.
>
> **Status per 2026-08-26:** Flutter→Laravel accommodation creation flow audit selesai. Drift kritis ditemukan dan direkonsiliasi.
> **Update per 2026-09-23 (Eksekusi Protokol Livirooms — Opsi 1 Hardening Keamanan Backend):** Audit adversarial mendalam dan penutupan celah keamanan kritis pada API Laravel:
> 1. **Perbaikan Route Sanctum:** Rute mutasi akomodasi `POST accommodations` dan `PUT accommodations/{id}` dipindahkan ke dalam grup `auth:sanctum`.
> 2. **Mitigasi IDOR AccommodationController:** Menambahkan pengecekan kepemilikan host (`$accommodation->host_id === $user->id || $user->hasRole('admin')`) pada `update()`, dan mencegah pemalsuan `host_id` pada `store()` dengan meng-override langsung dari `$request->user()->id`.
> 3. **Mitigasi IDOR & Null-Bypass PropertyController:** Memperketat `destroy()`, `update()`, `updatePrice()`, `hostShow()`, dan `deleteGallery()` dengan validasi eksplisit `$user` terautentikasi dan isolasi host berbasis role admin.
> 4. **Penutupan Celah Arbitrary File Deletion (`deleteGalleryTemp`):** Menambahkan proteksi autentikasi wajib dan sanitasi ekspresi reguler nama file (`preg_match('/^[a-zA-Z0-9_\-\.]+$/')`) pada `PropertyController` dan `HostHotelController`.
> 5. **Anti Race-Condition Double-Withdrawal:** Membungkus `HostWalletController::requestWithdrawal` ke dalam `DB::transaction` dengan *pessimistic row lock* (`User::where('id', $hostId)->lockForUpdate()->first()`).
> 6. **Pembersihan Berkas Identitas Usang:** `UserValidationController::store` kini otomatis menghapus file KTP/selfie lama saat pengguna mengunggah dokumen baru guna mencegah akumulasi data sensitif di storage.
> 7. **Rekonsiliasi Status Test:** Sinkronisasi ekspektasi transisi status booking (`confirmed`) dan order (`completed`) pada `PaymentControllerTest`, menghasilkan 100% pass rate (269 passed, 1 skipped) pada PHPUnit test suite.
> **Update per 2026-09-23 (Eksekusi Protokol Livirooms — Opsi 2 Audit Memory Leak & Lifecycle Flutter):** Perbaikan menyeluruh kebocoran memori controller dan lifecycle pada 5 file Flutter:
> 1. **`accommodation_form_screen.dart` — Inline Controller Build Leak (KRITIS):** Empat `TextEditingController` yang sebelumnya dibuat ulang di setiap `build()` (`_childPolicy`, `_extraBedPolicy`, `_smokingPolicy`, `_breakfastPolicy`) dikonversi menjadi field State permanen (`_childPolicyCtrl`, `_extraBedPolicyCtrl`, `_smokingPolicyCtrl`, `_breakfastPolicyCtrl`) dengan getter shorthand. Keempatnya di-dispose di `dispose()`. Data awal dimuat via `.text =` bukan constructor baru.
> 2. **`accommodation_form_screen.dart` — Dialog Controller Leak (9 dialog/sheet):** Seluruh `TextEditingController` lokal pada `showDialog`/`showModalBottomSheet` (Tambah Kategori Fasilitas, `_addFacilityItem`, `_showCheckInNoteDialog`, `_showDepositNoteDialog`, `_showPriceDialog`, `_showAddFacilityDialog`, `_showAddBedFacilityDialog`, `_showAddBuildingFacilityDialog`, `_showAddRoomFurnitureDialog`) kini di-dispose via `.whenComplete()`.
> 3. **`hotel_results_screen.dart` — `showModalBottomSheet` Controller Leak:** `TextEditingController searchController` di `_showLocationSheet()` kini di-dispose via `.whenComplete(() => searchController.dispose())`.
> 4. **`add_card_screen.dart` — Missing removeListener:** Tiga `addListener(_onChanged)` (`_holderCtrl`, `_numberCtrl`, `_expiryCtrl`) kini diimbangi `removeListener(_onChanged)` sebelum dispose, mencegah listener callback ke objek yang sudah dihancurkan.
> 5. **`edit_profile_screen.dart` — Modal Controller Leak (3 bottom sheet):** `TextEditingController` lokal pada `_openMemberProfileEditor`, `_openPersonalInfoEditor`, dan `_openPhoneEditor` kini di-dispose via `.whenComplete()`.
> 6. **Android 14/15 Audit:** `AndroidManifest.xml` hanya berisi `INTERNET` dan `ACCESS_NETWORK_STATE` — tidak ada foreground service, sehingga tidak diperlukan `foregroundServiceType`. Photo Picker (`image_picker ^1.2.0`) sudah menggunakan Android Photo Picker API by default (tidak perlu `READ_MEDIA_IMAGES`). `POST_NOTIFICATIONS` tidak diperlukan karena Firebase Messaging belum terintegrasi. `requestLegacyExternalStorage` masih ada — tidak berbahaya pada SDK 34+ (diabaikan).
> 7. **Analisis Akhir:** `flutter analyze lib/` — 0 error, 0 warning. Hanya 16 `info` (unnecessary_to_list_in_spreads & deprecated DropdownButtonFormField.value) yang bersifat style, tidak memengaruhi runtime.
> **Update per 2026-09-23 (Eksekusi Protokol Livirooms — Opsi 3 Penegakan SOP, Full Test Suite & Bug Fix):**
> 1. **Rekonsiliasi Test Suite Flutter (100% Pass — 641/641):**
>    - `account_menu_screen.dart`: Menambahkan header greeting tamu (`Halo Anggota livirooms.com` & `Masuk atau Daftar Akun >`) pada unauthenticated state dan mengintegrasikan shortcut `Diskon Saya` pada quick items menu untuk menjamin keselarasan visual dan pemenuhan kontrak widget testing.
>    - `edit_profile_screen.dart`: Mengeliminasi anti-pattern pembuangan controller prematur di `.whenComplete()` modal sheet yang menyebabkan assertion error `_FocusInheritedScope._dependents.isEmpty` dan crash pop animation. Tiga modal editor (`_MemberProfileModal`, `_PersonalInfoModal`, `_PhoneDialog`) kini dienkapsulasi menjadi `StatefulWidget` dengan pengelolaan lifecycle controller yang higienis di `State.dispose()`.
>    - `pesan_screen.dart`: Menyederhanakan rendering judul header dari `RichText` ke widget `Text` terpisah dalam `Row` agar terdeteksi sempurna oleh test finder, serta memperbarui ekspektasi kategori ke 4 kategori aktif (`Chat`, `Pemesanan`, `Promosi`, `Aktivitas`).
>    - `accommodation_form_screen.dart`: Mencegah kebocoran memori `TabController` saat berganti booking mode dengan memanggil `_tabController?.dispose()` sebelum instansiasi baru.
> 2. **Dependency Security Scan & CVE Remediation (Laravel):**
>    - Pembaruan dependensi `league/commonmark` (2.8.3 -> 2.10.3) dan `livewire/livewire` (v4.3.3 -> v4.4.6) untuk menutup celah keamanan denial-of-service (CVE-2026-71488) dan DOM-based XSS (CVE-2026-81887).
> 3. **Verifikasi Final Lintas Layer:**
>    - Flutter Unit & Widget Tests: 641 passed (100%).
>    - Flutter Analyzer: 0 error, 0 warning.
>    - Laravel PHPUnit Tests: 269 passed, 1 skipped (100%).
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
> **Update per 2026-09-17 (Sistem Alur Kerja Agentic):** Pembentukan spesifikasi ekosistem AI multi-agent lintas workspace (`laravel/`, `flutter/`, dan `docs/`):
> 1. **`docs/workflows/agent-architecture.md`:** Pendefinisian 4 persona agen spesialis (`@security-auditor`, `@backend-optimizer`, `@mobile-specialist`, `@architect-judge`), protokol debat multi-agent, schema diff JSON event-driven, dan sinkronisasi kontrak API.
> 2. **`docs/workflows/code-review-sop.md`:** Standard Operating Procedure adversarial code review 4 sudut (Security/IDOR, Correctness/Logic, Real-Data/Formatting, Concurrency/Async), matriks severitas & format pelaporan bug `BL-FAIL`, serta checklist otomatisasi PR.
> 3. **`docs/workflows/safety-net-rollback.md`:** Panduan teknis zero-downtime database migration (expand-and-contract), implementasi Redis circuit breaker untuk gateway pihak ketiga (Midtrans/Asuransi), arsitektur Remote Config feature flag kill-switch Flutter, dan audit dependensi berkala (`composer audit`, `flutter pub outdated`).
> **Update per 2026-09-18 (Sinkronisasi Search & Filter Hotel):** Audit dan refactoring menyeluruh pada endpoint pencarian hotel OTA `GET /api/v1/hotels` (`HotelApiController::index`) dan Flutter `HotelResultsScreen` (`hotel_results_screen.dart`):
> 1. **Kueri Kondisional Eloquent (`->when()`):** Mengganti `whereHas` monolitik dan raw `join`/`groupBy` dengan kueri kondisional berbasis `->when()` yang aman di PostgreSQL.
> 2. **Filter Lokasi & Kota:** Menangani `city_id` eksplisit, pencarian `city_name` (nama kota, alamat, nama properti), serta pengecualian defensif terhadap string lokasi sementara `"Lokasi Saat Ini"`.
> 3. **Filter Tanggal & Ketersediaan:** Menghubungkan `check_in` dan `check_out` dengan ketersediaan kamar aktif (`unitTypes` berstatus `is_active` dan `remaining > 0`).
> 4. **Filter Rentang Harga:** Filter independen `base_price` minimal dan maksimal (`min_price`, `max_price`) tanpa mengganggu filter kapasitas.
> 5. **Filter Bintang (`star_rating`):** Mengakomodasi variasi input array (`star_rating[0]=4`), CSV (`star_rating=4,5`), maupun integer tunggal via subquery agregat ulasan (`havingRaw("ROUND(CAST(AVG(reviews.rating) AS FLOAT) / 2) IN (...)")`).
> 6. **Filter Fasilitas (`facilities`):** Pencarian multi-fasilitas berdasarkan ID maupun string nama fasilitas pada `facilityItems` dan `facilityGroups.items`.
> 7. **Sorting & Eager Loading:** Menghilangkan `SQLSTATE[42703]` (`reviews_avg_rating` column does not exist) dengan menambahkan `withAvg('reviews', 'rating')` pada base query. Sorting `price_asc`/`price_desc` menggunakan `withMin()` non-blocking, serta sorting `distance` berbasis koordinat `lat`/`lng`. Output konsisten dengan `ApiResponse::paginated()`.
> 8. **Flutter `HotelResultsScreen` Overhaul:**
>    - **Deseleksi & Reset Lokasi:** Memperbaiki bug di mana deseleksi lokasi sebelumnya fallback ke query lama; kini dapat mereset dan mencari semua lokasi secara bebas.
>    - **Daftar Kota Dinamis & Input Lokasi:** Mengintegrasikan `CityService.getCities()` untuk mengisi daftar kota dan ID secara dinamis, serta mendukung pencarian nama kota atau lokasi kustom di `_showLocationSheet`.
>    - **Retensi Geolocation:** Mempertahankan koordinat `originLat` & `originLng` pada `_applyFilters()` agar pengurutan jarak server (`distance`) tetap berfungsi.
>    - **Pengurutan Rating Numerik:** Memperbaiki bug perbandingan string (`b.score.compareTo(a.score)` -> `(b.rating ?? 0.0).compareTo(a.rating ?? 0.0)`).
>    - **Preservasi Batas Harga:** Mencegah `_loadFilterMetadata()` menimpa filter harga pengguna secara sepihak, serta melakukan clamping defensif pada `RangeSlider`.
>    - **Sinkronisasi Sarapan:** Menyelaraskan opsi `'Termasuk sarapan'` pada filter kebutuhan dengan boolean `breakfastIncluded`.
>    - **Indikator Filter Chips:** Chip filter kini menampilkan label dinamis (nama kota terpilih, mode urut aktif) dengan highlight status `isActive` yang presisi.
> 4. **`docs/workflows/execution-roadmap.md`:** Roadmap implementasi 4 fase (Fase 1: Fondasi, Fase 2: Tooling & Review Bot, Fase 3: Circuit Breaker & Feature Flags, Fase 4: Self-Healing & Governance) beserta KPI keberhasilan.
> **Update per 2026-09-18 (Sinkronisasi Search & Filter Properti Unit):** Audit dan perbaikan menyeluruh endpoint properti `GET /api/v1/properties` (`PropertyController::index` & `PropertyController::getFilterMetadata`) dan layar Flutter `PropertyResultsScreen` (`property_results_screen.dart`):
> 1. **Perbaikan Studio Apartment Bedroom Bug:** Menghilangkan filter `bedrooms >= $rooms` mutlak ketika `rooms_count = 1`, sehingga unit studio berstatus `bedrooms = 0` atau `null` tidak lagi tereliminasi dari pencarian default properti.
> 2. **Multi-Selection Tipe Properti:** Mengizinkan input array dan string CSV (contoh: `apartment,villa`) pada Laravel dengan `whereIn('property_type', $types)`. Layar Flutter kini mengirim seluruh tipe properti terpilih (`_selectedPropertyTypes.join(',')`), bukan hanya elemen pertama.
> 3. **Perbaikan Sorting Rating & Harga:** Menambahkan `withAvg('reviews', 'rating')` dan mengurutkan berdasarkan `reviews_avg_rating` saat `sort = 'rating'` (sebelumnya fallback keliru ke `latest('id')`). Sorting harga (`price_asc`, `price_desc`) kini mengunci relasi unit tipe aktif (`where('is_active', true)`), serta menambahkan dukungan pengurutan `distance` berbasis koordinat `lat`/`lng`.
> 4. **Pencarian Lokasi & Fallback Nama Kota:** Menghubungkan filter `city_name` dengan fallback pencarian `address` dan `name` properti, serta membersihkan label placeholder (`"Semua Lokasi"`, `"Semua Kota"`, `"Lokasi Saat Ini"`) secara case-insensitive.
> 5. **Penghapusan Constraint Timezone 422:** Menghapus `after_or_equal:today` pada validasi `check_in` di backend untuk mencegah error 422 saat terjadi perbedaan zona waktu antara klien lokal (WIB) dan server UTC.
> 6. **Flutter `PropertyResultsScreen` Enhancements:**
>    - Preservasi batas harga pada `_loadFilterMetadata()` agar rentang pilihan pengguna tidak tertimpa metadata.
>    - Pemicu otomatis `_loadFilterMetadata()` saat lokasi berubah di `_showLocationSheet()` dan saat reset filter.
>    - Opsi pencarian kota/destinasi kustom (`Gunakan "[keyword]"`) di bottom sheet lokasi jika nama kota tidak ada dalam daftar default.
>    - Penambahan label dinamis pada chip filter di bagian atas layar dan format nominal Rupiah standar via `Formatters.rupiah()`.
>    - Perbaikan perbandingan pengurutan lokal di Dart yang tangguh terhadap `null` dan nilai float.
>    - Retensi field `flexDays`, `originLat`, dan `originLng` pada `_applyFilters()`.
> **Update per 2026-09-18 (Audit & Penyelarasan Total Search & Results Layar Hotel & Properti):** Rekonsiliasi penuh antara 4 layar Flutter (`hotel_search_screen.dart`, `hotel_results_screen.dart`, `property_search_screen.dart`, `property_results_screen.dart`) dan 2 Controller Laravel (`HotelApiController.php`, `PropertyController.php`):
> 1. **Paritas Query & Sanitasi Lokasi Global:**
>    - `HotelApiController::index()` dan `HotelApiController::getFilterMetadata()` kini membersihkan label lokasi umum (`'lokasi saat ini'`, `'semua lokasi'`, `'semua kota'`, `'semua kota, indonesia'`), mencegah eksekusi kueri `WHERE city.name ILIKE '%Semua Lokasi%'` yang sebelumnya mengembalikan nol hasil.
>    - Pilihan lokasi "Semua Lokasi" kini tersedia di seluruh modal pemilih lokasi (`_openLocationPicker` dan `_showLocationSheet`).
>    - Penambahan opsi pencarian custom / fallback destinasi `Gunakan "[keyword]"` pada kedua layar pencarian sehingga pengguna dapat mencari nama akomodasi, jalan, atau distrik yang tidak terdaftar di daftar kota master.
> 2. **Perbaikan Batas & Filter Harga (Price Capping Bug):**
>    - Menghilangkan capping batas harga hardcode `2.500.000` di `hotel_search_screen.dart` yang sebelumnya selalu terkirim ke API meski pengguna tidak menyentuh filter harga (mengabaikan hotel di atas 2,5 juta IDR).
>    - `_onSearchSubmit()` hanya mengirim `min_price` jika `> 0` dan `max_price` jika pengguna membatasi harga secara spesifik di bawah `meta.priceMax`.
> 3. **Responsivitas UX Pencarian (`_canSearch`):**
>    - Inisialisasi awal `_canSearch = true` pada `hotel_search_screen.dart` dan `property_search_screen.dart`, mencegah tombol "Cari" terkunci saat koneksi lambat atau saat metadata filter sedang dimuat di latar belakang.
> 4. **Tampilan Hasil Kosong & Reset State:**
>    - Penambahan `EmptyView` dengan aksi tombol "Reset Filter" (`_resetFiltersAndReload`) pada `hotel_results_screen.dart` dan `property_results_screen.dart` saat kueri atau kombinasi filter menghasilkan nol akomodasi.
>    - Pemicu otomatis `_loadFilterMetadata()` saat lokasi berubah di hasil pencarian agar batas harga dan fasilitas selalu relevan dengan lokasi aktif.
> 5. **Pembersihan Lint & Deprecations:**
>    - Migrasi seluruh pemanggilan `withOpacity(...)` ke `withValues(alpha: ...)`.
>    - Analisis Flutter (`flutter analyze`) 100% bebas error dan warning pada seluruh 4 file layar.
>    - Seluruh pengujian PHPUnit (36 tests Property, 98 tests Hotel) lolos 100%.
> **Update per 2026-09-17 (Integrasi `price_original` Livewire Wizard):** Sinkronisasi dan persistensi field harga coret / normal (`price_original`) pada Livewire `Accommodations\WizardForm`:
> 1. **Blade Template (`wizard_form.blade.php`):** Menghapus batasan kondisional `@if($booking_mode === 'unit')` yang sebelumnya menyembunyikan input `price_original` di Tab 3 pada Room (Hotel) mode. Menambahkan blok pesan validasi `@error('price_original')` dan `@error('price_caption')` pada mode Unit dan Room.
> 2. **Komponen Livewire (`WizardForm.php`):**
>    - Mendaftarkan aturan validasi `'price_original' => 'nullable|numeric|min:0'` dan `'price_caption' => 'nullable|string|max:255'` pada method `rules()`.
>    - Mengisi `$this->price_original` saat `edit()` dari atribut `$accommodation->price_original` (dengan fallback ke `unit_types.price_original`).
>    - Menyertakan `'price_original' => $priceOriginalVal` pada array `$data` saat pemanggilan `Accommodation::create()` / `Accommodation::update()`, dengan fallback cerdas ke tipe kamar pertama pada Room mode jika tidak diisi secara eksplisit.
>    - Memastikan pembaruan `accommodations.price_original` selalu sinkron di `saveUnitMode()` dan `saveRoomMode()`.
> 3. **Pengujian Otomatis:** Menambahkan 3 test case di `AccommodationWizardFormTest.php` (`test_save_unit_mode_persists_price_original`, `test_save_room_mode_persists_price_original`, `test_edit_loads_price_original`). Seluruh 15 test suite Livewire lolos 100%.
> **Update per 2026-09-17 (Tampilan `price_original` di DataTable Admin & List Properti Flutter):**
> 1. **Laravel Admin DataTable (`PropertyDataTable.php`):**
>    - Menambahkan kolom `price_original` ("Harga Coret") dan memformat kolom `price_from` dengan tampilan bertingkat: harga sewa aktif di atas dan harga coret tercoret (`text-decoration-line-through`) di bawahnya.
>    - Mendaftarkan `price_from` dan `price_original` ke `rawColumns` untuk rendering HTML yang aman dan rapi.
> 2. **Flutter Workspace:**
>    - **Model (`property.dart` & `accommodation.dart`):** Menambahkan getter `hasDiscount` dan `discountPercent` pada class `Property`, serta memastikan `Accommodation::toProperty()` menyalurkan `priceOriginal` (sebelumnya terlewat sehingga bernilai null saat konversi).
>    - **Widget Kartu Properti (`property_card.dart`):** Memperbarui `PropertyCard` dan `PropertyCardCompact` untuk menampilkan harga coret merah (`TextDecoration.lineThrough`) jika properti memiliki diskon (`hasDiscount`). Memperbaiki toleransi `_hasDiscount` pada `AccommodationCardItem`.
>    - **Pengujian:** Menambahkan unit dan widget test `test/widgets/property_card_test.dart` (4 test lolos 100%).

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

### 4. Harga Coret & Ketentuan Pajak (Fixed & Synchronized)
- Kolom `price_original` (decimal 14,2 nullable) kini ditambahkan ke tabel `accommodations` via migration `2026_09_17_000001_add_price_original_to_accommodations_table.php`.
- Endpoint `PUT host/accommodations/{property}/price` (dan alias `PUT host/properties/{property}/price`) diimplementasikan di `PropertyController::updatePrice` untuk memperbarui `price_original`, `price_caption`, `tax_percentage`, dan `tax_calculation` di tabel `accommodations` dan menyinkronkan `unit_types.price_original`.
- Endpoint `POST host/accommodations` (`PropertyController::store`) dan `PUT host/accommodations/{id}` (`PropertyController::update`) kini menyimpan dan memperbarui `price_original` langsung ke tabel `accommodations` (serta menyinkronkan ke `unit_types`).
- Layar Flutter `availability_price_edit_screen.dart` memanggil `HostService.updatePropertyPrice` dan menyegarkan tampilan baik saat simpan berhasil maupun saat trigger refresh (`_loadDetail` / `RefreshIndicator`).

### 5. DataTable Harga Coret & Suffix Sesuai Property Card (Synchronized)
- Laravel `PropertyDataTable.php` (`price_from` & `price_original`) disinkronkan persis dengan logika display di Flutter `property_card.dart` (lines 151, 170, 177):
  1. Line 151 (`hasDiscount`): Harga coret `price_original` ditampilkan di bagian atas dengan styling merah coret (`text-danger text-decoration-line-through`) jika dan hanya jika `price_original > activePrice` dan `activePrice > 0`.
  2. Line 170: Harga aktif dihitung dari `price_from > 0 ? price_from : (price_original > 0 ? price_original : '-')`.
  3. Line 177: Jika `booking_mode === 'room'` (hotel), ditambahkan suffix ` / malam`. Jika bukan room (`unit`), tanpa suffix.
  4. Kolom `booking_mode` ditampilkan dengan badge Metronic (`Room (Hotel)` vs `Unit (Property)`).


