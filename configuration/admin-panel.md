# Admin Panel Architecture

Dokumen ini menjelaskan bagaimana data mengalir dari **Controller → DataTable → Blade View** dan bagaimana **Livewire** menangani operasi add/edit (termasuk file uploads) di admin panel. Dokumen ini berfungsi sebagai **role model untuk membangun semua 24 modul** yang tercantum di project README.

**Canonical reference implementation:** `resources/views/admin/user-management/`. Folder ini berisi working patterns yang digunakan di seluruh project:
- **Pattern A (Users)**: DataTable + standalone Livewire modal (`AddUserModal`)
- **Pattern B (Roles)**: Pure Livewire list (`RoleList`) + standalone modal (`RoleModal`), no DataTable
- **Pattern C (Permissions)**: DataTable + standalone Livewire modal (`PermissionModal`)
- **Pattern D (Accommodation Wizard)**: DataTable + Multi-Step Livewire Form Wizard modal (`Accommodations\WizardForm`) yang mengelola relasi kompleks 21 tabel ternormalisasi (3NF) dalam `DB::transaction`.

Semua modul harus mengikuti salah satu dari 4 patterns ini.

## Daftar Isi

- [Struktur File](#struktur-file)
- [Tiga Pattern Modul](#tiga-pattern-modul)
- [Controller Pattern](#controller-pattern)
- [DataTable Pattern (Yajra DataTables)](#datatable-pattern-yajra-datatables)
- [Blade View Pattern (DataTable Page)](#blade-view-pattern-datatable-page)
- [Livewire Component Pattern](#livewire-component-pattern)
- [Livewire Blade Pattern (Modal)](#livewire-blade-pattern-modal)
- [Modal Communication Flow](#modal-communication-flow)
- [Checklist Implementasi Modul Baru](#checklist-implementasi-modul-baru)

## Struktur File

```
laravel/
├── app/
│   ├── Http/Controllers/Admin/
│   │   ├── RoleManagementController.php
│   │   ├── UserManagementController.php
│   │   ├── PermissionManagementController.php
│   │   ├── PropertyController.php
│   │   ├── BookingController.php
│   │   ├── AvailabilityController.php
│   │   ├── PropertyPriceController.php
│   │   ├── VoucherController.php
│   │   ├── PropertyRecommendationController.php
│   │   ├── ConversationController.php
│   │   ├── FaqController.php
│   │   ├── NotificationLogController.php
│   │   ├── UserProfileController.php
│   │   ├── OrderController.php
│   │   ├── PaymentController.php
│   │   ├── PaymentMethodController.php
│   │   ├── WithdrawalController.php
│   │   ├── ReviewController.php
│   │   ├── WishlistController.php
│   │   ├── ReferralController.php
│   │   ├── BannerController.php
│   │   ├── CmsPageController.php
│   │   ├── AuditLogController.php
│   │   ├── PropertySearchLogController.php
│   │   └── ReportController.php
│   ├── DataTables/
│   │   ├── PermissionsDataTable.php
│   │   ├── UsersAssignedRoleDataTable.php
│   │   ├── UsersDataTable.php
│   │   ├── PropertyDataTable.php
│   │   ├── BookingDataTable.php
│   │   ├── AvailabilityDataTable.php
│   │   ├── PropertyPriceDataTable.php
│   │   ├── VoucherDataTable.php
│   │   ├── PropertyRecommendationDataTable.php
│   │   ├── ConversationDataTable.php
│   │   ├── FaqDataTable.php
│   │   ├── NotificationLogDataTable.php
│   │   ├── UserProfileDataTable.php
│   │   ├── OrderDataTable.php
│   │   ├── PaymentDataTable.php
│   │   ├── PaymentMethodDataTable.php
│   │   ├── WithdrawalDataTable.php
│   │   ├── ReviewDataTable.php
│   │   ├── WishlistDataTable.php
│   │   ├── ReferralDataTable.php
│   │   ├── BannerDataTable.php
│   │   ├── CmsPageDataTable.php
│   │   ├── AuditLogDataTable.php
│   │   └── PropertySearchLogDataTable.php
│   └── Livewire/
│       ├── Permission/
│       │   ├── RoleList.php
│       │   ├── RoleModal.php
│       │   └── PermissionModal.php
│       ├── User/
│       │   └── AddUserModal.php
│       ├── Properties/
│       │   ├── Form.php
│       │   └── PropertyModal.php
│       ├── Bookings/
│       │   ├── Form.php
│       │   └── BookingModal.php
│       ├── Availabilities/
│       │   ├── Form.php
│       │   └── AvailabilityModal.php
│       ├── PropertyPrices/
│       │   ├── Form.php
│       │   └── PropertyPriceModal.php
│       ├── Vouchers/
│       │   ├── Form.php
│       │   └── VoucherModal.php
│       ├── PropertyRecommendations/
│       │   ├── Form.php
│       │   └── PropertyRecommendationModal.php
│       ├── Conversations/
│       │   ├── Form.php
│       │   └── ConversationModal.php
│       ├── Faqs/
│       │   ├── Form.php
│       │   └── FaqModal.php
│       ├── NotificationLogs/
│       │   ├── Form.php
│       │   └── NotificationLogModal.php
│       ├── UserProfiles/
│       │   ├── Form.php
│       │   └── UserProfileModal.php
│       ├── Orders/
│       │   ├── Form.php
│       │   └── OrderModal.php
│       ├── Payments/
│       │   ├── Form.php
│       │   └── PaymentModal.php
│       ├── PaymentMethods/
│       │   ├── Form.php
│       │   └── PaymentMethodModal.php
│       ├── Withdrawals/
│       │   ├── Form.php
│       │   └── WithdrawalModal.php
│       ├── Reviews/
│       │   ├── Form.php
│       │   └── ReviewModal.php
│       ├── Wishlists/
│       │   ├── Form.php
│       │   └── WishlistModal.php
│       ├── Referrals/
│       │   ├── Form.php
│       │   └── ReferralModal.php
│       ├── Banners/
│       │   ├── Form.php
│       │   └── BannerModal.php
│       ├── CmsPages/
│       │   ├── Form.php
│       │   └── CmsPageModal.php
│       ├── AuditLogs/
│       │   ├── Form.php
│       │   └── AuditLogModal.php
│       └── PropertySearchLogs/
│           ├── Form.php
│           └── PropertySearchLogModal.php
└── resources/views/
    ├── admin/
    │   ├── user-management/
    │   │   ├── users/
    │   │   │   ├── list.blade.php
    │   │   │   ├── show.blade.php
    │   │   │   └── columns/
    │   │   │       ├── _user.blade.php
    │   │   │       └── _actions.blade.php
    │   │   ├── roles/
    │   │   │   ├── list.blade.php
    │   │   │   ├── show.blade.php
    │   │   │   └── columns/
    │   │   │       ├── _user.blade.php
    │   │   │       └── _actions.blade.php
    │   │   └── permissions/
    │   │       ├── list.blade.php
    │   │       └── columns/
    │   │           ├── _assign-to.blade.php
    │   │           └── _actions.blade.php
    │   ├── properties/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── bookings/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── availabilities/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── property_prices/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── vouchers/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── property_recommendations/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── conversations/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── faqs/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── notification_logs/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── user_profiles/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── orders/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── payments/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── payment_methods/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── withdrawals/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── reviews/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── wishlists/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── referrals/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── banners/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── cms_pages/
    │   │   ├── index.blade.php
    │   │   └── columns/
    │   │       └── _actions.blade.php
    │   ├── audit_logs/
    │   │   ├── index.blade.php
    │   │   └ columns/
    │   │       └── _actions.blade.php
    │   └── property_search_logs/
    │       ├── index.blade.php
    │       └── columns/
    │           └── _actions.blade.php
    └── livewire/
        ├── user/
        │   └── add-user-modal.blade.php
        ├── permission/
        │   ├── role-list.blade.php
        │   ├── role-modal.blade.php
        │   └── permission-modal.blade.php
        ├── properties/
        │   └── form.blade.php
        ├── bookings/
        │   └── form.blade.php
        ├── availabilities/
        │   └── form.blade.php
        ├── property_prices/
        │   └── form.blade.php
        ├── vouchers/
        │   └── form.blade.php
        ├── property_recommendations/
        │   └── form.blade.php
        ├── conversations/
        │   └── form.blade.php
        ├── faqs/
        │   └── form.blade.php
        ├── notification_logs/
        │   └── form.blade.php
        ├── user_profiles/
        │   └── form.blade.php
        ├── orders/
        │   └── form.blade.php
        ├── payments/
        │   └── form.blade.php
        ├── payment_methods/
        │   └── form.blade.php
        ├── withdrawals/
        │   └── form.blade.php
        ├── reviews/
        │   └── form.blade.php
        ├── wishlists/
        │   └── form.blade.php
        ├── referrals/
        │   └── form.blade.php
        ├── banners/
        │   └── form.blade.php
        ├── cms_pages/
        │   └── form.blade.php
        ├── audit_logs/
        │   └── form.blade.php
        └── property_search_logs/
            └── form.blade.php
```

### Tiga Pattern Modul

Project menggunakan **3 distinct module patterns**. Pilih yang sesuai dengan kebutuhan UI modul:

| Pattern | When to Use | List View | Add/Edit |
|---------|-------------|-----------|----------|
| **A: DataTable + Livewire Modal** | Large datasets needing search/sort/export | Yajra DataTable | Standalone Livewire modal |
| **B: Pure Livewire** | Simple card/grid layouts, small datasets | Livewire list component | Standalone Livewire modal |
| **C: Base Form + Modal Wrapper** | Reusable form logic across create/edit | Same as Pattern A | Base `Form.php` + thin `Modal.php` wrapper |

**Canonical examples:**
- Pattern A: `user-management/users` (UsersDataTable + AddUserModal)
- Pattern B: `user-management/roles` (RoleList + RoleModal)
- Pattern C: Most CRUD modules (e.g., Properties, Bookings)

---

## Controller Pattern

Controllers di admin panel adalah **thin**. Mereka terutama merender views dan delegasi data rendering ke DataTables atau Livewire components.

### Pattern A: DataTable Controller (Users, Permissions, dan kebanyakan modul CRUD)

```php
<?php

namespace App\Http\Controllers\Admin;

use App\DataTables\UsersDataTable;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class UserManagementController extends Controller
{
    public function index(UsersDataTable $dataTable)
    {
        return $dataTable->render('admin.user-management.users.list');
    }

    public function show(User $user)
    {
        return view('admin.user-management.users.show', compact('user'));
    }

    // CRUD stubs — actual logic handled by Livewire modal
    public function create() {}
    public function store(Request $request) {}
    public function edit(User $user) {}
    public function update(Request $request, User $user) {}
    public function destroy(User $user) {}
}
```

### Pattern B: Pure Livewire Controller (Roles)

```php
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;

class RoleManagementController extends Controller
{
    public function index()
    {
        return view('admin.user-management.roles.list');
    }

    public function show(Role $role, UsersAssignedRoleDataTable $dataTable)
    {
        return $dataTable->with('role', $role)
            ->render('admin.user-management.roles.show', compact('role'));
    }

    // CRUD stubs — actual logic handled by Livewire modal
    public function create() {}
    public function store(Request $request) {}
    public function edit(Role $role) {}
    public function update(Request $request, Role $role) {}
    public function destroy(Role $role) {}
}
```

### Pattern C: Permission-Style Controller

```php
<?php

namespace App\Http\Controllers\Admin;

use App\DataTables\PermissionsDataTable;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PermissionManagementController extends Controller
{
    public function index(PermissionsDataTable $dataTable)
    {
        return $dataTable->render('admin.user-management.permissions.list');
    }

    public function show(string $id) {}

    // CRUD stubs — actual logic handled by Livewire modal
    public function create() {}
    public function store(Request $request) {}
    public function edit(string $id) {}
    public function update(Request $request, string $id) {}
    public function destroy(string $id) {}
}
```

**Key rules:**
- `index()` returns a Blade view that embeds a DataTable and/or Livewire component
- `show()` returns a detail view, optionally with a sub-DataTable
- Actual add/edit/delete logic is handled by **Livewire**, not the controller
- `create()`, `store()`, `edit()`, `update()`, `destroy()` can remain empty stubs
- Route model binding is used where applicable (e.g., `User $user`, `Role $role`)

---

## DataTable Pattern (Yajra DataTables)

DataTables handle **server-side rendering** of tabular data with search, sort, and pagination.

### Contoh: `PermissionsDataTable.php`

```php
<?php

namespace App\DataTables;

use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Spatie\Permission\Models\Permission;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class PermissionsDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->editColumn('name', function (Permission $permission) {
                return ucwords($permission->name);
            })
            ->addColumn('assigned_to', function (Permission $permission) {
                $roles = $permission->roles;
                return view('admin.user-management.permissions.columns._assign-to', compact('roles'));
            })
            ->editColumn('created_at', function (Permission $permission) {
                return $permission->created_at->format('d M Y, h:i a');
            })
            ->addColumn('actions', function (Permission $permission) {
                return view('admin.user-management.permissions.columns._actions', compact('permission'));
            })
            ->setRowId('id');
    }

    public function query(Permission $model): QueryBuilder
    {
        return $model->newQuery()->with('roles');
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()
            ->setTableId('permissions-table')
            ->columns($this->getColumns())
            ->minifiedAjax()
            ->dom('rt' . "<'row'<'col-sm-12 col-md-5'l><'col-sm-12 col-md-7'p>>",)
            ->addTableClass('table align-middle table-row-dashed fs-6 gy-5 dataTable no-footer text-gray-600 fw-semibold')
            ->setTableHeadClass('text-start text-muted fw-bold fs-7 text-uppercase gs-0')
            ->orderBy(0)
            ->drawCallback("function() {" . file_get_contents(resource_path('views/admin/user-management/permissions/columns/_draw-scripts.js')) . "}")
            ->parameters(['destroy' => true]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('name'),
            Column::make('assigned_to'),
            Column::make('created_at')->addClass('text-nowrap'),
            Column::computed('actions')
                ->addClass('text-end text-nowrap')
                ->exportable(false)
                ->printable(false),
        ];
    }

    protected function filename(): string
    {
        return 'Permissions_' . date('YmdHis');
    }
}
```

---

## Blade View Pattern (DataTable Page)

### Contoh: `admin/user-management/permissions/list.blade.php`

```blade
<x-default-layout>

    @section('title')
        Permissions
    @endsection

    @section('breadcrumbs')
        {{ Breadcrumbs::render('user-management.permissions.index') }}
    @endsection

    <div class="card">
        <div class="card-header border-0 pt-6">
            <div class="card-title">
                <div class="d-flex align-items-center position-relative my-1">
                    {!! getIcon('magnifier','fs-3 position-absolute ms-5') !!}
                    <input type="text" data-kt-user-table-filter="search"
                           class="form-control form-control-solid w-250px ps-13"
                           placeholder="Search permission" id="mySearchInput"/>
                </div>
            </div>
            <div class="card-toolbar">
                <button type="button" class="btn btn-light-primary"
                        data-bs-toggle="modal"
                        data-bs-target="#kt_modal_update_permission">
                    Add Permission
                </button>
                <livewire:permission.permission-modal></livewire:permission.permission-modal>
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
                window.LaravelDataTables['permissions-table'].search(this.value).draw();
            });

            document.addEventListener('livewire:load', function () {
                Livewire.on('success', function () {
                    $('#kt_modal_update_permission').modal('hide');
                    window.LaravelDataTables['permissions-table'].ajax.reload();
                });
            });
        </script>
    @endpush

</x-default-layout>
```

**Key rules:**
- `{!! $dataTable->table() !!}` renders the table HTML + ajax source
- `{!! $dataTable->scripts() !!}` loads the DataTables JS initialization
- The Livewire modal is embedded at the bottom: `<livewire:permission.permission-modal></livewire:permission.permission-modal>`
- JavaScript listens for `livewire:load` and `Livewire.on('success', ...)` to hide modal and reload table

---

## Livewire Component Pattern

Livewire handles **add, edit, and delete** logic entirely on the frontend with backend validation.

Project menggunakan **3 Livewire component patterns**. Semua didemonstrasikan di `resources/views/admin/user-management/`.

### Pattern A: DataTable + Standalone Modal (Users)

#### List View (Blade)

```blade
{{-- resources/views/admin/user-management/users/list.blade.php --}}
<div class="card">
    <div class="card-header border-0 pt-6">
        <div class="card-title">
            <input type="text" placeholder="Search user" id="mySearchInput"/>
        </div>
        <div class="card-toolbar">
            <button type="button" class="btn btn-primary"
                    data-bs-toggle="modal" data-bs-target="#kt_modal_add_user">
                Add User
            </button>
            <livewire:user.add-user-modal></livewire:user.add-user-modal>
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
        document.addEventListener('livewire:load', function () {
            Livewire.on('success', function () {
                $('#kt_modal_add_user').modal('hide');
                window.LaravelDataTables['users-table'].ajax.reload();
            });
        });
    </script>
@endpush
```

#### Standalone Modal Component (`AddUserModal.php`)

```php
<?php

namespace App\Livewire\User;

use App\Models\User;
use App\Models\UserProfile;
use Livewire\Attributes\On;
use Livewire\Component;
use Livewire\WithFileUploads;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AddUserModal extends Component
{
    use WithFileUploads;

    public $user_id;
    public $name;
    public $password;
    public $email;
    public $role;
    public $avatar;
    public $saved_avatar;

    public $type = 'consumer';
    public $phone;
    public $company_name;
    public $npwp;
    public $address;

    public $edit_mode = false;

    protected function rules()
    {
        return [
            'name' => 'required|string|max:255',
            'email' => $this->edit_mode
                ? 'required|email|max:255|unique:users,email,'.$this->user_id
                : 'required|email|max:255|unique:users,email',
            'password' => $this->edit_mode ? 'nullable|string|min:8' : 'required|string|min:8',
            'role' => 'nullable|string',
            'type' => 'nullable|string|in:consumer,host,corporate',
            'phone' => 'nullable|string|max:50',
            'company_name' => 'nullable|string|max:255',
            'npwp' => 'nullable|string|max:100',
            'address' => 'nullable|string',
        ];
    }

    public function render()
    {
        $roles = Role::all();
        return view('livewire.user.add-user-modal', compact('roles'));
    }

    public function submit()
    {
        $this->validate();

        DB::transaction(function () {
            $userData = [
                'name' => $this->name,
                'email' => $this->email,
                'email_verified_at' => now(),
            ];

            if ($this->password) {
                $userData['password'] = Hash::make($this->password);
            }

            $user = $this->user_id
                ? tap(User::findOrFail($this->user_id))->update($userData)
                : User::create($userData);

            if ($this->role) {
                if ($this->edit_mode) {
                    $user->syncRoles([$this->role]);
                } else {
                    $user->assignRole($this->role);
                }
            }

            UserProfile::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'type' => $this->type ?? 'consumer',
                    'phone' => $this->phone,
                    'company_name' => $this->company_name,
                    'npwp' => $this->npwp,
                    'address' => $this->address,
                ]
            );

            $this->dispatch('success', $this->edit_mode ? __('User updated successfully') : __('User created successfully'));
        });

        $this->resetInputFields();
    }

    #[On('update_user')]
    public function updateUser($id)
    {
        $this->edit_mode = true;

        $user = User::with('userProfile')->findOrFail($id);
        $this->user_id = $user->id;
        $this->name = $user->name;
        $this->email = $user->email;
        $this->role = $user->roles?->first()?->name ?? '';

        if ($user->userProfile) {
            $this->type = $user->userProfile->type ?? 'consumer';
            $this->phone = $user->userProfile->phone;
            $this->company_name = $user->userProfile->company_name;
            $this->npwp = $user->userProfile->npwp;
            $this->address = $user->userProfile->address;
        }
    }

    public function resetInputFields()
    {
        $this->reset([
            'user_id', 'name', 'password', 'email', 'role',
            'avatar', 'saved_avatar', 'type', 'phone',
            'company_name', 'npwp', 'address'
        ]);
        $this->edit_mode = false;
    }

    public function hydrate()
    {
        $this->resetErrorBag();
        $this->resetValidation();
    }
}
```

**Key rules for Pattern A:**
- Single standalone modal component (no base Form + Modal wrapper)
- Uses `edit_mode` boolean to switch between create/edit
- Edit event: `#[On('update_user')]` loads data into component properties
- Save method: `submit()`
- Success event: `$this->dispatch('success', message)` — Blade JS listens and reloads DataTable
- Modal embedded inside `card-toolbar` div
- `wire:ignore.self` on modal div

### Pattern B: Pure Livewire List + Modal (Roles)

#### Blade View

```blade
{{-- resources/views/admin/user-management/roles/list.blade.php --}}
<x-default-layout>

@section('title') Roles @endsection

@section('breadcrumbs')
    {{ Breadcrumbs::render('user-management.roles.index') }}
@endsection

<!--begin::Content container-->
<div id="kt_app_content_container" class="app-container container-xxl">
    <livewire:permission.role-list></livewire:permission.role-list>
</div>
<!--end::Content container-->

<!--begin::Modal-->
<livewire:permission.role-modal></livewire:permission.role-modal>
<!--end::Modal-->

</x-default-layout>
```

#### List Component (`RoleList.php`)

```php
<?php

namespace App\Livewire\Permission;

use Illuminate\Database\Eloquent\Collection;
use Livewire\Attributes\On;
use Livewire\Component;
use Spatie\Permission\Models\Role;

class RoleList extends Component
{
    public array|Collection $roles;

    public function render()
    {
        $this->roles = Role::with('permissions')->get();
        return view('livewire.permission.role-list');
    }

    #[On('success')]
    public function updateRoleList()
    {
        $this->roles = Role::with('permissions')->get();
    }

    public function hydrate()
    {
        $this->resetErrorBag();
        $this->resetValidation();
    }
}
```

#### Modal Component (`RoleModal.php`)

```php
<?php

namespace App\Livewire\Permission;

use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Str;
use Livewire\Attributes\On;
use Livewire\Component;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleModal extends Component
{
    public $name;
    public $checked_permissions;
    public $check_all;

    public Role $role;
    public Collection $permissions;

    protected $rules = [
        'name' => 'required|string',
    ];

    #[On('modal.show.role_name')]
    public function mountRole($role_name = '')
    {
        if (empty($role_name)) {
            $this->role = new Role;
            $this->name = '';
            return;
        }

        $role = Role::where('name', $role_name)->first();
        if (is_null($role)) {
            $this->dispatch('error', 'The selected role [' . $role_name . '] is not found');
            return;
        }

        $this->role = $role;
        $this->name = $this->role->name;
        $this->checked_permissions = $this->role->permissions->pluck('name');
    }

    public function mount()
    {
        $this->permissions = Permission::all();
        $this->checked_permissions = [];
    }

    public function render()
    {
        $permissions_by_group = [];
        foreach ($this->permissions ?? [] as $permission) {
            $ability = Str::after($permission->name, ' ');
            $permissions_by_group[$ability][] = $permission;
        }

        return view('livewire.permission.role-modal', compact('permissions_by_group'));
    }

    public function submit()
    {
        $this->validate();

        $this->role->name = $this->name;
        if ($this->role->isDirty()) {
            $this->role->save();
        }

        $this->role->syncPermissions($this->checked_permissions);

        $this->dispatch('success', 'Permissions for ' . ucwords($this->role->name) . ' role updated');
    }

    public function checkAll()
    {
        if ($this->check_all) {
            $this->checked_permissions = $this->permissions->pluck('name');
        } else {
            $this->checked_permissions = [];
        }
    }

    public function hydrate()
    {
        $this->resetErrorBag();
        $this->resetValidation();
    }
}
```

**Key rules for Pattern B:**
- No DataTable; list is rendered by Livewire (`role-list.blade.php`)
- List component (`RoleList`) listens for `#[On('success')]` to refresh data
- Modal component (`RoleModal`) uses `mountRole()` instead of `edit_mode`
- Save method is `submit()` (not `save()`)
- Event: `#[On('modal.show.role_name')]`
- Modal embedded at bottom of Blade view

### Pattern C: DataTable + Standalone Modal with mountPermission() (Permissions)

#### Blade View

```blade
{{-- resources/views/admin/user-management/permissions/list.blade.php --}}
<div class="card">
    <div class="card-header border-0 pt-6">
        <div class="card-title">
            <input type="text" placeholder="Search permission" id="mySearchInput"/>
        </div>
        <div class="card-toolbar">
            <button type="button" class="btn btn-light-primary"
                    data-bs-toggle="modal" data-bs-target="#kt_modal_update_permission">
                Add Permission
            </button>
        </div>
    </div>
    <div class="card-body py-4">
        <div class="table-responsive">
            {!! $dataTable->table() !!}
        </div>
    </div>
</div>

<livewire:permission.permission-modal></livewire:permission.permission-modal>

@push('scripts')
    {!! $dataTable->scripts() !!}
    <script>
        document.addEventListener('livewire:load', function () {
            Livewire.on('success', function () {
                $('#kt_modal_update_permission').modal('hide');
                window.LaravelDataTables['permissions-table'].ajax.reload();
            });
        });
    </script>
@endpush
```

#### Modal Component (`PermissionModal.php`)

```php
<?php

namespace App\Livewire\Permission;

use Livewire\Attributes\On;
use Livewire\Component;
use Spatie\Permission\Models\Permission;

class PermissionModal extends Component
{
    public $name;
    public Permission $permission;

    protected $rules = [
        'name' => 'required|string',
    ];

    public function render()
    {
        return view('livewire.permission.permission-modal');
    }

    #[On('modal.show.permission_name')]
    public function mountPermission($permission_name = null)
    {
        if (empty($permission_name)) {
            $this->permission = new Permission;
            $this->name = '';
            return;
        }

        $permission = Permission::find($permission_name);
        if (is_null($permission)) {
            $this->dispatch('error', 'The selected permission is not found');
            return;
        }

        $this->permission = $permission;
        $this->name = $this->permission->name;
    }

    public function submit()
    {
        $this->validate();

        $this->permission->name = strtolower($this->name);
        if ($this->permission->isDirty()) {
            $this->permission->save();
        }

        $this->dispatch('success', 'Permission updated');
    }

    #[On('delete_permission')]
    public function delete($id)
    {
        $permission = Permission::find($id);
        if (!is_null($permission)) {
            $permission->delete();
        }
        $this->dispatch('success', 'Permission deleted');
    }

    public function hydrate()
    {
        $this->resetErrorBag();
        $this->resetValidation();
    }
}
```

**Key rules for Pattern C:**
- DataTable for list, standalone modal for add/edit
- Modal uses `mountPermission()` instead of `edit()` or `edit_mode`
- Save method is `submit()`
- Event: `#[On('modal.show.permission_name')]`
- Delete event: `#[On('delete_permission')]`
- Success dispatches message string: `$this->dispatch('success', 'Permission updated')`

### Pattern D: Base Form + Modal Wrapper (Most CRUD Modules)

Most modules (Properties, Bookings, etc.) use a **base `Form.php`** class plus a thin **`Modal.php`** wrapper.

#### Example: `PropertyPrices/Form.php` (base form)

```php
<?php

namespace App\Livewire\PropertyPrices;

use App\Models\PropertyPrice;
use App\Models\Property;
use Livewire\Attributes\On;
use Livewire\Component;

class Form extends Component
{
    public ?int $propertypriceId = null;

    public $property_id = null;
    public $price_type = null;
    public $amount = '';
    public $cleaning_fee = '';
    public $deposit = '';
    public $service_fee = '';
    public $extra_guest_fee = '';

    protected function rules(): array
    {
        return [
            'property_id' => 'required|exists:properties,id',
            'price_type' => 'required|in:daily,weekly,monthly,yearly',
            'amount' => 'required|numeric|min:0',
            'cleaning_fee' => 'nullable|numeric|min:0',
            'deposit' => 'nullable|numeric|min:0',
            'service_fee' => 'nullable|numeric|min:0',
            'extra_guest_fee' => 'nullable|numeric|min:0',
        ];
    }

    #[On('modal.show.property_price')]
    public function edit($id)
    {
        if ($id) {
            $propertyprice = PropertyPrice::findOrFail($id);
            $this->propertypriceId = $propertyprice->id;
            $this->property_id = $propertyprice->property_id;
            $this->price_type = $propertyprice->price_type;
            $this->amount = $propertyprice->amount;
            $this->cleaning_fee = $propertyprice->cleaning_fee;
            $this->deposit = $propertyprice->deposit;
            $this->service_fee = $propertyprice->service_fee;
            $this->extra_guest_fee = $propertyprice->extra_guest_fee;
        } else {
            $this->reset(['property_id', 'price_type', 'amount', 'cleaning_fee', 'deposit', 'service_fee', 'extra_guest_fee']);
            $this->propertypriceId = null;
        }
    }

    public function save()
    {
        $validated = $this->validate();

        foreach (['cleaning_fee', 'deposit', 'service_fee', 'extra_guest_fee'] as $key) {
            if ($validated[$key] === '') {
                $validated[$key] = null;
            }
        }

        if ($this->propertypriceId) {
            PropertyPrice::findOrFail($this->propertypriceId)->update($validated);
            session()->flash('success', 'Manajemen Harga updated successfully.');
        } else {
            PropertyPrice::create($validated);
            session()->flash('success', 'Manajemen Harga created successfully.');
        }

        $this->dispatch('success');
    }

    public function render()
    {
        $property_idOptions = Property::pluck('name', 'id');
        return view('livewire.property_prices.form', compact('property_idOptions'));
    }

    public function hydrate()
    {
        $this->resetErrorBag();
        $this->resetValidation();
    }
}
```

#### Example: `PropertyPrices/PropertyModal.php` (thin wrapper)

```php
<?php

namespace App\Livewire\PropertyPrices;

class PropertyModal extends Form
{
    public function render()
    {
        return parent::render();
    }
}
```

**Key rules for Pattern D:**
- The **base `Form.php`** contains all properties, rules, `edit()` handler, `save()` method, and `render()`
- The **`Modal.php`** wrapper only overrides `render()` to call `parent::render()`
- Event handler: `edit($id)`
- Save method: `save()`
- Event: `#[On('modal.show.module_name')]`
- `hydrate()` resets validation errors

---

## Livewire Blade Pattern (Modal)

### Struktur Modal Standar

```blade
<div class="modal fade" id="kt_modal_add_resource" tabindex="-1" aria-hidden="true" wire:ignore.self>
    <div class="modal-dialog modal-dialog-centered mw-650px">
        <div class="modal-content">
            <div class="modal-header" id="kt_modal_add_resource_header">
                <h2 class="fw-bold">Add Resource</h2>
                <div class="btn btn-icon btn-sm btn-active-icon-primary" data-kt-dismiss-modal="true">
                    {!! getIcon('cross','fs-1') !!}
                </div>
            </div>

            <div class="modal-body px-5 my-7">
                <form id="kt_modal_add_resource_form" class="form" wire:submit.prevent="submit">
                    <div class="d-flex flex-column scroll-y me-n7 pe-7" id="kt_modal_add_resource_scroll"
                         data-kt-scroll="true" data-kt-scroll-activate="{default: false, lg: true}"
                         data-kt-scroll-max-height="auto"
                         data-kt-scroll-dependencies="#kt_modal_add_resource_header"
                         data-kt-scroll-wrappers="#kt_modal_add_resource_scroll"
                         data-kt-scroll-offset="300px">

                        <!-- Form fields here -->

                    </div>
                </form>
            </div>

            <div class="modal-footer flex-center">
                <button type="reset" class="btn btn-light me-3" data-kt-dismiss-modal="true" wire:loading.attr="disabled">Discard</button>
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

@push('scripts')
<script>
    const modal = document.querySelector('#kt_modal_add_resource');

    modal.addEventListener('show.bs.modal', (e) => {
        const {module}Id = e.relatedTarget ? e.relatedTarget.getAttribute('data-{module}-id') : null;
        Livewire.emit('modal.show.{module_name', {module}Id);
    });
</script>
@endpush
```

**Key rules:**
- `wire:ignore.self` on the modal div prevents Livewire from re-rendering the modal
- `wire:model.defer` for two-way binding (deferred until submit)
- `wire:submit.prevent="submit"` intercepts form submit
- `wire:loading` / `wire:loading.remove` for loading states
- `@error('field')` shows validation errors
- JavaScript `show.bs.modal` event dispatches a Livewire event with the selected record ID

---

## Modal Communication Flow

The modal communication follows this exact sequence:

```
1. User clicks button in Blade (e.g., "Edit Role")
   → data-bs-toggle="modal" data-bs-target="#kt_modal_update_role"
   → data-role-id="{{ $role->name }}" is passed via HTML attribute

2. Bootstrap shows the modal
   → 'show.bs.modal' event fires

3. JavaScript listener catches the event
   → Livewire.dispatch('modal.show.role_name', { role_name: roleId })

4. Livewire component receives the event via #[On('modal.show.role_name')]
   → mountPermission() / mountRole() is called
   → Model is loaded or new instance created
   → Form fields are populated

5. User fills form and clicks Submit
   → wire:submit.prevent="submit"
   → Validation runs
   → Model is saved

6. Livewire dispatches 'success' event
   → $this->dispatch('success', 'Permission updated')

7. Blade JavaScript listens for 'success'
   → $('#modal').modal('hide')
   → window.LaravelDataTables['table-id'].ajax.reload()
```

---

## Three Module Patterns Summary

| Pattern | When to Use | List View | Add/Edit |
|---------|-------------|-----------|----------|
| **A: DataTable + Livewire Modal** | Large datasets needing search/sort/export | Yajra DataTable | Standalone Livewire modal |
| **B: Pure Livewire** | Simple card/grid layouts, small datasets | Livewire list component | Standalone Livewire modal |
| **C: Base Form + Modal Wrapper** | Reusable form logic across create/edit | Same as Pattern A | Base `Form.php` + thin `Modal.php` wrapper |

---

## Checklist Implementasi Modul Baru

- [ ] Buat folder `resources/views/admin/{module}/`
- [ ] Buat `index.blade.php` dengan card + DataTable + Livewire modal
- [ ] Buat `columns/_actions.blade.php` dengan variabel yang sesuai DataTable
- [ ] Buat DataTable class di `app/DataTables/{Module}DataTable.php`
- [ ] Buat Controller di `app/Http/Controllers/Admin/{Module}Controller.php`
- [ ] Daftarkan route di `routes/admin_generated.php`
- [ ] Daftarkan breadcrumb di `routes/breadcrumbs.php`
- [ ] Gunakan `<x-default-layout>` sebagai wrapper
- [ ] Include `@push('scripts')` untuk DataTable scripts + Livewire events
- [ ] Gunakan kelas CSS standar: `card`, `card-header`, `card-body`, `btn btn-primary`, `form-control form-control-solid`
