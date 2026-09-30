# Sistem Panduan & Tutorial Panel Admin & Wizard Livewire

Dokumentasi implementasi fitur bantuan instruksional, panduan halaman (Page Tutorial), dan overlay panduan interaktif pada panel web administrator Livirooms.

---

## 1. Latar Belakang & Masalah Arsitektur

### A. Masalah Nested Modal Bootstrap 5
Pada formulir registrasi dan edit akomodasi [wizard_form.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/livewire/accommodations/wizard_form.blade.php), wizard formulir di-render di dalam modal utama (`#kt_modal_accommodation_wizard`).

Ketika tombol *"Panduan Wizard"* memicu modal baru (`#kt_modal_wizard_tutorial`), terjadi konflik *nested modal* pada Bootstrap 5:
1. **Backdrop Stacking & Click Blocking**: Backdrop modal kedua menumpuk di atas modal pertama atau mengunci interaksi pengguna.
2. **Focus Trap Conflict**: Focus trap Bootstrap 5 menyebabkan keyboard cycling terjebak atau crash.
3. **Scroll Lock Loss**: Saat modal tutorial ditutup (`data-bs-dismiss="modal"`), Bootstrap otomatis menghapus kelas `.modal-open` dari elemen `<body>`, membekukan kemampuan scroll pada modal wizard utama di bawahnya.
4. **Resiko Kehilangan State Livewire**: Re-render atau backdrop dismissal dapat memicu re-inisialisasi komponen Livewire.

---

## 2. Solusi: In-Modal Overlay Panel (Zero-Conflict Pattern)

Alih-alih menggunakan modal kedua, tombol "Panduan Wizard" memanfaatkan **In-Modal Overlay Panel** (`#kt_wizard_tutorial_overlay`) yang ditempatkan secara langsung di dalam kontainer `.modal-content` modal wizard utama.

### Spesifikasi Teknis:
- **Kontainer Induk**: `.modal-content` dilengkapi kelas `position-relative overflow-hidden` dan `style="min-height: 580px;"`.
- **Elemen Overlay**: 
  ```html
  <div id="kt_wizard_tutorial_overlay" class="d-none position-absolute top-0 start-0 w-100 h-100 bg-white d-flex flex-column" wire:ignore style="z-index: 1050; border-radius: inherit;">
  ```
- **Karakteristik & Keunggulan**:
  1. **Zero-Backdrop**: Tidak memicu backdrop Bootstrap baru sehingga tidak mengganggu scroll modal utama.
  2. **100% State Preserved**: Pengguna dapat membaca panduan dan langsung kembali ke form tanpa kehilangan input apa pun yang sedang diketik (`wire:ignore` mencegah modifikasi DOM oleh Livewire).
  3. **Seamless Navigation**: Menyediakan navigasi tab Bootstrap 5 (Model Unit vs Room, 7 Langkah PMS, Status & Validasi) secara penuh di dalam modal wizard.
  4. **Dedicated Dismissal Handler**: 
     - Tombol *"Kembali ke Formulir"* dan *"Saya Mengerti & Lanjutkan Pengisian"* langsung menyembunyikan overlay.
     - Event listener tombol `Escape` menangkap event secara defensif untuk hanya menutup overlay panduan tanpa menutup modal wizard induk.
     - Event listener jQuery `hidden.bs.modal` pada modal wizard mereset status overlay secara otomatis.

---

## 3. Sistem "Panduan Halaman" Global (Page Tutorial System)

Untuk halaman-halaman tabel indeks panel admin, diterapkan komponen modular reusable:
- **Partial**: [admin/partials/_page-tutorial-button.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/partials/_page-tutorial-button.blade.php)
- **Komponen**:
  1. Tombol pemicu dengan styling standar Metronic 8 (`btn btn-sm btn-light-primary fw-bold`).
  2. Modal instruksional Bootstrap 5 dengan desain seragam (ikon, badge, timeline alur kerja, tabel aturan bisnis, dan alert mitigasi).

### Cakupan Halaman:
1. **Manajemen Properti**: [properties/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/properties/index.blade.php) (Panduan listing, diskriminator, & sinkronisasi harga)
2. **Pemesanan (Bookings)**: [bookings/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/bookings/index.blade.php) & [bookings/show.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/bookings/show.blade.php) (Alur status Midtrans, validasi check-in/out, refund)
3. **Manajemen Pengguna & Izin**: [users/list.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/user-management/users/list.blade.php) & [permissions/list.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/user-management/permissions/list.blade.php) (RBAC Spatie, penetapan hak akses)
4. **Halaman CMS & Konten**: [cms_pages/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/cms_pages/index.blade.php)
5. **Log Notifikasi**: [notification_logs/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/notification_logs/index.blade.php) (FCM & SMS broadcast auditing)
6. **Pusat Bantuan (FAQ)**: [faqs/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/faqs/index.blade.php)
7. **Daftar Gedung**: [building-lists/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/building-lists/index.blade.php)
8. **Rekomendasi Akomodasi**: [accommodation_recommendations/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/accommodation_recommendations/index.blade.php)
9. **Log Pencarian**: [accommodation_search_logs/index.blade.php](file:///d:/Project/Fastwork/rental.apartemen/laravel/resources/views/admin/accommodation_search_logs/index.blade.php)
