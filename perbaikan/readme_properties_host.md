
> **Status dokumen:** ditulis ulang 18 Agustus 2026 setelah audit kode baris-per-baris.
> Setiap klaim di dokumen ini sudah **diverifikasi ke source code**, bukan diasumsikan dari dokumen lama.
> Versi sebelumnya memuat beberapa klaim yang salah — lihat **§2 Koreksi** sebelum mengeksekusi apa pun.

Modul yang dicakup: properti **non-hotel** (`booking_mode = 'unit'`) — apartemen, rumah, villa,
hotel residence, guest house, kost eksklusif. Modul hotel (`booking_mode = 'room'`) punya dokumen
sendiri: [readme_hotels_host.md](flutter/assets/json/readme_hotels_host.md).

---

## §0 Cara pakai dokumen ini

Dokumen ini adalah **spec eksekusi**, bukan catatan diskusi. Urutan bacanya:

| Bagian | Isi | Kapan dibaca |
|---|---|---|
| **§1** | Status board — daftar temuan + severity + link bukti | Selalu, pertama |
| **§2** | Koreksi terhadap versi lama readme ini | Sebelum menyalin instruksi lama |
| **§3** | Ground truth — kolom DB, field API, matriks sinkronisasi, keputusan | Saat butuh nama field pasti |
| **§4** | **File yang perlu di-UPDATE** | Saat mulai ngoding |
| **§5** | **File yang perlu DIBUAT BARU** (migration / seeder / kode / fixture) | Saat mulai ngoding |
| **§6** | Langkah eksekusi berurutan + kode konkret | Saat mulai ngoding |
| **§7** | Verifikasi & acceptance criteria (manual — tanpa test otomatis) | Sebelum bilang "selesai" |
| **§8** | Lampiran — inventaris fixture, referensi cepat | Saat perlu cross-check |

**Aturan untuk AI yang mengeksekusi:**

1. **Jangan tambah kolom/relasi yang belum diputuskan.** Semua keputusan arsitektur ada di **§3.5**.
   Kalau sebuah field tidak tercantum di sana, jangan bikin migration untuknya.
2. **Kerjakan berurutan sesuai §6.** Tahap P0 memperbaiki kehilangan data; jangan lompat ke P2.
3. **Setelah tiap tahap, jalankan verifikasi §7 untuk tahap itu.** Jangan lanjut kalau merah.
4. Bahasa **kode & komentar: Inggris**. Bahasa **dokumen: Indonesia**.
5. **Tidak ada test otomatis pada pekerjaan ini** — sengaja, atas permintaan. Artinya verifikasi §7
   bukan pelengkap, ia satu-satunya bukti: jalankan seluruhnya, jangan sebagian.
6. DB produksi **PostgreSQL**; jalankan semua verifikasi di sana. Suite test yang sudah ada memakai
   **SQLite in-memory**, dan SQLite tidak menegakkan CHECK constraint — jadi `php artisan test` yang
   hijau **tidak** membuktikan enum `property_type` benar. Uji enum manual di pgsql.

---

## §1 Status board — temuan hasil audit

Total **26 temuan** terverifikasi: **5 P0** (blocker / kehilangan data), **12 P1** (fungsional rusak
atau tidak konsisten), **9 P2** (kualitas & utang teknis).

| ID | Severity | Ringkas | Dampak |
|---|---|---|---|
| P0-1 | 🔴 Blocker | Edit properti menghapus 16 field JSONB `properties_other` | Kehilangan data permanen |
| P0-2 | 🔴 Blocker | `facilities` di-encode JSON dua kali oleh API | Fasilitas hilang di admin panel + filter mati |
| P0-3 | 🔴 Blocker | Hapus foto saat mode edit **selalu** gagal 422 | Fitur mati total |
| P0-4 | 🔴 Blocker | Host tidak bisa memuat properti `draft` miliknya untuk diedit | Draft tidak bisa dilanjutkan |
| P0-5 | 🔴 Blocker | Blok `other` hanya dikirim kalau `prices` tidak kosong | Semua data kaya hilang senyap |
| P1-1 | 🟠 High | `review_summary`, `star_rating`, `check_in_time/out` di-hardcode setiap submit | Menimpa data nyata |
| P1-2 | 🟠 High | `index()` tidak eager-load `other` | **27 kunci** jatuh ke default di list & search |
| P1-3 | 🟠 High | Respons `store()`/`update()` tidak punya `rating`/`review_count` | Bentuk respons beda dari `show()` |
| P1-4 | 🟠 High | Livewire `WizardForm` tanpa `authorize()`, `host_id` bisa dioper klien | Host bisa edit properti orang lain |
| P1-5 | 🟠 High | `bathrooms` tidak punya kolom di mana pun | `pricing().bathrooms` selalu `0` |
| P1-6 | 🟠 High | Duplikat `price_type` menabrak unique index | HTTP 500, bukan 422 |
| P1-7 | 🟠 High | Ada **5** konvensi penamaan fasilitas yang berbeda | Filter & tampilan tidak cocok |
| P1-8 | 🟠 High | `other.cover` menerima URL absolut, `gallery` relatif; `map_preview` tanpa API key | Gambar rusak |
| P1-9 | 🟠 High | `reviews[].photos` dikirim sebagai string JSON, bukan array | Parse error di Flutter |
| P1-10 | 🟠 High | `period_label` diambil dari `booking.duration_type` secara lazy | N+1 query; kolom asli diabaikan |
| P1-11 | 🟠 High | `asked_by` adalah FK user tapi diserialisasi mentah | UI menampilkan angka/kosong, bukan nama |
| P1-12 | 🟠 High | `_status` yang dimuat tidak pernah dipakai saat submit | Properti `maintenance`/`inactive` jadi `active` |
| P2-1 | 🟡 Medium | `WizardForm` default `status='active'` & fasilitas terisi otomatis | Beda dari default DB (`draft`) |
| P2-2 | 🟡 Medium | `WizardForm` hanya menangani 1 baris harga, hardcode `booking_mode='unit'` | Admin tidak bisa kelola multi-harga |
| P2-3 | 🟡 Medium | Kolom mati: `other.rating`, `other.review_count`, `other.price_from` | Diisi seeder, tidak pernah dibaca |
| P2-4 | 🟡 Medium | `PropertiesOtherSeeder` hanya mengisi 1 dari 4 properti, provinsi bertabrakan | Data demo tidak konsisten |
| P2-5 | 🟡 Medium | `InclusionList` abaikan `collapsed_rows`; `AddOn` baca `selected` bukan `is_selected` | Kontrak Dart↔API menyimpang |
| P2-6 | 🟡 Medium | Tidak ada `DELETE host/properties/{property}` | Host tidak bisa hapus properti |
| P2-7 | 🟡 Medium | Model Dart `Property` tidak punya `toJson()` | Payload dirakit manual, mudah bocor |
| P2-8 | 🟡 Medium | `description_extra` direkonstruksi dari `intro` + heading | Paragraf asli hancur |
| P2-9 | 🟡 Medium | `pricing().thumbnail` path relatif & baca kolom `cover` yang tidak ada | Gambar tidak muncul |

### §1.1 Detail P0 — blocker

#### P0-1 · Edit properti menghapus 16 field JSONB `properties_other`

Rantai penyebabnya tiga langkah:

1. [router.dart:268](flutter/lib/router.dart#L268) adalah **satu-satunya** tempat
   `PropertyFormScreen` dibangun, dan ia hanya mengirim `property:` —
   parameter `initialData:` **tidak pernah** diisi di seluruh codebase.
2. [property_form_screen.dart:125](flutter/lib/screens/mitra/property_form_screen.dart#L125)
   `final initial = widget.initialData ?? (widget.property != null ? _propertyToMap(widget.property!) : null);`
   → karena `initialData` selalu `null`, jalur edit **selalu** lewat `_propertyToMap`.
3. [`_propertyToMap` (baris 815–846)](flutter/lib/screens/mitra/property_form_screen.dart#L815-L846)
   hanya mengeluarkan **22 key**. Semua field kaya tidak ada di situ.

Akibatnya `_loadInitialData` menerima `null` untuk field-field itu, state lokal jadi `[]`/`null`,
lalu `_submit` mengirim state kosong itu ke `PUT host/properties/{id}` dan
[`update()` baris 465–472](laravel/app/Http/Controllers/Api/PropertyController.php#L465-L472)
menimpanya.

**Field yang hilang setiap kali host menekan "Simpan Perubahan":**

`specs` · `check_in_notes` · `deposit_notes` · `unit_detail` · `nearby` · `bed_facilities` ·
`building_facilities` · `building_facilities_all` · `room_furniture` · `room_furniture_groups` ·
`description_extra` · `guest_media` · `building_units` · `review_summary` · `is_favorite` ·
`extra_media_count`

Catatan: `is_favorite` dibaca dari `data['is_favorite']`
([baris 246](flutter/lib/screens/mitra/property_form_screen.dart#L246)) tapi `_propertyToMap`
tidak mengirimkannya → selalu jatuh ke `false`.

#### P0-2 · `facilities` di-encode JSON dua kali

[Property.php:18-21](laravel/app/Models/Property.php#L18-L21) sudah mendeklarasikan
`protected $casts = ['gallery' => 'array', 'facilities' => 'array']`. Tetapi controller
meng-encode manual **sebelum** cast bekerja:

- [store() baris 425](laravel/app/Http/Controllers/Api/PropertyController.php#L425) — `$data['facilities'] = json_encode($data['facilities'] ?? []);`
- [update() baris 452-454](laravel/app/Http/Controllers/Api/PropertyController.php#L452-L454) — hal yang sama

Yang tersimpan di DB jadi `"[\"Wi-Fi\",\"AC\"]"` (string ber-escape di dalam kolom JSON), bukan
`["Wi-Fi","AC"]`. Perhatikan **asimetri**: `gallery` di
[baris 426](laravel/app/Http/Controllers/Api/PropertyController.php#L426) **tidak** di-encode manual
— jadi dua kolom sejenis diperlakukan berbeda.

Bug ini **tersembunyi di API** karena
[`decodeJson()` PropertyResource baris 130-139](laravel/app/Http/Resources/PropertyResource.php#L130-L139)
menerima string lalu `json_decode` sekali lagi. Tapi ia **tidak** tersembunyi di dua tempat lain:

- [WizardForm.php:118](laravel/app/Livewire/Properties/WizardForm.php#L118)
  `$this->facilities = is_array($property->facilities) ? $property->facilities : [];`
  → cast mengembalikan **string** (hasil decode satu lapis), `is_array` gagal → `[]` →
  begitu admin menekan Simpan, fasilitas **terhapus dari DB**.
- Filter fasilitas di [index() baris 141-152](laravel/app/Http/Controllers/Api/PropertyController.php#L141-L152)
  memakai `orWhere('facilities', 'like', '%"{$slug}"%")`. Pada baris ber-escape ganda, pola
  `"wifi"` tidak pernah cocok karena yang tersimpan adalah `\"wifi\"`.

#### P0-3 · Hapus foto saat mode edit selalu gagal 422

[property_form_screen.dart:687-691](flutter/lib/screens/mitra/property_form_screen.dart#L687-L691):

```dart
if (_isEdit && widget.initialData != null) {
  await _service.deleteGallery(widget.initialData!['id'] as int, relative);  // ← tidak pernah tereksekusi
} else {
  await _service.deleteGalleryTemp(relative);                                // ← selalu ini
}
```

Karena `initialData` selalu `null` (lihat P0-1), cabang pertama **mati**. Jadi foto milik properti
yang sudah tersimpan dikirim ke endpoint *temp*, dan
[`deleteGalleryTemp()` baris 362-373](laravel/app/Http/Controllers/Api/PropertyController.php#L362-L373)
sengaja menolak path yang sudah terpakai:

```php
$inUse = Property::query()->where('gallery', 'like', '%' . $imagePath . '%')->exists();
if ($inUse) { return ApiResponse::error('Foto ini sudah terpakai pada sebuah properti.', 422, ...); }
```

→ 422 → `catch` di [baris 692-696](flutter/lib/screens/mitra/property_form_screen.dart#L692-L696)
mengembalikan foto ke list dan menampilkan "Gagal menghapus gambar". **100% gagal, bukan kadang-kadang.**

#### P0-4 · Host tidak bisa memuat properti `draft` miliknya

`GET properties/{id}` berada di grup **publik**
([api_mobile.php baris 36-51](laravel/routes/api_mobile.php#L36-L51)) — tanpa middleware `sanctum`.
Konsekuensinya `$request->user()` bernilai `null`, sehingga guard di
[show() baris 207-211](laravel/app/Http/Controllers/Api/PropertyController.php#L207-L211):

```php
abort_if($property->status !== 'active' && $property->host_id !== optional($request->user())->id, 404, ...);
```

selalu memenuhi syarat abort untuk properti non-`active` → **404**. Padahal default `status` di DB
adalah `draft`.

Dan tidak ada alternatif: daftar route host
([baris 134-141](laravel/routes/api_mobile.php#L134-L141)) hanya punya `GET host/properties`
(index), `POST`, `PUT`, dan tiga route gallery. **Tidak ada `GET host/properties/{property}`.**
Detail lengkap satu properti draft karena itu tidak bisa diambil oleh pemiliknya sendiri.

#### P0-5 · Blok `other` hanya dikirim kalau `prices` tidak kosong

[property_form_screen.dart:346](flutter/lib/screens/mitra/property_form_screen.dart#L346):

```dart
if (prices.isNotEmpty)
  'other': { ...32 field... },   // baris 347-380
```

Kalau host mengisi tab detail (spesifikasi, fasilitas kamar, catatan check-in, tempat sekitar) tapi
belum mengisi harga apa pun — misalnya menyimpan sebagai **draft** — seluruh blok `other` tidak
dikirim. Tidak ada pesan error. Data yang baru diketik hilang tanpa jejak.

### §1.2 Detail P1 — high

#### P1-1 · Empat field di-hardcode setiap submit

[property_form_screen.dart:352-354 & 379](flutter/lib/screens/mitra/property_form_screen.dart#L352-L354):

```dart
'star_rating': _type == 'hotel_residence' || _type == 'hotel' ? 4 : null,   // 352
'check_in_time': '14:00:00',                                               // 353
'check_out_time': '12:00:00',                                              // 354
...
'review_summary': {'average': 0, 'total': 0, 'label': '', 'breakdown': []}, // 379
```

Tidak ada input UI untuk keempatnya, dan tidak dibaca dari data awal. Jadi setiap simpan:
bintang direset ke 4 (atau `null`), jam check-in/out dipaksa 14:00/12:00, dan **ringkasan ulasan
nyata ditimpa nol** — termasuk `breakdown` enam kategori yang diisi
[PropertiesOtherSeeder baris 175-187](laravel/database/seeders/PropertiesOtherSeeder.php#L175-L187).

#### P1-2 · `index()` tidak eager-load `other`

[PropertyController.php:46-50](laravel/app/Http/Controllers/Api/PropertyController.php#L46-L50):

```php
$query = Property::query()->where('status', 'active')
    ->with(['prices', 'city', 'hotel.roomTypes', 'masterFacilities'])   // ← tidak ada 'other'
    ->withCount('reviews')->withAvg('reviews', 'rating');
```

`PropertyResource` mengambil `other` lewat
[baris 36](laravel/app/Http/Resources/PropertyResource.php#L36):
`$other = $this->relationLoaded('other') ? $this->other : null;` — sengaja **tidak** lazy-load.
Jadi di `GET properties` dan hasil pencarian, **27 dari 31 kunci** yang bersumber dari `other`
terdampak. Rinciannya:

- **23 kunci** jatuh ke nilai kosong: `type_label` `''`, `specs` `[]`, `price_caption`
  `'per bulan mulai dari'`, `is_flash_sale` `false`, `intro` `''`, `has_breakfast` `false`,
  `extra_media_count` `0`, `deposit_amount` `null`, dan seterusnya.
- **3 kunci hilang seluruhnya** — `star_rating`, `check_in_time`, `check_out_time`. Fallback-nya
  `whenLoaded('hotel')`, dan untuk properti unit relasi itu tidak dimuat, jadi hasilnya `MissingValue`
  → Laravel membuang kuncinya.
- **1 kunci turun kualitas** — `review_summary` jadi `{average, total, label:'', breakdown:[]}` dari
  agregat, kehilangan breakdown per kategori.

Empat kunci sisanya selamat karena punya fallback yang benar-benar bekerja: `cover`/`cover_image`
(ke `gallery[0]`), `province` dan `area_label` (ke relasi `city`, yang **memang** dimuat).

Bandingkan: [show() baris 213](laravel/app/Http/Controllers/Api/PropertyController.php#L213) dan
[hostIndex() baris 284](laravel/app/Http/Controllers/Api/PropertyController.php#L284) **memuat**
`other`. Jadi field yang sama muncul terisi di detail tapi kosong di list — inkonsistensi ini yang
membuat UI list terlihat "kurang data" padahal DB-nya lengkap.

#### P1-3 · Respons `store()`/`update()` bentuknya beda dari `show()`

`rating` dan `review_count` di PropertyResource memakai `$this->when(isset(...))`
([baris 66-67](laravel/app/Http/Resources/PropertyResource.php#L66-L67)) — `when()` yang gagal
**menghilangkan key-nya sama sekali**, bukan mengirim `null`.

| Endpoint | Agregat ulasan | `rating` / `review_count` |
|---|---|---|
| `GET properties` ([49-50](laravel/app/Http/Controllers/Api/PropertyController.php#L49-L50)) | `withCount` + `withAvg` | ✅ ada |
| `GET properties/{id}` ([214-215](laravel/app/Http/Controllers/Api/PropertyController.php#L214-L215)) | `loadCount` + `loadAvg` | ✅ ada |
| `GET host/properties` ([285-286](laravel/app/Http/Controllers/Api/PropertyController.php#L285-L286)) | `withCount` + `withAvg` | ✅ ada |
| `POST host/properties` ([442](laravel/app/Http/Controllers/Api/PropertyController.php#L442)) | — tidak ada | ❌ **key hilang** |
| `PUT host/properties/{id}` ([475](laravel/app/Http/Controllers/Api/PropertyController.php#L475)) | — tidak ada | ❌ **key hilang** |

Fixture host justru **mencantumkan** kedua key itu, jadi fixture dan API nyata tidak sinkron
(lihat §2 koreksi #6).

#### P1-4 · Livewire `WizardForm` tanpa otorisasi

[WizardForm.php](laravel/app/Livewire/Properties/WizardForm.php) tidak memanggil
`$this->authorize()` di `edit()` maupun `save()`. Sementara grup admin di
[web.php:41](laravel/routes/web.php#L41) memakai `role:admin|host` — **host ikut masuk**.

Dua properti publik komponen (`$propertyId` dan field `host_id`) dapat dimanipulasi klien, dan
endpoint `/livewire/update` **tidak** memutar ulang middleware `role`/`permission` Spatie
(lihat [laravel/CLAUDE.md](laravel/CLAUDE.md) bagian "Guard permission"). Artinya seorang host bisa
mengedit properti host lain, dan bisa memindahkan kepemilikan properti dengan mengubah `host_id`.

#### P1-5 · `bathrooms` tidak punya kolom di mana pun

[pricing() baris 243](laravel/app/Http/Controllers/Api/PropertyController.php#L243):
`'bathrooms' => (int) ($property->other?->bathrooms ?? 0),`

Kolom `bathrooms` **tidak ada** di
[properties](laravel/database/migrations/2026_07_14_080100_create_properties_table.php) maupun di
[properties_other](laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php)
(33 kolom data, tak satu pun `bathrooms`). Eloquent mengembalikan `null` untuk atribut yang tidak
ada → hasilnya **selalu `0`**. Satu-satunya tempat jumlah kamar mandi tersimpan sekarang adalah
sebagai string di dalam `specs` JSONB
([contoh seeder baris 34](laravel/database/seeders/PropertiesOtherSeeder.php#L34):
`['icon' => 'bathroom', 'label' => '2']`) — tidak bisa difilter, tidak bisa di-`orderBy`.

#### P1-6 · Duplikat `price_type` → HTTP 500

[migration `add_unique_price_type_to_property_prices_table`](laravel/database/migrations/2026_08_09_121326_add_unique_price_type_to_property_prices_table.php)
memasang `unique(['property_id', 'price_type'])`. Tapi validasi
[baris 498-500](laravel/app/Http/Controllers/Api/PropertyController.php#L498-L500) hanya memeriksa
tipe per baris, tidak keunikan antar baris:

```php
'prices' => ['nullable', 'array'],
'prices.*.price_type' => ['required_with:prices', 'string', 'in:daily,weekly,monthly,yearly'],
```

Kalau klien mengirim dua baris `monthly`, loop di
[store() 431-435](laravel/app/Http/Controllers/Api/PropertyController.php#L431-L435) /
[update() 458-463](laravel/app/Http/Controllers/Api/PropertyController.php#L458-L463) melempar
`QueryException` → **500**, bukan 422 yang bisa ditangani UI.

#### P1-7 · Lima konvensi penamaan fasilitas

| Sumber | Bentuk | Contoh |
|---|---|---|
| [PropertySeeder baris 36](laravel/database/seeders/PropertySeeder.php#L36) | slug snake_case | `wifi`, `ac`, `swimming_pool`, `washing_machine` |
| [komentar migration `facilities.slug`](laravel/database/migrations/2026_08_13_000008_create_master_facilities_tables.php#L13) | slug pendek | `wifi`, `pool`, `breakfast`, `gym` |
| [property_form_screen.dart:49-52](flutter/lib/screens/mitra/property_form_screen.dart#L49-L52) | Title Case + varian | `Wi-Fi`, `GYM`, `Access Card` |
| [WizardForm.php:35](laravel/app/Livewire/Properties/WizardForm.php#L35) | Title Case | `Wi-Fi`, `AC`, `TV`, `Kitchen` |
| Fixture `GET_properties_id.json` | CamelCase tanpa pemisah | `WiFi`, `Gym`, `Parking` |

> Baris kedua adalah **komentar**, bukan data — tabel `facilities` kosong, jadi `pool` tidak pernah
> ada di DB. Karena itu D-1 memilih `swimming_pool` (yang benar-benar tersimpan lewat
> `PropertySeeder`), bukan `pool`. Jangan "memperbaiki" seeder agar cocok dengan komentar itu;
> arahnya justru sebaliknya — komentarnya yang perlu diperbarui.


Filter di [baris 141-152](laravel/app/Http/Controllers/Api/PropertyController.php#L141-L152) mencoba
dua jalur — `whereHas('masterFacilities', slug)` **atau** `LIKE '%"slug"%'` pada JSONB — dan
**keduanya mati**:

- Jalur master: **tidak ada seeder** yang mengisi tabel `facilities`. Di DB hasil
  `php artisan migrate --seed`, tabel itu kosong, jadi `whereHas` tidak pernah cocok.
- Jalur JSONB: `strtolower(trim($fac))` di
  [baris 144](laravel/app/Http/Controllers/Api/PropertyController.php#L144) mengubah `Wi-Fi` → `wi-fi`,
  yang tidak sama dengan `wifi` yang tersimpan. Dan untuk baris hasil API, string-nya ber-escape
  ganda (P0-2) sehingga pola `"wifi"` juga gagal.

#### P1-8 · Path gambar campur aduk

- [baris 341](flutter/lib/screens/mitra/property_form_screen.dart#L341) mengirim `gallery` sebagai
  path **relatif** (`_toRelativePath`), tapi
  [baris 349-350](flutter/lib/screens/mitra/property_form_screen.dart#L349-L350) mengirim
  `other.cover` / `other.cover_image` = `_gallery.first` — **URL absolut**, tanpa dikonversi.
- [PropertyResource baris 16](laravel/app/Http/Resources/PropertyResource.php#L16) membungkus
  `gallery` dengan `asset('storage/'.$path)` tapi `cover` di
  [baris 58-59](laravel/app/Http/Resources/PropertyResource.php#L58-L59) dipakai apa adanya →
  kalau gallery kosong, `cover` keluar mentah.
- [baris 364](flutter/lib/screens/mitra/property_form_screen.dart#L364) merakit
  `map_preview` dari Google Static Maps **tanpa parameter `key=`** → Google menolak, gambar rusak.
  (Catatan: `googleMapsApiKey` ada di config Flutter tapi tidak ada package maps terpasang.)
- Seeder mengisi `cover`, `cover_image`, `map_preview`, dan `building_units.image` dengan
  `https://example.com/...`
  ([baris 19-20, 44, 172](laravel/database/seeders/PropertiesOtherSeeder.php#L19-L20)) — domain
  dummy yang bocor ke aplikasi.

#### P1-9 · `reviews[].photos` string JSON, bukan array

[migration reviews baris 19](laravel/database/migrations/2026_07_14_081500_create_reviews_table.php#L19)
mendeklarasikan `$table->json('photos')->nullable();`, tetapi
[model Review](laravel/app/Models/Review.php) **tidak punya `$casts`** sama sekali. Jadi
`$r->photos` mengembalikan **string** mentah, dan
[PropertyResource baris 99](laravel/app/Http/Resources/PropertyResource.php#L99)
`'photos' => $r->photos ?? []` mengirim string itu ke klien. Sisi Dart mengharapkan `List`.

#### P1-10 · `period_label` — kolom yang ada justru diabaikan

Kolom `reviews.period_label` **sudah ada**
([migration](laravel/database/migrations/2026_08_16_081501_add_period_label_to_reviews_table.php))
dan sudah masuk `$fillable`
([Review.php:22](laravel/app/Models/Review.php#L22)). Tapi
[PropertyResource baris 95](laravel/app/Http/Resources/PropertyResource.php#L95) menghitungnya
ulang dari relasi lain:

```php
'period_label' => $r->booking?->duration_type ?? '',
```

`show()` hanya memuat `reviews.user`
([baris 213](laravel/app/Http/Controllers/Api/PropertyController.php#L213)) — **bukan**
`reviews.booking`. Jadi `$r->booking` memicu satu query lazy **per ulasan** (N+1), sementara kolom
yang sudah disiapkan tidak pernah dipakai.

#### P1-11 · `asked_by` FK user diserialisasi mentah

[migration property_questions](laravel/database/migrations/2026_08_16_000004_create_property_questions_table.php)
mendefinisikan `asked_by` sebagai `foreignId(...)->constrained('users')->nullable()` — sebuah
**integer FK**. Tapi:

- [PropertyResource baris 105](laravel/app/Http/Resources/PropertyResource.php#L105) mengirim
  `'asked_by' => $q->asked_by` — angka mentah.
- Fixture mengirim `"asked_by": "Budi"` — sebuah **nama**.
- [PropertyQuestionSeeder baris 21 & 28](laravel/database/seeders/PropertyQuestionSeeder.php#L21)
  mengisi `'asked_by' => null`.

Sisi Dart menstringifikasi apa pun yang datang, jadi UI menampilkan `"3"` atau string kosong,
bukan nama penanya. Relasi `asker` juga belum ada di model.

#### P1-12 · `_status` yang dimuat tidak pernah dipakai

[baris 56](flutter/lib/screens/mitra/property_form_screen.dart#L56) mendeklarasikan
`String _status = 'active';`, dan [baris 238](flutter/lib/screens/mitra/property_form_screen.dart#L238)
mengisinya dari data properti. Tetapi `_status` **tidak pernah dibaca lagi** — payload memakai
parameter method:

```dart
Future<void> _submit({String status = 'active'}) async { ... 'status': status, ... }   // 307, 340
onPressed: () => _submit(status: 'draft'),    // 443
onPressed: () => _submit(status: 'active'),   // 451
```

Enum `status` punya lima nilai (`draft`, `active`, `inactive`, `maintenance`, `fully_booked` —
[validateProperty baris 496](laravel/app/Http/Controllers/Api/PropertyController.php#L496)), tapi
form hanya bisa menghasilkan dua. Properti yang sedang `maintenance` atau `fully_booked` akan
**naik jadi `active`** begitu host menekan "Simpan Perubahan".

### §1.3 Detail P2 — medium

**P2-1 · Default `WizardForm` menyimpang dari default DB.**
[baris 30](laravel/app/Livewire/Properties/WizardForm.php#L30) `public $status = 'active';` sedangkan
kolom `status` di
[migration properties](laravel/database/migrations/2026_07_14_080100_create_properties_table.php)
ber-default `draft`. Ditambah
[baris 35](laravel/app/Livewire/Properties/WizardForm.php#L35) yang mengisi
`facilities = ['Wi-Fi','AC','TV','Kitchen']` otomatis — admin bisa menerbitkan properti dengan
fasilitas yang tidak pernah ia pilih.

**P2-2 · `WizardForm` hanya mengelola satu baris harga & hardcode `booking_mode`.**
[baris 122](laravel/app/Livewire/Properties/WizardForm.php#L122) `$property->prices()->first()`
mengambil baris **sembarang** (tanpa `orderBy`), lalu
[baris 183-192](laravel/app/Livewire/Properties/WizardForm.php#L183-L192) `updateOrCreate` hanya
menulis satu `price_type`. Baris harga lain tidak terlihat dan tidak bisa diedit dari admin panel.
[baris 160](laravel/app/Livewire/Properties/WizardForm.php#L160) memaksa `'booking_mode' => 'unit'`.
Komponen ini juga **tidak menyentuh `properties_other`** sama sekali — semua field kaya tak
terjangkau dari admin panel.

**P2-3 · Tiga kolom mati di `properties_other`.**
`rating` ([baris 18](laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php#L18)),
`review_count` ([19](laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php#L19)),
dan `price_from` ([17](laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php#L17))
ada di tabel, ada di `$fillable`
([PropertyOther.php:21-22](laravel/app/Models/PropertyOther.php#L21-L22)), dan diisi seeder
([22-23](laravel/database/seeders/PropertiesOtherSeeder.php#L22-L23)) — tetapi **tidak pernah dibaca
PropertyResource**, yang memakai agregat `reviews_avg_rating`/`reviews_count` dan `$cheapestPrice`.
Keduanya juga tidak ada di `validateProperty()` sehingga tidak bisa ditulis via API. Nilai
`rating: 4.8` di DB dan `rating` di respons bisa berbeda tanpa ada yang tahu.

**P2-4 · Seeder `properties_other` hanya mengisi 1 dari 4 properti.**
[PropertiesOtherSeeder baris 12-15](laravel/database/seeders/PropertiesOtherSeeder.php#L12-L15)
mencari satu properti bernama `'Sunset Beach Apartment'` dan `return` diam-diam kalau tidak ada.
Tiga properti lain dari [PropertySeeder](laravel/database/seeders/PropertySeeder.php) tidak punya
baris `properties_other`. Lebih buruk: seeder mengisi `province => 'Bali'` dan `area_label => 'Bali'`
([18, 29](laravel/database/seeders/PropertiesOtherSeeder.php#L18-L29)) padahal properti tersebut
dibuat di **Jakarta** oleh `PropertySeeder` → `province` dari `other` menang di
[PropertyResource baris 63](laravel/app/Http/Resources/PropertyResource.php#L63), jadi respons
menyatakan Bali untuk properti Jakarta.

**P2-5 · Kontrak `pricing()` menyimpang dari model Dart.**

| Dikirim API | Dibaca Dart | Status |
|---|---|---|
| `inclusions.collapsed_rows` ([253](laravel/app/Http/Controllers/Api/PropertyController.php#L253)) | — tidak dibaca ([unit_pricing.dart:78-81](flutter/lib/models/unit_pricing.dart#L78-L81)) | ❌ dibuang |
| `add_ons[].is_selected` (usulan doc lama) | `json['selected']` ([131](flutter/lib/models/unit_pricing.dart#L131)) | ❌ nama beda |
| `special_prices[].min_nights` | `as int?` ([100](flutter/lib/models/unit_pricing.dart#L100)) | ⚠️ crash kalau API kirim desimal |

**P2-6 · Tidak ada endpoint hapus properti.**
[api_mobile.php baris 134-141](laravel/routes/api_mobile.php#L134-L141) tidak punya
`DELETE host/properties/{property}`, dan `PropertyController` tidak punya method `destroy()`.
Host hanya bisa mengubah `status` ke `inactive`.

**P2-7 · Model Dart `Property` tanpa `toJson()`.**
[property.dart](flutter/lib/models/property.dart) (702 baris) punya `fromJson` lengkap dengan
tipe kaya (`SpecItem`, `FacilityItem`, `InfoNote`, `UnitDetailRow`, `NearbyPlace`, `GalleryItem`,
`BuildingUnitsTeaser`, `ReviewSummary`, `PropertyQuestion`) tapi **nol** method serialisasi balik.
Itulah akar struktural P0-1: karena tidak ada `toJson()`, seseorang menulis `_propertyToMap` manual
di layar form dan lupa 16 field.

**P2-8 · `description_extra` direkonstruksi, bukan dipertahankan.**
[baris 325-329](flutter/lib/screens/mitra/property_form_screen.dart#L325-L329) membangun
`descriptionExtra` dari `intro` + `description_extra_heading`, lalu mengirimnya sebagai
`other.description_extra` ([362](flutter/lib/screens/mitra/property_form_screen.dart#L362)).
Paragraf asli (dua paragraf deskriptif di seeder) tidak pernah dimuat dan langsung tertimpa oleh
duplikat intro + judul.

**P2-9 · `pricing().thumbnail` salah dua kali.**
[baris 241](laravel/app/Http/Controllers/Api/PropertyController.php#L241):
`'thumbnail' => $property->cover ?? $property->gallery[0] ?? null,`
— `properties` **tidak punya** kolom `cover` (Eloquent → `null`), lalu `gallery[0]` adalah path
**relatif** tanpa `asset('storage/'.…)`. Berbeda dari `PropertyResource` yang selalu membungkus
dengan `asset()` ([baris 16](laravel/app/Http/Resources/PropertyResource.php#L16)).

---

## §2 Koreksi terhadap versi lama dokumen ini

Versi lama readme ini (819 baris, struktur "Audit Komparatif → §1 Sinkronisasi → §2 Seeder →
§3 Analisis Kelemahan → §4 Instruksi Eksekusi → §5 Kesimpulan") sebagian besar benar pada
**tabel pemetaan baris `PropertyResource`** — nomor barisnya akurat. Delapan klaim lainnya salah dan
**tidak boleh dieksekusi apa adanya**.

### K-1 · ❌ "Perbaiki `PropertyController@pricing` agar mengambil data dari DB"

Ini instruksi P1 paling menonjol di versi lama (§4.2.C). **Method itu sudah mengambil data dari DB.**
[pricing() baris 223-261](laravel/app/Http/Controllers/Api/PropertyController.php#L223-L261) sudah
melakukan `$property->prices()->where('price_type', $priceType)->first()`, sudah `abort_if` 404 kalau
harga tidak ada, dan sudah mengeluarkan `base_price` + `service_fee` nyata.

Empat "perbaikan" yang diusulkan versi lama semuanya menunjuk hal yang **tidak ada**:

| Usulan versi lama | Kenyataan |
|---|---|
| `$property->specialPrices` | Relasi tidak ada di [Property.php](laravel/app/Models/Property.php) |
| `$property->addOns` | Relasi tidak ada |
| `$property->paymentPlans` | Relasi tidak ada |
| `other.inclusions_included` / `other.inclusions_excluded` | Kolom tidak ada di `properties_other` |
| `other.bathrooms` | Kolom tidak ada — **dan** versi lama di tempat lain mengusulkan `bathrooms` ditaruh di tabel `properties`, saling bertentangan |

**Keputusan: JANGAN sentuh `pricing()` untuk empat hal itu.** Yang benar-benar perlu diperbaiki di
method ini hanya `thumbnail` (P2-9) dan `bathrooms` setelah kolomnya dibuat (P1-5).

### K-2 · ❌ "`GET_properties_id_host.json` = detail properti untuk host/manajemen"

Salah. File itu adalah respons dari **`GET properties/{id}/host`** — informasi **pemilik**, bukan
properti. Isinya delapan field yang dibangun
[`host()` baris 400-419](laravel/app/Http/Controllers/Api/PropertyController.php#L400-L419):
`id`, `name`, `email`, `phone`, `is_verified`, `company_name`, `joined_at`, `total_properties`.
Suffix `_host` pada nama file merujuk ke segmen URL, bukan ke peran pengguna.

Selain itu inventaris fixture versi lama hanya menyebut **4 file** padahal ada **12+** fixture
properti di [flutter/assets/json/](flutter/assets/json/) — lihat §8.1.

### K-3 · ⚠️ "`_status` di-hardcode `active` saat submit"

Setengah benar, dan setengah yang salah menyesatkan arah perbaikan. `status` **memang dikirim** dan
nilainya **ditentukan tombol** (`draft` vs `active`) — bukan hardcode `active`.
Bug sebenarnya adalah `_status` hasil load tidak pernah dibaca, sehingga status `inactive`,
`maintenance`, dan `fully_booked` tidak bisa dipertahankan. Rumusan yang benar ada di **P1-12**.

### K-4 · ❌ "`price_original` dihitung dari `prices`"

Salah. `$priceOriginal` **hanya** di-assign di dalam cabang `$hotelLoaded`
([PropertyResource baris 27-30](laravel/app/Http/Resources/PropertyResource.php#L27-L30)):

```php
if ($hotelLoaded) {
    $cheapestPrice = $this->hotel->price_from;
    $priceOriginal = $this->hotel->price_original;   // ← satu-satunya sumber
}
```

Untuk `booking_mode != 'room'`, `price_original` **selalu `null`**. Tidak ada fallback dari
`prices`. Kalau fitur "harga coret" diinginkan untuk properti unit, itu **pekerjaan baru** dengan
keputusan sumber data tersendiri (§3.5 D-6), bukan sekadar mengoreksi dokumentasi.

### K-5 · ❌ Daftar kolom `properties_other` versi lama tidak lengkap

Versi lama melewatkan tiga kolom yang **sudah ada** — `rating`, `review_count`, dan `price_from`
([baris 17-19](laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php#L17-L19)).
Ini bukan detail sepele: setiap rencana "tambah kolom rating" akan menabrak kolom yang sudah ada.
Daftar 33 kolom yang otoritatif ada di **§3.2**.

### K-6 · ❌ Usulan kolom `property_add_ons.is_selected`

Nama field-nya salah. Model Dart membaca `json['selected']`
([unit_pricing.dart:131](flutter/lib/models/unit_pricing.dart#L131)), bukan `is_selected`. Kalau
tabel dibuat dengan nama `is_selected` dan API mengirimkannya apa adanya, checkbox add-on **tidak
akan pernah** tercentang. (Keputusan apakah tabel ini dibuat sama sekali: §3.5 D-4.)

### K-7 · ❌ "Flutter: create dan edit sudah memakai form yang sama — ✅ sudah lengkap"

Bertentangan langsung dengan **P0-1** dan **P0-3**. Benar bahwa keduanya memakai satu widget, tapi
jalur edit kehilangan 16 field dan tombol hapus foto 100% gagal. Kesimpulan "sudah lengkap" inilah
yang membuat masalah ini tidak terdeteksi.

### K-8 · ⚠️ "Butuh 4 migration baru"

Versi lama menyimpulkan perlu empat migration: `bathrooms`, `property_special_prices`,
`property_add_ons`, `property_payment_plans`. Hanya **satu** yang jelas dibutuhkan sekarang
(`bathrooms`). Tiga sisanya adalah fitur yang **belum ada UI-nya, belum ada endpoint-nya, dan belum
ada keputusan produknya** — membuat tabel kosong hanya menambah utang skema. Lihat **§3.5 D-4**
dan §5.

### K-9 · ℹ️ Yang versi lama benar dan tetap dipakai

- Seluruh tabel pemetaan field → nomor baris `PropertyResource` (60 field) — **akurat**, dipakai
  ulang sebagai basis §3.3.
- Observasi bahwa `properties_other` menampung mayoritas field kaya sebagai JSONB — benar.
- Observasi bahwa `PropertySeeder` tidak mengisi `booking_mode`, `cancellation_policy`, dan
  `properties_other` — benar (lihat P2-4).

---

## §3 Ground truth

Semua tabel di bagian ini dibaca langsung dari migration & source. **Pakai ini sebagai satu-satunya
acuan nama field.** Jangan menyalin nama field dari fixture — fixture punya penyimpangan sendiri (§8.1).

### §3.1 Kolom tabel `properties` (17 kolom data + timestamps)

| Kolom | Tipe | Null | Default | Sumber migration |
|---|---|---|---|---|
| `id` | bigint PK | — | auto | [create_properties](laravel/database/migrations/2026_07_14_080100_create_properties_table.php#L12) |
| `host_id` | FK `users` cascade | ✗ | — | [#L13](laravel/database/migrations/2026_07_14_080100_create_properties_table.php#L13) |
| `city_id` | FK `cities` nullOnDelete | ✓ | `null` | [add_city_id](laravel/database/migrations/2026_08_08_000002_add_city_id_to_properties_table.php#L12) |
| `property_type` | enum | ✗ | — | [#L14](laravel/database/migrations/2026_07_14_080100_create_properties_table.php#L14) + [pgsql check](laravel/database/migrations/2026_08_13_000001_update_properties_for_hotels.php#L19) |
| `booking_mode` | string | ✗ | `'unit'` | [update_for_hotels #L12](laravel/database/migrations/2026_08_13_000001_update_properties_for_hotels.php#L12) |
| `name` | string | ✗ | — | #L15 |
| `building_name` | string | ✓ | `null` | #L16 |
| `description` | text | ✓ | `null` | #L17 |
| `address` | text | ✗ | — | #L18 |
| `latitude` | decimal(10,7) | ✓ | `null` | #L19 |
| `longitude` | decimal(10,7) | ✓ | `null` | #L20 |
| `guest_capacity` | uint | ✗ | `1` | #L21 |
| `bedrooms` | uint | ✗ | `1` | #L22 |
| `facilities` | json | ✓ | `null` | #L23 |
| `gallery` | json | ✓ | `null` | #L24 |
| `status` | enum | ✗ | **`'draft'`** | #L25 |
| `cancellation_policy` | string | ✓ | `null` | [add_cancellation_policy](laravel/database/migrations/2026_08_09_121257_add_cancellation_policy_to_properties_table.php#L15) |

**Nilai enum yang sah:**

- `property_type` — `apartment`, `house`, `villa`, `hotel_residence`, `guest_house`, `exclusive_kost`,
  **`hotel`**. Nilai `hotel` masuk lewat CHECK constraint yang dibangun ulang untuk pgsql
  ([baris 19](laravel/database/migrations/2026_08_13_000001_update_properties_for_hotels.php#L19)).
  ⚠️ Dua tempat **membatasi ke 6 nilai** tanpa `hotel`:
  [WizardForm rules baris 57](laravel/app/Livewire/Properties/WizardForm.php#L57) dan
  [`kCreatablePropertyTypes`](flutter/lib/screens/mitra/property_form_screen.dart#L16-L23).
  Ini **disengaja** — properti bertipe `hotel` dibuat lewat modul hotel, bukan form ini. Jangan "perbaiki".
- `booking_mode` — `unit` | `room`. Kolomnya `string`, **bukan** enum: tidak ada constraint DB.
- `status` — `draft`, `active`, `inactive`, `maintenance`, `fully_booked`.

**Yang TIDAK ada di `properties`:** `bathrooms`, `cover`, `rating`, `review_count`, `price_from`,
`star_rating`, `check_in_time`, `check_out_time`, `size`, `floor`, `tower`.

### §3.2 Kolom tabel `properties_other` (34 kolom data + `property_id` + timestamps)

Relasi `hasOne` dari `Property` ([Property.php:75-78](laravel/app/Models/Property.php#L75-L78)),
`property_id` **unique** — satu baris per properti.
Sumber: [create_properties_other_table](laravel/database/migrations/2026_08_16_000001_create_properties_other_table.php).

| # | Kolom | Tipe | Dibaca `PropertyResource`? | Bisa ditulis via API? |
|---|---|---|---|---|
| 1 | `province` | string | ✅ [L63](laravel/app/Http/Resources/PropertyResource.php#L63) | ✅ |
| 2 | `cover` | string | ✅ [L58](laravel/app/Http/Resources/PropertyResource.php#L58) (fallback) | ✅ |
| 3 | `cover_image` | string | ✅ [L59](laravel/app/Http/Resources/PropertyResource.php#L59) (fallback) | ✅ |
| 4 | `price_from` | decimal(15,2) | ❌ **kolom mati** (P2-3) | ✅ |
| 5 | `rating` | decimal(3,2) | ❌ **kolom mati** (P2-3) | ❌ tidak divalidasi |
| 6 | `review_count` | uint | ❌ **kolom mati** (P2-3) | ❌ tidak divalidasi |
| 7 | `star_rating` | utinyint | ✅ [L52](laravel/app/Http/Resources/PropertyResource.php#L52) | ✅ |
| 8 | `check_in_time` | time | ✅ [L53](laravel/app/Http/Resources/PropertyResource.php#L53) | ✅ |
| 9 | `check_out_time` | time | ✅ [L54](laravel/app/Http/Resources/PropertyResource.php#L54) | ✅ |
| 10 | `has_breakfast` | bool | ✅ [L55](laravel/app/Http/Resources/PropertyResource.php#L55) | ✅ |
| 11 | `type_label` | string | ✅ L80 | ✅ |
| 12 | `area_label` | string | ✅ L81 | ✅ |
| 13 | `extra_media_count` | uint | ✅ L82 | ✅ |
| 14 | `specs` | json | ✅ L83 | ✅ |
| 15 | `is_favorite` | bool | ✅ L84 | ✅ |
| 16 | `intro` | text | ✅ L120 | ✅ |
| 17 | `description_extra` | json | ✅ L121 | ✅ |
| 18 | `description_extra_heading` | string | ✅ L122 | ✅ |
| 19 | `map_preview` | string | ✅ L123 | ✅ |
| 20 | `price_caption` | string, default `'per bulan mulai dari'` | ✅ L124 | ✅ |
| 21 | `is_flash_sale` | bool | ✅ L125 | ✅ |
| 22 | `bed_facilities` | json | ✅ L108 | ✅ |
| 23 | `building_facilities` | json | ✅ L109 | ✅ |
| 24 | `building_facilities_all` | json | ✅ L110 | ✅ |
| 25 | `room_furniture` | json | ✅ L111 | ✅ |
| 26 | `room_furniture_groups` | json | ✅ L112 | ✅ |
| 27 | `check_in_notes` | json | ✅ L113 | ✅ |
| 28 | `deposit_amount` | decimal(15,2) | ✅ L114 | ✅ |
| 29 | `deposit_notes` | json | ✅ L115 | ✅ |
| 30 | `unit_detail` | json | ✅ L116 | ✅ |
| 31 | `nearby` | json | ✅ L117 | ✅ |
| 32 | `guest_media` | json | ✅ L118 | ✅ |
| 33 | `building_units` | json | ✅ L119 | ✅ |
| 34 | `review_summary` | json | ✅ [L85-90](laravel/app/Http/Resources/PropertyResource.php#L85-L90) | ✅ |

> Kolom 34 baris — nomor 4/5/6 adalah tiga kolom mati. **Tidak ada kolom `bathrooms`** dan tidak ada
> `inclusions_included` / `inclusions_excluded` (bertentangan dengan usulan versi lama, lihat K-1).

"Bisa ditulis via API" merujuk `validateProperty()`
([baris 505-537](laravel/app/Http/Controllers/Api/PropertyController.php#L505-L537)) — 31 aturan
`other.*`, tanpa `rating` dan `review_count`.

### §3.3 Endpoint & bentuk respons

Semua endpoint di bawah memakai satu Resource yang sama —
[`PropertyResource`](laravel/app/Http/Resources/PropertyResource.php) (60 key) — tetapi **isi
respons berbeda** karena `PropertyResource` sengaja hanya membaca relasi yang sudah di-eager-load
(`relationLoaded`/`whenLoaded`). Tabel ini adalah kontrak sebenarnya:

| Method + path | Auth | Controller | Eager load | `other`? | `rating`/`review_count`? |
|---|---|---|---|---|---|
| `GET properties` | publik | [index()](laravel/app/Http/Controllers/Api/PropertyController.php#L46-L50) | `prices, city, hotel.roomTypes, masterFacilities` | ❌ **P1-2** | ✅ |
| `GET properties/{id}` | publik | [show()](laravel/app/Http/Controllers/Api/PropertyController.php#L205-L221) | `prices, host, city, hotel.roomTypes, masterFacilities, other, reviews.user, questions` | ✅ | ✅ |
| `GET properties/{id}/pricing` | publik | [pricing()](laravel/app/Http/Controllers/Api/PropertyController.php#L223-L261) | — (bentuk khusus, bukan Resource) | — | — |
| `GET properties/{id}/availability` | publik | [availability()](laravel/app/Http/Controllers/Api/PropertyController.php#L263-L277) | — (bentuk khusus) | — | — |
| `GET properties/{id}/host` | publik | [host()](laravel/app/Http/Controllers/Api/PropertyController.php#L400-L419) | — (info pemilik, 8 field) | — | — |
| `GET host/properties` | sanctum | [hostIndex()](laravel/app/Http/Controllers/Api/PropertyController.php#L279-L295) | `prices, city, hotel.roomTypes, other` | ✅ | ✅ |
| `POST host/properties` | sanctum | [store()](laravel/app/Http/Controllers/Api/PropertyController.php#L421-L445) | `prices, city, other` | ✅ | ❌ **P1-3** |
| `PUT host/properties/{id}` | sanctum | [update()](laravel/app/Http/Controllers/Api/PropertyController.php#L447-L478) | `prices, city, other` | ✅ | ❌ **P1-3** |
| `POST host/properties/gallery/upload` | sanctum | [uploadGallery()](laravel/app/Http/Controllers/Api/PropertyController.php#L297-L309) | — → `{path, url}` | — | — |
| `DELETE host/properties/{id}/gallery` | sanctum | [deleteGallery()](laravel/app/Http/Controllers/Api/PropertyController.php#L311-L343) | — → `{gallery, cover, deleted}` | — | — |
| `DELETE host/properties/gallery` | sanctum | [deleteGalleryTemp()](laravel/app/Http/Controllers/Api/PropertyController.php#L345-L378) | — → `{deleted}` | — | — |
| **`GET host/properties/{id}`** | — | **TIDAK ADA** — P0-4 | — | — | — |
| **`DELETE host/properties/{id}`** | — | **TIDAK ADA** — P2-6 | — | — | — |

Route: publik di [api_mobile.php baris 36-51](laravel/routes/api_mobile.php#L36-L51), host di
[baris 134-141](laravel/routes/api_mobile.php#L134-L141).

Dua catatan penting tentang bentuk respons:

1. **`$this->when()` menghilangkan key, bukan mengirim `null`.** `rating` dan `review_count`
   ([L66-67](laravel/app/Http/Resources/PropertyResource.php#L66-L67)) memakai
   `$this->when(isset($this->reviews_avg_rating), …)`. Klien Dart **harus** aman terhadap key yang
   absen, bukan hanya terhadap `null`.
2. **Semua respons dibungkus amplop** `{ status, code, message, data, meta, errors }` (+ `error_code`
   saat gagal) oleh [ApiResponse](laravel/app/Support/ApiResponse.php). Kuncinya `status` bertipe
   **bool** — bukan `success`.

### §3.4 Matriks alur field host: DB → API → Form Flutter

Kolom "Load" = apakah nilainya sampai ke form saat mode edit. Kolom "Submit" = apakah nilainya
dikirim balik. Baris yang **Load ❌ / Submit ✅** adalah baris yang menyebabkan kehilangan data (P0-1).

| Field (`other.*` kecuali disebut) | Load ke form | Submit dari form | Sumber nilai saat submit | Status |
|---|---|---|---|---|
| `name`, `address`, `building_name`, `description` (kolom `properties`) | ✅ | ✅ | input user | ✅ |
| `property_type`, `city_id`, `guest_capacity`, `bedrooms` | ✅ | ✅ | input user | ✅ |
| `latitude`, `longitude` | ✅ | ✅ | input user | ✅ |
| `facilities` (kolom `properties`) | ✅ | ✅ | chip pilihan | ⚠️ P0-2 + P1-7 |
| `gallery` (kolom `properties`) | ✅ | ✅ | upload | ⚠️ P1-8 |
| `status` (kolom `properties`) | ✅ ke `_status` | ✅ tapi dari tombol | tombol draft/active | ❌ P1-12 |
| `prices[]` (tabel `property_prices`) | ✅ | ✅ | input per tipe | ⚠️ P1-6 |
| `intro` | ✅ | ✅ | input user | ✅ |
| `description_extra_heading` | ✅ | ✅ | input user | ✅ |
| `price_caption`, `is_flash_sale` | ✅ | ✅ | input user | ✅ |
| `deposit_amount` | ✅ | ✅ | input user | ✅ |
| `is_favorite` | ✅ dari data | ❌ tidak ada di `_propertyToMap` | selalu `false` | ❌ P0-1 |
| `specs` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `check_in_notes` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `deposit_notes` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `unit_detail` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `nearby` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `bed_facilities` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `building_facilities` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `building_facilities_all` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `room_furniture` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `room_furniture_groups` | ✅ dari data | ❌ | `[]` | ❌ P0-1 |
| `questions` (tabel `property_questions`) | ✅ dari data | ❌ tidak pernah dikirim | — | ❌ P0-1 |
| `description_extra` | ❌ tidak dibaca | ✅ direkonstruksi | intro + heading | ❌ P2-8 |
| `guest_media` | ❌ tidak dibaca | ✅ selalu | `[]` | ❌ P0-1 |
| `building_units` | ❌ tidak dibaca | ✅ selalu | `null` | ❌ P0-1 |
| `review_summary` | ❌ tidak dibaca | ✅ selalu | nol semua | ❌ P1-1 |
| `star_rating` | ❌ | ✅ selalu | `4` atau `null` | ❌ P1-1 |
| `check_in_time` / `check_out_time` | ❌ | ✅ selalu | `'14:00:00'` / `'12:00:00'` | ❌ P1-1 |
| `cover`, `cover_image` | ❌ | ✅ | `_gallery.first` (URL absolut) | ❌ P1-8 |
| `map_preview` | ❌ | ✅ | Static Maps tanpa API key | ❌ P1-8 |
| `province`, `area_label`, `type_label` | ❌ | ✅ | diturunkan dari `city` / tipe | ⚠️ acceptable |
| `extra_media_count` | ❌ | ✅ | `_gallery.length` | ⚠️ acceptable |
| `has_breakfast` | ❌ | ✅ | `facilities.contains('Breakfast')` | ⚠️ rapuh (P1-7) |
| `cancellation_policy` (kolom `properties`) | ❌ | ❌ tidak ada di form | — | ⚠️ gap fitur |
| `booking_mode` (kolom `properties`) | ❌ | ❌ | default `'unit'` di server | ✅ by design |
| `bathrooms` | — | — | **kolom tidak ada** | ❌ P1-5 |

### §3.5 Keputusan — WAJIB diikuti, jangan improvisasi

Setiap keputusan di bawah menutup satu pertanyaan terbuka. AI yang mengeksekusi **tidak boleh**
mengambil arah lain tanpa persetujuan manusia.

**D-1 · Konvensi fasilitas = slug huruf kecil, sumber kebenaran `facilities.slug`.**
Bentuk kanonik adalah slug pada tabel master `facilities`
([migration](laravel/database/migrations/2026_08_13_000008_create_master_facilities_tables.php#L13)).
Kolom JSONB `properties.facilities` **menyimpan slug yang sama** (bukan label).
Label untuk UI diambil dari `facilities.name`, bukan di-hardcode di Flutter.
Slug yang dipakai (mengikuti seeder yang sudah ada, karena datanya sudah tertulis di DB):
`wifi`, `ac`, `kitchen`, `parking`, `swimming_pool`, `tv`, `washing_machine`, `security`,
`elevator`, `gym`, `breakfast`, `access_card`, `water_heater`.
**Bukan** migrasi ke pivot `facility_property` — itu di luar cakupan; kolom JSONB tetap jadi
penyimpanan utama untuk properti unit.

**D-2 · Perbaiki double-encode dengan MENGHAPUS `json_encode`, bukan menghapus `$casts`.**
`$casts` adalah perilaku Laravel yang benar dan dipakai `WizardForm`
([baris 169](laravel/app/Livewire/Properties/WizardForm.php#L169) mengirim array). Yang salah adalah
`json_encode` manual di controller. Jangan balik arahnya.
**Wajib disertai backfill** untuk baris yang sudah tersimpan ber-escape ganda (§6 Langkah 2b).

**D-3 · Mode edit HARUS memuat detail lengkap dari API, bukan merekonstruksi dari model list.**
Ini menutup P0-1 dan P0-4 sekaligus. `PropertyFormScreen` dalam mode edit memanggil endpoint baru
`GET host/properties/{id}` dan memakai **map JSON mentah** hasilnya sebagai `initialData`.
`_propertyToMap` **dihapus** — bukan dilengkapi. Alasan: melengkapinya berarti memelihara dua
serializer yang harus selalu sinkron dengan 34 kolom `properties_other`; sumber bug yang sama akan
muncul lagi setiap kali ada kolom baru.
Konsekuensi: `Property.toJson()` **tidak perlu dibuat** (P2-7 selesai dengan sendirinya).

**D-4 · `special_prices`, `add_ons`, `payment_plans`, `inclusions` = DITUNDA. Tidak ada tabel baru.**
`pricing()` tetap mengembalikan `[]` / `null` untuk keempatnya. Alasan: tidak ada UI input, tidak ada
endpoint pengelolaan, dan belum ada keputusan produk soal aturannya. Membuat empat tabel kosong
sekarang hanya menambah skema yang tidak terpakai.
Kalau nanti dibangun, catat dua hal ini: nama field add-on adalah **`selected`** (bukan
`is_selected`, lihat K-6), dan `min_nights` harus dikirim sebagai **integer** (Dart memakai
`as int?`, [unit_pricing.dart:100](flutter/lib/models/unit_pricing.dart#L100)).

**D-5 · `bathrooms` = kolom baru di tabel `properties`, bukan di `properties_other`.**
Alasan: `bathrooms` sekelas dengan `bedrooms` dan `guest_capacity` — atribut inti yang perlu
di-filter dan di-`orderBy`. Menaruhnya di `properties_other` membuatnya tidak bisa difilter tanpa
join, dan `properties_other` memang dirancang untuk field presentasi. Tipe: `unsignedInteger`
nullable (bukan `default(1)` — properti lama tidak boleh diklaim punya 1 kamar mandi).

**D-6 · `price_original` untuk `booking_mode = 'unit'` = DILUAR CAKUPAN.**
Tetap `null`. Fitur "harga coret" untuk properti unit butuh keputusan sumber harga pembanding
(harga lama? harga sebelum diskon? harga pasar?) yang belum ada. Jangan mengarang fallback dari
`prices`. Cukup dokumentasikan di §7 sebagai perilaku yang benar.

**D-7 · Sumber kebenaran `review_summary` = `properties_other.review_summary` (JSONB), ditulis server.**
Tidak ada tabel `property_review_summaries` baru. Klien **berhenti mengirim** `other.review_summary`
sama sekali, dan `validateProperty()` **menolak** field itu (`prohibited`). Perhitungannya jadi
tanggung jawab server. Untuk tahap ini cukup: jangan ditimpa. Recompute otomatis
(event/listener saat review masuk) dicatat sebagai pekerjaan lanjutan, bukan bagian dari eksekusi ini.
Hal yang sama berlaku untuk `star_rating`, `check_in_time`, `check_out_time`: klien hanya boleh
mengirimnya kalau ada input UI-nya. Karena belum ada, klien berhenti mengirim.

**D-8 · `asked_by` tetap FK integer di DB; API mengirim NAMA.**
Tambah relasi `asker()` di `PropertyQuestion`, lalu serialisasi
`'asked_by' => $q->asker?->name ?? 'Pengguna'`. Ini menyamakan API dengan yang sudah diharapkan
fixture dan model Dart, tanpa mengubah skema. Jangan mengganti tipe kolom jadi string.

**D-9 · Path gambar: DB simpan RELATIF, URL absolut hanya diturunkan di Resource.**
Berlaku untuk `properties.gallery`, `other.cover`, `other.cover_image`. Klien mengirim path relatif
untuk ketiganya (`_toRelativePath` dipakai konsisten). `PropertyResource` membungkus ketiganya
dengan `asset('storage/'.…)`. `map_preview` **tidak** dikirim klien — kalau nanti dibutuhkan,
dibangun di server dengan API key dari config.

**D-10 · `status`: form mempertahankan nilai yang tidak bisa diwakili tombol.**
Tombol "Simpan Draft" → `draft`, "Publikasikan"/"Simpan Perubahan" → `active`. Tetapi kalau properti
sedang `inactive`, `maintenance`, atau `fully_booked`, tombol simpan **mempertahankan** status itu
(tidak menaikkannya ke `active`). Perubahan status ke/dari ketiga nilai tersebut adalah aksi
terpisah, bukan efek samping menyimpan form.

**D-11 · Tiga kolom mati tidak di-drop, tapi ditutup aksesnya.**
`other.rating`, `other.review_count`, `other.price_from` **tetap ada** di DB (drop kolom butuh
migration destruktif di produksi — keputusan terpisah). Yang dilakukan sekarang: keluarkan dari
`$fillable` [PropertyOther](laravel/app/Models/PropertyOther.php), berhenti mengisinya di seeder, dan
tulis komentar yang menunjuk sumber sebenarnya (`reviews_avg_rating` / `reviews_count` /
`price_from` dari `prices`). Dengan begitu tidak ada lagi jalur tulis yang menghasilkan nilai
menyesatkan.

**D-12 · Tabel master `facilities` harus diisi seeder.**
Tanpa itu separuh filter fasilitas mati permanen (lihat P1-7). Ini alasan `FacilitySeeder` masuk
daftar file baru di §5.

---

## §4 FILE YANG PERLU DI-UPDATE

18 file. Kolom "Temuan" merujuk ID di §1. Kode konkret ada di §6.

### §4.1 Laravel — controller, resource, model

| # | File | Yang diubah | Temuan |
|---|---|---|---|
| U-1 | [PropertyController.php](laravel/app/Http/Controllers/Api/PropertyController.php) | **9 perubahan** (rincian di bawah) | P0-2, P0-4, P1-2, P1-3, P1-5, P1-6, P2-6, P2-9, D-7 |
| U-2 | [PropertyResource.php](laravel/app/Http/Resources/PropertyResource.php) | `period_label` dari kolom; `asked_by` → nama; `cover`/`cover_image` lewat `asset()`; tambah `bathrooms` | P1-8, P1-10, P1-11, P1-5 |
| U-3 | [Property.php](laravel/app/Models/Property.php) | tambah `'bathrooms'` ke `$fillable` | P1-5 |
| U-4 | [Review.php](laravel/app/Models/Review.php) | tambah `protected $casts = ['photos' => 'array'];` | P1-9 |
| U-5 | [PropertyQuestion.php](laravel/app/Models/PropertyQuestion.php) | tambah relasi `asker(): BelongsTo` ke `User` | P1-11, D-8 |
| U-6 | [PropertyOther.php](laravel/app/Models/PropertyOther.php) | keluarkan `rating`, `review_count`, `price_from` dari `$fillable` + komentar | P2-3, D-11 |
| U-7 | [api_mobile.php](laravel/routes/api_mobile.php) | tambah 2 route host (`GET` + `DELETE` per-properti) | P0-4, P2-6 |
| U-8 | [WizardForm.php](laravel/app/Livewire/Properties/WizardForm.php) | `authorize()` di `edit()` & `save()`; `host_id` tidak boleh dari input klien; `$status` default `'draft'`; `$facilities` default `[]`; slug, bukan Title Case | P1-4, P2-1, D-1 |

**Rincian U-1 — sembilan perubahan di `PropertyController`:**

| Sub | Lokasi | Perubahan |
|---|---|---|
| U-1a | [store() L425](laravel/app/Http/Controllers/Api/PropertyController.php#L425) | **hapus** `json_encode` pada `facilities` (D-2) |
| U-1b | [update() L452-454](laravel/app/Http/Controllers/Api/PropertyController.php#L452-L454) | **hapus** `json_encode` pada `facilities` (D-2) |
| U-1c | [index() L48](laravel/app/Http/Controllers/Api/PropertyController.php#L48) | tambah `'other'` ke `with([...])` |
| U-1d | [store() L442](laravel/app/Http/Controllers/Api/PropertyController.php#L442) & [update() L475](laravel/app/Http/Controllers/Api/PropertyController.php#L475) | tambah `->loadCount('reviews')->loadAvg('reviews','rating')` |
| U-1e | [validateProperty() L482](laravel/app/Http/Controllers/Api/PropertyController.php#L482) | tambah `bathrooms`; tambah `distinct` untuk `prices.*.price_type`; set `other.review_summary`, `other.rating`, `other.review_count`, `other.price_from` → `prohibited` |
| U-1f | [pricing() L241](laravel/app/Http/Controllers/Api/PropertyController.php#L241) | `thumbnail` pakai `asset('storage/'.…)`, buang `$property->cover` |
| U-1g | [pricing() L243](laravel/app/Http/Controllers/Api/PropertyController.php#L243) | `bathrooms` baca `$property->bathrooms` (kolom baru), bukan `other` |
| U-1h | method baru `hostShow()` | detail satu properti milik host, memuat semua relasi + agregat (P0-4) |
| U-1i | method baru `destroy()` | hapus properti milik host (P2-6) |

> `pricing()` **selain** U-1f dan U-1g **tidak boleh diubah** — lihat K-1.

### §4.2 Laravel — seeder

| # | File | Yang diubah | Temuan |
|---|---|---|---|
| U-9 | [PropertySeeder.php](laravel/database/seeders/PropertySeeder.php) | tambah `booking_mode`, `cancellation_policy`, `bathrooms`; sebar kota (jangan semua Jakarta); slug fasilitas ikut D-1 | P2-4, P1-5, D-1 |
| U-10 | [PropertiesOtherSeeder.php](laravel/database/seeders/PropertiesOtherSeeder.php) | **jangan** hanya 1 properti — loop semua properti unit; `province`/`area_label` ikut kota properti; ganti semua `https://example.com/...` jadi path relatif; hapus `rating`/`review_count`/`price_from` | P2-4, P1-8, D-9, D-11 |
| U-11 | [PropertyQuestionSeeder.php](laravel/database/seeders/PropertyQuestionSeeder.php) | `asked_by` diisi ID user nyata, bukan `null` | P1-11 |
| U-12 | [DatabaseSeeder.php](laravel/database/seeders/DatabaseSeeder.php) | daftarkan `FacilitySeeder` (sebelum `PropertySeeder`) | D-12 |

### §4.3 Flutter

| # | File | Yang diubah | Temuan |
|---|---|---|---|
| U-13 | [property_form_screen.dart](flutter/lib/screens/mitra/property_form_screen.dart) | **7 perubahan** (rincian di bawah) | P0-1, P0-3, P0-5, P1-1, P1-8, P1-12, P2-8, D-1, D-3 |
| U-14 | [host_service.dart](flutter/lib/services/host_service.dart) | tambah `propertyDetail(int id)` dan `deleteProperty(int id)` | P0-4, P2-6 |
| U-15 | [dummy_api_client.dart](flutter/lib/services/dummy_api_client.dart) | daftarkan dua endpoint baru ke peta fixture — **wajib**, kalau tidak mode `DUMMY_API=true` pecah | P0-4, P2-6 |
| U-16 | [property.dart](flutter/lib/models/property.dart) | tambah field `bathrooms` di `fromJson` | P1-5 |
| U-17 | [unit_pricing.dart](flutter/lib/models/unit_pricing.dart) | `InclusionList.fromJson` baca `collapsed_rows`; `SpecialPriceTier.minNights` toleran terhadap `num` | P2-5 |
| U-18 | [GET_properties_id.json](flutter/assets/json/GET_properties_id.json) + fixture properti lain | `facilities` jadi slug (D-1); tambah `bathrooms`; ganti URL `example.com` | D-1, P1-5, P1-8 |

**Rincian U-13 — tujuh perubahan di `property_form_screen.dart`:**

| Sub | Lokasi | Perubahan |
|---|---|---|
| U-13a | [L125](flutter/lib/screens/mitra/property_form_screen.dart#L125) + [L815-846](flutter/lib/screens/mitra/property_form_screen.dart#L815-L846) | **hapus `_propertyToMap`**; mode edit `await _service.propertyDetail(widget.property!.id)` lalu pakai map mentahnya (D-3) |
| U-13b | [L687-691](flutter/lib/screens/mitra/property_form_screen.dart#L687-L691) | syarat cabang jadi berbasis ID properti, bukan `initialData != null` (P0-3) |
| U-13c | [L346](flutter/lib/screens/mitra/property_form_screen.dart#L346) | kirim `other` **tanpa syarat** `prices.isNotEmpty` (P0-5) |
| U-13d | [L352-354, L379](flutter/lib/screens/mitra/property_form_screen.dart#L352-L354) | **hapus** `star_rating`, `check_in_time`, `check_out_time`, `review_summary` dari payload (P1-1, D-7) |
| U-13e | [L349-350, L364](flutter/lib/screens/mitra/property_form_screen.dart#L349-L350) | `cover`/`cover_image` pakai `_toRelativePath`; **hapus** `map_preview` dari payload (P1-8, D-9) |
| U-13f | [L340](flutter/lib/screens/mitra/property_form_screen.dart#L340) | `status` mempertahankan `_status` untuk nilai non-draft/active (P1-12, D-10) |
| U-13g | [L49-52](flutter/lib/screens/mitra/property_form_screen.dart#L49-L52) + [L325-329](flutter/lib/screens/mitra/property_form_screen.dart#L325-L329) | fasilitas jadi pasangan slug↔label (D-1); `description_extra` dimuat & dipertahankan, bukan direkonstruksi (P2-8) |

**Yang TIDAK perlu diubah:**
[router.dart:268](flutter/lib/router.dart#L268) tetap mengirim `property:` saja — dengan D-3, layar
form yang mengambil detail lengkap sendiri, jadi router tidak perlu tahu apa-apa. Jangan ubah.

---

## §5 FILE YANG PERLU DIBUAT BARU

**7 file baru.** Setiap baris menyatakan **jenisnya secara eksplisit** — migration, model, seeder,
fixture, atau kode biasa — supaya tidak ada kebingungan saat eksekusi.

### §5.1 Ringkasan jenis

| Jenis | Jumlah | Keterangan |
|---|---|---|
| **Migration** | **3** | 1 tambah kolom (N-1) + 2 perbaikan data / backfill (N-2, N-7) |
| **Model Eloquent** | **0** | ❗ Tidak ada model baru. `Facility`, `PropertyOther`, `PropertyQuestion` semuanya sudah ada |
| **Seeder** | **1** | `FacilitySeeder` — tabel master `facilities` belum pernah diisi siapa pun |
| **Route** | **0 file baru** | Dua route baru ditambahkan ke [api_mobile.php](laravel/routes/api_mobile.php) yang sudah ada (U-7) |
| **Controller** | **0 file baru** | Dua method baru masuk ke `PropertyController` yang sudah ada (U-1h, U-1i) |
| **API Resource** | **0** | `PropertyResource` sudah ada — cukup di-update (U-2) |
| **Kode Flutter** | **1** | Peta slug↔label fasilitas + builder payload, dipisah dari widget |
| **Fixture JSON** | **2** | Untuk dua endpoint baru, dipakai `DummyApiClient` (tanpa ini mode dummy 404) |
| **Test** | **0** | Diminta dilewati. Verifikasi dilakukan manual — lihat §7 |

### §5.2 Migration (3 file)

**N-1 · `laravel/database/migrations/2026_08_18_000001_add_bathrooms_to_properties_table.php`**
Jenis: **migration skema**. Menambah satu kolom sesuai **D-5**.

```php
public function up(): void
{
    Schema::table('properties', function (Blueprint $table) {
        // Core searchable attribute, sits alongside bedrooms/guest_capacity (see D-5).
        // Nullable on purpose: existing rows have no known value.
        $table->unsignedInteger('bathrooms')->nullable()->after('bedrooms');
    });
}

public function down(): void
{
    Schema::table('properties', function (Blueprint $table) {
        $table->dropColumn('bathrooms');
    });
}
```

**N-2 · `laravel/database/migrations/2026_08_18_000002_fix_double_encoded_facilities.php`**
Jenis: **migration data (backfill)**, bukan skema. Wajib menyertai U-1a/U-1b — menghapus
`json_encode` hanya memperbaiki tulisan **baru**; baris yang sudah tersimpan ber-escape ganda tetap
rusak sampai diperbaiki.

```php
public function up(): void
{
    // Rows written by the old API store()/update() were json_encode()d on top of the
    // 'facilities' => 'array' cast, so the column holds a JSON *string*, e.g. "[\"Wi-Fi\"]".
    // Decode one extra layer and rewrite as a real JSON array.
    DB::table('properties')->select('id', 'facilities')->orderBy('id')
        ->chunk(200, function ($rows) {
            foreach ($rows as $row) {
                if ($row->facilities === null) {
                    continue;
                }
                $decoded = json_decode($row->facilities, true);
                // A correctly-stored row decodes straight to an array. A double-encoded
                // row decodes to a string that needs a second pass.
                if (! is_string($decoded)) {
                    continue;
                }
                $inner = json_decode($decoded, true);
                if (! is_array($inner)) {
                    continue;
                }
                DB::table('properties')->where('id', $row->id)
                    ->update(['facilities' => json_encode(array_values($inner))]);
            }
        });
}

public function down(): void
{
    // Data repair — intentionally irreversible.
}
```

> ⚠️ Migration ini **tidak** menormalkan Title Case → slug. Itu pekerjaan **N-7** di bawah, dipisah
> karena butuh peta slug yang sama dengan `FacilitySeeder` dan harus jalan **setelah** double-encode
> beres — kalau dibalik, normalisasi membaca string dan tidak menemukan apa pun.

**N-7 · `laravel/database/migrations/2026_08_18_000003_normalize_property_facility_slugs.php`**
Jenis: **migration data (backfill)**. Menyatukan lima ejaan fasilitas yang beredar di DB menjadi satu
slug kanonik (D-1). Tanpa ini, separuh filter pencarian yang baru hidup di tahap 2
(`orWhere('facilities','like','%"wifi"%")`) tetap melewatkan baris yang menyimpan `"Wifi"` atau
`"Swimming Pool"` — dan itu justru baris yang dibuat lewat admin panel.

```php
public function up(): void
{
    // Five spellings of the same facility exist in the wild: the lowercase slugs
    // written by PropertySeeder, the Title-Case labels written by the Livewire
    // WizardForm and by early builds of the Flutter form, plus space- and
    // dash-separated variants. Collapse them all onto the canonical slug.
    // Keep this map in sync with FacilitySeeder (N-3) and kPropertyFacilities (N-4).
    $canonical = [
        'wifi', 'ac', 'kitchen', 'parking', 'swimming_pool', 'tv',
        'washing_machine', 'security', 'elevator', 'gym', 'water_heater',
        'access_card', 'breakfast',
    ];

    // Display label -> slug, for rows that stored the human-readable text.
    $aliases = [
        'wi-fi' => 'wifi',
        'kolam_renang' => 'swimming_pool',
        'dapur' => 'kitchen',
        'parkir' => 'parking',
        'mesin_cuci' => 'washing_machine',
        'keamanan' => 'security',
        'keamanan_24_jam' => 'security',
        'lift' => 'elevator',
        'kartu_akses' => 'access_card',
        'sarapan' => 'breakfast',
        'pemanas_air' => 'water_heater',
    ];

    DB::table('properties')->select('id', 'facilities')->orderBy('id')
        ->chunk(200, function ($rows) use ($canonical, $aliases) {
            foreach ($rows as $row) {
                $list = json_decode((string) $row->facilities, true);
                if (! is_array($list)) {
                    continue;
                }

                $slugs = [];
                foreach ($list as $item) {
                    if (! is_string($item)) {
                        continue;
                    }
                    $key = strtolower(trim($item));
                    $key = preg_replace('/[\s-]+/', '_', $key);
                    $key = $aliases[$key] ?? $key;

                    if (in_array($key, $canonical, true)) {
                        $slugs[$key] = true;   // key dedupes
                    }
                    // Unknown values are dropped rather than kept as a sixth
                    // spelling. Nothing reads them and they only break filters.
                }

                $slugs = array_keys($slugs);
                if ($slugs !== array_values((array) $list)) {
                    DB::table('properties')->where('id', $row->id)
                        ->update(['facilities' => json_encode($slugs)]);
                }
            }
        });
}

public function down(): void
{
    // Data repair — intentionally irreversible.
}
```

> Sebelum menjalankan N-7, **catat dulu** nilai yang akan dibuang, supaya tidak ada fasilitas nyata
> yang hilang diam-diam. Perintahnya ada di §6 Tahap 6.


### §5.3 Seeder (1 file)

**N-3 · `laravel/database/seeders/FacilitySeeder.php`**
Jenis: **seeder**. Mengisi tabel master `facilities` yang **sampai sekarang kosong** — tidak ada satu
pun seeder yang menyentuhnya (D-12, P1-7). Tanpa file ini, cabang `whereHas('masterFacilities')` pada
filter pencarian mati permanen.

```php
<?php

namespace Database\Seeders;

use App\Models\Facility;
use Illuminate\Database\Seeder;

class FacilitySeeder extends Seeder
{
    /**
     * Canonical facility slugs (see D-1). The slug is the single source of truth:
     * properties.facilities (JSONB) stores these exact strings, and the UI label
     * comes from `name`, never from a hardcoded client-side list.
     */
    public function run(): void
    {
        $facilities = [
            ['slug' => 'wifi',            'name' => 'Wi-Fi',           'icon' => 'wifi',            'category' => 'general'],
            ['slug' => 'ac',              'name' => 'AC',              'icon' => 'ac',              'category' => 'room'],
            ['slug' => 'tv',              'name' => 'TV',              'icon' => 'tv',              'category' => 'room'],
            ['slug' => 'kitchen',         'name' => 'Dapur',           'icon' => 'kitchen',         'category' => 'room'],
            ['slug' => 'water_heater',    'name' => 'Water Heater',    'icon' => 'water_heater',    'category' => 'room'],
            ['slug' => 'washing_machine', 'name' => 'Mesin Cuci',      'icon' => 'washing_machine', 'category' => 'room'],
            ['slug' => 'parking',         'name' => 'Parkir',          'icon' => 'parking',         'category' => 'general'],
            ['slug' => 'swimming_pool',   'name' => 'Kolam Renang',    'icon' => 'pool',            'category' => 'general'],
            ['slug' => 'gym',             'name' => 'Gym',             'icon' => 'gym',             'category' => 'general'],
            ['slug' => 'security',        'name' => 'Keamanan 24 Jam', 'icon' => 'security',        'category' => 'general'],
            ['slug' => 'elevator',        'name' => 'Lift',            'icon' => 'elevator',        'category' => 'general'],
            ['slug' => 'access_card',     'name' => 'Kartu Akses',     'icon' => 'access_card',     'category' => 'general'],
            ['slug' => 'breakfast',       'name' => 'Sarapan',         'icon' => 'breakfast',       'category' => 'hotel'],
        ];

        foreach ($facilities as $facility) {
            Facility::updateOrCreate(['slug' => $facility['slug']], $facility);
        }
    }
}
```

Daftarkan di [DatabaseSeeder](laravel/database/seeders/DatabaseSeeder.php) pada blok
"Base / no FK dependencies" — **sebelum** `PropertySeeder` (U-12).

---

### §5.4 N-4 · Katalog fasilitas + builder payload (kode Flutter)

**Jenis: kode Dart biasa** (bukan test, bukan model DTO — model `Property` tidak diubah, lihat D-3).

**File baru:** `flutter/lib/screens/mitra/property_form_payload.dart`

**Kenapa dipisah dari widget.** [property_form_screen.dart](flutter/lib/screens/mitra/property_form_screen.dart)
panjang 856 baris dan blok payload-nya (L331-381) adalah sumber dari **4 temuan sekaligus**:
P0-2 (double encode fasilitas hulu-hilir), P0-5 (`other` hilang saat `prices` kosong),
P1-1 (empat field hardcode), P1-8 (path gambar campur absolut/relatif). Selama payload
menempel di `State`, tidak ada cara membacanya tanpa membaca seluruh widget. Setelah dipisah
jadi fungsi murni, isi payload bisa diperiksa mata langsung — dan itu penting karena §7
memverifikasi manual, tanpa test.

```dart
// lib/screens/mitra/property_form_payload.dart

/// Canonical facility catalogue for the host property form.
///
/// The **key is the wire format**: it is what `properties.facilities` (JSONB)
/// stores and what `facilities.slug` in the master table holds, so both halves
/// of the search filter in `PropertyController::index()` can match it. The
/// value is display-only — never send it to the API. See decision D-1.
const Map<String, String> kPropertyFacilities = <String, String>{
  'wifi': 'WiFi',
  'ac': 'AC',
  'kitchen': 'Dapur',
  'parking': 'Parkir',
  'swimming_pool': 'Kolam Renang',
  'tv': 'TV',
  'washing_machine': 'Mesin Cuci',
  'security': 'Keamanan 24 Jam',
  'elevator': 'Lift',
  'gym': 'Gym',
  'water_heater': 'Water Heater',
  'access_card': 'Kartu Akses',
  'breakfast': 'Sarapan',
};

/// Maps whatever a stored property holds onto a canonical slug.
///
/// Existing rows carry five different spellings of the same facility — the
/// Title-Case labels written by [WizardForm] and by earlier builds of this
/// screen, plus `Swimming Pool` / `swimming-pool` variants. Old data must still
/// light up the right checkbox, but every *write* leaves as a slug.
String? canonicalFacility(String raw) {
  final key = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  if (kPropertyFacilities.containsKey(key)) return key;
  // Label -> slug, for rows that stored the display text.
  for (final entry in kPropertyFacilities.entries) {
    if (entry.value.toLowerCase() == raw.trim().toLowerCase()) return entry.key;
  }
  return null; // unknown value: drop it rather than persist a sixth spelling
}

/// Normalises a stored list into canonical slugs, dropping unknown entries.
List<String> canonicalFacilities(Iterable<dynamic> raw) => raw
    .map((dynamic e) => canonicalFacility('$e'))
    .whereType<String>()
    .toSet()
    .toList();

/// Builds the request body for `POST host/properties` / `PUT host/properties/{id}`.
///
/// Rules baked in here, so the widget cannot re-break them:
/// * `facilities` holds slugs only — the controller stores the array as-is,
///   Eloquent's `array` cast does the single JSON encode (D-2).
/// * `other` is **always** present, even when [prices] is empty. Previously it
///   was emitted only for a non-empty price list, so a draft saved without a
///   price silently wiped all 16 detail fields (P0-1, P0-5).
/// * `gallery` and `cover` hold **relative** storage paths. Absolute URLs are
///   derived by `PropertyResource`, never stored (D-9).
/// * `star_rating`, `check_in_time`, `check_out_time`, `review_summary` and
///   `map_preview` are **not sent at all** — server-owned or derived (D-7, D-9).
/// * dead columns `price_from`, `rating`, `review_count` are not sent (D-11).
Map<String, dynamic> buildPropertyPayload({
  required String name,
  required String propertyType,
  required String address,
  required String buildingName,
  required String description,
  required int guestCapacity,
  required int bedrooms,
  int? bathrooms,
  required Set<String> facilities,
  required String status,
  required List<String> galleryRelativePaths,
  required int? cityId,
  double? latitude,
  double? longitude,
  required List<Map<String, dynamic>> prices,
  // `other` payload
  required String province,
  required String typeLabel,
  required String areaLabel,
  required String intro,
  required String descriptionExtraHeading,
  required List<String> descriptionExtra,
  required String priceCaption,
  required bool isFavorite,
  required bool isFlashSale,
  required double depositAmount,
  required List<dynamic> specs,
  required List<dynamic> bedFacilities,
  required List<dynamic> buildingFacilities,
  required List<dynamic> buildingFacilitiesAll,
  required List<dynamic> roomFurniture,
  required List<dynamic> roomFurnitureGroups,
  required List<dynamic> checkInNotes,
  required List<dynamic> depositNotes,
  required List<dynamic> unitDetail,
  required List<dynamic> nearby,
  required List<dynamic> guestMedia,
  required List<dynamic> buildingUnits,
}) {
  final slugs = canonicalFacilities(facilities);
  final cover = galleryRelativePaths.isNotEmpty
      ? galleryRelativePaths.first
      : null;

  return <String, dynamic>{
    'name': name,
    'property_type': propertyType,
    'address': address,
    'building_name': buildingName,
    'description': description,
    'guest_capacity': guestCapacity,
    'bedrooms': bedrooms,
    if (bathrooms != null) 'bathrooms': bathrooms,
    'facilities': slugs,
    'status': status,
    'gallery': galleryRelativePaths,
    'city_id': cityId,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'prices': prices,
    // Unconditional — see P0-5.
    'other': <String, dynamic>{
      'province': province,
      'cover': cover,
      'cover_image': cover,
      'has_breakfast': slugs.contains('breakfast'),
      'type_label': typeLabel,
      'area_label': areaLabel,
      'extra_media_count': galleryRelativePaths.length,
      'specs': specs,
      'is_favorite': isFavorite,
      'intro': intro,
      'description_extra': descriptionExtra,
      'description_extra_heading': descriptionExtraHeading,
      'price_caption': priceCaption,
      'is_flash_sale': isFlashSale,
      'bed_facilities': bedFacilities,
      'building_facilities': buildingFacilities,
      'building_facilities_all': buildingFacilitiesAll,
      'room_furniture': roomFurniture,
      'room_furniture_groups': roomFurnitureGroups,
      'check_in_notes': checkInNotes,
      'deposit_amount': depositAmount,
      'deposit_notes': depositNotes,
      'unit_detail': unitDetail,
      'nearby': nearby,
      'guest_media': guestMedia,
      'building_units': buildingUnits,
    },
  };
}
```

**Yang dipakai di widget** (detail di U-13):

```dart
final body = buildPropertyPayload(
  name: _nameCtrl.text.trim(),
  propertyType: _type,
  // ... dst
  status: _resolveStatus(status),   // U-13f — jaga inactive/maintenance/fully_booked
  galleryRelativePaths: _gallery.map(_toRelativePath).toList(),
  prices: prices,
);
```

---

### §5.5 N-5 & N-6 · Dua fixture JSON untuk mode dummy

**Jenis: fixture data**, bukan kode. Wajib, bukan opsional: `DummyApiClient._handle()`
melempar `ApiException(404, 'Endpoint dummy tidak tersedia: …')` untuk route yang tidak ada
di map `routes` ([dummy_api_client.dart:295-301](flutter/lib/services/dummy_api_client.dart#L295-L301)).
Menambah endpoint di `PropertyService` tanpa fixture = mode `--dart-define=DUMMY_API=true` pecah.

Konvensi nama sudah baku di folder ini: `GET host/properties/{id}` → basename
`GET_host_properties_id`. Registrasi map-nya bagian dari **U-15**.

| # | File baru | Route | Isi |
|---|---|---|---|
| **N-5** | `flutter/assets/json/GET_host_properties_id.json` | `GET host/properties/{id}` | satu properti **lengkap** — 26 field `other` terisi, `prices` 4 baris, `facilities` slug |
| **N-6** | `flutter/assets/json/DELETE_host_properties_id.json` | `DELETE host/properties/{id}` | amplop sukses sederhana |

**N-5** harus meniru bentuk `PropertyResource` **setelah** U-2, bukan sebelum. Urutan dan nama
kunci di bawah diambil langsung dari
[PropertyResource::toArray()](laravel/app/Http/Resources/PropertyResource.php#L38-L127) — bukan
karangan. Empat titik yang paling mudah salah:

1. Kuncinya **`city_name`**, bukan `city`. Dan **`price_from`**, bukan `price`. Tidak ada kunci
   `price_type` di level properti.
2. Review memakai **`user_name`** (string datar), bukan objek `user`. Pertanyaan **tidak punya
   `id`** — hanya `question`, `answer`, `asked_by`, `created_at`.
3. `star_rating`, `check_in_time`, `check_out_time` **tidak muncul sama sekali** untuk properti
   unit. Ekspresinya `$other?->star_rating ?? $this->whenLoaded('hotel', …)`
   ([L52-54](laravel/app/Http/Resources/PropertyResource.php#L52-L54)): kalau kolomnya `null` dan
   relasi `hotel` tidak dimuat — dan `hostShow()` memang tidak memuatnya — hasilnya `MissingValue`,
   dan Laravel **membuang kuncinya**. Jangan ditulis `null`; hilangkan barisnya.
4. `prices` adalah `whenLoaded('prices')` → koleksi model mentah, jadi ikut membawa `id`,
   `property_id`, `created_at`, `updated_at`, dan di PostgreSQL nilai `decimal` keluar sebagai
   **string** (`"850000.00"`), bukan angka.

```json
{
  "status": true,
  "code": 200,
  "message": "Detail properti berhasil dimuat.",
  "data": {
    "id": 1,
    "host_id": 2,
    "city_id": 1,
    "property_type": "apartment",
    "booking_mode": "unit",
    "name": "Sunset Beach Apartment",
    "building_name": "Sunset Tower",
    "description": "Apartemen 2 kamar dengan view kota.",
    "address": "Jl. Kemang Raya No. 12, Jakarta Selatan",
    "latitude": -6.2607,
    "longitude": 106.8134,
    "guest_capacity": 4,
    "bedrooms": 2,
    "bathrooms": 1,
    "has_breakfast": false,
    "facilities": ["wifi", "ac", "kitchen", "parking", "swimming_pool"],
    "gallery": [
      "http://10.0.2.2:8000/storage/properties/gallery/1-a.jpg",
      "http://10.0.2.2:8000/storage/properties/gallery/1-b.jpg"
    ],
    "cover": "http://10.0.2.2:8000/storage/properties/gallery/1-a.jpg",
    "cover_image": "http://10.0.2.2:8000/storage/properties/gallery/1-a.jpg",
    "status": "draft",
    "cancellation_policy": "flexible",
    "city_name": "Jakarta Selatan",
    "province": "DKI Jakarta",
    "price_from": "850000.00",
    "price_original": null,
    "rating": 4.7,
    "review_count": 12,
    "prices": [
      {"id": 1, "property_id": 1, "price_type": "daily",   "amount": "850000.00",    "cleaning_fee": "50000.00", "deposit": "500000.00",  "service_fee": "25000.00", "created_at": "2026-08-01T03:00:00.000000Z", "updated_at": "2026-08-01T03:00:00.000000Z"},
      {"id": 2, "property_id": 1, "price_type": "weekly",  "amount": "5200000.00",   "cleaning_fee": "50000.00", "deposit": "500000.00",  "service_fee": "25000.00", "created_at": "2026-08-01T03:00:00.000000Z", "updated_at": "2026-08-01T03:00:00.000000Z"},
      {"id": 3, "property_id": 1, "price_type": "monthly", "amount": "18000000.00",  "cleaning_fee": "75000.00", "deposit": "1000000.00", "service_fee": "50000.00", "created_at": "2026-08-01T03:00:00.000000Z", "updated_at": "2026-08-01T03:00:00.000000Z"},
      {"id": 4, "property_id": 1, "price_type": "yearly",  "amount": "190000000.00", "cleaning_fee": "75000.00", "deposit": "2000000.00", "service_fee": "50000.00", "created_at": "2026-08-01T03:00:00.000000Z", "updated_at": "2026-08-01T03:00:00.000000Z"}
    ],
    "type_label": "Apartemen",
    "area_label": "Jakarta Selatan",
    "extra_media_count": 2,
    "specs": [{"icon": "bed", "label": "2 Kamar"}],
    "is_favorite": false,
    "review_summary": {
      "average": 4.7,
      "total": 12,
      "label": "Sangat Baik",
      "breakdown": [
        {"label": "Kebersihan", "score": 4.8},
        {"label": "Lokasi", "score": 4.9}
      ]
    },
    "reviews": [
      {
        "id": 1,
        "user_name": "Rani",
        "rating": 5,
        "period_label": "monthly",
        "created_at": "2026-07-14T04:20:00.000000Z",
        "comment": "Bersih dan strategis.",
        "host_reply": "Terima kasih!",
        "photos": []
      }
    ],
    "question_count": 1,
    "questions": [
      {
        "question": "Boleh bawa hewan?",
        "answer": "Mohon maaf, belum bisa.",
        "asked_by": "Budi",
        "created_at": "2026-07-10T02:00:00.000000Z"
      }
    ],
    "bed_facilities": [],
    "building_facilities": [],
    "building_facilities_all": [],
    "room_furniture": [],
    "room_furniture_groups": [],
    "check_in_notes": [],
    "deposit_amount": "500000.00",
    "deposit_notes": [],
    "unit_detail": [],
    "nearby": [],
    "guest_media": [],
    "building_units": null,
    "intro": "Tinggal nyaman di jantung Kemang.",
    "description_extra": ["Tinggal nyaman di jantung Kemang.", "Tentang Unit Ini"],
    "description_extra_heading": "Tentang Unit Ini",
    "map_preview": null,
    "price_caption": "per malam",
    "is_flash_sale": false,
    "created_at": "2026-08-01T03:00:00.000000Z"
  },
  "meta": null,
  "errors": null
}
```

> `status` diisi `"draft"` **dengan sengaja** — fixture ini justru harus membuktikan bahwa jalur
> edit draft berfungsi, yaitu kasus yang selama ini 404 (P0-4). Kunci `hotel` dan `host` tidak ada
> karena `hostShow()` tidak memuat relasi itu; `whenLoaded` membuang kuncinya, bukan mengisi `null`.


**N-6** cukup pendek:

```json
{
  "status": true,
  "code": 200,
  "message": "Properti berhasil dihapus.",
  "data": {"deleted": true},
  "meta": null,
  "errors": null
}
```

> ⚠️ `ApiResponse.fromJson` **toleran** terhadap `status` yang hilang — fixture berbentuk
> `{"success": true}` tetap terparse tanpa error sambil melewati seluruh logika amplop
> ([api_response.dart:55](flutter/lib/models/api_response.dart#L55)). Jadi salah bentuk di sini
> tidak akan berbunyi sendiri. Pakai `status` (bool), persis seperti fixture host lain.

---

## §6 · LANGKAH EKSEKUSI

Tahap 0 (prasyarat, tanpa perubahan kode) + **sembilan tahap kerja**, dikerjakan
**berurutan**. Urutannya bukan selera: setiap tahap dipilih supaya aplikasi tetap
jalan setelah tahap itu selesai, dan supaya perubahan yang berisiko (tahap 2 dan 4) datang setelah
fondasinya ada. Jangan menggabung tahap — kalau ada yang pecah, batas tahap adalah tempat mencari.

| Tahap | Isi | Item | Risiko |
|---|---|---|---|
| **0** | Prasyarat lingkungan | — | — |
| **1** | Kolom `bathrooms` + rapikan model | N-1, U-3, U-4, U-5, U-6 | rendah |
| **2** | Perbaiki double-encode `facilities` + backfill | U-1a, U-1b, N-2 | **tinggi** |
| **3** | Validasi request | U-1e | sedang |
| **4** | Dua endpoint host baru | U-1h, U-1i, U-7, U-14, U-15, N-5, N-6 | sedang |
| **5** | Bersihkan `PropertyResource` | U-2, U-1c, U-1d, U-1f, U-1g | sedang |
| **6** | Normalisasi slug fasilitas | N-3, N-7, U-12 | **tinggi** |
| **7** | Form Mitra Flutter | N-4, U-13a…U-13g, U-16 | **tinggi** |
| **8** | Livewire admin | U-8 | rendah |
| **9** | Seeder & fixture | U-9, U-10, U-11, U-17, U-18 | rendah |

---

### Tahap 0 · Prasyarat

1. Pastikan DB aktif adalah **PostgreSQL** (`DB_CONNECTION=pgsql`). Tahap 2 dan 6 menyentuh JSONB;
   di SQLite hasilnya berbeda dan CHECK constraint tidak ditegakkan.
2. **Backup tabel** `properties` dan `properties_other` sebelum tahap 2 dan 6 — keduanya menulis
   ulang data yang sudah ada, bukan hanya skema.

   ```bash
   pg_dump -t properties -t properties_other -a -f backup_properties.sql "$DB_DATABASE"
   ```

3. Jangan pernah menyalin, menampilkan, atau meng-commit `.env` — berisi `DB_PASSWORD` nyata.
4. Catat jumlah baris awal, dipakai jadi pembanding di §7:

   ```bash
   php artisan tinker --execute="echo App\Models\Property::count().' / '.App\Models\PropertyOther::count();"
   ```

---

### Tahap 1 · Kolom `bathrooms` + rapikan model

**Kenapa pertama.** Tidak ada yang bergantung pada tahap ini, tapi tiga tahap berikutnya
bergantung padanya (validasi, Resource, form). Semua perubahan di sini aditif — tidak ada
perilaku lama yang berubah.

**1.1** Buat migration **N-1** (kode lengkap di §5.2), lalu jalankan:

```bash
php artisan make:migration add_bathrooms_to_properties_table
# tempel kode §5.2, lalu:
php artisan migrate
```

**1.2 · U-3** — [Property.php](laravel/app/Models/Property.php), tambahkan ke `$fillable`
tepat setelah `'bedrooms'`:

```php
'bathrooms',
```

**1.3 · U-4** — [Review.php](laravel/app/Models/Review.php). Model ini **tidak punya `$casts`
sama sekali**, padahal `photos` adalah kolom `json`. Tambahkan:

```php
/**
 * `photos` is a `json` column; without this cast Eloquent hands the raw
 * string to `PropertyResource`, which then serialises it as a JSON *string*
 * instead of an array — see P1-9.
 */
protected $casts = [
    'photos' => 'array',
    'rating' => 'integer',
];
```

**1.4 · U-5** — [PropertyQuestion.php](laravel/app/Models/PropertyQuestion.php). `asked_by` tetap
FK integer (D-8); yang kurang hanya relasinya:

```php
public function asker(): BelongsTo
{
    return $this->belongsTo(User::class, 'asked_by');
}
```

Jangan lupa `use Illuminate\Database\Eloquent\Relations\BelongsTo;`.

**1.5 · U-6** — [PropertyOther.php](laravel/app/Models/PropertyOther.php). Keluarkan tiga kolom
mati dari `$fillable` dan beri alasannya di tempat, supaya tidak dikembalikan orang lain:

```php
// `price_from`, `rating` and `review_count` are intentionally NOT fillable.
// Nothing reads them: prices come from the `property_prices` relation and the
// rating aggregates come from `withAvg`/`withCount` on `reviews`. Keeping them
// writable only invites two sources of truth. Columns are left in place — see
// decision D-11 — but they are write-locked here.
```

**Cek tahap 1:**

```bash
php artisan tinker --execute="
\$p = App\Models\Property::first();
\$p->bathrooms = 2; \$p->save();
echo 'bathrooms=' . \$p->fresh()->bathrooms . PHP_EOL;
echo 'photos cast=' . get_debug_type(App\Models\Review::first()?->photos) . PHP_EOL;
"
```

Harus tampil `bathrooms=2` dan `photos cast=array` (atau `null` kalau belum ada review).

---

### Tahap 2 · Perbaiki double-encode `facilities` (P0-2)

⚠️ **Tahap paling berisiko.** Dua langkah harus dilakukan **bersama** — kalau hanya kode yang
diperbaiki tanpa backfill, baris lama tetap rusak; kalau hanya backfill tanpa perbaikan kode,
penyimpanan berikutnya merusaknya lagi.

**2.1 · U-1a** — [PropertyController::store() L425](laravel/app/Http/Controllers/Api/PropertyController.php#L425).
Hapus barisnya:

```php
// SEBELUM
$data['facilities'] = json_encode($data['facilities'] ?? []);

// SESUDAH — the model already casts `facilities` to `array`; encoding here
// makes Eloquent encode the *string*, storing "\"[\\\"wifi\\\"]\"" (P0-2).
$data['facilities'] = $data['facilities'] ?? [];
```

**2.2 · U-1b** — [update() L452-454](laravel/app/Http/Controllers/Api/PropertyController.php#L452-L454).
Hapus seluruh blok `if`:

```php
// HAPUS
if (\array_key_exists('facilities', $data)) {
    $data['facilities'] = json_encode($data['facilities']);
}
```

Tidak perlu diganti apa pun — cast `array` di [Property.php](laravel/app/Models/Property.php)
sudah menangani encode-nya.

**2.3 · N-2** — jalankan migration backfill (kode lengkap di §5.2). Migration ini mendeteksi
baris yang isinya string JSON, lalu meng-decode-nya satu lapis:

```bash
php artisan migrate
```

**Cek tahap 2** — tidak boleh ada `facilities` bertipe string lagi:

```bash
php artisan tinker --execute="
foreach (App\Models\Property::all() as \$p) {
    \$raw = \$p->getRawOriginal('facilities');
    \$ok = is_array(json_decode(\$raw, true)) && ! is_string(json_decode(\$raw, true));
    echo \$p->id . ' ' . (\$ok ? 'OK' : 'RUSAK: ' . \$raw) . PHP_EOL;
}"
```

Semua baris harus `OK`. Satu pun `RUSAK` → backfill belum lengkap, jangan lanjut ke tahap 6.

---

### Tahap 3 · Validasi request (U-1e)

[validateProperty()](laravel/app/Http/Controllers/Api/PropertyController.php#L480) — empat
perubahan pada array aturan.

**3.1** Tambahkan `bathrooms` tepat setelah `bedrooms`:

```php
'bathrooms' => ['nullable', 'integer', 'min:0', 'max:20'],
```

**3.2** Tutup duplikasi `price_type` (P1-6). Tabel `property_prices` punya unique constraint
`(property_id, price_type)`, jadi payload dengan dua baris `daily` sekarang lolos validasi lalu
meledak jadi **500** di `->create()`. Ubah aturannya jadi:

```php
'prices'                 => ['sometimes', 'array'],
'prices.*.price_type'    => ['required_with:prices', 'string', 'in:daily,weekly,monthly,yearly', 'distinct'],
```

`distinct` mengubah 500 jadi 422 dengan pesan yang bisa ditampilkan.

**3.3** Tolak field yang dimiliki server (D-7, D-11). Tambahkan:

```php
// Server-owned: written by aggregates, never accepted from a client. `prohibited`
// returns 422 instead of silently ignoring the key, so a stale client build is
// visible rather than mysterious. See D-7 and D-11.
'other.review_summary' => ['prohibited'],
'other.star_rating'    => ['prohibited'],
'other.check_in_time'  => ['prohibited'],
'other.check_out_time' => ['prohibited'],
'other.rating'         => ['prohibited'],
'other.review_count'   => ['prohibited'],
'other.price_from'     => ['prohibited'],
'other.map_preview'    => ['prohibited'],
```

> Konsekuensi urutan: begitu langkah 3.3 aktif, **build Flutter lama akan gagal menyimpan** karena
> masih mengirim empat field itu. Karena itu tahap 7 (form Flutter) wajib dikerjakan pada rilis yang
> sama. Kalau perlu dipisah, jalankan 3.3 **paling akhir**, setelah tahap 7.

**3.4** `property_type` sudah memuat `hotel` di baris 484 — **jangan diubah**. Ini titik yang
mudah salah karena enum di migration awal tidak punya `hotel`; yang menambahkannya adalah
[update_properties_for_hotels](laravel/database/migrations) lewat CHECK constraint pgsql. Validasi
dan DB sudah sinkron.

---

### Tahap 4 · Dua endpoint host baru (P0-4, P2-6)

**4.1 · U-1h** — tambahkan `hostShow()` di
[PropertyController](laravel/app/Http/Controllers/Api/PropertyController.php), letakkan tepat
setelah `hostIndex()` supaya berdekatan:

```php
/**
 * Full detail of one property owned by the authenticated host.
 *
 * `GET properties/{id}` cannot serve the edit form: it lives in the *public*
 * route group, so `$request->user()` is always null there and the owner check
 * in `show()` can never pass — every non-`active` property 404s, and `draft`
 * is the DB default. See P0-4.
 */
public function hostShow(Property $property, Request $request)
{
    abort_unless($property->host_id === $request->user()->id, 403, 'Properti ini bukan milik Anda.');

    $property->load([
        'prices',
        'city',
        'other',
        'reviews.user',
        'reviews.booking',   // `period_label` fallback — avoids the N+1 in P1-10
        'questions.asker',   // question author name — see D-8
    ])
        ->loadCount('reviews')
        ->loadAvg('reviews', 'rating');

    return ApiResponse::success(
        new PropertyResource($property),
        'Detail properti berhasil dimuat.'
    );
}
```

**4.2 · U-1i** — tambahkan `destroy()`:

```php
/**
 * Deletes a property owned by the authenticated host.
 *
 * Gallery files are removed too: they live under `properties/gallery/` and
 * nothing else references them once the row is gone. `$property->gallery` is
 * cast to `array`, but older rows may still hold a JSON string — normalise
 * before iterating.
 */
public function destroy(Property $property, Request $request)
{
    abort_unless($property->host_id === $request->user()->id, 403, 'Properti ini bukan milik Anda.');

    $gallery = $property->gallery ?? [];
    if (\is_string($gallery)) {
        $gallery = json_decode($gallery, true) ?: [];
    }

    foreach ((array) $gallery as $path) {
        if (\is_string($path) && $this->isSafeGalleryPath($path)) {
            Storage::disk('public')->delete($path);
        }
    }

    $property->delete();

    return ApiResponse::success(['deleted' => true], 'Properti berhasil dihapus.');
}
```

`isSafeGalleryPath()` sudah ada (baris 382) dan `Storage` sudah ter-import — tidak ada import baru.

**4.3 · U-7** — [api_mobile.php](laravel/routes/api_mobile.php). ⚠️ **Urutan pendaftaran
menentukan.** Route baru harus diletakkan **setelah** baris 140, bukan sebelumnya:

```php
Route::get('host/properties', [PropertyController::class, 'hostIndex']);
Route::post('host/properties', [PropertyController::class, 'store']);
Route::put('host/properties/{property}', [PropertyController::class, 'update']);
Route::post('host/properties/gallery/upload', [PropertyController::class, 'uploadGallery']);
Route::delete('host/properties/{property}/gallery', [PropertyController::class, 'deleteGallery']);
Route::delete('host/properties/gallery', [PropertyController::class, 'deleteGalleryTemp']);
// ↓ BARU — must stay below `host/properties/gallery`, otherwise `{property}`
//   swallows the literal segment "gallery" and the temp-delete route 404s.
Route::get('host/properties/{property}', [PropertyController::class, 'hostShow']);
Route::delete('host/properties/{property}', [PropertyController::class, 'destroy']);
```

Verifikasi urutannya benar:

```bash
php artisan route:list --path=host/properties
```

`DELETE api/v1/host/properties/gallery` harus muncul **di atas**
`DELETE api/v1/host/properties/{property}`.

**4.4 · U-14** — [host_service.dart](flutter/lib/services/host_service.dart), dua method baru
setelah `updateProperty`:

```dart
  /// Full detail of one of the host's own properties.
  ///
  /// Returns the **raw map**, not a [Property]. The edit form needs all 26
  /// `properties_other` fields and the model carries only a fraction of them;
  /// mapping through [Property] is exactly how the old `_propertyToMap` lost
  /// 16 of them (P0-1, D-3).
  Future<Map<String, dynamic>> propertyDetail(int id) async {
    final res = await _api.get('host/properties/$id');
    return res.dataMap;
  }

  Future<void> deleteProperty(int id) async {
    await _api.delete('host/properties/$id');
  }
```

**4.5 · U-15** — [dummy_api_client.dart](flutter/lib/services/dummy_api_client.dart), tambahkan ke
map `routes` di dekat baris 143:

```dart
    'GET host/properties/{id}': 'GET_host_properties_id',
    'DELETE host/properties/{id}': 'DELETE_host_properties_id',
```

**4.6** Buat fixture **N-5** dan **N-6** (isi lengkap di §5.5).

**Cek tahap 4:**

```bash
# 1. login sebagai host, ambil token
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"host@example.com","password":"password"}' | jq -r '.data.token')

# 2. draft harus bisa dibaca pemiliknya
curl -s http://127.0.0.1:8000/api/v1/host/properties/1 \
  -H "Authorization: Bearer $TOKEN" | jq '.status, .data.status, (.data.other_keys // (.data|keys|length))'
```

Harus `true`, status apa pun (termasuk `"draft"`), dan jumlah key jauh di atas 20. Lalu pastikan
milik orang lain ditolak — panggil ID properti host lain, harus **403**, bukan 200 atau 404.

---

### Tahap 5 · Bersihkan `PropertyResource` (U-2) + empat perbaikan controller

**5.1 · U-2 tambah `bathrooms`** — [PropertyResource.php L51](laravel/app/Http/Resources/PropertyResource.php#L51),
sisipkan tepat setelah `bedrooms`:

```php
'bathrooms' => $this->bathrooms !== null ? (int) $this->bathrooms : null,
```

Sengaja `null`, bukan `0`: nol kamar mandi dan "belum diisi" adalah dua hal berbeda, dan form Mitra
perlu bisa membedakannya supaya tidak menulis `0` ke properti yang datanya memang belum lengkap.

**5.2 · U-2 `cover` / `cover_image`** — [L58-59](laravel/app/Http/Resources/PropertyResource.php#L58-L59).
Bug halus: `$gallery` sudah diubah jadi URL absolut di baris 16, tapi fallback `$other?->cover`
masih path relatif mentah. Jadi kunci yang sama bisa mengembalikan dua bentuk berbeda tergantung
apakah galeri kosong atau tidak — dan `NetworkImage` di sisi Flutter gagal untuk yang relatif.

```php
// SEBELUM
'cover' => $gallery[0] ?? ($other?->cover ?? null),
'cover_image' => $gallery[0] ?? ($other?->cover_image ?? null),

// SESUDAH — every image key leaves this Resource absolute. The DB stores
// relative paths (D-9); deriving the URL is this class's job, and doing it in
// only one of the two branches is what made the key inconsistent (P1-8).
'cover' => $gallery[0] ?? $this->assetOrNull($other?->cover),
'cover_image' => $gallery[0] ?? $this->assetOrNull($other?->cover_image),
```

Tambahkan helper privat di sebelah `decodeJson()`:

```php
private function assetOrNull(?string $path): ?string
{
    if ($path === null || $path === '') {
        return null;
    }

    // Already absolute (legacy rows, and the example.com values still sitting in
    // PropertiesOtherSeeder) — leave them alone rather than double-prefixing.
    if (\preg_match('#^https?://#i', $path) === 1) {
        return $path;
    }

    return asset('storage/' . ltrim($path, '/'));
}
```

**5.3 · U-2 `period_label`** — [L95](laravel/app/Http/Resources/PropertyResource.php#L95). Kolom
`reviews.period_label` **sudah ada** (ditambah oleh
`add_period_label_to_reviews_table`) dan sudah masuk `$fillable`, tapi Resource mengabaikannya dan
menghitung ulang dari `$r->booking?->duration_type`. Karena `reviews.booking` tidak pernah
di-eager-load, tiap review memicu satu query tambahan — N+1 (P1-10).

```php
// SEBELUM
'period_label' => $r->booking?->duration_type ?? '',

// SESUDAH — prefer the stored column; fall back to the booking only when that
// relation was actually eager-loaded, so this never fires a lazy query (P1-10).
'period_label' => $r->period_label
    ?: ($r->relationLoaded('booking') ? ($r->booking?->duration_type ?? '') : ''),
```

**5.4 · U-2 `asked_by`** — [L105](laravel/app/Http/Resources/PropertyResource.php#L105). Sekarang
mengirim ID mentah, jadi UI menampilkan angka. `asked_by` tetap FK (D-8); yang berubah hanya
representasinya:

```php
// SEBELUM
'asked_by' => $q->asked_by,

// SESUDAH — the column stays an integer FK (D-8); the API speaks names.
// Guarded on relationLoaded so an un-eager-loaded caller cannot trigger N+1.
'asked_by' => $q->relationLoaded('asker')
    ? ($q->asker?->name ?? 'Pengguna')
    : 'Pengguna',
```

**5.5 · Tambahan kecil di luar tabel §4.1** — dua relasi di atas hanya berguna kalau dimuat.
`hostShow()` (tahap 4) sudah memuatnya; `show()` belum. Ubah
[show() L213](laravel/app/Http/Controllers/Api/PropertyController.php#L213):

```php
// 'reviews.user', 'questions'  →
'reviews.user', 'reviews.booking', 'questions.asker',
```

**5.6 · U-1c** — [index() L48](laravel/app/Http/Controllers/Api/PropertyController.php#L48).
Daftar publik tidak memuat `other`, jadi `$other` di Resource selalu `null` dan **27 kunci**
terdampak (rincian di P1-2): `type_label` kosong, `specs` kosong, `price_caption` selalu
`'per bulan mulai dari'`, dan tiga kunci waktu check-in hilang sama sekali. Tambahkan `'other'`:

```php
->with(['prices', 'city', 'hotel.roomTypes', 'other'])
```

**5.7 · U-1d** — [store() L442](laravel/app/Http/Controllers/Api/PropertyController.php#L442) dan
[update() L475](laravel/app/Http/Controllers/Api/PropertyController.php#L475). `rating` dan
`review_count` dibungkus `$this->when(isset(...))`
([L66-67](laravel/app/Http/Resources/PropertyResource.php#L66-L67)) — kalau agregatnya tidak ada,
Laravel **menghapus kuncinya**, bukan mengisi `null`. Jadi respons `POST`/`PUT` punya bentuk yang
berbeda dari `GET`, dan `Property.fromJson` di Flutter membaca kunci yang tidak ada (P1-3).

```php
// store()
new PropertyResource(
    $property->load(['prices', 'city', 'other'])
        ->loadCount('reviews')
        ->loadAvg('reviews', 'rating')
),

// update()
new PropertyResource(
    $property->fresh()->load(['prices', 'city', 'other'])
        ->loadCount('reviews')
        ->loadAvg('reviews', 'rating')
),
```

**5.8 · U-1f + U-1g** — [pricing() L241-243](laravel/app/Http/Controllers/Api/PropertyController.php#L241-L243):

```php
// SEBELUM
'thumbnail' => $property->cover ?? $property->gallery[0] ?? null,
'bathrooms' => (int) ($property->other?->bathrooms ?? 0),

// SESUDAH — `properties` has no `cover` column, so the first operand was always
// null; the second returned a relative path while every other endpoint returns
// an absolute URL (P1-8). `bathrooms` now lives on `properties` (D-5), and
// `properties_other` never had the column at all — the old expression could only
// ever evaluate to 0 (P1-5).
'thumbnail' => $this->galleryThumbnail($property),
'bathrooms' => (int) ($property->bathrooms ?? 0),
```

Helper privat di controller:

```php
private function galleryThumbnail(Property $property): ?string
{
    $gallery = $property->gallery ?? [];
    if (\is_string($gallery)) {
        $gallery = json_decode($gallery, true) ?: [];
    }

    $first = \is_array($gallery) ? ($gallery[0] ?? null) : null;

    return \is_string($first) && $first !== ''
        ? asset('storage/' . ltrim($first, '/'))
        : null;
}
```

**Cek tahap 5:**

```bash
curl -s http://127.0.0.1:8000/api/v1/properties | jq '.data[0] | {type_label, specs: (.specs|length), price_caption}'
curl -s http://127.0.0.1:8000/api/v1/properties/1 | jq '.data | {cover, bathrooms, q: .questions[0].asked_by, p: .reviews[0].period_label}'
curl -s http://127.0.0.1:8000/api/v1/properties/1/pricing | jq '.data | {thumbnail, bathrooms}'
```

- `type_label` **tidak** kosong pada daftar (bukti U-1c jalan).
- `cover` dan `thumbnail` diawali `http://`.
- `asked_by` berupa **nama** (atau `"Pengguna"`), bukan angka.
- `period_label` bukan string kosong.

Aktifkan juga log query sesaat untuk memastikan N+1 hilang:

```bash
php artisan tinker --execute="
DB::enableQueryLog();
\$p = App\Models\Property::with(['prices','city','other','reviews.user','reviews.booking','questions.asker'])->find(1);
(new App\Http\Resources\PropertyResource(\$p))->toArray(request());
echo count(DB::getQueryLog()) . ' query' . PHP_EOL;
"
```

Jumlah query harus **tetap** meski jumlah review bertambah — bukan naik satu per review.

---

### Tahap 6 · Normalisasi slug fasilitas (D-1, P1-7)

⚠️ Tahap ini menulis ulang kolom `facilities` untuk **semua** properti. Jalankan hanya setelah cek
tahap 2 bersih — normalisasi membaca array, dan pada baris yang masih ber-escape ganda ia akan
melihat string lalu melewatinya diam-diam.

**6.1 · U-12** — daftarkan `FacilitySeeder` (N-3) di
[DatabaseSeeder.php](laravel/database/seeders/DatabaseSeeder.php), pada blok
"Base / no FK dependencies", **sebelum** `PropertySeeder`. Lalu:

```bash
php artisan db:seed --class=Database\\Seeders\\FacilitySeeder
```

**6.2 · Inventaris sebelum membuang.** N-7 **membuang** nilai yang tidak dikenal. Lihat dulu apa
saja yang akan hilang, supaya keputusannya sadar dan bukan kejutan:

```bash
php artisan tinker --execute="
\$known = ['wifi','ac','kitchen','parking','swimming_pool','tv','washing_machine','security','elevator','gym','water_heater','access_card','breakfast'];
\$seen = [];
foreach (App\Models\Property::all() as \$p) {
    foreach ((array) \$p->facilities as \$f) {
        \$k = preg_replace('/[\s-]+/', '_', strtolower(trim((string) \$f)));
        if (! in_array(\$k, \$known, true)) { \$seen[\$k] = (\$seen[\$k] ?? 0) + 1; }
    }
}
print_r(\$seen);
"
```

Kalau muncul nilai yang **memang fasilitas nyata** (misal `'balcony'`), tambahkan ke tiga tempat
sekaligus sebelum lanjut: `FacilitySeeder` (N-3), peta `$aliases`/`$canonical` di N-7, dan
`kPropertyFacilities` (N-4). Ketiganya harus identik — itu satu-satunya alasan D-1 bisa dipegang.

**6.3** Jalankan N-7:

```bash
php artisan migrate
```

**6.4 · Soal cabang `whereHas('masterFacilities')`.** Setelah tahap 2 + 6, separuh filter yang
berbasis JSONB (`orWhere('facilities','like','%"wifi"%')` pada
[L149](laravel/app/Http/Controllers/Api/PropertyController.php#L149)) **hidup**. Cabang pivot pada
[L147-148](laravel/app/Http/Controllers/Api/PropertyController.php#L147-L148) tetap tidak
menghasilkan apa pun karena tabel pivot `facility_property` memang tidak diisi — dan menurut D-1
kita **tidak** memindahkan data ke sana.

**Keputusan: biarkan cabang itu, jangan dihapus.** Alasannya bukan sentimental: ia `orWhere`, jadi
tidak mempersempit hasil, dan begitu ada modul admin yang mulai menulis pivot, filter langsung ikut
bekerja tanpa ubah kode. Tambahkan komentar supaya tidak dibaca sebagai bug:

```php
$fq->whereHas('masterFacilities', function (Builder $mfq) use ($slug) {
        // The pivot is not populated today — `properties.facilities` (JSONB) is the
        // source of truth (D-1). Kept as an OR branch so that any future writer of
        // `facility_property` is picked up without touching this filter.
        $mfq->where('slug', $slug);
    })
    ->orWhere('facilities', 'like', "%\"{$slug}\"%");
```

**Cek tahap 6:**

```bash
php artisan tinker --execute="
\$bad = 0;
foreach (App\Models\Property::all() as \$p) {
    foreach ((array) \$p->facilities as \$f) {
        if (\$f !== strtolower(\$f) || str_contains(\$f, ' ')) { \$bad++; echo \$p->id . ': ' . \$f . PHP_EOL; }
    }
}
echo \$bad === 0 ? 'SEMUA SLUG OK' : \$bad . ' nilai belum slug';
"
echo '---'
curl -s 'http://127.0.0.1:8000/api/v1/properties?facilities=wifi' | jq '.meta.total'
curl -s 'http://127.0.0.1:8000/api/v1/properties?facilities=wifi,ac' | jq '.meta.total'
```

Filter `wifi` harus mengembalikan angka **> 0** — ini pertama kalinya filter itu benar-benar bekerja.
Dan `wifi,ac` harus ≤ hasil `wifi` (AND, bukan OR, karena tiap fasilitas jadi satu `where` terpisah).

---

### Tahap 7 · Form Mitra Flutter (P0-1, P0-3, P0-5, P1-1, P1-12, P2-8)

⚠️ Tahap dengan perubahan perilaku paling terasa bagi pengguna. Kerjakan dalam satu rilis bersama
langkah 3.3.

**7.1 · N-4** — buat `flutter/lib/screens/mitra/property_form_payload.dart` (kode lengkap di §5.4).

**7.2 · U-16** — [property.dart](flutter/lib/models/property.dart), tambahkan `bathrooms` di
`fromJson` (dan sebagai field). Cukup `int?` — bedakan "nol" dari "belum diisi", sejalan dengan 5.1:

```dart
bathrooms: (json['bathrooms'] as num?)?.toInt(),
```

**7.3 · U-13g fasilitas jadi slug** — [L49-52](flutter/lib/screens/mitra/property_form_screen.dart#L49-L52).
`_allFacilities` sekarang daftar Title Case dan disimpan apa adanya. Ganti sumbernya ke
`kPropertyFacilities`, tampilkan `value`, kirim `key`:

```dart
// SEBELUM: _allFacilities = ['WiFi', 'AC', 'Dapur', ...] — the label WAS the payload
// SESUDAH:
final Set<String> _facilities = <String>{};   // holds slugs

// in build(), for each chip:
...kPropertyFacilities.entries.map((e) => FilterChip(
      label: Text(e.value),                       // label: display only
      selected: _facilities.contains(e.key),      // value:  the slug
      onSelected: (on) => setState(() =>
          on ? _facilities.add(e.key) : _facilities.remove(e.key)),
    ))
```

Saat memuat data lama, lewatkan dulu melalui normalisasi supaya baris Title Case tetap mencentang
chip yang benar:

```dart
_facilities
  ..clear()
  ..addAll(canonicalFacilities(initial['facilities'] as List? ?? const []));
```

`has_breakfast` ikut otomatis — `buildPropertyPayload` menurunkannya dari
`slugs.contains('breakfast')`, jadi tidak ada lagi perbandingan `contains('Breakfast')` yang
bergantung pada kapitalisasi.

**7.4 · U-13a hapus `_propertyToMap`** — ini inti P0-1. `initState`
[L125](flutter/lib/screens/mitra/property_form_screen.dart#L125) memanggil `_propertyToMap`, yang
hanya bisa menyusun **22 kunci** dari model `Property`; 16 field `properties_other` tidak ada di
sana, jadi `_loadInitialData` tidak pernah mengisinya, dan `_submit` mengirim nilai kosong
menimpa data yang sudah tersimpan.

**Hapus** `_propertyToMap` seluruhnya ([L815-846](flutter/lib/screens/mitra/property_form_screen.dart#L815-L846))
dan ambil map lengkap dari endpoint baru:

```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 4, vsync: this);
  _loadCities();
  _loadDraft();

  final id = widget.initialData?['id'] as int? ?? widget.property?.id;
  if (widget.initialData != null) {
    _loadingInitial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData(widget.initialData!));
  } else if (id != null) {
    // Edit mode: fetch the full record. Never rebuild it from the `Property`
    // model — that model carries a fraction of the fields the form writes, and
    // reconstructing from it is exactly how 16 `properties_other` fields got
    // wiped on every save (P0-1, D-3).
    _loadingInitial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRemoteDetail(id));
  }
  _tabController.addListener(_onTabChanged);
}

Future<void> _loadRemoteDetail(int id) async {
  try {
    final map = await _service.propertyDetail(id);
    if (!mounted) return;
    await _loadInitialData(map);
  } catch (e) {
    if (!mounted) return;
    setState(() => _loadingInitial = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat data properti: $e'), backgroundColor: Colors.red),
    );
    // Bail out rather than open an empty form over a real property — saving it
    // would overwrite good data with blanks.
    Navigator.pop(context);
  }
}
```

> `Navigator.pop` pada kegagalan itu **disengaja**. Membuka form kosong di atas properti nyata lebih
> berbahaya daripada tidak membukanya: tombol simpan akan menimpa data bagus dengan kosong. Ini juga
> alasan `Property.toJson()` **tidak** dibuat — menyediakannya justru mengundang pola lama kembali.

**7.5 · U-13b hapus cabang mati** — [L687-691](flutter/lib/screens/mitra/property_form_screen.dart#L687-L691).
Syaratnya `widget.initialData != null`, padahal `router.dart` selalu memanggil dengan `property:`,
jadi cabang pertama tidak pernah jalan dan foto milik properti tersimpan dikirim ke endpoint *temp*
yang memang menolaknya dengan 422 (P0-3). Ganti syaratnya jadi berbasis ID:

```dart
final id = widget.initialData?['id'] as int? ?? widget.property?.id;
try {
  if (id != null) {
    await _service.deleteGallery(id, relative);      // saved property
  } else {
    await _service.deleteGalleryTemp(relative);      // not persisted yet
  }
} catch (e) { … }
```

**7.6 · U-13c/d/e/f payload** — ganti seluruh blok
[L331-381](flutter/lib/screens/mitra/property_form_screen.dart#L331-L381) dengan pemanggilan
`buildPropertyPayload` (§5.4). Yang hilang dari payload, dan alasannya:

| Field | Aksi | Alasan |
|---|---|---|
| `if (prices.isNotEmpty)` di depan `other` | **hapus syaratnya** | draft tanpa harga kehilangan seluruh detail (P0-5) |
| `star_rating`, `check_in_time`, `check_out_time` | **hapus** | hardcode `4` / `'14:00:00'` / `'12:00:00'`; milik server (P1-1, D-7) |
| `review_summary` | **hapus** | dikirim ter-nol → menimpa ringkasan review nyata (P1-1, D-7) |
| `map_preview` | **hapus** | URL turunan, bukan data (D-9) |
| `price_from` | **hapus** | kolom mati (D-11) |
| `cover`, `cover_image` | **relatifkan** | tadinya absolut, tidak konsisten dengan `gallery` (P1-8, D-9) |

**7.7 · U-13f jaga status** — [L340](flutter/lib/screens/mitra/property_form_screen.dart#L340).
`_status` diisi dari data awal ([L238](flutter/lib/screens/mitra/property_form_screen.dart#L238))
tapi **tidak pernah dibaca**. `_submit({String status = 'active'})` selalu menang, jadi properti
`inactive` / `maintenance` / `fully_booked` berubah jadi `active` begitu host menekan simpan —
tanpa niat dan tanpa peringatan (P1-12).

```dart
/// Status to persist for this save.
///
/// The two buttons can only express `draft` (save draft) and `active`
/// (publish). Every other state — `inactive`, `maintenance`, `fully_booked` —
/// is set elsewhere and must survive an unrelated edit, so an `active` request
/// never downgrades a property that is deliberately in another state (D-10).
String _resolveStatus(String requested) {
  const buttonStates = {'draft', 'active'};
  if (requested == 'draft') return 'draft';
  if (_status.isNotEmpty && !buttonStates.contains(_status)) return _status;
  return 'active';
}
```

**7.8 · U-13g `description_extra`** — [L325-329](flutter/lib/screens/mitra/property_form_screen.dart#L325-L329).
Sekarang direkonstruksi tiap simpan dari `intro` + `description_extra_heading`, jadi paragraf
tambahan apa pun di luar dua field itu hilang (P2-8). Muat nilainya di `_loadInitialData`, simpan di
state, dan kirim kembali; hanya tambahkan `intro`/heading kalau memang belum ada di dalamnya.

**Cek tahap 7** (manual, di app Mitra):

1. `flutter run --dart-define=DUMMY_API=true` → buka Mitra → Properti → **Edit**. Form harus terisi
   **termasuk** tab detail (spesifikasi, fasilitas kamar, catatan check-in, tempat sekitar). Sebelum
   perbaikan, keempatnya kosong.
2. Jalankan lawan backend nyata. Edit **hanya nama**, simpan, lalu:

   ```bash
   php artisan tinker --execute="print_r(App\Models\PropertyOther::where('property_id',1)->first()->only(['specs','nearby','check_in_notes','unit_detail']));"
   ```

   Isinya harus **sama seperti sebelum** disimpan. Ini pembuktian langsung P0-1.
3. Properti baru, isi tab detail, **jangan isi harga**, tekan *Simpan Draft*. Baris
   `properties_other` harus tetap terbentuk dengan isi lengkap (P0-5).
4. Set satu properti ke `maintenance` lewat admin, lalu edit-dan-simpan dari app. Statusnya harus
   tetap `maintenance` (P1-12).
5. Di mode edit, hapus satu foto yang sudah tersimpan. Harus berhasil — bukan
   "Gagal menghapus gambar" (P0-3).
6. `flutter analyze` harus bersih.

---

### Tahap 8 · Livewire admin (U-8, P1-4, P2-1)

[WizardForm.php](laravel/app/Livewire/Properties/WizardForm.php) — komponen ini tidak punya satu pun
`authorize()`. Grup admin di [web.php:41](laravel/routes/web.php#L41) memakai `role:admin|host`,
jadi **host mana pun** ikut masuk; dan `/livewire/update` tidak memutar ulang middleware `role`
Spatie, jadi pertahanan di route tidak berlaku untuk aksi Livewire. Properti publik komponen bisa
diubah dari sisi klien.

**8.1** Gate di dua pintu masuk:

```php
public function edit(int $propertyId): void
{
    $property = Property::findOrFail($propertyId);

    // /livewire/update does not replay Spatie's `role` middleware, so the route
    // guard in web.php does not protect this method. An admin may edit anything;
    // a host only their own property.
    abort_unless(
        auth()->user()->hasRole('admin') || $property->host_id === auth()->id(),
        403
    );

    // …
}

public function save(): void
{
    // …same check before writing…
}
```

**8.2** `host_id` tidak boleh berasal dari input klien. Di `save()`, untuk pembuatan baru, set dari
`auth()->id()` (atau biarkan admin memilih lewat select yang divalidasi `exists:users,id`) — jangan
dari properti publik komponen yang bisa di-set klien.

**8.3** Default aman ([L30](laravel/app/Livewire/Properties/WizardForm.php#L30) dan
[L35](laravel/app/Livewire/Properties/WizardForm.php#L35)):

```php
public string $status = 'draft';   // was 'active' — publishing must be deliberate
public array $facilities = [];     // was a Title-Case list; now slugs (D-1)
```

**8.4** Fasilitas pakai slug, bukan Title Case
([L35](laravel/app/Livewire/Properties/WizardForm.php#L35),
[L118](laravel/app/Livewire/Properties/WizardForm.php#L118),
[L169](laravel/app/Livewire/Properties/WizardForm.php#L169)). Ambil pilihannya dari tabel master
yang baru diisi, jadi hanya ada satu daftar:

```php
// Options for the view. The master table is the label source; the slug is what
// gets stored in `properties.facilities` (D-1).
public function getFacilityOptionsProperty(): array
{
    return Facility::orderBy('name')->pluck('name', 'slug')->all();
}
```

**8.5** Aturan validasi ([L57](laravel/app/Livewire/Properties/WizardForm.php#L57)) belum memuat
`hotel` pada `property_type`, padahal API sudah. Selaraskan, dan validasi slug fasilitasnya:

```php
'property_type' => ['required', 'in:apartment,house,villa,hotel_residence,guest_house,kost,hotel'],
'facilities'    => ['array'],
'facilities.*'  => ['string', 'exists:facilities,slug'],
```

**Cek tahap 8:** login sebagai host A di admin panel, buka daftar properti, coba `edit()` properti
milik host B — harus **403**. Lalu simpan properti baru dari wizard: `status` awalnya harus `draft`,
dan `facilities` di DB harus berisi slug.

---

### Tahap 9 · Seeder & fixture (U-9, U-10, U-11, U-17, U-18)

Tahap terakhir dan paling aman — tidak ada logika yang berubah, hanya data contoh. Tapi jangan
dilewati: seeder yang salah adalah alasan sebagian temuan di §1 bertahan lama tanpa terlihat.

**9.1 · U-9** — [PropertySeeder.php](laravel/database/seeders/PropertySeeder.php). Empat properti
saat ini semuanya Jakarta, tanpa `booking_mode`, tanpa `cancellation_policy`, tanpa `bathrooms`.
Tambahkan ketiganya, dan sebar kotanya — filter `city_id` tidak pernah benar-benar teruji selama
semua data berada di satu kota. Slug fasilitas di L36/55/74/93 sudah lowercase; cocokkan dengan
daftar D-1 (tambahkan `gym`, `water_heater`, `access_card` bila relevan).

**9.2 · U-10** — [PropertiesOtherSeeder.php](laravel/database/seeders/PropertiesOtherSeeder.php).
File ini **sudah ada dan sudah terdaftar** — jadi ini update, bukan file baru. Tiga masalah:

- Hanya menyentuh satu properti, dicari lewat nama:
  `Property::where('name', 'Sunset Beach Apartment')->first()`. Tiga properti lain tidak punya baris
  `properties_other` sama sekali → `$other` null → 27 kunci terdampak (P1-2).
- `province => 'Bali'` dan `area_label => 'Bali'` untuk properti yang alamatnya Jakarta.
- Semua URL gambar `https://example.com/...` — absolut dan tidak ada, padahal D-9 menetapkan path
  relatif.

Ubah jadi loop semua properti `booking_mode = 'unit'`, turunkan `province`/`area_label` dari relasi
`city`, pakai path relatif `properties/gallery/…`, dan **jangan** menulis `rating`, `review_count`,
atau `price_from` (D-11 — ketiganya sudah tidak fillable setelah U-6, jadi menuliskannya hanya
akan diabaikan diam-diam).

**9.3 · U-11** — [PropertyQuestionSeeder.php](laravel/database/seeders/PropertyQuestionSeeder.php).
`'asked_by' => null` membuat `asked_by` di API selalu jatuh ke fallback, jadi perbaikan 5.4 tidak
pernah terlihat. Isi dengan ID user nyata:

```php
'asked_by' => User::where('email', '!=', $property->host?->email)->value('id'),
```

**9.4 · U-17** — [unit_pricing.dart](flutter/lib/models/unit_pricing.dart). Dua ketidaksesuaian
kecil dengan backend: `InclusionList.fromJson` mengabaikan `collapsed_rows` yang dikirim
[pricing() L253](laravel/app/Http/Controllers/Api/PropertyController.php#L253), dan
`SpecialPriceTier.minNights` membaca `json['min_nights'] as int?` — pecah kalau JSON mengirim
`5.0`. Pakai `(json['min_nights'] as num?)?.toInt()`.

Bagian ketiga P2-5 — `AddOn` membaca `json['selected']` sementara sebagian dokumen lama menyebut
`is_selected` — **tidak perlu diubah**. `add_ons` selalu `[]` (D-4), jadi tidak ada data yang bisa
menyimpang; dan kalau nanti dibangun, `selected` adalah nama yang dipakai (D-4 memutuskan itu, dan
kode Dart-nya sudah sesuai). Cukup jangan diubah ke `is_selected`.

**9.5 · U-18** — fixture properti di `flutter/assets/json/`. Selaraskan dengan D-1 dan tahap 5:
`facilities` berisi slug, ada kunci `bathrooms`, dan URL `example.com` diganti. Minimal
[GET_properties_id.json](flutter/assets/json/GET_properties_id.json),
`GET_properties.json`, `GET_host_properties.json`, `POST_host_properties.json`,
`PUT_host_properties_id.json`.

**Cek tahap 9:**

```bash
php artisan migrate:fresh --seed
php artisan tinker --execute="
echo 'properties: ' . App\Models\Property::count() . PHP_EOL;
echo 'others: ' . App\Models\PropertyOther::count() . PHP_EOL;
echo 'facilities: ' . App\Models\Facility::count() . PHP_EOL;
echo 'questions tanpa asker: ' . App\Models\PropertyQuestion::whereNull('asked_by')->count() . PHP_EOL;
echo 'kota unik: ' . App\Models\Property::distinct('city_id')->count('city_id') . PHP_EOL;
"
```

Target: `others` **sama dengan** jumlah properti unit (bukan 1), `facilities` = 13,
`questions tanpa asker` = 0, `kota unik` > 1.

---

## §7 · VERIFIKASI & ACCEPTANCE

**Tidak ada test otomatis pada pekerjaan ini** — diminta dilewati. Konsekuensinya harus disadari:
tidak ada jaring pengaman yang menahan regresi di kemudian hari, jadi verifikasi manual di bawah
bukan formalitas, ia satu-satunya bukti. Jalankan **seluruhnya**, bukan sebagian, dan jalankan pada
**PostgreSQL** — bukan SQLite.

### §7.1 Acceptance per temuan

Satu baris per temuan di §1. Kolom "Bukti" adalah hal konkret yang harus dilihat dengan mata; kalau
tidak bisa dilihat, temuan itu **belum** selesai.

| ID | Tahap | Cara membuktikan | Lulus bila |
|---|---|---|---|
| P0-1 | 7 | Edit **hanya nama** properti yang `properties_other`-nya terisi, simpan, bandingkan `specs`/`nearby`/`check_in_notes`/`unit_detail` sebelum & sesudah | keempatnya **identik** |
| P0-2 | 2 | `Property::first()->getRawOriginal('facilities')` | mulai dengan `[` dan tidak ada `\"` |
| P0-3 | 7 | Mode edit → hapus satu foto tersimpan | foto hilang, **tanpa** snackbar merah |
| P0-4 | 4 | `GET host/properties/{id}` untuk properti `draft` milik sendiri | HTTP 200 + `data.status == "draft"` |
| P0-5 | 7 | Properti baru, isi tab detail, **tanpa harga**, Simpan Draft | baris `properties_other` terbentuk & terisi |
| P1-1 | 3, 7 | Kirim `other.star_rating` dari klien | HTTP **422** (`prohibited`) |
| P1-2 | 5 | `GET properties` → item pertama | `type_label` tidak kosong, `specs` tidak kosong |
| P1-3 | 5 | Bandingkan `keys` respons `POST host/properties` vs `GET properties/{id}` | keduanya punya `rating` & `review_count` |
| P1-4 | 8 | Host A memanggil `edit()` properti host B | **403** |
| P1-5 | 1, 5 | `GET properties/{id}/pricing` setelah `bathrooms` di-set 2 | `bathrooms == 2`, bukan `0` |
| P1-6 | 3 | Kirim dua baris `prices` dengan `price_type: "daily"` | **422**, bukan 500 |
| P1-7 | 6 | `GET properties?facilities=wifi` | `meta.total > 0` |
| P1-8 | 5, 7 | `cover`, `cover_image`, `gallery[]`, `thumbnail` pada satu respons | **semua** absolut (`http…`) |
| P1-9 | 1 | `GET properties/{id}` pada properti yang review-nya punya foto | `reviews[0].photos` array, bukan string |
| P1-10 | 5 | `DB::getQueryLog()` saat merender Resource dengan 10 review | jumlah query tidak naik seiring review |
| P1-11 | 5, 9 | `GET properties/{id}` → `questions[0].asked_by` | berupa nama, bukan angka |
| P1-12 | 7 | Set properti `maintenance` via admin, edit-simpan dari app | status tetap `maintenance` |
| P2-1 | 8 | Simpan properti baru dari wizard admin | `status == 'draft'`, `facilities` berisi slug |
| P2-2 | — | **tidak dikerjakan** — lihat §7.4 | — |
| P2-3 | 1, 3 | Kirim `other.rating` | **422** (`prohibited`) |
| P2-4 | 9 | `migrate:fresh --seed` lalu hitung `PropertyOther::count()` | sama dengan jumlah properti unit |
| P2-5 | 9 | `GET properties/{id}/pricing` diparse `UnitPricing` | `collapsed_rows` terbaca (5), tidak crash pada `min_nights: 5.0` |
| P2-6 | 4 | `DELETE host/properties/{id}` milik sendiri, lalu milik orang lain | 200 lalu **403** |
| P2-7 | 7 | Cari `_propertyToMap` di repo | **nol hasil** (D-3 — bukan dengan menambah `toJson`) |
| P2-8 | 7 | Isi `description_extra` 3 paragraf, simpan, muat ulang | ketiganya masih ada |
| P2-9 | 5 | `GET properties/{id}/pricing` → `thumbnail` | absolut & gambarnya benar-benar terbuka |

### §7.2 Smoke test end-to-end (manual, ±10 menit)

Satu alur utuh sebagai penutup. Kalau ini lulus, sembilan tahap benar-benar menyatu.

1. `php artisan migrate:fresh --seed` — harus selesai tanpa error. Ini sekaligus membuktikan N-1,
   N-2, N-7, dan `FacilitySeeder` bisa jalan dari nol.
2. `composer run dev` + `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1`.
3. Login sebagai host → **Mitra → Properti → Tambah**.
4. Isi tab 1 & 2 saja (nama, tipe, alamat, kota, kapasitas, kamar, **kamar mandi**, fasilitas,
   1 foto). **Jangan** isi harga. Tekan **Simpan Draft**.
5. Buka kembali properti itu dari daftar → semua yang diisi harus muncul, termasuk fasilitas yang
   tercentang dan foto.
6. Lengkapi tab 3 (harga 4 durasi) dan tab 4 (spesifikasi, tempat sekitar, catatan check-in). Tekan
   **Publikasikan**.
7. Buka properti yang sama di **admin panel**. Fasilitasnya harus terbaca sebagai daftar tercentang
   — bukan satu blok teks berisi `["wifi","ac"]`. Ini bukti P0-2 tuntas hulu-hilir.
8. Dari app konsumen, cari dengan filter fasilitas `WiFi`. Properti itu harus muncul.
9. Kembali ke Mitra, edit **hanya harga harian**, simpan. Lalu periksa tab 4 — spesifikasi dan
   tempat sekitar harus **masih utuh**.
10. Hapus satu foto, lalu hapus propertinya. Keduanya harus berhasil.

### §7.3 Yang **tidak** boleh dianggap bug setelah perbaikan

Daftar ini penting justru karena kelihatan seperti temuan baru. Lima hal berikut **benar** apa
adanya, dan "memperbaikinya" akan melawan keputusan di §3.5:

| Yang terlihat | Kenapa itu benar |
|---|---|
| `price_original` selalu `null` untuk properti unit | Harga coret hanya ada di jalur hotel (`hotel.price_original`). Mode unit tidak punya sumbernya — **di luar cakupan** (D-6) |
| `special_prices`, `add_ons`, `payment_plans` selalu `[]` | Belum ada tabelnya dan **tidak dibuat** di pekerjaan ini (D-4). `pricing()` sengaja mengembalikan array kosong, bukan data palsu |
| Kunci `star_rating`, `check_in_time`, `check_out_time` **hilang** dari respons properti unit | `whenLoaded('hotel')` menghasilkan `MissingValue` → Laravel membuang kuncinya. Itu perilaku yang diinginkan, bukan field yang lupa diisi (§5.5 poin 3) |
| Kolom `other.rating`, `other.review_count`, `other.price_from` masih ada di DB | Sengaja tidak di-drop (D-11) — hanya ditutup dari `$fillable` dan validasi. Drop kolom butuh migrasi terpisah dan tidak menyelesaikan apa pun |
| `facility_property` kosong | JSONB adalah sumber kebenaran (D-1). Tabel master hanya untuk label & ikon (D-12) |

### §7.4 Yang sengaja **tidak** dikerjakan

Jujur dicatat supaya tidak dianggap sudah beres:

- **P2-2** — `WizardForm` hanya bisa mengelola satu baris harga dan mengunci `booking_mode = 'unit'`
  ([L160](laravel/app/Livewire/Properties/WizardForm.php#L160),
  [L183-192](laravel/app/Livewire/Properties/WizardForm.php#L183-L192)). Memperbaikinya berarti
  merombak wizard admin menjadi repeater 4-durasi — pekerjaan tersendiri, bukan bagian dari
  perbaikan jalur host. Tahap 8 hanya menutup lubang keamanan dan default-nya.
- **Test otomatis** — diminta dilewati. Kalau nanti dibuat, tiga yang paling berbayar: `hostShow()`
  mengizinkan pemilik & menolak non-pemilik, `facilities` bulat-balik tanpa double-encode, dan
  update-parsial tidak mengosongkan `properties_other`. Catatan: suite berjalan di **SQLite
  in-memory**, yang tidak menegakkan CHECK constraint — jadi bug ENUM `property_type` tetap hanya
  akan muncul di PostgreSQL, dan test hijau bukan jaminan untuk hal itu.
- **Drop kolom mati** — lihat §7.3.
- **`Property.toJson()`** — sengaja tidak dibuat (D-3). Menyediakannya justru mengundang pola
  `_propertyToMap` kembali, dan pola itulah akar P0-1.

### §7.5 Definition of done

Selesai berarti **kesembilan** baris ini benar, sekaligus:

- [ ] `php artisan migrate:fresh --seed` bersih di PostgreSQL
- [ ] 26 baris §7.1 terbukti (kecuali P2-2 yang eksplisit di luar cakupan)
- [ ] Smoke test §7.2 lulus dari langkah 1 sampai 10
- [ ] `./vendor/bin/pint` bersih
- [ ] `flutter analyze` bersih
- [ ] Tidak ada `json_encode($data['facilities'])` tersisa di repo
- [ ] Tidak ada `_propertyToMap` tersisa di repo
- [ ] `route:list --path=host/properties` menampilkan `gallery` di atas `{property}`
- [ ] `.env` tidak ikut ter-commit

Tiga di antaranya bisa dicek sekaligus:

```bash
grep -rn "json_encode(\$data\['facilities'\])" laravel/app || echo "OK: bersih"
grep -rn "_propertyToMap" flutter/lib || echo "OK: bersih"
git check-ignore -v laravel/.env || echo "PERINGATAN: .env tidak ter-gitignore"
```

---

## §8 · LAMPIRAN

### §8.1 Inventaris fixture properti

Fixture di [flutter/assets/json/](flutter/assets/json/) yang menyentuh domain properti. Kolom
"Sentuh?" menandai mana yang perlu diubah oleh U-18 / N-5 / N-6.

| Fixture | Route | Sentuh? |
|---|---|---|
| `GET_properties.json` | `GET properties` | ✅ slug + `bathrooms` |
| `GET_properties_id.json` | `GET properties/{id}` | ✅ slug + `bathrooms` + URL |
| `GET_properties_id_pricing.json` | `GET properties/{id}/pricing` | ✅ `bathrooms`, `collapsed_rows` |
| `GET_properties_id_reviews.json` | `GET properties/{id}/reviews` | ⬜ |
| `GET_properties_id_availability.json` | `GET properties/{id}/availability` | ⬜ |
| `GET_properties_id_host.json` | `GET properties/{id}/host` | ⬜ — **info pemilik**, bukan properti milik host |
| `GET_host_properties.json` | `GET host/properties` | ✅ slug + `bathrooms` |
| `GET_host_properties_id.json` | `GET host/properties/{id}` | 🆕 **N-5** |
| `POST_host_properties.json` | `POST host/properties` | ✅ tambah `rating`/`review_count` (U-1d) |
| `PUT_host_properties_id.json` | `PUT host/properties/{id}` | ✅ tambah `rating`/`review_count` (U-1d) |
| `DELETE_host_properties_id.json` | `DELETE host/properties/{id}` | 🆕 **N-6** |
| `POST_host_properties_gallery_upload.json` | `POST host/properties/gallery/upload` | ⬜ |
| `DELETE_host_properties_gallery.json` | `DELETE host/properties/gallery` | ⬜ |
| `DELETE_host_properties_id_gallery.json` | `DELETE host/properties/{id}/gallery` | ⬜ |
| `property_dummy.json` | — **tidak dirujuk kode mana pun** | ⚠️ lihat catatan |
| `POST_bookings_property.json` | `POST booking-property` ([dummy_api_client.dart:102](flutter/lib/services/dummy_api_client.dart#L102)) | ⬜ — namanya mengandung "property" tapi ini **domain booking**; jangan ikut diubah U-18 |

> `property_dummy.json` tidak muncul di map `routes` `DummyApiClient` dan tidak dirujuk dari
> `flutter/lib/` sama sekali — isinya duplikat lama dari `GET_properties_id.json`. Pilihannya dua:
> **hapus**, atau samakan dengan U-18. Jangan dibiarkan setengah jalan: fixture usang yang masih
> terbaca manusia adalah cara ejaan lama berlanjut hidup.

**Pemetaan konkret untuk U-18.** Nilai yang benar-benar ada di ketiga fixture sekarang adalah
`"WiFi"`, `"Pool"`, `"Gym"`, `"Parking"`. Gantikan tepat seperti ini:

| Sekarang | Jadi |
|---|---|
| `"WiFi"` | `"wifi"` |
| `"Pool"` | `"swimming_pool"` ← **bukan** `"pool"`, lihat catatan P1-7 |
| `"Gym"` | `"gym"` |
| `"Parking"` | `"parking"` |


> Jebakan nama: `GET_properties_id_host.json` **bukan** properti milik host. Itu respons
> `properties/{id}/host` — profil pemiliknya (nama, telepon, `total_properties`), dilayani
> [host()](laravel/app/Http/Controllers/Api/PropertyController.php#L400). Yang berhubungan dengan
> panel Mitra selalu berawalan `*_host_properties*`.

### §8.2 Rujukan cepat

| Butuh | Buka |
|---|---|
| Bentuk respons properti (satu-satunya sumber) | [PropertyResource.php](laravel/app/Http/Resources/PropertyResource.php) |
| Aturan validasi host | [validateProperty()](laravel/app/Http/Controllers/Api/PropertyController.php#L480) |
| Daftar route host | [api_mobile.php:134-141](laravel/routes/api_mobile.php#L134-L141) |
| Kolom `properties` | `create_properties_table` + `update_properties_for_hotels` + `add_city_id_…` + `add_cancellation_policy_…` |
| Kolom `properties_other` (34) | `create_properties_other_table` |
| Form Mitra | [property_form_screen.dart](flutter/lib/screens/mitra/property_form_screen.dart) |
| Service host Flutter | [host_service.dart](flutter/lib/services/host_service.dart) |
| Peta fixture dummy | [dummy_api_client.dart:141-147](flutter/lib/services/dummy_api_client.dart#L141-L147) |
| Wizard admin | [WizardForm.php](laravel/app/Livewire/Properties/WizardForm.php) |
| Amplop API | [ApiResponse.php](laravel/app/Support/ApiResponse.php) · [api_response.dart](flutter/lib/models/api_response.dart) |

### §8.3 Ringkasan angka

| | Jumlah |
|---|---|
| Temuan terverifikasi | **26** (5 P0 · 12 P1 · 9 P2) |
| Koreksi atas dokumen lama | **9** (K-1 … K-9) |
| Keputusan yang mengikat | **12** (D-1 … D-12) |
| File yang perlu di-update | **18** (U-1 … U-18) |
| File yang perlu dibuat baru | **7** (N-1 … N-7) |
| Migration baru | **3** — 1 skema, 2 backfill |
| Model baru | **0** |
| Tahap eksekusi | **9** tahap kerja (+ tahap 0 prasyarat) |
| Test baru | **0** — diminta dilewati (§7.4) |




