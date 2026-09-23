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

## 6. Ground Rules Livirooms: 5 Pilar Protokol Pengembangan Tingkat Lanjut (Mandatory Engineering Protocols)

Seluruh proses analisis, perancangan arsitektur, penulisan kode, refactoring, dan audit pada ekosistem **Livirooms (`com.liviroom.app`)** — baik pada backend Laravel maupun mobile Flutter — wajib tunduk pada **5 Pilar Protokol Pengembangan Tingkat Lanjut Livirooms**:

### 1. Adversarial (Critical Code Review & Vulnerability Hunt)
- **Tujuan:** Menguji batas (*boundary testing*), menguliti, dan secara kritis "menyerang" implementasi kode sendiri sebelum disetujui (*zero-tolerance regression*).
- **Fokus Pemeriksaan:**
  - **Keamanan & Autorisasi:** Validasi IDOR pada seluruh endpoint berbasis resource (`host_id === auth()->id()`), perlindungan SQL injection, mass assignment guard (`$fillable`), dan integritas token Sanctum / Midtrans.
  - **Memory Leak & Resource Management:** Pembersihan `StreamSubscription`, `TextEditingController`, `AnimationController`, dan `ScrollController` pada lifecycle `dispose()` Flutter, serta pembersihan listener dan koneksi unclosed.
  - **State Machine Integrity:** Verifikasi state transitions (Provider, Livewire reactive state, status booking/order) agar terbebas dari race condition atau state yatim piatu (*orphaned state*).
  - **Android 14/15 Permission & OS Limits:** Penanganan izin granular (`READ_MEDIA_IMAGES`), `POST_NOTIFICATIONS`, Foreground Service Types terdaftar di AndroidManifest (`android:foregroundServiceType`), Photo Picker fallback, serta adaptasi Doze Mode.
- **Rujukan Operasional:** [`workflows/code-review-sop.md`](workflows/code-review-sop.md).

### 2. Multi-Agent Debate (Multi-Perspective Architecture Discussion)
- **Tujuan:** Mengkaji dan mendebat keputusan arsitektur kompleks dari berbagai sudut pandang sebelum satu baris kode pun ditulis.
- **Perspektif / Agen yang Terlibat:**
  - **Performance Optimization Expert:** Menilai latensi jaringan, query N+1 Eloquent, efisiensi indexing PostgreSQL, caching layer (Redis), widget rebuild cost di Flutter, dan target rendering 60/120 FPS.
  - **Security & Privacy Advocate:** Menilai kepatuhan privasi (UU PDP / GDPR), enkripsi data sensitif (at rest via `flutter_secure_storage` & in transit TLS), pembatasan akses hak istimewa (least privilege), dan integritas webhook Midtrans S2S.
  - **UX & Frontend Specialist:** Memastikan responsivitas UI, penanganan error state yang informatif bagi pengguna, konsistensi design tokens, dan kelancaran navigasi antar-layar (deep linking & tab preservation).
- **Hasil Wajib:** Sintesis konsensus arsitektural yang mendokumentasikan tradeoff yang dipilih sebelum eksekusi.
- **Rujukan Operasional:** [`workflows/agent-architecture.md`](workflows/agent-architecture.md).

### 3. Safety Net (Checkpoint & Rollback Strategy)
- **Tujuan:** Menjamin stabilitas sistem dengan memecah setiap modifikasi skala menengah hingga besar menjadi langkah-langkah modular yang terisolasi dan dapat dibatalkan (*reversible*).
- **Mekanisme Penerapan:**
  - **Atomic Modular Steps:** Hindari perubahan monolitik; pecah perubahan menjadi modul-modul independen (misal: integrasi Media3 Transformer, pembaruan Foreground Service, atau refactoring skema pembayaran).
  - **Comprehensive Error Boundaries & Fallback:** Setiap service call wajib membungkus operasi berisiko tinggi dengan `try-catch`, menyediakan safe fallback data/UI, serta mencatat telemetry log yang jelas tanpa membuat aplikasi crash.
  - **Checkpoint & Rollback Plan:** Sebelum menerapkan perubahan berisiko tinggi, tetapkan checkpoint (Git branching/tagging atau commit isolasi) sehingga jika terjadi regresi atau kegagalan kompatibilitas, rollback dapat dilakukan seketika tanpa merusak modul yang sudah stabil.
- **Rujukan Operasional:** [`workflows/safety-net-rollback.md`](workflows/safety-net-rollback.md).

### 4. Skill & Dependency Security Scan
- **Tujuan:** Memvalidasi kredibilitas, keamanan, dan efisiensi setiap dependensi atau plugin pihak ketiga sebelum dimasukkan ke dalam `pubspec.yaml` (Flutter) atau `composer.json` (Laravel).
- **Parameter Audit Wajib:**
  - **Kredibilitas & Maintenance:** Memeriksa reputasi publisher, skor pub.dev / Packagist, riwayat rilis, dan aktivitas maintenance dalam 6 bulan terakhir.
  - **Kompatibilitas Platform:** Mendukung penuh Dart 3 *sound null-safety*, kompatibilitas dengan Android SDK 34/35+ (Java 17/Kotlin modern), serta kestabilan pada iOS.
  - **Dampak Ukuran & Performa:** Menghitung estimasi pertambahan ukuran binary (APK/AAB/IPA) serta overhead konsumsi RAM/CPU saat runtime. Hindari library berukuran besar untuk utilitas sepele.
  - **Audit Kerentanan (CVE):** Bebas dari kerentanan keamanan yang dilaporkan, lisensi open source yang aman (MIT/Apache 2.0/BSD), dan tidak menyisipkan pelacak/telemetri tersembunyi.

### 5. Scheduled SOP (Routine Workflow Enforcement)
- **Tujuan:** Menjalankan 4 fase alur kerja berjenjang secara berurutan dan terdisiplin pada setiap siklus implementasi atau refactoring modul:
  - **Fase 1: Analisis & Perdebatan (Multi-Agent Debate)** — Bedah requirement, bandingkan pendekatan arsitektural (Performance vs Security vs UX), tentukan solusi terbaik sebelum pengkodean.
  - **Fase 2: Pembuatan Kode Modular dengan Checkpoint (Safety Net)** — Implementasikan kode secara modular, pasang try-catch/fallback guards, dan siapkan titik isolasi rollback yang aman.
  - **Fase 3: Pemeriksaan Keamanan & Dependensi (Skill Security Scan)** — Audit library/plugin yang dibutuhkan sebelum `pub get` atau `composer require`, pastikan null-safety, ukuran, dan perizinan telah teruji.
  - **Fase 4: Pengujian Celah & Ketahanan Kode (Adversarial Audit)** — Lakukan uji batas kritis, periksa kebocoran memori, audit siklus hidup state/controller, verifikasi izin Android 14/15, serta jalankan `flutter analyze` / `flutter test` / `php artisan test`.
- **Rujukan Operasional:** [`workflows/execution-roadmap.md`](workflows/execution-roadmap.md).