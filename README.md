# Rental Apartemen (Livirooms) — Dokumentasi Sistem

Platform penyewaan properti multi-tipe berbasis subscription dan reservasi hotel OTA yang mendukung penyewaan harian, mingguan, bulanan, dan tahunan. Melayani empat aktor utama: **Konsumen (Guest)**, **Host/Mitra**, **Admin**, dan **Corporate**.

> 📍 **Navigasi Lengkap:** Buka **[INDEX.md](INDEX.md)** untuk daftar rute topik dokumen dan implementasi kode.

---

## 1. Ringkasan Proyek

| Aspek | Detail Teknis |
|---|---|
| **Nama Proyek** | Rental Apartemen / Livirooms Multi-Accommodation Platform |
| **Tipe Akomodasi** | Apartemen, Rumah, Villa, Hotel Residence, Guest House, Kost Eksklusif, **Hotel (OTA Mode)** |
| **Periode Sewa** | Harian · Mingguan · Bulanan · Tahunan |
| **Platform** | Mobile App (Flutter) + Admin Panel (Laravel 12 / Livewire 4) + Corporate Web |
| **Basis Data** | PostgreSQL (21 tabel ternormalisasi 3NF untuk entitas produk) |
| **Payment Gateway** | Midtrans Snap (VA, QRIS, E-Wallet, Kartu Kredit) dengan Webhook S2S terverifikasi |
| **Autentikasi** | Laravel Sanctum (API Mobile) + Session & Spatie Permission (Admin Panel) |

---

## 2. Arsitektur Sistem

```
┌───────────────────────────────────────────────────────────────────────────────────┐
│                              API Gateway (Laravel 12)                             │
│       Routes: /api/v1/* (Sanctum / Public) + /admin/* (Session / Livewire 4)      │
│       Layer: Controller → Eloquent Model (21 Normalized Tables) → API Resources   │
└────────────────────────────────────────┬──────────────────────────────────────────┘
                                         │
                 ┌───────────────────────┼────────────────────────┐
                 ▼                       ▼                        ▼
       ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
       │   Mobile App     │    │   Admin Panel    │    │   Midtrans Snap  │
       │   (Flutter)      │    │(Livewire Wizards)│    │(Payment Gateway) │
       └──────────────────┘    └──────────────────┘    └──────────────────┘
```

---

## 3. Stack Teknologi Terpasang

### Backend (Laravel 12)
- **Framework:** `laravel/framework ^12.0`
- **Autentikasi API:** `laravel/sanctum ^4.3`
- **UI Admin Panel:** `livewire/livewire ^4.3` (Livewire 4)
- **Tabel Server-side:** `yajra/laravel-datatables-* ^12`
- **Otorisasi:** `spatie/laravel-permission ^6.9`
- **Payment Gateway:** `midtrans/midtrans-php ^2.6`
- **PDF Generation:** `barryvdh/laravel-dompdf`
- **Basis Data:** PostgreSQL (Production)

### Mobile (Flutter)
- **Framework:** Flutter SDK `>=3.19.0`
- **State Management:** `provider ^6.1.2`
- **HTTP Client:** `http ^1.2.1`
- **In-App Payment WebView:** `webview_flutter ^4.13.0`
- **Deep Link Handler:** `app_links ^6.3.2` (`livirooms://payment-result`)

---

## 4. Struktur Database & Model (21 Tabel Ternormalisasi)

Data modeling akomodasi menggunakan arsitektur 3NF terpadu berbasis 1 tabel akar `accommodations` dan 20 tabel satelit:
1. `accommodations` (Entitas akar, diskriminator `booking_mode`: `room` vs `unit`)
2. `building_lists` (Master gedung/tower)
3. `unit_types` (Sumber tunggal harga, kapasitas, dan tipe kamar)
4. `unit_type_prices` (Tarif harian/mingguan/bulanan)
5. `unit_type_images` (Foto tipe kamar)
6. `facility_groups` (Grup kategori fasilitas)
7. `facility_items` (Item fasilitas dengan `context`: `facility`, `furniture`, `spec`)
8. `facility_tags` (Tag fasilitas ringkas)
9. `galleries` (Galeri foto resmi dan foto tamu)
10. `reviews` & `review_photos` (Ulasan seragam skala 1-10)
11. `accommodation_policies` (Kebijakan umum, check-in, dan deposit)
12. `accommodation_questions` (Q&A manager & user)
13. `nearby_points` (Titik minat & transportasi sekitar)
14. `room_furniture_groups` & `room_furniture_items` (Furnitur per ruangan & bed config)
15. `bed_facilities` (Ringkasan tipe ranjang)
16. `accommodation_description_paragraphs` (Paragraf tambahan)
17. `accommodation_details`, `accommodation_detail_groups`, `accommodation_detail_lines` (Rincian spesifikasi & biaya kompleks)

---

## 5. Administrasi & Livewire Form Wizards

Pendaftaran dan pengeditan akomodasi dilakukan melalui form wizard multi-step yang intuitif:
- **Accommodation Wizard (Unified):** [`App\Livewire\Accommodations\WizardForm`](file:///d:/Project/Fastwork/rental.apartemen/laravel/app/Livewire/Accommodations/WizardForm.php)

Setiap wizard mengelola state transaksional yang aman (`DB::transaction`), upload multi-file foto, validasi per-tab, dan otorisasi role Spatie.

## 6. Skill (Optional will added later)
1. Adversarial 
Mengulitii dan "menyerang" hasil kerjaan untuk mencari kelemahan, celah keamanan, bug, dan lain-lain

2. Multi-Agent Debate
Beberapa agent mencoba pendekatan berbeda dan saling mengkritik sebelum mengambil kesimpulan

3. Safety Net
Membaut checkpoint supaya perubahan berisiko bisa di rollback kalau ada error

4. Skill Security Scan
Memeriksa skill/plugin pihak ketiga sebelum kamu install

5. Scheduled SOP 
Mengubah workflow/SOP menjadi routine yang bisa di jalankan secara terjadwal