<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyCheckInNote extends Model
{
    protected $fillable = [
        'property_id',
        'icon',
        'title',
        'text',
        'tone',
        'sort_order',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
