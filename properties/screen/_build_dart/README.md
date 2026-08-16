# `_build_dart` — implementasi Flutter dari mockup Property Detail & Rincian Unit

Folder ini berisi **hasil terjemahan 24 mockup** (`docs/properties/screen/property_detail_screen/` dan
`docs/properties/screen/rincian_unit_screen/`) menjadi kode Flutter yang siap dipindahkan ke
`flutter/lib/`. Semuanya UI + model presentasi — belum ada pemanggilan API.

Sifat folder ini:

- **Nol dependensi tambahan.** Hanya `package:flutter`. Tidak memakai `intl`,
  `cached_network_image`, `google_maps_flutter`, `share_plus`, `url_launcher`, `provider`, atau `http`
  (lihat [Asumsi & divergensi](#asumsi--divergensi-yang-perlu-dikonfirmasi)).
- **Self-contained.** Token warna/tipografi sendiri (`theme/detail_tokens.dart`), formatter sendiri
  (`utils/fmt.dart`), fixture sendiri (`models/sample_data.dart`) yang mereproduksi angka & teks
  mockup persis.
- **Semua efek samping lewat callback.** Screen tidak pernah memanggil navigator/route aplikasi,
  API, atau plugin; host yang memutuskan (`onSelectUnit`, `onShare`, `onOpenMap`, `onSubmit`, dst.).

---

## 1. Cara memakai

```dart
import 'package:flutter/material.dart';

import 'models/sample_data.dart';
import 'models/unit_pricing.dart';
import 'property_detail_screen.dart';
import 'rincian_unit_screen.dart';

void openDetail(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => PropertyDetailScreen(
      detail: SampleData.detailWithReviews,   // atau SampleData.detail (tanpa ulasan)
      onSelectUnit: () => openRincian(context),
      onShare: () {/* share_plus / Share.share(...) */},
      onOpenMap: () {/* url_launcher ke Google Maps */},
      onContactHost: () {/* buka chat */},
      onFavoriteChanged: (isFavorite) {/* PATCH /favorites */},
    ),
  ));
}

void openRincian(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => RincianUnitScreen(
      initialPeriod: RentalPeriod.daily,
      pricing: {
        RentalPeriod.daily: SampleData.dailyPricing,
        RentalPeriod.monthly: SampleData.monthlyPricing,
        RentalPeriod.yearly: SampleData.yearlyPricing,
      },
      onPeriodChanged: (period) {/* refetch harga periode ini */},
      onEditDates: () {/* showDateRangePicker */},
      onBrowsePromos: (ctx) async => null,   // kembalikan AppliedPromo? dari halaman promo
      onSubmit: (draft) {/* POST /bookings */},
    ),
  ));
}
```

Data nyata: `PropertyDetail.fromJson` dan `UnitPricing.fromJson` sudah tersedia di
`models/`, jadi cukup ganti `SampleData.*` dengan hasil parse response API.

`onSubmit` menerima `BookingDraft` — periode, durasi, tanggal, `addOnIds`, `planId`, `promoCode`,
dan `payableAmount` (nilai yang tampil di baris penutup `Ringkasan`).

---

## 2. Peta mockup → kode

### 2.1 `property_detail_screen/` (15 gambar)

Mockup 2–7 **bukan tab terpisah** — semuanya satu halaman yang di-scroll. Lihat
[§3 Arsitektur](#3-arsitektur-yang-perlu-diketahui).

| Mockup | Diwujudkan oleh |
|---|---|
| `property_detail_screen_1.jpg` | `PropertyDetailScreen` pada offset 0 → `DetailGalleryHeader` + `DetailOverviewBlock` + `DetailActionRow`. Strip navigasi belum terlihat (masih di bawah lipatan) |
| `..._1_with_reviews.jpeg` | idem + `ReviewSummaryCard` — muncul hanya bila `detail.hasReviews` |
| `..._1_bottom_sheet_diskusi.jpeg` | `sheets/qna_sheet.dart` → `QnaSheet` (route layar penuh, AppBar merah) |
| `..._1_bottom_sheet_ulasan.jpeg` | `sheets/reviews_sheet.dart` → `ReviewsSheet` (+ `ReviewTile`) |
| `..._2_tab_facilities.jpg` | `SectionTabStrip` ter-pin (indeks `Facilities`) + `FacilitiesSection` / `FacilityTileGrid` |
| `..._2_..._bottom_sheet_fasilitas_gedung.jpeg` | `sheets/building_facilities_sheet.dart` |
| `..._2_..._bottom_sheet_fruniture_ruangan.jpeg` | `sheets/room_furniture_sheet.dart` |
| `..._3_tab_info_tab_check_in_info.jpg` | `InfoSection` segmen 1 → `InfoNotePanel` + `InfoNoteRow` |
| `..._3_tab_info_tab_deposit.jpeg` | `InfoSection` segmen 2 → `DepositPanel` |
| `..._3_tab_info_tab_unit_detail.jpeg` | `InfoSection` segmen 3 → `UnitDetailPanel` |
| `..._4_tab_details.jpg` | `IntroCard` (`Pengantar`) — anchor `Details` |
| `..._5_tab_location.jpg` | `LocationSection` + `NearbyGrid` — anchor `Location` |
| `..._6.jpg` | `DescriptionCard` + `GuestMediaSection` |
| `..._6_show_bottom_sheet_descripton.jpeg` | `sheets/description_sheet.dart` (satu-satunya yang benar-benar `showModalBottomSheet`) |
| `..._7.jpg` | `BuildingUnitsCard` + `StickyPriceBar` (bottom bar `PILIH UNIT`) |

### 2.2 `rincian_unit_screen/` (9 gambar)

Semuanya satu screen: `rincian_unit_screen.dart` → `RincianUnitScreen`, tiga segmen
(`Harian` / `Bulanan` / `Tahunan`).

| Mockup | Diwujudkan oleh |
|---|---|
| `tab_harian_1.jpg` | segmen `daily`, bagian atas → `PeriodSelector` + `UnitStayCard` + `InclusionTable` |
| `tab_harian_2.jpg` | segmen `daily`, bagian bawah → `SpecialPriceList` + `AddOnSelector` + `PriceSummaryCard` + `PromoRow` (promo terpasang) + tombol `PESAN` |
| `tab_bulanan_1.jpg` | segmen `monthly` — `UnitStayCard` menambah baris `Bulan` berikut chevron |
| `tab_bulanan_2.jpg` | segmen `monthly`, bagian bawah (add-on `Linen`, `Dust Mite` tanpa harga) |
| `tab_tahunan_default.jpg` | segmen `yearly`, rencana default `Bayar Penuh` → `PaymentPlanField`; `InstallmentSchedule` menyusut (tidak ada `entries`) |
| `tab_tahunan_filter.jpg` | segmen `yearly` dengan rencana cicilan → `PaymentPlanField` + `InstallmentSchedule` |
| `tab_tahunan_filter_1.jpg` | `InstallmentSchedule` terbuka: tabel tanggal/nominal + `Total` + catatan merah |
| `tab_tahunan_filter_2.jpg` | `Ringkasan` mode cicilan (`Bayar Sekarang`) + `PromoRow` kosong (`Gunakan Kupon`) + toggle `tampilkan selengkapnya` di bawah kartu inklusi |
| `tab_tahunan_filter_show_select_screen_cicilan.jpg` | `sheets/payment_plan_sheet.dart` → `PaymentPlanSheet` (6 opsi, kartu terpilih merah solid) |

---

## 3. Arsitektur yang perlu diketahui

### 3.1 `Facilities | Info | Details | Location` adalah *scroll-spy*, bukan `TabBar`

Bukti dari mockup: saat `Details` aktif, di bawahnya terlihat `Pengantar` **dan** `Peta Lokasi`;
saat `Location` aktif, terlihat `Peta Lokasi` **dan** `Deskripsi`. Konten tidak pernah ditukar —
halaman hanya melompat ke posisi tertentu. Karena itu:

- `property_detail_screen.dart` memakai `CustomScrollView` + `SliverAppBar(pinned)` +
  `SliverPersistentHeader(pinned)` (`SectionTabStripDelegate`), dengan empat `GlobalKey`
  sebagai anchor.
- Offset anchor dihitung lewat
  `RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset - DT.tabStripHeight`.
- `_onScroll` memilih anchor terakhir yang sudah dilewati (toleransi 4 px) untuk menyorot label;
  `_jumping` mencegah sorot berkedip saat `animateTo` berjalan.
- Strip sengaja diletakkan **setelah** blok judul, sehingga pada offset 0 ia berada di bawah
  lipatan (sesuai mockup 1) dan menempel di bawah AppBar begitu di-scroll (mockup 2–7).

### 3.2 Sheet layar penuh vs bottom sheet

Empat "bottom sheet" pada nama file mockup sebenarnya digambar sebagai **halaman penuh dengan
AppBar merah**: Diskusi, Ulasan, Fasilitas Gedung, Furnitur Ruangan — plus
`PILIH RENCANA PEMBAYARAN`. Semuanya memakai `SheetScaffold` + `MaterialPageRoute`.
Hanya `Deskripsi` yang benar-benar `showModalBottomSheet` + `DraggableScrollableSheet`.

### 3.3 Kepemilikan state

| State | Pemilik | Catatan |
|---|---|---|
| favorit | `PropertyDetailScreen` (`detail.copyWith`) | diteruskan ke host via `onFavoriteChanged` |
| segmen `Info` | `InfoSection` | internal, tidak perlu diangkat |
| expand inklusi | `InclusionTable` | internal |
| collapse `Pilih Add On` | `AddOnSelector` | internal |
| expand `Jadwal Pembayaran` | `InstallmentSchedule` | di-reset lewat `key: ValueKey(plan.id)` |
| periode, durasi, add-on tercentang, rencana bayar, promo | `RincianUnitScreen` | karena semuanya masuk ke perhitungan `Ringkasan` |

`RincianUnitScreen` menyimpan pilihan **per periode** (`Map<RentalPeriod, …>`), jadi berpindah
segmen tidak menghapus centang add-on atau rencana cicilan segmen lain.

---

## 4. Aritmetika uang (diverifikasi dari gambar)

`PriceSummaryCard` sengaja **tidak** menghitung apa pun — ia hanya merender `SummaryLine`
yang sudah diformat. Seluruh aritmetika ada di `RincianUnitScreen._summaryLines` dan `._payable`.

**Harian** (`tab_harian_2.jpg`)

| Baris | Nilai |
|---|---|
| `Total harga untuk 1 malam` | 1.020.000 |
| `Service Fee` | 260.000 |
| `PROMO` (AGD30) | −50.000 |
| add-on `Personal Insurance` (tercentang, tidak ditampilkan sebagai baris) | +4.100 |
| **`Total`** (merah) | **1.234.100** |

**Bulanan** (`tab_bulanan_2.jpg`): 14.250.000 + 750.000 − 150.000 + 35.500 + 940.000 =
**15.825.500**.

**Tahunan tanpa cicilan** (`tab_tahunan_default.jpg`): `Bayar Penuh` → `plan.total`
113.980.000 = 111.750.000 + 2.230.000 (base + service fee).

**Tahunan dengan cicilan** (`Cicilan 2x`): baris pertama jadwal `firstDue` = 30.260.625 sudah
**termasuk** service fee, sehingga kartu memecahnya kembali:

| Baris | Nilai | Rumus |
|---|---|---|
| `Pembayaran Pertama` | 28.030.625 | `plan.firstDue - serviceFee` |
| `Service Fee` | 2.230.000 | `serviceFee` |
| add-on tercentang | +271.000 | tidak tampil sebagai baris |
| **`Bayar Sekarang`** (merah) | **30.531.625** | `plan.firstDue - diskon + addOnTotal` |

Add-on dengan `price == null` (`Dust Mite Cleaning Service`) bersifat *quote on request* — tidak
menambah total.

---

## 5. Asumsi & divergensi yang perlu dikonfirmasi

Semua poin di bawah adalah tempat mockup dan aplikasi yang berjalan **tidak sama**. Kode di sini
mengikuti mockup; yang perlu diputuskan adalah mana yang menang saat integrasi.

1. **Palet merah vs navy/emas.** Mockup memakai merah sebagai warna aksen; aplikasi memakai navy
   `#0E2340` + emas `#F4A93B`. Kode ini setia pada gambar, tetapi **setiap** warna disalurkan
   melalui `DT` di `theme/detail_tokens.dart`, jadi rebranding = mengubah satu file.
2. **Format angka & tanggal.** Mockup menulis `IDR 14,100,000` dan `16 Agt 2026`; aplikasi memakai
   `Rp 14.100.000` dan `Agu` (locale `id_ID` dari `intl`). `utils/fmt.dart` mereproduksi versi
   mockup tanpa `intl`. Untuk menyeragamkan dengan aplikasi, ganti isi `Fmt` dengan pemanggilan
   `flutter/lib/utils/formatters.dart`.
3. **Peta tidak interaktif.** `google_maps_flutter` bukan dependensi proyek, jadi
   `LocationSection` menampilkan pratinjau statis + tombol yang memanggil `onOpenMap` milik host.
4. **Bagikan.** `share_plus` juga tidak ada; ikon share hanya memanggil `onShare`.
5. **Gambar.** Memakai `Image.network` (bukan `cached_network_image`). Saat dipindah ke
   `flutter/lib/`, ganti isi `NetImage` supaya ikut kebijakan cache aplikasi.
6. **Total `Cicilan 12x` tidak sama dengan jumlah barisnya.** Angka `Total IDR 135,217,500` pada
   mockup ≠ penjumlahan 12 baris yang tercetak. Nilai tersebut disimpan apa adanya di
   `InstallmentPlan.total` agar layar identik dengan screenshot; `scheduleTotal` akan memakai
   jumlah baris bila `total` tidak diisi. **Perlu klarifikasi ke pemilik produk** mana yang benar.
7. **Add-on tidak muncul sebagai baris `Ringkasan`.** Mockup menghitung add-on tercentang di
   total, tetapi tidak menampilkannya sebagai baris. Perilaku ini diikuti; jika sebaiknya
   ditampilkan, cukup tambahkan `SummaryLine` di `_summaryLines`.
8. **Mengubah durasi tidak menghitung ulang harga.** `_changeDuration` hanya mengganti nilai
   terpilih — harga baru semestinya datang dari API. Sambungkan ke endpoint harga saat integrasi.
9. **Konten fixture.** Nama properti, ulasan, tanya-jawab, dan nominal di `models/sample_data.dart`
   disalin dari gambar hanya sebagai contoh tampilan, bukan data produksi.

---

## 6. Struktur file

```
_build_dart/
├── property_detail_screen.dart   # PropertyDetailScreen — mockup 1–15
├── rincian_unit_screen.dart      # RincianUnitScreen + BookingDraft — mockup 16–24
├── theme/
│   └── detail_tokens.dart        # DT: warna, teks, radius, gutter, tinggi strip
├── utils/
│   ├── fmt.dart                  # Fmt: IDR 1,020,000 · 16 Agt 2026 · mask nama
│   └── detail_icons.dart         # DetailIcons: nama fasilitas → IconData
├── models/
│   ├── property_detail.dart      # PropertyDetail + 15 tipe pendukung (galeri, fasilitas, info, ulasan, Q&A)
│   ├── unit_pricing.dart         # RentalPeriod, UnitPricing, AddOn, InstallmentPlan, AppliedPromo, SummaryLine
│   └── sample_data.dart          # fixture yang mereproduksi angka & teks mockup
├── widgets/
│   ├── detail_primitives.dart    # NetImage, SectionCard, TitledCard, BrandButton, DropdownField, SheetScaffold, …
│   ├── detail_gallery_header.dart
│   ├── detail_overview_block.dart
│   ├── detail_action_row.dart
│   ├── review_summary_card.dart
│   ├── section_tab_strip.dart    # SectionTabStrip + SliverPersistentHeaderDelegate
│   ├── facility_grid.dart
│   ├── info_segmented.dart       # Check In Info / Deposit / Unit Detail
│   ├── description_card.dart     # IntroCard + DescriptionCard
│   ├── location_section.dart     # peta statis + NearbyGrid
│   ├── guest_media_section.dart
│   ├── building_units_card.dart
│   ├── sticky_price_bar.dart
│   ├── unit_stay_card.dart       # PeriodSelector + UnitStayCard
│   ├── inclusion_table.dart      # InclusionTable + SpecialPriceList
│   ├── add_on_selector.dart
│   ├── installment_schedule.dart # InstallmentSchedule + PaymentPlanField
│   ├── price_summary_card.dart
│   └── promo_row.dart
└── sheets/
    ├── qna_sheet.dart
    ├── reviews_sheet.dart
    ├── building_facilities_sheet.dart
    ├── room_furniture_sheet.dart
    ├── description_sheet.dart
    └── payment_plan_sheet.dart
```

---

## 7. Langkah integrasi ke `flutter/lib/`

1. Pindahkan `screens/` (dua file screen), `widgets/`, dan `sheets/` ke
   `flutter/lib/screens/property/` mengikuti konvensi folder per area, lalu rapikan import relatif.
2. Gabungkan `models/property_detail.dart` + `models/unit_pricing.dart` ke `flutter/lib/models/`
   dan sambungkan `fromJson` ke response `api/v1` yang sesuai.
3. Ganti `theme/detail_tokens.dart` dengan tema aplikasi (atau biarkan sebagai lapisan token dan
   isi nilainya dari tema) — lihat divergensi palet di §5.1.
4. Ganti `utils/fmt.dart` dengan `flutter/lib/utils/formatters.dart` bila format aplikasi yang
   dipakai (§5.2).
5. Daftarkan route di `flutter/lib/router.dart` (`AppRoutes.*`) dan ganti dua `MaterialPageRoute`
   di contoh §1 dengan `Navigator.pushNamed`.
6. Sambungkan callback ke service: harga & ketersediaan, promo, favorit, chat host, dan `POST`
   booking dari `BookingDraft`.
7. Buang `models/sample_data.dart` (atau pindahkan ke `test/fixtures/`) setelah API tersambung.

## 8. Verifikasi

`docs/` berada di luar package Flutter, sehingga analyzer di IDE selalu melaporkan
`Target of URI doesn't exist: 'package:flutter/material.dart'` untuk folder ini — itu bukan error
kode. Untuk memeriksanya sungguhan, salin sementara ke dalam package:

```bash
cp -r docs/properties/screen/_build_dart flutter/lib/zz_build_check
rm -f flutter/lib/zz_build_check/README.md
cd flutter && flutter analyze lib/zz_build_check
rm -rf lib/zz_build_check          # jangan tinggalkan salinannya
```

Hasil terakhir (33 file `.dart`, Flutter SDK di repo ini):

```
Analyzing zz_build_check...
No issues found!
```

Catatan: `property_detail_screen.dart` butuh `import 'package:flutter/rendering.dart' show
RenderAbstractViewport;` — `material.dart` tidak mengekspor `RenderAbstractViewport`, dan
`_anchorOffset()` memakainya untuk menghitung offset scroll-spy (§3.1). Jangan hapus import itu
saat memindahkan file.
