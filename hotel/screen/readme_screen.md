# 🏨 MASTER REFERENCE — Hotel Screen, Kontrak API & Payload

> **Status:** FASE 1 (Audit & Dokumentasi) — **SELESAI**
> **Tanggal audit:** 2026-08-16
> **Peran dokumen:** **Pusat Referensi Utama (Master Reference)** untuk seluruh implementasi Flutter & Laravel modul Hotel.
> **Ruang lingkup:** 40 layar/komponen hotel (search → filter → hasil → detail → pesan kamar → pembayaran → detail booking).

Semua angka, nama file, warna, dan nama field pada dokumen ini **diverifikasi langsung** dari filesystem, dari HTML mockup di `_build/html/`, dan dari kode Laravel/Flutter yang ada. Klaim yang belum terverifikasi ditandai `⚠️ BELUM DIVERIFIKASI`.

---

## 0. Cara Pakai Dokumen Ini

| Kalau kamu mau… | Buka bagian |
|---|---|
| Tahu file gambar/HTML mana yang jadi acuan sebuah layar | [§3 Inventaris Aset](#3-inventaris-aset-terverifikasi) |
| Tahu aset mana yang rusak/hilang/salah nama | [§4 Log Anomali](#4-log-anomali-aset--dokumentasi) |
| Bangun satu layar Flutter | [§6 Analisis Detail Per Layar](#6-analisis-detail-per-layar) → cari nomor layar |
| Tahu warna/font yang benar | [§7 Design System](#7-design-system) |
| Tahu widget mana yang harus dibuat sekali & dipakai ulang | [§8 Komponen Reusable](#8-komponen-reusable) |
| Paham beda Booking Hotel vs Booking Properti biasa | [§10 Pemisahan Domain](#10-pemisahan-domain-booking-hotel-vs-booking-properti) ← **WAJIB BACA** |
| Tahu endpoint & payload yang benar | [§11 Kontrak API](#11-kontrak-api--log-drift) + [§12 Dummy JSON](#12-dummy-json-payload-per-form) |
| Lihat struktur HTML acuan untuk sebuah komponen | [§13 Referensi Struktur HTML](#13-referensi-struktur-html) |
| Mulai coding Fase 2 | [§15 Checklist Fase 2](#15-checklist-fase-2) |

**Aturan emas:**
1. Kalau HTML mockup dan gambar JPEG berbeda → **HTML menang** (HTML adalah sumber render PNG terbaru).
2. Kalau dokumen ini dan `docs/hotel/01`–`07` berbeda → **dokumen ini menang** (lalu perbaiki 01–07).
3. Kalau dokumen ini dan kode Laravel berbeda → cek [§11](#11-kontrak-api--log-drift); drift sudah dicatat, jangan diam-diam ubah kontrak.

**Panduan Visual Alternatif:** kalau struktur layar atau bottom sheet terasa membingungkan, buka file HTML di `docs/hotel/screen/_build/html/` sebagai acuan, atau verifikasi langsung gambar pada folder screen terkait.

---

## 1. Peta Dokumen Terkait

| # | File | Isi | Relasi ke dokumen ini |
|---|---|---|---|
| — | **`docs/hotel/screen/readme_screen.md`** | ← **file ini** — layar, aset, payload, design system | Master |
| 01 | `docs/hotel/01-database-migration.md` | Struktur 47 migration, tabel hotel/room_type/room/room_inventory, matriks relasi (§3 baris 474), indeks (§4 baris 508) | Sumber nama kolom di [§11](#11-kontrak-api--log-drift) |
| 02 | `docs/hotel/02-models-relationships.md` | Eloquent model + relasi, observer, scope | Sumber relasi `Booking → bookingRooms → roomType` |
| 03 | `docs/hotel/03-query-filters.md` | Query pencarian & filter; §5 (baris 279) Alur Pemesanan Hotel & Kalkulasi Asuransi | Sumber logika filter di layar #7–#11 |
| 04 | `docs/hotel/04-flutter-implementation.md` | Struktur Flutter; §8 (baris 519) daftar berkas layar Flutter | Sumber peta implementasi [§14](#14-peta-implementasi-flutter) |
| 05 | `docs/hotel/05-insurance-integration.md` | `insurance_providers`, `insurance_plans`, `booking_insurances`, `calculatePremium()` | Sumber field asuransi di [§12](#12-dummy-json-payload-per-form) |
| 06 | `docs/hotel/06-hotel-management-flow.md` | Alur mitra: kelola hotel, room type, allotment | Di luar cakupan layar konsumen |
| 07 | `docs/hotel/07-compatibility-map.md` | §4 (baris 130) Tampilan & Opsi Asuransi; §5 (baris 173) Matriks Integrasi 3 Domain | Sumber kompatibilitas hotel ↔ properti |
| — | `docs/flutter/screens.md` | Registry global layar Flutter | ✅ **Sudah disinkronkan** 16 Agt 2026 ([A-11](#4-log-anomali-aset--dokumentasi) beres) |
| — | `docs/hotel/screen/_build/manifest.json` | 40 entri render HTML→PNG (390×844) | Sumber tabel [§3.3](#33-tabel-silang-html--png--jpeg-40-baris) |

---

## 2. Ringkasan Temuan Audit (Executive Summary)

| Kategori | Angka | Catatan |
|---|---|---|
| File HTML mockup (`_build/html/`) | **40** | 1:1 dengan manifest |
| Entri `manifest.json` | **40** | ✅ konsisten dengan HTML |
| File PNG render (`_build_image/`) | **41** | ⚠️ 1 orphan → [A-04](#4-log-anomali-aset--dokumentasi) |
| File JPEG screenshot asli | **48** | tersebar di 4 folder |
| **Total aset gambar** | **89** | 41 PNG + 48 JPEG |
| Layar Flutter hotel yang sudah ada | **4** | `hotel_search`, `hotel_results`, `hotel_detail`, `hotel_booking` |
| Anomali tercatat | **21** | A-01 … A-21 (A-11 … A-18 sudah beres; A-19 … A-21 ditemukan saat [F-7](#152-flutter)) |
| Drift kontrak API tercatat | **16** | A-D1 … A-D16 (A-D11 … A-D16 ditemukan saat Fase 2, bukan Fase 1) |
| Endpoint API yang dipanggil Flutter tapi **tidak ada** di Laravel | **2** | `GET hotel/filters`, `POST hotel/bookings` |
| Test Flutter yang sudah ada | **17 file** | saat Fase 1: **99 test**, **6 file sudah menyentuh Hotel/asuransi**; setelah Fase 2: **20 file / 209 deklarasi `test(` → 273 test saat dijalankan** (+3 file baru: `models/special_request_test.dart`, `models/promo_voucher_test.dart`, `services/voucher_service_test.dart`, ditambah helper `test/support/fake_voucher_api.dart` yang tidak berisi test) → [§15.3](#153-test--wajib-permintaan-eksplisit-pengguna) |
| Test Laravel hotel yang sudah ada | **7 file** | +3 file baru & +15 test di `HotelApiTest.php` pada Fase 2 → [§15.3](#153-test--wajib-permintaan-eksplisit-pengguna) |

**3 temuan paling penting:**
1. 🔴 **`guests[]` melewati kontrol allotment.** Di `BookingController::storeHotelBooking()`, cabang `if (!empty($guests))` **tidak** melakukan `lockForUpdate()` maupun `increment('booked_count')` pada `room_inventories`. Hanya cabang `else if ($roomType)` yang mengunci inventori. Artinya form multi-kamar (layar #28–#32, yang **selalu** mengirim `guests[]`) bisa overbooking.
2. 🔴 **2 endpoint hantu.** `HotelService.getHotelFilters()` dan `HotelService.createHotelBooking()` ada di `dummy_api_client.dart` tetapi **tidak ada route-nya** di `routes/api_mobile.php` → 404 saat mode API nyata.
3. 🟠 **Provider bypass.** `HotelSearchProvider` memakai `PropertyService.searchHotels()` (`GET properties`), bukan `HotelService` (`GET hotels`) — sehingga menyimpan `Paginated<Property>` bukan `Paginated<Hotel>` dan kehilangan field khusus hotel.

---

## 3. Inventaris Aset Terverifikasi

### 3.1 Struktur folder nyata

> ⚠️ **PENTING:** tiga folder memiliki **sufiks literal ` (folder)`** pada nama direktori di disk. Path yang menghilangkan sufiks ini **tidak valid**. Lihat [A-01](#4-log-anomali-aset--dokumentasi).

```
docs/hotel/screen/
├── readme_screen.md                    ← file ini
├── booking/                            (7 JPEG)   ✅ nama bersih
├── detail_hotel (folder)/              (25 JPEG)  ⚠️ sufiks " (folder)"
├── filter_hotel (folder)/              (6 JPEG)   ⚠️ sufiks " (folder)"
├── result_filter_hotel (folder)/       (10 JPEG)  ⚠️ sufiks " (folder)"
├── _build/
│   ├── manifest.json                   (40 entri)
│   ├── *.mjs                           (skrip render HTML→PNG)
│   └── html/                           (40 HTML, 390×844)
└── _build_image/                       (41 PNG)   ⚠️ 1 orphan
```

| Folder | JPEG | Cakupan |
|---|---|---|
| `booking/` | 7 | daftar booking, pembayaran, detail booking hotel |
| `detail_hotel (folder)/` | 25 | halaman detail hotel + 8 tab + sheet kamar + form pesan kamar |
| `filter_hotel (folder)/` | 6 | layar pencarian awal: lokasi, kalender, tanggal fleksibel, kamar & tamu |
| `result_filter_hotel (folder)/` | 10 | hasil pencarian + 4 bottom sheet filter + top modal tanggal/tamu |
| **Total JPEG** | **48** | |

### 3.2 Spesifikasi render

Semua entri `manifest.json` memakai viewport identik:

```json
{ "screen": "<slug>", "file": "<slug>.html", "outName": "<nama>.png", "w": 390, "h": 844 }
```

- **390 × 844 px** = iPhone 13/14 logical size → jadikan ini baseline layout Flutter.
- `w`/`h` konstan di **40/40** entri → tidak ada layar dengan viewport khusus.

### 3.3 Tabel silang HTML ↔ PNG ↔ JPEG (40 baris)

Kolom **JPEG** = screenshot asli sebagai pembanding. `—` = tidak ada padanan JPEG.

| # | `screen` (slug HTML) | PNG (`outName`) | JPEG padanan | Folder JPEG |
|---|---|---|---|---|
| 1 | `filter_location` | `filter_location.png` | `filter_by_lokasi_screen.jpeg` | `filter_hotel (folder)` |
| 2 | `filter_screen` | `filter_screen.png` | `filter_screen.jpeg` | `filter_hotel (folder)` |
| 3 | `filter_kamar_tamu` | `filter_kamar_tamu.png` | `filter_kamar_dan_tamu_screen.jpeg` | `filter_hotel (folder)` ⧉ |
| 4 | `filter_kamar_tamu_bottom_modal_select_anak` | `filter_kamar_tamu_bottom_modal_select_anak.png` | `show_modal_bottom/select_umur_anak.jpeg` | `filter_hotel (folder)` ⧉ |
| 5 | `filter_kalendar` | `filter_by_tab_kalendar_screen.png` | `filter_by_tab_kalendar_screen.jpeg` | `filter_hotel (folder)` ⧉ |
| 6 | `filter_kalendar_tanggal_flexibel` | `filter_by_tab_tanggal_flexibel_screen.png` | `filter_by_tab_tanggal_flexibel_screen.jpeg` | `filter_hotel (folder)` ⧉ |
| 7 | `result_pencarian` | `result_pencarian.png` | `result_pencarian_screen.jpeg` | `result_filter_hotel (folder)` |
| 8 | `result_pencarian_bottom_modal_filter` | `result_pencarian_bottom_modal_filter.png` | `bottom_modal_filter.jpeg` | `result_filter_hotel (folder)` |
| 9 | `result_pencarian_bottom_modal_filter_kebutuhan` | `result_pencarian_bottom_modal_filter_kebutuhan.png` | `bottom_modal_filter_kebutuhan.jpeg` | `result_filter_hotel (folder)` |
| 10 | `result_pencarian_bottom_modal_filter_urutkan` | `result_pencarian_bottom_modal_filter_urutkan.png` | `bottom_modal_filter_urutkan.jpeg` | `result_filter_hotel (folder)` |
| 11 | `result_pencarian_bottom_modal_filter_lokasi` | `result_pencarian_bottom_modal_filter_lokasi.png` | `bottom_modal_filter_lokasi.jpeg` | `result_filter_hotel (folder)` |
| 12 | `result_pencarian_top_modal_filter_date_and_tamu` | `result_pencarian_top_modal_filter_date_and_tamu.png` | `top_modal_filter_date_and_tamu.jpeg` | `result_filter_hotel (folder)` |
| 13 | `result_pencarian_top_modal_filter_date_and_tamu_kalendar` | `..._kalendar.png` | `filter_by_tab_kalendar_screen.jpeg` | `result_filter_hotel (folder)` ⧉ |
| 14 | `result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel` | `..._tanggal_flexibel.png` | `filter_by_tab_tanggal_flexibel_screen.jpeg` | `result_filter_hotel (folder)` ⧉ |
| 15 | `result_pencarian_top_modal_filter_date_and_tamu_2nd` | `..._2nd.png` | `filter_kamar_dan_tamu_screen.jpeg` | `result_filter_hotel (folder)` ⧉ |
| 16 | `result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak` | `..._2nd_bottom_modal_select_anak.png` | `show_modal_bottom/select_umur_anak.jpeg` | `result_filter_hotel (folder)` ⧉ |
| 17 | `detail_hotel` | `detail_hotel_screen.png` | `detail_hotel_screen.jpeg` | `detail_hotel (folder)` |
| 18 | `detail_tab_kamar` | `detail_hotel_screen_tab_kamar.png` | `detail_hotel_screen_tab_kamar.jpeg` | `detail_hotel (folder)` |
| 19 | `detail_tab_ulasan` | `detail_hotel_screen_tab_ulasan.png` | `detail_hotel_screen_tab_ulasan.jpeg` | `detail_hotel (folder)` |
| 20 | `detail_tab_lokasi` | `detail_hotel_screen_tab_lokasi.png` | `detail_hotel_screen_tab_lokasi.jpeg` | `detail_hotel (folder)` |
| 21 | `detail_tab_fasilitas` | `detail_hotel_screen_tab_fasilitas.png` | `detail_hotel_screen_tab_fasilitas.jpeg` | `detail_hotel (folder)` |
| 22 | `detail_tab_kebijakan` | `detail_hotel_screen_tab_kebijakan.png` | `detail_hotel_screen_tab_kebijakan.jpeg` | `detail_hotel (folder)` |
| 23 | `detail_tab_keterangan` | `detail_hotel_screen_tab_keterangan.png` | `detail_hotel_screen_tab_keterangan.jpeg` | `detail_hotel (folder)` |
| 24 | `detail_tab_trip_moments` | `detail_hotel_screen_tab_trip_moments.png` | `detail_hotel_screen_tab_trip_moments.jpeg` | `detail_hotel (folder)` |
| 25 | `detail_tab_akomodasi_terdekat` | `detail_hotel_screen_tab_akomodasi_terdekat.png` | `detail_hotel_screen_tab_akomodasi_terdekat.jpeg` | `detail_hotel (folder)` |
| 26 | `pesan_kamar_section` | `detail_hotel_screen_saat_mau_pilih_button_pesan_kamar.png` | **TIDAK ADA** ⚠️ [A-02](#4-log-anomali-aset--dokumentasi) | — |
| 27 | `sheet_pesan_kamar` | `sheet_pesan_kamar.png` | `form_pesan_kamar.jpeg` ⚠️ [A-05](#4-log-anomali-aset--dokumentasi) | `detail_hotel (folder)` |
| 28 | `form_pengisian_kamar` | `form_pesan_kamar_form_pengisian_kamar.png` | **TIDAK ADA** ⚠️ [A-03](#4-log-anomali-aset--dokumentasi) | — |
| 29 | `form_pengisian_kamar_scroll` | `form_pesan_kamar_form_pengisian_kamar_scroll.png` | **TIDAK ADA** ⚠️ [A-03](#4-log-anomali-aset--dokumentasi) | — |
| 30 | `form_pesan_kamar_step1` | `form_pesan_kamar_step1.png` | `form_pesan_kamar_1.jpeg` | `detail_hotel (folder)` |
| 31 | `form_pesan_kamar_step2` | `form_pesan_kamar_step2.png` | `form_pesan_kamar_2.jpeg` | `detail_hotel (folder)` |
| 32 | `form_pesan_kamar_step3` | `form_pesan_kamar_step3.png` | `form_pesan_kamar_3.jpeg` | `detail_hotel (folder)` |
| 33 | `bottom_sheet_informasi_tambahan` | `bottom_sheet_informasi_tambahan.png` | `bottom_sheet_informasi_tambahan.jpeg` | `detail_hotel (folder)` |
| 34 | `room_detail_family_suite` | `room_detail_family_suite.png` ⚠️ **stub** [A-19](#4-log-anomali-aset--dokumentasi) | `form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/tab_family_suite/{1..4}.jpeg` (4 langkah scroll) ⚠️ [A-20](#4-log-anomali-aset--dokumentasi) | `detail_hotel (folder)` |
| 35 | `room_detail_kamar_superior` | `room_detail_kamar_superior.png` | `form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/tab_kamar_superior/{1..4}.jpeg` (4 langkah scroll) ⚠️ [A-20](#4-log-anomali-aset--dokumentasi) | `detail_hotel (folder)` |
| 36 | `bottom_sheet_kode_promo` | `bottom_sheet_kode_promo.png` | `bottom_sheet_kode_promo.jpeg` | `detail_hotel (folder)` |
| 37 | `bottom_sheet_permintaan` | `bottom_sheet_permintaan.png` | `bottom_sheet_permintaan.jpeg` | `detail_hotel (folder)` |
| 38 | `booking_list_screen` | `booking_list_screen.png` | `booking_list_screen.jpeg` | `booking/` |
| 39 | `booking_pembayaran_screen` | `booking_pembayaran_screen.png` | `booking_pembayaran_screen.jpeg` | `booking/` |
| 40 | `booking_hotel_detail_screen` | `booking_hotel_detail_screen.png` | `booking_hotel_detail_screen.jpeg` | `booking/` |

**Legenda:** ⧉ = aset dipakai ganda (satu picker diakses dari dua entry point) → lihat [A-06](#4-log-anomali-aset--dokumentasi).

**PNG ke-41 (orphan):** `_build_image/form_pesan_kamar.png` — tidak ada HTML sumber, tidak ada entri manifest → [A-04](#4-log-anomali-aset--dokumentasi).

---

## 4. Log Anomali Aset & Dokumentasi

| ID | Tingkat | Anomali | Bukti | Tindakan yang disarankan |
|---|---|---|---|---|
| **A-01** | 🟠 Sedang | Tiga direktori punya **sufiks literal ` (folder)`**: `detail_hotel (folder)`, `filter_hotel (folder)`, `result_filter_hotel (folder)`. Hanya `booking/` bersih. | Listing filesystem | **Jangan rename saat Fase 2** (path lama di 01–07 akan pecah). Rename terpisah + sweep referensi, atau biarkan dan selalu pakai nama lengkap. Dokumen ini memakai nama lengkap. |
| **A-02** | 🔴 Tinggi | `detail_hotel_screen_saat_mau_pilih_button_pesan_kamar.jpeg` dirujuk **dua kali** oleh readme versi lama di path yang saling bertentangan (`…/sheet_modal_button_pesan_kamar/…` dan `…/form_pesan_kamar_screen/…`) dan **tidak ada di keduanya**. | Readme lama baris 35 & 484 | Hanya PNG-nya yang ada. Gunakan PNG + HTML `pesan_kamar_section.html` sebagai acuan. Referensi JPEG sudah dihapus dari tabel [§3.3](#33-tabel-silang-html--png--jpeg-40-baris). |
| **A-03** | 🔴 Tinggi | Baris registry lama merujuk `form_pesan_kamar_form_pengisian_kamar.jpeg` dan `…_scroll.jpeg` — **keduanya tidak ada di disk**. Folder nyata hanya punya `form_pesan_kamar.jpeg`, `_1`, `_2`, `_3`. | Listing `detail_hotel (folder)` | Acuan = PNG + HTML `form_pengisian_kamar.html` / `form_pengisian_kamar_scroll.html`. Sudah dikoreksi di [§3.3](#33-tabel-silang-html--png--jpeg-40-baris) baris 28–29. |
| **A-04** | 🟡 Rendah | Orphan render `_build_image/form_pesan_kamar.png` — tanpa HTML sumber & tanpa entri manifest (41 PNG vs 40 HTML/manifest). | Glob PNG vs manifest | Sisa render lama. Hapus, atau tambahkan HTML+manifest bila memang layar terpisah. Jangan dipakai sebagai acuan. |
| **A-05** | 🟡 Rendah | Registry `sheet_pesan_kamar` menunjuk JPEG `form_pesan_kamar.jpeg`, sedangkan `outName` manifest `sheet_pesan_kamar.png` → penamaan terbelah antara era JPEG dan era HTML. | manifest #27 | Anggap keduanya layar yang sama (bottom sheet ringkasan pesan kamar). Nama kanonik = slug HTML `sheet_pesan_kamar`. |
| **A-06** | 🟡 Rendah | 4 pasang aset **duplikat nama** antara `filter_hotel (folder)` dan `result_filter_hotel (folder)`: `filter_by_tab_kalendar_screen.jpeg`, `filter_by_tab_tanggal_flexibel_screen.jpeg`, `filter_kamar_dan_tamu_screen.jpeg`, `show_modal_bottom/select_umur_anak.jpeg`. | Listing kedua folder | **Bukan bug** — picker yang sama diakses dari 2 entry point (pencarian awal & top-modal di hasil). Di Flutter cukup **1 widget** dipakai 2 kali → [§8](#8-komponen-reusable). |
| **A-07** | 🟡 Rendah | Penomoran per-layar readme lama melompat (#11 → #16; 12–15 hilang). | Readme lama | **Sudah diperbaiki**: [§6](#6-analisis-detail-per-layar) memakai penomoran 1–40 kontinu, 1 nomor = 1 entri manifest. |
| **A-08** | 🟠 Sedang | Readme lama mendokumentasikan dependency Flutter `top_modal_sheet: ^2.1.0` yang **tidak ada** di `flutter/pubspec.yaml`. | `pubspec.yaml` | Top modal (layar #12–#16) harus dibuat manual (`showGeneralDialog` + `SlideTransition` dari atas) **atau** tambahkan paketnya di Fase 2. Jangan asumsikan tersedia. |
| **A-09** | 🟡 Rendah | Registry lama punya **39 baris** vs **40 entri** manifest — `filter_kalendar_screen` menggabungkan 2 entri manifest jadi 1 baris. | Registry lama vs manifest | **Sudah diperbaiki**: [§3.3](#33-tabel-silang-html--png--jpeg-40-baris) = 40 baris, tab kalender & tanggal-fleksibel dipisah (#5 dan #6). |
| **A-10** | 🟠 Sedang | **Kebocoran branding pihak ketiga.** HTML mockup menulis literal `Trip.com` pada teks Syarat & Ketentuan dan memakai istilah `Trip Coins` / `Trip Moments`. | `form_pesan_kamar_step3.html:66-67`, `detail_tab_trip_moments.html` | Aplikasi bernama **Sewain**. Saat implementasi: ganti "Trip.com" → "Sewain". Istilah `Trip Coins` **boleh dipertahankan** karena sudah jadi nama kolom DB (`bookings.trip_coins_earned`) — konsistensi DB lebih penting; ganti hanya label UI bila diminta. |
| **A-11** | ✅ **BERES** | `docs/flutter/screens.md` **kontradiktif & basi**: TOC baris 20 "C. Hotel OTA (Planned -- Belum Dibuat)" vs heading baris 114 "C. Hotel OTA (Screens Selesai Dibuat)" (anchor pecah); baris 210 `hotel/ (0 file) ❌ 6 screen planned` (salah — **4 file ada**); baris 224 "6 Hotel OTA belum didaftarkan" (salah — **semua route sudah terdaftar** di `router.dart`); baris 231–233 catatan basi. | `docs/flutter/screens.md` | **Sudah disinkronkan 16 Agt 2026** — detail di [§16](#16-daftar-sinkronisasi-dokumen-lanjutan). |
| **A-12** | ✅ **BERES** | **Test hijau memaku endpoint hantu.** Dua test di `flutter/test/services/hotel_service_test.dart` memakai `expectedPath: 'hotel/bookings'` — endpoint yang tidak ada di Laravel ([A-D5](#113-drift-kontrak-flutter--laravel)). Karena `_CapturingTransport` hanya menangkap body bila path cocok, `expect(capturedBody, isNotNull)` akan gagal saat A-D5 diperbaiki. | `flutter/test/services/hotel_service_test.dart` | **Sudah diperbaiki 16 Agt 2026** bersama [F-3](#152-flutter): `expectedPath` → `bookings`, dan `_CapturingTransport` sekarang merekam `capturedPath` **tanpa syarat** sehingga endpoint diasersi langsung, bukan disimpulkan dari `capturedBody != null`. Status per ID: [T-F4 di §15.3](#153-test--wajib-permintaan-eksplisit-pengguna). |
| **A-13** | ✅ **BERES** | **Guard test menghadap arah yang salah.** `flutter/test/api_envelope_test.dart` menjaga *route dummy ↔ fixture asset*, tetapi tidak ada test yang membandingkan route yang dipanggil Flutter dengan `routes/api_mobile.php` — itulah sebab A-D4 & A-D5 tidak pernah tertangkap. | `flutter/test/api_envelope_test.dart` | **Sudah ditambah 16 Agt 2026** (T-F18): grup `hotel bookings ride on POST bookings` mematok `POST hotel/bookings` **wajib 404** dan body ber-`hotel_id` diterima di `POST bookings`. Route hantu tak bisa hidup kembali tanpa memecahkan test. Catatan penting: guard yang **sudah ada** ternyata sudah menangkap A-D4 — lihat [A-14](#4-log-anomali-aset--dokumentasi). |
| **A-14** | 🟠 Sedang | **Suite Flutter sudah merah sebelum Fase 2 dimulai — tanpa disadari.** Guard `every route in the table is covered by this test` ([`api_envelope_test.dart:120-125`](../../../flutter/test/api_envelope_test.dart)) menuntut setiap kunci `DummyApiClient.routes` punya pasangan di map `requests` milik test. Route hantu `GET hotel/filters` **ada** di tabel route tapi **tidak pernah** ditambahkan ke `requests`, jadi `untested` tidak kosong dan test itu gagal. Guard-nya bekerja benar; yang tidak berjalan adalah kebiasaan menjalankan suite-nya. | `flutter/test/api_envelope_test.dart:120-125` vs `DummyApiClient.routes` | ✅ **BERES** — route hantu dihapus bersama [L-2](#151-laravel), sehingga guard hijau kembali tanpa mengubah test-nya. Pelajaran: **A-D4 dan A-D5 sebenarnya tertangkap alat yang sudah ada** — kegagalannya adalah proses, bukan cakupan test. Jalankan `flutter test` sebelum menandai item apa pun selesai. |
| **A-15** | 🔴 Tinggi | **Layar detail hotel tak terjangkau dari mana pun di aplikasi.** Kartu hasil pencarian di `hotel_results_screen.dart` mem-`pushNamed(Routes.propertyDetail)` — layar sewa **unit** generik — padahal `Routes.hotelDetail` sudah terdaftar di `router.dart`. Jadi 8 tab hotel, kartu rekomendasi, dan tombol "Pesan kamar" hanya bisa dicapai lewat panggilan manual dari kode, bukan dari alur pengguna. Query pencarian pun ikut hilang di gerbang: `propertyDetail` tidak menerima `HotelSearchQuery`. | [`hotel_results_screen.dart:948-949`](../../../flutter/lib/screens/property/hotel/hotel_results_screen.dart#L948-L949) (setelah perbaikan) vs `Routes.hotelDetail` di [`router.dart`](../../../flutter/lib/router.dart) | ✅ **BERES 16 Agt 2026** bersama [F-8](#152-flutter) — kartu kini push `Routes.hotelDetail` dengan `HotelDetailArgs(hotel: h, hotelId: h.id, query: _currentQuery)`. **Pelajaran:** route yang terdaftar bukan bukti route itu terpakai; audit Fase 1 mencatat "semua route sudah terdaftar" ([A-11](#4-log-anomali-aset--dokumentasi)) dan itu benar — tapi tak satu pun memeriksa siapa yang memanggilnya. |
| **A-16** | 🔴 Tinggi | **Tiap tipe kamar berbentuk-DB dihargai Rp 0.** `HotelRoomItem.fromJson` membaca `base_price`/`price_original` dengan `as num?`, sedangkan `RoomType` memberi keduanya cast `decimal:2` → Laravel mengirimnya sebagai **string** (`"446637.00"`). Cast Dart `as num?` pada `String` menghasilkan `null` tanpa exception, jadi harga jatuh ke `0.0` **secara diam-diam**. Tak terdeteksi karena fixture dummy memakai `price` (angka), sementara API nyata `GET hotels/{hotel}` memancarkan `active_room_types[].base_price` (string) lewat `$rt->toArray()`. | [`RoomType.php:45`](../../../laravel/app/Models/RoomType.php#L45) `'price_original' => 'decimal:2'` · [`HotelApiController.php:180`](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L180) `$rt->toArray()` · bukti langsung: [`HostHotelTest.php:294`](../../../laravel/tests/Feature/Api/HostHotelTest.php#L294) mengasersi `data.price_original` = **`'1200000.00'`** (string) | ✅ **BERES 16 Agt 2026** bersama [F-8](#152-flutter) — helper `HotelRoomItem._toDouble()` menerima `num` **dan** `String`, dipakai untuk `price`/`base_price`/`price_original`. Dipatok T-F28. **Pelajaran:** setiap kolom `decimal:*` menyeberang ke Dart sebagai string — jangan pakai `as num?` untuk uang. |
| **A-17** | 🟡 Rendah | Pil tanggal di hasil pencarian merender `checkIn.substring(5)` → tampil **`08-28`**, bukan `28 Agt`; dan membaca `widget.query` sementara baris kota di sebelahnya membaca `_currentQuery`, jadi kedua paruh pil itu **berbeda** setelah tanggal diubah in-place lewat top modal. | [`hotel_results_screen.dart:733,737`](../../../flutter/lib/screens/property/hotel/hotel_results_screen.dart#L733-L737) (setelah perbaikan) | ✅ **BERES 16 Agt 2026** bersama [F-8](#152-flutter) — keduanya kini `Formatters.isoDayMonthShort(_currentQuery.…)`. Formatter ditulis tangan (bukan `DateFormat(..., 'id_ID')`) karena intl butuh `initializeDateFormatting` yang tak pernah jalan di widget test, **dan** intl menyingkat Agustus `Agu` sedangkan mockup menulis `Agt`. Dipatok T-F19 + T-F31. |
| **A-18** | 🟠 Sedang | **Satu test Laravel yang tidak mungkin hijau — sejak sebelum Fase 2.** `HotelApiTest::test_search_filters_by_star_rating` membuat hotel bintang-3 kedua di atas `$this->property->id` yang **sama**, padahal `hotels.property_id` punya index **UNIQUE** → `Hotel::create()` melempar constraint violation sebelum request pertama dikirim (SQLite **menegakkan** UNIQUE, tidak seperti CHECK). Lapis kedua: hotel baru itu juga tidak punya `RoomType` aktif, dan `GET hotels` hanya mengembalikan hotel yang punya minimal satu — jadi bahkan tanpa constraint, asersi "hotel bintang-3 tidak muncul di `star_rating[]=4`" akan hijau **tanpa** filter bintang bekerja sama sekali. | [`2026_08_13_000002_create_hotels_table.php:12`](../../../laravel/database/migrations/2026_08_13_000002_create_hotels_table.php#L12) `->unique()` · [`HotelApiTest.php:164-181`](../../../laravel/tests/Feature/Api/HotelApiTest.php#L164-L181) | ✅ **BERES 16 Agt 2026** bersama [F-13](#152-flutter) — helper baru `createHotel(starRating:, name:, basePrice:)` memberi setiap hotel fixture **Property sendiri + satu RoomType aktif**, jadi filter bintang benar-benar diuji. **Pelajaran:** ini bukti kedua (setelah [A-14](#4-log-anomali-aset--dokumentasi)) bahwa suite ini merah tanpa disadari; angka test di dokumen ini adalah hasil **pembacaan kode**, bukan eksekusi — lihat baris terakhir [§17](#17-riwayat-audit). |
| **A-19** | 🟠 Sedang | **Satu dari 40 HTML mockup adalah stub kosong.** [`_build/html/room_detail_family_suite.html`](_build/html/room_detail_family_suite.html) berisi `<head>` lengkap (font, CSS, viewport 390×844) tetapi **`<body>undefined</body>`** — skrip render menuliskan literal `undefined`, artinya layar #34 tidak pernah punya sumber HTML. PNG `room_detail_family_suite.png` yang ada di `_build_image/` adalah render dari stub itu, jadi ia **juga** kosong. | [`room_detail_family_suite.html:20`](_build/html/room_detail_family_suite.html#L20) vs [`room_detail_kamar_superior.html`](_build/html/room_detail_kamar_superior.html) yang lengkap (152 baris) | ✅ **DITANGANI 16 Agt 2026 saat [F-7](#152-flutter)** — tidak dengan menambal HTML-nya, melainkan dengan memakai **#35 sebagai satu-satunya acuan struktur** dan 8 JPEG di [A-20](#4-log-anomali-aset--dokumentasi) untuk isi tab Family Suite. Ini konsisten dengan temuan struktural F-7: #34 dan #35 **bukan dua layar**, melainkan dua state pil dari **satu** sheet (lihat [§6 #34/#35](#grup-d--pilih--pesan-kamar-2637)) — jadi stub itu bukan kehilangan layar, hanya kehilangan render state kedua. Bila mau dibereskan: render ulang dari HTML #35 dengan pil `Family Suite` aktif. |
| **A-20** | 🔴 Tinggi | **Kolom JPEG baris #34 & #35 menunjuk 2 file yang tidak ada, sementara 8 file yang benar tak pernah tercatat.** Tabel [§3.3](#33-tabel-silang-html--png--jpeg-40-baris) menulis `detail_kamar_family_suite.jpeg` dan `detail_kamar_superior.jpeg` di `detail_hotel (folder)`; glob `**/detail_kamar*` di seluruh `docs/hotel/screen` → **0 hasil**. Screenshot aslinya ada, tapi **empat tingkat lebih dalam** dan dalam bentuk 4+4 langkah scroll: `detail_hotel (folder)/form_pesan_kamar_screen/show_modal_bottom_full/bottom_screen_kamar_superior/{tab_kamar_superior,tab_family_suite}/{1,2,3,4}.jpeg`. | Glob `**/detail_kamar*` → kosong · Glob `**/*kamar_superior*/**/*.jpeg` → **8 file** | ✅ **DIKOREKSI 16 Agt 2026** — [§3.3](#33-tabel-silang-html--png--jpeg-40-baris) baris #34/#35 kini menunjuk folder yang benar. **Nilai temuannya bukan path**: nama folder induknya (`form_pesan_kamar_screen/show_modal_bottom_full/`) adalah bukti langsung bahwa sheet ini dibuka **dari form pesan kamar** dan **penuh tinggi**, dan dua subfolder `tab_*` di dalam **satu** folder `bottom_screen_kamar_superior` adalah bukti "satu sheet, dua tab" — dua fakta yang menentukan bentuk komponen [C-39](#8-komponen-reusable) dan tak satu pun bisa dibaca dari HTML. Total JPEG **48** tidak berubah (8 file ini sudah terhitung di `detail_hotel (folder)`). |
| **A-21** | 🟡 Rendah | **Deskripsi #34 di §6 menjanjikan CTA yang tidak ada di aset mana pun.** Baris lama berbunyi "…kebijakan (`Tidak dapat di-refund`), sarapan berbayar `Rp108.900`, **CTA pilih**". HTML #35 berakhir di catatan biaya sarapan lalu menutup `.scroll`/`.body` — **tidak ada** `.btn`, tidak ada bottom bar; langkah scroll ke-4 di kedua folder `tab_*` juga berakhir tanpa tombol. Sheet ini **read-only**: kamar dipilih di layar induk (#26/#28), bukan di sini. | [`room_detail_kamar_superior.html:147-152`](_build/html/room_detail_kamar_superior.html#L147-L152) (penutup, tanpa tombol) vs `.btn-primary` yang **ada** di `pesan_kamar_section.html` | ✅ **DIKOREKSI 16 Agt 2026** — klaim CTA dihapus dari [§6](#grup-d--pilih--pesan-kamar-2637), dan `RoomDetailSheet` sengaja dibangun **tanpa** tombol bawah. Kalau CTA sempat ditambahkan atas dasar baris ini, ia akan jadi tombol kedua yang memesan kamar — bersaing dengan `Pesan kamar ini` di kartu tipe kamar layar detail dan dengan bottom bar #31, untuk aksi yang **sudah** dilakukan sebelum sheet ini dibuka. |

**Tambahan** (bukan anomali aset, tapi wajib dicatat): batas karakter permintaan khusus berbeda antara UI dan API — lihat [A-D1](#113-drift-kontrak-flutter--laravel).

---

## 5. Registry Layar (ringkas)

Grup fungsional 40 layar. Kolom "Ada di Flutter?" = status per audit 2026-08-16.

| Grup | Layar (#) | Layar Flutter penampung | Ada di Flutter? |
|---|---|---|---|
| **A. Pencarian** | 1–6 | `hotel_search_screen.dart` | ✅ ada (sheet belum lengkap) |
| **B. Hasil & Filter** | 7–16 | `hotel_results_screen.dart` | ✅ ada (4 sheet + top modal belum) |
| **C. Detail Hotel** | 17–25 | `hotel_detail_screen.dart` | ✅ ada (8 tab) |
| **D. Pilih & Pesan Kamar** | 26–37 | `hotel_booking_screen.dart` | ⚠️ ada, **banyak sheet belum dibuat** |
| **E. Booking & Pembayaran** | 38–40 | `booking/` + `payment/` | ⚠️ generik, belum ada varian hotel |

---

## 6. Analisis Detail Per Layar

> Penomoran **1–40 kontinu**, sinkron 1:1 dengan [§3.3](#33-tabel-silang-html--png--jpeg-40-baris) dan `manifest.json`. Ini memperbaiki [A-07](#4-log-anomali-aset--dokumentasi) & [A-09](#4-log-anomali-aset--dokumentasi).

### Grup A — Pencarian (1–6)

#### 1. `filter_location` — Filter Lokasi
- **Header:** "Filter Lokasi" + tombol close.
- **Search field:** placeholder `Cari lokasi`.
- **Seksi "Populer":** Jakarta Pusat · Jakarta Selatan · Bali · Kuala Lumpur · Yogyakarta.
- **Output ke query:** `city_id` (atau `q` bebas teks bila tidak match).
- **Catatan:** daftar populer harus datang dari API, bukan hardcode → kandidat endpoint `GET cities?popular=1`. ⚠️ BELUM DIVERIFIKASI apakah endpoint ini ada.

#### 2. `filter_screen` — Layar Pencarian Utama
- Entry point pencarian hotel: field lokasi, ringkasan tanggal, ringkasan kamar & tamu, tombol cari.
- Tap lokasi → #1; tap tanggal → #5/#6; tap kamar & tamu → #3.

#### 3. `filter_kamar_tamu` — Kamar dan Tamu
- **Judul:** `Kamar dan Tamu`.
- **3 stepper:** `Kamar`, `Dewasa`, `Anak`.
- **Seksi:** "Usia anak pada saat check-in" → baris per anak: `Anak 1` → `<1 tahun`, `Anak 2` → `4 tahun`.
- **Tombol:** `Selesai`.
- **Output:** `rooms_count`, `adults`, `children`, `children_ages[]`.
- ⚠️ `children_ages[]` **tidak ada** di validasi `BookingController::store()` → lihat [A-D2](#113-drift-kontrak-flutter--laravel).

#### 4. `filter_kamar_tamu_bottom_modal_select_anak` — Pilih Umur Anak
- Bottom sheet dari #3 saat baris "Anak N" ditap. Daftar umur `<1 tahun` … `17 tahun`.
- Widget sama dipakai oleh #16 → [A-06](#4-log-anomali-aset--dokumentasi).

#### 5. `filter_kalendar` — Tab Kalender
- Tab 1 dari picker tanggal. Pilih check-in & check-out (range). Menampilkan jumlah malam.
- **Output:** `check_in`, `check_out` (format `Y-m-d`).

#### 6. `filter_kalendar_tanggal_flexibel` — Tab Tanggal Fleksibel
- Tab 2 dari picker yang sama: pilih durasi (1 malam / 2 malam / seminggu) + bulan.
- **Output:** tetap dinormalisasi menjadi `check_in`/`check_out` sebelum dikirim ke API.

### Grup B — Hasil Pencarian & Filter (7–16)

#### 7. `result_pencarian` — Hasil Pencarian
Struktur terverifikasi dari HTML:
- **Search bar ringkas:** `15 Agt` / `16 Agt` (stack 11px/700) │ divider 1px `#E0E0E0` │ `Jakarta Pusat, Indonesia` (13px/600) │ `¥/$ IDR` (10px/700).
- **Baris chip filter** (4): `Urutkan` · `Filter` · `Lokasi` · `Kebutuhan` — pill `border-radius:20px`, `border:1.5px solid #E0E0E0`, 13px/600, ikon 15px.
- **Banner promo:** kartu putih radius 12px, shadow `0 2px 12px rgba(0,0,0,.10)`, ikon tag 30×30 bg `#FCE4EC` fill `#E91E63`, judul `Diskon hingga Rp393.750` (14px/700), subjudul `Promo Homestay Unggulan` (12px `#757575`), chevron.
- **Jumlah hasil:** `975 akomodasi ditemukan` (14px/700, padding `8px 16px`).
- **Kartu hotel** — background `#F5F5F5` di belakang, kartu putih, pemisah `border-bottom:8px solid #F5F5F5`:
  - Gambar kiri **130×165 px**, `flex:0 0 130px`, radius 0.
  - Tombol favorit: 30×30 bulat, `rgba(0,0,0,.3)`, `top:8px right:8px`.
  - Nama hotel 14px/700 + bintang 14px (`#FFA726` aktif / `#E0E0E0` nonaktif).
  - Skor: badge `#2962FF` teks putih 12px/700 radius 4px padding `2px 8px` → `8,1/10`; label `Luar Biasa` 12px/700; `371 ulasan` 12px `#757575`.
  - Jarak: `800m dari pusat kota` 12px `#757575`.
  - Tag (kolom, gap 2px): `Kamar Keluarga`, `Aktivitas untuk anak` — 12px/500 `#14B8A6`.
  - Sosial: `1.549 orang menambahkan ke favorit` 11px `#757575`.
  - Harga (rata kanan): `Rp541.790` 11px `#757575` strikethrough → `Rp446.637` 18px/800 `#2962FF` → `Total harga: Rp1.089.796` 11px → `2 kamar × 1 malam termasuk pajak & biaya lainnya` 10px → chip `Diskon Spesial` bg `#FCE4EC` teks `#E91E63` 11px/700 radius 10px.
  - **Kartu ke-2** (Amaris Hotel Pasar Baru) membuktikan state opsional: **tanpa** harga coret, **tanpa** label skor teks, **tanpa** chip diskon → semua elemen ini harus nullable di model.
- **Floating bottom bar:** pil `rgba(26,26,46,.88)` radius 30px, `backdrop-filter:blur(10px)`, `bottom:20px`, center; isi `📍 Peta` │ divider │ `♡ Disimpan`, 14px/700 putih.

#### 8. `result_pencarian_bottom_modal_filter` — Sheet Filter Utama
- Bottom sheet gabungan: rentang harga, bintang, fasilitas, dsb.
- **Spesifikasi sheet (berlaku untuk #8–#11):** scrim `rgba(0,0,0,.3)` z-index 29; sheet `position:absolute; bottom:0; border-radius:20px 20px 0 0; max-height:70%`; drag handle 36×4 `#E0E0E0` radius 2 margin `10px auto`; header `padding:12px 20px`, judul 17px/700, ikon close 22px, `border-bottom:1px solid #EEEEEE`; body `padding:20px; overflow:auto`.

#### 9. `result_pencarian_bottom_modal_filter_kebutuhan` — Filter Kebutuhan
- **Grid 2 kolom, 8 chip.**
- **Terpilih:** `border:1.5px solid #2962FF`, `background:#F0F4FF`, teks `#2962FF` weight 600.
- **Tidak terpilih:** `border:1.5px solid #E0E0E0`, background putih, teks `#1A1A2E` weight 400.
- Multi-select → kirim sebagai array.

#### 10. `result_pencarian_bottom_modal_filter_urutkan` — Urutkan
**4 opsi radio** (terverifikasi `result_pencarian_bottom_modal_filter_urutkan.html:168-199`):

| Opsi | State | Style |
|---|---|---|
| `Rekomendasi` | **terpilih** | radio 20×20 `border:2px solid #2962FF` + fill `#2962FF` + centang putih 12px; teks 15px/700 `#2962FF` |
| `Harga terendah` | — | radio `border:2px solid #E0E0E0` transparan; teks 15px/400 `#1A1A2E` |
| `Rating tertinggi` | — | idem |
| `Jarak terdekat` | — | idem |

Setiap baris: `padding:14px 0`, `gap:12px`, `border-bottom:1px solid #EEEEEE`.
**Mapping ke API** (terverifikasi di `PropertyController::index()`): `Rekomendasi` → `sort=newest` atau kosongkan · `Harga terendah` → `sort=price_asc` · `Rating tertinggi` → `sort=rating` · `Jarak terdekat` → 🔴 **tidak ada padanan server**. Server hanya menerima `newest|price_asc|price_desc|rating`; nilai lain (termasuk `popularity` dan `distance`) ditolak **422**. Lihat [A-D9](#113-drift-kontrak-flutter--laravel).

#### 11. `result_pencarian_bottom_modal_filter_lokasi` — Filter Lokasi (dari hasil)
- Header "Filter Lokasi", field `Cari lokasi`, seksi "Populer": Jakarta Pusat · Jakarta Selatan · Bali · Kuala Lumpur · Yogyakarta.
- Sama dengan #1 tetapi disajikan sebagai bottom sheet di atas hasil (latar tetap menampilkan `975 akomodasi ditemukan`).
- Di Flutter: **1 widget isi** (`LocationFilterBody`) dengan 2 pembungkus (full screen & bottom sheet).

#### 12. `result_pencarian_top_modal_filter_date_and_tamu` — Top Modal Tanggal & Tamu
- Modal **turun dari atas** (bukan bottom sheet) berisi ringkasan tanggal + kamar/tamu.
- ⚠️ Paket `top_modal_sheet` **tidak ada** di `pubspec.yaml` → [A-08](#4-log-anomali-aset--dokumentasi). Implementasi manual: `showGeneralDialog` + `SlideTransition(begin: Offset(0,-1))`.

#### 13. `result_pencarian_top_modal_filter_date_and_tamu_kalendar` — Top Modal → Tab Kalender
Sama isi dengan #5, dibuka dari top modal.

#### 14. `result_pencarian_top_modal_filter_date_and_tamu_tanggal_flexibel` — Top Modal → Tab Fleksibel
Sama isi dengan #6.

#### 15. `result_pencarian_top_modal_filter_date_and_tamu_2nd` — Top Modal → Kamar & Tamu
Sama isi dengan #3.

#### 16. `result_pencarian_top_modal_filter_date_and_tamu_2nd_bottom_modal_select_anak` — Top Modal → Umur Anak
Sama isi dengan #4. Bottom sheet di atas top modal → perhatikan **stacking order** navigator.

### Grup C — Detail Hotel (17–25)

#### 17. `detail_hotel` — Detail Hotel (utama)
- Hero gambar, nama hotel, bintang, badge skor, alamat, jarak, ringkasan fasilitas, CTA `Pesan Kamar`.
- **TabBar 8 tab, `isScrollable: true`** → #18–#25.
- **Pola Flutter:** `NestedScrollView` + `SliverAppBar(pinned: true, floating: true)` + `TabBar(isScrollable: true)` + `TabBarView`. Contoh kanonik ada di `docs/properties/screen/readme_screen.md` (snippet `NestedTabScreen`).

#### 18. `detail_tab_kamar` — Tab Kamar
Daftar tipe kamar dengan harga/malam, kapasitas, tempat tidur, badge kebijakan. Tap kartu → #34/#35. Tombol pilih → #26.

#### 19. `detail_tab_ulasan` — Tab Ulasan
Skor agregat, distribusi, daftar ulasan.

#### 20. `detail_tab_lokasi` — Tab Lokasi
Peta, alamat, POI sekitar, jarak ke landmark.

#### 21. `detail_tab_fasilitas` — Tab Fasilitas
Fasilitas dikelompokkan per kategori + ikon.

#### 22. `detail_tab_kebijakan` — Tab Kebijakan
Jam check-in/check-out, kebijakan anak, hewan, pembatalan, deposit.

#### 23. `detail_tab_keterangan` — Tab Keterangan
Deskripsi naratif hotel.

#### 24. `detail_tab_trip_moments` — Tab Trip Moments
Galeri UGC (foto pengguna). ⚠️ Istilah "Trip Moments" = Trip.com-ism → [A-10](#4-log-anomali-aset--dokumentasi).

#### 25. `detail_tab_akomodasi_terdekat` — Tab Akomodasi Terdekat
Kartu hotel alternatif di sekitar — reuse `HotelResultCard` (#7) versi ringkas.

### Grup D — Pilih & Pesan Kamar (26–37)

#### 26. `pesan_kamar_section` — Seksi CTA "Pesan Kamar"
- State di detail hotel saat pengguna menekan CTA — menampilkan ringkasan pilihan kamar sebelum sheet penuh.
- ⚠️ JPEG-nya **tidak ada** → gunakan PNG `detail_hotel_screen_saat_mau_pilih_button_pesan_kamar.png` + HTML. [A-02](#4-log-anomali-aset--dokumentasi).

#### 27. `sheet_pesan_kamar` — Sheet Ringkasan Pesan Kamar
Terverifikasi dari `sheet_pesan_kamar.html`:
- **Header:** `[←]` (kiri absolut `left:16px`) + `Grand Cemara Hotel` (17px/700, center), `border-bottom:1px solid #EEEEEE`, padding `12px 16px`.
- **Kartu ringkasan booking** `border:1.5px solid #E0E0E0; border-radius:12px; padding:16px`:
  - Baris tanggal (`space-between`, `border-bottom:1px solid #EEEEEE`, `padding-bottom:14px`):
    - Kiri: `Check-in` 11px `#757575` → `Sab, 15 Agt` 18px/800 → `Setelah pukul 14:00` 12px `#757575`
    - Tengah: `1 malam` 12px `#757575` + garis `border-top:1px solid #E0E0E0; width:60px`
    - Kanan (rata kanan): `Check-out` → `Min, 16 Agt` → `Sebelum pukul 12:00`
  - **Blok per tipe kamar** (`padding:14px 0; border-bottom:1px solid #EEEEEE`), judul 16px/700 + ` | 1 Kamar` (14px/400 `#757575`):

    | Tipe | Atribut (13px, ikon 16px, `padding:5px 0`) |
    |---|---|
    | **Family Suite \| 1 Kamar** | 👤 `Harga untuk 4 Dewasa` · 🛏 `2 queen bed` · 🚭 `Bebas rokok` · ☕ `Sarapan berbayar Rp108.900 (opsional)` · ⓘ `Tidak dapat di-refund` |
    | **Kamar Superior \| 1 Kamar** | 👤 `Harga untuk 2 dewasa + 1 anak` · 🛏 `1 queen bed atau 2 single bed` · 🚭 `Bebas rokok` · 💜 `Anak Menginap Gratis` (`#14B8A6`, 600) · ☕ `Sarapan berbayar Rp108.900 (opsional)` · ⓘ `Tidak dapat di-refund` |

- **Seksi "Info tamu ⓘ"** (16px/700): satu baris `background:#F5F5F5; border-radius:8px; padding:12px 14px` → kiri ikon kartu-identitas 18px + `Kamar 1` (14px/600); kanan ikon user 15px + `Pilih tamu yang tersimpan` (13px `#757575`).
- **Banner teal:** `background:#e0f7fa; padding:10px 16px`, center → `💜 Kami Samakan Harga` (13px/600 `#00796b`).
- **Bottom bar:** `border-top:1px solid #EEEEEE; padding:10px 16px 16px` → kiri `Prabayar Online (total harga)` (11px `#757575`) + `Rp1.089.796 ⓘ` (20px/800 `#2962FF`, ⓘ 14px `#757575`); kanan tombol `Pesan` di container `width:100px`, `height:44px`, 15px, bg `#2962FF`.

#### 28. `form_pengisian_kamar` — Form Pengisian Data Kamar
Terverifikasi dari `form_pengisian_kamar.html`:
- **Header:** `[←] Grand Cemara Hotel`.
- **Blok per kamar:** ikon bed + `Kamar N` (15px/700) + chip abu `Pilih tamu yang tersimpan` (bg `#F5F5F5`, radius 10px); subjudul = nama tipe kamar (13px `#757575`).
- **2 field per kamar** — outlined `border:1.5px solid #E0E0E0; border-radius:8px; padding:14px 16px`, placeholder `Nama depan*` / `Nama belakang*`.
- **Seksi "Info Kontak"** (16px/700):
  - **Email — state TERISI:** `border:1.5px solid #2962FF`, floating label `Email*` 11px `#2962FF`, nilai `mohbaswandegorie@gmail.com`, ikon `✓` `#4caf50`.
  - **Telepon — state KOSONG:** `+62` (14px/600) + divider 1px + chevron + placeholder `Nomor Telepon*` `#757575`.
- **Footer:** banner teal + `Prabayar Online (total harga)` / `Rp1.089.796 ⓘ` + tombol `Pesan` (100×44).
- **Payload:** → [§12.3](#123-post-bookings--form-pengisian-kamar-multi-kamar).

#### 29. `form_pengisian_kamar_scroll` — Form Pengisian (state ter-scroll)
Lanjutan #28 setelah scroll: Trip Coins, Permintaan Khusus, Informasi Tambahan, Syarat & Ketentuan, checkbox terima promo.

#### 30. `form_pesan_kamar_step1` — Step 1: Data Tamu
Versi multi-step dari #28 — daftar blok kamar + info kontak.

#### 31. `form_pesan_kamar_step2` — Step 2: Diskon & Benefit
Terverifikasi dari `form_pesan_kamar_step2.html`:
- **Judul seksi:** `Diskon & benefit` (20px/800, margin-bottom 16px).
- **Kartu "Kode Promo"** (16px/700) + status `Kode promo berhasil digunakan` (13px/600 `#00796b`).
- **Promo per tipe kamar** — 🔴 **penting: promo di-apply PER TIPE KAMAR, bukan per booking**:
  - `Kamar Superior` (14px/700) → `Kode promo pengguna baru (pemesanan pertama) : - Rp22.351` + badge `Digunakan` (`#00796b` 700) + chevron.
  - `Family Suite` (14px/700) → `Silakan masukkan kode promo Anda (4 tidak dapat digunakan)` + chevron.
- **Trip Coins** (14px/700) — seksi expandable.
- **Permintaan Khusus** (16px/700) + link `Pelajari Selengkapnya` (13px/700 underline) → buka #37.
- **Informasi Tambahan (1)** (16px/700) + link `Pelajari Selengkapnya` → buka #33.
- **Banner teal:** `Hati tenangkan berkat opsi pembatalan gratis.` (13px/600 `#14B8A6`).
- **Bottom bar:** `Prabayar Online (total harga)` / `Rp1.089.796 ⓘ` + `Pesan`.
- ⚠️ **Drift:** API hanya menerima **satu** `voucher_code` untuk seluruh booking → [A-D3](#113-drift-kontrak-flutter--laravel).

#### 32. `form_pesan_kamar_step3` — Step 3: Konfirmasi & S&K
Terverifikasi dari `form_pesan_kamar_step3.html`:
- `Trip Coins` (14px/700) · `Permintaan Khusus` (16px/700) + `Pelajari Selengkapnya` · `Informasi Tambahan (1)` + `Pelajari Selengkapnya`.
- **Blok persetujuan:** `… Syarat & Ketentuan dan Pernyataan Privasi Trip.com.` — underline `#1A1A2E` 600. ⚠️ **"Trip.com" harus diganti "Sewain"** → [A-10](#4-log-anomali-aset--dokumentasi).
- **Banner teal:** `Kami Samakan Harga` (13px/600 `#00796b`).
- **Bottom bar:** identik #31.

#### 33. `bottom_sheet_informasi_tambahan` — Sheet Informasi Tambahan
- Header: `Informasi Tambahan` + `[X]`.
- Body: `Kebijakan Deposit` (18px/800) + `Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in`.
- **Read-only** — tidak menghasilkan payload.

#### 34 & 35. `room_detail_family_suite` / `room_detail_kamar_superior` — Detail Kamar

> 🔴 **Keduanya adalah SATU komponen, bukan dua layar.** Bukti struktural, bukan tafsiran: kedua screenshot tinggal di **satu** folder `…/show_modal_bottom_full/bottom_screen_kamar_superior/` dengan dua subfolder `tab_kamar_superior/` dan `tab_family_suite/` ([A-20](#4-log-anomali-aset--dokumentasi)), dan HTML #35 sendiri merender **baris pil** berisi *kedua* nama kamar — `Kamar Superior` aktif (`#F0F4FF` + border `1.5px #2962FF`) dan `Family Suite` non-aktif (putih + border `#E0E0E0`) — [`room_detail_kamar_superior.html:44-47`](_build/html/room_detail_kamar_superior.html#L44-L47). Nama folder induknya juga menyebut `form_pesan_kamar_screen` + `show_modal_bottom_full`: **bottom sheet penuh tinggi yang dibuka dari form pesan kamar**. Implementasi: [C-39 `RoomDetailSheet`](#8-komponen-reusable) — satu widget, pil memindah state. HTML #34 adalah stub kosong ([A-19](#4-log-anomali-aset--dokumentasi)), jadi seluruh struktur diambil dari #35 + 8 JPEG.

**Urutan blok (terverifikasi dari `room_detail_kamar_superior.html`, 152 baris):**

| Blok | Isi mockup | Sumber data | Status implementasi |
|---|---|---|---|
| Header | `[X]` kiri + nama kamar 17px/700 di tengah | `room_types.name` | ✅ (di-**pin**, tidak ikut scroll — dari JPEG; HTML tidak bisa menunjukkan ini) |
| Galeri | 1 foto 180px radius 12 | `room_types.images` `[{url, caption}]` | ✅ 1 foto → lebar penuh; >1 → strip horizontal 260×180; 0 → placeholder |
| Judul + **pil** | nama 20px/800, lalu 2 pil tipe kamar | `active_room_types[]` | ✅ pil ter-scroll horizontal, di-pin bersama header; disembunyikan bila hanya 1 tipe |
| Spesifikasi | `21 m²` · `Memiliki jendela` · `Bebas rokok` · `Wi-Fi gratis` | `room_size_sqm`, `has_window`, `no_smoking`, `free_wifi` | ✅ |
| Tempat tidur | caption `Jenis kamar disediakan selama persediaan masih ada` + tabel `Opsi 1` / `Opsi 2` | **`bed_configuration` di-split** pada ` atau ` / ` / ` | ✅ tabel hanya bila ada ≥2 opsi; 1 opsi → baris inline (lihat [§12.12](#1212-room_detail-3435--sumber-tiap-blok)) |
| `Pilihan Anda` | `2 dewasa, 1 anak (Usia 0-5 tahun)` + `…mengakomodasi hingga 3 tamu` + `Tidak termasuk makanan` | `capacity_adults`, `capacity_children`, `max_guests`, `breakfast_included` | ⚠️ `(Usia 0-5 tahun)` **dihapus** — tak ada kolomnya |
| Biaya sarapan | 2 kartu `Dewasa` / `Buffet:Rp108.900 per orang` | — | ❌ **dihapus** — tak ada kolom harga sarapan |
| Jaminan | `Konfirmasi Langsung` (teal `#14B8A6`) + `Prabayar Online` | — | ✅ **konstanta yang dibenarkan alur**, bukan copy mockup: `storeHotelBooking()` membuat booking + `increment('booked_count')` sekaligus (tanpa persetujuan host), dan tiap booking hotel dibayar lewat Midtrans sebelum check-in |
| `Fasilitas Kamar` | grid 2 kolom, 6 item + `Tampilkan semua fasilitas` | `room_types.facilities` (jsonb) | ✅ plafon 6 lalu expand; link **di tengah, tanpa underline** (dari JPEG; HTML menulisnya rata kiri + underline) |
| `Kebijakan & layanan` | `Pembatalan Gratis` teal + timeline 2 baris ber-tanggal + `Konfirmasi Langsung` | `properties.cancellation_policy` (**`string(255)`, teks bebas**) | ⚠️ dijadikan **seksi expandable** (chevron — dari JPEG); **timeline ber-tanggal dihapus** — tak ada kolom tenggat, hanya satu kalimat |
| `Kebijakan Anak dan Tempat Tidur Tambahan` | `Kebijakan Tamu Anak` + `Ranjang Bayi dan Tempat Tidur Tambahan` | `hotels.policies.child_policy` / `.extra_bed_policy` | ⚠️ expandable; **dicetak sekali** — mockup mengulang teks ranjang tambahan 2× (inline dekat tempat tidur **dan** di seksi ini), sedangkan sumbernya satu (per-hotel, bukan per-kamar) |
| `Sarapan` | `Gaya: Buffet` · `Jam buka [Sen-Min] 07:00-10:00` · tabel biaya (`Anak usia 5-17 tahun` Rp65.000 / `Dewasa` Rp108.900) | — | ❌ **dihapus seluruhnya** — tak ada satu pun kolomnya di `room_types` maupun `hotels` |
| Bottom CTA | **tidak ada** | — | ✅ tidak dibuat — klaim "CTA pilih" di readme lama salah, lihat [A-21](#4-log-anomali-aset--dokumentasi) |

**Perbedaan tab (dari 8 JPEG):** `Kamar Superior` → `21 m²`, `1 queen bed atau 2 single bed` (2 opsi), `2 dewasa, 1 anak`, `Tidak termasuk makanan`, benefit `💜 Anak Menginap Gratis` (`#14B8A6`). `Family Suite` → `2 queen bed` (1 opsi, inline), `4 Dewasa`, kebijakan `Tidak dapat di-refund`.

**Aturan yang dipegang:** setiap baris ❌/⚠️ di atas dihapus karena **tidak punya kolom**, bukan karena diabaikan. Menyalin `Rp108.900` atau `07:00-10:00` sebagai literal berarti mencetak angka yang tak pernah disetujui server — kesalahan yang sama sudah terjadi sekali di modul ini ([A-D11](#113-drift-kontrak-flutter--laravel): fixture dummy punya harga, API nyata tidak). Bila blok-blok itu memang diinginkan, yang dibutuhkan **migrasi**: `room_types.breakfast_fees` (jsonb), `hotels.breakfast_style` + `breakfast_hours`, dan `properties.cancellation_deadline_hours` (integer) untuk membangun timeline.

#### 36. `bottom_sheet_kode_promo` — Sheet Kode Promo
Terverifikasi dari `bottom_sheet_kode_promo.html`:
- **Baris input:** placeholder `Tambah Kode Promo` + tombol abu `Tambah`.
- **Judul daftar:** `Pilih Kode Promo (0 Tersedia)`.
- **3 kartu, semua `opacity:0.6`** (tidak memenuhi syarat), tiap kartu = judul / subjudul / masa berlaku / alasan (`#e65100`, underline):

  | Judul | Subjudul | Masa berlaku | Alasan tidak berlaku |
  |---|---|---|---|
  | `Diskon 5% Maks. Diskon Rp21…` | `Diskon 3 malam` | `Berlaku mulai 14 Agt 2026, 11.57 sampai 21 Agt 2026, 22.59` | `Tidak berlaku untuk jumlah malam yang Anda pilih` |
  | `Diskon hingga Rp393.750` | `Promo Homestay Unggulan` | idem | `Tidak berlaku untuk akomodasi ini` |
  | `Diskon 10% Maks. Diskon Rp9…` | `Kode promo pengguna baru (pemesan pertama)` | `Berlaku mulai 13 Agt 2026, 02.12 sampai 27 Agt 2026, 22.59` | `Kode promo ini tidak dapat digunakan pada pemesanan saat ini` |

- **Implikasi model:** setiap voucher butuh `is_eligible: bool` + `ineligible_reason: string?` agar UI bisa menampilkan state dimmed + alasan. Validasi eligibility harus dari server (`resolveDiscount()`), jangan di klien.

#### 37. `bottom_sheet_permintaan` — Sheet Permintaan Khusus
Terverifikasi dari `bottom_sheet_permintaan.html`. **Scope: per tipe kamar** (heading `Kamar Superior`).

| Grup | Kontrol | Opsi |
|---|---|---|
| Preferensi tipe tempat tidur | **RADIO** (`border-radius:50%`) | `Utamakan 2 single bed` · `Utamakan 1 queen bed` |
| Posisi dari Lift | **RADIO** | `Jauh dari lift` · `Dekat lift` |
| Permintaan lainnya | **CHECKBOX** (`border-radius:4px`) | `Kamar kedap suara` · `Perlu pembersihan khusus asap rokok` · `Kamar non-corner` · `Perlu menitipkan bagasi` |
| Permintaan tambahan | Textarea `min-height:80px` | counter `0/200` → **maks 200 karakter** |

- **Disclaimer:** `Pihak akomodasi akan berupaya secara maksimal, tetapi tidak menjamin semua permintaan dapat dipenuhi.`
- **Tombol:** `Selesai`.
- ⚠️ **2 drift:** batas 200 vs 500 karakter di API, dan scope per-tipe-kamar vs field tunggal per-booking → [A-D1](#113-drift-kontrak-flutter--laravel).

### Grup E — Booking & Pembayaran (38–40)

#### 38. `booking_list_screen` — Daftar Booking
Daftar booking pengguna dengan status. Harus membedakan kartu `booking_type='room'` (hotel) vs `'unit'` (properti) → [§10](#10-pemisahan-domain-booking-hotel-vs-booking-properti).

#### 39. `booking_pembayaran_screen` — Layar Pembayaran
Pilih metode pembayaran → Midtrans. **Aturan keras:** callback browser (`Payment/*Controller`) **tidak boleh** mengubah status apa pun — hanya parse `order_id` → redirect deep link `sewain://payment-result`. Perubahan status **hanya** dari webhook S2S.

#### 40. `booking_hotel_detail_screen` — Detail Booking Hotel
Terverifikasi dari `booking_hotel_detail_screen.html`. **5 bagian** dipisah `border-bottom:8px solid #F5F5F5`:

| Bagian | Isi terverifikasi |
|---|---|
| 1. Identitas & countdown | `No. Pemesanan 1367843010567330`, `PIN *****`, countdown `28:00` |
| 2. Ringkasan menginap | tanggal, malam, tipe kamar, jam check-in/out |
| 3. Data tamu | `Tea Wan`, `62-0858****3846`, `mohba******gorie@gmail.com` — **wajib ter-mask** |
| 4. Rincian harga | total `Rp1.498.990`, `Dapatkan 43 Trip Coins (≈Rp7.665)` |
| 5. Jaminan | badge `Kami Samakan Harga` + `Jaminan Menginap di Hotel` |

- **Tombol bawah:** `Bayar` (bg `#d84315`) + `Batalkan Pemesanan` (`#2962FF`).
- **Verifikasi silang Trip Coins:** `43 / 1.498.990 = 0,00287` — **tidak** sama dengan 0,5% (`round(1498990 × 0.005) = 7495`). **Sumber kebenaran = kode:** `$tripCoins = (int) round($total * 0.005)`. Angka mockup adalah data contoh dari Trip.com, **bukan** spesifikasi. Jangan menyalin `43` sebagai ekspektasi test.

---

## 7. Design System

### 7.1 Palet warna

| Token | Hex | Dipakai untuk |
|---|---|---|
| `primary` | `#2962FF` | tombol utama, harga diskon, badge skor, radio/chip terpilih, teks link biru |
| `primary_dark` | `#0039CB` | state pressed |
| `primary_tint` | `#F0F4FF` | background chip terpilih (#9) |
| `teal_accent` | `#14B8A6` | tag benefit (`Anak Menginap Gratis`, tag kartu hotel), banner pembatalan gratis |
| `teal_banner_bg` | `#e0f7fa` | background banner "Kami Samakan Harga" |
| `teal_banner_text` | `#00796b` | teks banner teal, badge `Digunakan`, status promo sukses |
| `text_primary` | `#1A1A2E` | teks utama |
| `text_secondary` | `#757575` | teks sekunder, label, placeholder |
| `text_disabled` | `#BDBDBD` | teks nonaktif |
| `bg_primary` | `#FFFFFF` | background kartu & layar |
| `bg_surface` | `#F5F5F5` | background list, chip abu, pemisah 8px |
| `border` | `#E0E0E0` | outline field, radio kosong, bintang nonaktif |
| `divider` | `#EEEEEE` | pemisah 1px |
| `star_color` | `#FFA726` | bintang aktif |
| `price_original` | `#E53935` | harga asli (+ `line-through`) |
| `price_discount` | `#2962FF` | harga setelah diskon |
| `score_badge_bg` | `#2962FF` | background badge skor |
| `score_badge_text` | `#FFFFFF` | teks badge skor |
| `chip_discount_bg` | `#FCE4EC` | background chip diskon & ikon promo |
| `chip_discount_text` | `#E91E63` | teks chip diskon |
| `success` | `#4caf50` | centang field tervalidasi |
| `warning_text` | `#e65100` | alasan voucher tidak berlaku |
| `danger_action` | `#d84315` | tombol `Bayar` di #40 |
| `scrim` | `rgba(0,0,0,.3)` | scrim di belakang bottom sheet |
| `floating_bar_bg` | `rgba(26,26,46,.88)` | pil floating Peta/Disimpan |

> Catatan: token `price_original` bernilai `#E53935`, tetapi HTML kartu hasil (#7) memakai `#757575` untuk harga coret. **Untuk kartu hasil pencarian pakai `#757575`**; `#E53935` untuk konteks penekanan diskon lain.

### 7.2 Tipografi

Font: **Inter** (400/500/600/700/800).

| Peran | Ukuran | Weight | Contoh |
|---|---|---|---|
| H1 / judul seksi besar | 22px (mockup 20px) | 800 | `Diskon & benefit` |
| H2 | 18px | 700–800 | `Kebijakan Deposit`, `Sab, 15 Agt` |
| H3 / judul sheet | 17px | 700 | `Grand Cemara Hotel`, `Urutkan` |
| Judul seksi | 16px | 700 | `Info Kontak`, `Info tamu`, `Permintaan Khusus` |
| Item radio/opsi | 15px | 400 / 700 (terpilih) | `Harga terendah` |
| Body | 14px | 400–700 | nama hotel, `Kamar 1` |
| Caption | 12–13px | 400–600 | `371 ulasan`, tag teal |
| Micro | 10–11px | 400–700 | `2 kamar × 1 malam…`, label `Check-in` |
| Price Large | 18–24px | 800 | `Rp446.637`, `Rp1.089.796` |
| Score Badge | 12–14px | 700 | `8,1/10` |

### 7.3 Metrik layout

| Properti | Nilai |
|---|---|
| Viewport baseline | 390 × 844 |
| Status bar | 28px |
| Tombol utama | height 48px (bottom bar: **44px**), radius 8px, 15px/700 |
| Field outlined | `border 1.5px`, radius 8px, padding `14px 16px` |
| Kartu | radius 12px, `border 1.5px #E0E0E0` |
| Chip pill | radius 20px, padding `7px 12px`, 13px/600 |
| Chip kecil | radius 10px, padding `3px 10px`, 11px/700 |
| Bottom sheet | radius `20px 20px 0 0`, `max-height:70%`, handle 36×4 |
| Pemisah grup | `border-bottom: 8px solid #F5F5F5` |
| Pemisah baris | `1px #EEEEEE` |
| Gambar kartu hasil | 130 × 165 |
| Ikon inline | 14–18px (bintang 14, ikon baris 16, ikon seksi 18, ikon header 22–24) |

---

## 8. Komponen Reusable

Dibuat **sekali**, dipakai berulang. Kolom "Dipakai di" merujuk nomor layar [§6](#6-analisis-detail-per-layar).

| # | Komponen | Dipakai di | Catatan |
|---|---|---|---|
| C-01 | `HotelSearchBarCompact` | 7, 8–16 | tanggal stack + lokasi + IDR |
| C-02 | `FilterChipRow` | 7–11 | 4 chip: Urutkan/Filter/Lokasi/Kebutuhan |
| C-03 | `PromoBannerCard` | 7, 11 | shadow `0 2px 12px rgba(0,0,0,.10)` |
| C-04 | `HotelResultCard` | 7, 11, 25 | semua elemen harga/skor/chip **nullable** |
| C-05 | `StarRatingRow` | 7, 17, 18 | `#FFA726` / `#E0E0E0` |
| C-06 | `ScoreBadge` | 7, 17, 19 | `#2962FF` + putih |
| C-07 | `DiscountChip` | 7 | `#FCE4EC` / `#E91E63` |
| C-08 | `FavoriteToggle` | 7, 17 | bulat 30px `rgba(0,0,0,.3)` |
| C-09 | `FloatingMapSavedBar` | 7 | pil blur `rgba(26,26,46,.88)` |
| C-10 | `AppBottomSheetShell` | 8–11, 33, 36, 37 | scrim + handle + header + body scroll |
| C-11 | `AppTopModalShell` | 12–16 | **manual** — paket tidak ada, [A-08](#4-log-anomali-aset--dokumentasi) |
| C-12 | `RadioOptionTile` | 10, 37 | radius 50%, 20×20 |
| C-13 | `CheckboxOptionTile` | 37 | radius 4px |
| C-14 | `SelectableChipGrid` | 9 | grid 2 kolom, multi-select |
| C-15 | `LocationFilterBody` | 1, 11 | 1 isi, 2 pembungkus |
| C-16 | `DateRangeCalendar` | 5, 13 | range picker + hitung malam |
| C-17 | `FlexibleDateTab` | 6, 14 | durasi + bulan → normalisasi ke tanggal |
| C-18 | `RoomGuestStepperSheet` | 3, 15 | stepper Kamar/Dewasa/Anak + umur anak |
| C-19 | `ChildAgePickerSheet` | 4, 16 | reuse penuh, [A-06](#4-log-anomali-aset--dokumentasi) |
| C-20 | `HotelDetailTabScaffold` | 17–25 | `NestedScrollView` + `TabBar(isScrollable:true)` 8 tab |
| C-21 | `StayDateSummaryCard` | 27, 40 | Check-in │ N malam │ Check-out |
| C-22 | `RoomTypeAttributeList` | 27, 34, 35 | baris ikon 16px + teks 13px · ⚠️ **belum jadi widget bersama**: [F-7](#152-flutter) memakai `_spec()` privat di `room_detail_sheet.dart` karena #34/#35 memakai ikon berbeda per baris (`aspect_ratio`/`window`/`smoke_free`/`wifi`/`bed`/`person_outline`/`restaurant`/`check`), sedangkan #27 memakai daftar tetap. Kalau kelak disatukan, sumber ikonnya harus jadi parameter, bukan konstanta |
| C-23 | `GuestRoomFormBlock` | 28, 29, 30 | `Kamar N` + nama depan/belakang |
| C-24 | `OutlinedTextField` | 28, 30, 37 | state kosong / terisi(biru+✓) / error |
| C-25 | `PhoneFieldWithCountryCode` | 28, 30 | `+62` + divider + chevron |
| C-26 | `SavedGuestPickerChip` | 27, 28 | chip abu `Pilih tamu yang tersimpan` |
| C-27 | `PricePrepaidBottomBar` | 27–32 | label + total 20px/800 + tombol 100×44 |
| C-28 | `TealAssuranceBanner` | 27–32, 40 | `#e0f7fa` / `#00796b`, teks konfigurabel |
| C-29 | `TripCoinsSection` | 29, 31, 32, 40 | expandable |
| C-30 | `SpecialRequestSection` | 29, 31, 32 | trigger → C-31 · ✅ dibangun [F-4](#152-flutter) — `special_request_sheet.dart` |
| C-31 | `SpecialRequestSheet` | 37 | radio + checkbox + textarea 200 char · ✅ dibangun [F-4](#152-flutter) — `maxLength` **dinamis** (200 hanya batas atas; sisa anggaran 500/booking yang menentukan) |
| C-32 | `AdditionalInfoSheet` | 33 | read-only · ✅ dibangun [F-6](#152-flutter) — `additional_info_sheet.dart` (+ `showAdditionalInfoSheet()` + `AdditionalInfoSection` untuk baris pemicunya di #31/#32). Isinya **diturunkan** dari `Hotel` lewat `additionalInfoEntries()`, bukan dua daftar terpisah: `(N)` di baris dan isi sheet mustahil beda |
| C-33 | `PromoCodeSection` | 31 | ~~per tipe kamar~~ → **satu baris per booking** · ✅ dibangun [F-5](#152-flutter) — resolusi [A-D3](#113-drift-kontrak-flutter--laravel): API hanya menerima **satu** `voucher_code`, jadi baris per tipe kamar akan menjanjikan yang tak bisa dikirim |
| C-34 | `PromoCodeSheet` | 36 | kartu voucher + state dimmed + alasan · ✅ dibangun [F-5](#152-flutter) — `promo_code_sheet.dart` (+ `showPromoCodeSheet()`), publik agar bisa dipompa test |
| C-35 | `VoucherCard` | 36 | `opacity:0.6` bila tidak eligible · ✅ dibangun [F-5](#152-flutter) — **tidak** jadi widget terpisah: hanya satu sheet yang memakainya dan ia membaca state sheet (`_checking`, kandidat terpilih), jadi ia hidup sebagai method `_card(PromoCandidate)` di `_PromoCodeSheetState`. Yang publik adalah sheet-nya — itu yang butuh terjangkau test |
| C-36 | `TermsConsentBlock` | 32 | ganti "Trip.com" → "Sewain" |
| C-37 | `BookingStatusCard` | 38 | varian hotel vs unit |
| C-38 | `MaskedContactRow` | 40 | `62-0858****3846` |
| C-39 | `RoomDetailSheet` | **34 + 35** | sheet penuh tinggi (`heightFactor: 0.92`) + **pil pemindah tipe kamar** · ✅ dibangun [F-7](#152-flutter) — `room_detail_sheet.dart` (+ `showRoomDetailSheet()` + fungsi murni `distinctRoomTypes()`). **Satu** komponen untuk **dua** nomor mockup, lihat [§6 #34/#35](#grup-d--pilih--pesan-kamar-2637) untuk buktinya. Header + pil di-pin, body scroll. Read-only, tanpa CTA ([A-21](#4-log-anomali-aset--dokumentasi)). Dipicu dari **dua** tempat: kartu tipe kamar di layar detail (link `Lihat Detail`) dan baris nama kamar di layar booking — keduanya mengirim **seluruh** tipe kamar sehingga pil benar-benar berfungsi, bukan hanya kamar yang ditekan |

---

## 9. Alur Pengguna (User Flow)

```
[Home]
  └─ Cari Hotel
      └─ #2 filter_screen
          ├─ tap lokasi   → #1 filter_location
          ├─ tap tanggal  → #5 filter_kalendar ⇄ #6 tanggal_flexibel
          └─ tap tamu     → #3 filter_kamar_tamu
                              └─ tap "Anak N" → #4 select_umur_anak
          └─ [Cari]
              └─ #7 result_pencarian
                  ├─ chip Urutkan   → #10  (4 opsi radio)
                  ├─ chip Filter    → #8
                  ├─ chip Lokasi    → #11
                  ├─ chip Kebutuhan → #9   (grid 8 chip)
                  ├─ tap search bar → #12 top modal
                  │                   ├─ #13 kalender  ⇄ #14 fleksibel
                  │                   └─ #15 kamar & tamu → #16 umur anak
                  └─ tap kartu hotel
                      └─ #17 detail_hotel  (TabBar 8: #18…#25)
                          ├─ tap kartu kamar → #34 / #35 room_detail
                          └─ [Pesan Kamar] → #26 pesan_kamar_section
                              └─ #27 sheet_pesan_kamar
                                  └─ [Pesan]
                                      └─ #28 form_pengisian_kamar
                                          │  (scroll → #29)
                                          │  (varian multi-step: #30 → #31 → #32)
                                          ├─ Kode Promo          → #36
                                          ├─ Permintaan Khusus   → #37
                                          ├─ Informasi Tambahan  → #33
                                          └─ [Pesan]  ──POST bookings──▶
                                              └─ #40 booking_hotel_detail_screen
                                                  ├─ [Bayar] → #39 booking_pembayaran
                                                  │             └─ Midtrans → sewain://payment-result
                                                  └─ [Batalkan Pemesanan]
[Akun] └─ Pesanan Saya → #38 booking_list_screen → #40
```

---

## 10. Pemisahan Domain: Booking Hotel vs Booking Properti

🔴 **Bagian paling penting dari dokumen ini.** Satu tabel `bookings` melayani dua domain; pembedanya adalah kolom **`booking_type`**.

### 10.1 Diskriminator

| | Booking Properti (unit) | Booking Hotel (room) |
|---|---|---|
| `bookings.booking_type` | `'unit'` | `'room'` |
| Yang disewa | **seluruh unit properti** | **N kamar** dari satu/lebih tipe kamar |
| Prefix kode | `BK-` + 8 char random | `HTL-` + `Ymd` + `-` + 4 char random |
| Tabel anak | — | **`booking_rooms`** (1 baris per kamar) |
| Kalender ketersediaan | ketersediaan unit | **`room_inventories`** (allotment harian per tipe kamar) |
| `duration_type` | `daily` \| `weekly` \| `monthly` \| `yearly` | selalu **`daily`** (di-hardcode) |
| Data tamu per kamar | tidak ada | `guests[]` → `booking_rooms.guest_first_name` / `guest_last_name` / `room_number` / `room_name` |
| `rooms_count` | tidak relevan | jumlah kamar |
| `check_in_time` / `check_out_time` | — | dari `hotels.check_in_time` / `check_out_time`, default `14:00:00` / `12:00:00` |
| `host_confirmed` | menunggu konfirmasi mitra | **`true` langsung** (auto-confirm agar bisa bayar seketika) |
| Asuransi (Stay Protection) | opsional | opsional, premi dari `InsurancePlan::calculatePremium($nights, $adults, $roomSubtotal)` |
| Trip Coins | ada | ada — `round($total * 0.005)` |
| Entry point request | `property_id` | `hotel_id` **atau** `property_id` + penanda room |

### 10.2 Cara Laravel memutuskan mode

`BookingController::store()` — resolusi `booking_type`:

```
booking_type =
  $data['booking_type']                       // 1. eksplisit dari klien
  ?? ( property->booking_mode === 'room'      // 2. properti memang mode kamar
       || !empty(room_type_id)                // 3. ada tipe kamar
       || !empty(hotel_id)                    // 4. ada hotel_id
       || !empty(guests)                      // 5. ada data tamu per kamar
       ? 'room' : 'unit' )
```

→ lalu bercabang ke `storeHotelBooking()` atau `storeUnitBooking()`.

**Implikasi untuk Flutter:** kirim `booking_type: "room"` **secara eksplisit** dari layar hotel. Jangan bergantung pada inferensi — inferensi adalah jaring pengaman, bukan kontrak.

### 10.3 Tiga cabang penetapan harga di `storeHotelBooking()`

| Cabang | Kondisi | Harga | Kunci inventori? |
|---|---|---|---|
| **B1** | `guests[]` terisi | per tamu: `matchedRoomType.base_price × nights` (fallback `446637`) | 🔴 **TIDAK** |
| **B2** | `guests[]` kosong **dan** `roomType` ada | dari `room_inventories` bila `count ≥ nights`: Σ `inv.price × rooms_count`; else `base_price × nights × rooms_count` | ✅ `lockForUpdate()` + `increment('booked_count')` + tolak bila `is_closed` atau `allotment - booked_count < rooms_count` |
| **B3** | keduanya kosong | `500000 × nights × rooms_count` (hardcode) | ❌ tidak |

🔴 **Konsekuensi:** layar #28–#32 **selalu** mengirim `guests[]` → selalu masuk **B1** → **allotment tidak pernah dikurangi**. Overbooking mungkin terjadi. Harus diperbaiki di Fase 2 → [§15.1 L-1](#151-laravel).

### 10.4 Rumus uang (urutan wajib)

```
roomSubtotal   = Σ per kamar (harga/malam × malam)
[discount, , err] = VoucherController::resolveDiscount(voucher_code, roomSubtotal)
   └─ err !== null  → HTTP 422 ERR_VALIDATION {voucher_code: [err]}
hasInsurance   = has_insurance || include_insurance
insuranceFee   = hasInsurance && insurance_plan_id
                 ? InsurancePlan::calculatePremium(nights, adults, roomSubtotal)
                 : 0
total          = max(0, roomSubtotal - discount) + insuranceFee
tripCoins      = (int) round(total * 0.005)          // 0,5%
```

- Diskon **tidak** boleh membuat total negatif (`max(0, …)`).
- Premi asuransi ditambahkan **setelah** diskon → tidak ikut didiskon.
- `orders.subtotal = roomSubtotal`, `orders.discount = discount`, `orders.total = total`.

### 10.5 Baris yang dibuat per booking hotel

```
bookings                (1)   status='waiting_payment', host_confirmed=true
 ├─ booking_rooms       (N)   N = count(guests) atau rooms_count
 ├─ booking_insurances  (0|1) status='pending', premium_amount, coverage_amount
 └─ orders              (1)   order_code='ORD-'+8char, status='pending'
```

Semua dalam **satu** `DB::transaction()`.

---

## 11. Kontrak API & Log Drift

### 11.1 Endpoint yang benar-benar ada (`routes/api_mobile.php`, prefix `api/v1`, auth `sanctum`)

| Method | Path | Untuk layar | Catatan |
|---|---|---|---|
| GET | `hotels` | 7 | daftar/pencarian hotel |
| GET | `hotels/{hotel}` | 17–25 | detail hotel |
| GET | `hotels/{hotel}/room-types` | 18 | ⚠️ **tidak pernah dipanggil Flutter** |
| GET | `properties` | 7 | dipakai `HotelSearchProvider` (bypass) |
| POST | `bookings` | 28–32 | **satu-satunya** endpoint pembuatan booking hotel |
| GET | `bookings` | 38 | daftar booking |
| GET | `bookings/{booking}` | 40 | detail booking |

### 11.2 Bentuk respons

Semua dibungkus `app/Support/ApiResponse.php`:

```json
{ "success": true, "message": "…", "data": { }, "meta": { } }
```

`ApiResponse::created(...)` untuk 201; `ApiResponse::error($msg, $status, $errors, $code)` untuk galat (`ApiResponse::ERR_VALIDATION` pada voucher gagal).

**Field harga yang dipancarkan endpoint hotel** (bukan kolom `hotels` — dihitung dari tipe kamar aktif sejak [F-13](#152-flutter); sebelumnya tidak ada sama sekali, lihat [A-D11](#113-drift-kontrak-flutter--laravel)):

| Field | `GET hotels` | `GET hotels/{hotel}` | `GET properties` (mode `room`) | Sumber | `null` berarti |
|---|---|---|---|---|---|
| `price_from` | ✅ | ✅ | ✅ | `base_price` tipe kamar **aktif termurah** | tak ada tipe kamar aktif |
| `price_original` | ✅ | ✅ | ✅ sejak [L-9](#151-laravel) | `price_original` **tipe kamar yang sama** dengan `price_from` — bukan `MIN()` lintas tipe | tarif itu tidak sedang diskon |
| `total_price` | hanya bila `check_in`+`check_out` ada di query | ❌ | ❌ **by design** | `price_from × jumlah malam × rooms_count` (default 1 kamar) | tak ada stay untuk ditotal → UI **sembunyikan** barisnya |

> ⚠️ Ketiganya `float` di JSON (accessor melakukan cast eksplisit), **berbeda** dari `active_room_types[].base_price` yang tetap **string** `"450000.00"` karena cast `decimal:2`. Sisi Dart wajib memakai parser toleran-tipe untuk keduanya ([A-16](#4-log-anomali-aset--dokumentasi)). Jumlah malam dihitung `generateDateRange()` yang **eksklusif** check-out, jadi `count()` = jumlah malam ([§10.4](#104-rumus-uang-urutan-wajib)).

> ℹ️ **Kolom `GET properties` bukan duplikasi implementasi.** `PropertyResource` **mendelegasikan** ke accessor `Hotel` yang sama, jadi kedua jalur mustahil menjawab beda — sampai 16 Agt 2026 ia punya rumus sendiri dan memang menjawab beda ([A-D13](#113-drift-kontrak-flutter--laravel)). `total_price` tetap absen di sana karena endpoint itu melayani hasil campuran unit+room, dan "total" mode unit ikut menghitung `cleaning_fee`/`deposit`/`service_fee` — satu nama untuk dua arti lebih berbahaya daripada key yang tidak ada. Untuk properti mode `unit`, `price_from` tetap dari `property_prices.amount` termurah dan `price_original` selalu `null`.

### 11.3 Drift kontrak Flutter ↔ Laravel

| ID | Tingkat | Drift | Bukti | Perbaikan Fase 2 |
|---|---|---|---|---|
| **A-D1** | ✅ | `bottom_sheet_permintaan` membatasi teks **200** karakter; Laravel memvalidasi `special_requests` **max:500**. Selain itu sheet ber-scope **per tipe kamar**, sedangkan API hanya punya **satu** string per booking. | HTML counter `0/200` vs `BookingController` | Pilih salah satu: (a) UI naikkan ke 500 & gabungkan permintaan semua kamar jadi satu string berlabel, atau (b) tambah kolom `booking_rooms.special_requests`. **Rekomendasi: (a)** — tanpa migrasi. ⟶ ✅ **BERES 16 Agt 2026** lewat [F-4](#152-flutter) dengan opsi (a), tanpa migrasi. Yang tidak terlihat saat audit: 500 itu **plafon bersama seluruh booking**, bukan per kamar — jadi menaikkan counter dari 200 ke 500 justru akan **memperburuk** keadaan (dua kamar × 500 = 422). Yang dipakai: `SpecialRequestDraft.noteBudget()` menghitung sisa nyata (blok kamar lain yang sudah terserialisasi + label yang dicentang kamar ini), dan counter menampilkan sisa itu apa adanya (`0/111`). 200 tetap sebagai **batas atas**, sesuai mockup. `serializeAll()` masih memotong di 500 sebagai jaring pengaman terakhir — memotong permintaan itu buruk, tetapi 422 yang membuang seluruh booking lebih buruk. Dipatok T-F3 + T-F38/T-F40/T-F41/T-F44. |
| **A-D2** | 🟠 | Layar #3/#4 menghasilkan `children_ages[]`, tetapi field ini **tidak ada** di validasi `store()` → data umur anak hilang. | `BookingController::store()` validasi | Tambahkan `children_ages` (array of int) atau simpan di `special_requests`/kolom baru. Keputusan produk. |
| **A-D3** | ✅ | Layar #31 menerapkan promo **per tipe kamar** (Kamar Superior `- Rp22.351` "Digunakan"; Family Suite belum). API hanya menerima **satu** `voucher_code` untuk seluruh booking. | `form_pesan_kamar_step2.html:46-52` vs validasi | Fase 2: batasi UI ke 1 voucher per booking, atau perluas API ke `vouchers[{room_type_id, code}]`. **Rekomendasi: batasi UI** — sesuai kemampuan `resolveDiscount()` sekarang. ⟶ ✅ **BERES 16 Agt 2026** lewat [F-5](#152-flutter), rekomendasi dijalankan **apa adanya**: C-33 `PromoCodeSection` adalah **satu baris untuk seluruh booking**, bukan satu baris per tipe kamar. Konsekuensi yang harus dicatat karena ia mengubah tampilan dari mockup: angka `- Rp22.351` di #31 adalah potongan **atas satu tipe kamar**, sedangkan baris tunggal ini memotong **subtotal kamar seluruh booking** — itulah angka yang benar-benar akan dihitung server (`max(0, $roomSubtotal - $discount) + $insuranceFee`). Tidak ada perubahan Laravel: validasi `voucher_code`, `resolveDiscount()`, dan cabang cashback sudah tertutup [L-1](#151-laravel) dan dipatok T-L18. Dipatok T-F45…T-F58. |
| **A-D4** | 🔴 | `GET hotel/filters` dipanggil `HotelService.getHotelFilters()` & ada di `dummy_api_client.dart`, tetapi **tidak ada route** → 404 di mode API nyata. | `routes/api_mobile.php` | Tambah route + controller, **atau** hapus pemanggilan & bangun opsi filter dari `meta` respons `GET hotels`. |
| **A-D5** | 🔴 | `POST hotel/bookings` dipanggil `HotelService.createHotelBooking()` & ada di dummy client, tetapi **tidak ada route**. Diperkuat oleh 2 test hijau yang **memaku** path salah ini (`hotel_service_test.dart`, `expectedPath: 'hotel/bookings'` — lihat [A-12](#4-log-anomali-aset--dokumentasi)). | idem | Arahkan Flutter ke `POST bookings` dengan `booking_type='room'`. **Jangan** buat endpoint kedua. Perbaikan ini **memecahkan** kedua test tersebut → perbarui `expectedPath` bersamaan ([§15.3](#153-test--wajib-permintaan-eksplisit-pengguna)). |
| **A-D6** | 🟠 | `HotelSearchProvider` memakai `PropertyService.searchHotels()` → `GET properties`, melewati `GET hotels` & `HotelService`; menyimpan `Paginated<Property>` bukan `Paginated<Hotel>` → field khusus hotel (skor, jumlah ulasan, jarak, tag) hilang. | `hotel_search_provider.dart` | Alihkan ke `HotelService.searchHotels()` → `GET hotels`, ubah tipe state ke `Paginated<Hotel>`. |
| **A-D7** | 🟠 | `HotelSearchQuery.fromUri` memanggil `int.tryParse(q['city_id']!)` — **null-assertion** akan throw bila `city_id` absen dari deep link `sewain://search?...`. | `hotel_search_query.dart` | Ganti ke `q['city_id'] != null ? int.tryParse(q['city_id']!) : null`. |
| **A-D8** | 🟡 | `GET hotels/{hotel}/room-types` ada di Laravel tapi tak pernah dipakai; #18 kemungkinan mengandalkan tipe kamar yang ter-embed di detail hotel. | grep Flutter | Verifikasi apakah `GET hotels/{hotel}` sudah menyertakan `room_types`; kalau ya, tandai endpoint ini sebagai cadangan. |
| **A-D9** | 🔴 | **TERVERIFIKASI 16 Agt 2026.** `PropertyController::index()` menerima **tepat 4** nilai: `in:newest,price_asc,price_desc,rating` ([baris 42](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/PropertyController.php), `match` baris 179–185). Konsekuensinya: (a) opsi UI **"Jarak terdekat" tidak punya implementasi server** sama sekali — `lat`/`lng` diterima tapi tak ada cabang sorting jarak; (b) `docs/hotel/03-query-filters.md` baris 42 menuliskan `popularity` yang **ditolak 422** oleh controller nyata; (c) "Rekomendasi" hanya memetakan ke `newest` (`latest()`), bukan peringkat rekomendasi. | `PropertyController.php:42,179-185` | Pemetaan final: Rekomendasi→`newest`/kosong · Harga terendah→`price_asc` · Rating tertinggi→`rating`. Untuk "Jarak terdekat": tambah cabang `distance` (haversine dari `lat`/`lng`) **atau** sembunyikan opsinya — jangan tampilkan tombol yang tak berefek. Kamus lengkap: [03 §1.1](../03-query-filters.md#11-kamus-nilai-sort--ui--server-terverifikasi). |
| **A-D10** | 🟡 | Field `contact_phone` divalidasi **max:25** di controller, sedangkan kolom migrasi bergaya 20 char. | `BookingController` validasi | Selaraskan validasi ke lebar kolom, atau lebarkan kolom. Jangan biarkan berbeda — PostgreSQL akan menolak >20 walau validasi lolos. |
| **A-D11** | 🔴 | **DITEMUKAN 16 Agt 2026 saat mengerjakan [F-8](#152-flutter).** `GET hotels` dan `GET hotels/{hotel}` **tidak pernah memancarkan** `price_per_night`, `price_original`, maupun `total_price` — ketiganya bukan kolom `hotels` dan tak ada satu pun yang dihitung di controller. `index()` mengembalikan model `Hotel` mentah (`ApiResponse::paginated($hotels, …)`), `show()` mengembalikan `$hotel->toArray()` + field properti; harga hanya ada di dalam `active_room_types[].base_price`. Akibatnya `Hotel.pricePerNight`/`totalPrice` = **0.0** dan `priceOriginal` = **null** di API nyata, sehingga **setiap kartu hasil pencarian menampilkan `Rp 0` dan `Total harga: Rp 0`**. Tertutup selama ini karena fixture dummy `GET_hotels.json` memuat ketiga kunci itu, sedangkan API nyata tidak. Kolateral dari akar yang sama: `review_count` selalu 0 dan `score_label` selalu jatuh ke default `'Luar Biasa'` (`hotels` tak punya kedua kolom itu, dan hotel **tidak** dibungkus `PropertyResource`). | [`HotelApiController.php:123-125`](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L123-L125) (index) · [`:167-183`](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L167-L183) (show) · casts [`Hotel.php:34-44`](../../../laravel/app/Models/Hotel.php#L34-L44) — tanpa kolom harga · konsumen: [`hotel_results_screen.dart:1071-1087`](../../../flutter/lib/screens/property/hotel/hotel_results_screen.dart#L1071-L1087) | Server-side lebih tepat daripada tambal di klien: `index()` sudah punya `withMin('activeRoomTypes as min_price', 'base_price')` untuk sort harga — jadikan **selalu** dieager-load dan pancarkan sebagai `price_from` (nama yang sudah dibaca `Hotel.fromJson`), plus `total_price` = `price_from × nights × rooms_count` bila `check_in`/`check_out` ada di query. Sementara itu layar detail sudah aman lewat `_nightlyFrom()` (fallback ke tipe kamar termurah yang bookable); kartu hasil pencarian **belum** → dilacak sebagai [F-13](#152-flutter). ⟶ ✅ **BERES 16 Agt 2026** lewat [F-13](#152-flutter), tapi **bukan** dengan `withMin()` kedua: `orderByDistance()` memanggil `->select('hotels.*')` yang **mengganti** daftar kolom, jadi kolom hasil `withMin` (yang memakai `addSelect`) hilang tepat pada `sort=distance`. Yang dipakai: accessor `price_from`/`price_original` di `Hotel` yang membaca relasi room-type **yang sudah ter-eager-load**, di-`append()` per koleksi oleh `HotelApiController::attachCardPricing()`, plus `total_price` yang di-`setAttribute` (nama sengaja berbeda dari accessor mana pun — lihat [A-D12](#113-drift-kontrak-flutter--laravel)). Dipatok T-L27…T-L32 + T-F32…T-F35. |
| **A-D12** | 🟡 | **DITEMUKAN 16 Agt 2026 saat mengerjakan [F-13](#152-flutter). Sengaja dibiarkan terbuka.** `min_price`/`max_price` memakai predikat **"punya ≥1 tipe kamar aktif di rentang itu"** (`whereHas('activeRoomTypes', …)`), sedangkan `price_from` yang tercetak di kartu adalah **"tarif aktif termurah"** — dua definisi berbeda atas hotel yang sama. Contoh nyata dari fixture: `?min_price=1000000` meloloskan hotel karena Family Suite-nya 1.200.000, tetapi kartunya mengutip Kamar Superior **450.000**, yaitu angka **di bawah** batas yang baru saja diminta pengguna. Tidak salah hitung — hanya tidak sinkron dengan harapan pengguna. | `HotelApiController::index()` filter harga vs `Hotel::getPriceFromAttribute()` | **Belum diperbaiki, dan dua tambalan yang jelas sudah diuji lalu ditolak:** (a) `setAttribute('price_from', …)` dari controller **tidak berpengaruh** — `attributesToArray()` menjalankan get-mutator atas atribut apa pun yang punya satu, jadi nilai accessor menimpa nilai yang di-set (inilah sebabnya `total_price` **tidak** boleh dinamai ulang jadi salah satu nama accessor); (b) mempersempit eager-load `activeRoomTypes` ke rentang harga akan ikut mengubah key `active_room_types` di respons — key yang dibaca `Hotel.cheapestBookableRoom` untuk fallback pilihan kamar di layar booking, sehingga filter harga diam-diam mengubah **kamar apa yang dipesan**. Perbaikan yang disarankan: relasi terpisah (mis. `roomTypesInPriceRange`) khusus untuk penetapan harga kartu, atau pancarkan `price_from_in_range` sebagai field ketiga dan biarkan `active_room_types` utuh. Keputusan produk: apakah kartu harus mengutip kamar termurah, atau kamar termurah **yang cocok filter**. |
| **A-D13** | 🟠 | **DITEMUKAN 16 Agt 2026 saat memverifikasi klaim yang baru ditulis sendiri di [07-compatibility-map.md](../07-compatibility-map.md) — "dua jalur, dua implementasi, selaraskan bila salah satu diubah". Ternyata keduanya memang sudah tidak selaras.** Hotel yang **sama** dihargai berbeda oleh dua endpoint, karena `PropertyResource` menghitung ulang harga sendiri alih-alih memakai accessor `Hotel`. Tiga selisihnya: **(a) filter `is_active`** — `PropertyResource` memakai `min('base_price')` atas **seluruh** tipe kamar termasuk `is_active = false`, sedangkan `GET hotels` hanya yang aktif; satu tipe kamar murah yang dinonaktifkan cukup untuk membuat `GET properties` mengutip tarif yang **tidak bisa dipesan siapa pun**. **(b) tipe JSON** — `Collection::min()` mengembalikan nilai cast `decimal:2` **mentah**, jadi `price_from` di `GET properties` adalah **string** `"450000.00"` sementara accessor mengembalikan **float**; Flutter aman karena `_toDouble`, konsumen ketat tidak. **(c) field yang hilang** — `price_original` dan `total_price` **tidak ada sama sekali** di `PropertyResource`, jadi hotel yang datang lewat jalur ini **tak pernah bisa** menampilkan harga coret. Jalur ini bukan jalur mati: [A-D6](#113-drift-kontrak-flutter--laravel) mencatat `HotelSearchProvider` sempat memakainya, dan `hostIndex()` (daftar properti Mitra) masih memakainya sampai sekarang. Akar yang sama menular ke **`has_breakfast`** — ia memanggil `contains('breakfast_included', true)` tanpa filter aktif, jadi satu tipe kamar bersarapan yang dinonaktifkan tetap mengiklankan sarapan. | [`PropertyResource.php:19-22`](../../../laravel/app/Http/Resources/PropertyResource.php#L19-L22) (kode lama: `min('base_price')`, tanpa `is_active`) · `:45` (`has_breakfast`) vs [`Hotel::cheapestActiveRoomType()`](../../../laravel/app/Models/Hotel.php#L78-L91) · eager-load [`PropertyController.php:48`](../../../laravel/app/Http/Controllers/Api/PropertyController.php#L48) & `:244` | ⟶ ✅ **BERES 16 Agt 2026** lewat [L-9](#151-laravel), dengan **menghapus** implementasi kedua alih-alih menyamakan dua rumus: `PropertyResource` sekarang **mendelegasikan** ke `$this->hotel->price_from` / `->price_original`. Gratis secara query — accessor membaca relasi `roomTypes` yang **sudah** di-eager-load lewat `with('hotel.roomTypes')`, persis cabang yang dirancang untuk endpoint host di docblock accessor-nya. Tiga penyesuaian yang **wajib** menyertainya: (1) `hostIndex()` diubah dari `with('hotel')` → `with('hotel.roomTypes')`, kalau tidak `relationLoaded('roomTypes')` gagal dan daftar Mitra jatuh ke tarif `property_prices`; (2) fallback `property_prices` **dikunci** ke `booking_mode !== 'room'` — tabel itu tarif mode unit, dan hotel tanpa tipe kamar aktif memang **tidak punya** tarif; `null` adalah kontraknya (klien merender "Harga belum tersedia"), bukan angka yang tak bisa dibeli; (3) `has_breakfast` ikut memfilter `is_active` **dan** dipagari diskriminator `booking_mode === 'room'` yang sama — dulu ia tidak memeriksanya sama sekali. `total_price` **sengaja tetap** absen di sini: endpoint ini melayani hasil campuran unit+room dan "total" mode unit ikut menghitung `cleaning_fee`/`deposit`/`service_fee`, jadi nama yang sama akan berarti dua hal berbeda. Dipatok T-L33…T-L37. |
| **A-D14** | 🟡 | **DITEMUKAN 16 Agt 2026 saat mengerjakan [F-5](#152-flutter).** Payload daftar voucher di [§12.5](#125-bottom_sheet_kode_promo-36--voucher) **tidak bisa dipenuhi server**: `GET vouchers` mengembalikan **model `Voucher` mentah**, jadi tidak ada `available_count`, tidak ada `is_eligible`, tidak ada `ineligible_reason`, dan **kolom `subtitle` tidak ada** di tabel `vouchers` sama sekali. Lebih jauh, `index()` sudah memfilter `is_active` + `starts_at <= now() <= ends_at`, jadi setiap baris yang sampai ke klien **selalu** valid menurut waktu — mustahil ada kartu kedaluwarsa untuk di-dim. Akibatnya tiga kartu dimmed + header `(0 Tersedia)` di mockup #36 **tidak punya sumber data**: satu-satunya oracle kelayakan yang benar-benar ada adalah `POST vouchers/apply`, yang menjawab 422 dengan alasan di `errors.code`. | [`VoucherController::index()`](../../../laravel/app/Http/Controllers/Api/VoucherController.php#L12-L24) (tanpa transformer/resource) · [`:26-52`](../../../laravel/app/Http/Controllers/Api/VoucherController.php#L26-L52) (`apply`, 422 `['code' => [$error]]`) · migrasi `vouchers` — kolom: `code`, `title`, `type`, `value`, `category`, `starts_at`, `ends_at`, `usage_limit`, `is_active` | ⟶ ✅ **DIKERJAKAN DI KLIEN 16 Agt 2026 lewat [F-5](#152-flutter), tanpa menyentuh Laravel.** Kartu **mulai** dalam keadaan bisa ditawarkan (`PromoCandidate.from()` → `isEligible: true` untuk semua), dan berpindah ke state dimmed **hanya** setelah server menolaknya (`PromoCandidate.reject(code, reason)`), sehingga header `(N Tersedia)` menghitung kandidat yang belum ditolak — `(0 Tersedia)` di mockup tercapai lewat penolakan nyata, bukan lewat angka yang ditebak. Alasan yang tampil adalah **kata-kata server** apa adanya (`'Voucher ini sudah kedaluwarsa.'` dst.), bukan string yang diarang klien. Baris kedua kartu memakai `category` (satu-satunya field deskriptif yang ada) lewat `PromoLabels.category()`. §12.5 kini ditandai **aspirasional**. Kalau kelak diputuskan server yang menilai: butuh kolom `subtitle` + resource yang menyuntik `is_eligible`/`ineligible_reason` per konteks booking (subtotal, jumlah malam, properti) — dan konteks itu **belum** dikirim ke `GET vouchers` sama sekali. Dipatok T-F49 + T-F52/T-F54. |
| **A-D15** | 🟡 | **DITEMUKAN 16 Agt 2026 saat mengerjakan [F-5](#152-flutter). Sengaja dibiarkan.** Jendela masa berlaku voucher dirender **apa adanya dalam UTC**, bukan waktu lokal pengguna. `config/app.php` menetapkan `'timezone' => 'UTC'` dan `Voucher.php` men-cast `starts_at`/`ends_at` ke `datetime`, jadi Laravel mengirim ISO-8601 berakhiran `Z`; sisi Dart `DateTime.tryParse` menghasilkan `DateTime` UTC dan `Formatters.dayMonthYearDotTime` membaca `d.hour`/`d.minute` langsung. Untuk pengguna WIB, "Berlaku sampai 21 Agt 2026, 22.59" sebenarnya berarti 22 Agt 05.59 WIB — **7 jam lebih longgar** dari yang tertulis. | `config/app.php` (`timezone` `UTC`) · `Voucher::$casts` · `formatters.dart` (`dayMonthYearDotTime`) · grep `toLocal()` di `flutter/lib` → **0 hasil** | **Tidak ditambal di F-5, dan sengaja.** `.toLocal()` tidak dipakai **di mana pun** dalam `flutter/lib` — seluruh tanggal aplikasi (check-in/out, jadwal pembayaran, riwayat booking) dirender dengan konvensi yang sama. Menambahkannya hanya pada satu layar akan membuat #36 satu-satunya layar yang berbeda, yaitu menukar drift yang seragam dengan drift yang tak konsisten. Perbaikan yang benar adalah **satu keputusan tingkat aplikasi** (pasang `.toLocal()` di `Formatters`, atau set `APP_TIMEZONE=Asia/Jakarta` di Laravel — lalu perbarui seluruh test tanggal), bukan tambalan setempat. Efek samping yang menguntungkan: literal `_kFixtureValidity` di test bebas-mesin, tidak tergantung timezone runner. |
| **A-D16** | 🟠 | **DITEMUKAN 16 Agt 2026 saat mengerjakan [F-7](#152-flutter). Empat kolom yang sudah ada tapi tak pernah sampai ke layar — dua sebab berbeda.** **(a) Wire diam:** `properties.cancellation_policy` ada sejak migrasi `2026_08_09_121257`, di-`fillable`, dan diisi `HotelSeeder` pada **kelima** hotel — tetapi `HotelApiController::show()` tidak pernah memilih maupun meratakannya, jadi satu-satunya layar yang mencetak syarat pembatalan (#34/#35, seksi `Kebijakan & layanan`) tidak punya sumber. **(b) Model diam:** `active_room_types[]` sudah membawa `description`, `facilities`, dan `images` — `show()` memancarkan `$rt->toArray()` **mentah** — tetapi `HotelRoomItem.fromJson` tidak mem-parse `description` maupun `facilities` sama sekali, sehingga grid `Fasilitas Kamar` (8 item nyata di seeder) selalu kosong. Lebih buruk untuk `images`: ia **di-parse**, tapi dengan `'$e'` atas elemen yang menurut komentar migrasi berbentuk **`[{url, caption}]`** → yang tercetak di galeri adalah literal `{url: …, caption: …}`, bukan URL. | [`HotelApiController.php:200,221`](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L200) (sesudah perbaikan) · [`HotelSeeder.php:68`](../../../laravel/database/seeders/HotelSeeder.php#L68) · [`RoomType.php:35-36,51-52`](../../../laravel/app/Models/RoomType.php#L35-L36) (`facilities`/`images` cast `array`) · konsumen: `HotelRoomItem.fromJson` di [`hotel.dart`](../../../flutter/lib/models/hotel.dart) | ✅ **BERES 16 Agt 2026** lewat [F-7](#152-flutter), diperbaiki **di sisi yang salah masing-masing** — bukan semuanya di klien: (a) `show()` kini memilih `cancellation_policy` di eager-load `property:` **dan** meratakannya ke `data.cancellation_policy`, persis pola `name`/`address`/`gallery` di sekitarnya; `Hotel.cancellationPolicy` membaca **kedua** bentuk (rata **dan** bersarang di `property`) karena kedua bentuk itu benar-benar beredar. (b) `HotelRoomItem` mendapat `description` + `facilities`, dan helper file-level `_flattenStringList(raw, keys)` mereduksi tiap elemen ke kunci pertama yang ia punya (`url` untuk gambar, `name` untuk fasilitas) sambil tetap menerima string biasa — panel admin bisa menulis salah satu bentuk, dan **keduanya** harus tampil sebagai teks, bukan sebagai literal `Map`. **Yang sengaja TIDAK ditambal:** tenggat pembatalan. Kolomnya `string(255)` teks bebas, jadi timeline dua-baris ber-tanggal di mockup (`Sebelum 16 Agt 2026, 23.59` / `Setelah …`) **tidak bisa dihitung** — mencetak tanggal tebakan pada layar kebijakan refund adalah jenis kesalahan yang berakhir di sengketa pembayaran. Butuh `properties.cancellation_deadline_hours`. Dipatok T-F65/T-F66 + T-L38/T-L39. |

> ⚠️ **Catatan test:** test Laravel memakai **SQLite in-memory** yang **tidak** menegakkan CHECK constraint. Bug ENUM/lebar kolom (mis. A-D10) hanya muncul di PostgreSQL. Test yang menyentuh batas kolom harus dijalankan juga di `pgsql`.

---

## 12. Dummy JSON Payload per Form

Semua payload di bawah **hanya** memakai field yang benar-benar ada pada validasi `BookingController::store()`. Field yang belum didukung ditandai dan **dikeluarkan** dari contoh yang valid.

### 12.1 Kontrak validasi lengkap (acuan)

| Field | Aturan | Layar sumber |
|---|---|---|
| `property_id` | nullable, exists:properties,id | — |
| `hotel_id` | nullable, exists:hotels,id | 17 |
| `check_in` | **required**, date, after_or_equal:today | 5/6/13/14 |
| `check_out` | **required**, date, after:check_in | 5/6/13/14 |
| `duration_type` | nullable, in:daily,weekly,monthly,yearly | — (hotel → `daily`) |
| `booking_type` | nullable, in:unit,room | ← kirim `room` |
| `room_type_id` | nullable, exists:room_types,id | 18/34/35 |
| `rooms_count` | nullable, integer, min:1 | 3/15 |
| `adults` | nullable, integer, min:1 | 3/15 |
| `children` | nullable, integer, min:0 | 3/15 |
| `guests` | nullable, array | 28/30 |
| `guests.*.room_number` | required_with:guests, integer | 28/30 |
| `guests.*.room_name` | nullable, string | 27/28 |
| `guests.*.first_name` | required_with:guests, string, max:100 | 28/30 |
| `guests.*.last_name` | nullable, string, max:100 | 28/30 |
| `contact_email` | nullable, email | 28/30 |
| `contact_phone` | nullable, string, max:25 | 28/30 |
| `special_requests` | nullable, string, max:500 | 37 |
| `receive_promos` | nullable, boolean | 29/32 |
| `voucher_code` | nullable, string | 36 |
| `include_insurance` | nullable, boolean | 31 |
| `has_insurance` | nullable, boolean | 31 |
| `insurance_plan_id` | nullable, exists:insurance_plans,id | 31 |
| `holder_name` | nullable, string, max:150 | 31 |
| `holder_identity` | nullable, string, max:50 | 31 |

⚠️ **Perhatikan:** nama field tanggal adalah `check_in` / `check_out` — **bukan** `start_date` / `end_date`.

### 12.2 Query pencarian — layar #1–#6, #7–#16

`GET /api/v1/hotels?…` (query string, bukan body):

```json
{
  "city_id": 1,
  "q": "Jakarta Pusat",
  "check_in": "2026-08-15",
  "check_out": "2026-08-16",
  "rooms_count": 2,
  "adults": 2,
  "children": 1,
  "children_ages": [4],
  "sort": "recommended",
  "price_min": 200000,
  "price_max": 1500000,
  "star_ratings": [3, 4, 5],
  "needs": ["kamar_keluarga", "termasuk_sarapan"],
  "page": 1,
  "per_page": 20
}
```

> `children_ages` → [A-D2](#113-drift-kontrak-flutter--laravel): **dipastikan tidak didukung** — `BookingController::store()` tidak memvalidasi maupun menyimpannya, jadi umur anak hilang saat submit.
> `sort` → [A-D9](#113-drift-kontrak-flutter--laravel): **sudah diverifikasi** — server hanya menerima `newest|price_asc|price_desc|rating`; `Jarak terdekat` belum ada implementasinya.

### 12.3 `POST bookings` — form pengisian kamar (multi kamar)

Payload kanonik dari layar #27 → #28 (2 kamar: Family Suite + Kamar Superior), sesuai data mockup:

```json
{
  "hotel_id": 1,
  "booking_type": "room",
  "check_in": "2026-08-15",
  "check_out": "2026-08-16",
  "duration_type": "daily",
  "rooms_count": 2,
  "adults": 4,
  "children": 1,
  "guests": [
    {
      "room_number": 1,
      "room_name": "Family Suite",
      "first_name": "Tea",
      "last_name": "Wan"
    },
    {
      "room_number": 2,
      "room_name": "Kamar Superior",
      "first_name": "Moh",
      "last_name": "Baswan"
    }
  ],
  "contact_email": "mohbaswandegorie@gmail.com",
  "contact_phone": "+6285812343846",
  "receive_promos": true
}
```

**Respons 201 yang diharapkan:**

```json
{
  "success": true,
  "message": "Booking hotel berhasil dibuat. Selesaikan pembayaran Anda.",
  "data": {
    "booking": {
      "id": 1,
      "booking_code": "HTL-20260815-A1B2",
      "property_id": 1,
      "user_id": 7,
      "check_in": "2026-08-15",
      "check_out": "2026-08-16",
      "check_in_time": "14:00:00",
      "check_out_time": "12:00:00",
      "duration_type": "daily",
      "booking_type": "room",
      "rooms_count": 2,
      "adults": 4,
      "children": 1,
      "contact_email": "mohbaswandegorie@gmail.com",
      "contact_phone": "+6285812343846",
      "special_requests": null,
      "trip_coins_earned": 5449,
      "receive_promos": true,
      "status": "waiting_payment",
      "has_insurance": false,
      "insurance_fee": "0.00",
      "total_price": "1089796.00",
      "host_confirmed": true,
      "booking_rooms": [
        {
          "id": 1, "booking_id": 1, "room_type_id": 2,
          "room_number": 1, "room_name": "Family Suite",
          "guest_first_name": "Tea", "guest_last_name": "Wan",
          "quantity": 1, "price_per_night": "643159.00", "subtotal": "643159.00",
          "room_type": { "id": 2, "name": "Family Suite", "base_price": "643159.00" }
        },
        {
          "id": 2, "booking_id": 1, "room_type_id": 1,
          "room_number": 2, "room_name": "Kamar Superior",
          "guest_first_name": "Moh", "guest_last_name": "Baswan",
          "quantity": 1, "price_per_night": "446637.00", "subtotal": "446637.00",
          "room_type": { "id": 1, "name": "Kamar Superior", "base_price": "446637.00" }
        }
      ],
      "insurance": null
    },
    "order": {
      "id": 1,
      "order_code": "ORD-X7K2M9QP",
      "booking_id": 1,
      "user_id": 7,
      "subtotal": "1089796.00",
      "discount": "0.00",
      "total": "1089796.00",
      "status": "pending"
    }
  }
}
```

> `643159 + 446637 = 1.089.796` → cocok dengan total di mockup. `trip_coins_earned = round(1089796 × 0.005) = 5449`.

### 12.4 `POST bookings` — kamar tunggal via `room_type_id` (jalur ber-allotment)

Tanpa `guests[]` → masuk cabang **B2**, inventori dikunci & dikurangi. Gunakan bentuk ini kalau kontrol allotment wajib:

```json
{
  "hotel_id": 1,
  "booking_type": "room",
  "room_type_id": 1,
  "check_in": "2026-08-15",
  "check_out": "2026-08-18",
  "rooms_count": 2,
  "adults": 2,
  "children": 0,
  "contact_email": "mohbaswandegorie@gmail.com",
  "contact_phone": "+6285812343846"
}
```

**Galat allotment (422):**

```json
{
  "success": false,
  "message": "Kamar penuh pada tanggal 2026-08-16.",
  "data": null
}
```

### 12.5 `bottom_sheet_kode_promo` (#36) — voucher

**Payload state UI (lokal, bukan API):**

```json
{
  "input_code": "NEWUSER10",
  "applied": [
    { "room_type_id": 1, "room_type_name": "Kamar Superior", "code": "NEWUSER10", "discount_amount": 22351, "status": "used" },
    { "room_type_id": 2, "room_type_name": "Family Suite", "code": null, "status": "not_applicable", "reason": "4 tidak dapat digunakan" }
  ]
}
```

**Yang dikirim ke API — hanya satu kode** ([A-D3](#113-drift-kontrak-flutter--laravel)):

```json
{ "voucher_code": "NEWUSER10" }
```

> ⚠️ **Nama field berbeda per endpoint — jebakan nyata.** Hanya `POST bookings` yang menyebutnya `voucher_code`. Pemeriksaan pra-booking `POST vouchers/apply` memvalidasi **`code`** (plus `subtotal`, wajib, `numeric min:0`), dan galat 422-nya muncul di **`errors.code`** — bukan `errors.voucher_code`. Membaca kunci yang salah akan menelan kata-kata alasan server dan jatuh ke pesan envelope generik; dipatok T-F51.
>
> ```json
> { "code": "NEWUSER10", "subtotal": 893274 }
> ```
>
> Balasan sukses: `{ "voucher": {…}, "discount": 89327, "subtotal": 893274, "total": 803947 }`. **`discount` dari server adalah satu-satunya angka yang boleh dipakai** — jangan hitung ulang dari `value`: `type: 'cashback'` **sah** namun mengembalikan `discount: 0` ([§10.4](#104-rumus-uang-urutan-wajib), T-L18), dan `total` server sudah ter-`max(0, …)`.

**Bentuk daftar voucher untuk UI** (kartu dimmed + alasan) — ⚠️ **ASPIRASIONAL: bukan yang dikirim server** ([A-D14](#113-drift-kontrak-flutter--laravel)):

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "available_count": 0,
    "vouchers": [
      {
        "code": "DISKON5-3MALAM",
        "title": "Diskon 5% Maks. Diskon Rp21.000",
        "subtitle": "Diskon 3 malam",
        "valid_from": "2026-08-14T11:57:00+07:00",
        "valid_until": "2026-08-21T22:59:00+07:00",
        "is_eligible": false,
        "ineligible_reason": "Tidak berlaku untuk jumlah malam yang Anda pilih"
      },
      {
        "code": "HOMESTAY393",
        "title": "Diskon hingga Rp393.750",
        "subtitle": "Promo Homestay Unggulan",
        "valid_from": "2026-08-14T11:57:00+07:00",
        "valid_until": "2026-08-21T22:59:00+07:00",
        "is_eligible": false,
        "ineligible_reason": "Tidak berlaku untuk akomodasi ini"
      },
      {
        "code": "NEWUSER10",
        "title": "Diskon 10% Maks. Diskon Rp90.000",
        "subtitle": "Kode promo pengguna baru (pemesan pertama)",
        "valid_from": "2026-08-13T02:12:00+07:00",
        "valid_until": "2026-08-27T22:59:00+07:00",
        "is_eligible": false,
        "ineligible_reason": "Kode promo ini tidak dapat digunakan pada pemesanan saat ini"
      }
    ]
  }
}
```

**Bentuk NYATA `GET vouchers`** — model `vouchers` mentah, tanpa transformer, sudah tersaring "valid saat ini" (`is_active` + `starts_at <= now() <= ends_at`, urut `ends_at`). Inilah yang dibaca `Voucher.fromJson` dan yang dipakai [F-5](#152-flutter):

```json
{
  "success": true,
  "message": "Voucher berhasil dimuat.",
  "data": [
    {
      "id": 1,
      "code": "HOTWEEK10",
      "title": "Diskon 10% Hot Week",
      "type": "percentage",
      "value": "10.00",
      "category": "weekly_hot_deal",
      "starts_at": "2026-08-14T11:57:00.000000Z",
      "ends_at": "2026-08-21T22:59:00.000000Z",
      "usage_limit": 100,
      "is_active": true,
      "created_at": "2026-07-14T08:06:00.000000Z",
      "updated_at": "2026-07-14T08:06:00.000000Z"
    }
  ],
  "meta": { "total": 1 }
}
```

> 🟡 Tiga hal yang membedakannya dari payload aspirasional di atas, semuanya berkonsekuensi UI: **(1)** `value` menyeberang sebagai **string** (`decimal:2` tanpa cast di model), jadi parser wajib toleran-tipe seperti `active_room_types[].base_price`; **(2)** tidak ada `subtitle` — baris kedua kartu memakai `category` lewat `PromoLabels.category()`; **(3)** tidak ada `is_eligible`/`ineligible_reason`/`available_count`, jadi kelayakan **hanya** bisa diketahui dengan memanggil `POST vouchers/apply` ([A-D14](#113-drift-kontrak-flutter--laravel)). `is_active` sudah `boolean` dan `starts_at`/`ends_at` sudah `datetime` (cast model), sisanya kolom mentah — termasuk `created_at`/`updated_at` yang tidak dipakai UI. Zona waktu `Z` dirender apa adanya — [A-D15](#113-drift-kontrak-flutter--laravel).

**Galat voucher pada `POST bookings` (422):**

```json
{
  "success": false,
  "message": "Kode voucher tidak valid.",
  "data": null,
  "errors": { "voucher_code": ["Kode voucher tidak valid."] },
  "error_code": "ERR_VALIDATION"
}
```

### 12.6 `bottom_sheet_permintaan` (#37) — permintaan khusus

**Payload state UI (per tipe kamar):**

```json
{
  "room_type_id": 1,
  "room_type_name": "Kamar Superior",
  "bed_preference": "prefer_two_single",
  "lift_position": "far_from_lift",
  "other_requests": ["soundproof_room", "non_corner_room"],
  "additional_note": "Tolong siapkan kamar di lantai tinggi.",
  "additional_note_max": 200
}
```

**Serialisasi ke API — satu string, maks 500 char** ([A-D1](#113-drift-kontrak-flutter--laravel)):

```json
{
  "special_requests": "Kamar Superior: Utamakan 2 single bed; Jauh dari lift; Kamar kedap suara; Kamar non-corner. Catatan: Tolong siapkan kamar di lantai tinggi."
}
```

**Kamus nilai (kunci ini di Fase 2):**

| Grup | Nilai | Label UI |
|---|---|---|
| `bed_preference` | `prefer_two_single` | Utamakan 2 single bed |
| | `prefer_one_queen` | Utamakan 1 queen bed |
| `lift_position` | `far_from_lift` | Jauh dari lift |
| | `near_lift` | Dekat lift |
| `other_requests[]` | `soundproof_room` | Kamar kedap suara |
| | `smoke_odor_cleaning` | Perlu pembersihan khusus asap rokok |
| | `non_corner_room` | Kamar non-corner |
| | `luggage_storage` | Perlu menitipkan bagasi |

### 12.7 `form_pesan_kamar_step2` (#31) — asuransi (Stay Protection)

```json
{
  "hotel_id": 1,
  "booking_type": "room",
  "check_in": "2026-08-15",
  "check_out": "2026-08-16",
  "rooms_count": 1,
  "adults": 2,
  "children": 0,
  "guests": [
    { "room_number": 1, "room_name": "Kamar Superior", "first_name": "Tea", "last_name": "Wan" }
  ],
  "contact_email": "mohbaswandegorie@gmail.com",
  "contact_phone": "+6285812343846",
  "voucher_code": "NEWUSER10",
  "has_insurance": true,
  "insurance_plan_id": 2,
  "holder_name": "Tea Wan",
  "holder_identity": "3174091234567890",
  "special_requests": "Kamar Superior: Utamakan 1 queen bed; Dekat lift.",
  "receive_promos": true
}
```

**Potongan respons asuransi:**

```json
{
  "has_insurance": true,
  "insurance_fee": "35000.00",
  "insurance": {
    "id": 1,
    "booking_id": 1,
    "insurance_plan_id": 2,
    "holder_name": "Tea Wan",
    "holder_identity_number": "3174091234567890",
    "premium_amount": "35000.00",
    "coverage_amount": "5000000.00",
    "status": "pending",
    "insurance_plan": { "id": 2, "name": "Stay Protection Plus", "coverage_amount": "5000000.00" }
  }
}
```

> `include_insurance` adalah alias `has_insurance` — controller menerima keduanya (`||`). Pakai **`has_insurance`** saja agar konsisten.

### 12.8 `bottom_sheet_informasi_tambahan` (#33) — read-only

Tidak ada payload keluar. Bentuk data masuk:

```json
{
  "title": "Informasi Tambahan",
  "sections": [
    {
      "heading": "Kebijakan Deposit",
      "body": "Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in"
    }
  ]
}
```

### 12.9 `booking_hotel_detail_screen` (#40) — `GET bookings/{id}`

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "booking": {
      "id": 1,
      "booking_code": "HTL-20260815-A1B2",
      "reference_number": "1367843010567330",
      "pin_masked": "*****",
      "payment_deadline": "2026-08-15T11:19:00+07:00",
      "countdown_seconds": 1680,
      "booking_type": "room",
      "status": "waiting_payment",
      "check_in": "2026-08-15",
      "check_out": "2026-08-16",
      "check_in_time": "14:00:00",
      "check_out_time": "12:00:00",
      "nights": 1,
      "rooms_count": 2,
      "adults": 4,
      "children": 1,
      "contact_email_masked": "mohba******gorie@gmail.com",
      "contact_phone_masked": "62-0858****3846",
      "primary_guest_name": "Tea Wan",
      "total_price": "1498990.00",
      "trip_coins_earned": 7495,
      "assurances": ["Kami Samakan Harga", "Jaminan Menginap di Hotel"],
      "booking_rooms": [ "…lihat §12.3…" ],
      "insurance": null
    }
  }
}
```

> Mockup menulis `Dapatkan 43 Trip Coins (≈Rp7.665)`. Angka itu **data contoh Trip.com**, bukan spesifikasi. Rumus yang berlaku: `round(total × 0.005)` → `round(1498990 × 0.005) = 7495`. **Jangan** pakai `43` sebagai ekspektasi test.

### 12.10 `booking_list_screen` (#38) — `GET bookings`

```json
{
  "success": true,
  "message": "OK",
  "data": [
    {
      "id": 1, "booking_code": "HTL-20260815-A1B2", "booking_type": "room",
      "status": "waiting_payment", "property_name": "Grand Cemara Hotel",
      "check_in": "2026-08-15", "check_out": "2026-08-16", "nights": 1,
      "rooms_count": 2, "total_price": "1089796.00"
    },
    {
      "id": 2, "booking_code": "BK-Q8R4T1YZ", "booking_type": "unit",
      "status": "confirmed", "property_name": "Apartemen Taman Anggrek 2BR",
      "check_in": "2026-09-01", "check_out": "2026-10-01",
      "duration_type": "monthly", "total_price": "7500000.00"
    }
  ],
  "meta": { "current_page": 1, "per_page": 20, "total": 2 }
}
```

> Kartu **harus** bercabang pada `booking_type`: `room` → tampilkan `rooms_count` + malam; `unit` → tampilkan `duration_type`. Lihat [§10.1](#101-diskriminator).

### 12.11 Peta form → payload (ringkas)

| Layar | Komponen | Field payload |
|---|---|---|
| 3, 15 | `RoomGuestStepperSheet` | `rooms_count`, `adults`, `children`, ⚠️`children_ages[]` |
| 4, 16 | `ChildAgePickerSheet` | elemen `children_ages[]` |
| 5, 6, 13, 14 | kalender | `check_in`, `check_out` |
| 9 | filter kebutuhan | `needs[]` (query) |
| 10 | urutkan | `sort` (query) |
| 1, 11 | filter lokasi | `city_id` / `q` (query) |
| 18, 34, 35 | pilih kamar | `room_type_id`, `guests[].room_name` |
| 27 | sheet pesan kamar | konfirmasi tanggal + `rooms_count` |
| 28, 30 | form pengisian kamar | `guests[]`, `contact_email`, `contact_phone` |
| 31 | diskon & benefit | `voucher_code`, `has_insurance`, `insurance_plan_id`, `holder_name`, `holder_identity` |
| 32 | konfirmasi | `receive_promos` |
| 36 | sheet kode promo | `voucher_code` |
| 37 | sheet permintaan | `special_requests` |
| 33 | info tambahan | — (read-only) |
| 34, 35 | sheet detail kamar | — (read-only; bentuk **masuk** di [§12.12](#1212-room_detail-3435--sumber-tiap-blok)) |

### 12.12 `room_detail` (#34/#35) — sumber tiap blok

**Tidak ada payload keluar** — sheet ini read-only, `Navigator.pop` tidak membawa apa pun ([A-21](#4-log-anomali-aset--dokumentasi)). Yang penting adalah bentuk **masuknya**: sheet tidak memanggil endpoint sendiri, ia diberi `List<HotelRoomItem>` + `HotelPolicy?` + satu String yang **semuanya** berasal dari respons `GET hotels/{hotel}` yang sudah dimuat layar induk. Potongan yang relevan dari respons itu:

```json
{
  "data": {
    "cancellation_policy": "Pembatalan gratis hingga 24 jam sebelum check-in.",
    "policies": {
      "child_policy": "Anak dari segala usia dapat menginap di kamar ini.",
      "extra_bed_policy": "Anda tidak dapat memesan tempat tidur tambahan dan ranjang bayi di tipe kamar ini"
    },
    "active_room_types": [
      {
        "id": 1,
        "name": "Kamar Superior",
        "description": "Kamar 21 m² dengan jendela menghadap taman.",
        "bed_configuration": "1 queen bed (lebar 1,6 m) atau 2 single bed (lebar 0,8 m)",
        "room_size_sqm": 21,
        "has_window": true,
        "no_smoking": true,
        "free_wifi": true,
        "capacity_adults": 2,
        "capacity_children": 1,
        "max_guests": 3,
        "breakfast_included": false,
        "base_price": "446637.00",
        "total_inventory": 4,
        "remaining": 4,
        "facilities": ["Kamar mandi pribadi", "AC", "TV LCD", "Pengering rambut", "Minibar", "Bathtub atau shower", "Meja kerja", "Teko listrik"],
        "images": [{ "url": "https://example.com/superior.jpg", "caption": "Kamar Superior" }]
      },
      { "id": 2, "name": "Family Suite", "bed_configuration": "2 queen bed (lebar 1,6 m)", "room_size_sqm": 30, "capacity_adults": 4, "capacity_children": 0, "max_guests": 4, "breakfast_included": true, "base_price": "650000.00", "total_inventory": 2 }
    ]
  }
}
```

**Empat hal yang membuat payload ini mudah salah dibaca:**

| Kunci | Jebakan | Aturan |
|---|---|---|
| `cancellation_policy` | Ada di **`properties`**, bukan `hotels` — jadi ia **rata** di `GET hotels/{hotel}` (di-flatten `show()`) tetapi **bersarang** di `property.cancellation_policy` pada payload lain. `nullable`. | Model membaca **kedua** bentuk lalu jatuh ke `''`; `''` **menyembunyikan** seksinya, tidak mencetak kalimat kosong. Ref [A-D16](#113-drift-kontrak-flutter--laravel), T-F66 |
| `bed_configuration` | Satu String yang bisa memuat **beberapa** pilihan. Pemisah yang benar-benar dipakai: **` atau `** (seeder, mis. `HotelSeeder.php:176`) dan **` / `** (komentar kolomnya). | `bedOptions` men-split keduanya, case-insensitive, butuh spasi di **kedua** sisi (`1 Katau Bed` bukan 2 opsi). ≥2 → tabel `Opsi 1`/`Opsi 2`; 1 → baris inline. T-F64 |
| `facilities` | jsonb "mirror" — panel admin boleh menulis `"AC"` **atau** `{"name":"AC"}`. | `_flattenStringList(raw, ['name'])`; elemen tanpa label (mis. `{"icon":"tv"}`) **dibuang**, bukan dicetak sebagai `Map`. T-F65 |
| `images` | Didokumentasikan `[{url, caption}]`, tapi sebagian data lama berisi String biasa. | `_flattenStringList(raw, ['url'])` menerima keduanya. 0 → placeholder, 1 → foto lebar penuh, >1 → strip 260×180. T-F65 |

`base_price` tetap `decimal:2` berbentuk **String** seperti di seluruh modul ini ([A-D11](#113-drift-kontrak-flutter--laravel)/T-F28) — sheet ini tidak mencetak harga, tapi `HotelRoomItem` yang sama dipakai kartu tipe kamar yang mencetaknya.

---

## 13. Referensi Struktur HTML

Cuplikan berikut adalah **kontrak visual**. Bila ragu soal layout, buka file HTML terkait di `docs/hotel/screen/_build/html/`, atau verifikasi langsung gambar di folder screen.

### 13.1 Bottom bar harga + tombol Pesan → `PricePrepaidBottomBar` (C-27)

Dipakai di #27–#32.

```html
<div style="display:flex;align-items:center;gap:12px;padding:10px 16px 16px;
            background:#fff;border-top:1px solid #EEEEEE">
  <div style="flex:1">
    <div style="font-size:11px;color:#757575">Prabayar Online (total harga)</div>
    <div style="font-size:20px;font-weight:800;color:#2962FF">
      Rp1.089.796 <span style="font-size:14px;color:#757575">ⓘ</span>
    </div>
  </div>
  <div style="width:100px">
    <div class="btn btn-primary" style="height:44px;font-size:15px">Pesan</div>
  </div>
</div>
```

**Flutter:** `Row` → `Expanded(Column(crossAxisAlignment: start))` + `SizedBox(width: 100, height: 44, child: FilledButton(...))`. Perhatikan tombol **44px**, bukan 48px.

### 13.2 Banner jaminan teal → `TealAssuranceBanner` (C-28)

```html
<div style="background:#e0f7fa;padding:10px 16px;display:flex;
            align-items:center;justify-content:center;gap:8px">
  <span style="font-size:20px">💜</span>
  <span style="font-size:13px;font-weight:600;color:#00796b">Kami Samakan Harga</span>
</div>
```

Varian teks: `Kami Samakan Harga` (#27, #32) · `Hati tenangkan berkat opsi pembatalan gratis.` (#31, warna `#14B8A6`).

### 13.3 Kartu ringkasan tanggal menginap → `StayDateSummaryCard` (C-21)

```html
<div style="border:1.5px solid #E0E0E0;border-radius:12px;padding:16px">
  <div style="display:flex;align-items:flex-start;justify-content:space-between;
              padding-bottom:14px;border-bottom:1px solid #EEEEEE">
    <div>
      <div style="font-size:11px;color:#757575">Check-in</div>
      <div style="font-size:18px;font-weight:800">Sab, 15 Agt</div>
      <div style="font-size:12px;color:#757575">Setelah pukul 14:00</div>
    </div>
    <div style="text-align:center;padding-top:12px">
      <div style="font-size:12px;color:#757575">1 malam</div>
      <div style="border-top:1px solid #E0E0E0;width:60px;margin:6px 0"></div>
    </div>
    <div style="text-align:right">
      <div style="font-size:11px;color:#757575">Check-out</div>
      <div style="font-size:18px;font-weight:800">Min, 16 Agt</div>
      <div style="font-size:12px;color:#757575">Sebelum pukul 12:00</div>
    </div>
  </div>
  <!-- blok per tipe kamar menyusul di sini -->
</div>
```

### 13.4 Baris atribut tipe kamar → `RoomTypeAttributeList` (C-22)

```html
<div style="padding:14px 0;border-bottom:1px solid #EEEEEE">
  <div style="font-size:16px;font-weight:700;margin-bottom:10px">
    Kamar Superior <span style="color:#757575;font-weight:400;font-size:14px">| 1 Kamar</span>
  </div>
  <div style="display:flex;align-items:flex-start;gap:10px;padding:5px 0;font-size:13px">
    <svg width="16" height="16"><!-- user --></svg> <span>Harga untuk 2 dewasa + 1 anak</span>
  </div>
  <div style="display:flex;align-items:flex-start;gap:10px;padding:5px 0;font-size:13px">
    <svg width="16" height="16"><!-- bed --></svg> <span>1 queen bed atau 2 single bed</span>
  </div>
  <div style="display:flex;align-items:flex-start;gap:10px;padding:5px 0;font-size:13px">
    <span style="font-size:18px">💜</span>
    <span><span style="color:#14B8A6;font-weight:600">Anak Menginap Gratis</span></span>
  </div>
</div>
```

**Flutter:** `Column` dari `Row(crossAxisAlignment: start, children:[Icon(size:16), SizedBox(width:10), Expanded(Text(13px))])`, tiap baris `Padding(vertical: 5)`.

### 13.5 Baris "Info tamu" → `SavedGuestPickerChip` (C-26)

```html
<div style="display:flex;align-items:center;justify-content:space-between;
            background:#F5F5F5;border-radius:8px;padding:12px 14px">
  <div style="display:flex;align-items:center;gap:8px;font-size:14px;font-weight:600">
    <svg width="18" height="18"><!-- id-card --></svg> Kamar 1
  </div>
  <div style="display:flex;align-items:center;gap:5px;font-size:13px;color:#757575">
    <svg width="15" height="15"><!-- user --></svg> Pilih tamu yang tersimpan
  </div>
</div>
```

### 13.6 Opsi radio → `RadioOptionTile` (C-12)

Terpilih:

```html
<div style="display:flex;align-items:center;gap:12px;padding:14px 0;border-bottom:1px solid #EEEEEE">
  <div style="width:20px;height:20px;border-radius:50%;border:2px solid #2962FF;
              display:flex;align-items:center;justify-content:center;background:#2962FF;flex:0 0 auto">
    <svg width="12" height="12" fill="#fff"><!-- check --></svg>
  </div>
  <span style="font-size:15px;font-weight:700;color:#2962FF">Rekomendasi</span>
</div>
```

Tidak terpilih: `border:2px solid #E0E0E0`, `background:transparent`, isi kosong, teks `15px/400 #1A1A2E`.

### 13.7 Shell bottom sheet → `AppBottomSheetShell` (C-10)

```html
<!-- scrim -->
<div style="position:absolute;inset:0;background:rgba(0,0,0,.3);z-index:29"></div>
<!-- sheet -->
<div style="position:absolute;bottom:0;left:0;right:0;background:#fff;
            border-radius:20px 20px 0 0;max-height:70%;
            display:flex;flex-direction:column;z-index:30">
  <div style="width:36px;height:4px;background:#E0E0E0;border-radius:2px;margin:10px auto;flex:0 0 auto"></div>
  <div style="display:flex;align-items:center;justify-content:space-between;
              padding:12px 20px;border-bottom:1px solid #EEEEEE;flex:0 0 auto">
    <span style="font-size:17px;font-weight:700">Urutkan</span>
    <svg width="22" height="22"><!-- close --></svg>
  </div>
  <div style="padding:20px;overflow:auto;flex:1"><!-- konten --></div>
</div>
```

**Flutter:** `showModalBottomSheet(isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: vertical(top: 20)), constraints: BoxConstraints(maxHeight: h * 0.7))`.

### 13.8 Field outlined: kosong vs terisi → `OutlinedTextField` (C-24)

```html
<!-- KOSONG -->
<div style="border:1.5px solid #E0E0E0;border-radius:8px;padding:14px 16px">
  <span style="font-size:14px;color:#757575">Nama depan*</span>
</div>

<!-- TERISI + valid -->
<div style="border:1.5px solid #2962FF;border-radius:8px;padding:10px 16px;
            display:flex;align-items:center;justify-content:space-between">
  <div>
    <div style="font-size:11px;color:#2962FF;font-weight:600">Email*</div>
    <div style="font-size:14px">mohbaswandegorie@gmail.com</div>
  </div>
  <svg width="18" height="18" stroke="#4caf50"><!-- check --></svg>
</div>
```

**Flutter:** `InputDecoration(border: OutlineInputBorder(borderRadius: 8), focusedBorder: … primary, floatingLabelBehavior: auto, suffixIcon: valid ? Icon(Icons.check, color: success) : null)`.

### 13.9 Kartu hasil hotel → `HotelResultCard` (C-04)

Struktur: `Row` → `[gambar 130×165 + FavoriteToggle (Stack)]` `[Expanded(Column: nama+bintang / skor / jarak / tag / sosial / harga rata-kanan)]`, padding info `12px 12px 12px 14px`, pemisah kartu `Container(height: 8, color: #F5F5F5)`.

Semua yang berikut **nullable** (dibuktikan kartu Amaris pada #7): harga coret, label skor teks, chip diskon, daftar tag.

---

## 14. Peta Implementasi Flutter

### 14.1 Yang sudah ada

```
flutter/lib/screens/property/
├── search_results_screen.dart
├── property_detail_screen.dart
└── hotel/
    ├── hotel_search_screen.dart      → layar #2 (+#1,#3–#6 via sheet)
    ├── hotel_results_screen.dart     → layar #7 (+#8–#16)
    ├── hotel_detail_screen.dart      → layar #17–#25 (8 tab)
    └── hotel_booking_screen.dart     → layar #26–#32 (~450 baris)
```

**Semua route sudah terdaftar** di `flutter/lib/router.dart` (konstanta `AppRoutes.*`) — ini membantah klaim basi di `docs/flutter/screens.md` baris 224 ([A-11](#4-log-anomali-aset--dokumentasi)).

### 14.2 Yang belum ada di `hotel_booking_screen.dart`

> Daftar ini adalah **kondisi awal audit**; kolom *Status* dimutakhirkan tiap item Fase 2 ditutup.

| Kekurangan | Layar | Status |
|---|---|---|
| Sheet kode promo | #36 | ✅ [F-5](#152-flutter) — `promo_code_sheet.dart` (C-34 + C-35 + C-33) |
| Sheet permintaan khusus | #37 | ✅ [F-4](#152-flutter) — `special_request_sheet.dart` (C-31 + C-30) |
| Sheet informasi tambahan | #33 | ✅ [F-6](#152-flutter) — `additional_info_sheet.dart` (C-32) |
| Sheet detail kamar (Family Suite / Kamar Superior) | #34, #35 | ✅ [F-7](#152-flutter) — `room_detail_sheet.dart` (C-39); **satu** sheet dua pil, bukan dua layar ([§6 #34 & 35](#34--35-room_detail_family_suite--room_detail_kamar_superior--detail-kamar)) |
| Ringkasan kamar masih hardcode via `_roomSummary(...)` | #27 | ✅ [F-8](#152-flutter) — rantai `HotelDetailArgs` → `HotelBookingArgs` |
| Seksi Trip Coins expandable | #29, #31, #32 | ⏳ [F-10](#152-flutter) |

### 14.3 Aturan arsitektur (jangan dilanggar)

1. **State:** `Provider` — bukan Riverpod, bukan Bloc.
2. **HTTP:** paket `http` via `ApiClient` — bukan Dio.
3. **Dummy mode:** setiap endpoint baru **wajib** ditambahkan ke `api_client.dart` **dan** `dummy_api_client.dart`. Aktivasi: `--dart-define=DUMMY_API=true`.
4. **Service:** 1 file per domain di `lib/services/`. Layar hotel → `HotelService`.
5. **Route:** semua di `lib/router.dart` lewat `AppRoutes.*`. Jangan hardcode string route.
6. **Deep link:** skema `sewain://`. Hasil pembayaran → `sewain://payment-result`; pencarian hotel → `sewain://search?check_in=…`.
7. **Branding:** aplikasi bernama **Sewain**. `appName` di `flutter/lib/config/app_config.dart` masih `LIVI.COM` — drift yang diketahui.

---

## 15. Checklist Fase 2

> Fase 2 baru boleh dimulai setelah [§16](#16-daftar-sinkronisasi-dokumen-lanjutan) selesai.
>
> **Status per 16 Agt 2026:** seluruh item Laravel sudah dikerjakan (termasuk **L-9** yang lahir di tengah Fase 2 dan **L-8** yang menutup file diagnostik `ProbeTest.php`), ditambah Flutter **F-1, F-2, F-3, F-4, F-5, F-6, F-7, F-8, F-11, F-13** (semua item 🔴, plus F-4, F-5, F-6 & F-7 🟠). Yang tersisa murni **komponen UI yang belum dibangun**: F-9, F-10, F-12. Kolom *Status* di bawah adalah catatan hasil verifikasi ulang terhadap kode, bukan rencana — dan **bukan** hasil eksekusi test (lihat baris terakhir [§17](#17-riwayat-audit)).

### 15.1 Laravel

| ID | Item | Prioritas | Status |
|---|---|---|---|
| **L-1** | 🔴 Perbaiki cabang `guests[]` di `storeHotelBooking()` agar **mengunci & mengurangi** `room_inventories` (samakan dengan cabang B2), termasuk penolakan `is_closed` / allotment kurang. | Tinggi | ✅ **selesai** — kedua cabang kini memanggil helper bersama `BookingController::holdRoomInventory()` (`lockForUpdate` → cek `is_closed` → cek `allotment - booked_count` → `increment`). Hardcode `446637`, `room_type_id => 1`, dan `500000` hilang. Harga per malam dibaca dari kalender; nama kamar yang tak dikenal → 422 (bukan fallback ke room type hotel lain). |
| **L-2** | 🔴 Putuskan `GET hotel/filters`: buat route+controller **atau** hapus dari Flutter & dummy client ([A-D4](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — dihapus. Tidak ada pemanggil di `lib/`; route dummy + fixture `GET_hotel_filters.json` dibuang. Lihat [A-14](#4-log-anomali-aset--dokumentasi). |
| **L-3** | 🔴 Jangan buat `POST hotel/bookings`; arahkan Flutter ke `POST bookings` ([A-D5](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — `HotelService.createHotelBooking()` POST ke `bookings`; route dummy + `POST_hotel_bookings.json` dibuang; `BookingController` menerima `hotel_id` **atau** `property_id` lewat `required_without` (dulu 404 dari `findOrFail(null)`, sekarang 422 yang menyebut field). |
| **L-4** | 🟠 Selaraskan `contact_phone`: validasi max:25 vs lebar kolom ([A-D10](#113-drift-kontrak-flutter--laravel)). | Sedang | ✅ **selesai** — validasi diturunkan ke `max:20`, sama dengan lebar kolom `bookings.contact_phone`, plus komentar peringatan di aturan validasi. |
| **L-5** | 🟠 Putuskan `children_ages[]`: tambah validasi+kolom, atau buang ([A-D2](#113-drift-kontrak-flutter--laravel)). | Sedang | ✅ **selesai** — dipertahankan: migration kolom `jsonb` + cast array + validasi `array max:10` / `integer 0..17`, dan disimpan sebagai `null` bila kosong (array kosong akan terbaca "0 anak dengan umur tak diketahui"). |
| **L-6** | 🔴 `sort` sudah terverifikasi ([A-D9](#113-drift-kontrak-flutter--laravel)) — yang tersisa adalah **memutuskan "Jarak terdekat"**. | Sedang | ✅ **selesai** — diimplementasikan, bukan disembunyikan. `HotelApiController::orderByDistance()` mengurutkan dari origin `lat`/`lng` (aproksimasi planar, hanya `+ - *`, agar hasilnya sama di PostgreSQL & SQLite); hotel tanpa koordinat selalu terakhir; `distance` tanpa origin turun ke relevansi (**bukan** `star_rating` seperti dulu). Flutter mengirim `sort=distance` apa adanya + `lat`/`lng`, dan re-sort sisi klien dibuang. `03-query-filters.md` §1.1 diperbarui. |
| **L-7** | 🟡 Verifikasi `GET hotels/{hotel}` sudah menyertakan `room_types`; tandai `…/room-types` sebagai cadangan bila ya. | Rendah | ✅ **selesai — tidak ada drift.** `show()` memuat `activeRoomTypes` dan mengeluarkan key `active_room_types`; `Hotel.fromJson` menerima `active_room_types` **maupun** `room_types`. `GET hotels/{hotel}/room-types` resmi berstatus cadangan — tidak dipanggil Flutter (`getRoomTypes()` mendelegasi ke `getHotelDetail()`), jadi **tidak** didaftarkan di `DummyApiClient`. |
| **L-8** | 🟡 Hapus `tests/Feature/Admin/ProbeTest.php` (diagnostik sementara, sudah ditandai untuk dihapus di `laravel/CLAUDE.md`). | Rendah | ✅ **selesai** — file dihapus (`rm tests/Feature/Admin/ProbeTest.php`). Sebelum dihapus, kedua pertanyaan yang di-probe file itu (`[A] mount as host`, `[B] host memanggil saveMidtrans`) diverifikasi sudah punya **assertion nyata** di `tests/Feature/Admin/PaymentSettingsAccessTest.php` — `test_host_cannot_mount_the_settings_component`, `test_host_cannot_save_midtrans_credentials` (yang benar-benar `->call('saveMidtrans')`), dan `test_admin_can_save_midtrans_credentials` — jadi penghapusannya tidak mengurangi cakupan apa pun; yang hilang hanya `fwrite(STDERR, …)` yang berakhir dengan `assertTrue(true)`. |
| **L-9** | 🟠 Satukan sumber harga hotel: `PropertyResource` mendelegasikan ke accessor `Hotel` alih-alih menghitung `min('base_price')` sendiri ([A-D13](#113-drift-kontrak-flutter--laravel)). | Sedang | ✅ **selesai** — 3 file. (1) [`PropertyResource.php`](../../../laravel/app/Http/Resources/PropertyResource.php): cabang hotel dijadikan satu flag `$hotelLoaded` (`booking_mode === 'room'` + `hotel` + `roomTypes` ter-load) → `price_from`/`price_original` dari accessor; key **baru** `price_original`; fallback `property_prices` dikunci ke non-`room`; `has_breakfast` memfilter `is_active` dan ikut memakai `$hotelLoaded`. (2) [`PropertyController::hostIndex()`](../../../laravel/app/Http/Controllers/Api/PropertyController.php): `with('hotel')` → `with('hotel.roomTypes')`, syarat agar accessor bekerja tanpa lazy-load di daftar properti Mitra. (3) [`HotelApiTest.php`](../../../laravel/tests/Feature/Api/HotelApiTest.php): +5 test (T-L33…T-L37) + helper `propertyPayload()` yang mencari properti **berdasarkan `id`**, bukan `data.0` — dua test di antaranya menambah properti ke fixture sehingga urutan tak bisa dipercaya. **Tidak** menyentuh `PropertyController::index()`: eager-load `hotel.roomTypes` di sana sudah ada sejak semula, itulah sebabnya perbaikan ini nol query tambahan. |

### 15.2 Flutter

| ID | Item | Prioritas | Status |
|---|---|---|---|
| **F-1** | 🔴 Alihkan `HotelSearchProvider` ke `HotelService.searchHotels()` / `GET hotels`, ubah state ke `Paginated<Hotel>` ([A-D6](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — dan ternyata bukan sekadar rapi-rapi: `PropertyService.searchHotels()` mengirim `sort=score_desc` ke `GET properties` yang aturannya `in:newest,price_asc,price_desc,rating`, jadi **setiap** pencarian lewat provider dijawab 422. Metode itu dihapus; provider kini punya `loadMore()` ber-token anti-balapan. |
| **F-2** | 🔴 Perbaiki null-assertion `city_id` di `HotelSearchQuery.fromUri` ([A-D7](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — `int.tryParse(q['city_id'] ?? '')`. Sekalian ditemukan asimetri serializer↔parser: `toQueryParams()` memancarkan `star_rating[0]` tapi `fromUri` hanya membaca CSV, jadi URI buatan kelas ini sendiri kehilangan filter bintang saat dibaca ulang. `_parseStarRatings()` sekarang menerima kedua bentuk. `originLat`/`originLng` ikut di-round-trip. |
| **F-3** | 🔴 Kirim `booking_type: "room"` eksplisit dari layar hotel. | Tinggi | ✅ **selesai** — `booking_type: 'room'` + `duration_type: 'daily'` dikirim eksplisit, tidak lagi menggantungkan diri pada inferensi server. |
| **F-4** | 🟠 Bangun C-31 `SpecialRequestSheet` (#37) + serialisasi ke `special_requests`. | Sedang | ✅ **selesai** — resolusi [A-D1](#113-drift-kontrak-flutter--laravel) opsi (a) **dieksekusi di kode**: sheet tetap per-tipe-kamar, API tetap satu string. Tiga file: `models/special_request.dart` (katalog 8 nilai + `SpecialRequestDraft` immutable), `screens/property/hotel/special_request_sheet.dart` (C-31 + `showSpecialRequestSheet()` + C-30 `SpecialRequestSection`), dan 5 sunting di `hotel_booking_screen.dart` (map draft ber-key `room_types.id` → `SpecialRequestDraft.serializeAll()` masuk body `POST bookings`). Yang tidak terduga: **plafon 500 char itu milik seluruh booking**, bukan per kamar, jadi counter `0/200` mockup akan berbohong begitu ada 2 tipe kamar. `noteBudget()` menghitung sisa anggaran nyata (blok kamar lain yang sudah terserialisasi + label yang dicentang kamar ini) dan menyuapinya ke `maxLength` — counter membaca `0/111` apa adanya, bukan menabrak 422 setelah tombol "Pesan". Pada anggaran **0** field **diganti** panel penjelas, bukan di-disable: `TextField(maxLength: 0)` dan `LengthLimitingTextInputFormatter(0)` dua-duanya `assert maxLength > 0`, jadi meneruskan anggaran mentah akan meng-*crash* sheet justru saat booking paling penuh. Radio bisa di-**toggle off** (mockup tak punya baris "tidak ada preferensi"). Dipatok T-F3 + T-F36…T-F44. |
| **F-5** | 🟠 Bangun C-34 `PromoCodeSheet` (#36) + batasi 1 voucher/booking ([A-D3](#113-drift-kontrak-flutter--laravel)). | Sedang | ✅ **selesai** — rekomendasi [A-D3](#113-drift-kontrak-flutter--laravel) ("batasi UI") dijalankan apa adanya: **satu** voucher per booking, jadi C-33 adalah satu baris untuk seluruh booking, bukan satu baris per tipe kamar seperti #31. **Tidak ada perubahan Laravel** — `voucher_code`, `resolveDiscount()`, dan cabang cashback sudah tertutup [L-1](#151-laravel) dan dipatok T-L18, jadi kewajiban "test Laravel + test Flutter" untuk item ini dipenuhi oleh T-L18 + T-F45…T-F58. Enam file: `models/promo_voucher.dart` (**baru** — `PromoCandidate` + `PromoSelection`), `utils/promo_labels.dart` (**baru** — satu sumber kata-kata, dipakai sheet hotel **dan** `screens/payment/promo_code_screen.dart` yang sudah ada; pelajaran [A-D13](#113-drift-kontrak-flutter--laravel) diterapkan sebagai kode, bukan komentar), `screens/property/hotel/promo_code_sheet.dart` (**baru** — C-34 + C-35 + `showPromoCodeSheet()` + C-33 `PromoCodeSection`), plus `models/voucher.dart` (+`starts_at`/`ends_at`), `services/voucher_service.dart` (+`check()`/`VoucherCheck`), `utils/formatters.dart` (+`dayMonthYearDotTime`, pemisah **titik** milik mockup) dan 3 sunting di `hotel_booking_screen.dart`. **Empat hal yang hanya terlihat setelah controller-nya dibaca, bukan dari dokumen:** (1) [A-D14](#113-drift-kontrak-flutter--laravel) — `GET vouchers` tak mengirim `is_eligible`/`ineligible_reason`/`subtitle`, jadi kartu dimmed #36 **tidak punya sumber data**; kelayakan hanya bisa didapat dari `POST vouchers/apply`, sehingga kartu mulai bisa ditawarkan lalu di-dim oleh penolakan nyata dan header `(N Tersedia)` menyusut bersamanya. (2) **Cashback berhasil tanpa mengurangi apa pun** (`[0.0, $voucher, null]`), jadi `check()` tidak boleh membaca nol sebagai penolakan dan baris promo menulis "Cashback Rp 25.000 setelah menginap", bukan `- Rp 0`. (3) **Bug yang justru akan dibuat F-5 kalau tidak diperiksa:** `_estimatedTripCoins` dihitung dari `_roomSubtotal`, sedangkan server menghitung `round($total * 0.005)` **setelah** diskon — koin dialihkan ke `_dueTotal`, dan T-F58 menuntut kalimat koin pra-diskon **hilang** dari tree. (4) Sheet menerima subtotal **sebelum** diskon, karena `resolveDiscount()` mengalikan persentase dengan apa pun yang ia terima; kode yang diketik di-`toUpperCase()` sebelum dikirim (`textCapitalization` hanya petunjuk keyboard, bukan transformasi — kode seeder semuanya huruf besar). Mengikuti pelajaran [F-4](#152-flutter)/[F-13](#152-flutter), sheet **dan** section dibuat publik dan `VoucherService` bisa disuntikkan lewat konstruktor `HotelBookingScreen`. [A-D15](#113-drift-kontrak-flutter--laravel) ditemukan di sini dan **sengaja tidak ditambal**. Dipatok T-F45…T-F58. |
| **F-6** | 🟠 Bangun C-32 `AdditionalInfoSheet` (#33). | Sedang | ✅ **selesai** — dan yang membuatnya bukan pekerjaan kosmetik: #33 mockup isinya **satu** seksi (`Kebijakan Deposit` — "Deposit tunai sebesar Total Rp100.000 diperlukan saat check-in"), dan angka itu ternyata **data nyata yang selama ini dibuang Flutter**. `hotels.deposit_amount` ada utuh di server — migration `2026_08_15_000001_add_hotel_ota_columns.php:34` (`decimal('deposit_amount', 12, 2)->default(0)`, komentar "Deposit tunai wajib saat check-in (Rp)"), `Hotel.php` fillable + cast `decimal:2`, bahkan dipatok `HotelApiTest.php:319` (`data.deposit_amount == '100000.00'`, persis Rp100.000 milik mockup) — tetapi `Hotel.fromJson` di Flutter tidak pernah membaca key-nya, jadi #33 tak punya apa pun untuk ditampilkan. Drift baru, ditemukan di sini. Karena `decimal:2` tiba sebagai **String**, field baru `depositAmount` dilewatkan `_toDouble()` yang sudah ada — perangkap yang sama dengan [A-D11](#113-drift-kontrak-flutter--laravel)/T-F28, dan alasan `depositAmount` tidak boleh dibaca `as num?`. Dua file: `models/hotel.dart` (+1 field, +1 baris parse) dan `screens/property/hotel/additional_info_sheet.dart` (**baru** — C-32 + `showAdditionalInfoSheet()` + `AdditionalInfoSection` untuk baris pemicu di #31/#32), plus 3 sunting di `hotel_booking_screen.dart`. **Tiga keputusan yang perlu dicatat:** (1) isi sheet **diturunkan** dari `Hotel` oleh fungsi murni `additionalInfoEntries()`, dan baris `Informasi Tambahan (N)` menghitung `N` dari daftar yang **sama** — pelajaran [A-D13](#113-drift-kontrak-flutter--laravel) lagi: angka yang dipelihara terpisah bebas berbeda dari isi yang terbuka. Seksi kosong **dibuang**, bukan dirender kosong, supaya `(N)` jujur: deposit `0` (nilai default kolom, dan mayoritas hotel) tidak memunculkan baris "Deposit tunai sebesar Rp 0". (2) Kata **"Total"** pada kalimat mockup dijatuhkan dengan sengaja — deposit bukan total dan sisipan itu membuat kalimatnya tak gramatikal; dicatat sebagai komentar di kode supaya tidak "diperbaiki" balik ke PNG. (3) Blok yang digantikan bukan placeholder kosong: `hotel_booking_screen.dart` **mencetak `childPolicy` + `extraBedPolicy` mentah** ke dalam kartu Trip Coins dengan judul tebal `Informasi Tambahan` — padahal #31/#32 menaruhnya di balik tautan `Pelajari Selengkapnya`. Kedua teks itu dilipat menjadi seksi `Kebijakan Anak` + `Ranjang Tambahan` di dalam sheet, jadi tak ada informasi yang hilang; konsekuensinya `(1)` milik mockup adalah kasus "deposit tanpa objek policy", dan payload lengkap membaca `(3)` — bukan ketidaksesuaian, melainkan mockup yang di-capture dari hotel tanpa policy. Dipatok T-F59…T-F63. |
| **F-7** | 🟠 Bangun sheet detail kamar #34/#35. | Sedang | ✅ **selesai** — dan temuan terbesarnya struktural, bukan visual: **#34 dan #35 bukan dua layar, melainkan satu sheet dengan dua pil tipe kamar.** Buktinya bukan tafsiran — 8 JPEG-nya tersimpan di **satu** folder `bottom_screen_kamar_superior/` dengan dua anak `tab_family_suite/` + `tab_kamar_superior/`, dan `room_detail_kamar_superior.html:44-47` memang memuat baris pil berisi **kedua** nama kamar ([§6](#34--35-room_detail_family_suite--room_detail_kamar_superior--detail-kamar)). Membangunnya sebagai dua widget akan menggandakan galeri, fasilitas, dan kebijakan — lalu memaksa keduanya sinkron manual, kesalahan yang sama dengan [A-D13](#113-drift-kontrak-flutter--laravel). Empat file: `screens/property/hotel/room_detail_sheet.dart` (**baru** — C-39 + `showRoomDetailSheet()` + fungsi murni `distinctRoomTypes()`), `models/hotel.dart` (+`cancellationPolicy`, +`description`/`facilities` pada `HotelRoomItem`, +getter `bedOptions`/`capacityLabel`, parse `images` bentuk objek), `HotelApiController::show()` (+`cancellation_policy` di `select` properti dan diratakan ke akar), dan 2 sunting di `hotel_booking_screen.dart` (pemicu dari kartu kamar #27 **dan** dari baris `Detail kamar` #31). **Empat hal yang hanya muncul setelah asetnya dibuka satu-satu:** (1) **[A-D16](#113-drift-kontrak-flutter--laravel)** — empat kolom sudah ada tapi tak pernah sampai ke layar, dan letak bugnya berbeda sisi: `properties.cancellation_policy` (kolom + fillable + di-seed 5 hotel) tak pernah dipilih `show()` → bug **server**; `description`/`facilities` tak pernah di-parse dan `images` di-map dengan `'$e'` sehingga mencetak literal `{url: …, caption: …}` → bug **klien**. Perbaikan diletakkan di sisi yang benar masing-masing, bukan ditambal di UI. (2) **Timeline refund sengaja tidak dibuat.** Mockup menampilkan tanggal ("gratis hingga 24 jam sebelum check-in" → tanggal konkret), tapi `cancellation_policy` adalah `string(255)` teks bebas — tak ada `cancellation_deadline_hours` untuk dihitung, dan mencetak tanggal tebakan di layar kebijakan refund adalah jenis kesalahan yang berakhir di sengketa pembayaran. Teks dicetak apa adanya. (3) **Tabel biaya sarapan (`Anak 5-17 th` Rp65.000 / `Dewasa` Buffet Rp108.900), gaya + jam sarapan, dan kurung "(Usia 0-5 tahun)"** dibuang dengan alasan yang sama — tak ada `room_types.breakfast_fees`, `hotels.breakfast_style`, maupun `breakfast_hours`; migration yang dibutuhkan dinamai di [§6](#34--35-room_detail_family_suite--room_detail_kamar_superior--detail-kamar) supaya tidak "diperbaiki" jadi hardcode. Yang **dipertahankan** sebagai konstanta hanya `Konfirmasi Langsung` + `Prabayar Online`, karena keduanya memang perilaku sistem: `storeHotelBooking()` memesan sekaligus mengurangi allotment dalam satu transaksi, dan setiap booking hotel dibayar di muka lewat Midtrans. (4) Sheet **tanpa CTA bawah** ([A-21](#4-log-anomali-aset--dokumentasi)): HTML-nya berakhir tanpa `.btn` dan langkah scroll ke-4 kedua tab juga tidak punya tombol — menambahkannya akan melahirkan tombol pesan kedua yang bersaing dengan `Pesan kamar ini` (#27) dan bilah bawah #31. Mengikuti pelajaran [F-4](#152-flutter)/[F-13](#152-flutter), sheet + `distinctRoomTypes()` dibuat publik dan tiap `_ExpandableSection` diberi `key: ValueKey(title)` agar bisa dipompa berulang tanpa elemen lama dipakai ulang. Dipatok T-F64…T-F71 + T-L38/T-L39. |
| **F-8** | 🟠 Ganti `_roomSummary(...)` hardcode dengan data asli `room_types`. | Sedang | ✅ **selesai** — dan ternyata akarnya struktural, bukan kosmetik: layar booking tak bisa diperbaiki sendirian karena query pencarian **juga** tidak pernah masuk ke layar detail. Dibuat rantai `HotelDetailArgs` → `HotelBookingArgs` (+ `HotelRoomSelection`) dengan `HotelSearchQuery.defaultStay()` sebagai satu-satunya fallback. Sekalian ditemukan 3 bug lain: (a) kartu hotel di hasil pencarian membuka `Routes.propertyDetail` sehingga **seluruh layar detail hotel tak terjangkau dari mana pun** ([A-15](#4-log-anomali-aset--dokumentasi)); (b) `HotelRoomItem.fromJson` membaca `base_price` dengan `as num?` padahal cast `decimal:2` mengirim **string**, jadi tiap tipe kamar berbentuk-DB dihargai **Rp 0** ([A-16](#4-log-anomali-aset--dokumentasi)); (c) pil tanggal di hasil pencarian memakai `substring(5)` → tampil `08-28`, bukan `28 Agt` ([A-17](#4-log-anomali-aset--dokumentasi)). |
| **F-9** | 🟠 Bangun C-11 `AppTopModalShell` manual (#12–#16) — paket tidak ada ([A-08](#4-log-anomali-aset--dokumentasi)). | Sedang | ⏳ belum |
| **F-10** | 🟡 Bangun C-29 `TripCoinsSection` expandable. | Rendah | ⏳ belum |
| **F-11** | 🟡 Ganti "Trip.com" → "Sewain" pada teks S&K ([A-10](#4-log-anomali-aset--dokumentasi)). | Rendah | ✅ **selesai** — teks persetujuan promo kini "promo spesial **Sewain**". `Trip Coins` **sengaja dipertahankan**: itu nama kolom ledger `bookings.trip_coins_earned`, bukan merek pihak ketiga ([A-10](#4-log-anomali-aset--dokumentasi)). |
| **F-12** | 🟡 Bedakan kartu `booking_type` room vs unit di #38. | Rendah | ⏳ belum |
| **F-13** | 🔴 Kartu hasil pencarian menampilkan `Rp 0` di API nyata — `GET hotels` tak memancarkan `price_per_night`/`total_price`/`price_original` ([A-D11](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — item **baru**, lahir saat [F-8](#152-flutter), dan perbaikannya memang **di Laravel**. Tiga bagian: (1) `Hotel::cheapestActiveRoomType()` + accessor `price_from`/`price_original` yang membaca relasi room-type **yang sudah ter-eager-load** (`activeRoomTypes`, lalu `roomTypes`, baru query sebagai jalan terakhir) — accessor lama menyelidiki relasi yang salah dan tak pernah dipakai; (2) `HotelApiController::attachCardPricing()` meng-`append()` keduanya atas koleksi paginasi + men-`setAttribute('total_price')` = `price_from × malam × kamar`, **hanya** bila query membawa `check_in`/`check_out` (tanpa tanggal → `null`, supaya kartu menyembunyikan barisnya alih-alih mencetak `Total harga: Rp 0`); `show()` memancarkan dua key harga tanpa `total_price` karena endpoint itu tak punya tanggal untuk ditotal; (3) Flutter: `_toDouble` dinaikkan jadi fungsi tingkat-file di `hotel.dart` dan dipakai ketiga field uang, lalu kolom harga kartu diekstrak jadi widget publik `HotelCardPrice` — merender lewat `Formatters.rupiah`, menulis **"Harga belum tersedia"** alih-alih `Rp 0`, dan tidak memasang harga-coret bila tak ada tarif pembanding. 4 interpolasi `'Rp ${…toStringAsFixed(0)}'` mentah di kartu hilang. **Tiga keputusan yang sengaja tidak diambil**: `withMin()` kedua (dihapus `->select('hotels.*')` milik `orderByDistance()`), `$appends` (cabang query accessor akan menyala per baris di mana pun `Hotel` polos diserialisasi), dan `setAttribute('price_from', …)` (ditimpa get-mutator). Efek samping: [A-18](#4-log-anomali-aset--dokumentasi) (test bintang yang tak mungkin hijau) ditutup, [A-D12](#113-drift-kontrak-flutter--laravel) dibuka. |

### 15.3 Test — **wajib** (permintaan eksplisit pengguna)

**Laravel — sudah ada sebelum Fase 2 (7 file):**
`tests/Feature/Api/HotelApiTest.php` · `HotelBookingTest.php` · `HostHotelTest.php` · `tests/Feature/Jobs/ExtendHotelInventoriesJobTest.php` · `CancelExpiredBookingsJobTest.php` · `tests/Unit/Model/RoomTypeObserverTest.php` · `tests/Feature/Livewire/HotelWizardFormTest.php`

> `HotelApiTest.php` **ikut diperluas di Fase 2**: 12 → **27 test** dalam tiga gelombang — +8 untuk [F-13](#152-flutter) (T-L27…T-L32), +5 untuk [L-9](#151-laravel) (T-L33…T-L37), +2 untuk [F-7](#152-flutter) (T-L38/T-L39) — dan satu test lamanya diperbaiki karena tidak mungkin hijau ([A-18](#4-log-anomali-aset--dokumentasi)). Enam file lainnya tidak disentuh. **Total test hotel Laravel di Fase 2: 49 (3 file baru) + 15 (di `HotelApiTest.php`) = 64.**

**Laravel — ditambahkan di Fase 2 (3 file, 49 test):**

| File | Test | Cakupan | Item |
|---|---|---|---|
| [`HotelBookingInventoryTest.php`](../../../laravel/tests/Feature/Api/HotelBookingInventoryTest.php) | 13 | hold allotment: cabang `guests[]` **dan** cabang `room_type_id` | T-L1…T-L8 |
| [`HotelSearchSortTest.php`](../../../laravel/tests/Feature/Api/HotelSearchSortTest.php) | 15 | urutan & ketersediaan `GET hotels` | T-L9…T-L14 |
| [`HotelBookingContractTest.php`](../../../laravel/tests/Feature/Api/HotelBookingContractTest.php) | 21 | pemisahan unit↔room, urutan uang, batas validasi | T-L15…T-L25 |

| ID | Test | Menguji | Status |
|---|---|---|---|
| T-L1 | `guests[]` mengurangi `booked_count` tiap malam; hari check-out **tidak** dipotong | perbaikan L-1 | ✅ `test_guests_branch_increments_booked_count_on_every_night` |
| T-L2 | allotment adalah plafon keras — 422 sebelum baris apa pun ditulis | perbaikan L-1 | ✅ `…rejects_a_booking_past_the_allotment`, `…second_booking_cannot_oversell…` |
| T-L3 | satu malam `is_closed` membatalkan seluruh menginap, termasuk rollback malam pertama | perbaikan L-1 | ✅ `test_a_closed_night_blocks_the_whole_stay` |
| T-L4 | harga dibaca dari kalender per malam, bukan `base_price` dan bukan `446637` | perbaikan L-1 | ✅ `…nightly_calendar_price_wins…`, `…mixed_room_types_are_priced_and_held_separately` |
| T-L5 | nama kamar tak dikenal → 422 (dulu jatuh ke `room_type_id => 1`) | perbaikan L-1 | ✅ `…unknown_room_name_is_refused_by_name` + 2 test tetangga |
| T-L6 | cabang `room_type_id` memberi jaminan **identik** dengan cabang `guests[]` | perbaikan L-1 | ✅ `test_the_single_room_branch_holds_inventory_the_same_way` (+ closed night) |
| T-L7 | menginap di luar kalender 30 hari → harga `base_price`, tanpa hold | observer | ✅ `…stay_past_the_calendar_falls_back_to_base_price_without_holding` |
| T-L8 | `booking_type` tersimpan `room` di **semua** jalur hotel | diskriminator, [§10.2](#102-cara-laravel-memutuskan-mode) | ✅ `test_booking_type_is_persisted_as_room_for_every_hotel_path` |
| T-L9 | `sort=distance` benar-benar mengukur dari origin; tanpa koordinat selalu terakhir; origin berbeda → urutan berbeda | perbaikan L-6 | ✅ 3 test — fixture sengaja menaruh hotel terdekat pada bintang **terendah**, jadi peringkat bintang tak bisa lolos sebagai jarak |
| T-L10 | `distance` tanpa `lat`/`lng` turun ke **relevansi**, bukan `star_rating` | perbaikan L-6 | ✅ `…degrades_to_relevance_not_stars` — membandingkan 3 panggilan API hidup, bukan urutan hardcode |
| T-L11 | koordinat hanya sah sebagai pasangan; di luar rentang → 422; `sort` tak dikenal → 422 (bukan diabaikan) | validasi | ✅ 4 test |
| T-L12 | `star_rating` multi-select; hotel tanpa room type aktif tak terlihat; `flex_days > 3` → 422 | [§12.2](#122-query-pencarian--layar-16-716) | ✅ 3 test |
| T-L13 | ketersediaan dibaca dari kalender harian: malam tertutup & permintaan kamar > sisa → hotel hilang | [§11.2](#112-bentuk-respons) | ✅ 2 test |
| T-L14 | **hold dan search sepakat** — booking yang menghabiskan allotment menghapus hotel dari hasil, hotel lain tak terpengaruh; `meta` paginasi ada | integrasi L-1 ↔ L-6 | ✅ 2 test |
| T-L15 | `booking_code` `HTL-` + `waiting_payment` + `host_confirmed` vs `BK-` + `waiting_confirmation`; inferensi mode dari `booking_mode` maupun `guests[]` | [§10.1](#101-diskriminator), [§10.2](#102-cara-laravel-memutuskan-mode) | ✅ 3 test |
| T-L16 | **premi dihitung atas subtotal pra-diskon**, lalu `max(0, sub − disc) + fee`; `trip_coins == round(total × 0.005)` | [§10.4](#104-rumus-uang-urutan-wajib) | ✅ `…premium_is_computed_before_the_discount_is_applied` — angka dipilih agar urutan yang salah memberi total berbeda (1.650.000 vs 1.700.000) |
| T-L17 | diskon > subtotal tidak bisa membuat total negatif | [§10.4](#104-rumus-uang-urutan-wajib) | ✅ `…cannot_make_the_total_negative` |
| T-L18 | voucher tak ada / kedaluwarsa → 422 `ERR_VALIDATION` pada `voucher_code`; `cashback` **tidak** mengurangi tagihan | [§12.5](#125-bottom_sheet_kode_promo-36--voucher) | ✅ 3 test |
| T-L19 | asuransi membuat `booking_insurances` `pending` + `premium_amount` benar; flag tanpa `plan_id` tidak menagih apa pun | [§12.7](#127-form_pesan_kamar_step2-31--asuransi-stay-protection) | ✅ 2 test |
| T-L20 | `check_in_time`/`check_out_time` diambil dari hotel (fixture `15:00`/`11:00`, bukan fallback `14:00`/`12:00`) | [§10.1](#101-diskriminator) | ✅ `test_check_in_and_out_times_come_from_the_hotel` |
| T-L21 | `check_in` lampau, `check_out` sehari yang sama, tanpa `property_id`/`hotel_id`, properti non-`active` → semua 422 | validasi | ✅ 4 test |
| T-L22 | `special_requests` 501 char → 422; 500 char tetap lolos | [A-D1](#113-drift-kontrak-flutter--laravel) | ✅ `test_special_requests_of_501_characters_is_rejected` |
| T-L23 | `contact_phone` 21 char → 422, 20 char lolos; kontak kosong jatuh ke user login — **jalankan di PostgreSQL** | [A-D10](#113-drift-kontrak-flutter--laravel) | ⚠️ ✅ ditulis, tapi hanya *bermakna* di `pgsql` (lihat catatan di bawah) |
| T-L24 | satu transaksi: kegagalan me-rollback bookings + booking_rooms + order + insurance | [§10.5](#105-baris-yang-dibuat-per-booking-hotel) | ✅ `test_a_failure_rolls_back_every_row_of_the_booking` |
| T-L25 | `children_ages` tersimpan jsonb; list kosong → `null`; umur > 17 → 422 | perbaikan L-5 | ✅ 2 test |
| T-L26 | callback pembayaran browser **tidak** mengubah status apa pun | aturan keras | ✅ **sudah dijaga di luar modul hotel** — `tests/Feature/Api/PaymentCallbackTest.php`. Tidak diduplikasi di sini. |

**Ditambahkan ke `HotelApiTest.php` untuk [F-13](#152-flutter)** (8 metode baru, 12 → 20 test dalam file yang sudah ada — bukan file baru, karena harga kartu adalah bagian dari kontrak `GET hotels` yang file ini sudah pegang):
| ID | Test | Menguji | Status |
|---|---|---|---|
| T-L27 | `price_from` = tarif tipe kamar aktif **termurah** (450.000 dari fixture 1.200.000/450.000), dan key `total_price` **ada tapi `null`** saat query tanpa tanggal | [A-D11](#113-drift-kontrak-flutter--laravel) | ✅ `test_search_emits_price_from_cheapest_active_room_type` — `assertArrayHasKey` + `assertNull`, jadi "key hilang" dan "key null" tidak bisa saling menutupi |
| T-L28 | `price_original` milik **tipe kamar yang dikutip**, bukan `MIN(price_original)` lintas tipe | [A-D11](#113-drift-kontrak-flutter--laravel) | ✅ `test_search_price_original_belongs_to_the_quoted_room_type` — **inilah pembeda kuncinya**: fixture menambah `Kamar Ekonomi` 300.000 **tanpa diskon**, jadi `price_from` = 300.000 dan `price_original` **wajib `null`**; implementasi ber-`MIN()` akan menjawab 600.000 dan mengiklankan diskon yang tidak ada |
| T-L29 | tipe kamar **non-aktif** tidak pernah menentukan harga kartu (tipe 150.000 `is_active: false` diabaikan) | [A-D11](#113-drift-kontrak-flutter--laravel) | ✅ `test_search_pricing_ignores_inactive_room_types` |
| T-L30 | `total_price` = `price_from × malam × kamar` (2 malam × 2 kamar → 1.800.000); tanpa `rooms_count` jatuh ke **1 kamar**, bukan 0 | [§10.4](#104-rumus-uang-urutan-wajib) | ✅ 2 test — `…totals_the_stay_when_dates_are_given`, `…total_defaults_to_one_room` |
| T-L31 | harga kartu **selamat** di `sort=distance` (jebakan `->select('hotels.*')`) dan `sort=price_asc` mengurutkan tepat pada angka yang dicetak kartu | [A-D11](#113-drift-kontrak-flutter--laravel), [L-6](#151-laravel) | ✅ 2 test — `test_distance_sort_still_carries_card_pricing`, `test_price_sort_orders_by_the_rate_the_card_shows` (`assertEquals([200000.0, 450000.0], $prices)`) |
| T-L32 | `GET hotels/{hotel}` memancarkan `price_from` + `price_original` (bar bawah sticky layar detail) | [A-D11](#113-drift-kontrak-flutter--laravel) | ✅ `test_detail_emits_price_from_and_price_original` |

**Ditambahkan ke `HotelApiTest.php` untuk [L-9](#151-laravel)** (5 metode lagi, 20 → 25 test; menguji `GET /api/v1/properties`, tapi tetap tinggal di file ini karena yang diuji adalah **paritas harga hotel** antar dua endpoint):

| ID | Test | Menguji | Status |
|---|---|---|---|
| T-L33 | `GET properties` dan `GET hotels` mengutip **angka yang sama** untuk hotel yang sama — nilai **dan** tipe JSON-nya | [A-D13](#113-drift-kontrak-flutter--laravel) | ✅ `test_properties_endpoint_quotes_the_same_rate_as_the_hotels_endpoint` — memanggil **kedua** endpoint dalam satu test dan membandingkan hasilnya satu sama lain (bukan dua konstanta terpisah yang bisa ikut basi bersamaan), lalu `assertIsNotString` untuk memaku selisih string-vs-float, plus `price_original` = 600.000 yang dulu tidak ada key-nya |
| T-L34 | tipe kamar **non-aktif** tidak menentukan harga di `GET properties` juga | [A-D13](#113-drift-kontrak-flutter--laravel) | ✅ `test_properties_endpoint_pricing_ignores_inactive_room_types` — **pembeda kunci L-9**: `Kamar Lama` 150.000 `is_active: false`; implementasi lama (`min()` tanpa filter) menjawab **150.000** di sini sementara `GET hotels` menjawab 450.000 untuk hotel yang sama |
| T-L35 | `has_breakfast` hanya menghitung tipe kamar **aktif** | [A-D13](#113-drift-kontrak-flutter--laravel) | ✅ `test_properties_endpoint_has_breakfast_ignores_inactive_room_types` — memeriksa **`true` dulu, lalu `false`** setelah satu-satunya tipe bersarapan (`Family Suite`) dinonaktifkan; tanpa asersi `true` di awal, test ini akan hijau bahkan bila `has_breakfast` selalu `false` |
| T-L36 | hotel **tanpa** tipe kamar aktif → `price_from: null`, **bukan** tarif `property_prices` | [A-D13](#113-drift-kontrak-flutter--laravel), [§11.2](#112-kontrak-field-harga) | ✅ `test_properties_endpoint_reports_no_rate_when_no_room_type_is_active` — fixture sengaja **menaruh** baris `property_prices` 999.000 pada properti hotel itu, jadi test gagal kalau fallback mode-unit menyelamatkannya; `assertArrayHasKey` + `assertNull` supaya "key hilang" tak lolos sebagai "null" |
| T-L37 | properti mode **`unit`** tetap dihargai dari `property_prices` termurah — pagar `booking_mode === 'room'` tidak boleh merusak jalur lama | [A-D13](#113-drift-kontrak-flutter--laravel) | ✅ `test_properties_endpoint_still_prices_unit_properties_from_property_prices` — 2 baris harga (bulanan 4.500.000 + harian 350.000) → `price_from` = 350.000, `price_original` `null`, `has_breakfast` `false` |

> 🟡 Seluruh asersi uang di blok ini memakai `assertEquals`, **bukan** `assertSame`/`assertJsonPath` — accessor mengembalikan `float` sedangkan kolom `decimal:2` di tempat lain menyeberang sebagai string, dan `assertSame` akan gagal karena selisih tipe, bukan karena selisih angka.

**Ditambahkan ke `HotelApiTest.php` untuk [F-7](#152-flutter)** (2 metode lagi, 25 → **27 test**; keduanya menguji `GET hotels/{hotel}`, kontrak yang file ini sudah pegang):

| ID | Test | Menguji | Status |
|---|---|---|---|
| T-L38 | `show()` meratakan `properties.cancellation_policy` ke akar `data` | [A-D16](#113-drift-kontrak-flutter--laravel) | ✅ `test_detail_flattens_the_cancellation_policy` — **key wajib ada meski nilainya `null`** (`assertArrayHasKey` + `assertNull`), supaya klien bisa membedakan "hotel tak menerbitkan syarat" dari "payload versi lama". Lalu kolomnya diisi dan diperiksa menyeberang **verbatim**: teks bebas `string(255)`, tak ada normalisasi sisi server dan tak ada kolom tenggat untuk menurunkan timeline |
| T-L39 | `active_room_types` membawa `description`, `facilities`, `images`, `bed_configuration` — tiap blok sheet #34/#35 | [A-D16](#113-drift-kontrak-flutter--laravel), [§12.12](#1212-room_detail-3435--sumber-tiap-blok) | ✅ `test_detail_room_types_carry_the_fields_the_room_sheet_reads` — **inilah pasak sebenarnya**: field-field itu menumpang gratis pada `$rt->toArray()`, jadi mempersempitnya jadi daftar kolom nanti akan mengosongkan galeri, paragraf pembuka, dan seluruh grid `Fasilitas Kamar` **tanpa merahkan satu test pun**. Bentuk `images` diperiksa sebagai objek (`[0]['url']`), bukan string, dan `bed_configuration` diperiksa utuh berisi ` atau ` karena tabel `Opsi 1`/`Opsi 2` adalah string itu yang dipecah **di klien** |

> ⚠️ **Batas SQLite.** Suite berjalan di **SQLite in-memory** yang **tidak** menegakkan CHECK constraint maupun lebar kolom. Karena itu T-L2 memeriksa **guard tingkat aplikasi** (422 sebelum tulis), bukan constraint `booked_count <= allotment` milik DB; dan T-L23 di SQLite hanya membuktikan aturan validasi menyala. Jalankan ketiga file di `pgsql` untuk menguji batas yang sebenarnya.
>
> Dua keputusan desain lain yang menjaga hasil tetap sama di kedua engine: ekspresi jarak `orderByDistance()` sengaja hanya memakai `+ − ×` (tanpa `radians()`/`acos()`), dan fixture `hotels.score` memakai satu kunci satu digit karena `Hotel::$casts['score'] = 'array'` membuat `orderByDesc('score')` membandingkan jsonb/teks — bukan angka. `HotelSearchSortTest` juga sengaja **tidak** mengirim `q` atau `city_name` yang memakai `ilike` (PostgreSQL-only).

**Flutter — `flutter/test/` berisi 20 file berisi test + 1 helper tanpa test: 209 deklarasi `test(`/`testWidgets(`, dan 273 test saat dijalankan.** Saat Fase 1: **17 file, 99 test**, 6 di antaranya menyentuh Hotel/asuransi. Jangan tulis ulang yang sudah ada.

> 🔴 **Dua angka berbeda, jangan dicampur.** *Deklarasi* = jumlah baris `test(`/`testWidgets(` di kode (**209**). *Test saat dijalankan* = **273**, karena satu deklarasi — `api_envelope_test.dart:136`, di dalam `for (final key in requests.keys)` — menghasilkan **65** test, satu per rute di tabel `DummyApiClient`. Jadi 209 − 1 + 65 = 273. Tabel di bawah memakai **deklarasi** (angkanya bisa di-grep), kecuali baris `api_envelope_test.dart` yang menyebut keduanya.

> ⚠️ **Angka dasar (17 file / 139 deklarasi) adalah hasil hitung ulang per deklarasi `test(`/`testWidgets(` (16 Agt 2026), dan mengoreksi dua sel tabel di bawah yang sempat salah:** `hotel_screens_test.dart` sebelumnya dicatat **15** padahal isinya **17** (yang dihitung "2 render dasar" sebenarnya **4**), dan `formatters_test.dart` dicatat **16** padahal isinya **14** (baseline pra-Fase 2 adalah 8, bukan 10). Kebetulan kedua kesalahan itu saling meniadakan pada penjumlahan hotel, sehingga selisih total (133 vs 135 sebelum [F-13](#152-flutter)) tidak terlihat. Setelah itu [F-4](#152-flutter) menambah **+29** (139 → 168, +1 file), [F-5](#152-flutter) menambah **+28** (168 → 196, +2 file), [F-6](#152-flutter) menambah **+5** (196 → 201, **tanpa file test baru** — 1 test masuk `models/hotel_test.dart`, 4 ke `widgets/hotel_screens_test.dart`), dan [F-7](#152-flutter) menambah **+8** (201 → **209**, juga tanpa file baru — **3** ke `models/hotel_test.dart`, **5** ke `widgets/hotel_screens_test.dart`).
>
> 🔴 **Koreksi kedua (16 Agt 2026, hitung ulang penuh dengan grep).** Rantai yang sempat tercatat — 139 → **167** → **195** — salah **satu** test sejak F-4: grup serialisasi di `special_request_test.dart` berisi **10** test, bukan 9 (`reproduces the §12.6 example exactly`, `… §12.7 …`, urutan katalog, titik ganda, catatan-saja, draft kosong → `null`, whitespace, gabung banyak tipe kamar, draft kosong keluar dari gabungan, plafon tepat 500). Jadi file itu **20** test bukan 19, F-4 **+29** bukan +28, dan totalnya **168** lalu **196**. Baseline 139 sendiri terbukti benar: 196 − 29 − 28 = 139.

| File | Isi | Δ Fase 2 |
|---|---|---|
| [`models/hotel_search_query_test.dart`](../../../flutter/test/models/hotel_search_query_test.dart) | **11** test — query params default, deep link `sewain://search`, deep link **tanpa `city_id`**, deep link kosong → besok/besok-lusa, round-trip `star_rating[n]`, nilai ganda/tak terbaca dibuang, grup `sort: distance` (4 test), `sort` tak dikenal → `score_desc` | +9 (dari 2) |
| [`providers/hotel_search_provider_test.dart`](../../../flutter/test/providers/hotel_search_provider_test.dart) | **6** test — initial state, search memuat hotel, meta paginasi ikut terbawa, search gagal → error state & list tetap kosong, `loadMore` no-op di halaman terakhir, respons basi dibuang | +4 (dari 2) |
| [`services/hotel_service_test.dart`](../../../flutter/test/services/hotel_service_test.dart) | **10** test — `searchHotels` ×3 (parsing, **`GET hotels` bukan `GET properties`**, meta), `getHotelDetail`, `getRoomTypes`, `getInsurancePlans`, `createHotelBooking` ×2, `createHotelForProperty` ×2 | +2 (dari 8) |
| [`api_envelope_test.dart`](../../../flutter/test/api_envelope_test.dart) | **23** deklarasi → **87 test saat dijalankan** (22 statis + **65** yang di-generate satu per rute oleh `test(key, …)` di dalam loop pada baris 136) — 2 guard paritas route, envelope tiap route, aset fixture, 8 jalur galat, grup **"hotel bookings ride on POST bookings"** (3 test), parsing envelope, bentuk home feed | +3 |
| [`models/hotel_test.dart`](../../../flutter/test/models/hotel_test.dart) | **15** test — `Hotel` minimal & lengkap (metadata 8 tab), `HotelRoomItem` default, **harga `decimal:2` berbentuk string** (T-F28), `occupancyLabel` (T-F29), `cheapestBookableRoom` (T-F30), **kunci harga `GET hotels`: string ↔ angka** (T-F32), **key harga absen → 0, bukan angka salah** (T-F33), **`deposit_amount` string/angka/absen** (T-F59), **`bedOptions` memecah ` atau `/` / `** (T-F64), **`description`/`facilities`/`images` bentuk objek** (T-F65), **`cancellation_policy` rata **maupun** bersarang di `property`** (T-F66), `HotelPolicy` default, `HotelGuestInput.toJson()`, `HotelFacilityGroup` kosong | +9 (dari 6) |
| [`widgets/hotel_screens_test.dart`](../../../flutter/test/widgets/hotel_screens_test.dart) | **44** deklarasi (43 `testWidgets` + 1 `test` murni untuk `additionalInfoEntries`) — bukan lagi render-level saja: pil tanggal hasil pencarian (T-F19), kartu rekomendasi dihargai dari query (T-F20), tipe kamar penuh ditolak (T-F21), tanggal & jam booking dari query (T-F22), 1 form tamu per kamar (T-F23), total + Trip Coins (T-F24), branding Sewain (T-F25), fallback kamar termurah-bookable (T-F26), hotel tanpa kamar menolak submit (T-F27), **kolom harga kartu hasil pencarian** (T-F34, T-F35), **sheet permintaan khusus #37 + section-nya** (T-F36…T-F44), **sheet kode promo #36 + section + end-to-end di layar booking** (T-F52…T-F58), **sheet informasi tambahan #33 + section + end-to-end** (T-F60…T-F63), **sheet detail kamar #34/#35 — pil tipe kamar, seksi lipat, dedup, end-to-end dari #27 & #31** (T-F67…T-F71), + 4 test `HotelFormScreen` mitra & 4 render dasar | +36 (dari 8) |
| [`models/special_request_test.dart`](../../../flutter/test/models/special_request_test.dart) | **20** test — **file baru** ([F-4](#152-flutter)): serialisasi (**10**, termasuk dua contoh §12.6/§12.7 diasersi **literal**), anggaran catatan lintas-kamar (5), helper state + `toUiJson` + paritas katalog↔label (5) | **+20 (file baru)** |
| [`models/promo_voucher_test.dart`](../../../flutter/test/models/promo_voucher_test.dart) | **15** test — **file baru** ([F-5](#152-flutter)): `PromoLabels.value` (T-F45, 1), `PromoLabels.category` (T-F46, 2 — termasuk `"umum"` di luar enum), `PromoLabels.validity` (T-F47, 3 — baris #36 karakter-per-karakter + jendela separuh + pemisah titik), `Voucher` masa berlaku (T-F48, 2), `PromoCandidate` (T-F49, 4 — semua mulai eligible, `(0 Tersedia)` lewat penolakan, cocok kode case-insensitive), `PromoSelection` (T-F50, 3 — diskon server, `max(0, …)`, cashback nol) | **+15 (file baru)** |
| [`services/voucher_service_test.dart`](../../../flutter/test/services/voucher_service_test.dart) | **6** test — **file baru** ([F-5](#152-flutter)), semuanya T-F51: verdict diterima (kode & subtotal terekam), penolakan sebagai **nilai** bukan exception, alasan dibaca dari **`errors.code`** bukan `errors.voucher_code`, galat non-validasi tetap di-throw, cashback diterima dengan diskon 0, `active()` memetakan katalog | **+6 (file baru)** |
| [`utils/formatters_test.dart`](../../../flutter/test/utils/formatters_test.dart) | **14** test — label metode/status pembayaran, `dateTime`, `rupiah`, **+ helper tanggal pendek `dayMonthShort`/`weekdayDayMonthShort` + varian iso + `hourMinute`** (T-F31). `dayMonthYearDotTime` (tambahan [F-5](#152-flutter)) diuji di `promo_voucher_test.dart` T-F47, bersama baris #36 yang menjadi alasan keberadaannya | +6 (dari 8) |
| `models/insurance_plan_test.dart` | 4 test — premi fixed per malam (1 & banyak tamu), premi persentase, parsing JSON | — |
| [`support/fake_voucher_api.dart`](../../../flutter/test/support/fake_voucher_api.dart) | **0 test — helper**, bukan file test ([F-5](#152-flutter)): `FakeVoucherTransport implements ApiTransport` (perekam `lastAppliedCode`/`lastAppliedSubtotal`/`applyCalls`/`listCalls`) + 3 fixture voucher + `appliedVoucherResponse()` + `refusedVoucher(reason)`. **Dibagi** antara test service dan test widget alih-alih disalin ke masing-masing — fake yang ada dua salinan akan menyimpang ([A-D13](#113-drift-kontrak-flutter--laravel)) | **+1 file (0 test)** |

> 🟡 `services/hotel_service_test.dart` juga membuktikan `getRoomTypes` mendelegasikan ke `getHotelDetail` — itulah sebab endpoint `GET hotels/{hotel}/room-types` tak pernah terpanggil ([A-D8](#113-drift-kontrak-flutter--laravel)).

Status tiap item yang direncanakan:

| ID | Test | Jenis | Status |
|---|---|---|---|
| T-F1 | `HotelSearchQuery.fromUri` tanpa `city_id` tidak throw | unit | ✅ **BERES** — `a deep link without city_id parses instead of throwing` + `an empty deep link falls back to tomorrow/day-after`. Perbaikan [F-2](#152-flutter) membuang `q['city_id']!` ([A-D7](#113-drift-kontrak-flutter--laravel)) |
| T-F2 | `toQueryParameters()` menghasilkan [§12.2](#122-query-pencarian--layar-16-716) | unit | ✅ **BERES** — ditambah round-trip `star_rating[n]` (asimetri `toQueryParams` ↔ `fromUri`) dan `sort` tak dikenal → `score_desc` |
| T-F3 | serialisasi permintaan khusus → satu string ≤500 char | unit | ✅ **BERES** — 10 test di `models/special_request_test.dart`, dan **dua contoh terbit di [§12.6](#126-bottom_sheet_permintaan-37--permintaan-khusus)/[§12.7](#127-form_pesan_kamar_step2-31--asuransi-stay-protection) diasersi karakter-per-karakter**. Justru asersi literal itu yang memaksa dua aturan: `selectedLabels` memancarkan **urutan katalog, bukan urutan tap** (kalau tidak, set pilihan yang sama menghasilkan dua string berbeda), dan titik penutup **dilewati** bila teks sudah berakhiran `.`/`!`/`?` (contoh §12.6 catatannya sudah bertitik → tanpa aturan ini hasilnya `tinggi..`). Plafon 500 diuji jatuh **tepat** di 500 |
| T-F4 | body `POST bookings` sama persis dengan [§12.3](#123-post-bookings--form-pengisian-kamar-multi-kamar) | unit | ✅ **BERES** — kedua test kini `expectedPath: 'bookings'`; `_CapturingTransport` juga merekam `capturedPath` tanpa syarat, jadi endpoint diuji langsung, bukan disimpulkan dari `capturedBody != null`. Body diasersi termasuk `booking_type: 'room'` + `duration_type: 'daily'`, dan `children_ages` kosong **tidak** dikirim |
| T-F5 | parsing respons 201 → `Booking` + `BookingRoom[]` | unit | ❌ belum — `models/booking_test.dart` (3 test) tidak menyentuh `BookingRoom`, `trip_coins_earned`, maupun asuransi |
| T-F6 | parsing envelope galat 422 → pesan field | unit | ✅ ada — `api_envelope_test.dart` (generik, cukup) |
| T-F7 | `RoomGuestStepperSheet` stepper naik/turun + batas minimum | widget | ❌ belum — **koreksi rujukan:** baris ini sempat menunjuk [F-5](#152-flutter), padahal F-5 adalah sheet kode promo. C-18 dipakai layar #3 & #15, jadi ia menunggu [F-9](#152-flutter) (C-11 `AppTopModalShell`, #12–#16) — dan perlu dicatat bahwa **C-18 sendiri tidak punya item checklist**; ia tersirat di F-9 |
| T-F8 | `ChildAgePickerSheet` memilih umur → memperbarui baris induk | widget | ❌ belum — idem T-F7: bukan [F-5](#152-flutter). C-19 dipakai #4 & #16 dan me-reuse C-18 sepenuhnya ([A-06](#4-log-anomali-aset--dokumentasi)), jadi ia mengikuti [F-9](#152-flutter) |
| T-F9 | urutkan: pilih opsi → hanya 1 radio aktif (4 opsi) | widget | ❌ belum |
| T-F10 | filter kebutuhan: multi-select mengubah gaya chip | widget | ❌ belum |
| T-F11 | `HotelResultCard` render tanpa harga-coret/chip/tag (state nullable) | widget | ❌ belum — test yang ada hanya render *happy path* |
| T-F12 | `form_pengisian_kamar`: submit dengan nama depan kosong → error | widget | ❌ belum |
| T-F13 | field email terisi menampilkan border biru + centang | widget | ❌ belum |
| T-F14 | `PricePrepaidBottomBar` menampilkan total terformat + tombol 44px | widget | ⚠️ **sebagian** — T-F24 sudah mematok total yang **terformat** (`Formatters.rupiah`, bukan `toStringAsFixed(0)`) di bar bawah layar booking; tinggi tombol 44px & komponen bar sebagai widget terpisah belum diuji |
| T-F15 | tab detail hotel: 8 tab, dapat di-scroll, ganti tab | widget | ⚠️ sebagian — `HotelDetailScreen renders hotel information and tabs` hanya memastikan tab ter-render, belum jumlah/scroll/ganti tab |
| T-F16 | daftar booking membedakan kartu room vs unit | widget | ❌ belum ([F-12](#152-flutter)) |
| T-F17 | alur lengkap search → detail → pesan → sukses (DummyApiClient) | integrasi | ❌ belum |
| T-F18 | guard: endpoint `api_client.dart` ↔ `dummy_api_client.dart` ↔ `routes/api_mobile.php` | unit (guard) | ✅ **BERES** — guard lama tetap ada (route dummy ↔ fixture asset, dua arah), ditambah grup `hotel bookings ride on POST bookings`: body ber-`hotel_id` diterima, `POST hotel/bookings` **wajib 404**, dan body tanpa `hotel_id`/`property_id` → 422 `property_id`. Route hantu tak bisa hidup kembali tanpa memecahkan test |

**Item test tambahan yang lahir dari [F-8](#152-flutter), [F-11](#152-flutter), [F-13](#152-flutter), [F-4](#152-flutter), [F-5](#152-flutter), [F-6](#152-flutter) & [F-7](#152-flutter)** (tidak ada di rencana Fase 1 — masing-masing memaku satu bug nyata atau satu kontrak server yang tak terbaca dari dokumen, bukan sekadar menaikkan cakupan):

| ID | Test | Jenis | Bug yang dipaku | Status |
|---|---|---|---|---|
| T-F19 | pil tanggal hasil pencarian menampilkan `28 Agt`/`30 Agt`, **bukan** `08-28`, dan bukan literal `15 Agt` | widget | [A-17](#4-log-anomali-aset--dokumentasi) | ✅ |
| T-F20 | kartu rekomendasi = kamar termurah-bookable × kamar × malam; `Rp 1.089.796` hardcode **wajib hilang** | widget | [F-8](#152-flutter) | ✅ |
| T-F21 | `Kamar Superior` (lebih murah tapi `remaining: 0`) tidak direkomendasikan, dan tombolnya `onPressed == null` | widget | [L-1](#151-laravel) 422 allotment | ✅ |
| T-F22 | layar booking menampilkan tanggal dari query + jam check-in/out tanpa detik | widget | [F-8](#152-flutter) | ✅ |
| T-F23 | 1 form tamu per kamar fisik, dinamai tipe kamar yang benar-benar dipilih | widget | [L-1](#151-laravel) `room_name` tak dikenal → 422 | ✅ |
| T-F24 | total & Trip Coins dihitung (0,5% dari subtotal), bukan literal `1.089.796`/`31 Trip Coins` | widget | [F-8](#152-flutter), [§10.4](#104-rumus-uang-urutan-wajib) | ✅ |
| T-F25 | teks persetujuan promo menyebut **Sewain**; `Trip.com` tidak ada; `Trip Coins` **tetap ada** | widget | [A-10](#4-log-anomali-aset--dokumentasi), [F-11](#152-flutter) | ✅ |
| T-F26 | tanpa pilihan eksplisit → fallback ke kamar termurah **yang bookable**, sebanyak kamar yang dicari | widget | [F-8](#152-flutter) | ✅ |
| T-F27 | hotel tanpa tipe kamar → "Belum ada kamar yang dipilih." dan submit ditolak **lokal**, tidak di-POST | widget | [F-8](#152-flutter) | ✅ |
| T-F28 | `base_price`/`price_original` berbentuk string `"750000.00"` ter-parse jadi `double`; kunci DB `bed_configuration`/`room_size_sqm`/`total_inventory` diterima | unit | [A-16](#4-log-anomali-aset--dokumentasi) | ✅ |
| T-F29 | `occupancyLabel` mengikuti kapasitas kamar (3 kombinasi) + `maxGuests` default | unit | [F-8](#152-flutter) | ✅ |
| T-F30 | `cheapestBookableRoom`: campuran / semua tersedia / semua penuh / kosong | unit | [L-1](#151-laravel) | ✅ |
| T-F31 | helper tanggal pendek + `hourMinute`: `9 Mei`, `31 Des`, `Sab, 15 Agt`, input buruk → `-` (**bukan** potongan string) | unit | [A-17](#4-log-anomali-aset--dokumentasi) | ✅ |
| T-F32 | kunci harga `GET hotels` (`price_from`/`price_original`/`total_price`) ter-parse dari **string** `"450000.00"` **maupun** angka; nama/alamat tetap terbaca dari map `property` bersarang | unit | [A-D11](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F33 | `total_price: null` → `0.0`; `price_per_night` (fixture dummy) **menang** atas `price_from` (API nyata); `'gratis'` → `0.0` tanpa crash | unit | [A-D11](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F34 | `HotelCardPrice` merender tarif + `Total harga:` lewat `Formatters.rupiah` (`Rp 446.637` / `Rp 893.274`) + harga-coret; **`Rp 0` wajib tidak ada** di tree | widget | [A-D11](#113-drift-kontrak-flutter--laravel), [F-13](#152-flutter) | ✅ |
| T-F35 | `HotelCardPrice` menyembunyikan yang tak dikirim server: `total_price` 0 → baris total hilang; tarif 0 → **"Harga belum tersedia"**, dan `price_original` yatim **tidak** dirender sebagai diskon | widget | [A-D11](#113-drift-kontrak-flutter--laravel), [F-13](#152-flutter) | ✅ |
| T-F36 | `SpecialRequestSheet` merender struktur #37: 3 judul grup, **8 label katalog** (tak satu pun `snake_case` bocor ke layar), counter `0/200`, disclaimer, tombol "Selesai" — dan tidak ada yang tercentang duluan | widget | [F-4](#152-flutter) | ✅ |
| T-F37 | radio bed/lift **mengganti** pilihan dalam grupnya (bukan menumpuk) dan tap kedua di baris yang sama **mengosongkannya** — mockup tak punya baris "tidak ada preferensi", jadi tanpa toggle-off satu salah-tap permanen untuk seluruh booking | widget | [F-4](#152-flutter) | ✅ |
| T-F38 | checkbox "Permintaan lainnya" menumpuk, dan **"Selesai" mengembalikan draft tersunting** lewat `Navigator.pop` — hasilnya diasersi sampai ke `serialize()` | widget | [A-D1](#113-drift-kontrak-flutter--laravel), [F-4](#152-flutter) | ✅ |
| T-F39 | menutup sheet lewat X **membuang** suntingan (`Future` resolve ke `null`, bukan draft separuh jadi) — sheet menyunting salinan lokal justru untuk ini | widget | [F-4](#152-flutter) | ✅ |
| T-F40 | counter mengikuti **anggaran 500 yang dibagi seluruh booking**, bukan 200 flat: satu kamar tetangga dengan catatan 200 karakter → counter membaca `0/111` dan `0/200` **wajib** tidak ada di tree | widget | [A-D1](#113-drift-kontrak-flutter--laravel), [F-4](#152-flutter) | ✅ |
| T-F41 | anggaran habis (4 tetangga × 200) → `TextField` **diganti** panel penjelas, bukan diberi `maxLength: 0` — keduanya (`TextField` & `LengthLimitingTextInputFormatter`) `assert maxLength > 0`, jadi ini memaku sheet agar tidak *crash* tepat saat booking paling penuh. Pilihan centang tetap hidup | widget | [F-4](#152-flutter) | ✅ |
| T-F42 | `SpecialRequestSection` = **satu baris per tipe kamar**: yang kosong menawarkan "Tambah permintaan", yang terisi menampilkan `summaryLine` + badge jumlah | widget | [F-4](#152-flutter) | ✅ |
| T-F43 | tanpa tipe kamar section **menciut ke `Size.zero`**, bukan menyisakan kartu berbingkai kosong | widget | [F-4](#152-flutter) | ✅ |
| T-F44 | end-to-end di `HotelBookingScreen`: 2 kamar fisik bertipe sama → **1** baris permintaan (draft ber-key `room_types.id`), lalu apa yang dikembalikan sheet itulah yang muncul di baris | widget | [A-D1](#113-drift-kontrak-flutter--laravel), [F-4](#152-flutter) | ✅ |
| T-F45 | `PromoLabels.value`: `percentage` → `10%` (**bukan** `10.0%`), `nominal`/`cashback` → rupiah — cashback adalah **uang yang kembali**, bukan bagian dari tagihan | unit | [F-5](#152-flutter) | ✅ |
| T-F46 | `PromoLabels.category`: 5 nilai enum `vouchers.category` punya label, dan nilai tak dikenal **diteruskan apa adanya** — `assets/json/GET_vouchers.json` mengirim `"umum"` yang bahkan tidak ada di enum, jadi runtuh-ke-`''` akan menghapus baris kedua kartu tanpa jejak | unit | [A-D14](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F47 | baris masa berlaku #36 direproduksi **karakter-per-karakter** (`Berlaku mulai 14 Agt 2026, 11.57 sampai 21 Agt 2026, 22.59`); jendela separuh-diketahui turun ke separuh yang diketahui; kosong → `''` supaya pemanggil menyembunyikan baris, bukan mencetak `Berlaku mulai - sampai -`; pemisah jam **titik** dan `Agt` (**bukan** `Agu` milik intl), `:` wajib tidak ada | unit | [F-5](#152-flutter) | ✅ |
| T-F48 | `Voucher.fromJson` mem-parse **kedua** batas jendela + `value` berbentuk string `"10.00"`; payload tanpa jendela tetap terdekode (`startsAt`/`endsAt` `null` → `validityOf` `''`) | unit | [A-D14](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F49 | `PromoCandidate`: semua kandidat **mulai** eligible (server tak mengirim `is_eligible`), `(0 Tersedia)` milik mockup dicapai lewat **penolakan berturut-turut** bukan angka yang ditebak, penolakan hanya menyentuh kode yang cocok (case-insensitive, ber-trim — yang diketik tamu ≠ yang disimpan katalog), dan kode di luar katalog tidak mengubah daftar | unit | [A-D14](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F50 | `PromoSelection`: mengutip **diskon yang diresolusi server**, bukan hasil hitung ulang dari `value`; `totalAfter()` ter-`max(0, …)` seperti server; cashback = berhasil **tanpa** mengurangi (`reducesTotal` `false`) | unit | [§10.4](#104-rumus-uang-urutan-wajib), T-L18 | ✅ |
| T-F51 | `VoucherService.check()` (6 test): verdict diterima merekam `code`+`subtotal` yang dikirim; **penolakan adalah nilai, bukan exception** (kartu dimmed adalah state normal #36, bukan jalur galat); alasan dibaca dari **`errors.code`** — `errors.voucher_code` sengaja diuji **tidak** terbaca, karena hanya `POST bookings` memakai nama itu; galat non-validasi (offline/500/sesi habis) tetap di-throw agar tidak men-dim kartu yang tak pernah ditolak; cashback → eligible dengan diskon 0; `active()` memetakan katalog | unit | [A-D14](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F52 | `PromoCodeSheet` merender katalog #36: judul, input + tombol `Tambah`, header `Pilih Kode Promo (2 Tersedia)`, judul & label kategori tiap kartu, **dua** baris masa berlaku; tidak ada centang dan tidak ada teks kedaluwarsa saat baru dibuka, dan **`applyCalls == 0`** — membuka sheet tidak boleh memanggil `POST vouchers/apply` untuk seluruh katalog | widget | [A-D14](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F53 | kode yang diketik **di-`toUpperCase()` + trim** sebelum dikirim (`hotweek10 ` → `HOTWEEK10`), dan subtotal yang menyeberang adalah **subtotal sebelum diskon**; field kosong → tombol tidak memanggil server sama sekali | widget | [F-5](#152-flutter) | ✅ |
| T-F54 | kartu yang **ditolak server** menampilkan kata-kata alasan server, header menyusut `(1 Tersedia)` → `(0 Tersedia)`, dan kartunya di-dim `opacity` **0.6** (diasersi lewat `Opacity` induk teks alasan, bukan sekadar "ada `Opacity` di tree"). Sheet **tetap terbuka** setelah penolakan, dan tap kedua di kartu yang sama tidak memanggil server lagi | widget | [A-D14](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F55 | sheet mengembalikan **diskon yang dihargai server**: fake menjawab `44663` yang sengaja **bukan** 10% dari 500.000, jadi implementasi yang menghitung ulang dari `value: 10` akan merah; `value` tetap 10 untuk label | widget | [§10.4](#104-rumus-uang-urutan-wajib) | ✅ |
| T-F56 | "dihapus" ≠ "ditutup": tap kartu yang sedang terpakai mengembalikan `PromoSheetResult` ber-`isCleared` **tanpa** memanggil server, sedangkan menutup lewat X mengembalikan **`null`** — dua-duanya `null`-ish kalau kontraknya hanya satu nilai, dan layar akan salah membuang promo yang masih dipakai | widget | [F-5](#152-flutter) | ✅ |
| T-F57 | `PromoCodeSection` mengucapkan **4** state: kosong ("Tambah kode promo"), berdiskon ("Digunakan" + `- Rp …`), cashback ("Cashback Rp 25.000 setelah menginap", **`- Rp 0` wajib tidak ada**), dan voucher nominal yang dihargai 0 → "Tidak mengurangi tagihan" | widget | T-L18 | ✅ |
| T-F58 | end-to-end di `HotelBookingScreen`: promo diterapkan → total turun, subtotal lama bertahan **sebagai harga coret**, baris `- Rp …` muncul, dan **Trip Coins mengikuti jumlah yang benar-benar dibayar** — kalimat koin pra-diskon diasersi **hilang** dari tree, karena server menghitung `round($total * 0.005)` setelah diskon. Subtotal yang sampai ke server diasersi = subtotal kamar sebelum diskon | widget | [F-5](#152-flutter), [§10.4](#104-rumus-uang-urutan-wajib) | ✅ |
| T-F59 | `deposit_amount` ter-parse dari **string** `"100000.00"` **maupun** angka; `"0.00"` → 0; key **absen** → 0 (bukan null, bukan crash); `'gratis'` → 0 | unit | [F-6](#152-flutter), perangkap `decimal:2` yang sama dengan [A-D11](#113-drift-kontrak-flutter--laravel)/T-F28 | ✅ |
| T-F60 | `additionalInfoEntries()` hanya menghitung seksi yang **ada isinya**: deposit-saja → 1 (bentuk mockup #33, kalimatnya diasersi literal), policy-saja → 2 (`Kebijakan Anak`, `Ranjang Tambahan`), keduanya → 3 dengan **deposit lebih dulu**, deposit `0.00` + policy → tetap 2, tanpa keduanya → **kosong**. Inilah yang membuat `(N)` mustahil berbohong: baris dan sheet membaca **satu** daftar | unit | [F-6](#152-flutter), [A-D13](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F61 | `AdditionalInfoSheet` merender ketiga seksi fixture (judul + isi) di bawah judul sheet `Informasi Tambahan` **tanpa** angka `(3)` — angka itu milik baris pemicu, bukan sheet — lalu X menutupnya dan future-nya selesai (read-only, [§12.8](#128-bottom_sheet_informasi_tambahan-33--informasi-tambahan): tak ada payload keluar) | widget | [F-6](#152-flutter) | ✅ |
| T-F62 | `AdditionalInfoSection`: daftar kosong → **tak menggambar apa pun** (tautan ke sheet kosong lebih buruk daripada tautan yang hilang), daftar berisi → `Informasi Tambahan (3)` + `Pelajari Selengkapnya` yang **benar-benar bergaris bawah** (`style.decoration`, bukan sekadar ada), dan tap-nya memanggil `onTap` | widget | [F-6](#152-flutter) | ✅ |
| T-F63 | end-to-end di `HotelBookingScreen`: fixture ber-policy tanpa deposit → `(2)` dan teks policy mentah diasersi **hilang** dari layar (dulu dicetak langsung ke kartu Trip Coins), hotel ber-deposit → `(3)`, dan kalimat deposit hanya muncul **setelah** `Pelajari Selengkapnya` ditap | widget | [F-6](#152-flutter) | ✅ |
| T-F64 | `bedOptions` memecah ` atau ` **dan** ` / ` (case-insensitive, spasi di kedua sisi wajib — `1 Katau Bed` bukan pemisah), string kosong → daftar kosong; `capacityLabel` = `2 dewasa, 1 anak` / `2 dewasa` | unit | [F-7](#152-flutter) — tabel `Opsi 1`/`Opsi 2` adalah **turunan** `bed_configuration`, bukan kolom baru | ✅ |
| T-F65 | `HotelRoomItem` mem-parse `description` + `facilities`, dan `images` bentuk **objek** `{url, caption}` **maupun** string; entri sampah (`{icon: 'tv'}`, `''`, `{caption:…}` tanpa `url`) dibuang; payload tanpa key → default kosong | unit | [A-D16](#113-drift-kontrak-flutter--laravel) — `'$e'` yang lama mencetak literal `{url: …, caption: …}` sebagai URL | ✅ |
| T-F66 | `cancellation_policy` terbaca **rata di akar** (bentuk yang [T-L38](#153-test--wajib-permintaan-eksplisit-pengguna) baru buat) **maupun** bersarang di map `property`; absen/`null` → `''` sehingga seksinya disembunyikan, bukan dibuka ke ruang kosong | unit | [A-D16](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F67 | **klaim inti F-7**: pil memindahkan header **dan** seluruh isi — nama aktif muncul **3×** (pil + header + judul), yang non-aktif **1×** (hanya pil); ukuran, deskripsi, `capacityLabel`, kalimat "cocok untuk grup Anda", dan baris sarapan semuanya berganti; `Konfirmasi Langsung` + `Prabayar Online` tetap | widget | [F-7](#152-flutter) — **kalau #34/#35 dua layar, test ini tak mungkin ada**: tak ada pil untuk ditap | ✅ |
| T-F68 | satu kamar saja → **tak ada baris pil** (nama muncul 2×, bukan 3×) dan tanpa disclaimer `Jenis kamar disediakan selama persediaan masih ada`; `Opsi 1`/`Opsi 2` hanya muncul bila `bed_configuration` memang menawarkan pilihan, kalau tidak jatuh ke baris inline | widget | [F-7](#152-flutter) | ✅ — tiap `pumpSheet` memakai `ValueKey` berbeda; tanpa itu Flutter memperbarui elemen yang sama dan state sheet sebelumnya bertahan (perangkap [F-6](#152-flutter)) |
| T-F69 | `Fasilitas Kamar` dibangun dari data: **6 dari 8** terlihat, dua sisanya baru muncul setelah `Tampilkan semua fasilitas` ditap (dan tautannya lalu hilang); kamar yang host-nya tak mengisi apa pun — **semua** kamar hasil seeder — kehilangan seksinya **beserta tautannya**, bukan menyisakan grid kosong | widget | [A-D16](#113-drift-kontrak-flutter--laravel) | ✅ |
| T-F70 | dua seksi chevron **tertutup saat dibuka** (sesuai capture), bisa dibuka **dan ditutup lagi**, isinya `properties.cancellation_policy` + `hotels.policies`; hotel tanpa keduanya → **kedua** seksi hilang sementara badan kamar tetap ter-render (`Opsi 1` masih ada) | widget | [F-7](#152-flutter) — `room_types` tak punya kolom kebijakan, jadi teksnya memang tingkat-hotel | ✅ |
| T-F71 | end-to-end: 2 kamar Superior + 1 Family Suite → **2** pil (`distinctRoomTypes` diasersi sebagai fungsi murni lebih dulu), **2** tautan `Lihat Detail`, sheet terbuka pada kamar yang ditap (`initialIndex == 0`) dan menerima `cancellationPolicy` hotel | widget | [F-7](#152-flutter) — layar booking menyimpan satu entri per kamar **fisik**, jadi tanpa dedup dua Superior melahirkan dua pil identik | ✅ |

> 🟡 **Mengapa `HotelCardPrice` dijadikan widget publik terpisah:** `HotelResultsScreen` membangun `HotelService`-nya sendiri di `initState`, jadi widget test **tidak bisa** menyuntikkan hasil pencarian — kolom harga kartu tak terjangkau test selama ia hanya sebuah closure di dalam `_hotelCardItem`. Padahal justru di situ regresi `Rp 0` hidup. Ekstraksi ini bukan kosmetik: ia yang membuat T-F34/T-F35 mungkin.

> 🟡 **Pelajaran itu diterapkan lagi di [F-4](#152-flutter).** Seluruh bottom sheet hotel yang sudah ada adalah closure `showModalBottomSheet` + `StatefulBuilder` **di dalam** layarnya, dan tak satu pun bisa dipompa test. `SpecialRequestSheet` dan `SpecialRequestSection` karena itu dibuat **publik**, sehingga T-F36…T-F43 menguji keduanya tanpa melewati `HotelBookingScreen` (yang membangun `HotelService`-nya sendiri). Nilai kembalian sheet — kontrak "Selesai → draft, dismiss → `null`" — tetap butuh route nyata, jadi T-F38/T-F39 memakai pembungkus `_SheetLauncher` yang memanggil `showSpecialRequestSheet()` dan menangkap hasilnya; memompa `SpecialRequestSheet` langsung hanya menguji widget-nya, bukan apa yang ia kembalikan.

> 🟡 **[F-5](#152-flutter) menambah satu lapis lagi: sheet yang bicara ke server tak cukup dibuat publik.** `PromoCodeSheet` memanggil dua endpoint, jadi selain publik ia menerima `VoucherService?` lewat konstruktor — dan `HotelBookingScreen` ikut menerimanya, kalau tidak T-F58 (promo → total → koin) mustahil ditulis: layar itu membangun service-nya sendiri, persis pola yang membuat kolom harga kartu tak terjangkau test di [F-13](#152-flutter). Fake-nya (`FakeVoucherTransport`) ditaruh di `test/support/` dan **dibagi** oleh test service dan test widget, bukan disalin: fake yang ada dua salinan akan menyimpang, dan itu tepat kesalahan yang [A-D13](#113-drift-kontrak-flutter--laravel) hukumnya. Ia juga merekam apa yang dikirim (`lastAppliedCode`, `lastAppliedSubtotal`, `applyCalls`) — tanpa perekam itu, tiga asersi paling penting F-5 (kode di-uppercase, subtotal **sebelum** diskon, membuka sheet tidak memanggil server) tidak punya cara untuk gagal.
>
> Satu asersi sengaja dibuat **tidak bisa lolos secara kebetulan**: T-F55 menyuruh fake menjawab diskon `44663` yang **bukan** 10% dari 500.000. Implementasi yang menghitung ulang dari `value: 10` akan menghasilkan 50.000 dan merah — sedangkan fake yang "jujur" (menjawab 50.000) akan menghijaukan kedua implementasi, termasuk yang salah. Prinsip yang sama dipakai T-F54: yang diasersi adalah `opacity == 0.6` pada `Opacity` **induk teks alasan**, bukan keberadaan `Opacity` di tree — yang selalu benar dan karena itu tak membuktikan apa pun.
>
> Literal masa berlaku di test (`Berlaku mulai 14 Agt 2026, 11.57 …`) **bebas-mesin** justru karena [A-D15](#113-drift-kontrak-flutter--laravel) tidak ditambal: tanpa `.toLocal()`, hasil render tidak bergantung pada timezone mesin yang menjalankan test. Kalau kelak `.toLocal()` dipasang tingkat aplikasi, literal ini **akan** pecah di mesin non-UTC dan harus dinormalkan bersamaan.

> 🟡 **Mengapa formatter ditulis tangan, bukan `DateFormat(..., 'id_ID')`:** dua alasan yang keduanya terbukti dari kode — (1) `DateFormat` dengan locale non-default **throw** kecuali `initializeDateFormatting()` sudah jalan, dan itu hanya dipanggil di `main.dart:13` yang **tidak pernah** dieksekusi widget test; (2) intl menyingkat Agustus jadi `Agu`, sedangkan seluruh mockup hotel menulis `Agt`. `NumberFormat` (dipakai `Formatters.rupiah`) tidak butuh inisialisasi, jadi uang tetap lewat intl.

**Ringkas:** dari 18 item rencana, **6 tertutup di Fase 2** (T-F1, T-F2, T-F3, T-F4, T-F18 — plus T-F6 yang sudah ada), **2 sebagian** (T-F14, T-F15), sisanya **10 net-new** dan menunggu komponen [F-9…F-12](#152-flutter) dibuat lebih dulu — sebuah widget test tak bisa mendahului widget-nya. Di luar rencana itu, **53 item baru (T-F19…T-F71) ditulis dan ditutup** karena [F-8](#152-flutter)/[F-11](#152-flutter)/[F-13](#152-flutter)/[F-4](#152-flutter)/[F-5](#152-flutter)/[F-6](#152-flutter)/[F-7](#152-flutter) menyingkap perilaku yang tak terbayangkan saat Fase 1. Total suite Flutter: **99 → 209 deklarasi** (99 = keadaan sebelum Fase 2; angka **117** yang sempat tercatat adalah total **di tengah** Fase 2, setelah batch pertama +18 dan sebelum batch [F-8](#152-flutter); **139** adalah total setelah [F-13](#152-flutter); **168** setelah [F-4](#152-flutter); **196** setelah [F-5](#152-flutter); **201** setelah [F-6](#152-flutter)), kini **20 file** (+1 helper tanpa test) — +9 `hotel_search_query_test.dart`, +4 `hotel_search_provider_test.dart`, +2 `hotel_service_test.dart`, +3 `api_envelope_test.dart`, **+9 `hotel_test.dart`**, **+36 `hotel_screens_test.dart`** (9 di antaranya milik [F-4](#152-flutter), 7 milik [F-5](#152-flutter), 4 milik [F-6](#152-flutter), 5 milik [F-7](#152-flutter)), +6 `formatters_test.dart`, **+20 `special_request_test.dart` (file baru)**, **+15 `promo_voucher_test.dart` (file baru)**, **+6 `voucher_service_test.dart` (file baru)** = **+110**, dan 99 + 110 = 209 ✅. Saat dijalankan angkanya **273** (lihat kotak merah di atas: `api_envelope_test.dart` men-generate 65 test dari 1 deklarasi). Sisi Laravel: **49 test di 3 file baru + 15 test di `HotelApiTest.php`** (8 untuk [F-13](#152-flutter) + 5 untuk [L-9](#151-laravel) + 2 untuk [F-7](#152-flutter)) = **64 test Fase 2** — [F-5](#152-flutter) **tidak** menambah test Laravel karena ia tidak mengubah Laravel (kontrak voucher-nya sudah dipatok T-L18), dan [F-6](#152-flutter) juga tidak: `deposit_amount` sudah dipatok `HotelApiTest.php:319` sejak sebelumnya — yang hilang justru sisi Flutter-nya. [F-7](#152-flutter) sebaliknya **memang** menyentuh Laravel (`show()` tak pernah memilih `cancellation_policy`), jadi ia membawa 2 test server.

> ⚠️ **Jalankan `flutter test` sebelum menandai item apa pun selesai.** Suite ini sempat merah tanpa disadari karena route hantu tertinggal di tabel route dummy — lihat [A-14](#4-log-anomali-aset--dokumentasi). Guard-nya bekerja; yang tidak dijalankan adalah suite-nya.

---

## 16. Daftar Sinkronisasi Dokumen Lanjutan

Masih bagian **Fase 1** — dokumentasi saja, tanpa kode. **Semua target di bawah sudah disinkronkan 16 Agt 2026.**

| Dok | Yang disinkronkan | Status |
|---|---|---|
| `docs/flutter/screens.md` | [A-11](#4-log-anomali-aset--dokumentasi) diperbaiki: anchor TOC disamakan dengan heading; `hotel/ (0 file) ❌` → `property/hotel/ (4 file) ✅`; "6 Hotel OTA belum didaftarkan" → semua route terdaftar; catatan basi dibuang; angka disetel ke kondisi nyata (45 screen, 44 route, 24 model, 19 service, mitra 10 file); ditambah tabel "Komponen yang belum ada" + seksi "Cakupan Test Flutter" (17 file). | ✅ |
| `docs/hotel/01-database-migration.md` | Blok peringatan setelah migrasi `room_inventories`: tabel 3 cabang (B1/B2/B3) dengan status `lockForUpdate`/`increment`; penjelasan bahwa CHECK constraint `booked_count <= allotment` **tidak pernah dievaluasi** di jalur `guests[]` karena tak ada `UPDATE`; catatan SQLite tidak menegakkan CHECK. | ✅ |
| `docs/hotel/02-models-relationships.md` | Seksi baru **§1.5** — matriks `unit` vs `room`, rantai relasi `Booking → bookingRooms → roomType → hotel → property`, contoh query salah vs benar, penegasan `booking_type` sebagai satu-satunya sumber kebenaran di sisi baca. | ✅ |
| `docs/hotel/03-query-filters.md` | Seksi baru **§1.1** (kamus `sort` UI↔server, terverifikasi) & **§1.2** (`needs[]` + `children_ages` belum didukung). Dicatat 2 drift baru: doc menuliskan `popularity` yang **ditolak 422** oleh controller nyata, dan **"Jarak terdekat" tidak punya implementasi server**. | ✅ |
| `docs/hotel/04-flutter-implementation.md` | Sub-bagian baru **§8.F** — 4 peringatan (2 endpoint hantu, bypass provider, `top_modal_sheet` tak terpasang, deep link tanpa `city_id`), tabel komponen yang belum ada, dan cakupan 6 file test hotel + catatan A-12/A-D8. | ✅ |
| `docs/hotel/05-insurance-integration.md` | Seksi baru **§5.1** — `has_insurance` ≡ `include_insurance` (di-OR), tabel 4 kombinasi flag×plan_id, dan urutan rumus: premi dihitung dari subtotal **sebelum** diskon lalu ditambahkan **di luar** `max(0, …)`, Trip Coins dari total termasuk premi. | ✅ |
| `docs/hotel/06-hotel-management-flow.md` | Blok peringatan pada `CancelExpiredBookingsJob` — job hanya bisa melepas stok yang pernah dipotong; tabel B1 vs B2; konsekuensi kalender allotment Mitra menampilkan angka yang salah. | ✅ |
| `docs/hotel/07-compatibility-map.md` | Seksi baru **§2.A0** — matriks diskriminator kanonik 16 baris + potongan kode inferensi `booking_type` (5 jalur). | ✅ |

---

## 17. Riwayat Audit

| Tanggal | Perubahan |
|---|---|
| 2026-08-16 | Penulisan ulang penuh sebagai Master Reference. Diverifikasi 40 HTML = 40 entri manifest; dihitung 89 aset gambar (41 PNG + 48 JPEG); dicatat anomali A-01…A-11 + drift A-D1…A-D10; penomoran layar diperbaiki jadi 1–40 kontinu (memperbaiki A-07, A-09); ditambahkan pemisahan domain hotel-vs-properti, kontrak API, 11 payload dummy JSON, 9 cuplikan struktur HTML, 38 komponen reusable, dan checklist Fase 2 dengan 17 test Laravel + 18 test Flutter. |
| 2026-08-16 | **Sinkronisasi dokumen (§16) selesai** — 8 dokumen diperbarui: `docs/flutter/screens.md` + `docs/hotel/01`…`07`. |
| 2026-08-16 | **Koreksi kesalahan audit sendiri:** klaim "0 test Flutter" **salah** — `flutter/test/` berisi **17 file**, 6 di antaranya menyentuh Hotel/asuransi (±31 test hotel + 4 asuransi). §2 dan §15.3 diperbaiki; rencana test Flutter di-*rescope*: dari 18 item, 3 sudah tertutup (T-F2, T-F6, sebagian T-F15), 2 perlu **diperbaiki** bukan ditulis baru (T-F4, T-F18), 13 net-new. |
| 2026-08-16 | **3 temuan baru saat verifikasi silang** (bukan asumsi, semuanya dibaca dari kode): **A-12** — `hotel_service_test.dart:267,314` memaku `expectedPath: 'hotel/bookings'` sehingga perbaikan A-D5 akan memecahkan 2 test hijau; **A-13** — guard di `api_envelope_test.dart:125-132` menghadap ke fixture, bukan ke `routes/api_mobile.php`, itulah sebab A-D4/A-D5 lolos; **A-D9 naik ke 🔴** — `PropertyController::index()` hanya menerima `newest|price_asc|price_desc|rating`, jadi opsi UI "Jarak terdekat" tidak punya implementasi server dan `popularity` di `03-query-filters.md` ditolak 422. |
| 2026-08-16 | **A-D7 dikonfirmasi, bukan dilemahkan.** Sempat tampak sudah tertutup oleh test deep link yang ada; setelah `hotel_search_query_test.dart:25-37` dan `hotel_search_query.dart:84-102` dibaca, ternyata test selalu mengirim `city_id=3` sedangkan baris 92 memakai `q['city_id']!` tanpa `??` (satu-satunya field tanpa fallback). Bug nyata + celah test. |
| 2026-08-16 | **Pemeriksaan integritas tautan.** Seluruh 20 anchor lintas-dokumen divalidasi terhadap daftar heading nyata (bukan slug hasil tebakan). Ditemukan & diperbaiki **3 tautan rusak** yang saya sendiri tulis: `#103-tiga-cabang-harga-di-storehotelbooking` → `…-tiga-cabang-penetapan-harga-…` (di `01` & `06`), `[§15.2](#152-laravel)` → `[§15.1](#151-laravel)` (§15.2 sebenarnya "Flutter", di `01`), dan `#10-pemisahan-domain-hotel-vs-properti-biasa` → `#10-pemisahan-domain-booking-hotel-vs-booking-properti` (di `02`). 17 anchor lainnya terbukti resolve. |
| 2026-08-16 | **FASE 1 SELESAI.** Tidak ada kode Flutter/Laravel yang ditulis atau diubah — hanya dokumentasi, sesuai batasan fase. |
| 2026-08-16 | **FASE 2 — perbaikan kode.** Laravel: [L-1](#151-laravel) (jalur `guests[]` kini `lockForUpdate` + `increment` `room_inventories`, harga dari kalender, nama kamar tak dikenal → 422 alih-alih `room_type_id => 1`), L-2 (route hantu `GET hotel/filters` dihapus), L-3 (`POST hotel/bookings` tidak dibuat — Flutter diarahkan ke `POST bookings`), L-4 (`contact_phone` `max:25` → `max:20`, selaras kolom), L-5 (`children_ages` dimigrasi + di-cast + disimpan; list kosong → `null`), L-6 (`sort=distance` benar-benar mengukur dari `lat`/`lng`, tanpa origin turun ke relevansi — sebelumnya diam-diam `orderByDesc('star_rating')`), L-7 (tanpa drift). Flutter: [F-1](#152-flutter) (provider → `HotelService.searchHotels()` → `GET hotels`, state `Paginated<Hotel>`), F-2 (`city_id` tanpa null-assertion + `star_rating` round-trip), F-3 (endpoint hantu dimatikan di kedua transport). |
| 2026-08-16 | **FASE 2 — test wajib.** 3 file Laravel baru, **49 test**: `HotelBookingInventoryTest` (13, T-L1…T-L8), `HotelSearchSortTest` (15, T-L9…T-L14), `HotelBookingContractTest` (21, T-L15…T-L25). Flutter: `hotel_search_query_test.dart` 2→11, `hotel_search_provider_test.dart` 2→6, `hotel_service_test.dart` 8→10, `api_envelope_test.dart` +3 — total suite **117 test / 17 file**. Ketiga file Laravel ditulis **sadar-engine**: jarak tanpa `radians()`/`acos()`, fixture `score` satu digit (karena `Hotel::$casts['score']='array'` membuat `orderByDesc` membandingkan jsonb/teks), dan tanpa `q`/`city_name` yang memakai `ilike`. Batas kolom (T-L23) hanya bermakna di `pgsql`. §15.3 ditulis ulang jadi tabel berstatus; **T-F1/T-F2/T-F4/T-F18 ditutup** → **A-12** dan **A-13** ikut tutup. |
| 2026-08-16 | **A-14 — temuan paling tajam sesi ini: suite Flutter sudah merah sebelum Fase 2 dimulai.** Guard `every route in the table is covered by this test` menuntut setiap kunci `DummyApiClient.routes` punya fixture di map `requests`; route hantu `GET hotel/filters` ada di tabel tapi tak pernah didaftarkan, jadi test itu gagal — **sejak sebelum audit**. Artinya A-D4/A-D5 sebenarnya **sudah tertangkap alat yang ada**; yang gagal adalah proses, bukan cakupan test. Ditutup otomatis oleh L-2 tanpa menyentuh test-nya. Aturan baru: jalankan `flutter test` **sebelum** menandai item selesai. |
| 2026-08-16 | **Koreksi hitungan sendiri.** Sempat tercatat "50 test Laravel, T-L1…T-L24"; setelah dihitung ulang per metode, angkanya **49** dan blok `children_ages` belum punya ID → diberi **T-L25**. Rentang ID ketiga file juga sempat bertabrakan (masing-masing mengklaim T-L1…T-L11 / T-L12…T-L17 / T-L5…T-L16) dan satu docblock menunjuk file `HotelBookingBoundaryTest` yang **tidak pernah dibuat** — ketiganya dirapikan jadi blok terpisah agar tabel §15.3 bisa dipercaya. |
| 2026-08-16 | **[F-8](#152-flutter) + [F-11](#152-flutter) selesai — dan F-8 ternyata bukan item kosmetik.** Rencana Fase 1 menulis F-8 sebagai "ganti `_roomSummary(...)` hardcode dengan data asli". Saat dikerjakan, layar booking **tidak bisa** diperbaiki sendirian: query pencarian tak pernah sampai ke layar detail, jadi tak ada tanggal/jumlah kamar untuk diteruskan. Dibuat rantai argumen `HotelDetailArgs` → `HotelBookingArgs` (+ `HotelRoomSelection`), `router.dart` diperlebar untuk ketiga route hotel dengan back-compat (`Hotel` polos & `int` id tetap diterima), dan `HotelSearchQuery.defaultStay()` dijadikan satu-satunya fallback. Ditambah `Hotel.cheapestBookableRoom` yang memfilter `remaining > 0` — kebijakan pemilihan kamar yang **sama** dipakai kartu rekomendasi, bar bawah, dan fallback layar booking, sehingga tak ada layar yang lagi menawarkan kamar yang akan ditolak 422 oleh [L-1](#151-laravel). Tiga bug lain ikut tersingkap dan ditutup: **[A-15](#4-log-anomali-aset--dokumentasi)** (kartu hasil pencarian membuka `Routes.propertyDetail`, jadi seluruh layar detail hotel **tak terjangkau dari mana pun**), **[A-16](#4-log-anomali-aset--dokumentasi)** (`base_price` dibaca `as num?` padahal cast `decimal:2` mengirim string → Rp 0 diam-diam), **[A-17](#4-log-anomali-aset--dokumentasi)** (pil tanggal `substring(5)` + membaca `widget.query` sementara tetangganya `_currentQuery`). F-11: teks persetujuan promo → "promo spesial **Sewain**"; `Trip Coins` **sengaja dipertahankan** karena itu nama kolom ledger `bookings.trip_coins_earned`, bukan merek pihak ketiga ([A-10](#4-log-anomali-aset--dokumentasi)). |
| 2026-08-16 | **13 test baru di luar rencana (T-F19…T-F31), suite Flutter 117 → 133.** `hotel_screens_test.dart` 8 → 15 (dan tidak lagi render-level saja: tanggal, uang, koin, kapasitas, dan tombol kamar-penuh semuanya diasersi), `hotel_test.dart` 6 → 9, `formatters_test.dart` 10 → 16. Setiap asersi digrounding dengan **membaca widget yang merendernya**, bukan dari ingatan — cara itu menangkap tiga jebakan sebelum jadi test merah: `ListView` di dalam `NestedScrollView` membangun anak secara lazy sehingga kartu di luar viewport **tidak ada** di tree (diselesaikan dengan memperbesar `tester.view.physicalSize`, bukan `dragUntilVisible` yang harus menebak salah satu dari beberapa `Scrollable`); timer 4 detik `SnackBar` yang tertinggal **menggagalkan** body `testWidgets`; dan `Provider.create` yang lazy membuat `AuthProvider()` baru dikonstruksi sekarang (diperiksa: konstruktor `AuthProvider`/`AuthService` bebas efek samping, jadi aman). |
| 2026-08-16 | **[A-D11](#113-drift-kontrak-flutter--laravel) — drift baru, ditemukan Fase 2 bukan Fase 1: harga hotel tidak pernah dikirim server.** Saat memverifikasi A-16 sampai ke sumbernya, terbukti `GET hotels` (`ApiResponse::paginated($hotels, …)` atas model `Hotel` mentah) dan `GET hotels/{hotel}` (`$hotel->toArray()`) **tidak memuat** `price_per_night`, `price_original`, maupun `total_price` — ketiganya bukan kolom `hotels` dan tak dihitung di controller mana pun; harga hanya ada di `active_room_types[].base_price`. Jadi **setiap kartu hasil pencarian menampilkan `Rp 0` / `Total harga: Rp 0`** di API nyata, dan tertutup selama ini semata-mata karena fixture dummy memuat ketiga kunci itu. Layar detail sudah kebal lewat `_nightlyFrom()` (fallback ke tipe kamar termurah-bookable); kartu hasil pencarian **belum** → dilacak sebagai [F-13](#152-flutter), dengan perbaikan **di sisi Laravel**. Ini juga sebabnya audit Fase 1 tidak menangkapnya: perbandingan dilakukan terhadap fixture dummy, bukan terhadap respons controller nyata. |
| 2026-08-16 | **[F-13](#152-flutter) selesai — harga kartu kini datang dari server.** Perbaikan [A-D11](#113-drift-kontrak-flutter--laravel) dikerjakan **di Laravel** seperti yang direncanakan, tapi jalur teknisnya berbeda dari rencana: bukan `withMin()` kedua, melainkan accessor `Hotel::price_from`/`price_original` di atas `cheapestActiveRoomType()` (membaca relasi room-type **yang sudah ter-eager-load**, tanpa query per baris) yang di-`append()` per koleksi oleh `HotelApiController::attachCardPricing()`, plus `total_price` = `price_from × malam × kamar` yang **hanya** dihitung bila query membawa tanggal. Tiga jebakan yang ditemukan dengan **membaca dulu, bukan mencoba dulu**: (1) `orderByDistance()` memanggil `->select('hotels.*')` yang **mengganti** daftar kolom, jadi kolom `withMin` (`addSelect`) akan hilang tepat di `sort=distance` — dipatok T-L31; (2) memasukkan accessor ke `$appends` akan menyalakan cabang query-nya per baris di mana pun `Hotel` polos diserialisasi; (3) `attributesToArray()` menjalankan get-mutator atas atribut apa pun yang punya satu, jadi `setAttribute('price_from', …)` dari controller **ditimpa** accessor — sebab itulah nilai hitungan controller tidak boleh memakai nama accessor. Sisi Flutter: `_toDouble` dinaikkan jadi fungsi tingkat-file di `hotel.dart` (dipakai ketiga field uang) dan kolom harga kartu diekstrak jadi widget publik **`HotelCardPrice`** — `Formatters.rupiah`, **"Harga belum tersedia"** alih-alih `Rp 0`, total disembunyikan bila server tak mengirimnya, dan harga-coret hanya muncul bila ada tarif pembanding. Accessor `getPriceFromAttribute()` yang lama ternyata **menyelidiki relasi yang salah** dan tak pernah bisa dipakai (tidak ada di `$appends`) — diganti, bukan ditambal. |
| 2026-08-16 | **2 temuan sampingan F-13.** **[A-18](#4-log-anomali-aset--dokumentasi)** — `HotelApiTest::test_search_filters_by_star_rating` **tidak mungkin hijau sejak sebelum Fase 2**: ia membuat hotel kedua di atas `property_id` yang sama padahal kolom itu **UNIQUE** (SQLite menegakkan UNIQUE, hanya CHECK yang tidak), dan hotel itu juga tak punya room type aktif sehingga asersinya akan lolos untuk alasan yang salah; diperbaiki lewat helper `createHotel()` yang memberi tiap fixture Property sendiri + satu RoomType aktif. **[A-D12](#113-drift-kontrak-flutter--laravel)** 🟡 — `min_price`/`max_price` menyaring dengan "punya ≥1 kamar di rentang" sedangkan kartu mengutip "tarif termurah", jadi `?min_price=1000000` bisa menampilkan kartu berharga 450.000. **Sengaja tidak ditambal di F-13**: memperkecil eager-load `activeRoomTypes` akan ikut mengubah key `active_room_types` yang dibaca `Hotel.cheapestBookableRoom` — filter harga jadi diam-diam mengubah **kamar apa yang dipesan**. Dicatat sebagai drift ke-12 dengan dua opsi perbaikan, bukan diselundupkan ke dalam scope F-13. |
| 2026-08-16 | **Test F-13: 8 Laravel (T-L27…T-L32) + 4 Flutter (T-F32…T-F35).** `HotelApiTest.php` 12 → **20** test; `hotel_test.dart` 9 → 11; `hotel_screens_test.dart` 17 → 19. Test pembeda kuncinya **T-L28**: fixture menambah kamar 300.000 **tanpa** `price_original`, sehingga implementasi ber-`MIN(price_original)` akan mengiklankan diskon yang tidak ada — asersi menuntut `price_original` **`null`**. `HotelCardPrice` sengaja dijadikan widget **publik terpisah** karena `HotelResultsScreen` membangun `HotelService`-nya sendiri, jadi hasil pencarian tak bisa disuntikkan dari test — tanpa ekstraksi itu, tempat regresi `Rp 0` tinggal justru satu-satunya bagian yang tak terjangkau test. |
| 2026-08-16 | **Hitung ulang suite Flutter: 133 → 139 (bukan karena tambahan, tapi karena koreksi).** Dihitung per deklarasi `test(`/`testWidgets(`: `hotel_screens_test.dart` berisi **19** (batch [F-8](#152-flutter) menambah **9**, bukan 7 — yang dicatat "2 render dasar" sebenarnya 4) dan `formatters_test.dart` berisi **14** (baselinenya 8, bukan 10). Kedua kesalahan itu **saling meniadakan** pada penjumlahan file hotel, sehingga total 133 tampak konsisten padahal 2 kurang. Angka terverifikasi sekarang: **139 test / 17 file** Flutter, **230 metode test / 27 file** Laravel (49 di 3 file Fase 2 + 8 di `HotelApiTest`). |
| 2026-08-16 | **[A-D13](#113-drift-kontrak-flutter--laravel) + [L-9](#151-laravel) — memverifikasi klaim yang baru ditulis sendiri, dan menemukan klaim itu salah.** Baris `price_from` di [07-compatibility-map.md](../07-compatibility-map.md) yang ditulis untuk F-13 berbunyi "dua jalur, dua implementasi — selaraskan bila salah satu diubah". Saat dicek apakah keduanya masih selaras, ternyata **tidak**: `PropertyResource` memakai `min('base_price')` **tanpa** filter `is_active` dan mengembalikan **string** `decimal:2` mentah, sementara `GET hotels` memakai accessor yang memfilter aktif dan mengembalikan **float** — satu tipe kamar murah yang dinonaktifkan cukup membuat `GET properties` mengutip tarif yang tak bisa dipesan siapa pun. `price_original`/`total_price` juga tak ada di sana sama sekali. Akar yang sama menular ke `has_breakfast`. Diperbaiki dengan **menghapus implementasi kedua**, bukan menyamakan dua rumus: resource itu kini mendelegasikan ke `$this->hotel->price_from`, gratis secara query karena `PropertyController::index()` sudah meng-eager-load `hotel.roomTypes` sejak semula. Tiga penyesuaian wajib menyertainya — `hostIndex()` dinaikkan ke `with('hotel.roomTypes')` (kalau tidak daftar Mitra jatuh ke tarif mode-unit), fallback `property_prices` dikunci ke non-`room` (hotel tanpa kamar aktif memang **tidak punya** tarif; `null` adalah kontraknya), dan `has_breakfast` ikut memfilter `is_active`. **Pelajaran prosesnya:** peringatan "selaraskan bila diubah" di dokumen tidak pernah menjaga apa pun — yang menjaga adalah satu sumber kode + test paritas (T-L33) yang memanggil **kedua** endpoint dan membandingkan hasilnya satu sama lain, bukan terhadap dua konstanta yang bisa basi bersamaan. |
| 2026-08-16 | **Test L-9: 5 Laravel (T-L33…T-L37).** `HotelApiTest.php` 20 → **25** test; total Fase 2 sisi Laravel **62** (49 di 3 file baru + 13 di `HotelApiTest`). Pembeda kuncinya **T-L34** (`Kamar Lama` 150.000 `is_active: false` — implementasi lama menjawab 150.000 di `GET properties` sementara `GET hotels` menjawab 450.000 untuk hotel yang sama) dan **T-L36** yang sengaja **menaruh** baris `property_prices` 999.000 pada properti hotel supaya test gagal kalau fallback mode-unit menyelamatkannya. T-L35 memeriksa `true` **lalu** `false` — tanpa asersi pertama, test `has_breakfast` akan hijau bahkan bila nilainya selalu `false`. Helper `propertyPayload()` mencari properti berdasarkan **`id`**, bukan `data.0`, karena dua test di antaranya menambah properti ke fixture. |
| 2026-08-16 | **[F-4](#152-flutter) selesai — [A-D1](#113-drift-kontrak-flutter--laravel) ditutup, dan resolusi yang direkomendasikan Fase 1 ternyata setengah salah.** Rekomendasi audit adalah "(a) UI naikkan ke 500 & gabungkan permintaan semua kamar jadi satu string berlabel". Bagian "gabungkan berlabel" tepat dan dijalankan; bagian "naikkan ke 500" **justru akan memperburuk**, karena 500 itu plafon **seluruh booking**, bukan per kamar — dua tipe kamar yang masing-masing diberi 500 menghasilkan 422 yang membuang satu booking utuh. Yang dibangun: `SpecialRequestDraft.noteBudget()` menghitung sisa anggaran nyata dan menyuapinya ke `maxLength`, sehingga counter membaca sisa sebenarnya (`0/111`) dan 200 bertahan hanya sebagai batas atas sesuai mockup. Dua jebakan yang muncul saat membangun, dua-duanya ketemu dari membaca kontrak widget-nya lebih dulu: (1) `TextField(maxLength: 0)` **dan** `LengthLimitingTextInputFormatter(0)` sama-sama `assert maxLength > 0`, jadi meneruskan anggaran mentah akan meng-*crash* sheet tepat saat booking paling penuh → pada anggaran 0 field **diganti** panel penjelas (T-F41); (2) mockup tak punya baris "tidak ada preferensi", jadi radio harus bisa **toggle off** atau satu salah-tap jadi permanen (T-F37). Serialisasi memancarkan **urutan katalog, bukan urutan tap**, dan melewati titik penutup bila teks sudah bertitik — dua aturan yang lahir semata-mata karena dua contoh terbit di §12.6/§12.7 diasersi **literal**. Mengikuti pelajaran [F-13](#152-flutter), `SpecialRequestSheet`/`SpecialRequestSection` dibuat **publik** (semua sheet hotel lain adalah closure di dalam layarnya dan tak satu pun terjangkau test). |
| 2026-08-16 | **Test F-4: 20 unit + 9 widget (T-F3, T-F36…T-F44).** File baru `models/special_request_test.dart` (**20**); `hotel_screens_test.dart` 19 → **28**. Total suite Flutter **139 → 168 deklarasi / 17 → 18 file**. Test pembeda kuncinya adalah dua asersi **literal** terhadap string yang sudah diterbitkan dokumen (§12.6 & §12.7) — itu yang memaksa urutan katalog & aturan titik penutup; ditambah T-F40 yang menuntut counter membaca **`0/111`** dan `0/200` **tidak ada** di tree (implementasi ber-200-flat akan hijau tanpa asersi negatif itu), serta satu test unit yang menulis catatan **tepat sepanjang** `noteBudget()` lalu membuktikan hasil gabungan ≤500 **dan** tidak terpotong. Sisi Laravel tidak berubah: `special_requests` sudah `nullable|string|max:500` sejak [L-1](#151-laravel), dan tidak ada migrasi — opsi (b) `booking_rooms.special_requests` tetap tidak diambil. |
| 2026-08-16 | **[F-5](#152-flutter) selesai — dan pekerjaan sebenarnya adalah menemukan bahwa mockup #36 tak punya sumber data.** Rekomendasi [A-D3](#113-drift-kontrak-flutter--laravel) ("batasi UI ke 1 voucher/booking") dijalankan apa adanya, jadi C-33 jadi **satu baris untuk seluruh booking**, bukan per tipe kamar seperti #31. Yang tak tertulis di dokumen dan hanya muncul setelah `VoucherController` dibaca: **[A-D14](#113-drift-kontrak-flutter--laravel)** — `GET vouchers` mengembalikan **model mentah** tanpa `is_eligible`/`ineligible_reason`, kolom `subtitle` **tidak ada** di tabel, dan `index()` sudah memfilter "valid saat ini" sehingga **mustahil** ada kartu kedaluwarsa untuk di-dim. Tiga kartu dimmed + `(0 Tersedia)` di mockup karena itu dibangun dari satu-satunya oracle yang benar-benar ada: kartu **mulai** bisa ditawarkan, `POST vouchers/apply` yang men-dim-nya, dan header menghitung yang belum ditolak — jadi `(0 Tersedia)` tercapai lewat penolakan nyata, bukan angka yang ditebak. §12.5 kini menandai payload lamanya **aspirasional** dan menerbitkan bentuk nyatanya. Dua jebakan kontrak lain ikut dipatok: endpoint ini menamai field **`code`** (hanya `POST bookings` memakai `voucher_code`) dan galatnya muncul di `errors.code`; serta **cashback berhasil tanpa mengurangi apa pun** (`[0.0, $voucher, null]`), sehingga nol tidak boleh dibaca sebagai penolakan dan baris promo menulis "Cashback … setelah menginap" alih-alih `- Rp 0`. **Satu bug yang justru akan dibuat F-5 kalau tidak diperiksa:** `_estimatedTripCoins` menghitung koin dari subtotal, padahal server memakai `round($total * 0.005)` **setelah** diskon — dialihkan ke `_dueTotal`. **[A-D15](#113-drift-kontrak-flutter--laravel)** ditemukan dan **sengaja tidak ditambal**: jendela masa berlaku dirender dalam UTC karena `.toLocal()` tidak dipakai **di mana pun** di `flutter/lib` (grep: 0 hasil) dan `config/app.php` ber-`timezone` `UTC`; menambalnya di satu layar akan menukar drift seragam dengan drift tak konsisten — perbaikannya satu keputusan tingkat aplikasi. Tidak ada perubahan Laravel. |
| 2026-08-16 | **Test F-5: 28 test (T-F45…T-F58), suite Flutter 168 → 196 deklarasi / 18 → 20 file.** Dua file baru — `models/promo_voucher_test.dart` (**15**) & `services/voucher_service_test.dart` (**6**) — plus `hotel_screens_test.dart` 28 → **35**, dan satu helper `test/support/fake_voucher_api.dart` (0 test) yang **dibagi** dua file itu alih-alih disalin ([A-D13](#113-drift-kontrak-flutter--laravel) diterapkan sebagai kode). Test pembedanya **T-F55**: fake menjawab diskon `44663` yang sengaja **bukan** 10% dari 500.000, jadi implementasi yang menghitung ulang dari `value` akan merah — fake yang "jujur" akan menghijaukan implementasi benar **dan** salah. Prinsip sama di **T-F54** (`opacity == 0.6` pada `Opacity` **induk teks alasan**, bukan "ada `Opacity` di tree") dan **T-F58** (kalimat koin pra-diskon diasersi **hilang**; tanpa asersi negatif itu, koin yang dihitung dari subtotal tetap hijau). `HotelBookingScreen` kini menerima `VoucherService` lewat konstruktor — tanpa itu T-F58 mustahil, persis pelajaran [F-13](#152-flutter). Sisi Laravel nol tambahan: kontrak voucher sudah dipatok T-L18. |
| 2026-08-16 | **Sinkronisasi [docs/flutter/screens.md](../../flutter/screens.md) + hitung ulang ketiga kali — dan kali ini yang salah adalah *definisi* angkanya, bukan penjumlahannya.** Saat menyalin angka test ke `screens.md`, dua pola grep memberi dua jawaban berbeda (**196** vs 195). Penyebabnya: `api_envelope_test.dart:136` menulis `test(key, () async {` **di dalam** `for (final key in requests.keys)`, jadi satu deklarasi itu menghasilkan **65** test — satu per rute di tabel `DummyApiClient`. Pola yang mensyaratkan nama literal melewatkannya sama sekali. Konsekuensinya ada **dua angka** yang selama ini dicampur: **196 deklarasi** dan **260 test saat dijalankan** (196 − 1 + 65). Diverifikasi bahwa ini satu-satunya test ter-generate di seluruh suite: 13 loop lain di `flutter/test/` semuanya berada **di dalam** body test (asersi/pembangun data), bukan membungkus deklarasi. Hitung ulang penuh juga menemukan `special_request_test.dart` berisi **20** test bukan 19 — grup serialisasinya 10, bukan 9 — sehingga [F-4](#152-flutter) sesungguhnya **+29** dan rantainya **139 → 168 → 196**, bukan 139 → 167 → 195. Baseline 139 terbukti benar lewat 196 − 29 − 28 = 139. **Pelajarannya sejenis [A-D13](#113-drift-kontrak-flutter--laravel), tapi untuk angka:** menghitung deklarasi `test(` aman hanya selama tak ada test yang di-generate; begitu ada satu saja, "jumlah test" harus dinyatakan sebagai dua angka bernama — atau lebih baik lagi, dibaca dari output `flutter test`, yang belum bisa dijalankan di sini. `screens.md` sendiri disinkronkan: `hotel/ (6 file)`, `screens/` **47 file** (45 layar + 2 bottom sheet tanpa route), `models/` 26, `utils/` 2, tabel cakupan test diganti angka nyata + penunjuk ke [§15.3](#153-test--wajib-permintaan-eksplisit-pengguna) (satu sumber, bukan salinan kedua), dan **4 peringatan ⚠️ yang sudah beres** (A-D4, A-D5, A-D6, A-D7) dipindahkan ke daftar "sudah beres" agar tidak dibaca sebagai bug aktif — hanya catatan `top_modal_sheet` yang tetap ⚠️ karena [F-9](#152-flutter) masih terbuka. |
| 2026-08-16 | **[F-6](#152-flutter) selesai — dan yang tampak seperti satu bottom sheet dekoratif ternyata menutup drift data.** Mockup #33 hanya berisi satu kalimat, "Deposit tunai sebesar Rp100.000 diperlukan saat check-in", sehingga wajar dibaca sebagai teks statis. Setelah dilacak, angka itu **punya kolom sendiri di ujung ke ujung sisi server**: migrasi `2026_08_15_000001_add_hotel_ota_columns.php:34` (`decimal('deposit_amount', 12, 2)->default(0)`, komentar "Deposit tunai wajib saat check-in (Rp)"), `Hotel.php` fillable + cast `decimal:2`, dan `HotelApiTest.php:319` sudah **mengasersi** `deposit_amount == '100000.00'` — tepat angka mockup. Yang tidak ada justru sisi Flutter: model `Hotel` **tidak pernah mem-parse kolom itu**, jadi satu-satunya isi #33 tak punya jalan sampai ke layar. Ditambal lewat jalur yang sudah ada, bukan jalur baru: field `depositAmount` melewati `_toDouble()` tingkat-file yang lahir di [F-13](#152-flutter), karena `decimal:2` tiba sebagai String `"100000.00"` dan `as num?` akan diam-diam menghasilkan `null` ([A-D11](#113-drift-kontrak-flutter--laravel)). Tiga keputusan dicatat di kode: (1) **[A-D13](#113-drift-kontrak-flutter--laravel) diterapkan lagi** — `additionalInfoEntries(hotel)` adalah satu-satunya daftar, dan `(N)` di baris pemicu **diturunkan** dari `entries.length`, sehingga angka di baris dan isi sheet mustahil berselisih; bagian kosong dibuang agar hitungannya jujur (`Rp 0` bukan informasi). (2) Kata **"Total"** pada tangkapan ("Deposit tunai sebesar **Total** Rp100.000") **sengaja dibuang** — artefak alat desain yang membuat kalimatnya tak gramatikal; alasannya ditulis di komentar supaya tidak "diperbaiki" balik ke PNG. (3) Blok yang digantinya bukan placeholder: layar booking sebelumnya **menumpahkan** `policy.childPolicy` + `policy.extraBedPolicy` mentah sebagai teks polos di bawah kartu Trip Coins. Keduanya kini masuk sheet, itulah sebabnya mockup menunjukkan `(1)` sementara payload penuh jujur membaca `(3)` — bukan ketidaksesuaian. Mengikuti pelajaran [F-13](#152-flutter)/[F-4](#152-flutter), `AdditionalInfoSheet` & `AdditionalInfoSection` dibuat **publik** dan `additionalInfoEntries()` bisa diasersi tanpa mem-pump apa pun. Tidak ada perubahan Laravel — kontraknya sudah benar sejak semula. |
| 2026-08-16 | **Test F-6: 5 test (T-F59…T-F63), suite Flutter 196 → 201 deklarasi / 265 saat dijalankan — tanpa file test baru.** 1 unit ke `models/hotel_test.dart` (11 → **12**) dan 4 ke `widgets/hotel_screens_test.dart` (35 → **39**; kini 38 `testWidgets` + 1 `test` murni untuk fungsi turunannya). Test pembedanya **T-F63**: ia mengasersi kalimat deposit **tidak ada** di layar sebelum tautan disentuh lalu **ada** sesudahnya, **dan** bahwa `'Anak segala usia boleh menginap.'` tidak lagi tercetak inline — tanpa asersi negatif itu, tumpahan policy yang lama akan tetap hijau bersama sheet-nya. **T-F60** menguji fungsi turunannya langsung (deposit-saja → 1, policy-saja → 2, keduanya → 3, `'0.00'` + policy → 2, kosong → 0), jadi kejujuran `(N)` dipatok tanpa widget. **T-F59** memaku jebakan String `decimal:2` untuk kolom baru ini (`'100000.00'`, `100000`, `'0.00'`, absen, dan `'gratis'` → 0). Satu jebakan pumping ditemukan saat menulis T-F63: mem-pump layar kedua tanpa `key: ValueKey(hotel.id)` membuat Flutter **memperbarui elemen yang sama** alih-alih membangun state baru, jadi hotel deposit tak pernah benar-benar ter-render. |
| 2026-08-16 | **[F-7](#152-flutter) selesai — dan temuan terbesarnya membatalkan cara §3.3 mencacah layar: #34 dan #35 bukan dua layar, melainkan satu sheet dengan dua pil.** Rencana Fase 1 memperlakukan `room_detail_family_suite` dan `room_detail_kamar_superior` sebagai dua entri, dan HTML-nya memang dua file — tapi buktinya berlawanan dan tidak berupa tafsiran: 8 tangkapan JPEG-nya tersimpan di **satu** folder `bottom_screen_kamar_superior/` yang beranak `tab_family_suite/` + `tab_kamar_superior/`, dan `room_detail_kamar_superior.html:44-47` memuat baris pil berisi **kedua** nama kamar. Membangunnya sebagai dua widget akan menggandakan galeri, fasilitas, dan kebijakan lalu memaksa keduanya sinkron manual — kesalahan yang sama yang dihukum [A-D13](#113-drift-kontrak-flutter--laravel). Yang dibangun: satu `RoomDetailSheet` (C-39) + `showRoomDetailSheet()` + fungsi murni `distinctRoomTypes()`, dipicu dari **dua** tempat (kartu kamar #27 dan baris `Detail kamar` #31). **[A-D16](#113-drift-kontrak-flutter--laravel) — empat kolom yang sudah ada tapi tak pernah sampai ke layar, dan letak bugnya berbeda sisi.** `properties.cancellation_policy` punya migrasi sendiri sejak `2026_08_09_121257`, ada di `$fillable`, dan **di-seed pada 5 hotel** — tetapi `HotelApiController::show()` tak pernah memilihnya, jadi satu-satunya layar yang mencetak syarat refund tak punya apa pun untuk dicetak: bug **server**, diperbaiki di `select` + diratakan ke akar. Sementara `description` & `facilities` sudah menyeberang gratis lewat `$rt->toArray()` tapi tak pernah di-parse model, dan `images` di-map dengan `'$e'` sehingga URL-nya adalah literal `{url: …, caption: …}`: bug **klien**. Masing-masing ditambal di sisinya sendiri, bukan diakali di UI. **Yang sengaja tidak dibuat, masing-masing dengan kolom yang hilang dinamai:** timeline refund bertanggal (perlu `properties.cancellation_deadline_hours`; `cancellation_policy` adalah `string(255)` teks bebas, dan **mencetak tanggal tebakan di layar kebijakan refund adalah jenis kesalahan yang berakhir di sengketa pembayaran**), tabel biaya sarapan `Anak 5-17 th` Rp65.000 / `Dewasa` Buffet Rp108.900 (perlu `room_types.breakfast_fees` jsonb), gaya + jam sarapan (perlu `hotels.breakfast_style` + `breakfast_hours`), dan kurung "(Usia 0-5 tahun)" pada kebijakan anak. Yang **dipertahankan** sebagai konstanta hanya `Konfirmasi Langsung` + `Prabayar Online`, karena keduanya perilaku sistem yang terbukti: `storeHotelBooking()` memesan sekaligus mengurangi allotment dalam satu transaksi, dan setiap booking hotel dibayar di muka lewat Midtrans. Tiga anomali aset baru ikut tercatat: **[A-19](#4-log-anomali-aset--dokumentasi)** (`room_detail_family_suite.html` adalah **stub** — `<head>` lengkap, `<body>undefined</body>`, dan PNG-nya karena itu kosong), **[A-20](#4-log-anomali-aset--dokumentasi)** (dua JPEG yang dinamai §3.3 **tidak ada**; glob `**/detail_kamar*` → 0 hasil, sementara 8 tangkapan nyata empat tingkat lebih dalam tak pernah didaftarkan — dan nama folder induknya justru yang membuktikan sheet ini penuh-tinggi serta dibuka dari form booking), **[A-21](#4-log-anomali-aset--dokumentasi)** (§6 lama menjanjikan "CTA pilih" yang tidak ada di aset mana pun; menambahkannya akan melahirkan tombol pesan kedua yang bersaing dengan `Pesan kamar ini` #27 dan bilah bawah #31). |
| 2026-08-16 | **Test F-7: 8 Flutter (T-F64…T-F71) + 2 Laravel (T-L38/T-L39).** Flutter **201 → 209 deklarasi / 273 saat dijalankan**, tanpa file baru: 3 unit ke `models/hotel_test.dart` (12 → **15**) dan 5 widget ke `widgets/hotel_screens_test.dart` (39 → **44**). `HotelApiTest.php` 25 → **27**; total Fase 2 sisi Laravel **64**. Test pembedanya **T-F67** — ia menuntut nama kamar aktif muncul **3×** (pil + header + judul) dan yang non-aktif **1×**, lalu setelah pil ditap kedua hitungan itu bertukar: kalau #34/#35 benar-benar dua layar, test ini **tak mungkin ditulis**, karena tak ada pil untuk ditap. **T-L39** memaku sisi server dari klaim yang sama: `description`/`facilities`/`images`/`bed_configuration` menumpang gratis pada `$rt->toArray()`, jadi mempersempit `toArray()` itu ke daftar kolom nanti akan mengosongkan galeri, paragraf pembuka, dan seluruh grid `Fasilitas Kamar` **tanpa merahkan satu test pun**. **T-L38** menuntut key `cancellation_policy` **ada meski `null`** (`assertArrayHasKey` + `assertNull`), supaya "hotel tak menerbitkan syarat" tak bisa tertukar dengan "payload versi lama". Dua asersi negatif menjaga kejujuran seksi: **T-F69** menuntut `Fasilitas Kamar` **beserta tautannya** hilang untuk kamar tanpa fasilitas (kondisi **semua** kamar hasil seeder), dan **T-F70** menuntut kedua seksi chevron hilang untuk hotel tanpa kebijakan sementara badan kamar tetap ter-render. Jebakan pumping [F-6](#152-flutter) muncul lagi di **T-F68**: tiap `pumpSheet` diberi `ValueKey` berbeda, kalau tidak Flutter memperbarui elemen yang sama dan state sheet sebelumnya bertahan. |
| 2026-08-16 | **Belum dijalankan.** Seluruh angka test di atas adalah hasil pembacaan & penghitungan kode, **bukan** hasil eksekusi: `php artisan test`, `flutter test`, dan `flutter analyze` belum bisa dijalankan (shell terkunci sepanjang sesi-sesi ini — `Bash` maupun `PowerShell` ditolak classifier dengan "claude-opus-5 is temporarily unavailable"; gatenya per-pemanggilan, jadi layak dicoba lagi sewaktu-waktu). Sisi Laravel kini **tuntas** (L-1…L-9, termasuk [L-8](#151-laravel)); yang tersisa murni komponen UI Flutter yang belum dibangun: [F-9](#152-flutter), [F-10](#152-flutter), [F-12](#152-flutter). Urutan verifikasi yang disarankan begitu shell tersedia: `flutter analyze` → `flutter test` (tree paling banyak berubah di sini; mulai dari `--plain-name` tambahan [F-7](#152-flutter), lalu `models/hotel_test.dart` & `widgets/hotel_screens_test.dart`) → `php artisan test --filter=HotelApiTest` (15 test tambahan: 8 kartu `GET hotels` + 5 paritas `GET properties` + 2 kontrak sheet kamar, plus test bintang yang diperbaiki, [A-18](#4-log-anomali-aset--dokumentasi)) → `php artisan test --filter=HotelBookingTest` sebagai baseline regresi [L-1](#151-laravel) → `php artisan test --filter=PropertyControllerTest` (baseline regresi [L-9](#151-laravel) — endpoint `GET properties` ikut berubah) → 3 file Laravel baru → idealnya ulangi trio Laravel di `pgsql` agar T-L2 & T-L23 benar-benar menguji CHECK constraint dan lebar kolom. Verifikasi eksekusi wajib dilakukan sebelum modul ini dinyatakan selesai. |
