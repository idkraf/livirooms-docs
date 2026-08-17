<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyPromo extends Model
{
    protected $fillable = [
        'property_id',
        'code',
        'discount_type',
        'discount_value',
        'valid_from',
        'valid_until',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
