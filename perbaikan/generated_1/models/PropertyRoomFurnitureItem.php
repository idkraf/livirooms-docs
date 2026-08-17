<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyRoomFurnitureItem extends Model
{
    protected $fillable = [
        'property_room_furniture_group_id',
        'icon',
        'label',
        'sort_order',
    ];

    public function group(): BelongsTo
    {
        return $this->belongsTo(PropertyRoomFurnitureGroup::class, 'property_room_furniture_group_id');
    }
}
