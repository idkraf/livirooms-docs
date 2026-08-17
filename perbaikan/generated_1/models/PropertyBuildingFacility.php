<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyBuildingFacility extends Model
{
    protected $fillable = [
        'property_id',
        'icon',
        'label',
        'is_highlighted',
        'sort_order',
    ];

    protected $casts = [
        'is_highlighted' => 'boolean',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
