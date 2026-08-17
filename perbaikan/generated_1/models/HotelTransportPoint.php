<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HotelTransportPoint extends Model
{
    protected $table = 'hotel_transport_points';

    protected $fillable = [
        'hotel_id',
        'name',
        'type',
        'distance',
        'duration',
        'icon',
        'sort_order',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }
}
