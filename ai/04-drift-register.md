# Drift Register — Docs & Klaim vs Kode

> **Fungsi file ini.** Daftar selisih **terverifikasi** antara apa yang ditulis
> docs/`CLAUDE.md` dan apa yang benar-benar ada di kode, plus cacat integrasi
> yang ditemukan saat menyusun paket ini.
>
> **Baca ini sebelum mempercayai file docs lain di luar `docs/ai/` dan
> `docs/domain/hotel-vs-property.md`.**
>
> **Diverifikasi dari kode pada 2026-08-21.** Setiap baris punya bukti path:baris.

Kategori:
**🔴 Bug** — kode salah, akan gagal saat dijalankan.
**🟠 Docs salah** — kode benar, dokumentasi menyesatkan.
**🟡 Bau kode** — jalan, tapi melanggar konvensi repo sendiri.

---

## Ringkasan

| # | Temuan | Kategori |
|---|---|---|
| 17 | `App\Models\Room` orphan — tabel `rooms` ada, model tidak dipakai | 🟡 |
| 18 | FCM: endpoint ada, paket Firebase tidak | 🟠 |
| 19 | `googleMapsApiKey` ada, paket maps tidak | 🟠 |

---

## 🟡 Bau kode — jalan, tapi melanggar konvensi repo

### 17. Model orphan `Room`

`App\Models\Room` — tidak direferensikan di controller, Livewire, atau resource
manapun. Stok hotel sepenuhnya menggunakan counter `room_inventories`.
Tabel `rooms` dan migration-nya tetap dipertahankan untuk kompatibilitas
database yang sudah ada.

### 18. FCM: endpoint ada, paket Firebase tidak

`POST devices/fcm-token` punya controller + fixture, tapi `pubspec.yaml` tidak
memasang `firebase_messaging`. Jalur push belum aktif ujung ke ujung.

### 19. `googleMapsApiKey` ada, paket maps tidak

`AppConfig.googleMapsApiKey` ada, tapi `pubspec.yaml` tidak memasang paket
peta. Peta belum diimplementasikan.

---

## Cara memakai daftar ini

- **Sebelum mempercayai file docs**: cek apakah namanya muncul di ringkasan. Kalau ya,
  file itu masih ada — baca dan verifikasi.
- **Sebelum mempercayai angka inventaris** di `CLAUDE.md` mana pun: pakai
  `docs/ai/00-orientation.md` §5 untuk menghitung ulang.
- **Sebelum melaporkan "endpoint rusak"**: cek `03-api-contract.md` §4-5 —
  mungkin sudah tercatat di sini.
- **Setelah memperbaiki salah satu item**: hapus barisnya dari file ini dan
  perbarui pack terkait. Register yang tidak dirawat berubah jadi kebisingan.
