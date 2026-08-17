<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HotelFacility extends Model
{
    protected $table = 'hotel_facilities';

    protected $fillable = [
        'hotel_facility_group_id',
        'name',
        'is_available',
        'badge',
        'sort_order',
    ];

    protected $casts = [
        'is_available' => 'boolean',
    ];

    public function group(): BelongsTo
    {
        return $this->belongsTo(HotelFacilityGroup::class, 'hotel_facility_group_id');
    }
}
