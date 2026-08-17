<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RoomTypeFacility extends Model
{
    protected $fillable = [
        'room_type_id',
        'name',
        'is_available',
        'sort_order',
    ];

    protected $casts = [
        'is_available' => 'boolean',
    ];

    public function roomType(): BelongsTo
    {
        return $this->belongsTo(RoomType::class);
    }
}
