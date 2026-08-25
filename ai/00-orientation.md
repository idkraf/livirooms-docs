# AI Orientation — Baca Ini Dulu, Selalu

> **Fungsi file ini.** Titik masuk tunggal untuk AI yang menerima prompt baru di
> repo ini. Tujuannya satu: **kamu tidak perlu membaca ulang seluruh `laravel/`
> dan `flutter/`.** Paket di `docs/ai/` sudah memuat hasil pembacaan itu.
>
> Alurnya: baca file ini → pilih pack dari tabel dispatch → buka **hanya**
> file kode yang disebut pack itu → kerjakan.

---

## 1. Ringkasan Proyek

**Livirooms** — marketplace penyewaan properti multi-tipe dan hotel OTA. Monorepo dengan dua deliverable:

| Bagian | Isi & Arsitektur |
|---|---|
| `laravel/` | Laravel 12. **Dua muka:** REST API (`api/v1`, Sanctum) untuk app mobile + Admin Panel (Metronic blade + Livewire 4 + Yajra DataTables) untuk admin & mitra. DB PostgreSQL dengan 21 model ternormalisasi (3NF). |
| `flutter/` | Satu app, **dua peran**: Konsumen (`MainShell`) & Mitra/Host (`MitraShell`). State: Provider. HTTP: package `http`. |

Stok akomodasi dikelola lewat entitas akar terpadu `accommodations` dengan diskriminator `booking_mode`:
- `'unit'`: Sewa unit utuh (apartemen, villa, kost). Kapasitas & harga diatur via 1 baris internal `unit_types` + `unit_type_prices`.
- `'room'`: Sewa kamar hotel per malam. Kapasitas, tipe kamar, & inventori diatur via multiple `unit_types`.

---

## 2. Tabel Dispatch — Prompt Seperti Apa → Baca Apa

| Prompt kamu tentang… | Baca | Jangan buka |
|---|---|---|
| **Properti, hotel, kamar, stok, ketersediaan, pencarian listing, harga** | 🔴 `docs/domain/accommodations.md` **wajib lebih dulu**, lalu `01-backend-map.md` §Domain | seluruh `app/Models/` |
| Endpoint API — ada/tidak, request/response, siapa yang memanggil | `03-api-contract.md` (tabel endpoint lengkap) | `routes/api_mobile.php` |
| Bug/fitur di sisi mobile — layar, navigasi, service | `02-frontend-map.md` | seluruh `lib/` |
| Booking → order → payment → webhook → deep link | `01-backend-map.md` §Pembayaran + `docs/payments/system.md` + `03-api-contract.md` §Alur bayar | — |
| Modul admin baru / DataTable / Livewire Wizard | `01-backend-map.md` §Admin Panel + `docs/configuration/admin-panel.md` + `docs/configuration/ui-patterns.md` | `routes/admin_generated.php` |
| Status booking/order/payment, transisi state | `01-backend-map.md` §State machine | migration enum |
| Permission, role, guard admin | `01-backend-map.md` §Auth & permission | — |
| "Kenapa docs bilang X tapi kode Y?" | `04-drift-register.md` | — |
| Referral & Reward | `docs/features/referral.md` | — |

---

## 3. Aturan Keras Saat Mengerjakan Repo Ini

1. **NO TESTING / NO MIGRATING:** Jangan jalankan test, `php artisan test`, atau migration/seeder. Dilarang di semua sesi di repo ini.
2. **NO TOUCHING FLUTTER:** Jangan ubah kode Flutter atau JSON fixture terlindungi saat mengerjakan tugas backend.
3. **SINKRONKAN DOCS (Zero-Omission):** Setiap perubahan kode di `laravel/` wajib diikuti update file docs terkait di `docs/`.
4. **Jangan edit `laravel/routes/admin_generated.php`.** File hasil scaffold.
5. **Jangan commit `laravel/.env`** — berisi kredensial DB nyata.

---

## 4. Peta Dokumen Lain

| File | Deskripsi |
|---|---|
| `docs/domain/hotel-vs-property.md` | ✅ **Master domain properti/hotel & 21 tabel 3NF.** |
| `docs/INDEX.md` | ✅ Indeks navigasi global |
| `docs/README.md` | ✅ Ringkasan sistem & stack |
| `docs/configuration/admin-panel.md` | ✅ Pola modul admin & Livewire Form Wizards |
| `docs/configuration/ui-patterns.md` | ✅ Template Blade & Livewire UI |
| `docs/features/payments.md` | ✅ Sistem pembayaran Midtrans |
| `docs/features/referral.md` | ✅ Sistem referral |
| `docs/payments/system.md` | ✅ Spesifikasi pembayaran, webhook, dan deep link |
