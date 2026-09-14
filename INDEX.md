# Indeks Dokumentasi — Livirooms Multi-Accommodation Architecture

Peta rute dokumentasi proyek: **Topik → File Dokumentasi → Implementasi Kode**.

> ## 🟢 Titik Masuk AI: `ai/00-orientation.md`
>
> Paket **[`ai/`](ai/)** adalah representasi arsitektur `laravel/` + `flutter/` terpadu:
>
> | File | Isi Pokok |
> |---|---|
> | 🟢 [ai/00-orientation.md](ai/00-orientation.md) | **Titik masuk utama.** Routing direktori, aturan verifikasi inventaris, dan negative constraints. |
> | [ai/01-backend-map.md](ai/01-backend-map.md) | Laravel: 21 model ternormalisasi, layer data flow, state machine, Midtrans payments, Livewire wizard. |
> | [ai/02-frontend-map.md](ai/02-frontend-map.md) | Flutter: 45 layar, 45 route, 19 service, 44 model, fixture dummy contract. |
> | [ai/03-api-contract.md](ai/03-api-contract.md) | 85 endpoint → `Controller::method` → Dart service → payload fixture. |
> | [ai/04-drift-register.md](ai/04-drift-register.md) | Daftar drift terverifikasi & status perbaikan data model 3NF. |
>
> Untuk arsitektur data Hotel vs Property, dokumen master adalah:
> 🔴 **[domain/hotel-vs-property.md](domain/hotel-vs-property.md)**

---

## Navigasi Dokumen Berdasarkan Topik

| Kebutuhan Anda | File Rujukan Utama |
|---|---|
| **Memahami Model Database 21 Tabel (3NF)** | 🔴 **[domain/hotel-vs-property.md](domain/hotel-vs-property.md)** |
| **Arsitektur Global & Stack Teknologi** | [README.md](README.md) |
| **Konvensi & Panduan Backend Laravel 12** | `/laravel/CLAUDE.md` + [ai/01-backend-map.md](ai/01-backend-map.md) |
| **Konvensi & Arsitektur Mobile Flutter** | `/flutter/CLAUDE.md` + [ai/02-frontend-map.md](ai/02-frontend-map.md) |
| **User Guide Mobile App** | [manual/user-guide-mobile-app.md](manual/user-guide-mobile-app.md) |
| **User Guide Web Administrator** | [manual/user-guide-web-administrator.md](manual/user-guide-web-administrator.md) |
| **User Manual Web Administrator** | [manual/user-manual-web-administrator.md](manual/user-manual-web-administrator.md) |
| **User Manual Mobile App** | [manual/user-manual-mobile-app.md](manual/user-manual-mobile-app.md) |
| **Livewire Form Wizards (Add/Edit Property & Hotel)** | [configuration/admin-panel.md](configuration/admin-panel.md) + [configuration/ui-patterns.md](configuration/ui-patterns.md) |
| **Sistem Pembayaran Midtrans Snap & Webhook** | [payments/system.md](payments/system.md) + [features/payments.md](features/payments.md) |
| **Sistem Referral & Reward** | [features/referral.md](features/referral.md) |
| **Sampel Response API & Master Contract** | [response/detail-property.json](response/detail-property.json), [response/hotels.json](response/hotels.json), [response/home.json](response/home.json) |
| **Alur Eksekusi API & Workflows** | [workflows/run_api_sequence.xml](workflows/run_api_sequence.xml) |

---

## Ringkasan Struktur Modul Backend

### 1. Entitas Akomodasi Ternormalisasi (21 Tabel)
- **Akar:** `accommodations` (`booking_mode`: `room` vs `unit`).
- **Unit & Tarif:** `unit_types`, `unit_type_prices`, `unit_type_images`.
- **Fasilitas:** `facility_groups`, `facility_items` (`context`: `facility`/`furniture`/`spec`), `facility_tags`.
- **Media & Ulasan:** `galleries`, `reviews`, `review_photos`.
- **Kebijakan & Q&A:** `accommodation_policies` (`general`/`check_in`/`deposit`), `accommodation_questions`, `nearby_points`.
- **Detail Ruangan:** `room_furniture_groups`, `room_furniture_items`, `bed_facilities`.
- **Detail Kompleks:** `accommodation_description_paragraphs`, `accommodation_details`, `accommodation_detail_groups`, `accommodation_detail_lines`.

### 2. Livewire 4 Multi-Step Wizard
- **Accommodation Wizard (Unified):** `App\Livewire\Accommodations\WizardForm` (`livewire.accommodations.wizard_form`).

### 3. API Resources Terpadu
- **`AccommodationResource`**: Mengembalikan payload `hotelShape()` untuk hotel dan `propertyShape()` untuk properti, 100% presisi dengan contract JSON Flutter.
