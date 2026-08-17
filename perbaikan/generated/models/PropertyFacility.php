<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyFacility extends Model
{
    protected $fillable = [
        'property_id',
        'facility_id',
        'name',
        'is_available',
        'badge',
        'sort_order',
    ];

    protected $casts = [
        'is_available' => 'boolean',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function facility(): BelongsTo
    {
        return $this->belongsTo(Facility::class);
    }
}
