<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyBedFacility extends Model
{
    protected $fillable = [
        'property_id',
        'icon',
        'label',
        'note',
        'count',
        'sort_order',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
