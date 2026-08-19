# Kesimpulan: Perbandingan Modeling Database Hotels & Properties

> **Dokumen ini** membandingkan dua pendekatan modeling database yang telah di-generate:
> - **Generated_1**: Fully normalized, tanpa polymorphic
> - **Generate_2**: Streamlined dengan polymorphic (`media` + `model_has_facilities`)
>
> **Sumber:** `docs/perbaikan/generated_1/`, `docs/perbaikan/generate_2/`, `docs/perbaikan/data_ramping.md`

---

## 1. Ringkasan Perbandingan

| Aspek | Generated_1 (Fully Normalized) | Generate_2 (Polymorphic) |
|-------|-------------------------------|--------------------------|
| **Jumlah Migration** | 34 | 29 |
| **Jumlah Model** | 34 | 34 |
| **Jumlah Seeder** | 30 | 33 |
| **Media** | `property_media`, `room_type_media` (2 tabel) | 1 tabel `media` (polymorphic) |
| **Fasilitas** | 4 tabel terpisah | 1 master `facilities` + 1 pivot `model_has_facilities` |
| **Relasi** | `HasMany` / `BelongsTo` eksplisit | `MorphMany` / `MorphToMany` |
| **Kekompleksan** | Tinggi (banyak tabel) | Sedang (tabel lebih sedikit) |
| **Fleksibilitas** | Kaku per entity | Fleksibel untuk entity baru |

---

## 2. Kelebihan & Kekurangan Generated_1 (Fully Normalized)

### ✅ Kelebihan

1. **Relasi eksplisit & mudah dipahami**
   - Setiap tabel punya model dan relasi yang jelas (`PropertyMedia`, `RoomTypeMedia`, dll).
   - Tidak perlu memahami konsep polymorphic untuk developer baru.
   - IDE autocompletion lebih akurat.

2. **Query lebih sederhana untuk kasus spesifik**
   - Mengambil media untuk property: `$property->media` → query ke `property_media` saja.
   - Tidak ada filter `model_type` di setiap query.
   - Foreign key constraint lebih langsung.

3. **Validasi & debugging lebih mudah**
   - Error database lebih mudah dilacak karena setiap tabel punya FK yang jelas.
   - Tidak ada masalah dengan `model_type` mismatch.

4. **Performa query untuk entity spesifik**
   - Index per tabel lebih focused.
   - Tidak ada overhead filtering `model_type`.

### ❌ Kekurangan

1. **Duplikasi struktur tabel**
   - `property_media` dan `room_type_media` punya struktur sama (url, caption, sort_order).
   - Jika ada entity baru (misal `hotel_media`), migration baru harus dibuat.

2. **Maintenance lebih berat**
   - 34 migration harus di-maintain.
   - Setiap perubahan schema media harus diterapkan di beberapa tabel.

3. **Fleksibilitas terbatas**
   - Sulit menambahkan entity baru yang butuh media/fasilitas.
   - Perlu buat tabel + model + seeder baru setiap kali ada entity baru.

4. **Kode berulang**
   - Model `PropertyMedia`, `RoomTypeMedia` punya logika yang sama.
   - Relasi di `Property` dan `RoomType` harus ditulis ulang.

---

## 3. Kelebihan & Kekurangan Generate_2 (Polymorphic)

### ✅ Kelebihan

1. **Konsolidasi tabel**
   - 1 tabel `media` untuk semua entity (Property, Hotel, RoomType, dst).
   - 1 pivot `model_has_facilities` untuk semua fasilitas.
   - Hanya 29 migration vs 34.

2. **Fleksibel untuk entity baru**
   - Jika nanti ada `Hotel` butuh media, cukup pakai `Media::create(['model_type' => Hotel::class, ...])`.
   - Tidak perlu migration baru.

3. **DRY principle**
   - Tidak ada duplikasi struktur tabel media/fasilitas.
   - Logic normalisasi di satu tempat.

4. **Maintenance lebih ringan**
   - Perubahan schema media/fasilitas hanya di 1-2 tabel.
   - Model lebih sedikit untuk maintenance.

### ❌ Kekurangan

1. **Query lebih kompleks**
   - Harus filter `model_type` di setiap query: `Media::where('model_type', Property::class)->where('model_id', $id)`.
   - Eloquent `morphMany` menyembunyikan ini, tapi tetap ada overhead.

2. **Risiko data inconsistency**
   - `model_type` bisa salah ketik (`App\Models\Propert` vs `App\Models\Property`).
   - Tidak ada FK constraint karena `model_type` + `model_id` bukan FK biasa.

3. **Learning curve**
   - Developer harus paham polymorphic relationships.
   - Debugging lebih sulit jika ada masalah dengan `morphTo`.

4. **Performansi untuk listing besar**
   - Jika load 100 properties dengan media, query ke `media` akan filter `model_type` 100x.
   - Perlu `with()` yang hati-hati untuk hindari N+1.

---

## 4. Solusi untuk Masalah Teknis

### 4.1 Race Condition

**Masalah:** Pada module hotel/inventory, race condition bisa terjadi saat:
- Dua guest booking kamar yang sama di waktu bersamaan.
- Inventory `booked_count` melebihi `allotment`.

**Solusi:**

```php
// 1. Database-level constraint (PostgreSQL)
ALTER TABLE room_inventories 
ADD CONSTRAINT check_booked_le_allotment 
CHECK (booked_count <= allotment);

// 2. Transaction + Row-level lock
DB::transaction(function () use ($roomType, $dates, $requiredRooms) {
    $inventories = RoomInventory::whereIn('date', $dates)
        ->where('room_type_id', $roomType->id)
        ->lockForUpdate() // ← Row-level lock
        ->get();
    
    foreach ($inventories as $inv) {
        if ($inv->is_closed || ($inv->allotment - $inv->booked_count) < $requiredRooms) {
            throw new \Exception('Kamar tidak tersedia untuk tanggal tersebut.');
        }
    }
    
    // Proceed dengan booking...
});
```

**Generated_1 vs Generate_2:** Tidak ada perbedaan, karena race condition terjadi di `room_inventories` yang sama di kedua approach.

### 4.2 Penyederhanaan Get Data & Saving

**Masalah:**
- Property/Hotel punya 20+ relasi. Controller bisa jadi ribet.
- Saving data harus sync banyak tabel (media, facilities, pricing, dll).

**Solusi:**

```php
// 1. Gunakan API Resource untuk flatten response
class PropertyResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'gallery' => $this->media->pluck('url'), // dari polymorphic
            'facilities' => $this->facilities->pluck('name'), // dari pivot
            'cover' => $this->media->first()?->url,
            // ... flatten lainnya
        ];
    }
}

// 2. Gunakan Service Pattern untuk saving
class PropertyService
{
    public function saveProperty(array $data, Property $property = null): Property
    {
        DB::transaction(function () use ($data, $property) {
            // 1. Save core property
            $prop = $property ?? new Property();
            $prop->fill($data['property']);
            $prop->save();
            
            // 2. Sync media (delete old + insert new)
            $prop->media()->delete();
            foreach ($data['media'] as $media) {
                $prop->media()->create($media);
            }
            
            // 3. Sync facilities
            $prop->facilities()->sync($data['facility_ids']);
            
            // 4. Sync pricing, special_prices, add_ons, dll.
            // ... setiap relasi di-handle di sini
        });
        
        return $prop;
    }
}
```

**Generated_1 vs Generate_2:**
- **Generated_1**: Lebih verbose karena harus handle `PropertyMedia`, `RoomTypeMedia` terpisah.
- **Generate_2**: Lebih ringkas karena 1 method `syncMedia()` bisa dipakai semua entity.

### 4.3 Public, Draft, Validation, Production → Live/Accepted Host Post

**Masalah:**
- Host bisa submit property dalam status `draft`.
- Perlu validasi sebelum publish ke `active`.
- Perlu approval flow untuk production.

**Solusi:**

```php
// 1. State machine di model
class Property extends Model
{
    public function canBePublished(): bool
    {
        return $this->status === 'draft'
            && $this->name !== null
            && $this->address !== null
            && $this->media()->exists()
            && $this->prices()->exists()
            && $this->facilities()->exists();
    }
    
    public function publish(): bool
    {
        if (!$this->canBePublished()) {
            return false;
        }
        
        $this->update(['status' => 'active']);
        // Trigger notification ke admin untuk review
        AdminNotification::create([
            'type' => 'property_pending_approval',
            'property_id' => $this->id,
        ]);
        
        return true;
    }
}

// 2. Validation rules sebelum submit
class PropertyController extends Controller
{
    public function submitForReview(Request $request, Property $property)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string',
            'city_id' => 'required|exists:cities,id',
            'media' => 'required|array|min:1',
            'prices' => 'required|array|min:1',
            'facilities' => 'required|array|min:1',
        ]);
        
        if (!$property->canBePublished()) {
            return response()->json(['message' => 'Property belum lengkap'], 422);
        }
        
        $property->update(['status' => 'pending_review']);
        
        return response()->json(['message' => 'Property submitted for review']);
    }
}

// 3. Approval flow (admin/ops)
class PropertyApprovalController extends Controller
{
    public function approve(Property $property)
    {
        $property->update(['status' => 'active']);
        // Notify host bahwa property sudah live
        $property->host->notify(new PropertyApprovedNotification($property));
        
        return response()->json(['message' => 'Property approved and live']);
    }
    
    public function reject(Property $property, Request $request)
    {
        $property->update(['status' => 'draft']);
        $property->host->notify(new PropertyRejectedNotification($property, $request->reason));
        
        return response()->json(['message' => 'Property rejected']);
    }
}
```

**Generated_1 vs Generate_2:** Sama, karena status disimpan di tabel `properties` yang shared.

---

## 5. Rekomendasi

### 5.1 Kapan Pakai Generated_1 (Fully Normalized)

- **Tim kecil** yang belum familiar dengan polymorphic.
- **Query kompleks** yang sering filter by entity type.
- **Integrasi dengan sistem lain** yang butuh relasi FK eksplisit.
- **Audit trail** yang detail per tabel.

### 5.2 Kapan Pakai Generate_2 (Polymorphic)

- **Tim besar** yang butuh fleksibilitas menambah entity baru.
- **Sistem berkembang cepat** dengan entity type yang sering bertambah.
- **Maintenance lebih penting** daripada query complexity.
- **DRY principle** adalah prioritas.

### 5.3 Hybrid Approach (Rekomendasi untuk Kasus Ini)

Kombinasi keduanya untuk mendapat manfaat maksimal:

```php
// Core entities tetap normalized
class Property extends Model { /* ... */ }
class Hotel extends Model { /* ... */ }
class RoomType extends Model { /* ... */ }

// Media & Facilities pakai polymorphic
class Media extends Model { /* polymorphic */ }
class Facility extends Model { /* master */ }
class ModelHasFacility extends Model { /* polymorphic pivot */ }

// Display fields yang jarang berubah bisa tetap JSONB
// (opsional, untuk performa read-heavy)
class Property extends Model
{
    protected $casts = [
        'specs' => 'array', // ← Tetap JSONB untuk data yang jarang di-query
    ];
}
```

**Alasan hybrid:**
- Media & Facilities memang universal → polymorphic cocok.
- Display fields seperti `specs`, `review_summary` jarang di-filter → JSONB acceptable.
- Core entities (`properties`, `hotels`, `room_types`) tetap normalized untuk query performance.

---

## 6. Kesimpulan Akhir

| Kriteria | Pemenang |
|----------|----------|
| **Kesederhanaan awal** | Generated_1 (lebih mudah dipahami) |
| **Fleksibilitas jangka panjang** | Generate_2 (polymorphic) |
| **Maintenance** | Generate_2 (tabel lebih sedikit) |
| **Query performance** | Generated_1 (tidak ada filter `model_type`) |
| **Learning curve** | Generated_1 (tidak perlu paham polymorphic) |
| **Scalability** | Generate_2 ( mudah tambah entity baru) |
| **Data integrity** | Generated_1 (FK eksplisit) |
| **Kode reuse** | Generate_2 (tidak ada duplikasi) |

### Rekomendasi Final

**Gunakan Generate_2 (Polymorphic)** dengan catatan:
1. **Media**: Pakai tabel `media` polymorphic.
2. **Facilities**: Pakai `facilities` + `model_has_facilities`.
3. **Display fields**: Pilih hybrid—yang sering di-query → relational; yang jarang → JSONB.
4. **Room inventories**: Tetap tabel terpisah dengan unique constraint + check constraint.
5. **Status flow**: Implementasi state machine di model `Property` dan `Hotel`.

**Alasan:** Generated_1 menghasilkan 34 tabel yang harus di-maintain, sedangkan Generate_2 hanya 29 tabel dengan manfaat fleksibilitas yang lebih besar untuk perkembangan sistem ke depan.

---

## 7. Action Items

1. ✅ Pilih **Generate_2** sebagai basis implementasi.
2. 🔄 Implementasi hybrid untuk display fields (relational + JSONB where appropriate).
3. 🔒 Tambahkan row-level locking untuk `room_inventories` saat booking.
4. 📝 Dokumentasikan state machine untuk `status` property/hotel.
5. 🧪 Buat feature test untuk approval flow (draft → pending → active).
