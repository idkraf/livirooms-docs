# AI Orientation — Baca Ini Dulu, Selalu

> **Fungsi file ini.** Titik masuk tunggal untuk AI yang menerima prompt baru di
> repo ini. Tujuannya satu: **kamu tidak perlu membaca ulang seluruh `laravel/`
> dan `flutter/`.** Paket di `docs/ai/` sudah memuat hasil pembacaan itu.
>
> Alurnya: baca file ini → pilih pack dari tabel dispatch → buka **hanya**
> file kode yang disebut pack itu → kerjakan.
>
> **Diverifikasi langsung dari kode pada 2026-08-20.** Semua angka, path, dan
> baris di paket ini dihitung dari kode aktual, bukan disalin dari docs lama.

---

## 1. Apa proyek ini, dalam 6 baris

**Livirooms** — marketplace penyewaan properti multi-tipe. Monorepo, dua deliverable:

| Bagian | Isi |
|---|---|
| `laravel/` | Laravel 12. **Dua muka:** REST API (`api/v1`, Sanctum) untuk app mobile + Admin Panel (Metronic blade + Livewire 4 + Yajra DataTables) untuk admin & mitra. DB PostgreSQL. |
| `flutter/` | Satu app, **dua peran**: Konsumen (`MainShell`) & Mitra/Host (`MitraShell`). State: Provider. HTTP: package `http`. |

Yang dijual ada **dua bentuk stok** yang mekanikanya benar-benar berbeda —
sewa **satu unit utuh** vs sewa **per kamar (hotel/OTA)**. Diskriminatornya
`properties.booking_mode`. Ini sumber kerumitan nomor satu di repo ini.

---

## 2. Tabel dispatch — prompt seperti apa → baca apa

Cari baris yang paling cocok. Kolom "Baca" sudah urut prioritas.

| Prompt kamu tentang… | Baca | Jangan buka |
|---|---|---|
| **Properti, hotel, kamar, stok, ketersediaan, pencarian listing, harga** | 🔴 `docs/domain/hotel-vs-property.md` **wajib lebih dulu**, lalu `01-backend-map.md` §Domain | seluruh `app/Models/` |
| Endpoint API — ada/tidak, request/response, siapa yang memanggil | `03-api-contract.md` (tabel 84 endpoint lengkap) | `routes/api_mobile.php` (sudah disalin utuh ke pack) |
| Bug/fitur di sisi mobile — layar, navigasi, service | `02-frontend-map.md` | seluruh `lib/` |
| Booking → order → payment → webhook → deep link | `01-backend-map.md` §Pembayaran + `docs/payments/system.md` + `03-api-contract.md` §Alur bayar | — |
| Modul admin baru / DataTable / Livewire | `01-backend-map.md` §Admin Panel + `docs/configuration/admin-panel.md` + `docs/configuration/ui-patterns.md` | `routes/admin_generated.php` |
| Status booking/order/payment, transisi state | `01-backend-map.md` §State machine | migration enum |
| Permission, role, guard admin | `01-backend-map.md` §Auth & permission | — |
| "Kenapa docs bilang X tapi kode Y?" | `04-drift-register.md` | — |
| Job, scheduler, cron | `01-backend-map.md` §Job & scheduler | `routes/console.php` |
| Referral | `docs/features/referral.md` | — |

**Kalau tidak ada baris yang cocok:** baca `01-backend-map.md` (backend) atau
`02-frontend-map.md` (mobile) sesuai sisi yang disentuh, lalu buka file kode
yang disebut di bagian "Titik masuk kode" pack itu.

---

## 3. Aturan keras saat mengerjakan repo ini

1. **Jangan jalankan test, `php artisan test`, atau migration/seeder.** Dilarang
   di semua konteks di repo ini.
2. **Sinkronkan docs.** Setiap perubahan kode di `laravel/` atau `flutter/`
   wajib diikuti update file docs terkait — termasuk paket `docs/ai/` ini kalau
   yang berubah adalah struktur, endpoint, route, model, atau state machine.
3. **Jangan edit `laravel/routes/admin_generated.php`.** File hasil scaffold.
4. **Jangan commit `laravel/.env`** — berisi kredensial DB nyata.
5. **Angka di paket ini punya tanggal.** Kalau kamu menambah/menghapus file,
   perbarui angkanya di pack yang sama sekaligus (aturan 2).
6. **Paket ini bukan pengganti kode untuk logika.** Ia menggantikan *pencarian*.
   Untuk mengubah perilaku, tetap buka file yang ditunjuk dan baca badannya.

---

## 4. Isi paket `docs/ai/` dan docs terkait

| File | Isi | Kapan dibaca |
|---|---|---|
| `00-orientation.md` | file ini — dispatcher | selalu |
| `01-backend-map.md` | Laravel: layer, inventaris, domain, state machine, payment, admin panel, job, permission | tugas backend |
| `02-frontend-map.md` | Flutter: 45 layar, 45 route, 19 service, 44 model, lapisan API, dummy mode | tugas mobile |
| `03-api-contract.md` | 84 endpoint → controller::method → service Dart → layar. Jembatan dua sisi | tugas lintas-sisi / integrasi |
| `04-drift-register.md` | selisih terverifikasi antara docs/klaim vs kode, dan endpoint yang dipanggil app tapi tidak ada di backend | sebelum mempercayai docs lain |
| `payments/system.md` | Sistem pembayaran: 6 endpoint, payload, Flutter service methods, webhook contract, deep link, dummy fixtures | tugas payment / booking |

---

## 5. Regenerasi angka (kalau ragu paket sudah basi)

Perintah baca-saja, aman dijalankan. Hasilnya dibandingkan dengan angka di pack.

```bash
cd laravel
ls app/Models | wc -l                          # model      → 74
ls database/migrations | wc -l                 # migration  → 97
ls app/Http/Controllers/Api | wc -l            # api ctrl   → 20
ls app/Http/Controllers/Admin | wc -l          # admin ctrl → 33
ls app/Livewire | wc -l                        # livewire   → 30
ls app/DataTables | wc -l                      # datatable  → 27
grep -c 'Route::' routes/api_mobile.php        # endpoint   → 84

cd ../flutter
find lib/screens -name '*_screen.dart' | wc -l # layar      → 45
find lib/services -name '*.dart' | wc -l       # service    → 19
find lib/models   -name '*.dart' | wc -l       # model      → 44
grep -c 'static const' lib/router.dart         # route      → 45
```

Kalau ada selisih → struktur berubah sejak 2026-08-20. Perbarui pack yang
terkait sebelum menjawab, jangan menjawab dari angka lama.

---

## 6. Peta docs lain (di luar paket ini)

| File | Status |
|---|---|
| `docs/domain/hotel-vs-property.md` | ✅ **kanonik & segar** (2026-08-20). Master domain properti/hotel. |
| `docs/configuration/admin-panel.md` | ✅ pola modul admin A/B/C/D |
| `docs/configuration/ui-patterns.md` | ✅ markup Blade standar |
| `docs/features/referral.md` | ✅ sistem referral |
| `docs/configuration/missing-files.md` | ⚠️ log historis, bukan audit hidup |
| `docs/README.md` | ⚠️ punya drift stack — cek `04-drift-register.md` dulu |
| `docs/INDEX.md` | ⚠️ mereferensikan banyak file yang **tidak ada** — lihat `04-drift-register.md` §1 |
| `docs/sfds.md` | ❌ catatan lepas, tidak dipakai. Abaikan. |
| `laravel/CLAUDE.md`, `flutter/CLAUDE.md` | ✅ konvensi per sisi. Beberapa angka basi — pack ini yang benar. |
