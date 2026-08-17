<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HotelPolicy extends Model
{
    protected $table = 'hotel_policies';

    protected $fillable = [
        'hotel_id',
        'receptionist_24h',
        'allow_children',
        'extra_bed_available',
        'child_policy',
        'extra_bed_policy',
        'smoking_policy',
        'deposit_amount',
        'deposit_currency',
    ];

    protected $casts = [
        'receptionist_24h' => 'boolean',
        'allow_children' => 'boolean',
        'extra_bed_available' => 'boolean',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }
}
