# Wizard Form UI — PMS 7-Step Architecture & Input Upgrades

> **Last updated:** 2026-08-29  
> **Scope:** `app/Livewire/Accommodations/WizardForm.php` + `resources/views/livewire/accommodations/wizard_form.blade.php`

---

## 1. Blueprint 7-Step PMS Flow

Alur wizard diselaraskan penuh dengan standar industri PMS (*Property Management System*), menciptakan keselarasan logika antara mode **Hotel** (`booking_mode = 'room'`) dan **Properti Sewa Unit** (`booking_mode = 'unit'`):

| Step | Tab Name | Mode Room (Hotel) | Mode Unit (Apartemen/Villa/Kost) |
|---|---|---|---|
| **Tab 1** | **1. Identitas & Lokasi** | Host, Tipe Akomodasi, Jenis Properti, Nama Hotel, Gedung, Kota, Alamat, Lat/Long, Status, Star Rating, Tahun Buka. | Host, Tipe Akomodasi, Jenis Properti, Nama Properti, Gedung/Tower, Kota, Alamat, Lat/Long, Status, Tahun Buka. |
| **Tab 2** | **2. Inventaris & Ruang** | Manajemen Tipe Kamar (`room_types`): Nama, Bed, Luas m², Tamu Dws/Anak, Stok Kamar, Fitur Kamar, Foto Kamar, Tag Fasilitas Kamar. | Spesifikasi Ruang (Tamu, Bed/Bath, Luas m²), Fasilitas Kasur (`bed_facilities`), Furnitur per Ruangan (`room_furniture_groups`). |
| **Tab 3** | **3. Skema Harga** | Matrix Tarif Kamar: Tarif per malam, Harga coret diskon, Termasuk sarapan (`has_breakfast`), stok allotment. | Skema Sewa Multi-Durasi (`prices`: daily, weekly, monthly, yearly), Biaya Kebersihan, Deposit, Service Fee, Harga Coret, Caption. |
| **Tab 4** | **4. Fasilitas Properti** | Grup & Item Fasilitas Hotel (`facility_groups` + `facility_items` context=`facility`) dengan badge & status ketersediaan. | Fasilitas Gedung/Kompleks (`facilities`) & Spesifikasi Properti Tambahan (`specs`). |
| **Tab 5** | **5. Media & Cerita** | Foto Cover & Galeri Foto (`galleries`), Intro Singkat, Deskripsi Lengkap, Paragraf Sorotan, Rekomendasi & Flash Sale. | Foto Cover & Galeri Foto (`galleries`), Intro Singkat, Deskripsi Lengkap, Paragraf Sorotan, Rekomendasi & Flash Sale. |
| **Tab 6** | **6. Aturan & Kebijakan** | Jam Check-in/out, Resepsionis 24 Jam & Jam Operasional, Usia Min, Aturan Anak/Extra Bed/Rokok, Daftar Kebijakan Pembatalan Dinamis (`cancellation_policies`), Catatan Check-in & Deposit. | Jam Check-in/out, Deposit Properti, Daftar Kebijakan Pembatalan Dinamis (`cancellation_policies`), Catatan Check-in & Deposit. |
| **Tab 7** | **7. Sekitar & FAQ** | Preview Peta (`map_preview`), Titik POI (`nearby_points`), Titik Transit (`transport_points`), Tanya Jawab Pengelola (`faqs`). | Preview Peta (`map_preview`), Titik POI (`nearby_points`), Tanya Jawab (`questions`), Detail Properti Tambahan (`unit_detail`). |

---

## 2. Icon Rendering System

Semua icon picker dan rendering status menggunakan **Material Design SVG paths** murni (1:1 dengan Flutter) — tanpa dependensi icon font Metronic `ki-outline`:

### Blade Components

| Component | Path | Purpose |
|---|---|---|
| `flutter-icon` | `resources/views/components/flutter-icon.blade.php` | Server-side inline SVG untuk badge & sel tabel |
| `flutter-icon-registry` | `resources/views/components/flutter-icon-registry.blade.php` | Script global penyuplai `window._flutterIconPaths` untuk Alpine.js |
| `icon-picker` | `resources/views/components/icon-picker.blade.php` | Dropdown Alpine.js dengan preview SVG interaktif terikat Livewire |

### Penggunaan

```blade
{{-- Static icon rendering --}}
<x-flutter-icon name="pool" size="16" />

{{-- Interactive icon picker bound to Livewire property --}}
<x-icon-picker
    wire="new_facility_group_icon"
    :icons="['star' => 'Star', 'pool' => 'Kolam Renang']"
/>
```

---

## 3. Suggestion Pools & Autocomplete Reaktif

Semua input teks pendukung dilengkapi dropdown autocomplete reaktif berbasis Alpine.js (`wire:model.live` + getter `get filtered()`):

| Pool Property | Sumber Data | Digunakan Pada |
|---|---|---|
| `$facilitySuggestions` | `FacilityItem` (context=facility) DB | Tab 2/4 Autocomplete Nama Fasilitas |
| `$specSuggestions` | `FacilityItem` (context=spec) DB | Tab 4 Autocomplete Spesifikasi |
| `$nearbySuggestions` | `NearbyPoint` DB | Tab 7 Autocomplete Nama Lokasi POI |
| `$buildingListSuggestions` | `BuildingList` DB | Tab 1 Autocomplete Nama Gedung/Tower |
| `$roomNameSuggestions` | Presets Preset | Tab 2 Autocomplete Nama Tipe Kamar |
| `$bedSuggestions` | Presets Preset | Tab 2 Autocomplete Konfigurasi Bed |
| `$facilityCategorySuggestions` | Presets Preset | Tab 4 Autocomplete Kategori Fasilitas |
| `$nearbyTypeSuggestions` | Presets Preset | Tab 7 Autocomplete Tipe Lokasi Sekitar |
| `$nearbyDistanceSuggestions` | Presets Preset | Tab 7 Autocomplete Jarak |
| `$nearbyDurationSuggestions` | Presets Preset | Tab 7 Autocomplete Durasi |
| `$badgeSuggestions` | Presets Preset | Tab 4 Shortcut Badge Fasilitas |
| `$roomPolicyPresets` | Presets Preset | Tab 6 Shortcut & Presets Kebijakan Kamar |
| `$cancellationPolicyPresets` | Presets Preset | Tab 6 Shortcut Kebijakan Pembatalan |
| `$faqQuestionSuggestions` | Presets Preset | Tab 7 Autocomplete Pertanyaan FAQ |
| `$detailSuggestions` | Presets Preset | Tab 7 Autocomplete Label Detail |

---

## 4. Model `AccommodationPolicy` Multi-Section Architecture

Seluruh kebijakan properti dan kamar disimpan secara modular pada tabel `accommodation_policies`:
- `section = 'general'` — Pengaturan umum: jam operasional resepsionis, usia min tamu, boolean flags (resepsionis 24 jam, allow children, extra bed).
- `section = 'room_policy'` — Multi-item dinamis kebijakan kamar hotel (icon, tone, title, paragraphs/text).
- `section = 'cancellation'` — Butir-butir kebijakan pembatalan dinamis.
- `section = 'check_in'` — Catatan instruksi check-in khusus (icon, tone, title, paragraphs/text).
- `section = 'deposit'` — Catatan uang jaminan / deposit.

---

## 5. Single Root DOM & State Invariants

1. **Single Root Element:** File `wizard_form.blade.php` diawali dengan modal root tunggal `<div class="modal fade" ...>` dan `<x-flutter-icon-registry />` diletakkan di dalam root untuk mencegah kerusakan morphing Livewire.
2. **Navigasi Dinamis:** Method `setTab(n)`, `nextTab()`, dan `prevTab()` mengelola state `$currentTab` dengan aman.
3. **Validasi Kondisional:** Method `rules()` secara cerdas memvalidasi `guest_capacity`, `bedrooms`, dan `prices` hanya saat `booking_mode = 'unit'`, serta memvalidasi `room_types` hanya saat `booking_mode = 'room'`.
