<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyAddOn extends Model
{
    protected $fillable = [
        'property_id',
        'name',
        'duration_note',
        'price',
        'info',
        'is_selected',
        'sort_order',
    ];

    protected $casts = [
        'is_selected' => 'boolean',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
