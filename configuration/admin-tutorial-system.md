# Admin Page Tutorial & Guide System

Sistem **Panduan Halaman Admin** (Admin Tutorial Modal) dirancang untuk memberikan panduan operasional instan, ringkasan alur kerja, daftar aksi penting, serta batasan aturan bisnis (*domain invariants*) bagi tim Administrator dan Host pada seluruh antarmuka panel admin Livirooms.

---

## 1. Arsitektur Komponen

Sistem terdiri dari 4 berkas modular:

1. **`App\Services\AdminTutorialService`**
   - Registry data tutorial per route admin (`admin.properties.*`, `admin.bookings.*`, `admin.payments.*`, `admin.withdrawals.*`, dll).
   - Memetakan route name aktif ke panduan terkait secara instan tanpa query database (O(1) in-memory resolution).
   - Menyediakan fallback cerdas untuk modul admin baru.

2. **`resources/views/admin/partials/_page-tutorial-button.blade.php`**
   - Tombol pemicu dengan styling Metronic 8: `btn btn-sm btn-flex btn-light-primary fw-bold`.
   - Menggunakan ikon `ki-duotone ki-information-5`.
   - Menghubungkan trigger Bootstrap 5 modal ke `#kt_modal_page_tutorial`.

3. **`resources/views/admin/partials/_page-tutorial-modal.blade.php`**
   - Modal responsif interaktif yang menampilkan 4 tab komprehensif:
     - **Tab 1: Tujuan & Ringkasan**: Penjelasan fungsi halaman, daftar tombol penting, serta tips operasional.
     - **Tab 2: Alur Kerja (Workflow)**: Timeline berurutan langkah demi langkah.
     - **Tab 3: Aturan & Invariants**: Peringatan batas sistem (misal: Midtrans callback webhook, Hotel vs Property, SoftDeletes).
     - **Tab 4: Glosarium Status**: Tabel warna badge dan arti masing-masing status.

4. **`resources/views/components/admin-tutorial-modal.blade.php`**
   - Komponen Blade `<x-admin-tutorial-modal />` untuk kemudahan pemanggilan manual di mana pun.

---

## 2. Cara Kerja Integrasi Otomatis

Secara global, tombol panduan dipasang pada container toolbar aplikasi:
`resources/views/layout/partials/sidebar-layout/_toolbar.blade.php`

```blade
<!--begin::Actions-->
<div class="d-flex align-items-center gap-2 gap-lg-3">
    @yield('toolbar_actions')
    @include('admin.partials._page-tutorial-button')
</div>
<!--end::Actions-->
```

Karena setiap halaman admin dibungkus oleh `<x-default-layout>`, tombol **Panduan Halaman** otomatis muncul di pojok kanan atas toolbar halaman berdampingan dengan Page Title & Breadcrumbs.

---

## 3. Menambahkan Panduan untuk Modul Baru

Untuk menambahkan panduan modul admin baru, tambahkan entri pada method `getTutorialRegistry()` di file [`app/Services/AdminTutorialService.php`](file:///D:/Project/Fastwork/rental.apartemen/laravel/app/Services/AdminTutorialService.php):

```php
'admin.nama-modul.*' => [
    'module_id' => 'nama-modul',
    'title' => 'Judul Halaman',
    'badge' => 'Kategori Modul',
    'badge_color' => 'primary', // primary|success|info|warning|danger|dark
    'purpose' => 'Penjelasan fungsi halaman...',
    'workflow' => [
        [
            'step' => 1,
            'title' => 'Langkah Pertama',
            'description' => 'Penjelasan langkah...',
            'icon' => 'notepad-edit',
        ],
    ],
    'key_actions' => [
        [
            'label' => 'Nama Tombol',
            'badge' => 'badge-light-primary',
            'description' => 'Fungsi tombol...',
        ],
    ],
    'business_rules' => [
        'Aturan invariant 1...',
    ],
    'status_glossary' => [
        [
            'status' => 'Aktif',
            'badge_class' => 'badge-light-success',
            'meaning' => 'Artinya...',
        ],
    ],
    'tips' => [
        'Tips operasional...',
    ],
],
```

---

## 4. Keamanan & Performa

- **Sanitasi XSS**: Data tutorial dirender dengan escaping standar Blade `{{ }}` dan ikon statis terverifikasi.
- **Otorisasi**: Seluruh view berada dalam wrapper `<x-default-layout>` yang diproteksi oleh middleware `auth` dan `role:admin|host`.
- **Zero Overhead**: Tidak ada query database tambahan saat membuka halaman atau memuat modal.
