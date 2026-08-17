<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\Relations\MorphToMany;

class RoomType extends Model
{
    protected $table = 'room_types';

    protected $fillable = [
        'hotel_id',
        'name',
        'slug',
        'description',
        'capacity_adults',
        'capacity_children',
        'max_guests',
        'room_size_sqm',
        'bed_configuration',
        'base_price',
        'price_original',
        'breakfast_included',
        'total_inventory',
        'has_window',
        'no_smoking',
        'free_wifi',
        'is_active',
    ];

    protected $casts = [
        'capacity_adults' => 'integer',
        'capacity_children' => 'integer',
        'max_guests' => 'integer',
        'base_price' => 'decimal:2',
        'price_original' => 'decimal:2',
        'breakfast_included' => 'boolean',
        'total_inventory' => 'integer',
        'has_window' => 'boolean',
        'no_smoking' => 'boolean',
        'free_wifi' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }

    public function facilities(): MorphToMany
    {
        return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
            ->withPivot('is_available', 'sort_order')
            ->orderBy('sort_order');
    }

    public function media(): MorphMany
    {
        return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
    }

    public function inventories(): HasMany
    {
        return $this->hasMany(RoomInventory::class);
    }

    public function scopeAvailableForDates(Builder $query, string $checkIn, string $checkOut, int $requiredRooms = 1): Builder
    {
        $dates = generateDateRange($checkIn, $checkOut);
        $nightsCount = count($dates);

        return $query->whereHas('inventories', function (Builder $q) use ($dates, $requiredRooms) {
            $q->whereIn('date', $dates)
              ->where('is_closed', false)
              ->whereRaw('(allotment - booked_count) >= ?', [$requiredRooms]);
        }, '=', $nightsCount);
    }

    public function getImagesAttribute(): array
    {
        return $this->media->pluck('url')->toArray();
    }

    public function getFacilitiesAttribute(): array
    {
        return $this->facilities->pluck('name')->toArray();
    }
}
