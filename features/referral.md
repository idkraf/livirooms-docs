# Referral System Documentation

Dokumentasi sistem referral pada Sewain, meliputi database schema, API endpoints, implementasi Flutter, alur kerja, status implementasi, dan rekomendasi teknis.

## Daftar Isi

- [Database Schema](#database-schema)
- [Alur Kerja Referral](#alur-kerja-referral)
- [API Endpoints](#api-endpoints)
- [Implementasi Flutter](#implementasi-flutter)
- [Status Implementasi](#status-implementasi)
- [Rekomendasi Teknis](#rekomendasi-teknis)
- [Catatan Penting](#catatan-penting)
- [Referensi File](#referensi-file)

## Database Schema

### Tabel `referrals`

Path migration: `laravel/database/migrations/2026_07_14_081700_create_referrals_table.php`

```php
Schema::create('referrals', function (Blueprint $table) {
    $table->id();
    $table->foreignId('referrer_id')->constrained('users')->cascadeOnDelete();
    $table->foreignId('referred_id')->constrained('users')->cascadeOnDelete();
    $table->string('referral_code');
    $table->decimal('reward_amount', 15, 2)->nullable();
    $table->enum('status', ['pending','rewarded'])->default('pending');
    $table->timestamps();

    $table->unique(['referrer_id', 'referred_id']);
});
```

### Relasi Model

```php
// App\Models\Referral
class Referral extends Model
{
    protected $fillable = [
        'referrer_id',
        'referred_id',
        'referral_code',
        'reward_amount',
        'status',
    ];

    public function referrer()
    {
        return $this->belongsTo(User::class, 'referrer_id');
    }

    public function referred()
    {
        return $this->belongsTo(User::class, 'referred_id');
    }
}
```

### ER Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          users                                  │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                                                         │
│ name                                                             │
│ email                                                            │
│ ...                                                              │
└─────────────────────────────────────────────────────────────────┘
         │                     │
         │ referrer_id         │ referred_id
         ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                        referrals                                 │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                                                         │
│ referrer_id (FK → users.id)                                     │
│ referred_id (FK → users.id)                                     │
│ referral_code (string)                                          │
│ reward_amount (decimal, nullable)                               │
│ status (enum: pending|rewarded, default: pending)               │
│ created_at                                                      │
│ updated_at                                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Alur Kerja Referral

### Flow 1: Admin Membuat Referral

```
1. Admin login ke panel admin
2. Admin navigasi ke menu "Referral System"
3. Admin klik "Add Referral System"
4. Modal Livewire muncul dengan form:
   - Pilih Pemberi Referral (User A)
   - Pilih Penerima Referral (User B)
   - Input Kode Referral (misal: REF-ANDI-2026)
   - Input Jumlah Reward (misal: Rp50.000)
   - Pilih Status (pending / rewarded)
5. Admin submit form
6. Livewire validasi dan simpan ke database
7. DataTable refresh otomatis
```

### Flow 2: User Membagi Kode Referral

```
1. User A (referrer) login ke aplikasi Flutter
2. User A navigasi ke halaman Referral (Screen 23)
3. Halaman menampilkan:
   - Kode referral milik User A (misal: REF-ANDI-2026)
   - Jumlah referral yang berhasil
   - Total reward yang didapat
4. User A klik "Bagikan Kode"
5. Flutter membuka share dialog (WhatsApp, Telegram, dll) atau copy to clipboard
6. User B menerima kode referral
```

### Flow 3: User Baru Mendaftar dengan Kode Referral

```
1. User B buka aplikasi Sewain
2. User B navigasi ke halaman Register
3. User B input data diri (nama, email, password, kode referral opsional)
4. Flutter kirim POST /api/v1/auth/register dengan field referral_code
5. Backend verifikasi:
   - Kode referral ada dan status pending
   - User B bukan user yang membuat kode tersebut
   - User B belum pernah direferensikan sebelumnya
6. Backend buat user baru + otomatis apply referral jika kode valid:
   - referrer_id: id User A
   - referred_id: id User B
   - referral_code: REF-ANDI-2026
   - reward_amount: 50000 (dari admin)
   - status: pending
7. User B berhasil mendaftar dan login
```

### Flow 4: Reward Diberikan

```
1. User B menyelesaikan booking pertama dan pembayaran berhasil
2. Webhook Midtrans memicu update status booking → confirmed
3. BookingObserver atau Event Listener mendeteksi booking pertama User B
4. Sistem cari referral dengan referred_id = User B dan status = pending
5. Jika ditemukan:
   - Update status → rewarded
   - Update reward_amount sesuai aturan admin
   - Notifikasi dikirim ke User A (push notification / in-app)
   - Saldo/credit User A ditambah (jika ada sistem wallet)
6. Jika tidak ditemukan, tidak ada aksi
```

---

## API Endpoints

### Endpoint Admin

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| GET | `/admin/referrals` | DataTable admin (Yajra) |
| GET | `/admin/referrals/create` | Form create admin |
| GET | `/admin/referrals/{id}/edit` | Form edit admin |
| DELETE | `/admin/referrals/{id}` | Hapus referral |

### Endpoint Mobile API

Path: `laravel/routes/api_mobile.php`

```php
Route::middleware('auth:sanctum')->prefix('referrals')->name('referrals.')->group(function () {
    Route::get('/my-code', [App\Http\Controllers\Api\ReferralController::class, 'myCode'])->name('my-code');
    Route::get('/my-list', [App\Http\Controllers\Api\ReferralController::class, 'myList'])->name('my-list');
    Route::post('/apply', [App\Http\Controllers\Api\ReferralController::class, 'apply'])->name('apply');
    Route::get('/status', [App\Http\Controllers\Api\ReferralController::class, 'status'])->name('status');
});
```

Path: `laravel/app/Http/Controllers/Api/ReferralController.php`

- `GET /api/v1/referrals/my-code` — ambil kode referral user yang login
- `GET /api/v1/referrals/my-list` — ambil daftar referral + statistik
- `POST /api/v1/referrals/apply` — terapkan kode referral
- `GET /api/v1/referrals/status` — cek status referral user yang login

---

## Implementasi Flutter

### Model

Path: `flutter/lib/models/referral.dart`

```dart
class Referral {
  final int id;
  final String referralCode;
  final double? rewardAmount;
  final String status;
  final String? referredName;
  final String? referredEmail;
  final String? createdAt;

  const Referral({
    required this.id,
    required this.referralCode,
    this.rewardAmount,
    required this.status,
    this.referredName,
    this.referredEmail,
    this.createdAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
        id: json['id'] as int? ?? 0,
        referralCode: json['referral_code'] as String? ?? '',
        rewardAmount: json['reward_amount'] is num
            ? (json['reward_amount'] as num).toDouble()
            : double.tryParse('${json['reward_amount']}') ?? 0,
        status: json['status'] as String? ?? 'pending',
        referredName: json['referred_name'] as String?,
        referredEmail: json['referred_email'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

class ReferralStats {
  final int totalReferred;
  final int totalRewarded;
  final int totalPending;
  final double totalRewardAmount;

  const ReferralStats({
    required this.totalReferred,
    required this.totalRewarded,
    required this.totalPending,
    required this.totalRewardAmount,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
        totalReferred: json['total_referred'] as int? ?? 0,
        totalRewarded: json['total_rewarded'] as int? ?? 0,
        totalPending: json['total_pending'] as int? ?? 0,
        totalRewardAmount: json['total_reward_amount'] is num
            ? (json['total_reward_amount'] as num).toDouble()
            : double.tryParse('${json['total_reward_amount']}') ?? 0,
      );
}

class ReferralCodeResponse {
  final String code;
  final int userId;
  final String name;

  const ReferralCodeResponse({
    required this.code,
    required this.userId,
    required this.name,
  });

  factory ReferralCodeResponse.fromJson(Map<String, dynamic> json) =>
      ReferralCodeResponse(
        code: json['code'] as String? ?? '',
        userId: json['user_id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );
}

class ReferralStatusResponse {
  final bool hasReferral;
  final int? referralId;
  final String? referralCode;
  final String? referrerName;
  final double? rewardAmount;
  final String? status;
  final String? createdAt;

  const ReferralStatusResponse({
    required this.hasReferral,
    this.referralId,
    this.referralCode,
    this.referrerName,
    this.rewardAmount,
    this.status,
    this.createdAt,
  });

  factory ReferralStatusResponse.fromJson(Map<String, dynamic> json) =>
      ReferralStatusResponse(
        hasReferral: json['has_referral'] as bool? ?? false,
        referralId: json['referral_id'] as int?,
        referralCode: json['referral_code'] as String?,
        referrerName: json['referrer_name'] as String?,
        rewardAmount: json['reward_amount'] is num
            ? (json['reward_amount'] as num).toDouble()
            : double.tryParse('${json['reward_amount']}') ?? 0,
        status: json['status'] as String?,
        createdAt: json['created_at'] as String?,
      );
}
```

### Service

Path: `flutter/lib/services/referral_service.dart`

```dart
import '../models/referral.dart';
import 'api_client.dart';

class ReferralService {
  ReferralService({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  Future<ReferralCodeResponse> myCode() async {
    final res = await _api.get('referrals/my-code');
    final data = res.dataMap;
    return ReferralCodeResponse.fromJson(data);
  }

  Future<(ReferralStats, List<Referral>)> myList() async {
    final res = await _api.get('referrals/my-list');
    final data = res.dataMap;

    final statsJson = data['stats'] as Map<String, dynamic>? ?? {};
    final stats = ReferralStats.fromJson(statsJson);

    final listJson = data['referrals'] as List<dynamic>? ?? [];
    final referrals = listJson
        .map((e) => Referral.fromJson(e as Map<String, dynamic>))
        .toList();

    return (stats, referrals);
  }

  Future<void> applyCode(String code) async {
    await _api.post('referrals/apply', body: {
      'referral_code': code,
    });
  }

  Future<ReferralStatusResponse> status() async {
    final res = await _api.get('referrals/status');
    final data = res.dataMap;
    return ReferralStatusResponse.fromJson(data);
  }
}
```

### Screen: Referral Screen

Path: `flutter/lib/screens/account/referral_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../models/referral.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/referral_service.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _service = ReferralService();
  bool _loading = true;
  String? _myCode;
  ReferralStats? _stats;
  List<Referral> _referrals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final codeRes = await _service.myCode();
      final (stats, list) = await _service.myList();
      if (!mounted) return;
      setState(() {
        _myCode = codeRes.code;
        _stats = stats;
        _referrals = list;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data referral.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shareCode() async {
    if (_myCode == null) return;
    final user = context.read<AuthProvider>().user;
    final text =
        'Ayo Sewain properti Sewain! Gunakan kode referral saya $_myCode dan dapatkan reward bersama. Download app di https://sewain.app';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCodeCard(),
                const SizedBox(height: 16),
                _buildStatsCard(),
                const SizedBox(height: 16),
                _buildReferralList(),
              ],
            ),
    );
  }

  Widget _buildCodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Kode Referral Saya',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _myCode ?? '-',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _shareCode,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Bagikan Kode'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total Direferensikan', stats.totalReferred.toString()),
          _statItem('Berhasil', stats.totalRewarded.toString()),
          _statItem('Total Reward', Formatters.rupiah(stats.totalRewardAmount)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReferralList() {
    if (_referrals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Belum ada referral. Bagikan kode referral Anda sekarang!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Referral',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._referrals.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.referredName ?? r.referredEmail ?? 'User #${r.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.status == 'rewarded'
                              ? 'Reward: ${Formatters.rupiah(r.rewardAmount ?? 0)}'
                              : 'Menunggu transaksi pertama',
                          style: TextStyle(
                            fontSize: 12,
                            color: r.status == 'rewarded'
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: r.status == 'rewarded'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r.status == 'rewarded' ? 'Berhasil' : 'Pending',
                      style: TextStyle(
                        color: r.status == 'rewarded'
                            ? AppColors.success
                            : AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
```

### Router

Path: `flutter/lib/router.dart`

**Tambahkan route constant:**

```dart
static const referral = '/referral';
```

**Tambahkan case di `onGenerateRoute`:**

```dart
case Routes.referral:
  page = const ReferralScreen();
  break;
```

---

## Status Implementasi

### Yang Sudah Diimplementasikan

| Komponen | File | Deskripsi |
|----------|------|-----------|
| **Model** | `app/Models/Referral.php` | Eloquent model dengan relasi `referrer()` dan `referred()` ke User |
| **Migration** | `database/migrations/2026_07_14_081700_create_referrals_table.php` | Tabel `referrals` dengan foreign key, enum status, nullable reward_amount |
| **Migration (nullable)** | `database/migrations/2026_08_09_171700_make_referred_id_nullable_on_referrals_table.php` | Membuat `referred_id` nullable agar kode referral bisa dibuat sebelum user baru mendaftar |
| **Seeder** | `database/seeders/ReferralSeeder.php` | Sample data: Andi → Dewi, kode `REF-ANDI-2026`, reward Rp50.000, status `rewarded` |
| **DataTable** | `app/DataTables/ReferralDataTable.php` | Yajra DataTable dengan kolom: ID, Referrer, Direferensikan, Kode Referral, Reward, Status, Aksi |
| **Controller (Admin)** | `app/Http/Controllers/Admin/ReferralController.php` | Admin CRUD: `index`, `create`, `edit`, `destroy` |
| **Livewire Form** | `app/Livewire/Referrals/Form.php` | Form modal untuk create/edit referral dengan validasi |
| **Livewire Modal** | `app/Livewire/Referrals/ReferralModal.php` | Modal wrapper untuk form Livewire |
| **Views (Admin)** | `resources/views/admin/referrals/index.blade.php` | Halaman index dengan DataTable + tombol Add |
| **API Controller (Mobile)** | `app/Http/Controllers/Api/ReferralController.php` | 4 endpoint: `myCode`, `myList`, `apply`, `status` |
| **API Routes (Mobile)** | `routes/api_mobile.php` | Route group `referrals` dengan middleware `auth:sanctum` |
| **Flutter Model** | `lib/models/referral.dart` | Model `Referral`, `ReferralStats`, `ReferralCodeResponse`, `ReferralStatusResponse` |
| **Flutter Service** | `lib/services/referral_service.dart` | Service layer untuk API referral |
| **Flutter Screen** | `lib/screens/account/referral_screen.dart` | Halaman referral: kode, stats, daftar referral, copy & share |
| **Flutter Router** | `lib/router.dart` | Route constant `Routes.referral` |
| **Flutter Menu** | `lib/screens/account/account_menu_screen.dart` | Menu item Referral di Account Menu |

### Yang Belum Diimplementasikan

| # | Fitur yang Belum | Keterangan |
|---|------------------|------------|
| 1 | **Notifikasi referral (push/in-app)** | NotificationLog sudah dibuat oleh BookingObserver, tapi belum ada UI Flutter untuk menampilkan notifikasi referral |
| 2 | **Flutter tests untuk referral** | ❌ Belum — tidak ada test file untuk model, service, atau screen referral |

---

## Rekomendasi Teknis

### Prioritas Tinggi

1. **Tambahkan API Endpoints untuk Mobile** — Buat `ReferralController` di `app/Http/Controllers/Api/`, daftarkan route di `routes/api_mobile.php`, semua endpoint wajib pakai `auth:sanctum`.
2. **Auto-generate Referral Code** — Buat observer/listener pada `User` model saat user dibuat. Generate kode unik: `REF-{INITIALS}-{USER_ID}` atau `REF-{RANDOM_6_CHAR}`. Simpan kode di field `referral_code` di tabel `referrals` atau tambahkan kolom `referral_code` di tabel `users`.
3. **Implementasi Flutter Referral Screen** — Buat screen `ReferralScreen` dengan kode, stats, dan daftar referral. Integrasi `share_plus` untuk share kode. Tambahkan menu di `AccountMenuScreen`.

### Prioritas Menengah

4. **Auto-reward Logic** — Buat `BookingObserver` atau event listener. Deteksi booking pertama user (referred_id). Update status referral → `rewarded`. Trigger notifikasi ke referrer.
5. **Validasi Unique Constraint** — Tambahkan unique constraint `unique(['referrer_id', 'referred_id'])` di migration. Validasi di backend dan Flutter agar user tidak bisa referral diri sendiri.
6. **Referral History** — Tampilkan riwayat referral dengan status dan tanggal. Filter by status (pending/rewarded).

### Prioritas Rendah

7. **Notification System** — Push notification saat referral berhasil. In-app notification di Flutter.
8. **Reward Redemption** — Buat endpoint untuk menukarkan reward menjadi saldo/credit. Integrasi dengan sistem wallet.
9. **Analytics** — Track conversion rate (berapa yang daftar vs berhasil bayar). Track top referrers.

---

## Catatan Penting

- **Kode Referral**: Saat ini kode referral di-generate otomatis saat user dibuat via `UserObserver`. Format: `REF-{INITIALS}-{USER_ID}` dengan fallback suffix jika ada duplikat.
- **Reward Logic**: Auto-reward dijalankan oleh `BookingObserver` saat booking status berubah ke `confirmed` atau `completed`. NotificationLog dibuat untuk referrer.
- **Status**: Enum `pending|rewarded` cukup untuk tahap awal. Untuk production, pertimbangkan menambah status `cancelled` atau `expired`.
- **Unique Constraint**: Kolom `referral_code` sudah di-unique-kan via migration terpisah.
- **Security**: Pastikan endpoint API hanya bisa diakses oleh user yang terautentikasi (`auth:sanctum`).
- **Flutter Package**: Untuk share, gunakan package `share_plus`. Tambahkan ke `pubspec.yaml` jika belum ada.
- **Testing**: Laravel tests untuk referral API sudah ada (10 tests).

---

## Referensi File

### Backend (Laravel)

| File | Fungsi |
|------|--------|
| `app/Models/Referral.php` | Model Eloquent Referral |
| `database/migrations/2026_07_14_081700_create_referrals_table.php` | Migration tabel referrals |
| `database/migrations/2026_08_09_171700_make_referred_id_nullable_on_referrals_table.php` | Membuat `referred_id` nullable |
| `database/migrations/2026_08_09_165632_add_unique_referral_code_to_referrals_table.php` | Unique constraint untuk `referral_code` |
| `database/seeders/ReferralSeeder.php` | Seeder sample data referral |
| `app/DataTables/ReferralDataTable.php` | Yajra DataTable untuk admin |
| `app/Http/Controllers/Admin/ReferralController.php` | Admin controller (CRUD) |
| `app/Http/Controllers/Api/ReferralController.php` | API controller untuk mobile (`myCode`, `myList`, `apply`, `status`) |
| `app/Observers/UserObserver.php` | Auto-generate kode referral saat user dibuat |
| `app/Observers/BookingObserver.php` | Auto-reward referral + buat NotificationLog saat booking confirmed/completed |
| `app/Providers/AppServiceProvider.php` | Registrasi observer User & Booking |
| `app/Livewire/Referrals/Form.php` | Livewire form modal create/edit |
| `app/Livewire/Referrals/ReferralModal.php` | Livewire modal wrapper |
| `resources/views/admin/referrals/index.blade.php` | View admin index |
| `resources/views/admin/referrals/create.blade.php` | View admin create |
| `resources/views/admin/referrals/edit.blade.php` | View admin edit |
| `resources/views/admin/referrals/columns/_actions.blade.php` | Kolom aksi DataTable |
| `resources/views/livewire/referrals/form.blade.php` | Form modal Livewire |

### Frontend (Flutter)

| File | Fungsi |
|------|--------|
| `lib/models/referral.dart` | Model Referral, ReferralStats, ReferralCodeResponse, ReferralStatusResponse |
| `lib/services/referral_service.dart` | Service layer untuk API referral |
| `lib/screens/account/referral_screen.dart` | Screen halaman referral: kode, stats, daftar referral, copy & share |
| `lib/router.dart` | Route constant `Routes.referral` |
| `test/models/referral_test.dart` | Unit test model referral |
| `test/services/referral_service_test.dart` | Unit test service referral |
