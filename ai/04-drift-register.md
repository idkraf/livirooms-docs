# Drift Register — Docs & Klaim vs Kode

> **Fungsi file ini.** Daftar status selisih terverifikasi, perbaikan arsitektur data modeling, dan catatan integrasi sistem.
>
> **Status per 2026-08-25:** Rekonsiliasi Data Modeling PostgreSQL v3 selesai. 21 model ternormalisasi dan API Resources terpadu telah aktif.

---

## 1. Status Resolusi Arsitektur (Selesai Direkonsiliasi)

| Topik | Isu Lama | Status & Solusi Baru |
|---|---|---|
| **Data Modeling Hotel vs Property** | Tabel paralel tidak konsisten & JSON blob `display_meta` tak terstruktur | ✅ **Terselesaikan:** 21 tabel ternormalisasi 3NF dengan single root `accommodations` & `booking_mode`. |
| **Harga & Kapasitas** | Duplikasi harga di properti dan room type | ✅ **Terselesaikan:** Single source of truth pada `unit_types` + `unit_type_prices`. Relasi `cheapestUnitType()` (`HasOne::ofMany`). |
| **Transformasi Output API** | Resource monolitik campur ad-hoc | ✅ **Terselesaikan:** `AccommodationResource` auto-branching `hotelShape()` & `propertyShape()`, 100% cocok dengan master fixture JSON. |
| **Admin Form Wizards** | Form Livewire belum mendukung relasi ternormalisasi | ✅ **Terselesaikan:** `Properties\WizardForm` & `Hotels\WizardForm` mendukung 4-step wizard transaksional (`DB::transaction`). |

---

## 2. Catatan Integrasi Aktif

### 1. Model `Room` (Fisik)
Stok kamar hotel sepenuhnya menggunakan counter harian `room_inventories` (Allotment OTA style) dan bukan penomoran kamar fisik. Model `Room` bersifat pasif.

### 2. Push Notification & Maps
- Parameter `AppConfig.googleMapsApiKey` dan endpoint token `POST devices/fcm-token` tersedia di backend untuk ekspansi masa depan tanpa memblokir runtime Flutter.
