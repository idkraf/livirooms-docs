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


