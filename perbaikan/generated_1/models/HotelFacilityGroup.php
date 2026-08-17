<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HotelFacilityGroup extends Model
{
    protected $table = 'hotel_facility_groups';

    protected $fillable = [
        'hotel_id',
        'name',
        'icon',
        'sort_order',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }

    public function facilities(): HasMany
    {
        return $this->hasMany(HotelFacility::class);
    }
}
