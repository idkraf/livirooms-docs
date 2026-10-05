# Dokumentasi Fitur: Multi-Platform Demo Presentation

**URL Route:** `/demo` & `/demo-presentation`  
**Route Name:** `front.demo`, `front.demo-presentation`  
**Controller:** `App\Http\Controllers\Front\FrontController::demo`  
**View Blade:** `resources/views/front/demo.blade.php`  
**Tipe:** Public Interactive Product Presentation & Showcase  

---

## 1. Ringkasan Fitur

Multi-Platform Demo Presentation adalah halaman showcase interaktif berestetika tinggi (dark theme, glassmorphic accents) yang menampilkan demonstrasi alur produk Livirooms lintas platform:
1. **Mobile App Walkthrough (5 Alur Interaktif):**
   - 1. Cara Daftar Jadi Pembeli
   - 2. Cara Booking Hotel
   - 3. Cara Booking Apartemen / Villa
   - 4. Cara Daftar Jadi Host
   - 5. Cara Upload Akomodasi
2. **Web Portal Demo (2 Alur Interaktif):**
   - 1. Admin Dashboard Overview
   - 2. Managing User Data

---

## 2. Struktur Komponen UI & Visual Mockup

### A. Phone Mockup (Mobile App)
- **Desain:** iPhone style mockup dimensi 320x650px dengan notch atas, radius 45px, border bezel 12px, serta drop shadow dengan pantulan cahaya biru (`rgba(47, 129, 247, 0.15)`).
- **Video Swiper:** Swiper v11 terintegrasi dengan pemutaran otomatis, loop, mute, dan kendali play/pause saat slide diklik.

### B. Browser Mockup (Web Portal)
- **Desain:** Desktop browser mockup dengan rasio aspek 16:9, tab bar dengan traffic light dots (Merah, Kuning, Hijau yang dapat diklik untuk fullscreen), serta URL bar `https://livirooms.com/admin`.
- **Ekspansi Layout Responsif:** Saat beralih ke tab Web Portal, kontainer bertransisi halus menjadi tata letak lebar (hingga 1200px) untuk keterbacaan presentasi stakeholder.

### C. Kontrol Navigasi & Pintasan Keyboard
- **Tombol UI:** Previous, Next Step, Fullscreen Toggle, dan indikator slide (`X / N`).
- **Keyboard Shortcuts:**
  - `←` / `→` atau `Spasi`: Navigasi slide berikutnya/sebelumnya.
  - `M`: Beralih langsung ke tab Mobile App.
  - `W`: Beralih langsung ke tab Web Portal.
  - `F`: Toggle Fullscreen video.

---

## 3. Integrasi Kode, Storage Video & Streaming

### A. Lokasi File Video Storage
File video demonstrasi disimpan di direktori internal Laravel:
`storage/app/private/video/` (misal `1.mp4`, `2.mp4`).

### B. Endpoint Video Streaming
Rute `GET /demo/video/{filename}` didaftarkan untuk streaming video secara aman dengan dukungan header HTTP byte-range (`Accept-Ranges: bytes`) agar pemutar video HTML5 dapat melakukan buffering dan seeking:

```php
Route::get('demo/video/{filename}', [FrontController::class, 'demoVideo'])->name('front.demo.video');
```

```php
// app/Http/Controllers/Front/FrontController.php
public function demoVideo(string $filename)
{
    $filename = basename($filename);
    $extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));

    if (!in_array($extension, ['mp4', 'webm', 'ogg', 'mov'])) {
        abort(403, 'Invalid video format');
    }

    $path = storage_path('app/private/video/' . $filename);
    if (!file_exists($path)) {
        abort(404, 'Video not found');
    }

    return response()->file($path, [
        'Content-Type' => 'video/mp4',
        'Accept-Ranges' => 'bytes',
    ]);
}
```

### C. Dynamic Fallback & Resolution
Jika file video fisik (seperti `1.mp4`, `2.mp4`) ada di storage, sistem otomatis menggunakannya dan menandai `in_progress = false` (badge: *"Video Ready (Storage)"*). Untuk slide yang videonya masih dalam tahap proses, sistem otomatis memakai fallback sample video dengan penanda `in_progress = true` (badge: *"On Progress (Preview)"*). Begitu file video baru dimasukkan ke direktori storage, sistem langsung mendeteksinya tanpa perlu mengubah kode.

---

## 4. Buku Panduan & Dokumentasi Sistem (PDF Private Storage)

### A. Lokasi Dokumen & Inventaris PDF
File PDF tersimpan secara aman di dalam storage private Laravel:
`storage/app/private/documentation/`
1. `livirooms_documentation.pdf` — Arsitektur sistem lengkap, database 3NF, dan kontrak API.
2. `user-guide-mobile-app.pdf` — Buku panduan aplikasi mobile pelanggan / tamu.
3. `user_guide_host_mobile_app.pdf` — Buku panduan aplikasi mobile mitra host pemilik properti.
4. `user_guide_worker.pdf` — Panduan operasional Laravel worker, antrean background, & cronjob.
5. `user-guide-web-administrator.pdf` — Buku panduan portal web administrator & Metronic back-office.

### B. Endpoint Serving & Streaming PDF Aman
Rute `GET /demo/documentation/{filename}` didaftarkan untuk menyajikan dokumen PDF secara aman:
```php
Route::get('demo/documentation/{filename}', [FrontController::class, 'demoDoc'])->name('front.demo.doc');
```

Implementasi di `FrontController::demoDoc`:
- Sanitasi nama file menggunakan `basename()` untuk mitigasi serangan *path traversal* (LFD/Directory Traversal).
- Validasi ekstensi strictly `.pdf`.
- Validasi `realpath` memastikan file berada tepat di dalam folder `storage/app/private/documentation`.
- Mendukung dua mode:
  - **Inline Viewing**: Parameter standar tanpa download (`Content-Disposition: inline`) untuk pratinjau di iframe modal atau tab peramban baru.
  - **Direct Download**: Parameter `download=1` (`response()->download(...)`) untuk mengunduh berkas secara langsung.

### C. Integrasi Tab Navigasi Utama (3-Tab Architecture)
Dokumentasi telah dipindahkan menjadi tab utama setara bersama Mobile App dan Web Portal:
1. **Tabs Bar (`#tabs-wrapper`)**:
   - `Mobile App (5)` (`#tab-mobile`) — Walkthrough video interaktif aplikasi tamu Flutter dalam phone mockup.
   - `Web Portal (2)` (`#tab-web`) — Demo video interaktif portal admin back-office dalam desktop browser mockup.
   - `Documentation (5)` (`#tab-docs`) — Hub terpadu 5 buku panduan PDF dengan view container `#view-docs`.
2. **Keyboard Shortcut (`D`)**: Menekan tombol `D` pada keyboard otomatis berpindah ke tab Documentation (`M` untuk Mobile, `W` untuk Web, `F` untuk Fullscreen).
3. **Filter Kategori Dokumen**: Filter instan di dalam tab Documentation (`Semua`, `Aplikasi Mobile`, `Web Admin`, `Worker & Otomatisasi`, `Arsitektur Sistem`).
4. **5 Kartu Panduan Berestetika Tinggi**: Menampilkan badge peran pengguna, ukuran berkas dinamis, ringkasan isi, highlight tag fitur, serta tombol aksi *"Baca Online"*, *"Unduh PDF"*, dan *"Buka di Tab Baru"*.
5. **Interactive In-Modal PDF Viewer**: Pratinjau langsung di dalam halaman demo tanpa perlu meninggalkan konteks presentasi, dilengkapi tombol navigasi tab baru, unduh, dan tombol `Escape` untuk menutup.


