<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertySpecialPrice extends Model
{
    protected $fillable = [
        'property_id',
        'min_nights',
        'discount_percent',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
