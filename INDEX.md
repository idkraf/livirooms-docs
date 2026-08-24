# Indeks Dokumentasi

Peta rute: **topik → file docs → path kode**. Mulai dari sini, lalu buka hanya file yang relevan.

> ## 🟢 Untuk AI: mulai dari `ai/00-orientation.md`
>
> Paket **[ai/](ai/)** adalah hasil pembacaan menyeluruh `laravel/` + `flutter/`
> per **2026-08-21**, disusun supaya sesi AI **tidak perlu membaca ulang seluruh
> kedua codebase** untuk menjawab prompt baru.
>
> | File | Isi |
> |---|---|
> | 🟢 [ai/00-orientation.md](ai/00-orientation.md) | **Titik masuk.** Tabel dispatch: prompt seperti apa → baca pack yang mana → jangan buka apa |
> | [ai/01-backend-map.md](ai/01-backend-map.md) | Laravel: layer, inventaris, state machine, payment, admin panel, job, permission |
> | [ai/02-frontend-map.md](ai/02-frontend-map.md) | Flutter: 45 layar, 45 route, 19 service, 44 model, lapisan API, dummy mode |
> | [ai/03-api-contract.md](ai/03-api-contract.md) | 84 endpoint → `Controller::method` → service Dart → fixture dummy. Jembatan dua sisi |
> | [ai/04-drift-register.md](ai/04-drift-register.md) | 6 selisih terverifikasi docs vs kode, termasuk 2 bug integrasi |
>
> Untuk domain properti/hotel, `ai/` **menunjuk** ke
> [domain/hotel-vs-property.md](domain/hotel-vs-property.md) — itu tetap masternya.

## Mulai dari mana

| Kalau kamu ingin… | Baca ini |
|---|---|
| **AI menjawab prompt baru di repo ini** | 🟢 **[ai/00-orientation.md](ai/00-orientation.md)** |
| **Mengerjakan hotel atau properti** | 🔴 **[domain/hotel-vs-property.md](domain/hotel-vs-property.md) — WAJIB, baca dulu** |
| Gambaran umum sistem | [README.md](README.md) ⚠️ punya drift stack — cek [ai/04-drift-register.md](ai/04-drift-register.md) dulu |
| Menyiapkan environment dev | `/CLAUDE.md` (root) → bagian "Cara mulai" |
| Konvensi backend | `/laravel/CLAUDE.md` ⚠️ 4 angka inventaris basi — angka benar di [ai/01-backend-map.md](ai/01-backend-map.md) §3 |
| Konvensi mobile | `/flutter/CLAUDE.md` ⚠️ jumlah layar & gotcha `dummy` basi — lihat [ai/02-frontend-map.md](ai/02-frontend-map.md) |
| Membuat modul admin baru | [configuration/admin-panel.md](configuration/admin-panel.md) + [configuration/ui-patterns.md](configuration/ui-patterns.md) |
| **Mengerjakan pembayaran** | [ai/01-backend-map.md](ai/01-backend-map.md) §8 + [ai/03-api-contract.md](ai/03-api-contract.md) §6 |
| **Menambah layar Flutter** | [ai/02-frontend-map.md](ai/02-frontend-map.md) §4 |
| **Memahami modul hotel OTA** | [domain/hotel-vs-property.md](domain/hotel-vs-property.md) |

## Per domain

### Admin Panel & UI

| File | Isi | Kode terkait |
|---|---|---|
| [configuration/admin-panel.md](configuration/admin-panel.md) | Pola modul admin (Pattern A/B/C/D), alur CRUD | `laravel/app/Http/Controllers/Admin/`, `app/Livewire/`, `app/DataTables/` — jumlah aktual di [ai/01-backend-map.md](ai/01-backend-map.md) §3 |
| [configuration/ui-patterns.md](configuration/ui-patterns.md) | Markup Blade standar: layout wrapper, card DataTable, action column, form modal, halaman detail | `laravel/resources/views/admin/`, `laravel/resources/views/livewire/` |
| [configuration/missing-files.md](configuration/missing-files.md) | ⚠️ Log pekerjaan selesai, **bukan** audit hidup. Nilai historis saja | — |

### Pembayaran (Midtrans)

| Kebutuhan | Baca |
|---|---|
| Sistem pembayaran end-to-end, 6 endpoint, payload, Flutter flow | **[payments/system.md](payments/system.md)** |
| Aturan keras webhook, signature, idempoten, kredensial, deep link | [ai/01-backend-map.md](ai/01-backend-map.md) §8 |
| State machine booking/order/payment + tabel transisi webhook | [ai/01-backend-map.md](ai/01-backend-map.md) §7 |
| Alur bayar ujung ke ujung app ↔ backend ↔ Midtrans | [ai/03-api-contract.md](ai/03-api-contract.md) §6 |
| Endpoint pembayaran & pemanggilnya di Dart | [ai/03-api-contract.md](ai/03-api-contract.md) §3 |
| Kode | `laravel/app/Http/Controllers/Api/PaymentController.php`, `app/Support/{MidtransSnap,MidtransGateway,PaymentDeepLink}.php`, `app/Http/Controllers/Payment/` |

### Properti & Hotel

| File | Isi | Kode terkait |
|---|---|---|
| 🔴 [domain/hotel-vs-property.md](domain/hotel-vs-property.md) | **Master context domain.** Property vs Hotel, diskriminator `booking_mode`, peta relasi, inventaris migration/model/API/resource, 9 invarian, template prompt | `laravel/app/Models/Property.php`, `Hotel.php`, `Api/PropertyController.php`, `Api/HotelApiController.php` |

### Fitur

| File | Isi | Kode terkait |
|---|---|---|
| [features/referral.md](features/referral.md) | Sistem referral: kode, klaim, reward | `laravel/app/Models/Referral.php`, `Api/ReferralController.php`, `flutter/lib/services/referral_service.dart` |

### Mobile

| Kebutuhan | Baca |
|---|---|
| Arsitektur Flutter, 45 route, 45 layar, 19 service, 44 model | [ai/02-frontend-map.md](ai/02-frontend-map.md) |
| Dummy mode, API layer, router traps | [ai/02-frontend-map.md](ai/02-frontend-map.md) §4 |

## Cari cepat di kode (bukan di docs)

Untuk hal yang cepat basi kalau ditulis di docs, baca langsung dari kode.
Perintah baca-saja beserta angka harapan per 2026-08-21 ada di
[ai/00-orientation.md](ai/00-orientation.md) §5.

| Pertanyaan | Perintah / file |
|---|---|
| Endpoint API apa saja yang ada? | [ai/03-api-contract.md](ai/03-api-contract.md) (84 endpoint, sudah lengkap) atau `laravel/routes/api_mobile.php` |
| Route admin apa saja? | `laravel/routes/admin_generated.php` (142 named route) |
| Ada model/tabel apa saja? | `ls laravel/app/Models/` · `ls laravel/database/migrations/` |
| Route Flutter apa saja? | [ai/02-frontend-map.md](ai/02-frontend-map.md) §4 atau `flutter/lib/router.dart` |
| Package apa yang benar-benar terpasang? | `laravel/composer.json` · `flutter/pubspec.yaml` |
| Hotel model apa yang sudah ada? | `Hotel`, `RoomType`, `RoomInventory`, `BookingRoom`, `Facility`, `InsuranceProvider`, `InsurancePlan`, `BookingInsurance` — plus `Room` (**orphan**, bukan stok) |

## Drift yang diketahui

**Daftar lengkap & terverifikasi: [ai/04-drift-register.md](ai/04-drift-register.md)**
(6 temuan per 2026-08-21, masing-masing dengan bukti `path:baris`).

Yang paling perlu diwaspadai:

| Lokasi | Masalah |
|---|---|
| `docs/INDEX.md` (file ini) | mereferensikan direktori `docs/properties/`, `docs/hotel/`, `docs/flutter/` yang tidak ada — sudah dihapus peringatannya, gunakan `domain/hotel-vs-property.md` dan `ai/02-frontend-map.md` sebagai ganti |
| `flutter/lib/models/booking_payment.dart` | 🟡 `HotelBookingPayment` tidak membawa `redirectUrl`/`snapToken`, sedangkan `Payment` model Flutter membawanya — perbedaan struktur antara model hotel booking dan property booking |
| `AppConfig.baseUrl` | 🟡 default sudah diubah ke produksi `https://ipanzipang.pro/api/v1`; build tanpa `--dart-define=API_BASE_URL=...` sekarang menunjuk URL yang benar |
| `laravel/CLAUDE.md` inventaris | "33 model / 17 Api / 32 Admin / 26 Livewire" → aktual **74 / 20 / 33 / 30** |
| `flutter/CLAUDE.md` | "39 layar" → aktual **45** |

Aturan lama di sini adalah **"jangan tulis daftar file di docs"** — karena
daftar cepat basi. Paket `docs/ai/` sengaja melanggarnya, atas permintaan
eksplisit, supaya AI tidak perlu membaca ulang seluruh codebase. Dua mitigasi
yang membuatnya tetap aman: **setiap file bertanggal**, dan
[ai/00-orientation.md](ai/00-orientation.md) §5 memuat perintah baca-saja untuk
menghitung ulang setiap angka. Kalau hasil hitung berbeda dari yang tertulis,
perbarui pack dulu sebelum menjawab.

## Catatan

- `sfds.md` adalah catatan lepas berisi usulan struktur docs yang **tidak dipakai** dan bertentangan dengan struktur nyata. Abaikan atau hapus.
- Bahasa docs: Indonesia. Bahasa kode & komentar: Inggris.
- Setiap perubahan di `laravel/` atau `flutter/` **wajib** diikuti update docs terkait — termasuk paket `docs/ai/` bila yang berubah adalah struktur, endpoint, route, model, atau state machine.
- **Jangan jalankan test, `php artisan test`, atau migration/seeder** di repo ini.
