<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyExtraDescription extends Model
{
    protected $fillable = [
        'property_id',
        'text',
        'sort_order',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
