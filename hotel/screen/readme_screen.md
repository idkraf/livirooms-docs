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
| Anomali tercatat | **17** | A-01 … A-17 (A-11 … A-17 sudah beres) |
| Drift kontrak API tercatat | **11** | A-D1 … A-D11 (A-D11 ditemukan saat Fase 2, bukan Fase 1) |
| Endpoint API yang dipanggil Flutter tapi **tidak ada** di Laravel | **2** | `GET hotel/filters`, `POST hotel/bookings` |
| Test Flutter yang sudah ada | **17 file** | **6 sudah menyentuh Hotel/asuransi** (±31 test hotel + 4 asuransi) → [§15.3](#153-test--wajib-permintaan-eksplisit-pengguna) |
| Test Laravel hotel yang sudah ada | **7 file** | lihat [§15.3](#153-test--wajib-permintaan-eksplisit-pengguna) |

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
| 34 | `room_detail_family_suite` | `room_detail_family_suite.png` | `detail_kamar_family_suite.jpeg` | `detail_hotel (folder)` |
| 35 | `room_detail_kamar_superior` | `room_detail_kamar_superior.png` | `detail_kamar_superior.jpeg` | `detail_hotel (folder)` |
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

#### 34. `room_detail_family_suite` — Detail Kamar: Family Suite
Sheet/halaman detail satu tipe kamar: galeri, ukuran, tempat tidur (`2 queen bed`), kapasitas (`4 Dewasa`), fasilitas, kebijakan (`Tidak dapat di-refund`), sarapan berbayar `Rp108.900`, CTA pilih.

#### 35. `room_detail_kamar_superior` — Detail Kamar: Kamar Superior
Idem, dengan `1 queen bed atau 2 single bed`, `2 dewasa + 1 anak`, benefit `💜 Anak Menginap Gratis` (`#14B8A6`).

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
| C-22 | `RoomTypeAttributeList` | 27, 34, 35 | baris ikon 16px + teks 13px |
| C-23 | `GuestRoomFormBlock` | 28, 29, 30 | `Kamar N` + nama depan/belakang |
| C-24 | `OutlinedTextField` | 28, 30, 37 | state kosong / terisi(biru+✓) / error |
| C-25 | `PhoneFieldWithCountryCode` | 28, 30 | `+62` + divider + chevron |
| C-26 | `SavedGuestPickerChip` | 27, 28 | chip abu `Pilih tamu yang tersimpan` |
| C-27 | `PricePrepaidBottomBar` | 27–32 | label + total 20px/800 + tombol 100×44 |
| C-28 | `TealAssuranceBanner` | 27–32, 40 | `#e0f7fa` / `#00796b`, teks konfigurabel |
| C-29 | `TripCoinsSection` | 29, 31, 32, 40 | expandable |
| C-30 | `SpecialRequestSection` | 29, 31, 32 | trigger → C-31 |
| C-31 | `SpecialRequestSheet` | 37 | radio + checkbox + textarea 200 char |
| C-32 | `AdditionalInfoSheet` | 33 | read-only |
| C-33 | `PromoCodeSection` | 31 | **per tipe kamar** |
| C-34 | `PromoCodeSheet` | 36 | kartu voucher + state dimmed + alasan |
| C-35 | `VoucherCard` | 36 | `opacity:0.6` bila tidak eligible |
| C-36 | `TermsConsentBlock` | 32 | ganti "Trip.com" → "Sewain" |
| C-37 | `BookingStatusCard` | 38 | varian hotel vs unit |
| C-38 | `MaskedContactRow` | 40 | `62-0858****3846` |

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

### 11.3 Drift kontrak Flutter ↔ Laravel

| ID | Tingkat | Drift | Bukti | Perbaikan Fase 2 |
|---|---|---|---|---|
| **A-D1** | 🟠 | `bottom_sheet_permintaan` membatasi teks **200** karakter; Laravel memvalidasi `special_requests` **max:500**. Selain itu sheet ber-scope **per tipe kamar**, sedangkan API hanya punya **satu** string per booking. | HTML counter `0/200` vs `BookingController` | Pilih salah satu: (a) UI naikkan ke 500 & gabungkan permintaan semua kamar jadi satu string berlabel, atau (b) tambah kolom `booking_rooms.special_requests`. **Rekomendasi: (a)** — tanpa migrasi. |
| **A-D2** | 🟠 | Layar #3/#4 menghasilkan `children_ages[]`, tetapi field ini **tidak ada** di validasi `store()` → data umur anak hilang. | `BookingController::store()` validasi | Tambahkan `children_ages` (array of int) atau simpan di `special_requests`/kolom baru. Keputusan produk. |
| **A-D3** | 🟠 | Layar #31 menerapkan promo **per tipe kamar** (Kamar Superior `- Rp22.351` "Digunakan"; Family Suite belum). API hanya menerima **satu** `voucher_code` untuk seluruh booking. | `form_pesan_kamar_step2.html:46-52` vs validasi | Fase 2: batasi UI ke 1 voucher per booking, atau perluas API ke `vouchers[{room_type_id, code}]`. **Rekomendasi: batasi UI** — sesuai kemampuan `resolveDiscount()` sekarang. |
| **A-D4** | 🔴 | `GET hotel/filters` dipanggil `HotelService.getHotelFilters()` & ada di `dummy_api_client.dart`, tetapi **tidak ada route** → 404 di mode API nyata. | `routes/api_mobile.php` | Tambah route + controller, **atau** hapus pemanggilan & bangun opsi filter dari `meta` respons `GET hotels`. |
| **A-D5** | 🔴 | `POST hotel/bookings` dipanggil `HotelService.createHotelBooking()` & ada di dummy client, tetapi **tidak ada route**. Diperkuat oleh 2 test hijau yang **memaku** path salah ini (`hotel_service_test.dart`, `expectedPath: 'hotel/bookings'` — lihat [A-12](#4-log-anomali-aset--dokumentasi)). | idem | Arahkan Flutter ke `POST bookings` dengan `booking_type='room'`. **Jangan** buat endpoint kedua. Perbaikan ini **memecahkan** kedua test tersebut → perbarui `expectedPath` bersamaan ([§15.3](#153-test--wajib-permintaan-eksplisit-pengguna)). |
| **A-D6** | 🟠 | `HotelSearchProvider` memakai `PropertyService.searchHotels()` → `GET properties`, melewati `GET hotels` & `HotelService`; menyimpan `Paginated<Property>` bukan `Paginated<Hotel>` → field khusus hotel (skor, jumlah ulasan, jarak, tag) hilang. | `hotel_search_provider.dart` | Alihkan ke `HotelService.searchHotels()` → `GET hotels`, ubah tipe state ke `Paginated<Hotel>`. |
| **A-D7** | 🟠 | `HotelSearchQuery.fromUri` memanggil `int.tryParse(q['city_id']!)` — **null-assertion** akan throw bila `city_id` absen dari deep link `sewain://search?...`. | `hotel_search_query.dart` | Ganti ke `q['city_id'] != null ? int.tryParse(q['city_id']!) : null`. |
| **A-D8** | 🟡 | `GET hotels/{hotel}/room-types` ada di Laravel tapi tak pernah dipakai; #18 kemungkinan mengandalkan tipe kamar yang ter-embed di detail hotel. | grep Flutter | Verifikasi apakah `GET hotels/{hotel}` sudah menyertakan `room_types`; kalau ya, tandai endpoint ini sebagai cadangan. |
| **A-D9** | 🔴 | **TERVERIFIKASI 16 Agt 2026.** `PropertyController::index()` menerima **tepat 4** nilai: `in:newest,price_asc,price_desc,rating` ([baris 42](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Http/Controllers/Api/PropertyController.php), `match` baris 179–185). Konsekuensinya: (a) opsi UI **"Jarak terdekat" tidak punya implementasi server** sama sekali — `lat`/`lng` diterima tapi tak ada cabang sorting jarak; (b) `docs/hotel/03-query-filters.md` baris 42 menuliskan `popularity` yang **ditolak 422** oleh controller nyata; (c) "Rekomendasi" hanya memetakan ke `newest` (`latest()`), bukan peringkat rekomendasi. | `PropertyController.php:42,179-185` | Pemetaan final: Rekomendasi→`newest`/kosong · Harga terendah→`price_asc` · Rating tertinggi→`rating`. Untuk "Jarak terdekat": tambah cabang `distance` (haversine dari `lat`/`lng`) **atau** sembunyikan opsinya — jangan tampilkan tombol yang tak berefek. Kamus lengkap: [03 §1.1](../03-query-filters.md#11-kamus-nilai-sort--ui--server-terverifikasi). |
| **A-D10** | 🟡 | Field `contact_phone` divalidasi **max:25** di controller, sedangkan kolom migrasi bergaya 20 char. | `BookingController` validasi | Selaraskan validasi ke lebar kolom, atau lebarkan kolom. Jangan biarkan berbeda — PostgreSQL akan menolak >20 walau validasi lolos. |
| **A-D11** | 🔴 | **DITEMUKAN 16 Agt 2026 saat mengerjakan [F-8](#152-flutter).** `GET hotels` dan `GET hotels/{hotel}` **tidak pernah memancarkan** `price_per_night`, `price_original`, maupun `total_price` — ketiganya bukan kolom `hotels` dan tak ada satu pun yang dihitung di controller. `index()` mengembalikan model `Hotel` mentah (`ApiResponse::paginated($hotels, …)`), `show()` mengembalikan `$hotel->toArray()` + field properti; harga hanya ada di dalam `active_room_types[].base_price`. Akibatnya `Hotel.pricePerNight`/`totalPrice` = **0.0** dan `priceOriginal` = **null** di API nyata, sehingga **setiap kartu hasil pencarian menampilkan `Rp 0` dan `Total harga: Rp 0`**. Tertutup selama ini karena fixture dummy `GET_hotels.json` memuat ketiga kunci itu, sedangkan API nyata tidak. Kolateral dari akar yang sama: `review_count` selalu 0 dan `score_label` selalu jatuh ke default `'Luar Biasa'` (`hotels` tak punya kedua kolom itu, dan hotel **tidak** dibungkus `PropertyResource`). | [`HotelApiController.php:123-125`](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L123-L125) (index) · [`:167-183`](../../../laravel/app/Http/Controllers/Api/HotelApiController.php#L167-L183) (show) · casts [`Hotel.php:34-44`](../../../laravel/app/Models/Hotel.php#L34-L44) — tanpa kolom harga · konsumen: [`hotel_results_screen.dart:1071-1087`](../../../flutter/lib/screens/property/hotel/hotel_results_screen.dart#L1071-L1087) | Server-side lebih tepat daripada tambal di klien: `index()` sudah punya `withMin('activeRoomTypes as min_price', 'base_price')` untuk sort harga — jadikan **selalu** dieager-load dan pancarkan sebagai `price_from` (nama yang sudah dibaca `Hotel.fromJson`), plus `total_price` = `price_from × nights × rooms_count` bila `check_in`/`check_out` ada di query. Sementara itu layar detail sudah aman lewat `_nightlyFrom()` (fallback ke tipe kamar termurah yang bookable); kartu hasil pencarian **belum** → dilacak sebagai [F-13](#152-flutter). |

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

**Bentuk daftar voucher untuk UI** (kartu dimmed + alasan):

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

| Kekurangan | Layar |
|---|---|
| Sheet kode promo | #36 |
| Sheet permintaan khusus | #37 |
| Sheet informasi tambahan | #33 |
| Sheet detail kamar (Family Suite / Kamar Superior) | #34, #35 |
| Ringkasan kamar masih hardcode via `_roomSummary(...)` | #27 |
| Seksi Trip Coins expandable | #29, #31, #32 |

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
> **Status per 16 Agt 2026:** seluruh item Laravel kecuali L-8 dan tiga item Flutter prioritas tinggi (F-1…F-3) **sudah dikerjakan**. Kolom *Status* di bawah adalah catatan hasil verifikasi ulang terhadap kode, bukan rencana.

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
| **L-8** | 🟡 Hapus `tests/Feature/Admin/ProbeTest.php` (diagnostik sementara, sudah ditandai untuk dihapus di `laravel/CLAUDE.md`). | Rendah | ⏳ **tertunda** — isi file sudah diverifikasi sebagai diagnostik buangan (berakhir `assertTrue(true)`), tapi penghapusan butuh shell. |

### 15.2 Flutter

| ID | Item | Prioritas | Status |
|---|---|---|---|
| **F-1** | 🔴 Alihkan `HotelSearchProvider` ke `HotelService.searchHotels()` / `GET hotels`, ubah state ke `Paginated<Hotel>` ([A-D6](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — dan ternyata bukan sekadar rapi-rapi: `PropertyService.searchHotels()` mengirim `sort=score_desc` ke `GET properties` yang aturannya `in:newest,price_asc,price_desc,rating`, jadi **setiap** pencarian lewat provider dijawab 422. Metode itu dihapus; provider kini punya `loadMore()` ber-token anti-balapan. |
| **F-2** | 🔴 Perbaiki null-assertion `city_id` di `HotelSearchQuery.fromUri` ([A-D7](#113-drift-kontrak-flutter--laravel)). | Tinggi | ✅ **selesai** — `int.tryParse(q['city_id'] ?? '')`. Sekalian ditemukan asimetri serializer↔parser: `toQueryParams()` memancarkan `star_rating[0]` tapi `fromUri` hanya membaca CSV, jadi URI buatan kelas ini sendiri kehilangan filter bintang saat dibaca ulang. `_parseStarRatings()` sekarang menerima kedua bentuk. `originLat`/`originLng` ikut di-round-trip. |
| **F-3** | 🔴 Kirim `booking_type: "room"` eksplisit dari layar hotel. | Tinggi | ✅ **selesai** — `booking_type: 'room'` + `duration_type: 'daily'` dikirim eksplisit, tidak lagi menggantungkan diri pada inferensi server. |
| **F-4** | 🟠 Bangun C-31 `SpecialRequestSheet` (#37) + serialisasi ke `special_requests`. | Sedang | ⏳ belum |
| **F-5** | 🟠 Bangun C-34 `PromoCodeSheet` (#36) + batasi 1 voucher/booking ([A-D3](#113-drift-kontrak-flutter--laravel)). | Sedang | ⏳ belum |
| **F-6** | 🟠 Bangun C-32 `AdditionalInfoSheet` (#33). | Sedang | ⏳ belum |
| **F-7** | 🟠 Bangun sheet detail kamar #34/#35. | Sedang | ⏳ belum |
| **F-8** | 🟠 Ganti `_roomSummary(...)` hardcode dengan data asli `room_types`. | Sedang | ✅ **selesai** — dan ternyata akarnya struktural, bukan kosmetik: layar booking tak bisa diperbaiki sendirian karena query pencarian **juga** tidak pernah masuk ke layar detail. Dibuat rantai `HotelDetailArgs` → `HotelBookingArgs` (+ `HotelRoomSelection`) dengan `HotelSearchQuery.defaultStay()` sebagai satu-satunya fallback. Sekalian ditemukan 3 bug lain: (a) kartu hotel di hasil pencarian membuka `Routes.propertyDetail` sehingga **seluruh layar detail hotel tak terjangkau dari mana pun** ([A-15](#4-log-anomali-aset--dokumentasi)); (b) `HotelRoomItem.fromJson` membaca `base_price` dengan `as num?` padahal cast `decimal:2` mengirim **string**, jadi tiap tipe kamar berbentuk-DB dihargai **Rp 0** ([A-16](#4-log-anomali-aset--dokumentasi)); (c) pil tanggal di hasil pencarian memakai `substring(5)` → tampil `08-28`, bukan `28 Agt` ([A-17](#4-log-anomali-aset--dokumentasi)). |
| **F-9** | 🟠 Bangun C-11 `AppTopModalShell` manual (#12–#16) — paket tidak ada ([A-08](#4-log-anomali-aset--dokumentasi)). | Sedang | ⏳ belum |
| **F-10** | 🟡 Bangun C-29 `TripCoinsSection` expandable. | Rendah | ⏳ belum |
| **F-11** | 🟡 Ganti "Trip.com" → "Sewain" pada teks S&K ([A-10](#4-log-anomali-aset--dokumentasi)). | Rendah | ✅ **selesai** — teks persetujuan promo kini "promo spesial **Sewain**". `Trip Coins` **sengaja dipertahankan**: itu nama kolom ledger `bookings.trip_coins_earned`, bukan merek pihak ketiga ([A-10](#4-log-anomali-aset--dokumentasi)). |
| **F-12** | 🟡 Bedakan kartu `booking_type` room vs unit di #38. | Rendah | ⏳ belum |
| **F-13** | 🔴 Kartu hasil pencarian menampilkan `Rp 0` di API nyata — `GET hotels` tak memancarkan `price_per_night`/`total_price`/`price_original` ([A-D11](#113-drift-kontrak-flutter--laravel)). | Tinggi | ⏳ **belum** — item **baru**, lahir saat [F-8](#152-flutter). Perbaikan utamanya **di Laravel** (pancarkan `price_from` + `total_price` dari `HotelApiController::index()`), bukan di Flutter; jangan tambal dengan menghitung ulang di klien karena filter harga & sort sudah dihitung server. Layar detail sudah kebal lewat `_nightlyFrom()`. |

### 15.3 Test — **wajib** (permintaan eksplisit pengguna)

**Laravel — sudah ada sebelum Fase 2 (7 file):**
`tests/Feature/Api/HotelApiTest.php` · `HotelBookingTest.php` · `HostHotelTest.php` · `tests/Feature/Jobs/ExtendHotelInventoriesJobTest.php` · `CancelExpiredBookingsJobTest.php` · `tests/Unit/Model/RoomTypeObserverTest.php` · `tests/Feature/Livewire/HotelWizardFormTest.php`

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

> ⚠️ **Batas SQLite.** Suite berjalan di **SQLite in-memory** yang **tidak** menegakkan CHECK constraint maupun lebar kolom. Karena itu T-L2 memeriksa **guard tingkat aplikasi** (422 sebelum tulis), bukan constraint `booked_count <= allotment` milik DB; dan T-L23 di SQLite hanya membuktikan aturan validasi menyala. Jalankan ketiga file di `pgsql` untuk menguji batas yang sebenarnya.
>
> Dua keputusan desain lain yang menjaga hasil tetap sama di kedua engine: ekspresi jarak `orderByDistance()` sengaja hanya memakai `+ − ×` (tanpa `radians()`/`acos()`), dan fixture `hotels.score` memakai satu kunci satu digit karena `Hotel::$casts['score'] = 'array'` membuat `orderByDesc('score')` membandingkan jsonb/teks — bukan angka. `HotelSearchSortTest` juga sengaja **tidak** mengirim `q` atau `city_name` yang memakai `ilike` (PostgreSQL-only).

**Flutter — `flutter/test/` berisi 17 file, 117 test; 6 file menyentuh Hotel/asuransi.** Jangan tulis ulang yang sudah ada.

| File | Isi | Δ Fase 2 |
|---|---|---|
| [`models/hotel_search_query_test.dart`](../../../flutter/test/models/hotel_search_query_test.dart) | **11** test — query params default, deep link `sewain://search`, deep link **tanpa `city_id`**, deep link kosong → besok/besok-lusa, round-trip `star_rating[n]`, nilai ganda/tak terbaca dibuang, grup `sort: distance` (4 test), `sort` tak dikenal → `score_desc` | +9 (dari 2) |
| [`providers/hotel_search_provider_test.dart`](../../../flutter/test/providers/hotel_search_provider_test.dart) | **6** test — initial state, search memuat hotel, meta paginasi ikut terbawa, search gagal → error state & list tetap kosong, `loadMore` no-op di halaman terakhir, respons basi dibuang | +4 (dari 2) |
| [`services/hotel_service_test.dart`](../../../flutter/test/services/hotel_service_test.dart) | **10** test — `searchHotels` ×3 (parsing, **`GET hotels` bukan `GET properties`**, meta), `getHotelDetail`, `getRoomTypes`, `getInsurancePlans`, `createHotelBooking` ×2, `createHotelForProperty` ×2 | +2 (dari 8) |
| [`api_envelope_test.dart`](../../../flutter/test/api_envelope_test.dart) | **23** test — 2 guard paritas route, envelope tiap route, aset fixture, 8 jalur galat, grup **"hotel bookings ride on POST bookings"** (3 test), parsing envelope, bentuk home feed | +3 |
| [`models/hotel_test.dart`](../../../flutter/test/models/hotel_test.dart) | **9** test — `Hotel` minimal & lengkap (metadata 8 tab), `HotelRoomItem` default, **harga `decimal:2` berbentuk string** (T-F28), `occupancyLabel` (T-F29), `cheapestBookableRoom` (T-F30), `HotelPolicy` default, `HotelGuestInput.toJson()`, `HotelFacilityGroup` kosong | +3 (dari 6) |
| [`widgets/hotel_screens_test.dart`](../../../flutter/test/widgets/hotel_screens_test.dart) | **15** `testWidgets` — bukan lagi render-level saja: pil tanggal hasil pencarian (T-F19), kartu rekomendasi dihargai dari query (T-F20), tipe kamar penuh ditolak (T-F21), tanggal & jam booking dari query (T-F22), 1 form tamu per kamar (T-F23), total + Trip Coins (T-F24), branding Sewain (T-F25), fallback kamar termurah-bookable (T-F26), hotel tanpa kamar menolak submit (T-F27), + 4 test `HotelFormScreen` mitra & 2 render dasar | +7 (dari 8) |
| [`utils/formatters_test.dart`](../../../flutter/test/utils/formatters_test.dart) | **16** test — label metode/status pembayaran, `dateTime`, `rupiah`, **+ helper tanggal pendek `dayMonthShort`/`weekdayDayMonthShort` + varian iso + `hourMinute`** (T-F31) | +6 (dari 10) |
| `models/insurance_plan_test.dart` | 4 test — premi fixed per malam (1 & banyak tamu), premi persentase, parsing JSON | — |

> 🟡 `services/hotel_service_test.dart` juga membuktikan `getRoomTypes` mendelegasikan ke `getHotelDetail` — itulah sebab endpoint `GET hotels/{hotel}/room-types` tak pernah terpanggil ([A-D8](#113-drift-kontrak-flutter--laravel)).

Status tiap item yang direncanakan:

| ID | Test | Jenis | Status |
|---|---|---|---|
| T-F1 | `HotelSearchQuery.fromUri` tanpa `city_id` tidak throw | unit | ✅ **BERES** — `a deep link without city_id parses instead of throwing` + `an empty deep link falls back to tomorrow/day-after`. Perbaikan [F-2](#152-flutter) membuang `q['city_id']!` ([A-D7](#113-drift-kontrak-flutter--laravel)) |
| T-F2 | `toQueryParameters()` menghasilkan [§12.2](#122-query-pencarian--layar-16-716) | unit | ✅ **BERES** — ditambah round-trip `star_rating[n]` (asimetri `toQueryParams` ↔ `fromUri`) dan `sort` tak dikenal → `score_desc` |
| T-F3 | serialisasi permintaan khusus → satu string ≤500 char | unit | ❌ belum — sheet #37 ([F-4](#152-flutter)) belum dibuat |
| T-F4 | body `POST bookings` sama persis dengan [§12.3](#123-post-bookings--form-pengisian-kamar-multi-kamar) | unit | ✅ **BERES** — kedua test kini `expectedPath: 'bookings'`; `_CapturingTransport` juga merekam `capturedPath` tanpa syarat, jadi endpoint diuji langsung, bukan disimpulkan dari `capturedBody != null`. Body diasersi termasuk `booking_type: 'room'` + `duration_type: 'daily'`, dan `children_ages` kosong **tidak** dikirim |
| T-F5 | parsing respons 201 → `Booking` + `BookingRoom[]` | unit | ❌ belum — `models/booking_test.dart` (3 test) tidak menyentuh `BookingRoom`, `trip_coins_earned`, maupun asuransi |
| T-F6 | parsing envelope galat 422 → pesan field | unit | ✅ ada — `api_envelope_test.dart` (generik, cukup) |
| T-F7 | `RoomGuestStepperSheet` stepper naik/turun + batas minimum | widget | ❌ belum ([F-5](#152-flutter)) |
| T-F8 | `ChildAgePickerSheet` memilih umur → memperbarui baris induk | widget | ❌ belum ([F-5](#152-flutter)) |
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

**Item test tambahan yang lahir dari [F-8](#152-flutter) & [F-11](#152-flutter)** (tidak ada di rencana Fase 1 — masing-masing memaku satu bug nyata, bukan sekadar menaikkan cakupan):

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

> 🟡 **Mengapa formatter ditulis tangan, bukan `DateFormat(..., 'id_ID')`:** dua alasan yang keduanya terbukti dari kode — (1) `DateFormat` dengan locale non-default **throw** kecuali `initializeDateFormatting()` sudah jalan, dan itu hanya dipanggil di `main.dart:13` yang **tidak pernah** dieksekusi widget test; (2) intl menyingkat Agustus jadi `Agu`, sedangkan seluruh mockup hotel menulis `Agt`. `NumberFormat` (dipakai `Formatters.rupiah`) tidak butuh inisialisasi, jadi uang tetap lewat intl.

**Ringkas:** dari 18 item rencana, **5 tertutup di Fase 2** (T-F1, T-F2, T-F4, T-F18 — plus T-F6 yang sudah ada), **2 sebagian** (T-F14, T-F15), sisanya **11 net-new** dan menunggu komponen [F-4…F-12](#152-flutter) dibuat lebih dulu — sebuah widget test tak bisa mendahului widget-nya. Di luar rencana itu, **13 item baru (T-F19…T-F31) ditulis dan ditutup** karena [F-8](#152-flutter)/[F-11](#152-flutter) menyingkap bug yang tak terbayangkan saat Fase 1. Total suite Flutter: **117 → 133 test**, tetap **17 file** (+3 `hotel_test.dart`, +7 `hotel_screens_test.dart`, +6 `formatters_test.dart`).

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
| 2026-08-16 | **Belum dijalankan.** Seluruh angka test di atas adalah hasil pembacaan kode, **bukan** hasil eksekusi: `php artisan test`, `flutter test`, dan `flutter analyze` belum bisa dijalankan (shell terkunci sepanjang sesi-sesi ini). Tersisa juga [L-8](#151-laravel) (hapus `tests/Feature/Admin/ProbeTest.php` — butuh shell, `Write`/`Edit` tak bisa menghapus file) dan komponen [F-4](#152-flutter)…[F-7](#152-flutter), [F-9](#152-flutter), [F-10](#152-flutter), [F-12](#152-flutter), [F-13](#152-flutter). Urutan verifikasi yang disarankan begitu shell tersedia: `flutter analyze` → `flutter test` (tree paling banyak berubah di sini) → `php artisan test --filter=HotelBookingTest` sebagai baseline regresi L-1 → 3 file Laravel baru → idealnya ulangi trio Laravel di `pgsql` agar T-L2 & T-L23 benar-benar menguji CHECK constraint dan lebar kolom. Verifikasi eksekusi wajib dilakukan sebelum modul ini dinyatakan selesai. |
