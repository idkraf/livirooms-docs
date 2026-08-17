<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyNearbyPlace extends Model
{
    protected $fillable = [
        'property_id',
        'name',
        'type',
        'distance',
        'icon',
        'sort_order',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
