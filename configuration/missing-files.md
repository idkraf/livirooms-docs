# Missing Files Analysis

Dokumen ini merangkum hasil audit file dan relasi yang belum terdefinisi di proyek Laravel, termasuk model, relationship, DataTables path mismatch, dan namespace issues.

## Daftar Isi

- [Missing / Undefined Model Classes](#1-missing--undefined-model-classes)
- [Missing Eloquent Model Relationships](#2-missing-eloquent-model-relationships)
- [DataTables Action Column Path & Variable Mismatches](#3-datatables-action-column-path--variable-mismatches)
- [Outdated `pages/apps...` Paths in User Management DataTables](#4-outdated-pagesapps-paths-in-user-management-datatables)
- [Livewire Namespace & Template Mismatches](#5-livewire-namespace--template-mismatches)
- [DataTable Import & Typo Issues](#6-datatable-import--typo-issues)

## 1. Missing / Undefined Model Classes

| Model | Status |
|-------|--------|
| `UserValidation` | ✅ Created — diimport di `UserValidationDataTable`, migration disalin dari project viona |
| `UsersAssignedRole` | ✅ Created — diimport di `UsersAssignedRoleDataTable`, migration dibuat |
| **21 Model Ternormalisasi Produk** | ✅ **All Created** — `Accommodation`, `BuildingList`, `UnitType`, `UnitTypePrice`, `UnitTypeImage`, `FacilityGroup`, `FacilityItem`, `FacilityTag`, `Gallery`, `Review`, `ReviewPhoto`, `AccommodationPolicy`, `AccommodationQuestion`, `NearbyPoint`, `RoomFurnitureGroup`, `RoomFurnitureItem`, `BedFacility`, `AccommodationDescriptionParagraph`, `AccommodationDetail`, `AccommodationDetailGroup`, `AccommodationDetailLine` |

---

## 2. Missing Eloquent Model Relationships

### A. `User` Model (`app/Models/User.php`)

Model ini belum memiliki relasi `hasMany` ke model-model domain. Ini **tidak dikonfigurasi** di setup project saat ini, jadi tidak ditambahkan.

### B. `Accommodation` Model (`app/Models/Accommodation.php`)

Model ini sekarang menjadi single source of truth untuk Hotel dan Property. `Property.php` dan `Hotel.php` telah dihapus. Semua relasi terkonsolidasi di `Accommodation.php` dengan diskriminator `booking_mode` (`room` = Hotel, `unit` = Property).

### C. `RemoteConfigParameter` Model

✅ Fixed — Ditambahkan relasi `createdBy()` dan `updatedBy()` (fields: `created_by`, `updated_by`)

### D. `RemoteConfigPublishLog` Model

✅ Fixed — Ditambahkan relasi `publishedBy()` (field: `published_by`)

---

## 3. DataTables Action Column Path & Variable Mismatches

Semua DataTables di `app/DataTables/` telah diperbaiki untuk menggunakan path `_actions.blade.php` yang benar:

| DataTable Class | View Path | Status |
|-----------------|-----------|--------|
| `AuditLogDataTable` | `admin.audit_logs.columns._actions` | ✅ Fixed |
| `AvailabilityDataTable` | `admin.availabilities.columns._actions` | ✅ Fixed |
| `BannerDataTable` | `admin.banners.columns._actions` | ✅ Fixed |
| `BookingDataTable` | `admin.bookings.columns._actions` | ✅ Fixed |
| `CmsPageDataTable` | `admin.cms_pages.columns._actions` | ✅ Fixed |
| `ConversationDataTable` | `admin.conversations.columns._actions` | ✅ Fixed |
| `FaqDataTable` | `admin.faqs.columns._actions` | ✅ Fixed |
| `NotificationLogDataTable` | `admin.notification_logs.columns._actions` | ✅ Fixed |
| `OrderDataTable` | `admin.orders.columns._actions` | ✅ Fixed |
| `PaymentDataTable` | `admin.payments.columns._actions` | ✅ Fixed |
| `PaymentMethodDataTable` | `admin.payment_methods.columns._actions` | ✅ Fixed |
| `PropertyDataTable` | `admin.properties.columns._actions` | ✅ Fixed |
| `PropertyPriceDataTable` | `admin.property_prices.columns._actions` | ✅ Fixed |
| `PropertyRecommendationDataTable` | `admin.property_recommendations.columns._actions` | ✅ Fixed |
| `PropertySearchLogDataTable` | `admin.property_search_logs.columns._actions` | ✅ Fixed |
| `ReferralDataTable` | `admin.referrals.columns._actions` | ✅ Fixed |
| `ReviewDataTable` | `admin.reviews.columns._actions` | ✅ Fixed |
| `UserProfileDataTable` | `admin.user_profiles.columns._actions` | ✅ Fixed |
| `VoucherDataTable` | `admin.vouchers.columns._actions` | ✅ Fixed |
| `WishlistDataTable` | `admin.wishlists.columns._actions` | ✅ Fixed |
| `WithdrawalDataTable` | `admin.withdrawals.columns._actions` | ✅ Fixed |

Nama variabel di `_actions.blade.php` sekarang cocok dengan variabel yang di-pass oleh DataTable closures masing-masing.

---

## 4. Outdated `pages/apps...` Paths in User Management DataTables

✅ Fixed — Semua 4 User Management DataTables diperbarui untuk menggunakan path `admin/user-management...`:

1. `PermissionsDataTable.php` — path `_assign-to` dan `_actions`
2. `UsersDataTable.php` — path `_user` dan `_actions`
3. `UserValidationDataTable.php` — path `_user` dan `_actions`
4. `UsersAssignedRoleDataTable.php` — path `_user` dan `_actions`

---

## 5. Livewire Namespace & Template Mismatches

### A. Namespace Mismatch

✅ Fixed — Semua Livewire Permission components diperbarui dari `App\Http\Livewire` ke `App\Livewire`:
- `app/Livewire/Permission/RoleModal.php`
- `app/Livewire/Permission/RoleList.php`
- `app/Livewire/Permission/PermissionModal.php`

### B. View Template Paths

✅ Verified — Semua Livewire form render methods cocok dengan `resources/views/livewire/...`.

---

## 6. DataTable Import & Typo Issues

### A. `UsersAssignedRoleDataTable.php`

✅ Fixed — Dikoreksi import dari `App\Models\UsersAssingedRole` ke `App\Models\UsersAssignedRole`

### B. Missing Model

✅ Created — `app/Models/UsersAssignedRole.php` dengan relasi `user()` dan `role()`

### C. Missing Migration

✅ Created — `database/migrations/2026_06_16_000003_create_users_assigned_roles_table.php`

---

## 7. RolePermissionSeeder Status

`RolePermissionSeeder.php` bekerja dengan benar:
- Membuat roles: `admin`, `host`, `consumer`
- Assign `admin` role ke `admin@example.com`
- Assign `host` role ke `budi.host@example.com` dan `siti.host@example.com`

---

## 8. Admin Blade Layout Conversion

✅ Completed — Semua 65 admin blade files dikonversi dari `@extends('layouts.admin')` ke `<x-default-layout>` component-based approach.

✅ Completed — Dibuat 21 direktori `columns/` dengan file `_actions.blade.php` untuk semua section admin dengan DataTables.

---

## Summary of Completed Fixes

| Issue | Status |
|-------|--------|
| DataTables action column paths | ✅ Fixed |
| DataTables variable name mismatches | ✅ Fixed |
| `pages/apps...` paths in User Management DataTables | ✅ Fixed |
| Livewire namespace (`Http\Livewire` → `Livewire`) | ✅ Fixed |
| `UsersAssignedRole` typo in import | ✅ Fixed |
| Missing `UsersAssignedRole` model | ✅ Created |
| Missing `user_validations` migration | ✅ Copied from viona |
| Missing `users_assigned_roles` migration | ✅ Created |
| Missing `createdBy`/`updatedBy` in `RemoteConfigParameter` | ✅ Fixed |
| Missing `publishedBy` in `RemoteConfigPublishLog` | ✅ Fixed |

---

## Remaining Items (Not Configured)

Item berikut **tidak dikonfigurasi** di project saat ini dan **tidak boleh** ditambahkan:

1. **`User` model `hasMany` relationships** — Tidak dikonfigurasi di project saat ini
2. **`Property` model additional relationships** — Tidak dikonfigurasi di project saat ini
3. **Detailed permission creation in seeder** — Tidak dikonfigurasi di project saat ini
4. **`pages/` directory views** — Tidak digunakan di rental project (menggunakan struktur `admin/`)
