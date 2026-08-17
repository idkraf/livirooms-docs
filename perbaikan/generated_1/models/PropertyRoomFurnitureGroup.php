<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PropertyRoomFurnitureGroup extends Model
{
    protected $fillable = [
        'property_id',
        'name',
        'sort_order',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(PropertyRoomFurnitureItem::class);
    }
}
