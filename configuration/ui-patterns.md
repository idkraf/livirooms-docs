# Standard UI Patterns

Dokumen ini mendefinisikan pola UI standar untuk blade admin Laravel. Semua blade baru harus mengikuti pola ini agar konsisten.

## Daftar Isi

- [Layout Wrapper](#1-layout-wrapper)
- [Pola Index / DataTable (List)](#2-pola-index--datatable-list)
- [Pola Action Column (DataTable)](#3-pola-action-column-datatable)
- [Pola Form (Livewire Modal)](#4-pola-form-livewire-modal)
- [Pola Show / Detail Page](#5-pola-show--detail-page)
- [Pola Multi-Step Form Wizard (Property & Hotel)](#6-pola-multi-step-form-wizard-property--hotel)
- [Checklist Blade Baru](#checklist-blade-baru)

## 1. Layout Wrapper

Semua halaman admin dibungkus dengan layout default:

```blade
<x-default-layout>

    @section('title', 'Page Title')

    <!-- Konten di sini -->

</x-default-layout>
```

- `title`: String judul halaman.
- `breadcrumbs`: Render breadcrumb dari package `diegoegidio/laravel-breadcrumbs`. Pastikan route breadcrumb terdaftar di `routes/breadcrumbs.php`.

---

## 2. Pola Index / DataTable (List)

### 2.1 Struktur Card DataTable

Pola standar untuk halaman daftar dengan DataTables:

```blade
<x-default-layout>

    @section('title', 'Resource Name')

    <div class="card">
        <div class="card-header border-0 pt-6">
            <div class="card-title">
                <div class="d-flex align-items-center position-relative my-1">
                    {!! getIcon('magnifier', 'fs-3 position-absolute ms-5') !!}
                    <input type="text" data-kt-user-table-filter="search" class="form-control form-control-solid w-250px ps-13" placeholder="Search..." id="mySearchInput"/>
                </div>
            </div>
            <div class="card-toolbar">
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#kt_modal_add_resource">
                    {!! getIcon('plus', 'fs-2', '', 'i') !!}
                    Add Resource
                </button>
            </div>
        </div>
        <div class="card-body py-4">
            <div class="table-responsive">
                {!! $dataTable->table() !!}
            </div>
        </div>
    </div>

    @push('scripts')
        {!! $dataTable->scripts() !!}
        <script>
            document.getElementById('mySearchInput').addEventListener('keyup', function () {
                window.LaravelDataTables['resource-table'].search(this.value).draw();
            });
        </script>
    @endpush

</x-default-layout>
```

### 2.2 Alternatif Index Sederhana

Jika tidak butuh search + modal, gunakan struktur minimal:

```blade
<x-default-layout>

    @section('title', 'Resource Name')

    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Resource Name</h5>
            <a href="{{ route('admin.resource.create') }}" class="btn btn-primary btn-sm">+ Tambah</a>
        </div>
        <div class="card-body">
            {!! $dataTable->table() !!}
        </div>
    </div>

    @push('scripts')
        {!! $dataTable->scripts() !!}
    @endpush

</x-default-layout>
```

---

## 3. Pola Action Column (DataTable)

Setiap DataTable memiliki kolom aksi. File blade action disimpan di:
```
resources/views/admin/{module}/columns/_actions.blade.php
```

### 3.1 Standar Action Column

```blade
<a href="{{ route('admin.resource.edit', $resource) }}" class="btn btn-sm btn-warning">Edit</a>
<form action="{{ route('admin.resource.destroy', $resource) }}" method="POST" class="d-inline" onsubmit="return confirm('Hapus data ini?')">
    @csrf
    @method('DELETE')
    <button type="submit" class="btn btn-sm btn-danger">Hapus</button>
</form>
```

- Variabel `$resource` harus sesuai dengan nama variabel yang di-pass di DataTable.
- Route `edit` dan `destroy` harus terdaftar di `routes/admin_generated.php`.

### 3.2 Contoh Variabel per Modul

| Modul | Variabel | Route Prefix |
|-------|----------|--------------|
| users | `$user` | `admin.users` |
| properties | `$property` | `admin.properties` |
| bookings | `$booking` | `admin.bookings` |
| payments | `$payment` | `admin.payments` |
| orders | `$order` | `admin.orders` |
| banners | `$banner` | `admin.banners` |
| referrals | `$referral` | `admin.referrals` |

---

## 4. Pola Modal (Create / Edit)

### 4.1 Struktur Modal Standar

```blade
<div class="modal fade" id="kt_modal_add_resource" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered mw-650px">
        <div class="modal-content">
            <div class="modal-header" id="kt_modal_add_resource_header">
                <h2 class="fw-bold">Add Resource</h2>
                <div class="btn btn-icon btn-sm btn-active-icon-primary" data-bs-dismiss="modal" aria-label="Close">
                    {!! getIcon('cross','fs-1') !!}
                </div>
            </div>
            <div class="modal-body px-5 my-7">
                <form id="kt_modal_add_resource_form" class="form" wire:submit.prevent="submit">
                    <!-- Form fields here -->
                </form>
            </div>
            <div class="modal-footer flex-center">
                <button type="reset" class="btn btn-light me-3" data-bs-dismiss="modal" aria-label="Close" wire:loading.attr="disabled">Discard</button>
                <button type="submit" class="btn btn-primary" form="kt_modal_add_resource_form">
                    <span class="indicator-label" wire:loading.remove>Submit</span>
                    <span class="indicator-progress" wire:loading wire:target="submit">
                        Please wait...
                        <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
                    </span>
                </button>
            </div>
        </div>
    </div>
</div>
```

---

## 5. Pola Form (Create / Edit Page)

### 5.1 Form via Livewire Component

```blade
<x-default-layout>

    @section('title', 'Tambah Resource')

    <div class="card">
        <div class="card-header"><h5 class="mb-0">Tambah Resource</h5></div>
        <div class="card-body">
            @livewire('resource.form')
        </div>
    </div>

</x-default-layout>
```

### 5.2 Kelas Form yang Digunakan

| Kelas | Keterangan |
|-------|-----------|
| `form-control form-control-solid` | Input text/email/number standar |
| `form-select form-select-solid` | Select dropdown |
| `form-check-input` | Checkbox/radio |
| `fv-row mb-7` | Wrapper input group |
| `fs-6 fw-semibold mb-2` | Label standar |

---

## 6. Pola Show / Detail Page

```blade
<x-default-layout>

    @section('title', 'Resource Detail')

    <div class="d-flex flex-column flex-lg-row">
        <div class="flex-column flex-lg-row-auto w-lg-250px w-xl-350px mb-10">
            <div class="card mb-5 mb-xl-8">
                <div class="card-body">
                    <!-- Sidebar content here -->
                </div>
            </div>
        </div>
        <div class="flex-lg-row-fluid ms-lg-15">
            <div class="card card-flush mb-6 mb-xl-9">
                <div class="card-header pt-5">
                    <div class="card-title">
                        <h2 class="d-flex align-items-center">Title</h2>
                    </div>
                </div>
                <div class="card-body pt-0">
                    <!-- Content here -->
                </div>
            </div>
        </div>
    </div>

</x-default-layout>
```

---

## 7. Pola Kolom DataTable Kustom

### 7.1 Kolom dengan View Kustom

```php
// Di DataTable class
->editColumn('user', function (User $user) {
    return view('admin.users.columns._user', compact('user'));
})
```

```blade
<!-- resources/views/admin/users/columns/_user.blade.php -->
<div class="symbol symbol-circle symbol-50px overflow-hidden me-3">
    <!-- Avatar -->
</div>
<div class="d-flex flex-column">
    <a href="{{ route('admin.users.show', $user) }}" class="text-gray-800 text-hover-primary mb-1">
        {{ $user->name }}
    </a>
    <span>{{ $user->email }}</span>
</div>
```

### 7.2 Kolom Action dengan Raw HTML

```php
->addColumn('action', function (User $user) {
    return view('admin.users.columns._actions', compact('user'))->render();
})
->rawColumns(['action']);
```

---

## 8. Pola Script & Push

Setiap halaman yang menggunakan DataTable harus menyertakan script di `@push('scripts')`:

```blade
@push('scripts')
    {!! $dataTable->scripts() !!}
    <script>
        // Custom JS untuk DataTable search, modal reload, dll
    </script>
@endpush
```

---

## 9. Pola Ikon

Gunakan helper `getIcon()` untuk konsistensi ikon:

```blade
{!! getIcon('magnifier', 'fs-3 position-absolute ms-5') !!}
{!! getIcon('plus', 'fs-2', '', 'i') !!}
```

Format: `getIcon('icon-name', 'size-class', 'extra-class', 'tag')`

---

## 10. Pola Tabel Responsif

Semua tabel DataTable dibungkus dengan wrapper responsif:

```blade
<div class="table-responsive">
    {!! $dataTable->table() !!}
</div>
```

---

## 11. Pola Struktur Folder

```
resources/views/admin/
├── {module}/
│   ├── columns/
│   │   ├── _actions.blade.php
│   │   ├── _user.blade.php
│   │   └── _draw-scripts.js
│   ├── modals/
│   │   ├── _form.blade.php
│   │   └── _detail.blade.php
│   ├── index.blade.php
│   ├── create.blade.php
│   ├── edit.blade.php
│   └── show.blade.php
```

---

## 12. Checklist Implementasi Modul Baru

- [ ] Buat folder `resources/views/admin/{module}/`
- [ ] Buat `index.blade.php` dengan card + DataTable
- [ ] Buat `columns/_actions.blade.php` dengan variabel yang sesuai DataTable
- [ ] Buat DataTable class di `app/DataTables/{Module}DataTable.php`
- [ ] Buat Controller di `app/Http/Controllers/Admin/{Module}Controller.php`
- [ ] Daftarkan route di `routes/admin_generated.php`
- [ ] Daftarkan breadcrumb di `routes/breadcrumbs.php`
- [ ] Gunakan `<x-default-layout>` sebagai wrapper
- [ ] Include `@push('scripts')` untuk DataTable scripts
- [ ] Gunakan kelas CSS standar: `card`, `card-header`, `card-body`, `btn btn-primary`, `form-control form-control-solid`

---

## 13. Pola Livewire Modal

Semua form Create/Edit harus menggunakan Livewire modal. Livewire form component harus dibungkus dalam modal Bootstrap agar konsisten dengan UI standar.

### 13.1 Struktur Livewire Modal Component

```blade
<div class="modal fade" id="kt_modal_add_{module}" tabindex="-1" aria-hidden="true" wire:ignore.self>
    <div class="modal-dialog modal-dialog-centered mw-650px">
        <div class="modal-content">
            <div class="modal-header" id="kt_modal_add_{module}_header">
                <h2 class="fw-bold">@if({module}Id) Edit {Module Title} @else Add {Module Title} @endif</h2>
                <div class="btn btn-icon btn-sm btn-active-icon-primary" data-bs-dismiss="modal" aria-label="Close">
                    {!! getIcon('cross','fs-1') !!}
                </div>
            </div>
            <div class="modal-body px-5 my-7">
                <form id="kt_modal_add_{module}_form" class="form" wire:submit.prevent="submit">
                    <!-- Form fields here -->
                </form>
            </div>
            <div class="modal-footer flex-center">
                <button type="reset" class="btn btn-light me-3" data-bs-dismiss="modal" aria-label="Close" wire:loading.attr="disabled">Discard</button>
                <button type="submit" class="btn btn-primary" form="kt_modal_add_{module}_form">
                    <span class="indicator-label" wire:loading.remove>Submit</span>
                    <span class="indicator-progress" wire:loading wire:target="submit">
                        Please wait...
                        <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
                    </span>
                </button>
            </div>
        </div>
    </div>
</div>
```

### 13.2 Include Modal di Index Page

```blade
<livewire:{module}.{module}-modal></livewire:{module}.{module}-modal>
```

### 13.3 Action Column dengan Modal Trigger

```blade
<button type="button" class="btn btn-sm btn-warning" data-{module}-id="{{ $resource->id }}" data-bs-toggle="modal" data-bs-target="#kt_modal_add_{module}">
    Edit
</button>
```

### 13.4 Livewire Component Class

```php
protected $listeners = ['modal.show.{module_name}' => 'edit'];

public function edit({module}Id)
{
    {module}Id = {module}Id ?: null;
    // Load data...
}
```

---

## 14. Pola JavaScript (Custom App JS)

Setiap modul admin yang memiliki halaman index dengan DataTable dan/atau modal Livewire harus memiliki file JavaScript kustom di `resources/_themes/src/js/custom/apps/{module}/`.

### 14.1 Struktur Folder JS

```
resources/_themes/src/js/custom/apps/
├── {module}/
│   ├── list.js
│   ├── add.js
│   └── edit.js
```

### 14.2 Pola `list.js` (DataTable + Search)

```javascript
"use strict";

var KT{Module}List = function () {
    var table = document.getElementById('kt_table_{module}');
    var datatable;

    var initTable = function () {
        if (!table) return;
        datatable = $(table).DataTable({
            "info": false,
            'order': [],
            'columnDefs': [
                { orderable: false, targets: 0 },
            ]
        });
    }

    var handleSearchDatatable = () => {
        const filterSearch = document.querySelector('[data-kt-{module}-table-filter="search"]');
        if (filterSearch) {
            filterSearch.addEventListener('keyup', function (e) {
                datatable.search(e.target.value).draw();
            });
        }
    }

    return {
        init: function () {
            initTable();
            handleSearchDatatable();
        }
    };
}();

KTUtil.onDOMContentLoaded(function () {
    KT{Module}List.init();
});
```

### 14.3 Menyertakan JS di Controller

```php
public function index()
{
    addJavascriptFile('assets/js/custom/apps/{module}/list.js');
    return view('admin.{module}.index', compact('dataTable'));
}
```

### 14.4 Compile JS

Setiap kali menambah atau mengubah JS, jalankan:

```bash
npm run prod
```

---

## 15. Konvensi Nama Modal per Modul

| Modul | Modal ID | Data Attribute | Livewire Component |
|-------|----------|----------------|-------------------|
| audit_logs | `kt_modal_add_audit_log` | `data-auditlog-id` | `audit_logs.audit_logs-modal` |
| availabilities | `kt_modal_add_availability` | `data-availability-id` | `availabilities.availabilities-modal` |
| bookings | `kt_modal_add_booking` | `data-booking-id` | `bookings.bookings-modal` |
| payments | `kt_modal_add_payment` | `data-payment-id` | `payments.payments-modal` |
| properties | `kt_modal_add_property` | `data-property-id` | `properties.properties-modal` |
| referrals | `kt_modal_add_referral` | `data-referral-id` | `referrals.referrals-modal` |
| vouchers | `kt_modal_add_voucher` | `data-voucher-id` | `vouchers.vouchers-modal` |
| withdrawals | `kt_modal_add_withdrawal` | `data-withdrawal-id` | `withdrawals.withdrawals-modal` |

---

## 16. Pola Page Tutorial Modal (Panduan Halaman Admin)

Sistem tutorial langsung pada setiap halaman admin untuk menjelaskan fungsi halaman (*What & For What*), alur kerja operasional (*How It Works*), dan aturan bisnis serta batasan keamanan (*Rules & Invariants*).

### 16.1 Penempatan Tombol di Card Toolbar
Tombol ditempatkan berdampingan dengan tombol aksi utama pada `card-toolbar`:
```blade
<div class="card-toolbar">
    <div class="d-flex justify-content-end" data-kt-user-table-toolbar="base">
        <!-- Tombol Panduan Halaman -->
        <button type="button" class="btn btn-light-primary me-3" data-bs-toggle="modal" data-bs-target="#kt_modal_{module}_tutorial">
            {!! getIcon('information-5', 'fs-4 me-1') !!}
            Panduan Halaman
        </button>

        <!-- Tombol Aksi Utama -->
        <button type="button" class="btn btn-primary" ...>
            ...
        </button>
    </div>
</div>
```

### 16.2 Struktur Modal Panduan Standar
Modal menggunakan ID `#kt_modal_{module}_tutorial` dengan 3 tab utama:
1. **Tujuan & Peran / Apa & Untuk Apa:** Menjelaskan fungsi halaman, entitas yang dikelola, dan manfaat operasional bagi Admin/Host.
2. **Cara Kerja & Operasional:** Timeline berurutan langkah demi langkah mulai dari input, pencarian, hingga eksekusi aksi.
3. **Aturan & Keamanan:** Invariants backend, sinkronisasi peran Spatie, proteksi SoftDeletes, dan validasi basis data.

---

*Dokumen ini dibuat berdasarkan pola yang ada di `resources/views/admin/user-management/` dan modul admin lainnya.*

