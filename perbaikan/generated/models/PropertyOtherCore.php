<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyOtherCore extends Model
{
    protected $table = 'property_other_core';

    protected $fillable = [
        'property_id',
        'province',
        'price_from',
        'rating',
        'review_count',
        'star_rating',
        'check_in_time',
        'check_out_time',
        'has_breakfast',
        'type_label',
        'area_label',
        'extra_media_count',
        'intro',
        'description_extra_heading',
        'map_preview',
        'price_caption',
        'is_flash_sale',
        'deposit_amount',
        'schedule_note',
    ];

    protected $casts = [
        'has_breakfast' => 'boolean',
        'is_flash_sale' => 'boolean',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }
}
